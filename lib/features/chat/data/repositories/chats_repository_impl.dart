import 'dart:async';

import 'package:cc/core/database/models/conversation.dart';
import 'package:isar/isar.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/database/database_initializer.dart';
import 'package:cc/core/database/models/user.dart';
import 'package:cc/core/database/models/conversation.dart' as db;
import 'package:cc/core/adapters/conversation_adapter.dart';
import 'package:cc/core/database/models/current_user.dart';
// 移除ConversationSyncEvent import，改用数据库监听
import 'package:cc/core/services/communication_service.dart';
import 'package:cc/features/chat/domain/repositories/chats_repository.dart';
import 'package:cc/features/chat/domain/entities/chat_state_snapshot.dart';
import 'package:cc/core/database/models/message.dart';

import 'package:cc/core/proto/generated/conversation.pb.dart'
    as conversation_proto;

/// ChatsRepository的实现类
/// 负责聊天会话列表相关的数据处理、会话管理等功能
class ChatsRepositoryImpl implements ChatsRepository {
  final LogService _logger = LogService.instance;
  final CommunicationService _communicationService = CommunicationService();

  final CurrentUser _currentUser;

  // 获取当前数据库实例，使用DatabaseInitializer
  Isar get _isar => DatabaseInitializer.isar;
  IsarCollection<User> get _users => _isar.users;
  IsarCollection<db.Conversation> get _conversations => _isar.conversations;

  // 💢💢💢💢💢💢💢💢💢💢💢💢💢💢  状态快照管理  💢💢💢💢💢💢💢💢💢💢💢💢💢💢

  // 状态快照缓存
  final Map<String, ChatStateSnapshot> _stateSnapshots =
      <String, ChatStateSnapshot>{};

  // 移除ConversationSyncEvent相关代码，改用数据库监听

  // 事件订阅列表
  final List<StreamSubscription> _subscriptions = [];

  // 💢💢💢 新增：去重机制，防止重复处理同步响应
  String? _lastSyncResponseHash;
  DateTime? _lastSyncResponseTime;
  static const Duration _deduplicationWindow = Duration(seconds: 5);

  // 构造函数
  ChatsRepositoryImpl({required CurrentUser currentUser})
      : _currentUser = currentUser {
    _logger.x('ChatsRepositoryImpl 初始化');
    _registerEventHandlers();
  }

  /// 💢💢💢💢💢💢💢💢💢💢💢💢💢💢  事件处理  💢💢💢💢💢💢💢💢💢💢💢💢💢💢

  /// 注册事件监听
  Future<void> _registerEventHandlers() async {
    if (!_communicationService.isInitialized) {
      _logger.i('通信服务未初始化，无法注册事件处理器');
      return;
    }
    _logger.i('注册事件处理器');

    // 先取消所有现有的监听器，防止重复注册
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();

    _logger.i('ChatsRepository Proto事件流 订阅');
    _subscriptions
      ..add(_communicationService
          .onProto<conversation_proto.ConversationCollection>(
              'conversation:sync:response')
          .listen(_handleSyncResponseProto))
      ..add(_communicationService
          .onProto<conversation_proto.ConversationUpdateNotification>(
              'conversation:update:notification')
          .listen(_handleConversationUpdateNotification))
      ..add(_communicationService
          .onProto<conversation_proto.ConversationSettingsUpdateResponse>(
              'conversation:settings:updated')
          .listen(_handleConversationSettingsUpdate))
      ..add(_communicationService
          .onProto<conversation_proto.UserJoinedNotification>(
              'conversation:user:joined')
          .listen(_handleUserJoinedNotification))
      ..add(_communicationService
          .onProto<conversation_proto.UserLeftNotification>(
              'conversation:user:left')
          .listen(_handleUserLeftNotification))
      ..add(_communicationService
          .onProto<conversation_proto.ConversationDetailResponse>(
              'conversation:detail:response')
          .listen(_handleConversationDetailResponse))
      ..add(_communicationService
          .onProto<conversation_proto.ParticipantStatusUpdateResponse>(
              'participant:status:update:response')
          .listen(_handleParticipantStatusUpdateResponse))
      ..add(_communicationService
          .onProto<conversation_proto.ConversationJoinLeaveResponse>(
              'conversation:leave:response')
          .listen(_handleConversationLeaveResponse));
  }

  /// 获取联系人信息
  /// 根据ID获取单个联系人详情
  /// [userId] - 联系人ID
  /// 返回联系人信息,不存在则返回null
  @override
  Future<User?> getContactById(String userId) async {
    try {
      // 使用userId字段查询，而不是尝试转换为整数ID
      return await _users.filter().userIdEqualTo(userId).findFirst();
    } catch (error) {
      _logger.e('获取联系人信息失败', error: error, stackTrace: StackTrace.current);
      return null;
    }
  }

