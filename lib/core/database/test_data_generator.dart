import 'dart:math';
import 'package:cc/core/database/database_initializer.dart';
import 'package:cc/core/database/models/conversation.dart';
import 'package:cc/core/database/models/message.dart';
import 'package:cc/core/database/models/my_user.dart';
import 'package:cc/core/database/models/user.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/services/my_user_service.dart';
import 'package:isar/isar.dart';

/// 测试数据生成器
/// 用于生成测试用的数据
class TestDataGenerator {
  static final _logger = LogService('test_data_generator.dart');
  static final _random = Random();

  /// 生成测试数据
  static Future<void> generateTestData() async {
    try {
      final isar = DatabaseInitializer.isar;

      // 创建当前用户
      final myUser = await createCurrentUser(isar);

      // 创建联系人
      final contacts = await createContacts(isar, 20);

      // 创建私聊会话
      await createPrivateConversations(isar, myUser, contacts, 8);

      // 创建群聊会话
      await createGroupConversations(isar, myUser, contacts, 5);

      // 为每个会话创建消息
      final conversations = await isar.conversations.where().findAll();
      for (final conversation in conversations) {
        await createMessages(isar, conversation, myUser, contacts, 20);
      }

      _logger.i('测试数据生成完成');
    } catch (e) {
      _logger.e('生成测试数据失败', error: e);
    }
  }

  /// 生成更多测试数据
  static Future<void> generateMoreTestData() async {
    try {
      final isar = DatabaseInitializer.isar;

      // 确保有当前用户
      final myUser = await MyUserService.getCurrentUser() ?? await createCurrentUser(isar);

      // 确保有足够的联系人
      final existingContacts = await isar.users.where().findAll();
      final contactCount = 50;
      if (existingContacts.length < contactCount) {
        await createContacts(isar, contactCount - existingContacts.length);
      }

      // 获取所有联系人
      final contacts = await isar.users.where().findAll();

      // 创建会话
      final conversationCount = 30;
      final privateCount = 20;

      // 确保有足够的私聊会话
      final privateConversations = await isar.conversations.where().filter().typeEqualTo(ConversationType.private).findAll();
      if (privateConversations.length < privateCount) {
        await createPrivateConversations(isar, myUser, contacts, privateCount - privateConversations.length);
      }

      // 确保有足够的群聊会话
      final groupConversations = await isar.conversations.where().filter().typeEqualTo(ConversationType.group).findAll();
      final groupCount = conversationCount - privateCount;
      if (groupConversations.length < groupCount) {
        await createGroupConversations(isar, myUser, contacts, groupCount - groupConversations.length);
      }

      // 为每个会话生成消息
      final allConversations = await isar.conversations.where().findAll();
      final messageCount = 30;
      for (final conversation in allConversations) {
        final existingMessages = await isar.messages.where().filter().conversationIdEqualTo(conversation.conversationId).count();
        if (existingMessages < messageCount) {
          await createMessages(isar, conversation, myUser, contacts, messageCount - existingMessages);
        }
      }

      _logger.i('测试数据生成完成');
    } catch (e) {
      _logger.e('生成测试数据失败', error: e);
    }
  }

  /// 确保存在当前用户，如不存在则创建
  static Future<MyUser> createCurrentUser(Isar isar) async {
    // 查询现有的当前用户
    final existingUser = await isar.myUsers.where().findFirst();
    if (existingUser != null) {
      return existingUser;
    }

    // 创建新的当前用户
    final myUser = MyUser()
      ..name = '我'
      ..userId = 'u000001'
      ..token = 'test_token_${DateTime.now().millisecondsSinceEpoch}'
      ..phone = '13800000000'
      ..email = 'me@example.com'
      ..status = 'online'
      ..lastLoginTime = DateTime.now();

    await isar.writeTxn(() async {
      myUser.id = await isar.myUsers.put(myUser);
    });

    return myUser;
  }

