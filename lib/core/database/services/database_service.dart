import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:logger/logger.dart';


import '../models/user.dart';
import '../models/conversation.dart';
import '../models/message.dart';

/// 数据库服务
/// 提供对Isar数据库的操作封装
class ChatDatabase {
  static late Isar _isar;
  static final Logger _logger = Logger();


  // 获取数据库实例
  static Isar get isar => _isar;

  /// 初始化数据库
  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    _logger.i('数据库初始化: ${dir.path}');

    _isar = await Isar.open(
      [UserSchema, ConversationSchema, MessageSchema],
      directory: dir.path,
      inspector: kDebugMode, // 调试模式启用检查器
    );

    _logger.i('数据库初始化完成');
  }



  // =================== 用户/联系人操作 ===================

  /// 保存联系人
  static Future<void> saveUser(User user) async {
    await _isar.writeTxn(() async {
      await _isar.users.put(user);
    });
  }

  /// 批量保存联系人
  static Future<void> saveUsers(List<User> users) async {
    await _isar.writeTxn(() async {
      await _isar.users.putAll(users);
    });
  }

  /// 获取所有联系人(好友)
  static Future<List<User>> getAllFriends() async {
    return await _isar.users.filter().isFriendEqualTo(true).sortByName().findAll();
  }

  /// 根据ID获取联系人
  static Future<User?> getUserById(String userId) async {
    return await _isar.users.filter().userIdEqualTo(userId).findFirst();
  }

  /// 搜索联系人
  static Future<List<User>> searchUsers(String keyword) async {
    if (keyword.isEmpty) {
      return getAllFriends();
    }

    return await _isar.users
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
  }

  // =================== 会话操作 ===================

  /// 创建或更新会话
  static Future<void> saveConversation(Conversation conversation) async {
    await _isar.writeTxn(() async {
      await _isar.conversations.put(conversation);
    });
  }

  /// 获取所有会话(按最后消息时间排序)
  static Future<List<Conversation>> getAllConversations() async {
    final conversations = await _isar.conversations.where().findAll();
    // 手动按lastMessageTime降序排序，将null值排在最后
    conversations.sort((a, b) {
      if (a.lastMessageTime == null) return 1;
      if (b.lastMessageTime == null) return -1;
      return b.lastMessageTime!.compareTo(a.lastMessageTime!);
    });
    return conversations;
  }

  /// 获取私聊会话
  static Future<Conversation?> getPrivateConversation(String userId) async {
    return await _isar.conversations.filter().typeEqualTo(ConversationType.private).and().contactUserIdEqualTo(userId).findFirst();
  }

  /// 获取群聊会话
  static Future<Conversation?> getGroupConversation(String groupId) async {
    return await _isar.conversations.filter().typeEqualTo(ConversationType.group).and().conversationIdEqualTo(groupId).findFirst();
  }

  /// 通过ID获取会话
  static Future<Conversation?> getConversationById(String conversationId) async {
    return await _isar.conversations.filter().conversationIdEqualTo(conversationId).findFirst();
  }

  /// 搜索会话
  static Future<List<Conversation>> searchConversations(String keyword) async {
    if (keyword.isEmpty) {
      return getAllConversations();
    }

    final conversations = await _isar.conversations
        .filter()
        .group((q) => q.optional(keyword.isNotEmpty, (q) => q.nameContains(keyword, caseSensitive: false)).or().lastMessagePreviewContains(keyword, caseSensitive: false))
        .findAll();

    // 手动按lastMessageTime降序排序
    conversations.sort((a, b) {
      if (a.lastMessageTime == null) return 1;
      if (b.lastMessageTime == null) return -1;
      return b.lastMessageTime!.compareTo(a.lastMessageTime!);
    });

    return conversations;
  }

  /// 删除会话
  static Future<void> deleteConversation(String conversationId) async {
    await _isar.writeTxn(() async {
      // 先查找会话（使用conversationId字符串查找，而不是整数id）
      final conversation = await getConversationById(conversationId);
      if (conversation != null) {
        // 删除会话中的所有消息
        final messages = await _isar.messages.filter().conversationIdEqualTo(conversationId).findAll();

        for (final message in messages) {
          await _isar.messages.delete(message.id); // 使用Isar内部的整数id进行删除操作
        }

        // 删除会话
        await _isar.conversations.delete(conversation.id); // 使用Isar内部的整数id进行删除操作
      }
    });
  }

  // =================== 消息操作 ===================

  /// 保存消息
  static Future<void> saveMessage(Message message) async {
    await _isar.writeTxn(() async {
      // 保存消息
      await _isar.messages.put(message);

      // 更新对应会话的最后消息信息
      final conversation = await getConversationById(message.conversationId);
      if (conversation != null) {
        conversation.lastMessageTime = message.createdAt;
        conversation.lastMessagePreview = _generateMessagePreview(message);

        // 如果不是当前用户发送的消息，增加未读数
        if (message.senderId != getCurrentUserId() && !message.isRead) {
          conversation.unreadCount += 1;
        }

        await _isar.conversations.put(conversation);
      }
    });
  }

  /// 批量保存消息
  static Future<void> saveMessages(List<Message> messages) async {
    if (messages.isEmpty) return;

    await _isar.writeTxn(() async {
      // 保存所有消息
      await _isar.messages.putAll(messages);

      // 获取消息按会话分组后的最新消息
      final Map<String, Message> latestMessages = {};
      final Map<String, int> unreadCounts = {};

      final currentUserId = getCurrentUserId();

      for (final message in messages) {
        // 统计每个会话的未读消息数
        if (message.senderId != currentUserId && !message.isRead) {
          unreadCounts[message.conversationId] = (unreadCounts[message.conversationId] ?? 0) + 1;
        }

        // 找出每个会话的最新消息
        final existing = latestMessages[message.conversationId];
        if (existing == null || message.createdAt.isAfter(existing.createdAt)) {
          latestMessages[message.conversationId] = message;
        }
      }

      // 更新各会话的最后消息信息
      for (final entry in latestMessages.entries) {
        final conversation = await getConversationById(entry.key);
        if (conversation != null) {
          conversation.lastMessageTime = entry.value.createdAt;
          conversation.lastMessagePreview = _generateMessagePreview(entry.value);

          // 更新未读数
          if (unreadCounts.containsKey(entry.key)) {
            conversation.unreadCount += unreadCounts[entry.key]!;
          }

          await _isar.conversations.put(conversation);
        }
      }
    });
  }

  /// 获取会话消息(分页)
  static Future<List<Message>> getConversationMessages(
    String conversationId, {
    int limit = 20,
    DateTime? before,
  }) async {
    final query = _isar.messages.filter().conversationIdEqualTo(conversationId).optional(before != null, (q) => q.createdAtLessThan(before!)).sortByCreatedAtDesc();

    return await query.limit(limit).findAll();
  }

  /// 标记消息为已读
  static Future<void> markMessagesAsRead(String conversationId) async {
    final currentUserId = getCurrentUserId();

    await _isar.writeTxn(() async {
      // 查找会话中所有未读消息
      final unreadMessages = await _isar.messages.filter().conversationIdEqualTo(conversationId).and().not().senderIdEqualTo(currentUserId).and().isReadEqualTo(false).findAll();

      for (final message in unreadMessages) {
        message.isRead = true;
        await _isar.messages.put(message);
      }

      // 重置会话的未读计数
      final conversation = await getConversationById(conversationId);
      if (conversation != null) {
        conversation.unreadCount = 0;
        await _isar.conversations.put(conversation);
      }
    });
  }

  /// 搜索消息
  static Future<List<Message>> searchMessages(String keyword, {String? conversationId}) async {
    if (keyword.isEmpty) {
      return [];
    }

    return await _isar.messages
        .filter()
        .optional(conversationId != null, (q) => q.conversationIdEqualTo(conversationId!))
        .optional(keyword.isNotEmpty, (q) => q.textContains(keyword, caseSensitive: false))
        .sortByCreatedAtDesc()
        .findAll();
  }

  /// 删除消息
  static Future<void> deleteMessage(String messageId) async {
    await _isar.writeTxn(() async {
      // 使用messageId字符串查找消息，而不是整数id
      final message = await _isar.messages.filter().messageIdEqualTo(messageId).findFirst();

      if (message != null) {
        await _isar.messages.delete(message.id); // 使用Isar内部的整数id进行删除操作
      }
    });
  }

  // =================== 工具方法 ===================

  /// 获取当前用户ID
  /// 注意：这里需要集成实际的用户认证系统
  static String getCurrentUserId() {
    // 实际中应该从认证系统获取当前用户ID
    // 这里暂时返回一个模拟值
    return 'current_user_id';
  }

  /// 获取当前用户信息
  static Future<User?> getCurrentUser() async {
    return await getUserById(getCurrentUserId());
  }

  /// 生成消息预览
  static String _generateMessagePreview(Message message) {
    switch (message.type) {
      case MessageType.text:
        return message.text ?? '';
      case MessageType.image:
        return '[图片]';
      case MessageType.voice:
        return '[语音]';
      case MessageType.file:
        return '[文件] ${message.fileName ?? ''}';
      case MessageType.video:
        return '[视频]';
      case MessageType.location:
        return '[位置]';
      case MessageType.system:
        return '[系统消息]';
    }
  }

  // =================== 数据监听 ===================

  /// 监听会话列表变化
  static Stream<void> watchConversations() {
    return _isar.conversations.watchLazy();
  }

  /// 监听特定会话的消息变化
  static Stream<void> watchConversationMessages(String conversationId) {
    return _isar.messages.filter().conversationIdEqualTo(conversationId).watchLazy();
  }

  /// 监听联系人变化
  static Stream<void> watchUsers() {
    return _isar.users.watchLazy();
  }
}
