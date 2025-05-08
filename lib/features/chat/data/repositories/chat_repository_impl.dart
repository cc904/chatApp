import 'dart:async';
import 'dart:io';
import 'package:cc/core/database/database_initializer.dart';
import 'package:cc/core/database/models/conversation.dart';
import 'package:cc/core/database/models/message.dart';
import 'package:cc/core/database/models/user.dart';
import 'package:cc/core/services/file_upload_service.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/services/my_user_service.dart';
import 'package:cc/core/services/communication_service.dart';
import 'package:cc/features/chat/domain/repositories/chat_repository.dart';
import 'package:isar/isar.dart';

/// 消息异常
class MessageException implements Exception {
  final String message;
  MessageException(this.message);

  @override
  String toString() => message;
}

/// ChatRepository的实现类
/// 负责聊天相关的数据处理、消息收发、实时通信等功能
/// 主要功能包括：
/// 1. 会话管理：创建、获取、删除会话
/// 2. 消息管理：发送、接收、查询、删除消息
/// 3. 实时通信：管理Socket连接、处理实时事件
/// 4. 联系人操作：获取联系人信息、同步联系人
class ChatRepositoryImpl implements ChatRepository {
  final LogService _logger = LogService('chat_repository_impl.dart');
  final CommunicationService _communicationService = CommunicationService();

  /// 文件上传服务，处理媒体文件上传
  final FileUploadService _fileUploadService = FileUploadService();

  /// 消息流控制器，用于向UI发送新消息通知
  final StreamController<Message> _newMessagesController = StreamController<Message>.broadcast();

  /// 输入状态流控制器，传递用户输入状态事件
  final StreamController<Map<String, dynamic>> _typingStatusController = StreamController<Map<String, dynamic>>.broadcast();

  /// 在线状态流控制器，传递用户在线状态事件
  final StreamController<Map<String, dynamic>> _onlineStatusController = StreamController<Map<String, dynamic>>.broadcast();

  /// 消息状态流控制器，传递消息送达/已读状态事件
  final StreamController<Map<String, dynamic>> _messageStatusController = StreamController<Map<String, dynamic>>.broadcast();

  /// 同步状态流控制器，传递数据同步状态事件
  final StreamController<SyncStatus> _syncStatusController = StreamController<SyncStatus>.broadcast();

  /// 通信服务事件订阅集合
  final List<StreamSubscription> _subscriptions = [];

  // 获取消息流
  Stream<Message> get messageStream => _newMessagesController.stream;

  // 获取当前数据库实例
  final Isar _isar;

  // 获取用户集合
  IsarCollection<User> get _users => _isar.users;

  // 获取会话集合
  IsarCollection<Conversation> get _conversations => _isar.conversations;

  // 获取消息集合
  IsarCollection<Message> get _messages => _isar.messages;

  final String _currentUserId;

  // 构造函数
  ChatRepositoryImpl({required Isar isar, required String currentUserId})
      : _isar = isar,
        _currentUserId = currentUserId {
    // 注册事件处理
    _registerEventHandlers();
  }

  /// 注册事件监听
  void _registerEventHandlers() {
    // 监听新消息事件
    _communicationService.onEvent('new_message').listen(_handleNewMessage);

    // 监听消息状态更新
    _communicationService.onEvent('message_delivered').listen(_handleMessageDelivered);
    _communicationService.onEvent('message_read').listen(_handleMessageRead);
  }

  /// 处理消息已送达事件
  void _handleMessageDelivered(Map<String, dynamic> data) {
    // 实现消息已送达的处理逻辑
  }

  /// 处理消息已读事件
  void _handleMessageRead(Map<String, dynamic> data) {
    // 实现消息已读的处理逻辑
  }

  /// 获取联系人信息
  /// 根据ID获取单个联系人详情
  /// [userId] - 联系人ID
  /// 返回联系人信息，不存在则返回null
  @override
  Future<User?> getContactById(String userId) async {
    try {
      int id = int.tryParse(userId) ?? 0;
      return await _users.get(id);
    } catch (e) {
      _logger.e('获取联系人信息失败', error: e);
      return null;
    }
  }

