import 'dart:async';

import 'package:cc/core/database/models/conversation.dart';
import 'package:isar/isar.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/database/database_initializer.dart';
import 'package:cc/core/database/models/user.dart';
import 'package:cc/core/database/models/conversation.dart' as db;
import 'package:cc/core/adapters/conversation_adapter.dart';
import 'package:cc/core/database/models/current_user.dart';
import 'package:cc/core/services/communication_service.dart';
import 'package:cc/core/services/proto_socket_service.dart';
import 'package:cc/features/chat/domain/repositories/chats_repository.dart';
import 'package:cc/features/chat/domain/entities/chat_state_snapshot.dart';
import 'package:cc/features/chat/domain/entities/conversation_update_event.dart';
import 'package:cc/core/database/models/message.dart';
import 'package:cc/core/utils/message_sort_utils.dart';

import 'package:cc/core/proto/generated/conversation.pb.dart'
    as conversation_proto;
import 'package:cc/core/services/secure_storage_service.dart';
import 'package:fixnum/fixnum.dart';

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

  // 💢💢💢 新架构：会话更新事件流控制器
  final StreamController<ConversationUpdateEvent>
      _conversationUpdateController =
      StreamController<ConversationUpdateEvent>.broadcast();

  // 事件订阅列表
  final List<StreamSubscription> _subscriptions = [];

  /// 💢💢💢 新架构：通知会话更新事件
  void _notifyConversationUpdate(ConversationUpdateEvent event) {
    if (!_conversationUpdateController.isClosed) {
      _conversationUpdateController.add(event);
    }
  }

  // 构造函数
  ChatsRepositoryImpl({required CurrentUser currentUser})
      : _currentUser = currentUser {
    _logger.x('ChatsRepositoryImpl 初始化');
    _registerEventHandlers();
  }

  /// 💢💢💢💢💢💢💢💢💢💢💢💢💢💢  事件处理  💢💢💢💢💢💢💢💢💢💢💢💢💢💢

  /// 设置联系人更新监听器
  void _setupContactUpdateListener() {
    try {
      final protoSocketService = ProtoSocketService();
      protoSocketService.on('local:conversation:contact_updated',
          _handleContactUpdatedForConversations);
      _logger.i('联系人更新监听器设置成功');
    } catch (e) {
      _logger.e('设置联系人更新监听器失败', extra: {'error': e.toString()});
    }
  }

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

    // 监听本地联系人更新事件，用于更新私聊会话名称
    _setupContactUpdateListener();
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
            conversation.id = existing.id;
            await _conversations.put(conversation);
          } else {
            // 添加新会话
            await _conversations.put(conversation);
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

  /// 💢💢💢 新架构：获取会话更新事件流
  @override
  Stream<ConversationUpdateEvent> getConversationUpdateStream() {
    return _conversationUpdateController.stream;
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
        _logger.i('找到已存在的会话', extra: {
          'conversationId': existingConversation.conversationId,
          'id': existingConversation.id,
          'name': existingConversation.name,
          'contactUserId': existingConversation.contactUserId,
          'createdAt': existingConversation.createdAt.toIso8601String(),
        });

        // 💢💢💢 修复：检查conversationId是否为空
        if (existingConversation.conversationId.isEmpty) {
          _logger.w('找到的会话conversationId为空，需要重新创建', extra: {
            'existingId': existingConversation.id,
            'userId': userId,
          });

          // 删除无效的会话记录
          await _isar.writeTxn(() async {
            await _conversations.delete(existingConversation.id);
          });

          // 重新通过服务器创建会话
          _logger.i('删除无效会话记录，通过服务器重新创建');
          final conversation = await getOrCreatePrivateConversation(userId);

          _logger.i('重新创建会话成功',
              extra: {'conversationId': conversation.conversationId});
          return conversation.conversationId;
        }

        return existingConversation.conversationId;
      }

      // 💢💢💢 修复：通过服务器创建新会话，而不是本地创建
      _logger.i('未找到已存在会话，通过服务器创建新私聊会话');

      // 💢💢💢 使用现有的getOrCreatePrivateConversation方法
      final conversation = await getOrCreatePrivateConversation(userId);

      _logger
          .i('成功创建新会话', extra: {'conversationId': conversation.conversationId});
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
  /// 💢💢💢 新增：支持增量同步，只获取自上次同步以来有更新的会话
  @override
  Future<void> requestSyncConversations() async {
    try {
      if (_communicationService.isInitialized) {
        // 💢💢💢 新增：获取上次同步时间实现增量同步
        final lastSyncTime = await _getLastSyncTime();

        // 创建同步请求，包含上次同步时间
        final syncRequest = conversation_proto.SyncConversationsRequest();
        if (lastSyncTime != null) {
          syncRequest.lastSyncTime = Int64(lastSyncTime.millisecondsSinceEpoch);
          _logger.i('发送增量会话同步请求', extra: {
            'lastSyncTime': lastSyncTime.toIso8601String(),
            'lastSyncTimestamp': lastSyncTime.millisecondsSinceEpoch,
          });
        } else {
          _logger.i('发送全量会话同步请求（首次同步）');
        }

        // 发送同步请求到服务器
        _communicationService.emitProto('conversation:sync', syncRequest);
        _logger.i('会话同步请求已发送');
      } else {
        _logger.e('通信服务未初始化，无法同步会话');
      }
    } catch (error, stack) {
      _logger.e('同步会话失败', error: error, stackTrace: stack);
      rethrow;
    }
  }

  /// 💢💢💢 新增：获取上次同步时间
  Future<DateTime?> _getLastSyncTime() async {
    try {
      final secureStorage = SecureStorageService();
      final timestampStr =
          await secureStorage.read('conversations_last_sync_time');
      if (timestampStr != null) {
        final timestamp = int.tryParse(timestampStr);
        if (timestamp != null) {
          return DateTime.fromMillisecondsSinceEpoch(timestamp);
        }
      }
      return null;
    } catch (error) {
      _logger.w('获取上次同步时间失败: $error');
      return null;
    }
  }

  /// 💢💢💢 新增：保存同步时间
  Future<void> _saveLastSyncTime(DateTime syncTime) async {
    try {
      final secureStorage = SecureStorageService();
      await secureStorage.write('conversations_last_sync_time',
          syncTime.millisecondsSinceEpoch.toString());
      _logger.d('已保存会话同步时间', extra: {
        'syncTime': syncTime.toIso8601String(),
        'timestamp': syncTime.millisecondsSinceEpoch,
      });
    } catch (error) {
      _logger.w('保存同步时间失败: $error');
    }
  }

  /// 💢💢💢 新增：强制全量同步会话列表
  @override
  Future<void> requestFullSyncConversations() async {
    try {
      if (_communicationService.isInitialized) {
        // 发送不包含同步时间的请求，强制全量同步
        final syncRequest = conversation_proto.SyncConversationsRequest();
        _logger.i('发送强制全量会话同步请求');

        // 发送同步请求到服务器
        _communicationService.emitProto('conversation:sync', syncRequest);
        _logger.i('强制全量会话同步请求已发送');
      } else {
        _logger.e('通信服务未初始化，无法同步会话');
      }
    } catch (error, stack) {
      _logger.e('强制全量同步会话失败', error: error, stackTrace: stack);
      rethrow;
    }
  }

  /// 💢💢💢 新增：获取上次同步时间（公开方法）
  @override
  Future<DateTime?> getLastSyncTime() async {
    return await _getLastSyncTime();
  }

  /// 💢💢💢 新增：清除同步时间记录
  @override
  Future<void> clearSyncTime() async {
    try {
      final secureStorage = SecureStorageService();
      await secureStorage.delete('conversations_last_sync_time');
      _logger.i('已清除会话同步时间记录，下次同步将执行全量同步');
    } catch (error) {
      _logger.w('清除同步时间记录失败: $error');
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

  /// 更新会话信息
  ///
  /// 更新会话的名称或头像（群聊和频道）
  /// [conversationId] - 会话ID
  /// [name] - 新的会话名称
  /// [avatar] - 新的会话头像URL
  /// 返回是否更新成功
  @override
  Future<bool> updateConversationInfo(String conversationId,
      {String? name, String? avatar}) async {
    try {
      _logger.i('更新会话信息', extra: {
        'conversationId': conversationId,
        'name': name,
        'avatar': avatar,
      });

      // 验证参数
      if (name == null && avatar == null) {
        _logger.w('更新会话信息时没有提供有效参数');
        return false;
      }

      // 1️⃣ 先更新本地数据库，乐观更新
      final conversation = await _conversations
          .filter()
          .conversationIdEqualTo(conversationId)
          .findFirst();

      if (conversation != null) {
        await _isar.writeTxn(() async {
          if (name != null) conversation.name = name;
          if (avatar != null) conversation.avatar = avatar;
          await _conversations.put(conversation);
        });

        _logger.d('本地会话信息已预更新', extra: {
          'conversationId': conversationId,
          'name': name,
          'avatar': avatar,
        });
      }

      // 2️⃣ 同步到服务器
      if (_communicationService.isInitialized) {
        _logger.i('开始同步会话信息到服务器');

        final updateRequest = conversation_proto.ConversationUpdateRequest()
          ..conversationId = conversationId;
        if (name != null) updateRequest.name = name;
        if (avatar != null) updateRequest.avatar = avatar;

        _communicationService.emitProto('conversation:update', updateRequest);
        _logger.i('会话信息更新请求已发送');
        return true;
      } else {
        _logger.w('通信服务未初始化，无法同步会话信息');
        return true; // 本地已更新，视为成功
      }
    } catch (error) {
      _logger.e('更新会话信息失败', error: error);
      return false;
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

  /// 💢💢💢 新增：保存会话到本地数据库
  /// 直接保存一个会话对象到本地数据库
  /// [conversation] - 要保存的会话对象
  @override
  Future<void> saveConversation(db.Conversation conversation) async {
    try {
      // 💢💢💢 已移除：不再需要手动计算unreadCount，使用动态计算

      await _isar.writeTxn(() async {
        await _conversations.put(conversation);
      });

      _logger.i('会话已保存到本地数据库', extra: {
        'conversationId': conversation.conversationId,
        'type': conversation.type.name,
        'name': conversation.name,
        'unreadCount': conversation.unreadCount(_currentUser.userId),
      });
    } catch (error, stack) {
      _logger.e('保存会话到本地数据库失败', error: error, stackTrace: stack);
      rethrow;
    }
  }

  /// 💢💢💢 新增：获取第一条未读消息的ID
  /// [conversationId] - 会话ID
  /// [currentUserId] - 当前用户ID
  /// 返回第一条未读消息的ID，如果没有未读消息则返回null
  @override
  Future<String?> getFirstUnreadMessageId(
      String conversationId, String currentUserId) async {
    try {
      _logger.d('开始查找第一条未读消息ID', extra: {
        'conversationId': conversationId,
        'currentUserId': currentUserId,
      });

      // 首先获取会话信息
      final conversation = await getConversationById(conversationId);
      if (conversation == null) {
        _logger.w('会话不存在', extra: {'conversationId': conversationId});
        return null;
      }

      // 获取第一条未读消息的索引
      final firstUnreadIndex =
          conversation.getFirstUnreadMessageIndex(currentUserId);
      if (firstUnreadIndex == null) {
        _logger.d('没有未读消息', extra: {
          'conversationId': conversationId,
          'currentUserId': currentUserId,
        });
        return null;
      }

      // 从数据库查询对应索引的消息
      final message = await _isar.messages
          .filter()
          .conversationIdEqualTo(conversationId)
          .messageIndexEqualTo(firstUnreadIndex)
          .findFirst();

      if (message == null) {
        _logger.w('找不到对应索引的消息', extra: {
          'conversationId': conversationId,
          'firstUnreadIndex': firstUnreadIndex,
        });
        return null;
      }

      _logger.i('成功找到第一条未读消息', extra: {
        'conversationId': conversationId,
        'firstUnreadIndex': firstUnreadIndex,
        'messageId': message.messageId,
        'messageText': message.text?.substring(0, 50) ?? '非文本消息',
      });

      return message.messageId;
    } catch (error, stackTrace) {
      _logger.e('查找第一条未读消息ID失败', error: error, stackTrace: stackTrace, extra: {
        'conversationId': conversationId,
        'currentUserId': currentUserId,
      });
      return null;
    }
  }

  /// 💢💢💢 新增：获取会话中的媒体消息（图片、视频）
  @override
  Future<List<Message>> getMediaMessages(String conversationId,
      {int limit = 50, int offset = 0}) async {
    try {
      _logger.d('获取媒体消息', extra: {
        'conversationId': conversationId,
        'limit': limit,
        'offset': offset,
      });

      final messages = await _isar.messages
          .filter()
          .conversationIdEqualTo(conversationId)
          .group((q) => q
              .typeEqualTo(MessageType.image)
              .or()
              .typeEqualTo(MessageType.video))
          .sortByMessageIndexDesc()
          .offset(offset)
          .limit(limit)
          .findAll();

      // 💢💢💢 数据库查询后进行内存排序，处理临时消息的特殊排序
      MessageSortUtils.sortForDisplay(messages);

      _logger.d('获取媒体消息成功', extra: {
        'conversationId': conversationId,
        'count': messages.length,
      });

      return messages;
    } catch (error, stackTrace) {
      _logger.e('获取媒体消息失败', error: error, stackTrace: stackTrace);
      return [];
    }
  }

  /// 💢💢💢 新增：获取会话中的文件消息
  @override
  Future<List<Message>> getFileMessages(String conversationId,
      {int limit = 50, int offset = 0}) async {
    try {
      _logger.d('获取文件消息', extra: {
        'conversationId': conversationId,
        'limit': limit,
        'offset': offset,
      });

      final messages = await _isar.messages
          .filter()
          .conversationIdEqualTo(conversationId)
          .typeEqualTo(MessageType.file)
          .sortByMessageIndexDesc()
          .offset(offset)
          .limit(limit)
          .findAll();

      // 💢💢💢 数据库查询后进行内存排序，处理临时消息的特殊排序
      MessageSortUtils.sortForDisplay(messages);

      _logger.d('获取文件消息成功', extra: {
        'conversationId': conversationId,
        'count': messages.length,
      });

      return messages;
    } catch (error, stackTrace) {
      _logger.e('获取文件消息失败', error: error, stackTrace: stackTrace);
      return [];
    }
  }

  /// 💢💢💢 新增：获取会话中的语音消息
  @override
  Future<List<Message>> getVoiceMessages(String conversationId,
      {int limit = 50, int offset = 0}) async {
    try {
      _logger.d('获取语音消息', extra: {
        'conversationId': conversationId,
        'limit': limit,
        'offset': offset,
      });

      final messages = await _isar.messages
          .filter()
          .conversationIdEqualTo(conversationId)
          .typeEqualTo(MessageType.voice)
          .sortByMessageIndexDesc()
          .offset(offset)
          .limit(limit)
          .findAll();

      // 💢💢💢 数据库查询后进行内存排序，处理临时消息的特殊排序
      MessageSortUtils.sortForDisplay(messages);

      _logger.d('获取语音消息成功', extra: {
        'conversationId': conversationId,
        'count': messages.length,
      });

      return messages;
    } catch (error, stackTrace) {
      _logger.e('获取语音消息失败', error: error, stackTrace: stackTrace);
      return [];
    }
  }

  /// 💢💢💢 新增：获取会话中包含链接的消息
  @override
  Future<List<Message>> getLinkMessages(String conversationId,
      {int limit = 50, int offset = 0}) async {
    try {
      _logger.d('获取链接消息', extra: {
        'conversationId': conversationId,
        'limit': limit,
        'offset': offset,
      });

      // 查找文本消息中包含链接的消息
      // 使用简单的URL模式匹配（包含http://或https://的消息）
      final messages = await _isar.messages
          .filter()
          .conversationIdEqualTo(conversationId)
          .typeEqualTo(MessageType.text)
          .textIsNotNull()
          .group((q) => q
              .textContains('http://', caseSensitive: false)
              .or()
              .textContains('https://', caseSensitive: false))
          .sortByMessageIndexDesc()
          .offset(offset)
          .limit(limit)
          .findAll();

      // 💢💢💢 数据库查询后进行内存排序，处理临时消息的特殊排序
      MessageSortUtils.sortForDisplay(messages);

      _logger.d('获取链接消息成功', extra: {
        'conversationId': conversationId,
        'count': messages.length,
      });

      return messages;
    } catch (error, stackTrace) {
      _logger.e('获取链接消息失败', error: error, stackTrace: stackTrace);
      return [];
    }
  }

  /// 💢💢💢 已移除：_calculateAndUpdateUnreadCount 方法

  /// 处理会话同步响应事件
  /// 将Proto格式的会话数据转换为数据库模型并更新本地数据
  void _handleSyncResponseProto(
      conversation_proto.ConversationCollection collection) async {
    _logger.i('收到会话同步响应',
        extra: {'conversations': collection.conversations.length});

    try {
      if (collection.conversations.isEmpty) {
        _logger.i('会话列表为空，这可能是新用户或同步过程中的正常状态');
        return;
      }

      // 转换为数据库对象 - 使用适配器转换方法，保留本地字段
      final List<db.Conversation> dbConversations = [];
      for (final conv in collection.conversations) {
        // 查找现有会话以保留本地字段（如lastReadTime）
        final existing = await _conversations
            .filter()
            .conversationIdEqualTo(conv.conversationId)
            .findFirst();

        final dbConversation = ConversationAdapter.fromProto(
          conv,
          currentUserId: _currentUser.userId,
          existingConversation: existing,
        );
        dbConversations.add(dbConversation);
      }

      // 更新本地数据库，数据库变化会自动触发UI更新
      await _updateLocalConversations(dbConversations);

      // 💢💢💢 新架构：发送会话列表重载事件
      // 增量同步返回的 dbConversations 只是变更部分，如果直接发送会导致 UI 只拿到部分会话。
      // 为保证 UI 始终拿到完整列表，这里重新从数据库读取全部会话并发送。
      final allConversations = await _conversations.where().findAll();
      _notifyConversationUpdate(ConversationsReloadedEvent(
        conversations: allConversations,
        timestamp: DateTime.now(),
      ));

      // 💢💢💢 新增：保存同步时间，用于下次增量同步
      await _saveLastSyncTime(DateTime.now());

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

          // 💢💢💢 已移除：不再需要手动计算unreadCount，使用动态计算

          // 保存更新后的会话
          await _conversations.put(conversation);
          _logger.d('已更新本地会话数据', extra: {
            'conversationId': notification.conversationId,
            'unreadCount': conversation.unreadCount(_currentUser.userId),
          });

          // 💢💢💢 新架构：发送会话更新事件
          _notifyConversationUpdate(ConversationUpdatedEvent(
            updatedConversation: conversation,
            updatedFields: [
              'lastMessageName',
              'lastMessagePreview',
              'lastMessageIndex'
            ],
            timestamp: DateTime.now(),
          ));
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

          // 💢💢💢 新架构：发送会话设置更新事件
          final updatedFields = <String>[];
          if (response.hasMuted()) updatedFields.add('muted');
          if (response.hasPinned()) updatedFields.add('pinned');

          _notifyConversationUpdate(ConversationUpdatedEvent(
            updatedConversation: conversation,
            updatedFields: updatedFields,
            timestamp: DateTime.now(),
          ));
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
      // 查找现有会话以保留本地字段（如lastReadTime）
      final existing = await _conversations
          .filter()
          .conversationIdEqualTo(response.conversation.conversationId)
          .findFirst();

      final conversation = ConversationAdapter.fromProto(
        response.conversation,
        currentUserId: _currentUser.userId,
        existingConversation: existing,
      );

      _logger.i('成功获取会话详情', extra: {
        'conversationId': conversation.conversationId,
        'conversationType': conversation.type.name
      });
      await _isar.writeTxn(() async {
        if (existing != null) {
          conversation.id = existing.id;
        }
        await _conversations.put(conversation);
      });

      _logger.d('已将会话详情保存到本地数据库');
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
              'calculatedUnreadCount': conversation.unreadCount(currentUserId),
            });
          } else {
            // 更新其他参与者的信息
            final existingParticipantIndex = conversation.participants
                .indexWhere((p) => p.userId == participant.userId);

            if (existingParticipantIndex != -1) {
              // 🔧 修复：完全使用服务器数据，不保留本地状态
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

          // 💢💢💢 新增：发出会话更新事件通知ChatsPage
          _notifyConversationUpdate(ConversationUpdatedEvent(
            updatedConversation: conversation,
            updatedFields: ['readMessageIndex', 'unreadCount'],
            timestamp: DateTime.now(),
          ));

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

          // 💢💢💢 新增：发出会话更新事件通知ChatsPage
          _notifyConversationUpdate(ConversationUpdatedEvent(
            updatedConversation: conversation,
            updatedFields: ['lastReadTime'],
            timestamp: DateTime.now(),
          ));

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
        'currentScrollPosition':
            snapshot.currentScrollPosition?.getListIndex(snapshot.messages),
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
        });
        return snapshot;
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

  /// 清除所有无效的状态快照
  @override
  Future<void> cleanupExpiredSnapshots() async {
    try {
      final invalidKeys = _stateSnapshots.entries
          .where((entry) => !entry.value.isValid)
          .map((entry) => entry.key)
          .toList();

      for (final key in invalidKeys) {
        _stateSnapshots.remove(key);
      }

      if (invalidKeys.isNotEmpty) {
        _logger.d('🗑️ 清理无效状态快照', extra: {
          'cleanedCount': invalidKeys.length,
          'remainingCount': _stateSnapshots.length,
        });
      }
    } catch (error) {
      _logger.e('清理无效状态快照失败', error: error);
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
      // 💢💢💢 已移除：unreadCount参数，现在使用动态计算
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

  /// 处理联系人更新事件，更新相关的私聊会话名称
  void _handleContactUpdatedForConversations(dynamic data) async {
    try {
      final contactId = data['contactId'] as String?;
      final updatedFields =
          (data['updatedFields'] as List?)?.cast<String>() ?? [];

      if (contactId == null) {
        _logger.w('联系人更新事件缺少contactId');
        return;
      }

      _logger.i('收到联系人更新事件，准备更新相关会话名称', extra: {
        'contactId': contactId,
        'updatedFields': updatedFields,
      });

      // 只有当名称相关字段更新时才处理
      if (!updatedFields
          .any((field) => ['nickname', 'custom_nickname'].contains(field))) {
        _logger.d('跳过非名称字段更新', extra: {'updatedFields': updatedFields});
        return;
      }

      // 查找所有与此联系人相关的私聊会话
      final relatedConversations = await _conversations
          .filter()
          .typeEqualTo(db.ConversationType.private)
          .and()
          .contactUserIdEqualTo(contactId)
          .findAll();

      if (relatedConversations.isEmpty) {
        _logger.d('未找到与此联系人相关的私聊会话', extra: {'contactId': contactId});
        return;
      }

      // 获取更新后的联系人信息
      final updatedContact = await getContactById(contactId);
      if (updatedContact == null) {
        _logger.w('无法获取更新后的联系人信息', extra: {'contactId': contactId});
        return;
      }

      // 更新每个相关会话的名称和参与者信息
      await _isar.writeTxn(() async {
        for (final conversation in relatedConversations) {
          final oldName = conversation.name;

          // 更新会话名称
          conversation.name = updatedContact.name;

          // 更新参与者信息中的名称
          for (final participant in conversation.participants) {
            if (participant.userId == contactId) {
              participant.name = updatedContact.name;
              if (updatedContact.avatar != null) {
                participant.avatar = updatedContact.avatar!;
              }
              break;
            }
          }

          // 保存会话
          await _conversations.put(conversation);

          // 发出会话更新事件
          _notifyConversationUpdate(ConversationUpdatedEvent(
            updatedConversation: conversation,
            updatedFields: ['name', 'participants'],
            timestamp: DateTime.now(),
          ));

          _logger.i('已更新私聊会话名称', extra: {
            'conversationId': conversation.conversationId,
            'contactId': contactId,
            'oldName': oldName,
            'newName': conversation.name,
          });
        }
      });

      _logger.i('联系人更新处理完成', extra: {
        'contactId': contactId,
        'updatedConversations': relatedConversations.length,
      });
    } catch (e) {
      _logger.e('处理联系人更新事件失败', extra: {
        'error': e.toString(),
        'stackTrace': e is Error ? e.stackTrace.toString() : null,
      });
    }
  }

  /// 释放资源
  /// 取消所有订阅
  void dispose() {
    _logger.i('销毁ChatsRepository');

    // 💢💢💢 新架构：关闭会话更新事件流控制器
    _conversationUpdateController.close();

    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
  }
}
