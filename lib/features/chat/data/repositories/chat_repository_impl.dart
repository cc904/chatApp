import 'package:cc/core/database/models/user.dart';
import 'package:cc/core/database/models/conversation.dart';
import 'package:cc/core/database/models/message.dart';
import 'package:cc/core/database/database_initializer.dart';
import 'package:cc/features/chat/domain/repositories/chat_repository.dart';
import 'package:logger/logger.dart';
import 'package:isar/isar.dart';

/// ChatRepository的实现类
class ChatRepositoryImpl implements ChatRepository {
  final Logger _logger = Logger();

  // 获取当前数据库实例
  get _isar => DatabaseInitializer.isar;

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
    } catch (e) {
      _logger.e('获取会话列表失败', error: e);
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

      var query = _messages.filter().textContains(keyword, caseSensitive: false);

      // 如果指定了会话ID，只返回该会话中的消息
      if (conversationId != null) {
        query = query.and().conversationIdEqualTo(conversationId);
      }

      return await query.sortByCreatedAtDesc().findAll();
    } catch (e) {
      _logger.e('搜索消息失败', error: e);
      return [];
    }
  }

  @override
  Future<void> markConversationAsRead(String conversationId) async {
    try {
      final conv = await getConversationById(conversationId);
      if (conv == null) {
        return;
      }

      await _isar.writeTxn(() async {
        // 更新会话的未读计数
        conv.unreadCount = 0;
        // 同步会话ID字段
        DatabaseInitializer.syncIds(conv);
        await _conversations.put(conv);

        // 标记所有非自己发送的消息为已读
        final unreadMessages =
            await _messages.filter().conversationIdEqualTo(conversationId).and().not().senderIdEqualTo(_currentUserId.toString()).and().isReadEqualTo(false).findAll();

        for (final message in unreadMessages) {
          message.isRead = true;
          // 同步消息ID字段
          DatabaseInitializer.syncIds(message);
          await _messages.put(message);
        }
      });
    } catch (e) {
      _logger.e('标记会话已读失败', error: e);
      rethrow;
    }
  }

  @override
  Future<void> deleteMessage(String messageId) async {
    try {
      int id = int.tryParse(messageId) ?? 0;
      await _isar.writeTxn(() async {
        await _messages.delete(id);
      });
    } catch (e) {
      _logger.e('删除消息失败', error: e);
      rethrow;
    }
  }

  @override
  Future<void> deleteConversation(String conversationId) async {
    try {
      int id = int.tryParse(conversationId) ?? 0;
      await _isar.writeTxn(() async {
        // 删除会话关联的所有消息
        await _messages.filter().conversationIdEqualTo(conversationId).deleteAll();
        // 删除会话本身
        await _conversations.delete(id);
      });
    } catch (e) {
      _logger.e('删除会话失败', error: e);
      rethrow;
    }
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
          conversation.lastMessagePreview = text;
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
  Future<Message> sendVideoMessage(String conversationId, String localPath, int duration, {String? thumbnailUrl, String? mediaUrl}) async {
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
          conversation.lastMessagePreview = '[视频]';
          // 同步会话ID字段
          DatabaseInitializer.syncIds(conversation);
          await _conversations.put(conversation);
        }
      });

      return message;
    } catch (e) {
      _logger.e('发送视频消息失败', error: e);
      rethrow;
    }
  }
}