  /// 获取当前用户ID
  /// 从用户服务获取当前登录用户的ID
  /// 返回用户ID，如未找到则抛出异常
  Future<String> _getCurrentUserId() async {
    final currentUser = await MyUserService.getCurrentUser();
    if (currentUser == null) {
      throw Exception('找不到当前用户信息，请确保已登录');
    }
    return currentUser.userId;
  }

  /// 获取所有会话
  /// 从数据库获取所有会话并按最后消息时间排序
  /// 返回会话列表
  @override
  Future<List<Conversation>> getAllConversations() async {
    try {
      // 使用生成的访问器
      final conversations = await _conversations.where().findAll();
      // 手动按lastMessageTime降序排序，将null值排在最后
      conversations.sort((a, b) {
        if (a.lastMessageTime == null) return 1;
        if (b.lastMessageTime == null) return -1;
        return b.lastMessageTime!.compareTo(a.lastMessageTime!);
      });
      return conversations;
    } catch (e, stack) {
      _logger.e('获取会话列表失败', error: e, stackTrace: stack);
      _logger.d('获取会话列表失败');
      // 尝试检查是否为数据库初始化问题
      try {
        if (_isar.isOpen) {
          _logger.d('Isar 数据库已打开');
          _logger.d('尝试获取其他集合信息');
          try {
            final usersCount = await _users.count();
            _logger.d('用户集合数量', extra: {'count': usersCount});
          } catch (e) {
            _logger.e('无法获取用户集合', error: e);
          }
        } else {
          _logger.d('Isar 数据库未打开');
        }
      } catch (checkError) {
        _logger.e('检查数据库状态失败', error: checkError);
      }
      return _getMockConversations();
    }
  }

  /// 返回模拟会话数据
  /// 当数据库查询失败时提供备用的模拟数据
  /// 返回模拟的会话列表
  List<Conversation> _getMockConversations() {
    return List.generate(3, (index) {
      final isGroup = index == 2;
      final conversation = Conversation();
      conversation.type = isGroup ? ConversationType.group : ConversationType.private;
      conversation.name = isGroup ? '群聊$index' : '联系人$index';
      conversation.lastMessagePreview = '最新消息$index';
      conversation.lastMessageTime = DateTime.now().subtract(Duration(hours: index));
      conversation.unreadCount = index;
      conversation.contactUserId = isGroup ? null : (index + 1).toString(); // 模拟联系人ID
      return conversation;
    });
  }

  /// 获取会话信息
  /// 根据ID获取单个会话详情
  /// [conversationId] - 会话ID
  /// 返回会话信息，不存在则返回null
  @override
  Future<Conversation?> getConversationById(String conversationId) async {
    try {
      int id = int.tryParse(conversationId) ?? 0;
      // 使用生成的访问器
      return await _conversations.get(id);
    } catch (e) {
      _logger.e('获取会话信息失败', error: e);
      return null;
    }
  }

