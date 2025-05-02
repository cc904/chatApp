import 'package:cc/core/database/database_initializer.dart';
import 'package:cc/core/database/models/user.dart';
import 'package:cc/core/database/models/conversation.dart';
import 'package:cc/core/database/models/message.dart';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:logger/logger.dart';

/// 测试数据生成器
/// 用于生成更多的模拟聊天数据
class TestDataGenerator {
  static final Logger _logger = Logger();

  /// 生成更多测试数据
  static Future<void> generateMoreTestData({int conversationCount = 20, int messageCount = 10}) async {
    if (!kDebugMode) return; // 仅在调试模式下创建测试数据

    try {
      final isar = DatabaseInitializer.isar;
      _logger.i('开始生成更多测试数据');

      // 检查是否已有测试数据
      final hasUsers = await isar.users.count() > 0;
      if (!hasUsers) {
        _logger.w('没有用户数据，无法生成测试会话');
        return;
      }

      // 获取当前用户和现有联系人
      final currentUser = await isar.users.where().filter().isFriendEqualTo(false).findFirst() ?? (await createCurrentUser(isar));

      // 获取或创建足够的联系人
      final existingContacts = await isar.users.where().filter().isFriendEqualTo(true).findAll();
      final contacts = await ensureContacts(isar, existingContacts, 30); // 确保至少有30个联系人

      // 创建或补充私聊会话
      final privateConversations = await isar.conversations.where().filter().typeEqualTo(ConversationType.private).findAll();
      final privateCount = (conversationCount ~/ 2);
      if (privateConversations.length < privateCount) {
        await createPrivateConversations(isar, currentUser, contacts, privateCount - privateConversations.length);
      }

      // 创建或补充群聊会话
      final groupConversations = await isar.conversations.where().filter().typeEqualTo(ConversationType.group).findAll();
      final groupCount = (conversationCount ~/ 2);
      if (groupConversations.length < groupCount) {
        await createGroupConversations(isar, currentUser, contacts, groupCount - groupConversations.length);
      }

      // 确保每个会话有足够的消息
      await ensureMessagesForAllConversations(isar, currentUser, contacts, messageCount);

      _logger.i('测试数据生成完成');
    } catch (e) {
      _logger.e('生成测试数据失败', error: e);
    }
  }

  /// 确保存在当前用户，如不存在则创建
  static Future<User> createCurrentUser(Isar isar) async {
    final currentUser = User()
      ..name = '我'
      ..isFriend = false
      ..phone = '13800000000'
      ..email = 'me@example.com';

    await isar.writeTxn(() async {
      currentUser.id = await isar.users.put(currentUser);
      DatabaseInitializer.syncIds(currentUser);
      await isar.users.put(currentUser);
    });

    return currentUser;
  }

  /// 确保有足够的联系人
  static Future<List<User>> ensureContacts(Isar isar, List<User> existingContacts, int requiredCount) async {
    final contacts = List<User>.from(existingContacts);

    if (contacts.length >= requiredCount) {
      return contacts;
    }

    // 创建更多联系人直到达到所需数量
    final needToCreate = requiredCount - contacts.length;
    final newContacts = List.generate(needToCreate, (index) {
      final i = existingContacts.length + index;
      return User()
        ..name = '联系人${i + 1}'
        ..isFriend = true
        ..status = index % 3 == 0 ? 'online' : 'offline'
        ..phone = '1380000${(1000 + i).toString().padLeft(4, '0')}'
        ..email = 'contact${i + 1}@example.com'
        ..avatar = index % 5 == 0 ? 'https://picsum.photos/200?random=${1000 + i}' : '';
    });

    await isar.writeTxn(() async {
      for (final contact in newContacts) {
        contact.id = await isar.users.put(contact);
        DatabaseInitializer.syncIds(contact);
        await isar.users.put(contact);
        contacts.add(contact);
      }
    });

    return contacts;
  }

  /// 创建私聊会话
  static Future<void> createPrivateConversations(Isar isar, User currentUser, List<User> contacts, int count) async {
    // 仅使用尚未有私聊的联系人
    final usedContactIds = <String>{};
    final existingPrivateConversations = await isar.conversations.where().filter().typeEqualTo(ConversationType.private).findAll();

    for (final conv in existingPrivateConversations) {
      if (conv.contactUserId != null) {
        usedContactIds.add(conv.contactUserId!);
      }
    }

    final availableContacts = contacts.where((c) => !usedContactIds.contains(c.id.toString())).toList();

    // 创建新的私聊会话
    final newPrivateConversations = <Conversation>[];
    for (var i = 0; i < count && i < availableContacts.length; i++) {
      final contact = availableContacts[i];
      final conversation = Conversation()
        ..type = ConversationType.private
        ..name = contact.name
        ..contactUserId = contact.id.toString()
        ..createdAt = DateTime.now().subtract(Duration(days: i % 30))
        ..avatar = contact.avatar;

      newPrivateConversations.add(conversation);
    }

    // 保存会话和建立关系
    await isar.writeTxn(() async {
      for (final conversation in newPrivateConversations) {
        conversation.id = await isar.conversations.put(conversation);
        DatabaseInitializer.syncIds(conversation);
        await isar.conversations.put(conversation);

        // 添加会话参与者
        final contactId = int.tryParse(conversation.contactUserId ?? '0') ?? 0;
        final contact = await isar.users.get(contactId);

        if (contact != null) {
          conversation.participants.add(currentUser);
          conversation.participants.add(contact);
          // 避免使用返回值
          await conversation.participants.save();
        }
      }
    });
  }