  /// 创建联系人
  static Future<List<User>> createContacts(Isar isar, int count) async {
    final contacts = <User>[];

    // 联系人名称示例
    final firstNames = ['张', '王', '李', '赵', '钱', '孙', '周', '吴', '郑', '刘'];
    final lastNames = ['小', '大', '明', '华', '强', '伟', '芳', '娜', '文', '军'];

    // 创建联系人
    for (var i = 0; i < count; i++) {
      final firstName = firstNames[_random.nextInt(firstNames.length)];
      final lastName = lastNames[_random.nextInt(lastNames.length)];
      final name = '$firstName$lastName${i + 1}';

      final user = User()
        ..name = name
        ..phone = '138${(10000000 + i).toString().padLeft(8, '0')}'
        ..email = 'user$i@example.com'
        ..status = i % 3 == 0 ? 'online' : 'offline';

      contacts.add(user);
    }

    // 保存联系人
    await isar.writeTxn(() async {
      for (final user in contacts) {
        user.id = await isar.users.put(user);
        DatabaseInitializer.syncIds(user);
        await isar.users.put(user);
      }
    });

    return contacts;
  }

  /// 创建私聊会话
  static Future<void> createPrivateConversations(Isar isar, MyUser currentUser, List<User> contacts, int count) async {
    // 仅使用尚未有私聊的联系人
    final usedContactIds = <String>{};
    final existingPrivateConversations = await isar.conversations.where().filter().typeEqualTo(ConversationType.private).findAll();

    for (final conv in existingPrivateConversations) {
      if (conv.contactUserId != null) {
        usedContactIds.add(conv.contactUserId!);
      }
    }

    final availableContacts = contacts.where((c) => !usedContactIds.contains(c.userId)).toList();

    // 创建新的私聊会话
    final newPrivateConversations = <Conversation>[];
    for (var i = 0; i < count && i < availableContacts.length; i++) {
      final contact = availableContacts[i];
      final conversation = Conversation()
        ..type = ConversationType.private
        ..name = contact.name
        ..contactUserId = contact.userId
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
      }
    });
  }

  /// 创建群聊会话
  static Future<void> createGroupConversations(Isar isar, MyUser currentUser, List<User> contacts, int count) async {
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

    // 保存会话
    await isar.writeTxn(() async {
      for (final conversation in newGroupConversations) {
        conversation.id = await isar.conversations.put(conversation);
        DatabaseInitializer.syncIds(conversation);
        await isar.conversations.put(conversation);
      }
    });
  }

  /// 为会话创建消息
  static Future<void> createMessages(Isar isar, Conversation conversation, MyUser currentUser, List<User> contacts, int count) async {
    final messages = <Message>[];
    final messageTypes = ['text', 'image', 'voice'];
    final statusOptions = ['sent', 'delivered', 'read'];

    // 随机选择多个联系人作为发送者
    final messageSenders = <User>[];
    final shuffledContacts = List<User>.from(contacts)..shuffle();
    final senderCount = min(5, shuffledContacts.length);
    messageSenders.addAll(shuffledContacts.take(senderCount));

    // 生成消息
    for (var i = 0; i < count; i++) {
      final isCurrentUserSender = i % 2 == 0; // 交替发送者
      final type = messageTypes[i % messageTypes.length];
      final status = statusOptions[i % statusOptions.length];
      final createdAt = DateTime.now().subtract(Duration(minutes: count - i));

      final message = Message()
        ..conversationId = conversation.conversationId
        ..senderId = isCurrentUserSender ? currentUser.userId : messageSenders[i % senderCount].userId
        ..senderName = isCurrentUserSender ? currentUser.name : messageSenders[i % senderCount].name
        ..type = type
        ..status = status
        ..createdAt = createdAt
        ..isRead = !isCurrentUserSender; // 当前用户发送的消息默认未读，对方发送的默认已读

      // 根据消息类型设置内容
      switch (type) {
        case 'text':
          message.text = isCurrentUserSender ? '这是我发送的第${i + 1}条测试消息' : '收到你的消息了，这是回复${i + 1}';
          break;
        case 'image':
          message.text = '[图片消息]';
          message.mediaUrl = 'https://picsum.photos/200/300?random=${conversation.id + i}';
          break;
        case 'voice':
          message.text = '[语音消息]';
          message.duration = 10 + (i % 50); // 10-60秒不等
          break;
      }

      messages.add(message);
    }

    // 保存消息
    await isar.writeTxn(() async {
      for (final message in messages) {
        message.id = await isar.messages.put(message);
        DatabaseInitializer.syncIds(message);
        await isar.messages.put(message);
      }
    });
  }
}
