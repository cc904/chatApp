import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:cc/core/services/log_service.dart';

import '../models/user.dart';
import '../models/conversation.dart';
import '../models/message.dart';

/// 数据库服务
/// 提供对Isar数据库的操作封装
class ChatDatabase {
  static late Isar _isar;
  static final _logger = LogService.instance;

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
    return await _isar.users.where().sortByName().findAll();
  }

  /// 根据ID获取联系人
  static Future<User?> getUserById(String userId) async {
    final id = int.tryParse(userId);
    if (id == null) return null;
    return await _isar.users.get(id);
  }

  /// 搜索联系人
  static Future<List<User>> searchContacts(String keyword) async {
    if (keyword.isEmpty) {
      return getAllFriends();
    }

    return await _isar.users
        .filter()
        .group((q) => q.nameContains(keyword, caseSensitive: false).or().phoneContains(keyword).or().emailContains(keyword, caseSensitive: false))
        .sortByName()
        .findAll();
  }

  // =================== 会话操作 ===================

  /// 保存会话
  static Future<void> saveConversation(Conversation conversation) async {
    await _isar.writeTxn(() async {
      await _isar.conversations.put(conversation);
    });
  }

  /// 批量保存会话
  static Future<void> saveConversations(List<Conversation> conversations) async {
    await _isar.writeTxn(() async {
      await _isar.conversations.putAll(conversations);
    });
  }

  /// 获取所有会话
  static Future<List<Conversation>> getAllConversations() async {
    return await _isar.conversations.where().sortByLastMessageTime().findAll();
  }

  /// 根据ID获取会话
  static Future<Conversation?> getConversationById(String conversationId) async {
    final id = int.tryParse(conversationId);
    if (id == null) return null;
    return await _isar.conversations.get(id);
  }

  /// 删除会话
  static Future<void> deleteConversation(String conversationId) async {
    final id = int.tryParse(conversationId);
    if (id == null) return;
    await _isar.writeTxn(() async {
      await _isar.conversations.delete(id);
    });
  }

  // =================== 消息操作 ===================

  /// 保存消息
  static Future<void> saveMessage(Message message) async {
    await _isar.writeTxn(() async {
      await _isar.messages.put(message);
    });
  }

  /// 批量保存消息
  static Future<void> saveMessages(List<Message> messages) async {
    await _isar.writeTxn(() async {
      await _isar.messages.putAll(messages);
    });
  }

  /// 获取会话的所有消息
  static Future<List<Message>> getMessagesByConversation(String conversationId) async {
    return await _isar.messages.filter().conversationIdEqualTo(conversationId).sortByCreatedAt().findAll();
  }

  /// 获取会话的最近消息
  static Future<List<Message>> getRecentMessages(String conversationId, {int limit = 20}) async {
    return await _isar.messages.filter().conversationIdEqualTo(conversationId).sortByCreatedAt().limit(limit).findAll();
  }

  /// 删除消息
  static Future<void> deleteMessage(String messageId) async {
    final id = int.tryParse(messageId);
    if (id == null) return;
    await _isar.writeTxn(() async {
      await _isar.messages.delete(id);
    });
  }

  /// 批量删除消息
  static Future<void> deleteMessages(List<String> messageIds) async {
    final ids = messageIds.map((id) => int.tryParse(id)).whereType<int>().toList();
    await _isar.writeTxn(() async {
      await _isar.messages.deleteAll(ids);
    });
  }

  /// 清空所有数据
  static Future<void> clearAll() async {
    await _isar.writeTxn(() async {
      await _isar.clear();
    });
  }
}
