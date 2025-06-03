import 'dart:async';
import 'package:isar/isar.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/database/database_initializer.dart';
import 'package:cc/core/database/models/user.dart';
import 'package:cc/core/database/models/conversation.dart' as db;
import 'package:cc/core/database/models/current_user.dart';
import 'package:cc/features/chat/domain/entities/conversation_event.dart';
import 'package:cc/core/services/communication_service.dart';
import 'package:cc/features/chat/domain/repositories/chats_repository.dart';
import 'package:cc/features/chat/domain/repositories/chat_repository.dart';
import 'package:cc/core/proto/generated/message.pbenum.dart';
import 'package:fixnum/fixnum.dart' as $fixnum;

import 'package:cc/core/proto/generated/conversation.pb.dart'
    as conversation_proto;

/// ChatsRepository的实现类
/// 负责聊天会话列表相关的数据处理、会话管理等功能
class ChatsRepositoryImpl implements ChatsRepository {
  final LogService _logger = LogService.instance;
  final CommunicationService _communicationService = CommunicationService();
  final ChatRepository? _chatRepository; // 用于消息同步

  // 获取当前数据库实例，使用DatabaseInitializer
  Isar get _isar => DatabaseInitializer.isar;
  IsarCollection<User> get _users => _isar.users;
  IsarCollection<db.Conversation> get _conversations => _isar.conversations;

  // 事件流控制器
  final _conversationSyncController =
      StreamController<ConversationSyncEvent>.broadcast();
  final _conversationUpdateController =
      StreamController<ConversationUpdateEvent>.broadcast();

  @override
  Stream<ConversationSyncEvent> get conversationSyncStream =>
      _conversationSyncController.stream;

  @override
  Stream<ConversationUpdateEvent> get conversationUpdateStream =>
      _conversationUpdateController.stream;

  // 事件订阅列表
  final List<StreamSubscription> _subscriptions = [];

  // 消息同步相关配置
  static const int maxConcurrentMessageSync = 3; // 最大并发消息同步数
  static const int messageSyncDelayMs = 500; // 消息同步延迟（毫秒）

  // 构造函数
  ChatsRepositoryImpl({ChatRepository? chatRepository})
      : _chatRepository = chatRepository {
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
          .listen(_handleConversationDetailResponse));
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

  /// 获取当前用户ID
  /// 直接从数据库获取当前登录用户的ID
  /// 返回用户ID,如未找到则抛出异常
  Future<String> _getCurrentUserId() async {
    try {
      if (!DatabaseInitializer.isInitialized) {
        throw Exception('数据库未初始化，请确保已登录');
      }

      final currentUsers =
          await DatabaseInitializer.isar.currentUsers.where().findAll();

      if (currentUsers.isEmpty) {
        throw Exception('找不到当前用户信息，请确保已登录');
      }

      // 返回第一个用户的ID（通常只会有一个用户记录）
      return currentUsers.first.userId;
    } catch (e) {
      throw Exception('获取当前用户ID失败: ${e.toString()}');
    }
  }