  // /// 获取当前用户ID
  // /// 直接从数据库获取当前登录用户的ID
  // /// 返回用户ID,如未找到则抛出异常
  // Future<String> _getCurrentUserId() async {
  //   try {
  //     if (!DatabaseInitializer.isInitialized) {
  //       throw Exception('数据库未初始化，请确保已登录');
  //     }

  //     final currentUsers =
  //         await DatabaseInitializer.isar.currentUsers.where().findAll();

  //     if (currentUsers.isEmpty) {
  //       throw Exception('找不到当前用户信息，请确保已登录');
  //     }

  //     // 返回第一个用户的ID（通常只会有一个用户记录）
  //     return currentUsers.first.userId;
  //   } catch (e) {
  //     throw Exception('获取当前用户ID失败: ${e.toString()}');
  //   }
  // }

  /// 获取所有会话
  /// 从本地数据库获取所有会话
  /// 返回会话列表
  @override
  Future<List<db.Conversation>> getAllConversations() async {
    try {
      _logger.i('从本地数据库获取所有会话');

      // 直接从数据库获取会话列表，不发送同步事件
      final conversations = await _conversations.where().findAll();

      _logger.d('成功获取会话列表', extra: {'会话数量': conversations.length});
      return conversations;
    } catch (error, stack) {
      _logger.e('获取会话列表失败', error: error, stackTrace: stack);
      return [];
    }
  }

  /// 更新本地会话数据
  /// 将服务器返回的会话数据保存到本地数据库
  /// [serverConversations] - 从服务器获取的会话列表
  Future<void> _updateLocalConversations(
      List<db.Conversation> serverConversations) async {
    try {
      _logger.i('更新数据库会话数据', extra: {'会话数': serverConversations.length});
      await _isar.writeTxn(() async {
        for (final conversation in serverConversations) {
          // 检查会话是否已存在
          final existing = await _conversations
              .filter()
              .conversationIdEqualTo(conversation.conversationId)
              .findFirst();

          if (existing != null) {
            // 只有当服务器的最后消息时间更新时才更新本地数据
            if (conversation.lastMessageTime != null &&
                (existing.lastMessageTime == null ||
                    conversation.lastMessageTime!
                        .isAfter(existing.lastMessageTime!))) {
              conversation.id = existing.id;
              await _conversations.put(conversation);

              // ✅ 已移除会话更新事件流，改用数据库监听
            }

            // 🔥 新增：检查边界信息，如果缺失则请求详细信息
            if (conversation.firstMessageIndex <= 0 ||
                conversation.lastMessageIndex <= 0) {
              _logger.w('会话缺失边界信息，请求详细数据', extra: {
                'conversationId': conversation.conversationId,
                'firstMessageIndex': conversation.firstMessageIndex,
                'lastMessageIndex': conversation.lastMessageIndex,
              });

              // 异步请求详细信息，不阻塞当前流程
              requestConversationDetail(conversation.conversationId).ignore();
            }
          } else {
            // 添加新会话
            await _conversations.put(conversation);

            // ✅ 已移除会话更新事件流，改用数据库监听
          }
        }
      });
    } catch (error) {
      _logger.e('更新本地会话数据失败', extra: {'error': error.toString()});
      throw Exception('更新本地会话数据失败: $error');
    }
  }

  /// 获取会话信息
  /// 根据ID获取单个会话详情
  /// [conversationId] - 会话ID
  /// 返回会话信息,不存在则返回null
  @override
  Future<db.Conversation?> getConversationById(String conversationId) async {
    try {
      // 使用conversationId字段查询，而不是尝试转换为整数ID
      return await _conversations
          .filter()
          .conversationIdEqualTo(conversationId)
          .findFirst();
    } catch (error) {
      _logger.e('获取会话信息失败', error: error, stackTrace: StackTrace.current);
      return null;
    }
  }

