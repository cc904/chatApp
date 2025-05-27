import 'dart:async';
import 'dart:io';
import 'package:cc/core/database/models/current_user.dart';
import 'package:isar/isar.dart';
import 'package:cc/core/database/database_initializer.dart';
import 'package:cc/core/database/models/conversation.dart' as db;
import 'package:cc/core/database/models/message.dart';
import 'package:cc/core/database/models/user.dart';
import 'package:cc/core/services/file_upload_service.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/services/communication_service.dart';
import 'package:cc/features/chat/domain/repositories/chat_repository.dart';
import 'package:fixnum/fixnum.dart' as $fixnum;

import 'package:cc/core/proto/generated/user.pb.dart' as user_proto;
import 'package:cc/core/proto/generated/message.pb.dart' as message_proto;
import 'package:cc/core/proto/generated/conversation.pb.dart'
    as conversation_proto;

/// 消息异常
class MessageException implements Exception {
  final String message;
  MessageException(this.message);

  @override
  String toString() => message;
}

/// ChatRepository的实现类
/// 负责聊天相关的数据处理、消息收发、实时通信等功能
class ChatRepositoryImpl implements ChatRepository {
  final LogService _logger = LogService.instance;
  final CommunicationService _communicationService = CommunicationService();
  final FileUploadService _fileUploadService = FileUploadService();
  final user_proto.CurrentUserProto _currentUser;

  // 活跃的会话ID，用于过滤事件
  String? _activeConversationId;

  // 事件流控制器
  final _newMessagesController = StreamController<Message>.broadcast();
  final _typingStatusController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _onlineStatusController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _messageStatusController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _syncStatusController = StreamController<SyncStatus>.broadcast();

  // 事件订阅列表
  final List<StreamSubscription> _subscriptions = [];

  // 获取消息流
  Stream<Message> get messageStream => _newMessagesController.stream;

  // 构造函数
  ChatRepositoryImpl({required user_proto.CurrentUserProto currentUserProto})
      : _currentUser = currentUserProto {
    _logger.x('ChatRepositoryImpl 初始化');
  }

  /// 获取同步状态流
  /// 返回数据同步状态变化的流
  @override
  Stream<SyncStatus> getSyncStatusStream() {
    return _syncStatusController.stream;
  }

  /// 💢💢💢💢💢💢💢💢💢💢💢💢💢💢   Isar   💢💢💢💢💢💢💢💢💢💢💢💢💢💢

  // 获取当前数据库实例，使用DatabaseInitializer
  Isar get _isar => DatabaseInitializer.isar;

  // 获取用户集合
  IsarCollection<User> get _users => _isar.users;

  // 获取会话集合
  IsarCollection<db.Conversation> get _conversations => _isar.conversations;

  // 获取消息集合
  IsarCollection<Message> get _messages => _isar.messages;

  /// 💢💢💢💢💢💢💢💢💢💢💢💢💢💢  事件处理  💢💢💢💢💢💢💢💢💢💢💢💢💢💢

