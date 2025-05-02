import 'dart:async';
import 'dart:io';
import 'package:cc/core/database/database_initializer.dart';
import 'package:cc/core/database/models/conversation.dart';
import 'package:cc/core/database/models/message.dart';
import 'package:cc/core/database/models/user.dart';
import 'package:cc/features/chat/domain/repositories/chat_repository.dart';
import 'package:cc/core/services/file_upload_service.dart';
import 'package:logger/logger.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:developer' as dev;

/// ChatRepository的实现类
class ChatRepositoryImpl implements ChatRepository {
  final Logger _logger = Logger();

  // 消息流控制器，用于通知UI消息更新
  final StreamController<Message> _messageStreamController = StreamController<Message>.broadcast();

  // 获取消息流
  Stream<Message> get messageStream => _messageStreamController.stream;

  // 获取当前数据库实例
  Isar get _isar => DatabaseInitializer.isar;

  // 模拟当前用户ID，实际应该从认证服务获取
  int get _currentUserId => 1; // 假设当前用户的ID为1

  // 获取用户集合
  IsarCollection<User> get _users => _isar.collection<User>();

  // 获取会话集合
  IsarCollection<Conversation> get _conversations => _isar.collection<Conversation>();

  // 获取消息集合
  IsarCollection<Message> get _messages => _isar.collection<Message>();

  @override
  Future<List<User>> getAllContacts() async {
    try {
      return await _users.filter().isFriendEqualTo(true).sortByName().findAll();
    } catch (e) {
      _logger.e('获取联系人失败', error: e);
      return _getMockContacts();
    }
  }

  // 返回模拟联系人数据
  List<User> _getMockContacts() {
    return List.generate(5, (index) {
      final user = User();
      user.name = '联系人$index';
      user.isFriend = true;
      user.status = index % 2 == 0 ? 'online' : 'offline';
      return user;
    });
  }

  @override
  Future<List<User>> searchContacts(String keyword) async {
    try {
      if (keyword.isEmpty) {
        return getAllContacts();
      }

      return await _users
          .filter()
          .isFriendEqualTo(true)
          .group((q) => q
              .nameContains(keyword, caseSensitive: false)
              .or()
              .optional(keyword.isNotEmpty && keyword.length > 1, (q) => q.pinyinContains(keyword, caseSensitive: false))
              .or()
              .phoneContains(keyword)
              .or()
              .emailContains(keyword, caseSensitive: false))
          .sortByName()
          .findAll();
    } catch (e) {
      _logger.e('搜索联系人失败', error: e);
      return [];
    }
  }

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