  /// 获取或创建私聊会话
  /// 根据联系人ID查找已有会话,不存在则通过服务器创建新会话
  /// [contactUserId] - 联系人ID
  /// 返回会话对象
  @override
  Future<db.Conversation> getOrCreatePrivateConversation(
      String contactUserId) async {
    try {
      _logger.i('获取或创建私聊会话', extra: {'contactUserId': contactUserId});

      // 先查找已有的私聊会话
      final existing = await _conversations
          .filter()
          .typeEqualTo(db.ConversationType.private)
          .and()
          .contactUserIdEqualTo(contactUserId)
          .findFirst();

      if (existing != null) {
        _logger.i('找到已存在的私聊会话', extra: {
          'conversationId': existing.conversationId,
          'contactUserId': contactUserId,
        });
        return existing;
      }

      // 💢💢💢 修改：通过服务器创建新会话，而不是本地乐观创建
      _logger.i('未找到已存在会话，通过服务器创建新私聊会话');

      if (!_communicationService.isInitialized) {
        throw Exception('通信服务未初始化，无法创建会话');
      }

      // 获取联系人信息
      final contact = await getContactById(contactUserId);
      if (contact == null) {
        throw Exception('联系人不存在');
      }

      // 💢💢💢 创建会话请求
      final createRequest = conversation_proto.ConversationCreateRequest()
        ..type = conversation_proto.ConversationType.PRIVATE
        ..contactUserId = contactUserId
        ..name = contact.name;

      // 设置头像（如果有）
      if (contact.avatar != null && contact.avatar!.isNotEmpty) {
        createRequest.avatar = contact.avatar!;
      }

      _logger.d('发送创建会话请求', extra: {
        'contactUserId': contactUserId,
        'contactName': contact.name,
      });

      // 💢💢💢 发送创建请求到服务器
      final success = await _communicationService.emitProto(
          'conversation:create', createRequest);

      if (!success) {
        throw Exception('发送创建会话请求失败');
      }

      // 💢💢💢 等待服务器响应
      try {
        final response = await _communicationService
            .onProto<conversation_proto.ConversationCreateResponse>(
                'conversation:create:response')
            .timeout(const Duration(seconds: 10))
            .first;

        if (!response.success) {
          throw Exception('服务器创建会话失败: ${response.message}');
        }

        if (!response.hasConversation()) {
          throw Exception('服务器响应中缺少会话数据');
        }

        _logger.i('服务器创建会话成功', extra: {
          'conversationId': response.conversation.conversationId,
          'contactUserId': contactUserId,
        });

        // 💢💢💢 将服务器返回的会话数据保存到本地数据库
        final conversation = ConversationAdapter.fromProto(
          response.conversation,
          currentUserId: _currentUser.userId,
        );

        await _isar.writeTxn(() async {
          await _conversations.put(conversation);
        });

        return conversation;
      } on TimeoutException {
        _logger.e('等待服务器创建会话响应超时');
        throw Exception('创建会话超时，请重试');
      }
    } catch (error) {
      _logger.e('获取或创建私聊会话失败',
          error: error,
          stackTrace: StackTrace.current,
          extra: {'contactUserId': contactUserId});
      rethrow;
    }
  }

  /// 创建群聊会话
  /// 创建新的群组会话并添加成员
  /// [name] - 群聊名称
  /// [memberIds] - 群成员ID列表
  /// [avatar] - 可选的群头像
  /// 返回创建的群聊会话
  @override
  Future<db.Conversation> createGroupConversation(
      String name, List<String> memberIds,
      {String? avatar}) async {
    try {
      // 创建新的群聊会话
      final conversation = db.Conversation()
        ..type = db.ConversationType.group
        ..name = name
        ..avatar = avatar
        ..createdAt = DateTime.now();

      await _isar.writeTxn(() async {
        // 保存会话
        conversation.id = await _conversations.put(conversation);
        await _conversations.put(conversation);

        // 添加当前用户
        final currentUser = await getContactById(_currentUser.userId);
        if (currentUser != null) {
          final currentParticipant = _userToParticipant(currentUser);
          conversation.participants.add(currentParticipant);
        }

        // 添加其他成员
        for (final memberId in memberIds) {
          final member = await getContactById(memberId);
          if (member != null) {
            final memberParticipant = _userToParticipant(member);
            conversation.participants.add(memberParticipant);
          }
        }
      });

      return conversation;
    } catch (error) {
      _logger.e('创建群聊失败', error: error, stackTrace: StackTrace.current);
      rethrow;
    }
  }

  /// 监听会话变化
  /// 返回会话列表变化的流
  @override
  Stream<void> watchConversations() {
    return _conversations.watchLazy();
  }

  /// 💢💢💢 新增：监听单个会话变化
  /// 用于 ChatCubit 监听特定会话的状态变化
  @override
  Stream<Conversation?> watchConversation(String conversationId) {
    return _conversations
        .filter()
        .conversationIdEqualTo(conversationId)
        .watch(fireImmediately: false)
        .map((conversations) =>
            conversations.isNotEmpty ? conversations.first : null);
  }

  /// 删除会话
  /// 删除指定的会话及其所有消息和相关媒体文件
  /// [conversationId] - 会话ID
  @override
  Future<void> deleteConversation(String conversationId) async {
    try {
      final id = int.tryParse(conversationId) ?? 0;

      await _isar.writeTxn(() async {
        // 删除会话本身
        final success = await _conversations.delete(id);
        if (!success) {
          throw Exception('找不到要删除的会话');
        }
      });
    } catch (error) {
      _logger.e('删除会话失败', error: error, stackTrace: StackTrace.current);
      rethrow;
    }
  }