  /// 注册事件监听
  @override
  Future<void> registerEventHandlers() async {
    if (!_communicationService.isInitialized) {
      _logger.i('通信服务未初始化，无法注册事件处理器');
      return;
    }

    _logger.i('ChatRepository Proto事件流 订阅');
    _subscriptions
      ..add(_communicationService
          .onProto<message_proto.NewMessageProto>('message:new')
          .listen(_handleNewMessage))
      ..add(_communicationService
          .onProto<message_proto.MessageReadProto>('message:read')
          .listen(_handleMessageRead))
      ..add(_communicationService
          .onProto<message_proto.MessageDeliveredProto>('message:delivered')
          .listen(_handleMessageDelivered))
      ..add(_communicationService
          .onProto<conversation_proto.ConversationCollection>(
              'conversation:sync:response')
          .listen(_handleSyncResultProto))
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
          .listen(_handleUserLeftNotification));
  }

  /// 处理新消息
  void _handleNewMessage(message_proto.NewMessageProto data) {
    try {
      // 创建消息对象
      final message = Message()
        ..messageId = data.id
        ..conversationId = data.conversationId
        ..senderId = data.senderId
        ..createdAt =
            DateTime.fromMillisecondsSinceEpoch(data.timestamp.toInt())
        ..text = data.content
        ..type = data.type
        ..isRead = false
        ..status = 'received';

      // 保存消息
      _isar.writeTxn(() async {
        message.id = await _messages.put(message);
      });

      // 更新会话的最后消息信息
      _updateConversationLastMessage(message);

      // 通知UI
      _newMessagesController.add(message);
    } catch (error) {
      _logger.e('处理新消息失败', error: error, stackTrace: StackTrace.current);
    }
  }

  /// 处理消息已送达事件
  void _handleMessageDelivered(message_proto.MessageDeliveredProto data) {
    try {
      _messageStatusController.add({
        'messageId': data.messageId,
        'conversationId': data.conversationId,
        'status': 'delivered',
      });
    } catch (error) {
      _logger.e('处理消息已送达事件失败', error: error, stackTrace: StackTrace.current);
    }
  }

  /// 处理消息已读事件
  void _handleMessageRead(message_proto.MessageReadProto data) {
    try {
      _messageStatusController.add({
        'messageId': data.messageId,
        'conversationId': data.conversationId,
        'status': 'read',
      });
    } catch (error) {
      _logger.e('处理消息已读事件失败', error: error, stackTrace: StackTrace.current);
    }
  }

  /// 处理会话同步响应事件 (带类型的版本)
  void _handleSyncResultProto(
      conversation_proto.ConversationCollection response) {
    _logger.i('收到会话同步响应 (Protobuf类型)',
        extra: {'conversations': response.conversations.length});

    try {
      _logger.i('解析到 ${response.conversations.length} 个会话');
      if (response.conversations.isEmpty) {
        _logger.i('会话列表为空，这可能是新用户或同步过程中的正常状态');
        // 即使列表为空，也标记为同步成功
        _syncStatusController.add(SyncStatus.completed);
        return;
      }

      // 处理同步返回的会话数据
      _processSyncedConversations(response.conversations).then((_) {
        // 处理完成后标记同步成功
        _syncStatusController.add(SyncStatus.completed);
        _logger.i('会话同步完成');
      });
    } catch (e, stack) {
      _logger.e('处理同步响应数据失败', error: e, stackTrace: stack);
      // 处理失败时标记同步错误
      _syncStatusController.add(SyncStatus.error);
    }
  }

  /// 处理同步返回的会话数据
  /// 将Proto格式的会话数据转换为数据库模型并更新本地数据
  /// [conversations] - 从服务器同步返回的会话列表
  Future<void> _processSyncedConversations(
      List<conversation_proto.ConversationProto> conversations) async {
    try {
      // 转换为数据库对象 - 使用模型类提供的fromProto方法
      final List<db.Conversation> dbConversations =
          conversations.map((conv) => db.Conversation.fromProto(conv)).toList();

      // 更新本地数据库
      await _updateLocalConversations(dbConversations);

      _logger.i('已处理同步的会话数据', extra: {'count': dbConversations.length});
    } catch (e, stackTrace) {
      _logger.e('处理同步会话数据时出错', error: e, stackTrace: stackTrace);
    }
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

  /// 💢💢💢💢💢💢💢💢💢💢💢💢💢💢  会话相关  💢💢💢💢💢💢💢💢💢💢💢💢💢💢

  /// 获取所有会话
  /// 从本地数据库获取所有会话
  /// 返回会话列表
  @override
  Future<List<db.Conversation>> getAllConversations() async {
    try {
      _logger.i('开始从本地数据库获取所有会话');

      // 标记同步开始
      _syncStatusController.add(SyncStatus.syncing);

      // 从数据库获取最新的会话列表
      final conversations = await _conversations.where().findAll();

      // 手动按lastMessageTime降序排序,将null值排在最后
      conversations.sort((a, b) {
        if (a.lastMessageTime == null) return 1;
        if (b.lastMessageTime == null) return -1;
        return b.lastMessageTime!.compareTo(a.lastMessageTime!);
      });

      // 标记同步完成
      _syncStatusController.add(SyncStatus.completed);
      return conversations;
    } catch (error, stack) {
      _logger.e('获取会话列表失败', error: error, stackTrace: stack);

      // 标记同步错误
      _syncStatusController.add(SyncStatus.error);
      return [];
    }
  }

  /// 更新本地会话数据
  /// 将服务器返回的会话数据保存到本地数据库
  /// [serverConversations] - 从服务器获取的会话列表
  Future<void> _updateLocalConversations(
      List<db.Conversation> serverConversations) async {
    try {
      await _isar.writeTxn(() async {
        for (final conversation in serverConversations) {
          // 检查会话是否已存在
          // 根据会话ID查询本地数据库中是否已存在该会话记录
          // _conversations是Isar数据库的会话表访问器
          // filter()创建查询过滤器
          // conversationIdEqualTo()匹配指定的会话ID
          // findFirst()返回第一条匹配的记录,不存在则返回null
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
              await _conversations.put(conversation);
              _logger.d('更新已有会话',
                  extra: {'conversationId': conversation.conversationId});
            }
          } else {
            // 添加新会话
            await _conversations.put(conversation);
            _logger.d('添加新会话',
                extra: {'conversationId': conversation.conversationId});
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

  /// 标记会话为已读
  /// 调用markMessagesAsRead方法实现
  /// [conversationId] - 会话ID
  @override
  Future<void> markConversationAsRead(String conversationId) async {
    try {
      // 获取会话的最后一条消息ID
      final conversation = await getConversationById(conversationId);
      final lastMessageId = conversation?.lastMessageId;

      // 更新最后阅读时间
      await updateLastReadAt(conversationId, DateTime.now());

      // 如果有最后一条消息ID，更新最后阅读消息ID
      if (lastMessageId != null) {
        await updateLastReadMessageId(conversationId, lastMessageId);
      }

      // 标记消息为已读
      await markMessagesAsRead(conversationId);

      _logger.i('会话已标记为已读', extra: {'conversationId': conversationId});
    } catch (error) {
      _logger.e('标记会话为已读失败', error: error, stackTrace: StackTrace.current);
    }
  }

  /// 监听会话变化
  /// 返回会话列表变化的流
  @override
  Stream<void> watchConversations() {
    return _conversations.watchLazy();
  }

  /// 监听会话消息变化
  /// 监听指定会话中消息的变化
  /// [conversationId] - 会话ID
  /// 返回消息变化的流
  @override
  Stream<void> watchConversationMessages(String conversationId) {
    return _messages.filter().conversationIdEqualTo(conversationId).watchLazy();
  }

  /// 获取会话消息
  /// 获取指定会话的消息列表,支持分页
  /// [conversationId] - 会话ID
  /// [limit] - 获取消息的最大数量
  /// [before] - 可选的时间点,获取此时间之前的消息
  /// 返回消息列表
  @override
  Future<List<Message>> getConversationMessages(String conversationId,
      {int limit = 20, DateTime? before}) async {
    try {
      final query = _messages
          .filter()
          .conversationIdEqualTo(conversationId)
          .optional(before != null, (q) => q.createdAtLessThan(before!))
          .sortByCreatedAtDesc();

      final messages = await query.limit(limit).findAll();
      return messages;
    } catch (error) {
      _logger.e('获取会话消息失败', error: error, stackTrace: StackTrace.current);
      return [];
    }
  }

  /// 删除会话
  /// 删除指定的会话及其所有消息和相关媒体文件
  /// [conversationId] - 会话ID
  @override
  Future<void> deleteConversation(String conversationId) async {
    try {
      final id = int.tryParse(conversationId) ?? 0;

      // 先获取所有相关消息,以便收集需要删除的媒体文件
      final messages = await _messages
          .filter()
          .conversationIdEqualTo(conversationId)
          .findAll();

      // 收集所有媒体文件路径
      final filesToDelete = <String>[];
      for (final message in messages) {
        filesToDelete.addAll(_collectMediaFilePaths(message));
      }

      await _isar.writeTxn(() async {
        // 删除会话中的所有消息
        await _messages
            .filter()
            .conversationIdEqualTo(conversationId)
            .deleteAll();

        // 删除会话本身
        final success = await _conversations.delete(id);
        if (!success) {
          throw Exception('找不到要删除的会话');
        }
      });

      // 删除关联的媒体文件
      await _deleteMediaFiles(filesToDelete);
    } catch (error) {
      _logger.e('删除会话失败', error: error, stackTrace: StackTrace.current);
      rethrow;
    }
  }

  /// 清空会话消息
  /// 删除指定会话中的所有消息和相关媒体文件,但保留会话本身
  /// [conversationId] - 会话ID
  @override
  Future<void> clearConversationMessages(String conversationId) async {
    try {
      // 先获取所有相关消息,以便收集需要删除的媒体文件
      final messages = await _messages
          .filter()
          .conversationIdEqualTo(conversationId)
          .findAll();

      // 收集所有媒体文件路径
      final filesToDelete = <String>[];
      for (final message in messages) {
        filesToDelete.addAll(_collectMediaFilePaths(message));
      }

      // 在数据库事务中删除所有消息
      await _isar.writeTxn(() async {
        // 删除会话中的所有消息
        await _messages
            .filter()
            .conversationIdEqualTo(conversationId)
            .deleteAll();

        // 更新会话信息
        final conversation = await getConversationById(conversationId);
        if (conversation != null) {
          conversation.lastMessageTime = null;
          conversation.lastMessagePreview = null;
          conversation.unreadCount = 0;
          await _conversations.put(conversation);
        }
      });

      // 删除关联的媒体文件
      await _deleteMediaFiles(filesToDelete);
    } catch (error) {
      _logger.e('清空会话消息失败', error: error, stackTrace: StackTrace.current);
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

  /// 💢💢💢💢💢💢💢💢💢💢💢💢💢💢   消息相关   💢💢💢💢💢💢💢💢💢💢💢💢💢💢

  /// 创建消息通用方法
  /// 创建基本的消息对象,设置共同属性
  /// [conversationId] - 会话ID
  /// [text] - 消息文本
  /// [type] - 消息类型
  /// 返回创建的消息对象
  Future<Message> _createMessage(
      String conversationId, String text, String type) async {
    try {
      final message = Message();
      message.conversationId = conversationId;
      // 获取当前用户ID
      final currentUserId = await _getCurrentUserId();
      message.senderId = currentUserId;
      message.senderName = '我';
      message.type = type;
      message.text = text.isEmpty ? null : text;
      message.isRead = true; // 自己发送的消息默认已读
      message.status = 'sending';
      message.createdAt = DateTime.now();

      return message;
    } catch (error) {
      _logger.e('创建消息失败', error: error, stackTrace: StackTrace.current);
      rethrow;
    }
  }

  /// 搜索消息
  /// 根据关键词搜索消息
  /// [keyword] - 搜索关键词
  /// [conversationId] - 可选的会话ID,限定搜索范围
  /// 返回匹配的消息列表
  @override
  Future<List<Message>> searchMessages(String keyword,
      {String? conversationId}) async {
    try {
      if (keyword.isEmpty) {
        return [];
      }

      final query = _messages
          .filter()
          .optional(conversationId != null,
              (q) => q.conversationIdEqualTo(conversationId!))
          .and()
          .optional(keyword.isNotEmpty,
              (q) => q.textContains(keyword, caseSensitive: false));

      final messages = await query.sortByCreatedAtDesc().findAll();
      return messages;
    } catch (error) {
      _logger.e('搜索消息失败', error: error, stackTrace: StackTrace.current);
      return [];
    }
  }

  /// 将消息标记为已读
  /// 更新指定会话中所有未读消息的状态为已读
  /// [conversationId] - 会话ID
  Future<void> markMessagesAsRead(String conversationId) async {
    try {
      await _isar.writeTxn(() async {
        final messages = await _messages
            .filter()
            .conversationIdEqualTo(conversationId)
            .and()
            .isReadEqualTo(false)
            .findAll();
        for (final message in messages) {
          message.isRead = true;
          await _messages.put(message);
        }

        // 不再更新会话未读数，由updateLastReadAt处理
      });
    } catch (error) {
      _logger.e('标记消息为已读失败', error: error, stackTrace: StackTrace.current);
    }
  }

  /// 发送文本消息
  /// 创建并发送文本类型的消息
  /// [conversationId] - 会话ID
  /// [text] - 消息文本内容
  /// 返回创建的消息对象
  @override
  Future<Message> sendTextMessage(String conversationId, String text) async {
    final message = await _createMessage(conversationId, text, 'text');
    await sendMessage(message);
    return message;
  }

  /// 发送图片消息
  /// 创建并发送图片类型的消息,可选上传图片
  /// [conversationId] - 会话ID
  /// [localPath] - 图片本地路径
  /// [mediaUrl] - 可选的媒体URL,如已上传则直接使用
  /// 返回创建的消息对象
  @override
  Future<Message> sendImageMessage(String conversationId, String localPath,
      {String? mediaUrl}) async {
    final message = await _createMessage(conversationId, '', 'image');

    if (mediaUrl != null) {
      message.mediaUrl = mediaUrl;
    } else {
      final imageFile = File(localPath);
      // 上传图片
      final uploadResult = await _fileUploadService.uploadImage(imageFile);
      if (uploadResult != null) {
        message.mediaUrl = uploadResult.remoteUrl;
      }
    }
    message.localPath = localPath;

    await sendMessage(message);
    return message;
  }

  /// 发送语音消息
  /// 创建并发送语音类型的消息,可选上传语音文件
  /// [conversationId] - 会话ID
  /// [localPath] - 语音文件本地路径
  /// [duration] - 语音时长（秒）
  /// [mediaUrl] - 可选的媒体URL,如已上传则直接使用
  /// 返回创建的消息对象
  @override
  Future<Message> sendVoiceMessage(
      String conversationId, String localPath, int duration,
      {String? mediaUrl}) async {
    final message = await _createMessage(conversationId, '', 'voice');

    if (mediaUrl != null) {
      message.mediaUrl = mediaUrl;
      message.duration = duration;
    } else {
      final voiceFile = File(localPath);
      // 上传语音
      final uploadResult =
          await _fileUploadService.uploadVoice(voiceFile, duration);
      if (uploadResult != null) {
        message.mediaUrl = uploadResult.remoteUrl;
        if (uploadResult.duration != null) {
          message.duration = uploadResult.duration;
        } else {
          message.duration = duration;
        }
      } else {
        message.duration = duration;
      }
    }
    message.localPath = localPath;

    await sendMessage(message);
    return message;
  }

  /// 发送文件消息
  /// 创建并发送文件类型的消息,可选上传文件
  /// [conversationId] - 会话ID
  /// [localPath] - 文件本地路径
  /// [fileName] - 文件名
  /// [fileSize] - 文件大小
  /// [mediaUrl] - 可选的媒体URL,如已上传则直接使用
  /// 返回创建的消息对象
  @override
  Future<Message> sendFileMessage(
      String conversationId, String localPath, String fileName, double fileSize,
      {String? mediaUrl}) async {
    final message = await _createMessage(conversationId, '', 'file');

    if (mediaUrl != null) {
      message.mediaUrl = mediaUrl;
    } else {
      final file = File(localPath);
      // 上传文件
      final uploadResult = await _fileUploadService.uploadFile(file);
      if (uploadResult != null) {
        message.mediaUrl = uploadResult.remoteUrl;
      }
    }
    message.localPath = localPath;
    message.fileName = fileName;
    message.fileSize = fileSize;

    await sendMessage(message);
    return message;
  }

  /// 发送视频消息
  /// 创建并发送视频类型的消息,可选上传视频文件
  /// [conversationId] - 会话ID
  /// [localPath] - 视频文件本地路径
  /// [duration] - 视频时长（秒）
  /// [thumbnailUrl] - 可选的缩略图URL
  /// [mediaUrl] - 可选的媒体URL,如已上传则直接使用
  /// [isServerProcessed] - 是否由服务器处理缩略图
  /// 返回创建的消息对象
  @override
  Future<Message> sendVideoMessage(
      String conversationId, String localPath, int duration,
      {String? thumbnailUrl,
      String? mediaUrl,
      bool isServerProcessed = false}) async {
    try {
      final message = Message();
      message.conversationId = conversationId;
      // 获取当前用户ID
      final currentUserId = await _getCurrentUserId();
      message.senderId = currentUserId;
      message.senderName = '我';
      message.type = 'video';
      message.localPath = localPath;
      message.mediaUrl = mediaUrl;
      message.thumbnailUrl = thumbnailUrl;
      message.duration = duration;
      message.isRead = true; // 自己发送的消息默认已读

      // 如果缩略图由服务器处理,且尚未生成,设置状态为处理中
      if (isServerProcessed && thumbnailUrl == null) {
        message.status = 'processing'; // 服务器处理中
      } else {
        message.status = 'sent'; // 正常发送状态
      }

      await _isar.writeTxn(() async {
        message.id = await _messages.put(message);
        await _messages.put(message);

        // 更新会话最后消息预览
        final conversation = await getConversationById(conversationId);
        if (conversation != null) {
          conversation.lastMessageTime = message.createdAt;
          conversation.lastMessagePreview = '[视频]';
          await _conversations.put(conversation);
        }
      });

      // 如果是服务器处理模式且没有缩略图,模拟服务器异步处理
      if (isServerProcessed && thumbnailUrl == null) {
        _simulateServerProcessing(message);
      }

      await sendMessage(message);
      return message;
    } catch (error) {
      _logger.e('发送视频消息失败', error: error, stackTrace: StackTrace.current);
      rethrow;
    }
  }

  /// 发送位置消息
  /// 创建并发送位置类型的消息
  /// [conversationId] - 会话ID
  /// [latitude] - 纬度
  /// [longitude] - 经度
  /// [locationAddress] - 位置地址描述
  /// 返回创建的消息对象
  Future<Message> sendLocationMessage(
    String conversationId,
    double latitude,
    double longitude,
    String locationAddress,
  ) async {
    try {
      final message = Message();
      message.conversationId = conversationId;
      // 获取当前用户ID
      final currentUserId = await _getCurrentUserId();
      message.senderId = currentUserId;
      message.senderName = '我';
      message.type = 'location';
      message.latitude = latitude;
      message.longitude = longitude;
      message.locationAddress = locationAddress;
      message.isRead = true; // 自己发送的消息默认已读
      message.status = 'sent';

      await _isar.writeTxn(() async {
        message.id = await _messages.put(message);
        await _messages.put(message);

        // 更新会话最后消息预览
        final conversation = await getConversationById(conversationId);
        if (conversation != null) {
          conversation.lastMessageTime = message.createdAt;
          conversation.lastMessagePreview = '[位置] $locationAddress';
          await _conversations.put(conversation);
        }
      });

      await sendMessage(message);
      return message;
    } catch (error) {
      _logger.e('发送位置消息失败', error: error, stackTrace: StackTrace.current);
      rethrow;
    }
  }

  /// 删除消息
  /// 删除指定的消息及其相关的媒体文件
  /// [messageId] - 消息ID
  @override
  Future<void> deleteMessage(String messageId) async {
    try {
      // 使用messageId字段查询，而不是尝试转换为整数ID
      final message =
          await _messages.filter().messageIdEqualTo(messageId).findFirst();
      if (message == null) {
        throw Exception('找不到要删除的消息');
      }

      // 用于存储要删除的文件路径
      final filesToDelete = _collectMediaFilePaths(message);

      // 在数据库事务中删除消息
      await _isar.writeTxn(() async {
        // 使用消息的Isar ID删除
        final success = await _messages.delete(message.id);
        if (!success) {
          throw Exception('删除消息失败');
        }
      });

      // 删除关联的媒体文件
      await _deleteMediaFiles(filesToDelete);
    } catch (error) {
      _logger.e('删除消息失败', error: error, stackTrace: StackTrace.current);
      rethrow;
    }
  }

  /// 发送消息
  Future<String> sendMessage(Message message) async {
    try {
      // 保存消息到数据库
      await _isar.writeTxn(() async {
        message.id = await _isar.messages.put(message);
      });

      // 创建Map用于发送
      final protoMsg = message_proto.NewMessageProto()
        ..id = message.messageId
        ..senderId = message.senderId
        ..conversationId = message.conversationId
        ..content = message.text ?? ''
        ..timestamp = $fixnum.Int64(message.createdAt.millisecondsSinceEpoch)
        ..type = message.type;

      // 通过通信服务发送消息
      _communicationService.emitProto('message:new', protoMsg);

      // 更新会话的最后消息信息
      await _updateConversationLastMessage(message);

      return message.messageId;
    } catch (error) {
      _logger.e('发送消息失败', extra: {'error': error.toString()});
      throw MessageException('发送消息失败: ${error.toString()}');
    }
  }

  /// 更新会话的最后消息信息
  /// 当发送或接收新消息时，更新会话的最后消息预览和时间
  /// [message] - 最新的消息
  Future<void> _updateConversationLastMessage(Message message) async {
    try {
      await _isar.writeTxn(() async {
        // 查找会话
        final conversation = await _conversations
            .filter()
            .conversationIdEqualTo(message.conversationId)
            .findFirst();

        if (conversation != null) {
          // 更新会话信息
          conversation.lastMessageTime = message.createdAt;

          // 根据消息类型设置预览文本
          switch (message.type) {
            case 'text':
              conversation.lastMessagePreview = message.text ?? '';
              break;
            case 'image':
              conversation.lastMessagePreview = '[图片]';
              break;
            case 'voice':
              conversation.lastMessagePreview = '[语音]';
              break;
            case 'video':
              conversation.lastMessagePreview = '[视频]';
              break;
            case 'file':
              conversation.lastMessagePreview = '[文件]${message.fileName ?? ''}';
              break;
            case 'location':
              conversation.lastMessagePreview =
                  '[位置]${message.locationAddress ?? ''}';
              break;
            default:
              conversation.lastMessagePreview = '[消息]';
          }

          // 如果消息不是当前用户发送的，且用户不在会话页面中，增加未读计数
          if (message.senderId != _currentUser.userId) {
            // TODO: 检查用户是否在会话页面中（需要Socket.io房间信息）
            // 暂时简单处理：如果最后阅读时间晚于消息时间，则不增加未读计数
            final isUserInConversation = conversation.lastReadAt != null &&
                conversation.lastReadAt!.isAfter(message.createdAt);

            if (!isUserInConversation) {
              conversation.unreadCount += 1;
              _logger.d('增加会话未读计数', extra: {
                'conversationId': message.conversationId,
                'unreadCount': conversation.unreadCount
              });
            }
          }

          // 保存更新后的会话
          await _conversations.put(conversation);
        }
      });
    } catch (error) {
      _logger.e('更新会话最后消息失败', error: error, stackTrace: StackTrace.current);
    }
  }

  /// 发送消息已读状态
  /// 通知发送者消息已被读取
  /// [messageId] - 消息ID
  /// [conversationId] - 会话ID
  void sendMessageRead(String messageId, String conversationId) {
    if (_communicationService.isInitialized) {
      final readProto = message_proto.MessageReadProto()
        ..messageId = messageId
        ..conversationId = conversationId;
      _communicationService.emitProto('message:read', readProto);
      return;
    }

    _logger.w('通信服务未初始化,无法发送已读状态');
  }

  /// 从服务器获取消息
  /// 获取指定会话的消息列表,支持分页
  /// [conversationId] - 会话ID
  /// [limit] - 获取消息的最大数量
  /// [before] - 可选的时间点,获取此时间之前的消息
  /// 返回消息列表
  @override
  Future<List<Message>> fetchMessagesFromServer(String conversationId,
      {int limit = 20, DateTime? before}) async {
    try {
      _logger.i('从服务器获取消息',
          extra: {'conversationId': conversationId, 'limit': limit});

      // 创建请求参数
      final request = message_proto.MessageProto()
        ..conversationId = conversationId
        ..text = 'fetch'; // 用作临时标记

      if (before != null) {
        request.createdAt = $fixnum.Int64(before.millisecondsSinceEpoch);
      }

      // 发送请求到服务器
      await _communicationService.emitProto('messages:fetch', request);

      // 等待响应
      final response = await _communicationService
          .onProto<message_proto.MessageCollection>('messages:fetch:response')
          .first;

      // 转换服务器响应为消息列表
      final messages = response.messages.map((msg) {
        final message = Message()
          ..messageId = msg.messageId
          ..conversationId = msg.conversationId
          ..senderId = msg.senderId
          ..createdAt =
              DateTime.fromMillisecondsSinceEpoch(msg.createdAt.toInt())
          ..text = msg.text
          ..type = msg.type.toString()
          ..isRead = false
          ..status = 'received';

        // 保存消息到本地数据库
        _isar.writeTxn(() async {
          message.id = await _messages.put(message);
        });

        return message;
      }).toList();

      _logger.i('从服务器获取消息成功', extra: {'count': messages.length});
      return messages;
    } catch (error) {
      _logger.e('从服务器获取消息失败', error: error, stackTrace: StackTrace.current);
      return [];
    }
  }

  /// 💢💢💢💢💢💢💢💢💢💢💢💢💢💢     其他      💢💢💢💢💢💢💢💢💢💢💢💢💢💢

  /// 监听联系人变化
  /// 返回联系人列表变化的流
  @override
  Stream<void> watchContacts() {
    return _users.watchLazy();
  }

  /// 同步会话列表
  /// 从服务器同步最新的会话数据
  /// 该方法只发送同步请求，不返回会话列表
  /// 会话数据将通过事件通知并由状态管理系统更新UI
  @override
  Future<void> syncConversations() async {
    try {
      // 通知开始同步
      _syncStatusController.add(SyncStatus.syncing);
      _logger.i('开始会话同步流程');

      // 验证当前用户信息
      if (_currentUser.userId.isEmpty) {
        _logger.e('当前用户信息不完整，无法同步会话', extra: {'userId': _currentUser.userId});
        _syncStatusController.add(SyncStatus.error);
        return;
      }

      if (_communicationService.isInitialized) {
        // 创建同步请求并填充数据
        final syncRequest = conversation_proto.SyncConversationsRequest()
          ..userId = _currentUser.userId;

        // 获取本地会话ID列表
        final localConversations = await _conversations.where().findAll();
        final localIds = localConversations
            .map((conv) => conv.conversationId)
            .where((id) => id.isNotEmpty)
            .toList();

        // 添加本地会话ID到请求中
        syncRequest.localConversationIds.addAll(localIds);

        // 发送请求
        _communicationService.emitProto('conversation:sync', syncRequest);
        _logger.i('会话同步请求已发送', extra: {'localIdsCount': localIds.length});

        // 创建一个变量来跟踪同步状态
        bool isSyncComplete = false;

        // 添加一个临时监听器来检测同步状态变化
        final syncSubscription = _syncStatusController.stream.listen((status) {
          if (status != SyncStatus.syncing) {
            isSyncComplete = true;
          }
        });

        // 启动超时检查，如果15秒内没有收到响应，则标记为失败
        Future.delayed(const Duration(seconds: 15), () {
          syncSubscription.cancel(); // 取消监听器
          if (!isSyncComplete) {
            _logger.w('会话同步请求超时');
            _syncStatusController.add(SyncStatus.error);
          }
        });
      } else {
        _logger.e('通信服务未初始化，无法同步会话');
        _syncStatusController.add(SyncStatus.error);
      }
    } catch (error, stack) {
      _logger.e('同步会话失败', error: error, stackTrace: stack);
      _syncStatusController.add(SyncStatus.error);
      rethrow;
    }
  }

  /// 获取最后会话同步时间
  Future<DateTime?> _getLastConversationSyncTime() async {
    try {
      // 这里可以使用SharedPreferences或其他存储方式
      // 简单起见，这里暂时返回null
      return null;
    } catch (e) {
      _logger.e('获取最后会话同步时间失败', error: e);
      return null;
    }
  }

  /// 保存最后会话同步时间
  Future<void> _saveLastConversationSyncTime(DateTime time) async {
    try {
      // 这里可以使用SharedPreferences或其他存储方式
      // 简单起见，这里暂时不实现
    } catch (e) {
      _logger.e('保存最后会话同步时间失败', error: e);
    }
  }

  /// 收集消息中的媒体文件路径
  /// 分析消息对象,收集需要删除的媒体文件路径
  /// [message] - 消息对象
  /// 返回文件路径列表
  List<String> _collectMediaFilePaths(Message message) {
    final filesToDelete = <String>[];

    if (message.type == 'image' ||
        message.type == 'video' ||
        message.type == 'voice' ||
        message.type == 'file') {
      // 检查本地文件路径
      if (message.localPath != null && message.localPath!.isNotEmpty) {
        filesToDelete.add(message.localPath!);
      }

      // 检查媒体URL（如果是本地file://）
      if (message.mediaUrl != null && message.mediaUrl!.startsWith('file://')) {
        filesToDelete.add(message.mediaUrl!.substring(7)); // 移除file://前缀
      }

      // 检查缩略图URL（如果是本地file://）
      if (message.thumbnailUrl != null &&
          message.thumbnailUrl!.startsWith('file://')) {
        filesToDelete.add(message.thumbnailUrl!.substring(7)); // 移除file://前缀
      }
    }

    return filesToDelete;
  }

  /// 删除媒体文件
  /// 删除指定路径列表中的所有文件
  /// [filePaths] - 文件路径列表
  Future<void> _deleteMediaFiles(List<String> filePaths) async {
    for (final filePath in filePaths) {
      try {
        final file = File(filePath);
        if (await file.exists()) {
          await file.delete();
          _logger.d('已删除媒体文件', extra: {'path': filePath});
        }
      } catch (fileError) {
        // 文件删除失败,但不要中断整个删除过程
        _logger.w('删除媒体文件失败',
            extra: {'path': filePath, 'error': fileError.toString()});
      }
    }
  }

  /// 按日期范围获取消息
  /// 获取指定会话中特定日期范围内的消息
  /// [conversationId] - 会话ID
  /// [startDate] - 开始日期
  /// [endDate] - 结束日期
  /// [limit] - 消息数量限制
  /// 返回符合条件的消息列表
  @override
  Future<List<Message>> getMessagesByDateRange(
    String conversationId,
    DateTime startDate,
    DateTime endDate, {
    int limit = 50,
  }) async {
    try {
      int id = int.tryParse(conversationId) ?? 0;

      // 确保转换为有效的DateTime对象,避免日期比较问题
      final safeStartDate = DateTime.utc(
        startDate.year,
        startDate.month,
        startDate.day,
      );
      final safeEndDate = DateTime.utc(
        endDate.year,
        endDate.month,
        endDate.day,
        23,
        59,
        59,
      );

      _logger.d('按日期范围查询消息', extra: {
        '会话ID': id,
        '开始日期': safeStartDate.toString(),
        '结束日期': safeEndDate.toString(),
        '限制': limit
      });

      // 查询指定日期范围内的消息
      final messages = await _messages
          .filter()
          .conversationIdEqualTo(id.toString())
          .createdAtBetween(safeStartDate, safeEndDate)
          .sortByCreatedAt() // 按时间正序排序
          .limit(limit)
          .findAll();

      _logger.d('按日期范围查询结果', extra: {'找到消息数': messages.length});
      return messages;
    } catch (error) {
      _logger.e('根据日期范围获取消息失败', error: error, stackTrace: StackTrace.current);
      return [];
    }
  }

  /// 从指定日期获取会话消息
  /// 获取从指定日期开始的会话消息
  /// [conversationId] - 会话ID
  /// [startDate] - 开始日期
  /// [limit] - 消息数量限制
  /// 返回符合条件的消息列表
  @override
  Future<List<Message>> getConversationMessagesFromDate(
    String conversationId,
    DateTime startDate, {
    int limit = 30,
  }) async {
    try {
      int id = int.tryParse(conversationId) ?? 0;

      // 确保使用日期的开始时间
      final dayStart =
          DateTime(startDate.year, startDate.month, startDate.day, 0, 0, 0);

      // 查询从指定日期开始的消息
      final messages = await _messages
          .filter()
          .conversationIdEqualTo(id.toString())
          .createdAtGreaterThan(
              dayStart.subtract(const Duration(seconds: 1))) // 大于等于指定日期
          .sortByCreatedAt() // 按时间正序排序,确保最早的消息在前
          .limit(limit)
          .findAll();

      _logger.d('从日期获取消息结果', extra: {'找到消息数': messages.length});
      return messages;
    } catch (error) {
      _logger.e('从指定日期获取消息失败', error: error, stackTrace: StackTrace.current);
      return [];
    }
  }

  /// 💢💢💢💢💢💢💢💢💢💢💢💢💢💢 获取输入状态流  💢💢💢💢💢💢💢💢💢💢💢💢💢💢

  /// 发送输入状态
  /// 通知其他用户当前用户正在输入或停止输入
  /// [conversationId] - 会话ID
  /// [isTyping] - 是否正在输入
  @override
  Future<void> sendTypingStatus(String conversationId, bool isTyping) async {
    if (_communicationService.isInitialized) {
      final typingProto = message_proto.TypingProto()
        ..conversationId = conversationId
        ..isTyping = isTyping;
      _communicationService.emitProto(
          isTyping ? 'typing' : 'typing:stop', typingProto);
      return;
    }

    _logger.w('通信服务未初始化,无法发送输入状态');
  }

  /// 获取输入状态流
  /// 返回用户输入状态变化的流
  @override
  Stream<Map<String, dynamic>> getTypingStatusStream() {
    return _typingStatusController.stream;
  }

  /// 获取在线状态流
  /// 返回用户在线状态变化的流
  @override
  Stream<Map<String, dynamic>> getOnlineStatusStream() {
    return _onlineStatusController.stream;
  }

  /// 获取消息状态流
  /// 返回消息状态变化的流
  @override
  Stream<Map<String, dynamic>> getMessageStatusStream() {
    return _messageStatusController.stream;
  }

  /// 💢💢💢💢💢💢💢💢💢💢💢💢💢💢    释放资源     💢💢💢💢💢💢💢💢💢💢💢💢💢💢

  /// 释放资源
  /// 取消所有订阅并关闭流控制器
  @override
  void dispose() {
    _logger.i('销毁ChatRepository');
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
  }

  /// 💢💢💢💢💢💢💢💢💢💢💢💢💢💢      TODo     💢💢💢💢💢💢💢💢💢💢💢💢💢💢

  /// 模拟服务器处理视频缩略图
  /// 这是一个临时方法，实际应该由服务器完成
  /// [message] - 需要处理缩略图的消息
  void _simulateServerProcessing(Message message) {
    // 空实现，实际项目中应该由服务器处理
    _logger.d('模拟服务器处理视频缩略图', extra: {'messageId': message.messageId});
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
          conversation.lastMessagePreview = notification.lastMessagePreview;
          if (notification.lastMessageTime > 0) {
            conversation.lastMessageTime = DateTime.fromMillisecondsSinceEpoch(
                notification.lastMessageTime.toInt());
          }

          // 如果发送者不是当前用户，则增加未读消息计数
          if (notification.senderId != _currentUser.userId) {
            conversation.unreadCount = notification.unreadCount;
          }

          // 保存更新后的会话
          await _conversations.put(conversation);
          _logger.d('已更新本地会话数据',
              extra: {'conversationId': notification.conversationId});
        } else {
          _logger.w('本地找不到对应的会话',
              extra: {'conversationId': notification.conversationId});
          // 如果本地没有该会话，可以考虑触发会话同步
          await syncConversations();
        }
      });
    } catch (error, stackTrace) {
      _logger.e('处理会话更新通知失败', error: error, stackTrace: stackTrace);
    }
  }

  /// 测试会话更新通知功能
  /// 仅用于开发和测试，模拟接收会话更新通知
  /// [conversationId] - 会话ID
  Future<void> testConversationUpdateNotification(String conversationId) async {
    try {
      _logger.i('测试会话更新通知功能', extra: {'conversationId': conversationId});

      // 获取会话信息
      final conversation = await getConversationById(conversationId);
      if (conversation == null) {
        _logger.w('找不到会话', extra: {'conversationId': conversationId});
        return;
      }

      // 创建模拟的会话更新通知
      final notification = conversation_proto.ConversationUpdateNotification()
        ..conversationId = conversationId
        ..lastMessagePreview = '这是一条测试消息'
        ..lastMessageTime = $fixnum.Int64(DateTime.now().millisecondsSinceEpoch)
        ..unreadCount = 1
        ..senderId = 'test_user_id'
        ..senderName = '测试用户'
        ..messageType = 'text';

      // 直接调用处理方法
      _handleConversationUpdateNotification(notification);

      _logger.i('测试会话更新通知已发送');
    } catch (error) {
      _logger.e('测试会话更新通知失败', error: error, stackTrace: StackTrace.current);
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

          /* 
          // 更新最后阅读时间 - 等待proto定义更新后再启用
          if (response.hasLastReadAt()) {
            final lastReadAt = 
                DateTime.fromMillisecondsSinceEpoch(response.lastReadAt.toInt());
            conversation.lastReadAt = lastReadAt;
            
            // 如果最后阅读时间晚于或等于最后消息时间，则清零未读计数
            if (conversation.lastMessageTime != null && 
                (lastReadAt.isAfter(conversation.lastMessageTime!) || 
                 lastReadAt.isAtSameMomentAs(conversation.lastMessageTime!))) {
              conversation.unreadCount = 0;
            }
            
            _logger.d('已更新会话最后阅读时间',
                extra: {'conversationId': response.conversationId, 'lastReadAt': lastReadAt.toString()});
          }
          */

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

  @override
  Future<void> updateLastReadAt(
      String conversationId, DateTime timestamp) async {
    _logger.i('更新会话最后阅读时间', extra: {
      'conversationId': conversationId,
      'timestamp': timestamp.toString()
    });

    try {
      // 更新本地数据库
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
        _logger.i('本地数据库会话最后阅读时间已更新');
      } else {
        _logger.e('找不到指定会话', extra: {'conversationId': conversationId});
        throw Exception('找不到指定会话');
      }

      // 同步到服务器
      if (_communicationService.isInitialized) {
        _logger.i('开始同步会话最后阅读时间到服务器');

        // 创建会话标记已读请求
        final markReadRequest = conversation_proto.ConversationMarkReadRequest()
          ..conversationId = conversationId
          ..userId = _currentUser.userId
          ..readAt = $fixnum.Int64(timestamp.millisecondsSinceEpoch);

        // 发送请求到服务器
        _communicationService.emitProto(
            'conversation:mark:read', markReadRequest);

        // 监听服务器响应
        _communicationService
            .onProto<conversation_proto.ConversationMarkReadResponse>(
                'conversation:mark:read:response')
            .first
            .then((response) {
          if (response.success) {
            _logger.i('服务器已更新会话最后阅读时间', extra: {
              'conversationId': response.conversationId,
              'remainingUnread': response.remainingUnread
            });
          } else {
            _logger.w('服务器更新会话最后阅读时间失败',
                extra: {'conversationId': response.conversationId});
          }
        }).catchError((error) {
          _logger.e('接收服务器最后阅读时间更新响应时出错', error: error);
        });
      } else {
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
    _logger.i('更新会话最后阅读消息ID',
        extra: {'conversationId': conversationId, 'messageId': messageId});

    try {
      // 更新本地数据库
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
        _logger.i('本地数据库会话最后阅读消息ID已更新');
      } else {
        _logger.e('找不到指定会话', extra: {'conversationId': conversationId});
        throw Exception('找不到指定会话');
      }

      // 同步到服务器
      if (_communicationService.isInitialized) {
        _logger.i('开始同步会话最后阅读消息ID到服务器');

        // 创建会话标记已读请求
        final markReadRequest = conversation_proto.ConversationMarkReadRequest()
          ..conversationId = conversationId
          ..userId = _currentUser.userId
          ..messageId = messageId;

        // 发送请求到服务器
        _communicationService.emitProto(
            'conversation:mark:read', markReadRequest);

        // 监听服务器响应
        _communicationService
            .onProto<conversation_proto.ConversationMarkReadResponse>(
                'conversation:mark:read:response')
            .first
            .then((response) {
          if (response.success) {
            _logger.i('服务器已更新会话最后阅读消息ID', extra: {
              'conversationId': response.conversationId,
              'remainingUnread': response.remainingUnread
            });
          } else {
            _logger.w('服务器更新会话最后阅读消息ID失败',
                extra: {'conversationId': response.conversationId});
          }
        }).catchError((error) {
          _logger.e('接收服务器最后阅读消息ID更新响应时出错', error: error);
        });
      } else {
        _logger.w('通信服务未初始化，无法同步会话最后阅读消息ID到服务器');
      }
    } catch (error) {
      _logger.e('更新会话最后阅读消息ID失败', error: error);
      throw Exception('更新会话最后阅读消息ID失败: ${error.toString()}');
    }
  }

  /// 用户进入会话页面
  /// 将用户加入对应的Socket.io会话房间，但不重置未读消息计数
  /// [conversationId] - 会话ID
  @override
  Future<void> joinConversationRoom(String conversationId) async {
    try {
      _logger.i('用户进入会话页面', extra: {'conversationId': conversationId});

      // 通知服务器用户加入会话房间
      if (_communicationService.isInitialized) {
        final joinRoomRequest = conversation_proto.ConversationJoinRequest()
          ..conversationId = conversationId
          ..userId = _currentUser.userId;

        _communicationService.emitProto('conversation:join', joinRoomRequest);
        _logger.d('已发送加入会话房间请求');
      } else {
        _logger.w('通信服务未初始化，无法同步会话最后阅读消息ID到服务器');
      }

      // 更新最后阅读时间，但不重置未读计数
      await _isar.writeTxn(() async {
        final conversation = await _conversations
            .filter()
            .conversationIdEqualTo(conversationId)
            .findFirst();

        if (conversation != null) {
          conversation.lastReadAt = DateTime.now();

          // 如果有最后一条消息ID，也更新最后阅读消息ID
          if (conversation.lastMessageId != null) {
            conversation.lastReadMessageId = conversation.lastMessageId;
          }

          await _conversations.put(conversation);
          _logger.d('已更新会话最后阅读时间和最后阅读消息ID');
        }
      });
    } catch (error) {
      _logger.e('加入会话房间失败', error: error, stackTrace: StackTrace.current);
    }
  }

  /// 用户离开会话页面
  /// 将用户从对应的Socket.io会话房间中移除
  /// [conversationId] - 会话ID
  @override
  Future<void> leaveConversationRoom(String conversationId) async {
    try {
      _logger.i('用户离开会话页面', extra: {'conversationId': conversationId});

      // 通知服务器用户离开会话房间
      if (_communicationService.isInitialized) {
        final leaveRoomRequest = conversation_proto.ConversationLeaveRequest()
          ..conversationId = conversationId
          ..userId = _currentUser.userId;

        _communicationService.emitProto('conversation:leave', leaveRoomRequest);
        _logger.d('已发送离开会话房间请求');
      }
    } catch (error) {
      _logger.e('离开会话房间失败', error: error, stackTrace: StackTrace.current);
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

  /// 注册特定会话的事件处理器
  /// 当用户进入会话页面时调用，用于监听与该会话相关的事件
  /// [conversationId] - 会话ID
  @override
  void registerConversationEventHandlers(String conversationId) {
    _logger.i('注册会话事件处理器', extra: {'conversationId': conversationId});

    // 我们已经在 registerEventHandlers() 中设置了全局事件监听
    // 这里只需要记录当前活跃的会话ID，用于过滤事件
    _activeConversationId = conversationId;

    _logger.i('已注册会话[$conversationId]的事件处理器');
  }

  /// 移除特定会话的事件处理器
  /// 当用户离开会话页面时调用，用于移除与该会话相关的事件监听
  /// [conversationId] - 会话ID
  @override
  void unregisterConversationEventHandlers(String conversationId) {
    _logger.i('移除会话事件处理器', extra: {'conversationId': conversationId});

    // 清除当前活跃的会话ID
    _activeConversationId = null;

    _logger.i('已移除会话[$conversationId]的事件处理器');
  }

  /// 处理消息状态变更事件
  void _handleMessageStatus(message_proto.MessageReadProto data) {
    try {
      _messageStatusController.add({
        'messageId': data.messageId,
        'conversationId': data.conversationId,
        'status': 'read',
      });
    } catch (error) {
      _logger.e('处理消息状态变更事件失败', error: error, stackTrace: StackTrace.current);
    }
  }

  /// 处理用户输入状态事件
  void _handleTypingStatus(user_proto.UserTypingUpdate data) {
    try {
      _typingStatusController.add({
        'userId': data.userId,
        'conversationId': data.conversationId,
        'isTyping': data.isTyping,
      });
    } catch (error) {
      _logger.e('处理用户输入状态事件失败', error: error, stackTrace: StackTrace.current);
    }
  }
}