  @override
  Future<void> addContact(User user) async {
    try {
      // 确保是好友状态
      user.isFriend = true;
      await _isar.writeTxn(() async {
        user.id = await _users.put(user);
        // 同步ID字段
        DatabaseInitializer.syncIds(user);
        await _users.put(user);
      });
    } catch (e) {
      _logger.e('添加联系人失败', error: e);
      rethrow;
    }
  }

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
      dev.log('获取会话列表失败: $e\n$stack');
      // 尝试检查是否为数据库初始化问题
      try {
        if (_isar.isOpen) {
          dev.log('Isar 数据库已打开');
          dev.log('尝试获取其他集合信息');
          try {
            final usersCount = await _users.count();
            dev.log('用户集合数量: $usersCount');
          } catch (e) {
            dev.log('无法获取用户集合: $e');
          }
        } else {
          dev.log('Isar 数据库未打开');
        }
      } catch (checkError) {
        dev.log('检查数据库状态失败: $checkError');
      }
      return _getMockConversations();
    }
  }

  // 返回模拟会话数据
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
        final currentUser = await _users.get(_currentUserId);
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

  @override
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

  @override
  Future<void> markConversationAsRead(String conversationId) async {
    // 调用已实现的markMessagesAsRead方法
    await markMessagesAsRead(conversationId);
  }

  @override
  Stream<void> watchConversations() {
    return _conversations.watchLazy();
  }

  @override
  Stream<void> watchConversationMessages(String conversationId) {
    return _messages.filter().conversationIdEqualTo(conversationId).watchLazy();
  }

  @override
  Stream<void> watchContacts() {
    return _users.watchLazy();
  }

  @override
  Future<Message> sendTextMessage(String conversationId, String text) async {
    try {
      final message = Message();
      message.conversationId = conversationId;
      message.senderId = _currentUserId.toString();
      message.senderName = '我';
      message.type = MessageType.text;
      message.text = text;
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
          conversation.lastMessagePreview = text.length > 20 ? '${text.substring(0, 20)}...' : text;
          // 同步会话ID字段
          DatabaseInitializer.syncIds(conversation);
          await _conversations.put(conversation);
        }
      });

      return message;
    } catch (e) {
      _logger.e('发送文本消息失败', error: e);
      rethrow;
    }
  }

  @override
  Future<Message> sendImageMessage(String conversationId, String localPath, {String? mediaUrl}) async {
    try {
      final message = Message();
      message.conversationId = conversationId;
      message.senderId = _currentUserId.toString();
      message.senderName = '我';
      message.type = MessageType.image;
      message.localPath = localPath;
      message.mediaUrl = mediaUrl;
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
          conversation.lastMessagePreview = '[图片]';
          // 同步会话ID字段
          DatabaseInitializer.syncIds(conversation);
          await _conversations.put(conversation);
        }
      });

      return message;
    } catch (e) {
      _logger.e('发送图片消息失败', error: e);
      rethrow;
    }
  }

  @override
  Future<Message> sendVoiceMessage(String conversationId, String localPath, int duration, {String? mediaUrl}) async {
    try {
      final message = Message();
      message.conversationId = conversationId;
      message.senderId = _currentUserId.toString();
      message.senderName = '我';
      message.type = MessageType.voice;
      message.localPath = localPath;
      message.mediaUrl = mediaUrl;
      message.duration = duration;
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
          conversation.lastMessagePreview = '[语音]';
          // 同步会话ID字段
          DatabaseInitializer.syncIds(conversation);
          await _conversations.put(conversation);
        }
      });

      return message;
    } catch (e) {
      _logger.e('发送语音消息失败', error: e);
      rethrow;
    }
  }

  @override
  Future<Message> sendFileMessage(String conversationId, String localPath, String fileName, double fileSize, {String? mediaUrl}) async {
    try {
      final message = Message();
      message.conversationId = conversationId;
      message.senderId = _currentUserId.toString();
      message.senderName = '我';
      message.type = MessageType.file;
      message.localPath = localPath;
      message.mediaUrl = mediaUrl;
      message.fileName = fileName;
      message.fileSize = fileSize;
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
          conversation.lastMessagePreview = '[文件] $fileName';
          // 同步会话ID字段
          DatabaseInitializer.syncIds(conversation);
          await _conversations.put(conversation);
        }
      });

      return message;
    } catch (e) {
      _logger.e('发送文件消息失败', error: e);
      rethrow;
    }
  }

  @override
  Future<Message> sendVideoMessage(String conversationId, String localPath, int duration, {String? thumbnailUrl, String? mediaUrl, bool isServerProcessed = false}) async {
    try {
      final message = Message();
      message.conversationId = conversationId;
      message.senderId = _currentUserId.toString();
      message.senderName = '我';
      message.type = MessageType.video;
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

      return message;
    } catch (e) {
      _logger.e('发送视频消息失败', error: e);
      rethrow;
    }
  }

  /// 模拟服务器异步处理缩略图
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
            final appDocDir = await getApplicationDocumentsDirectory();
            final thumbnailPath = '${appDocDir.path}/media/thumbnails/server_${DateTime.now().millisecondsSinceEpoch}.jpg';

            // 获取视频文件以模拟生成缩略图
            if (message.localPath != null) {
              final videoFile = File(message.localPath!);
              if (await videoFile.exists()) {
                // 创建服务对象
                final fileService = FileUploadService();
                // 使用生成缩略图的方法
                final thumbnailFile = await fileService.generateVideoThumbnail(message.localPath!);
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
          _messageStreamController.add(message);
        });
      } catch (e) {
        _logger.e('模拟服务器处理缩略图失败', error: e);
      }
    });
  }

  @override
  Future<Message> sendLocationMessage(
    String conversationId,
    double latitude,
    double longitude,
    String locationAddress,
  ) async {
    try {
      final message = Message();
      message.conversationId = conversationId;
      message.senderId = _currentUserId.toString();
      message.senderName = '我';
      message.type = MessageType.location;
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

      return message;
    } catch (e) {
      _logger.e('发送位置消息失败', error: e);
      rethrow;
    }
  }

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

  /// 辅助方法：收集消息中的媒体文件路径
  List<String> _collectMediaFilePaths(Message message) {
    final filesToDelete = <String>[];

    if (message.type == MessageType.image || message.type == MessageType.video || message.type == MessageType.voice || message.type == MessageType.file) {
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

  /// 辅助方法：删除媒体文件
  Future<void> _deleteMediaFiles(List<String> filePaths) async {
    for (final filePath in filePaths) {
      try {
        final file = File(filePath);
        if (await file.exists()) {
          await file.delete();
          _logger.d('已删除媒体文件: $filePath');
        }
      } catch (fileError) {
        // 文件删除失败，但不要中断整个删除过程
        _logger.w('删除媒体文件失败: $filePath, 错误: $fileError');
      }
    }
  }
}