  /// 创建或获取与用户的对话
  /// 如果已存在与该用户的一对一会话,则返回该会话ID
  /// 否则创建新会话并返回ID
  /// [userId] - 目标用户ID
  @override
  Future<String?> createOrGetConversation(String userId) async {
    try {
      _logger.i('获取或创建与用户的会话', extra: {'userId': userId});

      // 检查是否已有与该用户的私聊会话
      final existingConversation = await _conversations
          .filter()
          .typeEqualTo(db.ConversationType.private)
          .and()
          .contactUserIdEqualTo(userId)
          .findFirst();

      if (existingConversation != null) {
        _logger.i('找到已存在的会话',
            extra: {'conversationId': existingConversation.conversationId});
        return existingConversation.conversationId;
      }

      // 获取目标用户信息
      final contactUser =
          await _users.filter().userIdEqualTo(userId).findFirst();
      if (contactUser == null) {
        _logger.e('未找到目标用户信息', extra: {'userId': userId});
        return null;
      }

      // 创建新会话
      final conversation = db.Conversation()
        ..type = db.ConversationType.private
        ..name = contactUser.name
        ..contactUserId = userId
        ..avatar = contactUser.avatar
        ..createdAt = DateTime.now();

      // 保存会话
      await _isar.writeTxn(() async {
        await _conversations.put(conversation);
        // 参与者信息已经包含在conversation对象中，无需单独保存
      });

      _logger
          .i('创建了新会话', extra: {'conversationId': conversation.conversationId});
      return conversation.conversationId;
    } catch (error) {
      _logger.e('创建或获取会话失败', error: error, stackTrace: StackTrace.current);
      return null;
    }
  }

  /// 监听联系人变化
  /// 返回联系人列表变化的流
  @override
  Stream<void> watchContacts() {
    return _users.watchLazy();
  }

  /// 请求同步会话列表
  /// 从服务器同步最新的会话数据
  /// 会话数据将通过事件通知并由状态管理系统更新UI
  @override
  Future<void> requestSyncConversations() async {
    try {
      if (_communicationService.isInitialized) {
        // 发送无参数的同步请求，服务器会根据当前用户ID返回所有会话
        _communicationService.emitProto(
            'conversation:sync', conversation_proto.SyncConversationsRequest());
        _logger.i('会话同步请求已发送');
      } else {
        _logger.e('通信服务未初始化，无法同步会话');
      }
    } catch (error, stack) {
      _logger.e('同步会话失败', error: error, stackTrace: stack);
      rethrow;
    }
  }

  /// 统一更新参与者设置（静音、置顶、已读状态）
  @override
  Future<void> updateParticipantSettings(
    String conversationId, {
    int? readMessageIndex,
    bool? muted,
    bool? pinned,
  }) async {
    _logger.i('更新参与者设置', extra: {
      'conversationId': conversationId,
      'readMessageIndex': readMessageIndex,
      'muted': muted,
      'pinned': pinned,
    });

    try {
      // 同步到服务器
      if (_communicationService.isInitialized) {
        _logger.i('开始同步参与者设置到服务器');

        // 创建参与者设置更新请求
        final participantUpdateRequest =
            conversation_proto.ParticipantStatusUpdateRequest()
              ..conversationId = conversationId;

        // 设置可选字段
        if (readMessageIndex != null) {
          participantUpdateRequest.readMessageIndex = readMessageIndex;
        }
        if (muted != null) {
          participantUpdateRequest.muted = muted;
        }
        if (pinned != null) {
          participantUpdateRequest.pinned = pinned;
        }

        // 发送请求到服务器
        _communicationService.emitProto(
            'participant:status:update', participantUpdateRequest);

        // 服务器响应会通过_handleParticipantSettingsUpdate方法处理
      } else {
        _logger.w('通信服务未初始化，无法同步参与者设置到服务器');
      }
    } catch (error) {
      _logger.e('更新参与者设置失败', error: error);
      throw Exception('更新参与者设置失败: ${error.toString()}');
    }
  }

  /// 根据标签过滤会话
  ///
  /// 根据标签类型过滤会话列表
  /// [tabIndex] - 标签索引
  /// 返回过滤后的会话列表
  @override
  Future<List<db.Conversation>> filterConversationsByTab(int tabIndex) async {
    try {
      _logger.d('根据标签过滤会话', extra: {'tabIndex': tabIndex});

      // 获取所有会话
      final conversations = await getAllConversations();

      // 根据标签类型过滤
      switch (tabIndex) {
        case 0: // 全部会话
          return conversations;
        case 1: // 私聊
          return conversations
              .where((c) => c.type == db.ConversationType.private)
              .toList();
        case 2: // 群组
          return conversations
              .where((c) => c.type == db.ConversationType.group)
              .toList();
        case 3: // 频道
          return conversations
              .where((c) => c.type == db.ConversationType.channel)
              .toList();
        case 4: // 未读
          // 💢💢💢 需要当前用户ID来判断未读状态
          final currentUserId = _currentUser.userId;
          return conversations
              .where((c) => c.unreadCount(currentUserId) > 0)
              .toList();
        default:
          return conversations;
      }
    } catch (error) {
      _logger.e('过滤会话失败', error: error, stackTrace: StackTrace.current);
      // 发生错误时返回空列表
      return [];
    }
  }