  /// 获取所有会话
  /// 从本地数据库获取所有会话
  /// 返回会话列表
  @override
  Future<List<db.Conversation>> getAllConversations() async {
    try {
      _logger.i('开始从本地数据库获取所有会话');

      // 标记同步开始
      _conversationSyncController.add(ConversationSyncEvent(
        type: ConversationSyncType.syncStarted,
        conversations: null,
      ));

      // 从数据库获取最新的会话列表
      final conversations = await _conversations.where().findAll();

      // 标记同步完成
      _conversationSyncController.add(ConversationSyncEvent(
        type: ConversationSyncType.syncCompleted,
        conversations: conversations,
      ));
      return conversations;
    } catch (error, stack) {
      _logger.e('获取会话列表失败', error: error, stackTrace: stack);

      // 标记同步错误
      _conversationSyncController.add(ConversationSyncEvent(
        type: ConversationSyncType.syncError,
        conversations: null,
      ));
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

              // 发布会话更新事件
              _conversationUpdateController.add(ConversationUpdateEvent(
                conversationId: conversation.conversationId,
                type: ConversationUpdateType.updated,
                conversation: conversation,
              ));
            }
          } else {
            // 添加新会话
            await _conversations.put(conversation);

            // 发布会话新增事件
            _conversationUpdateController.add(ConversationUpdateEvent(
              conversationId: conversation.conversationId,
              type: ConversationUpdateType.added,
              conversation: conversation,
            ));
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
  /// 根据联系人ID查找已有会话,不存在则创建新会话
  /// [contactUserId] - 联系人ID
  /// 返回会话对象
  @override
  Future<db.Conversation> getOrCreatePrivateConversation(
      String contactUserId) async {
    try {
      // 先查找已有的私聊会话
      final existing = await _conversations
          .filter()
          .typeEqualTo(db.ConversationType.private)
          .and()
          .contactUserIdEqualTo(contactUserId)
          .findFirst();

      if (existing != null) {
        return existing;
      }

      // 创建新会话
      final contact = await getContactById(contactUserId);
      if (contact == null) {
        throw Exception('联系人不存在');
      }

      final conversation = db.Conversation();
      conversation.type = db.ConversationType.private;
      conversation.name = contact.name;
      conversation.contactUserId = contactUserId;

      await _isar.writeTxn(() async {
        conversation.id = await _conversations.put(conversation);
        await _conversations.put(conversation);

        // 添加会话参与者
        conversation.participants.add(contact);
        await conversation.participants.save();
      });

      return conversation;
    } catch (error) {
      _logger.e('获取或创建私聊会话失败', error: error, stackTrace: StackTrace.current);
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
        final currentUserId = await _getCurrentUserId();
        final currentUser = await getContactById(currentUserId);
        if (currentUser != null) {
          conversation.participants.add(currentUser);
        }

        // 添加其他成员
        for (final memberId in memberIds) {
          final member = await getContactById(memberId);
          if (member != null) {
            conversation.participants.add(member);
          }
        }

        await conversation.participants.save();
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
        // 建立会话与用户的关联
        await conversation.participants.save();
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

  @override
  Future<void> updateConversationMuteStatus(
      String conversationId, bool isMuted) async {
    _logger.i('更新会话静音状态',
        extra: {'conversationId': conversationId, 'isMuted': isMuted});

    try {
      // 更新本地数据库
      final conversation = await _conversations
          .filter()
          .conversationIdEqualTo(conversationId)
          .findFirst();
      if (conversation != null) {
        // 使用事务包装数据库写入操作
        await _isar.writeTxn(() async {
          conversation.isMuted = isMuted;
          await _conversations.put(conversation);
        });
        _logger.i('本地数据库会话静音状态已更新');
      } else {
        _logger.e('找不到指定会话', extra: {'conversationId': conversationId});
        throw Exception('找不到指定会话');
      }

      // 同步到服务器
      if (_communicationService.isInitialized) {
        _logger.i('开始同步会话静音状态到服务器');

        // 创建会话设置更新请求
        final settingsUpdateRequest =
            conversation_proto.ConversationSettingsUpdateRequest()
              ..conversationId = conversationId
              ..muted = isMuted;

        // 发送请求到服务器
        _communicationService.emitProto(
            'conversation:settings:update', settingsUpdateRequest);

        // 服务器响应会通过_handleConversationSettingsUpdate方法处理
      } else {
        _logger.w('通信服务未初始化，无法同步会话静音状态到服务器');
      }
    } catch (error) {
      _logger.e('更新会话静音状态失败', error: error);
      throw Exception('更新会话静音状态失败: ${error.toString()}');
    }
  }

  @override
  Future<void> updateConversationPinStatus(
      String conversationId, bool isPinned) async {
    _logger.i('更新会话置顶状态',
        extra: {'conversationId': conversationId, 'isPinned': isPinned});

    try {
      // 更新本地数据库
      final conversation = await _conversations
          .filter()
          .conversationIdEqualTo(conversationId)
          .findFirst();
      if (conversation != null) {
        // 使用事务包装数据库写入操作
        await _isar.writeTxn(() async {
          conversation.isPinned = isPinned;
          await _conversations.put(conversation);
        });
        _logger.i('本地数据库会话置顶状态已更新');
      } else {
        _logger.e('找不到指定会话', extra: {'conversationId': conversationId});
        throw Exception('找不到指定会话');
      }

      // 同步到服务器
      if (_communicationService.isInitialized) {
        _logger.i('开始同步会话置顶状态到服务器');

        // 创建会话设置更新请求
        final settingsUpdateRequest =
            conversation_proto.ConversationSettingsUpdateRequest()
              ..conversationId = conversationId
              ..pinned = isPinned;

        // 发送请求到服务器
        _communicationService.emitProto(
            'conversation:settings:update', settingsUpdateRequest);

        // 服务器响应会通过_handleConversationSettingsUpdate方法处理
      } else {
        _logger.w('通信服务未初始化，无法同步会话置顶状态到服务器');
      }
    } catch (error) {
      _logger.e('更新会话置顶状态失败', error: error);
      throw Exception('更新会话置顶状态失败: ${error.toString()}');
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
          return conversations.where((c) => c.unreadCount > 0).toList();
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
        if (muted != null) conversation.isMuted = muted;
        if (pinned != null) conversation.isPinned = pinned;
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

            // 发出会话更新事件
            _conversationUpdateController.add(
              ConversationUpdateEvent(
                conversationId: conversationId,
                type: ConversationUpdateType.updated,
                isMuted: muted,
                isPinned: pinned,
              ),
            );
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
    // TODO: 实现获取联系人在线状态流
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

    // 标记同步开始
    _conversationSyncController.add(ConversationSyncEvent(
      type: ConversationSyncType.syncStarted,
      conversations: null,
    ));

    try {
      if (collection.conversations.isEmpty) {
        _logger.i('会话列表为空，这可能是新用户或同步过程中的正常状态');
        // 即使列表为空，也标记为同步成功
        _conversationSyncController.add(ConversationSyncEvent(
          type: ConversationSyncType.syncCompleted,
          conversations: [],
        ));
        _logger.i('发送会话同步完成事件');
        return;
      }

      // 转换为数据库对象 - 使用模型类提供的fromProto方法
      final List<db.Conversation> dbConversations = collection.conversations
          .map((conv) => db.Conversation.fromProto(conv))
          .toList();

      // 更新本地数据库
      await _updateLocalConversations(dbConversations);

      // 发送批量同步完成事件，通知Cubit重新加载数据
      _conversationSyncController.add(ConversationSyncEvent(
        type: ConversationSyncType.syncCompleted,
        conversations: dbConversations,
      ));
      _logger.i('发送会话同步完成事件');

      // 🔥 新增：会话同步完成后，触发消息同步
      await _triggerMessageSyncAfterConversationSync(collection.conversations);
    } catch (e, stack) {
      _logger.e('处理同步响应数据失败', error: e, stackTrace: stack);
      // 处理失败时标记同步错误
      _conversationSyncController.add(ConversationSyncEvent(
        type: ConversationSyncType.syncError,
        conversations: null,
      ));
      _logger.i('发送会话同步错误事件');
    }
  }

  /// 会话同步完成后触发消息同步
  ///
  /// 根据每个会话的last_read_message_id和未读消息数量，
  /// 制定合适的消息同步策略并执行同步
  Future<void> _triggerMessageSyncAfterConversationSync(
      List<conversation_proto.ConversationProto> conversations) async {
    if (_chatRepository == null) {
      _logger.w('ChatRepository未注入，跳过消息同步');
      return;
    }

    _logger.i('开始为${conversations.length}个会话制定消息同步策略');

    // 创建同步任务列表
    final List<ConversationSyncTask> syncTasks = [];

    for (final conversation in conversations) {
      final syncTask = await _createMessageSyncTask(conversation);
      if (syncTask != null) {
        syncTasks.add(syncTask);
      }
    }

    if (syncTasks.isEmpty) {
      _logger.i('没有需要同步消息的会话');
      return;
    }

    // 按优先级排序（未读消息优先）
    syncTasks.sort((a, b) => a.priority.compareTo(b.priority));

    _logger.d('开始批量消息同步', extra: {
      'taskCount': syncTasks.length,
      'tasks': syncTasks
          .map((t) => {
                'conversationId': t.conversationId,
                'syncType': t.type.name,
                'priority': t.priority,
              })
          .toList()
    });

    // 延迟执行，避免与会话同步冲突
    Timer(const Duration(milliseconds: messageSyncDelayMs), () async {
      try {
        // 批量同步消息
        final results = await _chatRepository!.batchSyncMessages(
          syncTasks,
          maxConcurrent: maxConcurrentMessageSync,
        );

        // 记录同步结果
        _logMessageSyncResults(results, syncTasks);
      } catch (error) {
        _logger.e('批量消息同步失败', error: error);
      }
    });
  }

  /// 创建消息同步任务
  /// 根据会话状态和本地数据情况创建合适的消息同步任务
  /// 新策略：
  /// 1. 有last_read_message_id → 日期同步（包含未读消息）
  /// 2. 没有last_read_message_id但有未读 → 未读同步
  /// 3. 两个都没有 → 不同步
  /// [conversation] - 会话Proto对象
  /// 返回同步任务，如果不需要同步则返回null
  Future<ConversationSyncTask?> _createMessageSyncTask(
      conversation_proto.ConversationProto conversation) async {
    final conversationId = conversation.conversationId;
    final lastReadMessageId = conversation.hasLastReadMessageId()
        ? conversation.lastReadMessageId
        : null;
    final unreadCount = conversation.unreadCount;

    if (_chatRepository == null) {
      _logger.w('ChatRepository未初始化，跳过消息同步');
      return null;
    }

    _logger.d('创建消息同步任务', extra: {
      'conversationId': conversationId,
      'lastReadMessageId': lastReadMessageId,
      'unreadCount': unreadCount,
    });

    MessageSyncType syncType;
    String? anchorMessageId;
    int priority = 0;

    if (lastReadMessageId != null && lastReadMessageId.isNotEmpty) {
      // 🎯 策略1：有last_read_message_id，使用日期同步（包含未读消息）
      _logger.d('使用日期同步策略，以last_read_message_id为锚点（包含未读消息）');
      syncType = MessageSyncType.RECENT;
      anchorMessageId = lastReadMessageId;
      priority = 1; // 最高优先级
    } else if (unreadCount > 0) {
      // 🎯 策略2：没有last_read_message_id但有未读消息，使用未读同步
      _logger.d('没有last_read_message_id，但有$unreadCount条未读消息，使用未读消息同步策略');
      syncType = MessageSyncType.UNREAD;
      anchorMessageId = null; // 未读同步不需要锚点
      priority = 2; // 次优先级
    } else {
      // 🎯 策略3：两个都没有，不同步
      _logger.d('没有last_read_message_id且没有未读消息，跳过消息同步');
      return null;
    }

    return ConversationSyncTask(
      conversationId: conversationId,
      type: syncType,
      anchorMessageId: anchorMessageId,
      priority: priority,
    );
  }

  /// 记录消息同步结果
  void _logMessageSyncResults(
      List<bool> results, List<ConversationSyncTask> tasks) {
    final successCount = results.where((r) => r).length;
    final failureCount = results.length - successCount;

    _logger.i('消息同步完成', extra: {
      'totalConversations': results.length,
      'successCount': successCount,
      'failureCount': failureCount,
    });

    // 记录失败的同步
    for (int i = 0; i < results.length; i++) {
      if (!results[i]) {
        _logger.w('会话消息同步失败', extra: {
          'conversationId': tasks[i].conversationId,
          'syncType': tasks[i].type.name,
        });
      }
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
          conversation.lastMessageTime = DateTime.fromMillisecondsSinceEpoch(
              notification.lastMessageTime.toInt());
          conversation.unreadCount = notification.unreadCount;

          // 保存更新后的会话
          await _conversations.put(conversation);
          _logger.d('已更新本地会话数据',
              extra: {'conversationId': notification.conversationId});

          // 发布会话更新事件
          _conversationUpdateController.add(ConversationUpdateEvent(
            conversationId: conversation.conversationId,
            type: ConversationUpdateType.updated,
            conversation: conversation,
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

      // TODO: 更新会话参与者列表
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

      // TODO: 更新会话参与者列表
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
          // 更新静音状态
          if (response.hasMuted()) {
            conversation.isMuted = response.muted;
            _logger.d('已更新会话静音状态', extra: {
              'conversationId': response.conversationId,
              'muted': response.muted
            });
          }

          // 更新置顶状态
          if (response.hasPinned()) {
            conversation.isPinned = response.pinned;
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
      final conversation = db.Conversation.fromProto(response.conversation);
      _logger.i('成功获取会话详情', extra: {
        'conversationId': conversation.conversationId,
        'conversationType': conversation.type.name
      });
      await _isar.writeTxn(() async {
        await _conversations.put(conversation);
      });

      _logger.d('已将会话详情保存到本地数据库');

      _conversationUpdateController.add(ConversationUpdateEvent(
        conversationId: conversation.conversationId,
        type: ConversationUpdateType.added,
        conversation: conversation,
      ));
    }
  }

  /// 💢💢💢💢💢💢💢💢💢💢💢💢💢💢   会话阅读状态管理   💢💢💢💢💢💢💢💢💢💢💢💢💢💢

  @override
  Future<void> updateLastReadAt(String conversationId, DateTime timestamp,
      {bool syncToServer = false}) async {
    _logger.i('更新会话最后阅读时间', extra: {
      'conversationId': conversationId,
      'timestamp': timestamp.toString(),
      'syncToServer': syncToServer,
    });

    try {
      // 🔥 更新本地会话数据库
      final conversation = await _conversations
          .filter()
          .conversationIdEqualTo(conversationId)
          .findFirst();
      if (conversation != null) {
        // 使用事务包装数据库写入操作
        await _isar.writeTxn(() async {
          conversation.lastReadAt = timestamp;

          // 如果最后阅读时间晚于或等于最后消息时间，则清零未读计数
          if (conversation.lastMessageTime != null &&
              (timestamp.isAfter(conversation.lastMessageTime!) ||
                  timestamp.isAtSameMomentAs(conversation.lastMessageTime!))) {
            conversation.unreadCount = 0;
          }

          await _conversations.put(conversation);
        });
        _logger.d('本地数据库会话最后阅读时间已更新');

        // 🔥 发送会话阅读状态更新事件，通知Cubit更新
        _conversationUpdateController.add(ConversationUpdateEvent(
          conversationId: conversationId,
          type: ConversationUpdateType.readStatusUpdated,
          lastReadAt: timestamp,
          unreadCount: conversation.unreadCount,
        ));
      } else {
        _logger.e('找不到指定会话', extra: {'conversationId': conversationId});
        throw Exception('找不到指定会话');
      }

      // 🔥 根据syncToServer参数决定是否同步到服务器
      if (syncToServer && _communicationService.isInitialized) {
        _logger.i('开始同步会话最后阅读时间到服务器');

        // 创建会话标记已读请求
        final markReadRequest = conversation_proto.ConversationMarkReadRequest()
          ..conversationId = conversationId
          ..readAt = $fixnum.Int64(timestamp.millisecondsSinceEpoch);

        // 发送请求到服务器
        _communicationService.emitProto(
            'conversation:mark:read', markReadRequest);

        _logger.d('会话最后阅读时间同步请求已发送');
      } else if (syncToServer) {
        _logger.w('通信服务未初始化，无法同步会话最后阅读时间到服务器');
      }
    } catch (error) {
      _logger.e('更新会话最后阅读时间失败', error: error);
      throw Exception('更新会话最后阅读时间失败: ${error.toString()}');
    }
  }

  @override
  Future<void> updateLastReadMessageId(
      String conversationId, String messageId) async {
    _logger.i('更新会话最后阅读消息ID', extra: {
      'conversationId': conversationId,
      'messageId': messageId,
    });

    try {
      // 🔥 更新本地会话数据库
      final conversation = await _conversations
          .filter()
          .conversationIdEqualTo(conversationId)
          .findFirst();
      if (conversation != null) {
        // 使用事务包装数据库写入操作
        await _isar.writeTxn(() async {
          conversation.lastReadMessageId = messageId;
          await _conversations.put(conversation);
        });
        _logger.d('本地数据库会话最后阅读消息ID已更新');

        // 🔥 发送会话阅读状态更新事件，通知Cubit更新
        _conversationUpdateController.add(ConversationUpdateEvent(
          conversationId: conversationId,
          type: ConversationUpdateType.readStatusUpdated,
          lastReadMessageId: messageId,
        ));
      } else {
        _logger.e('找不到指定会话', extra: {'conversationId': conversationId});
        throw Exception('找不到指定会话');
      }

      // 🔥 根据syncToServer参数决定是否同步到服务器
      if (_communicationService.isInitialized) {
        _logger.i('开始同步会话最后阅读消息ID到服务器');

        // 创建会话标记已读请求
        final markReadRequest = conversation_proto.ConversationMarkReadRequest()
          ..conversationId = conversationId
          ..messageId = messageId;

        // 发送请求到服务器
        _communicationService.emitProto(
            'conversation:mark:read', markReadRequest);

        _logger.d('会话最后阅读消息ID同步请求已发送');
      } else {
        _logger.w('通信服务未初始化，无法同步会话最后阅读消息ID到服务器');
      }
    } catch (error) {
      _logger.e('更新会话最后阅读消息ID失败', error: error);
      throw Exception('更新会话最后阅读消息ID失败: ${error.toString()}');
    }
  }

  /// 释放资源
  /// 取消所有订阅并关闭流控制器
  void dispose() {
    _logger.i('销毁ChatsRepository');
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    _conversationSyncController.close();
    _conversationUpdateController.close();
  }
}