  /// 获取或创建私聊会话
  /// 根据联系人ID查找已有会话，不存在则创建新会话
  /// [contactUserId] - 联系人ID
  /// 返回会话对象
  @override
  Future<Conversation> getOrCreatePrivateConversation(String contactUserId) async {
    try {
      // 先查找已有的私聊会话
      final existing = await _conversations.filter().typeEqualTo(ConversationType.private).and().contactUserIdEqualTo(contactUserId).findFirst();

      if (existing != null) {
        return existing;
      }

      // 创建新会话
      final contact = await getContactById(contactUserId);
      if (contact == null) {
        throw Exception('联系人不存在');
      }

      final conversation = Conversation();
      conversation.type = ConversationType.private;
      conversation.name = contact.name;
      conversation.contactUserId = contactUserId;

      await _isar.writeTxn(() async {
        conversation.id = await _conversations.put(conversation);
        // 同步ID字段
        DatabaseInitializer.syncIds(conversation);
        await _conversations.put(conversation);

        // 添加会话参与者
        conversation.participants.add(contact);
        await conversation.participants.save();
      });

      return conversation;
    } catch (e) {
      _logger.e('获取或创建私聊会话失败', error: e);
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
  Future<Conversation> createGroupConversation(String name, List<String> memberIds, {String? avatar}) async {
    try {
      // 创建新的群聊会话
      final conversation = Conversation()
        ..type = ConversationType.group
        ..name = name
        ..avatar = avatar
        ..createdAt = DateTime.now();

      await _isar.writeTxn(() async {
        // 保存会话
        conversation.id = await _conversations.put(conversation);
        // 同步ID字段
        DatabaseInitializer.syncIds(conversation);
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
    } catch (e) {
      _logger.e('创建群聊失败', error: e);
      rethrow;
    }
  }

  /// 获取会话消息
  /// 获取指定会话的消息列表，支持分页
  /// [conversationId] - 会话ID
  /// [limit] - 获取消息的最大数量
  /// [before] - 可选的时间点，获取此时间之前的消息
  /// 返回消息列表
  @override
  Future<List<Message>> getConversationMessages(String conversationId, {int limit = 20, DateTime? before}) async {
    try {
      final query = _messages.filter().conversationIdEqualTo(conversationId).optional(before != null, (q) => q.createdAtLessThan(before!)).sortByCreatedAtDesc();

      final messages = await query.limit(limit).findAll();
      return messages;
    } catch (e) {
      _logger.e('获取会话消息失败', error: e);
      return [];
    }
  }

  /// 搜索消息
  /// 根据关键词搜索消息
  /// [keyword] - 搜索关键词
  /// [conversationId] - 可选的会话ID，限定搜索范围
  /// 返回匹配的消息列表
  @override
  Future<List<Message>> searchMessages(String keyword, {String? conversationId}) async {
    try {
      if (keyword.isEmpty) {
        return [];
      }

      final query = _messages
          .filter()
          .optional(conversationId != null, (q) => q.conversationIdEqualTo(conversationId!))
          .and()
          .optional(keyword.isNotEmpty, (q) => q.textContains(keyword, caseSensitive: false));

      final messages = await query.sortByCreatedAtDesc().findAll();
      return messages;
    } catch (e) {
      _logger.e('搜索消息失败', error: e);
      return [];
    }
  }

  /// 将消息标记为已读
  /// 更新指定会话中所有未读消息的状态为已读
  /// [conversationId] - 会话ID
  Future<void> markMessagesAsRead(String conversationId) async {
    try {
      await _isar.writeTxn(() async {
        final messages = await _messages.filter().conversationIdEqualTo(conversationId).and().isReadEqualTo(false).findAll();
        for (final message in messages) {
          message.isRead = true;
          await _messages.put(message);
        }

        // 更新会话未读数
        final conversation = await getConversationById(conversationId);
        if (conversation != null) {
          conversation.unreadCount = 0;
          await _conversations.put(conversation);
        }
      });
    } catch (e) {
      _logger.e('标记消息为已读失败', error: e);
    }
  }

  /// 标记会话为已读
  /// 调用markMessagesAsRead方法实现
  /// [conversationId] - 会话ID
  @override
  Future<void> markConversationAsRead(String conversationId) async {
    // 调用已实现的markMessagesAsRead方法
    await markMessagesAsRead(conversationId);
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

  /// 监听联系人变化
  /// 返回联系人列表变化的流
  @override
  Stream<void> watchContacts() {
    return _users.watchLazy();
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
  /// 创建并发送图片类型的消息，可选上传图片
  /// [conversationId] - 会话ID
  /// [localPath] - 图片本地路径
  /// [mediaUrl] - 可选的媒体URL，如已上传则直接使用
  /// 返回创建的消息对象
  @override
  Future<Message> sendImageMessage(String conversationId, String localPath, {String? mediaUrl}) async {
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
  /// 创建并发送语音类型的消息，可选上传语音文件
  /// [conversationId] - 会话ID
  /// [localPath] - 语音文件本地路径
  /// [duration] - 语音时长（秒）
  /// [mediaUrl] - 可选的媒体URL，如已上传则直接使用
  /// 返回创建的消息对象
  @override
  Future<Message> sendVoiceMessage(String conversationId, String localPath, int duration, {String? mediaUrl}) async {
    final message = await _createMessage(conversationId, '', 'voice');

    if (mediaUrl != null) {
      message.mediaUrl = mediaUrl;
      message.duration = duration;
    } else {
      final voiceFile = File(localPath);
      // 上传语音
      final uploadResult = await _fileUploadService.uploadVoice(voiceFile, duration);
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
  /// 创建并发送文件类型的消息，可选上传文件
  /// [conversationId] - 会话ID
  /// [localPath] - 文件本地路径
  /// [fileName] - 文件名
  /// [fileSize] - 文件大小
  /// [mediaUrl] - 可选的媒体URL，如已上传则直接使用
  /// 返回创建的消息对象
  @override
  Future<Message> sendFileMessage(String conversationId, String localPath, String fileName, double fileSize, {String? mediaUrl}) async {
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
  /// 创建并发送视频类型的消息，可选上传视频文件
  /// [conversationId] - 会话ID
  /// [localPath] - 视频文件本地路径
  /// [duration] - 视频时长（秒）
  /// [thumbnailUrl] - 可选的缩略图URL
  /// [mediaUrl] - 可选的媒体URL，如已上传则直接使用
  /// [isServerProcessed] - 是否由服务器处理缩略图
  /// 返回创建的消息对象
  @override
  Future<Message> sendVideoMessage(String conversationId, String localPath, int duration, {String? thumbnailUrl, String? mediaUrl, bool isServerProcessed = false}) async {
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

      // 如果缩略图由服务器处理，且尚未生成，设置状态为处理中
      if (isServerProcessed && thumbnailUrl == null) {
        message.status = 'processing'; // 服务器处理中
      } else {
        message.status = 'sent'; // 正常发送状态
      }

      await _isar.writeTxn(() async {
        message.id = await _messages.put(message);
        // 同步ID字段
        DatabaseInitializer.syncIds(message);
        await _messages.put(message);

        // 更新会话最后消息预览
        final conversation = await getConversationById(conversationId);
        if (conversation != null) {
          conversation.lastMessageTime = message.createdAt;
          conversation.lastMessagePreview = '[视频]';
          // 同步会话ID字段
          DatabaseInitializer.syncIds(conversation);
          await _conversations.put(conversation);
        }
      });

      // 如果是服务器处理模式且没有缩略图，模拟服务器异步处理
      if (isServerProcessed && thumbnailUrl == null) {
        _simulateServerProcessing(message);
      }

      await sendMessage(message);
      return message;
    } catch (e) {
      _logger.e('发送视频消息失败', error: e);
      rethrow;
    }
  }

  /// 模拟服务器异步处理缩略图
  /// 用于模拟模式下服务器生成视频缩略图的过程
  /// [message] - 视频消息对象
  void _simulateServerProcessing(Message message) {
    // 模拟服务器处理时间 (1-3秒)
    final processingTime = 1000 + (DateTime.now().millisecondsSinceEpoch % 2000);

    Future.delayed(Duration(milliseconds: processingTime), () async {
      try {
        // 90%的概率成功
        final isSuccess = (DateTime.now().millisecondsSinceEpoch % 10) < 9;

        await _isar.writeTxn(() async {
          if (isSuccess) {
            // 模拟服务器生成缩略图

            // 获取视频文件以模拟生成缩略图
            if (message.localPath != null) {
              final videoFile = File(message.localPath!);
              if (await videoFile.exists()) {
                // 使用生成缩略图的方法
                final thumbnailFile = await _fileUploadService.generateVideoThumbnail(message.localPath!);
                if (thumbnailFile != null) {
                  message.thumbnailUrl = 'file://${thumbnailFile.path}';
                }
              }
            }

            message.status = 'sent';
          } else {
            // 模拟服务器处理失败
            message.status = 'thumbnail_failed';
          }

          await _messages.put(message);

          // 通知消息更新
          _newMessagesController.add(message);
        });
      } catch (e) {
        _logger.e('模拟服务器处理缩略图失败', error: e);
      }
    });
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
        // 同步ID字段
        DatabaseInitializer.syncIds(message);
        await _messages.put(message);

        // 更新会话最后消息预览
        final conversation = await getConversationById(conversationId);
        if (conversation != null) {
          conversation.lastMessageTime = message.createdAt;
          conversation.lastMessagePreview = '[位置] $locationAddress';
          // 同步会话ID字段
          DatabaseInitializer.syncIds(conversation);
          await _conversations.put(conversation);
        }
      });

      await sendMessage(message);
      return message;
    } catch (e) {
      _logger.e('发送位置消息失败', error: e);
      rethrow;
    }
  }

  /// 删除消息
  /// 删除指定的消息及其相关的媒体文件
  /// [messageId] - 消息ID
  @override
  Future<void> deleteMessage(String messageId) async {
    try {
      final id = int.tryParse(messageId) ?? 0;

      // 先获取消息以获取媒体文件路径信息
      final message = await _messages.get(id);
      if (message == null) {
        throw Exception('找不到要删除的消息');
      }

      // 用于存储要删除的文件路径
      final filesToDelete = _collectMediaFilePaths(message);

      // 在数据库事务中删除消息
      await _isar.writeTxn(() async {
        final success = await _messages.delete(id);
        if (!success) {
          throw Exception('删除消息失败');
        }
      });

      // 删除关联的媒体文件
      await _deleteMediaFiles(filesToDelete);
    } catch (e) {
      _logger.e('删除消息失败', error: e);
      rethrow;
    }
  }

  /// 删除会话
  /// 删除指定的会话及其所有消息和相关媒体文件
  /// [conversationId] - 会话ID
  @override
  Future<void> deleteConversation(String conversationId) async {
    try {
      final id = int.tryParse(conversationId) ?? 0;

      // 先获取所有相关消息，以便收集需要删除的媒体文件
      final messages = await _messages.filter().conversationIdEqualTo(conversationId).findAll();

      // 收集所有媒体文件路径
      final filesToDelete = <String>[];
      for (final message in messages) {
        filesToDelete.addAll(_collectMediaFilePaths(message));
      }

      await _isar.writeTxn(() async {
        // 删除会话中的所有消息
        await _messages.filter().conversationIdEqualTo(conversationId).deleteAll();

        // 删除会话本身
        final success = await _conversations.delete(id);
        if (!success) {
          throw Exception('找不到要删除的会话');
        }
      });

      // 删除关联的媒体文件
      await _deleteMediaFiles(filesToDelete);
    } catch (e) {
      _logger.e('删除会话失败', error: e);
      rethrow;
    }
  }

  /// 清空会话消息
  /// 删除指定会话中的所有消息和相关媒体文件，但保留会话本身
  /// [conversationId] - 会话ID
  @override
  Future<void> clearConversationMessages(String conversationId) async {
    try {
      // 先获取所有相关消息，以便收集需要删除的媒体文件
      final messages = await _messages.filter().conversationIdEqualTo(conversationId).findAll();

      // 收集所有媒体文件路径
      final filesToDelete = <String>[];
      for (final message in messages) {
        filesToDelete.addAll(_collectMediaFilePaths(message));
      }

      // 在数据库事务中删除所有消息
      await _isar.writeTxn(() async {
        // 删除会话中的所有消息
        await _messages.filter().conversationIdEqualTo(conversationId).deleteAll();

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
    } catch (e) {
      _logger.e('清空会话消息失败', error: e);
      rethrow;
    }
  }

  /// 收集消息中的媒体文件路径
  /// 分析消息对象，收集需要删除的媒体文件路径
  /// [message] - 消息对象
  /// 返回文件路径列表
  List<String> _collectMediaFilePaths(Message message) {
    final filesToDelete = <String>[];

    if (message.type == 'image' || message.type == 'video' || message.type == 'voice' || message.type == 'file') {
      // 检查本地文件路径
      if (message.localPath != null && message.localPath!.isNotEmpty) {
        filesToDelete.add(message.localPath!);
      }

      // 检查媒体URL（如果是本地file://）
      if (message.mediaUrl != null && message.mediaUrl!.startsWith('file://')) {
        filesToDelete.add(message.mediaUrl!.substring(7)); // 移除file://前缀
      }

      // 检查缩略图URL（如果是本地file://）
      if (message.thumbnailUrl != null && message.thumbnailUrl!.startsWith('file://')) {
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
        // 文件删除失败，但不要中断整个删除过程
        _logger.w('删除媒体文件失败', extra: {'path': filePath, 'error': fileError.toString()});
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

      // 确保转换为有效的DateTime对象，避免日期比较问题
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

      _logger.d('按日期范围查询消息', extra: {'会话ID': id, '开始日期': safeStartDate.toString(), '结束日期': safeEndDate.toString(), '限制': limit});

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
    } catch (e) {
      _logger.e('根据日期范围获取消息失败', error: e);
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
      final dayStart = DateTime(startDate.year, startDate.month, startDate.day, 0, 0, 0);

      // 查询从指定日期开始的消息
      final messages = await _messages
          .filter()
          .conversationIdEqualTo(id.toString())
          .createdAtGreaterThan(dayStart.subtract(const Duration(seconds: 1))) // 大于等于指定日期
          .sortByCreatedAt() // 按时间正序排序，确保最早的消息在前
          .limit(limit)
          .findAll();

      _logger.d('从日期获取消息结果', extra: {'找到消息数': messages.length});
      return messages;
    } catch (e) {
      _logger.e('从指定日期获取消息失败', error: e);
      return [];
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
      final messageMap = {
        'id': message.messageId,
        'senderId': message.senderId,
        'conversationId': message.conversationId,
        'content': message.text ?? '',
        'timestamp': message.createdAt.millisecondsSinceEpoch,
        'type': message.type,
      };

      // 通过通信服务发送消息
      _communicationService.emitEvent('new_message', messageMap);

      return message.messageId;
    } catch (e) {
      _logger.e('发送消息失败', extra: {'error': e.toString()});
      throw MessageException('发送消息失败: ${e.toString()}');
    }
  }

  /// 发送输入状态
  /// 通知其他用户当前用户正在输入或停止输入
  /// [conversationId] - 会话ID
  /// [isTyping] - 是否正在输入
  @override
  Future<void> sendTypingStatus(String conversationId, bool isTyping) async {
    if (_communicationService.isInitialized) {
      _communicationService.emitEvent(isTyping ? 'typing' : 'stop_typing', {'conversationId': conversationId});
      return;
    }

    _logger.w('通信服务未初始化，无法发送输入状态');
  }

  /// 发送消息已读状态
  /// 通知发送者消息已被读取
  /// [messageId] - 消息ID
  /// [conversationId] - 会话ID
  void sendMessageRead(String messageId, String conversationId) {
    if (_communicationService.isInitialized) {
      _communicationService.emitEvent('message_read', {
        'messageId': messageId,
        'conversationId': conversationId,
      });
      return;
    }

    _logger.w('通信服务未初始化，无法发送已读状态');
  }


  /// 处理新消息
  void _handleNewMessage(Map<String, dynamic> data) {
    try {
      // 创建消息对象
      final message = Message()
        ..messageId = data['id'] ?? ''
        ..conversationId = data['conversationId'] ?? ''
        ..senderId = data['senderId'] ?? ''
        ..senderName = data['senderName'] ?? ''
        ..senderAvatar = data['senderAvatar'] ?? ''
        ..createdAt = DateTime.fromMillisecondsSinceEpoch(data['timestamp'] ?? DateTime.now().millisecondsSinceEpoch)
        ..text = data['content'] ?? ''
        ..type = data['type'] ?? 'text'
        ..isRead = false
        ..status = 'received';

      _processNewMessage(message);
    } catch (e) {
      _logger.e('处理新消息失败', extra: {'errorMessage': e.toString()});
    }
  }

  /// 处理新消息的实际逻辑
  void _processNewMessage(Message message) {
    // 保存到数据库
    _isar.writeTxn(() async {
      await _isar.messages.put(message);
    });

    // 更新会话最后消息
    _updateConversationLastMessage(message.conversationId, message.messageId, message.createdAt);

    // 通知消息已送达
    _communicationService.emitEvent('message_delivered', {
      'messageId': message.messageId,
      'conversationId': message.conversationId,
      'recipientId': message.senderId == _currentUserId ? '' : _currentUserId,
    });

    // 广播消息流更新
    _newMessagesController.add(message);
  }

  /// 更新会话最后消息
  Future<void> _updateConversationLastMessage(String conversationId, String messageId, DateTime messageTime) async {
    final conversation = await _isar.conversations.filter().conversationIdEqualTo(conversationId).findFirst();

    if (conversation != null) {
      await _isar.writeTxn(() async {
        conversation.lastMessageTime = messageTime;
        // 更新其他需要的字段...
        await _isar.conversations.put(conversation);
      });
    }
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

  /// 获取同步状态流
  /// 返回数据同步状态变化的流
  @override
  Stream<SyncStatus> getSyncStatusStream() {
    return _syncStatusController.stream;
  }

  /// 创建消息通用方法
  /// 创建基本的消息对象，设置共同属性
  /// [conversationId] - 会话ID
  /// [text] - 消息文本
  /// [type] - 消息类型
  /// 返回创建的消息对象
  Future<Message> _createMessage(String conversationId, String text, String type) async {
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
    } catch (e) {
      _logger.e('创建消息失败', error: e);
      rethrow;
    }
  }

  /// 释放资源
  /// 取消所有订阅并关闭流控制器
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();

    _newMessagesController.close();
    _typingStatusController.close();
    _onlineStatusController.close();
    _messageStatusController.close();
    _syncStatusController.close();
  }

  /// 创建或获取与用户的对话
  /// 如果已存在与该用户的一对一会话，则返回该会话ID
  /// 否则创建新会话并返回ID
  /// [userId] - 目标用户ID
  @override
  Future<String?> createOrGetConversation(String userId) async {
    try {
      _logger.i('获取或创建与用户的会话', extra: {'userId': userId});

      // 获取当前用户ID
      final currentUserId = DatabaseInitializer.currentUserId;
      if (currentUserId == null) {
        _logger.e('当前用户未登录，无法创建会话');
        return null;
      }

      // 检查是否已有与该用户的私聊会话
      final existingConversation = await _conversations.filter().typeEqualTo(ConversationType.private).and().contactUserIdEqualTo(userId).findFirst();

      if (existingConversation != null) {
        _logger.i('找到已存在的会话', extra: {'conversationId': existingConversation.conversationId});
        return existingConversation.conversationId;
      }

      // 获取目标用户信息
      final contactUser = await _users.filter().userIdEqualTo(userId).findFirst();
      if (contactUser == null) {
        _logger.e('未找到目标用户信息', extra: {'userId': userId});
        return null;
      }

      // 创建新会话
      final conversation = Conversation()
        ..type = ConversationType.private
        ..name = contactUser.name
        ..contactUserId = userId
        ..avatar = contactUser.avatar
        ..createdAt = DateTime.now();

      // 保存会话
      await _isar.writeTxn(() async {
        await _conversations.put(conversation);
        DatabaseInitializer.syncIds(conversation);
        // 建立会话与用户的关联
        await conversation.participants.save();
      });

      _logger.i('创建了新会话', extra: {'conversationId': conversation.conversationId});
      return conversation.conversationId;
    } catch (e) {
      _logger.e('创建或获取会话失败', error: e);
      return null;
    }
  }
}