  /// 更新会话设置
  ///
  /// 更新会话的静音或置顶状态
  /// [conversationId] - 会话ID
  /// [muted] - 是否静音
  /// [pinned] - 是否置顶
  /// 返回是否更新成功
  @override
  Future<bool> updateConversationSettings(String conversationId,
      {bool? muted, bool? pinned}) async {
    try {
      _logger.i('更新会话设置', extra: {
        'conversationId': conversationId,
        'muted': muted,
        'pinned': pinned
      });

      // 验证参数
      if (muted == null && pinned == null) {
        _logger.w('更新会话设置时没有提供有效参数');
        return false;
      }

      // 更新本地数据库
      final conversation = await _conversations
          .filter()
          .conversationIdEqualTo(conversationId)
          .findFirst();

      if (conversation == null) {
        _logger.e('找不到指定会话', extra: {'conversationId': conversationId});
        return false;
      }

      // 使用事务包装数据库写入操作
      await _isar.writeTxn(() async {
        final currentUserId = _currentUser.userId;
        if (muted != null || pinned != null) {
          conversation.updateCurrentUserSettings(
            currentUserId: currentUserId,
            muted: muted,
            pinned: pinned,
          );
        }
        await _conversations.put(conversation);
      });

      _logger.i('本地数据库会话设置已更新');

      // 同步到服务器
      if (_communicationService.isInitialized) {
        _logger.i('开始同步会话设置到服务器');

        // 创建会话设置更新请求
        final settingsRequest =
            conversation_proto.ConversationSettingsUpdateRequest()
              ..conversationId = conversationId;

        if (muted != null) settingsRequest.muted = muted;
        if (pinned != null) settingsRequest.pinned = pinned;

        // 发送请求到服务器
        _communicationService.emitProto(
            'conversation:settings:update', settingsRequest);

        // 监听服务器响应
        _communicationService
            .onProto<conversation_proto.ConversationSettingsUpdateResponse>(
                'conversation:settings:update:response')
            .first
            .then((response) {
          if (response.success) {
            _logger.i('服务器已更新会话设置', extra: {
              'conversationId': response.conversationId,
              'muted': response.muted,
              'pinned': response.pinned
            });

            // ✅ 已移除会话更新事件流，改用数据库监听
          } else {
            _logger.w('服务器更新会话设置失败',
                extra: {'conversationId': response.conversationId});
          }
        }).catchError((error) {
          _logger.e('接收服务器设置更新响应时出错', error: error);
        });

        return true;
      } else {
        _logger.w('通信服务未初始化，无法同步会话设置到服务器');
        // 即使无法同步到服务器，也认为更新成功，因为本地数据库已更新
        return true;
      }
    } catch (error) {
      _logger.e('更新会话设置失败', error: error, stackTrace: StackTrace.current);
      return false;
    }
  }

  @override
  Stream<List<String>> getOnlineStatusStream() {
    // TODO 实现获取联系人在线状态流
    // 这里应该监听服务器推送的在线状态更新
    return const Stream.empty();
  }

  @override
  Future<void> requestConversationDetail(String conversationId) async {
    try {
      _logger.i('从服务器获取会话详情', extra: {'conversationId': conversationId});

      if (!_communicationService.isInitialized) {
        _logger.w('通信服务未初始化，无法获取会话详情');
        return;
      }

      // 创建获取会话详情请求
      final detailRequest = conversation_proto.ConversationDetailRequest()
        ..conversationId = conversationId;

      // 发送请求到服务器
      _communicationService.emitProto(
          'conversation:detail:request', detailRequest);

      return;
    } catch (error, stackTrace) {
      _logger.e('从服务器获取会话详情失败', error: error, stackTrace: stackTrace);
      return;
    }
  }

