import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:isar/isar.dart';

import 'models/user.dart';
import 'models/conversation.dart';
import 'models/message.dart';

/// 数据库初始化器
/// 负责初始化Isar数据库并提供数据库实例
class DatabaseInitializer {
  static late Isar _isar;
  static final Logger _logger = Logger();
  static bool _isInitialized = false;

  /// 获取数据库实例
  static Isar get isar {
    if (!_isInitialized) {
      throw Exception('数据库尚未初始化，请先调用init()方法');
    }
    return _isar;
  }

  /// 初始化数据库
  static Future<void> init() async {
    if (_isInitialized) {
      _logger.w('数据库已经初始化，不需要重复初始化');
      return;
    }

    try {
      final dir = await getApplicationDocumentsDirectory();
      _logger.i('数据库初始化路径: ${dir.path}');

      // 检查和清理之前的数据库（如果需要）
      await Isar.initializeIsarCore(download: true);

      // 列出所有模式，确保所有集合已注册
      _logger.d('注册数据库架构: ${[UserSchema, ConversationSchema, MessageSchema]}');

      // 打开数据库
      _isar = await Isar.open(
        [UserSchema, ConversationSchema, MessageSchema],
        directory: dir.path,
        inspector: kDebugMode, // 调试模式启用检查器
        name: 'default', // 显式指定数据库名称
      );

      // 验证和记录集合是否已正确创建
      _logger.d('数据库集合信息:');
      _logger.d('用户集合: ${_isar.users.name}');
      _logger.d('会话集合: ${_isar.conversations.name}');
      _logger.d('消息集合: ${_isar.messages.name}');

      _isInitialized = true;
      _logger.i('数据库初始化成功');

      // 创建一些初始数据用于测试
      await _createInitialData();
    } catch (e, stack) {
      _logger.e('数据库初始化失败', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// 创建初始测试数据
  static Future<void> _createInitialData() async {
    if (!kDebugMode) return; // 仅在调试模式下创建测试数据

    try {
      // 检查是否已有测试数据
      final hasUsers = await _isar.users.count() > 0;
      final hasConversations = await _isar.conversations.count() > 0;
      final hasMessages = await _isar.messages.count() > 0;

      if (hasUsers && hasConversations && hasMessages) {
        _logger.d('已存在测试数据，跳过初始数据创建');
        return;
      }

      // 创建当前用户
      final currentUser = User()
        ..name = '我'
        ..isFriend = false;

      // 创建一些联系人
      final contacts = List.generate(5, (index) {
        return User()
          ..name = '联系人${index + 1}'
          ..isFriend = true
          ..status = index % 2 == 0 ? 'online' : 'offline';
      });

      // 添加用户
      await _isar.writeTxn(() async {
        // 保存当前用户
        currentUser.id = await _isar.users.put(currentUser);
        syncIds(currentUser);
        await _isar.users.put(currentUser);

        // 保存联系人
        for (final contact in contacts) {
          contact.id = await _isar.users.put(contact);
          syncIds(contact);
          await _isar.users.put(contact);
        }
      });

      // 创建会话
      final privateConversation = Conversation()
        ..type = ConversationType.private
        ..name = contacts[0].name
        ..contactUserId = contacts[0].id.toString();

      final groupConversation = Conversation()
        ..type = ConversationType.group
        ..name = '测试群聊'
        ..createdAt = DateTime.now();

      // 保存会话和添加参与者
      await _isar.writeTxn(() async {
        // 保存私聊会话
        privateConversation.id = await _isar.conversations.put(privateConversation);
        syncIds(privateConversation);
        await _isar.conversations.put(privateConversation);

        // 添加私聊参与者
        privateConversation.participants.add(currentUser);
        privateConversation.participants.add(contacts[0]);
        await privateConversation.participants.save();

        // 保存群聊会话
        groupConversation.id = await _isar.conversations.put(groupConversation);
        syncIds(groupConversation);
        await _isar.conversations.put(groupConversation);

        // 添加群聊参与者
        groupConversation.participants.add(currentUser);
        for (final contact in contacts.take(3)) {
          groupConversation.participants.add(contact);
        }
        await groupConversation.participants.save();
      });

      // 添加测试消息
      await _createTestMessages(privateConversation.id.toString(), currentUser, contacts[0]);
      await _createTestMessages(groupConversation.id.toString(), currentUser, contacts[0], isGroup: true);

      _logger.i('测试数据创建成功');
    } catch (e) {
      _logger.e('创建测试数据失败', error: e);
      // 不抛出异常，允许应用继续运行
    }
  }

  /// 创建测试消息数据
  static Future<void> _createTestMessages(String conversationId, User currentUser, User contact, {bool isGroup = false}) async {
    try {
      final now = DateTime.now();

      // 定义一组测试消息
      final messages = [
        // 当前用户发送的消息
        Message()
          ..conversationId = conversationId
          ..senderId = currentUser.id.toString()
          ..senderName = currentUser.name
          ..text = '你好，这是一条测试消息'
          ..type = MessageType.text
          ..isRead = true
          ..status = 'sent'
          ..createdAt = now.subtract(const Duration(minutes: 30)),

        // 联系人的回复
        Message()
          ..conversationId = conversationId
          ..senderId = contact.id.toString()
          ..senderName = contact.name
          ..text = '你好，我收到了你的消息'
          ..type = MessageType.text
          ..isRead = true
          ..status = 'sent'
          ..createdAt = now.subtract(const Duration(minutes: 25)),

        // 当前用户的第二条消息
        Message()
          ..conversationId = conversationId
          ..senderId = currentUser.id.toString()
          ..senderName = currentUser.name
          ..text = '这是一条测试图片消息'
          ..type = MessageType.image
          ..mediaUrl = 'https://picsum.photos/200'
          ..isRead = true
          ..status = 'sent'
          ..createdAt = now.subtract(const Duration(minutes: 20)),

        // 联系人的最新消息
        Message()
          ..conversationId = conversationId
          ..senderId = contact.id.toString()
          ..senderName = contact.name
          ..text = '这是最新的测试消息'
          ..type = MessageType.text
          ..isRead = false // 未读消息
          ..status = 'sent'
          ..createdAt = now.subtract(const Duration(minutes: 5)),
      ];

      // 如果是群聊，添加其他成员的消息
      if (isGroup) {
        messages.add(
          Message()
            ..conversationId = conversationId
            ..senderId = '3' // 假设ID为3的成员
            ..senderName = '联系人3'
            ..text = '这是群聊中的消息'
            ..type = MessageType.text
            ..isRead = false
            ..status = 'sent'
            ..createdAt = now.subtract(const Duration(minutes: 10)),
        );
      }

      // 保存所有消息
      await _isar.writeTxn(() async {
        for (final message in messages) {
          message.id = await _isar.messages.put(message);
          syncIds(message);
          await _isar.messages.put(message);
        }

        // 更新会话的最后一条消息
        final conversation = await _isar.conversations.get(int.parse(conversationId));
        if (conversation != null) {
          // 找出最新消息
          messages.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          final lastMessage = messages.first;

          // 更新会话信息
          conversation.lastMessageTime = lastMessage.createdAt;
          conversation.lastMessagePreview = lastMessage.type == MessageType.text ? lastMessage.text : '[${lastMessage.type.toString().split('.').last}]';

          // 设置未读消息数量
          conversation.unreadCount = messages.where((m) => m.senderId != currentUser.id.toString() && !m.isRead).length;

          // 保存会话
          syncIds(conversation);
          await _isar.conversations.put(conversation);
        }
      });

      _logger.d('已为会话 $conversationId 创建 ${messages.length} 条测试消息');
    } catch (e) {
      _logger.e('创建测试消息失败: $e');
    }
  }

  /// 检查数据库是否已初始化
  static bool get isInitialized => _isInitialized;

  /// 关闭数据库（通常在应用退出时调用）
  static Future<void> close() async {
    if (_isInitialized) {
      await _isar.close();
      _isInitialized = false;
      _logger.i('数据库已关闭');
    }
  }

  /// 同步模型对象的ID字段
  /// 在保存对象前调用此方法，确保兼容性ID字段与Isar ID保持一致
  static void syncIds(dynamic obj) {
    if (obj is User && obj.id > 0) {
      obj.userId = obj.id.toString();
    } else if (obj is Conversation && obj.id > 0) {
      obj.conversationId = obj.id.toString();
      obj.safeUnreadCount = obj.unreadCount < 0 ? 0 : obj.unreadCount;
    } else if (obj is Message && obj.id > 0) {
      obj.messageId = obj.id.toString();
    }
  }
}