  /// 创建群聊会话
  static Future<void> createGroupConversations(Isar isar, User currentUser, List<User> contacts, int count) async {
    // 创建新的群聊会话
    final newGroupConversations = <Conversation>[];
    final groupTypes = ['学习群', '工作群', '兴趣群', '朋友群', '家庭群'];

    for (var i = 0; i < count; i++) {
      final groupType = groupTypes[i % groupTypes.length];
      final groupIndex = await isar.conversations.where().filter().typeEqualTo(ConversationType.group).count() + i + 1;

      final conversation = Conversation()
        ..type = ConversationType.group
        ..name = '$groupType $groupIndex'
        ..createdAt = DateTime.now().subtract(Duration(days: i % 20));

      newGroupConversations.add(conversation);
    }

    // 保存会话和建立关系
    await isar.writeTxn(() async {
      for (final conversation in newGroupConversations) {
        conversation.id = await isar.conversations.put(conversation);
        DatabaseInitializer.syncIds(conversation);
        await isar.conversations.put(conversation);

        // 添加会话参与者 (当前用户 + 随机5-15个联系人)
        conversation.participants.add(currentUser);

        // 随机选择5-15个联系人
        final memberCount = 5 + (conversation.id.toInt() % 10);
        final shuffledContacts = List<User>.from(contacts)..shuffle();
        for (var j = 0; j < memberCount && j < shuffledContacts.length; j++) {
          conversation.participants.add(shuffledContacts[j]);
        }

        // 保存参与者关系，忽略返回值
        await conversation.participants.save();
      }
    });
  }

  /// 确保所有会话都有足够的消息
  static Future<void> ensureMessagesForAllConversations(Isar isar, User currentUser, List<User> contacts, int minimumMessageCount) async {
    final conversations = await isar.conversations.where().findAll();

    for (final conversation in conversations) {
      final existingMessageCount = await isar.messages.where().filter().conversationIdEqualTo(conversation.id.toString()).count();

      if (existingMessageCount < minimumMessageCount) {
        await createMessagesForConversation(isar, conversation, currentUser, contacts, minimumMessageCount - existingMessageCount);
      }
    }
  }

  /// 为会话创建消息
  static Future<void> createMessagesForConversation(Isar isar, Conversation conversation, User currentUser, List<User> contacts, int count) async {
    // 简化模型：为每个会话使用3个随机联系人作为消息发送者
    final shuffledContacts = List<User>.from(contacts)..shuffle();
    final randomParticipants = shuffledContacts.take(3).toList();

    // 创建消息
    final messages = <Message>[];
    final now = DateTime.now();

    // 定义一些模拟的消息文本
    final textMessages = [
      '你好，最近怎么样？',
      '我们今天需要讨论一下项目进度',
      '周末有空一起出去玩吗？',
      '刚才发的文件收到了吗？',
      '这个问题我们明天再讨论吧',
      '今天天气真好',
      '新版本已经发布了，记得更新',
      '恭喜你！',
      '我这边已经准备好了',
      '稍等，我马上发给你',
      '这个周末我有事情，下次吧',
      '好的，我知道了',
      '谢谢你的提醒',
      '这个主意不错',
      '我正在路上，很快到',
    ];

    final messageTypes = [
      MessageType.text,
      MessageType.text,
      MessageType.text,
      MessageType.text,
      MessageType.image,
      MessageType.voice,
    ];

    for (var i = 0; i < count; i++) {
      // 决定发送者
      final isSentByCurrentUser = i % 2 == 0;
      final sender = isSentByCurrentUser ? currentUser : randomParticipants[i % randomParticipants.length];

      // 决定消息类型
      final type = messageTypes[i % messageTypes.length];

      // 创建基本消息对象
      final message = Message()
        ..conversationId = conversation.id.toString()
        ..senderId = sender.id.toString()
        ..senderName = sender.name
        ..type = type
        ..isRead = isSentByCurrentUser || i % 3 != 0 // 当前用户发送的消息或部分其他消息已读
        ..status = 'sent'
        ..createdAt = now.subtract(Duration(minutes: (count - i) * 5 + (i * 3))); // 消息时间递增

      // 根据类型设置消息内容
      switch (type) {
        case MessageType.text:
          message.text = textMessages[i % textMessages.length];
          break;
        case MessageType.image:
          message.mediaUrl = 'https://picsum.photos/200?random=${1000 + i}';
          break;
        case MessageType.voice:
          message.duration = 10 + (i % 50); // 10-60秒的语音
          message.mediaUrl = 'https://example.com/voice_$i.mp3';
          break;
        default:
          message.text = '未知类型消息';
      }

      messages.add(message);
    }

    // 保存所有消息
    await isar.writeTxn(() async {
      for (final message in messages) {
        message.id = await isar.messages.put(message);
        DatabaseInitializer.syncIds(message);
        await isar.messages.put(message);
      }

      // 更新会话的最后消息信息
      if (messages.isNotEmpty) {
        messages.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        final lastMessage = messages.first;

        conversation.lastMessageTime = lastMessage.createdAt;

        if (lastMessage.type == MessageType.text) {
          conversation.lastMessagePreview = lastMessage.text ?? '';
        } else {
          conversation.lastMessagePreview = '[${lastMessage.type.toString().split('.').last}]';
        }

        // 计算未读消息数量
        conversation.unreadCount = messages.where((m) => m.senderId != currentUser.id.toString() && !m.isRead).length;

        // 保存会话
        DatabaseInitializer.syncIds(conversation);
        await isar.conversations.put(conversation);
      }
    });
  }
}