  /// 处理会话同步响应事件
  /// 将Proto格式的会话数据转换为数据库模型并更新本地数据
  void _handleSyncResponseProto(
      conversation_proto.ConversationCollection collection) async {
    _logger.i('收到会话同步响应',
        extra: {'conversations': collection.conversations.length});

    // 💢💢💢 新增：去重机制，防止重复处理同步响应
    final currentSyncResponseHash = collection.hashCode.toString();
    final currentSyncResponseTime = DateTime.now();

    if (_lastSyncResponseHash == currentSyncResponseHash &&
        _lastSyncResponseTime != null &&
        currentSyncResponseTime.difference(_lastSyncResponseTime!).inSeconds <=
            _deduplicationWindow.inSeconds) {
      _logger.i('重复的同步响应，已忽略', extra: {
        'hash': currentSyncResponseHash,
        'timeDiff': currentSyncResponseTime
            .difference(_lastSyncResponseTime!)
            .inSeconds,
      });
      return;
    }

    _lastSyncResponseHash = currentSyncResponseHash;
    _lastSyncResponseTime = currentSyncResponseTime;

    try {
      if (collection.conversations.isEmpty) {
        _logger.i('会话列表为空，这可能是新用户或同步过程中的正常状态');
        return;
      }

      // 转换为数据库对象 - 使用适配器转换方法
      final List<db.Conversation> dbConversations = collection.conversations
          .map((conv) => ConversationAdapter.fromProto(conv))
          .toList();

      // 更新本地数据库，数据库变化会自动触发UI更新
      await _updateLocalConversations(dbConversations);

      _logger.i('会话同步完成，数据库已更新');
    } catch (e, stack) {
      _logger.e('处理同步响应数据失败', error: e, stackTrace: stack);
    }
  }

  /// 处理会话更新通知
  /// 根据服务器推送的会话更新通知更新本地会话数据
  /// [notification] - 会话更新通知数据
  void _handleConversationUpdateNotification(
      conversation_proto.ConversationUpdateNotification notification) {
    try {
      _logger.i('收到会话更新通知',
          extra: {'conversationId': notification.conversationId});

      // 更新本地会话数据
      _isar.writeTxn(() async {
        // 查找本地会话
        final conversation = await _conversations
            .filter()
            .conversationIdEqualTo(notification.conversationId)
            .findFirst();

        if (conversation != null) {
          // 更新会话信息
          conversation.lastMessageName = notification.lastMessageName;
          conversation.lastMessagePreview = notification.lastMessagePreview;
          conversation.lastMessageIndex = notification.lastMessageIndex.toInt();

          // 更新当前用户的未读数量
          final currentUserId = _currentUser.userId;
          conversation.updateCurrentUserSettings(
            currentUserId: currentUserId,
          );

          // 保存更新后的会话
          await _conversations.put(conversation);
          _logger.d('已更新本地会话数据',
              extra: {'conversationId': notification.conversationId});

          // ✅ 已移除会话更新事件流，改用数据库监听
        } else {
          _logger.w('本地找不到对应的会话',
              extra: {'conversationId': notification.conversationId});

          await requestConversationDetail(notification.conversationId);
        }
      });
    } catch (error, stackTrace) {
      _logger.e('处理会话更新通知失败', error: error, stackTrace: stackTrace);
    }
  }

  /// 处理用户加入会话通知
  /// 当其他用户加入会话时接收到的通知
  /// [notification] - 用户加入通知数据
  void _handleUserJoinedNotification(
      conversation_proto.UserJoinedNotification notification) {
    try {
      _logger.i('收到用户加入会话通知', extra: {
        'conversationId': notification.conversationId,
        'userId': notification.userId,
        'userName': notification.userName
      });

      // TODO 更新会话参与者列表
      // 需要获取用户信息并添加到会话参与者中
    } catch (error, stackTrace) {
      _logger.e('处理用户加入会话通知失败', error: error, stackTrace: stackTrace);
    }
  }

  /// 处理用户离开会话通知
  /// 当其他用户离开会话时接收到的通知
  /// [notification] - 用户离开通知数据
  void _handleUserLeftNotification(
      conversation_proto.UserLeftNotification notification) {
    try {
      _logger.i('收到用户离开会话通知', extra: {
        'conversationId': notification.conversationId,
        'userId': notification.userId,
        'userName': notification.userName,
        'reason': notification.reason
      });

      // TODO 更新会话参与者列表
      // 需要从会话参与者中移除该用户
    } catch (error, stackTrace) {
      _logger.e('处理用户离开会话通知失败', error: error, stackTrace: stackTrace);
    }
  }

