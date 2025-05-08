import 'dart:math';
import 'package:cc/core/database/models/conversation.dart';
import 'package:cc/core/database/models/message.dart';
import 'package:cc/core/database/models/my_user.dart';
import 'package:cc/core/database/models/user.dart';
import 'package:cc/core/database/mock_data_manager.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:isar/isar.dart';

/// 模拟数据生成器
/// 用于生成模拟用的数据，只写入模拟数据库
class MockDataGenerator {
  static final _logger = LogService('mock_data_generator.dart');
  static final _random = Random();

  /// 生成模拟数据
  ///
  /// 这个函数会生成基础模拟数据到模拟数据库中，包括：
  /// - 创建当前用户
  /// - 创建联系人
  /// - 创建私聊会话
  /// - 创建群聊会话
  /// - 为每个会话创建消息
  static Future<void> generateMockData() async {
    try {
      // 确保模拟数据管理器已初始化
      await MockDataManager.init();
      final isar = MockDataManager.testIsar;

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

      _logger.i('模拟数据生成完成（写入到模拟数据库）');
    } catch (e) {
      _logger.e('生成模拟数据失败', error: e);
    }
  }

  /// 生成更多模拟数据
  ///
  /// 这个函数会生成更全面的模拟数据到模拟数据库中，适合更复杂的模拟场景：
  /// - 确保已有当前用户，如无则创建
  /// - 确保有足够的联系人（至少50个）
  /// - 创建充足的私聊会话（约20个）和群聊会话（约10个）
  /// - 为每个会话生成约30条消息
  static Future<void> generateMoreMockData() async {
    try {
      // 确保模拟数据管理器已初始化
      await MockDataManager.init();
      final isar = MockDataManager.testIsar;

      // 确保有当前用户
      final existingUser = await isar.myUsers.where().findFirst();
      final myUser = existingUser ?? await createCurrentUser(isar);

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

      _logger.i('模拟数据生成完成（写入到模拟数据库）');
    } catch (e) {
      _logger.e('生成模拟数据失败', error: e);
    }
  }

  /// 确保存在当前用户，如不存在则创建
  ///
  /// 这个函数会：
  /// - 查询现有的当前用户
  /// - 如果不存在，则创建一个新的MyUser对象
  /// - 设置用户信息包括固定的ID、名称"我"、认证令牌和基本联系信息
  /// - 将用户保存至模拟数据库并返回
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
      ..token = 'mock_token_${DateTime.now().millisecondsSinceEpoch}'
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
  ///
  /// 这个函数会批量创建模拟联系人到模拟数据库：
  /// - 参数count指定需要创建的联系人数量
  /// - 使用预定义的中文姓氏和名字随机组合生成联系人名称
  /// - 为每个联系人设置手机号、邮箱和在线状态
  /// - 将联系人保存至模拟数据库
  /// - 返回创建的联系人列表
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
        ..userId = 'user_${1000 + i}'
        ..phone = '138${(10000000 + i).toString().padLeft(8, '0')}'
        ..email = 'user$i@example.com'
        ..status = i % 3 == 0 ? 'online' : 'offline'
        ..pinyin = name; // 简单处理，实际应转换为拼音

      contacts.add(user);
    }

    // 保存联系人
    await isar.writeTxn(() async {
      for (final user in contacts) {
        user.id = await isar.users.put(user);
        await isar.users.put(user);
      }
    });

    return contacts;
  }

  /// 创建私聊会话
  ///
  /// 这个函数会创建私聊会话到模拟数据库：
  /// - 参数count指定要创建的私聊会话数量
  /// - 从contacts列表中选择尚未有私聊的联系人
  /// - 为每个选定的联系人创建一个私聊会话
  /// - 设置会话类型、名称(使用联系人名称)和创建时间
  /// - 将会话保存至模拟数据库
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
        ..avatar = contact.avatar
        ..conversationId = 'conv_p_${1000 + i}';

      newPrivateConversations.add(conversation);
    }

    // 保存会话和建立关系
    await isar.writeTxn(() async {
      for (final conversation in newPrivateConversations) {
        conversation.id = await isar.conversations.put(conversation);
        await isar.conversations.put(conversation);
      }
    });
  }

  /// 创建群聊会话
  ///
  /// 这个函数会创建群聊会话到模拟数据库：
  /// - 参数count指定要创建的群聊会话数量
  /// - 使用预定义的群组类型("学习群"、"工作群"等)创建群名称
  /// - 设置会话类型为群聊和创建时间
  /// - 将群聊会话保存至模拟数据库
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
        ..createdAt = DateTime.now().subtract(Duration(days: i % 20))
        ..conversationId = 'conv_g_${2000 + i}';

      newGroupConversations.add(conversation);
    }

    // 保存会话
    await isar.writeTxn(() async {
      for (final conversation in newGroupConversations) {
        conversation.id = await isar.conversations.put(conversation);
        await isar.conversations.put(conversation);
      }
    });
  }

  /// 为会话创建消息
  ///
  /// 这个函数会为指定会话创建模拟消息到模拟数据库：
  /// - 参数count指定要创建的消息数量
  /// - 从contacts中随机选择多个联系人作为消息发送者
  /// - 生成不同类型的消息（文本、图片、语音）
  /// - 交替设置消息发送者（当前用户和其他联系人）
  /// - 设置消息创建时间、已读状态等属性
  /// - 为不同类型的消息设置特定内容：
  ///   - 文本消息：设置文本内容
  ///   - 图片消息：设置媒体URL
  ///   - 语音消息：设置持续时间
  /// - 将所有消息保存至模拟数据库
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
        ..isRead = !isCurrentUserSender // 当前用户发送的消息默认未读，对方发送的默认已读
        ..messageId = 'msg_${conversation.id}_$i';

      // 根据消息类型设置内容
      switch (type) {
        case 'text':
          message.text = isCurrentUserSender ? '这是我发送的第${i + 1}条模拟消息' : '收到你的消息了，这是回复${i + 1}';
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
        await isar.messages.put(message);
      }
    });
  }
}