  /// 处理会话设置更新响应
  /// 监听服务器推送的会话设置变更（如静音、置顶状态）并更新本地数据库
  /// 主要用于处理来自其他设备同步的设置变更
  /// [response] - 会话设置更新响应数据
  void _handleConversationSettingsUpdate(
      conversation_proto.ConversationSettingsUpdateResponse response) {
    try {
      _logger.i('收到会话设置更新通知', extra: {
        'conversationId': response.conversationId,
        'success': response.success,
        'muted': response.hasMuted() ? response.muted : '未变更',
        'pinned': response.hasPinned() ? response.pinned : '未变更'
      });

      if (!response.success) {
        _logger
            .w('会话设置更新失败', extra: {'conversationId': response.conversationId});
        return;
      }

      // 更新本地会话数据
      _isar.writeTxn(() async {
        // 查找本地会话
        final conversation = await _conversations
            .filter()
            .conversationIdEqualTo(response.conversationId)
            .findFirst();

        if (conversation != null) {
          final currentUserId = _currentUser.userId;

          // 更新静音状态
          if (response.hasMuted()) {
            conversation.updateCurrentUserSettings(
              currentUserId: currentUserId,
              muted: response.muted,
            );
            _logger.d('已更新会话静音状态', extra: {
              'conversationId': response.conversationId,
              'muted': response.muted
            });
          }

          // 更新置顶状态
          if (response.hasPinned()) {
            conversation.updateCurrentUserSettings(
              currentUserId: currentUserId,
              pinned: response.pinned,
            );
            _logger.d('已更新会话置顶状态', extra: {
              'conversationId': response.conversationId,
              'pinned': response.pinned
            });
          }

          // 保存更新后的会话
          await _conversations.put(conversation);
          _logger.d('已更新本地会话设置',
              extra: {'conversationId': response.conversationId});
        } else {
          _logger.w('本地找不到对应的会话',
              extra: {'conversationId': response.conversationId});
        }
      });
    } catch (error, stackTrace) {
      _logger.e('处理会话设置更新响应失败', error: error, stackTrace: stackTrace);
    }
  }

  void _handleConversationDetailResponse(
      conversation_proto.ConversationDetailResponse response) async {
    if (response.success && response.hasConversation()) {
      final conversation = ConversationAdapter.fromProto(response.conversation);
      _logger.i('成功获取会话详情', extra: {
        'conversationId': conversation.conversationId,
        'conversationType': conversation.type.name
      });
      await _isar.writeTxn(() async {
        await _conversations.put(conversation);
      });

      _logger.d('已将会话详情保存到本地数据库');

      // ✅ 已移除会话更新事件流，改用数据库监听
    }
  }

  /// 处理参与者状态更新响应
  void _handleParticipantStatusUpdateResponse(
      conversation_proto.ParticipantStatusUpdateResponse response) async {
    try {
      _logger.i('收到参与者状态更新响应', extra: {
        'conversationId': response.conversationId,
        'success': response.success,
      });

      if (!response.success) {
        _logger.w('参与者状态更新失败', extra: {
          'conversationId': response.conversationId,
        });
        return;
      }

      if (!response.hasParticipant()) {
        _logger.w('参与者状态更新响应中缺少参与者信息', extra: {
          'conversationId': response.conversationId,
        });
        return;
      }

      // 更新本地数据库
      await _isar.writeTxn(() async {
        // 查找本地会话
        final conversation = await _conversations
            .filter()
            .conversationIdEqualTo(response.conversationId)
            .findFirst();

        if (conversation != null) {
          final participant = response.participant;
          final currentUserId = _currentUser.userId;

          // 只有当更新的是当前用户的参与者信息时才更新本地设置
          if (participant.userId == currentUserId) {
            conversation.updateCurrentUserSettings(
              currentUserId: currentUserId,
              readMessageIndex: participant.readMessageIndex,
              muted: participant.muted,
              pinned: participant.pinned,
            );

            _logger.d('已更新当前用户的参与者设置', extra: {
              'conversationId': response.conversationId,
              'readMessageIndex': participant.readMessageIndex,
              'muted': participant.muted,
              'pinned': participant.pinned,
            });
          } else {
            // 更新其他参与者的信息
            final existingParticipantIndex = conversation.participants
                .indexWhere((p) => p.userId == participant.userId);

            if (existingParticipantIndex != -1) {
              // 更新现有参与者
              conversation.participants[existingParticipantIndex] =
                  ConversationAdapter.participantFromProto(participant);
              _logger.d('已更新其他参与者信息', extra: {
                'conversationId': response.conversationId,
                'userId': participant.userId,
              });
            }
          }

          // 保存更新后的会话
          await _conversations.put(conversation);
          _logger.d('参与者状态更新完成',
              extra: {'conversationId': response.conversationId});
        } else {
          _logger.w('本地找不到对应的会话',
              extra: {'conversationId': response.conversationId});
        }
      });
    } catch (error, stackTrace) {
      _logger.e('处理参与者状态更新响应失败', error: error, stackTrace: stackTrace);
    }
  }

  /// 处理会话离开响应
  void _handleConversationLeaveResponse(
      conversation_proto.ConversationJoinLeaveResponse response) async {
    try {
      _logger.i('收到会话离开响应', extra: {
        'conversationId': response.conversationId,
        'success': response.success,
        'message': response.message,
      });

      if (!response.success) {
        _logger.w('会话离开失败', extra: {
          'conversationId': response.conversationId,
          'message': response.message,
        });
        return;
      }

      // 更新本地数据库 - 更新最后阅读时间
      await updateConversationLastReadTime(response.conversationId);
    } catch (error, stackTrace) {
      _logger.e('处理会话离开响应失败', error: error, stackTrace: stackTrace);
    }
  }

  /// 更新会话的最后阅读时间
  @override
  Future<void> updateConversationLastReadTime(
    String conversationId, {
    DateTime? readTime,
  }) async {
    try {
      await _isar.writeTxn(() async {
        // 查找本地会话
        final conversation = await _conversations
            .filter()
            .conversationIdEqualTo(conversationId)
            .findFirst();

        if (conversation != null) {
          final currentUserId = _currentUser.userId;

          // 更新当前用户的最后阅读时间
          conversation.updateLastReadTime(currentUserId, readTime: readTime);

          // 保存更新后的会话
          await _conversations.put(conversation);

          _logger.d('已更新会话的最后阅读时间', extra: {
            'conversationId': conversationId,
            'lastReadTime': conversation.lastReadTime?.toIso8601String(),
          });
        } else {
          _logger.w('本地找不到对应的会话', extra: {'conversationId': conversationId});
        }
      });
    } catch (error, stackTrace) {
      _logger.e('更新会话最后阅读时间失败', error: error, stackTrace: stackTrace);
    }
  }

  /// 💢💢💢💢💢💢💢💢💢💢💢💢💢💢   状态快照管理   💢💢💢💢💢💢💢💢💢💢💢💢💢💢

  /// 保存会话状态快照
  @override
  Future<void> saveStateSnapshot(
      ChatStateSnapshot snapshot, String conversationId) async {
    try {
      // 💢💢💢 深拷贝消息列表以确保数据独立性
      final snapshotWithCopiedMessages = snapshot.copyWith(
        messages: List<Message>.from(snapshot.messages),
      );

      _stateSnapshots[conversationId] = snapshotWithCopiedMessages;

      _logger.d('💾 保存会话状态快照', extra: {
        'conversationId': conversationId,
        'messageCount': snapshot.messages.length,
        'currentScrollPosition': snapshot.currentScrollPosition?.messageIndex,
      });
    } catch (error) {
      _logger.e('保存状态快照失败', error: error);
    }
  }

  /// 获取会话状态快照
  @override
  Future<ChatStateSnapshot?> getStateSnapshot(String conversationId) async {
    try {
      final snapshot = _stateSnapshots[conversationId];

      if (snapshot != null && snapshot.isValid) {
        _logger.d('📖 获取会话状态快照', extra: {
          'conversationId': conversationId,
          'messageCount': snapshot.messages.length,
          'age': snapshot.ageInSeconds,
        });
        return snapshot;
      } else if (snapshot != null) {
        // 快照过期，清除
        _stateSnapshots.remove(conversationId);
        _logger.d('🗑️ 会话状态快照已过期', extra: {
          'conversationId': conversationId,
          'age': snapshot.ageInSeconds,
        });
      }

      return null;
    } catch (error) {
      _logger.e('获取状态快照失败', error: error);
      return null;
    }
  }

  /// 清除指定会话的状态快照
  @override
  Future<void> clearStateSnapshot(String conversationId) async {
    try {
      final removed = _stateSnapshots.remove(conversationId);
      if (removed != null) {
        _logger.d('🗑️ 清除会话状态快照', extra: {
          'conversationId': conversationId,
          'remainingSnapshots': _stateSnapshots.length,
        });
      }
    } catch (error) {
      _logger.e('清除状态快照失败', error: error);
    }
  }

  /// 清除所有过期的状态快照
  @override
  Future<void> cleanupExpiredSnapshots() async {
    try {
      final expiredKeys = _stateSnapshots.entries
          .where((entry) => !entry.value.isValid)
          .map((entry) => entry.key)
          .toList();

      for (final key in expiredKeys) {
        _stateSnapshots.remove(key);
      }

      if (expiredKeys.isNotEmpty) {
        _logger.d('🗑️ 清理过期状态快照', extra: {
          'cleanedCount': expiredKeys.length,
          'remainingCount': _stateSnapshots.length,
        });
      }
    } catch (error) {
      _logger.e('清理过期状态快照失败', error: error);
    }
  }

  /// 获取当前状态快照数量（用于监控和调试）
  @override
  int get stateSnapshotCount => _stateSnapshots.length;

  /// 将User对象转换为Participant对象
  Participant _userToParticipant(User user) {
    return Participant.create(
      userId: user.userId,
      name: user.name,
      avatar: user.avatar ?? '',
      unreadCount: 0,
      muted: false,
      pinned: false,
      joinedAt: DateTime.now(),
      deliveredMessageIndex: 0,
      readMessageIndex: 0,
      role: MemberRole.member,
      online: user.status == 'online',
      isActive: true,
    );
  }

  /// 释放资源
  /// 取消所有订阅
  void dispose() {
    _logger.i('销毁ChatsRepository');
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    // ✅ 已移除会话同步事件流相关代码
  }
}
