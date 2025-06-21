import 'package:flutter_test/flutter_test.dart';
import 'package:cc/core/database/models/conversation.dart';

/// Mock Repository for testing
class MockRepository {
  String? mockMessageId;
  Map<String, dynamic> calledWith = {};

  Future<String?> getFirstUnreadMessageId(
      String conversationId, String userId) async {
    calledWith['conversationId'] = conversationId;
    calledWith['userId'] = userId;
    return mockMessageId;
  }
}

void main() {
  /// 创建测试用的会话对象
  Conversation _createTestConversation() {
    final participant = Participant.create(
      userId: 'user1',
      name: 'Test User 1',
      readMessageIndex: 0,
    );

    return Conversation()
      ..conversationId = 'conv1'
      ..name = 'Test Conversation'
      ..type = ConversationType.group
      ..lastMessageIndex = 50
      ..participants = [participant];
  }

  group('Conversation hasNewMessageCount Tests', () {
    test('应该正确计算新消息数量', () {
      // 创建测试用的参与者
      final participant = Participant.create(
        userId: 'test_user_123',
        name: 'Test User',
        readMessageIndex: 10, // 用户已读到第10条消息
      );

      // 创建测试用的会话
      final conversation = Conversation()
        ..conversationId = 'test_conversation'
        ..lastMessageIndex = 15 // 会话最后消息是第15条
        ..participants = [participant];

      // 计算新消息数量
      final newMessageCount = conversation.hasNewMessageCount('test_user_123');

      // 验证结果：15 - 10 = 5条新消息
      expect(newMessageCount, equals(5));
    });

    test('用户不存在时应该返回0', () {
      final conversation = Conversation()
        ..conversationId = 'test_conversation'
        ..lastMessageIndex = 15
        ..participants = [];

      final newMessageCount =
          conversation.hasNewMessageCount('non_existent_user');

      expect(newMessageCount, equals(0));
    });

    test('用户已读消息索引大于等于最后消息索引时应该返回0', () {
      final participant = Participant.create(
        userId: 'test_user_123',
        name: 'Test User',
        readMessageIndex: 15, // 用户已读到第15条消息
      );

      final conversation = Conversation()
        ..conversationId = 'test_conversation'
        ..lastMessageIndex = 15 // 会话最后消息也是第15条
        ..participants = [participant];

      final newMessageCount = conversation.hasNewMessageCount('test_user_123');

      expect(newMessageCount, equals(0));
    });

    test('会话没有消息时应该返回0', () {
      final participant = Participant.create(
        userId: 'test_user_123',
        name: 'Test User',
        readMessageIndex: 5,
      );

      final conversation = Conversation()
        ..conversationId = 'test_conversation'
        ..lastMessageIndex = 0 // 没有消息
        ..participants = [participant];

      final newMessageCount = conversation.hasNewMessageCount('test_user_123');

      expect(newMessageCount, equals(0));
    });
  });

  /// 💢💢💢 新增：第一条未读消息相关测试
  group('getFirstUnreadMessageId Tests', () {
    test('应该正确获取第一条未读消息的索引', () {
      // 创建有未读消息的会话
      final conversation = _createTestConversation();
      conversation.lastMessageIndex = 100;

      // 用户已读到第80条消息，有20条未读
      final participant = conversation.participants.first;
      participant.readMessageIndex = 80;

      final firstUnreadIndex = conversation.getFirstUnreadMessageIndex('user1');
      expect(firstUnreadIndex, equals(81)); // 第一条未读消息索引应该是81
    });

    test('没有未读消息时应该返回null', () {
      final conversation = _createTestConversation();
      conversation.lastMessageIndex = 50;

      // 用户已读到最新消息
      final participant = conversation.participants.first;
      participant.readMessageIndex = 50;

      final firstUnreadIndex = conversation.getFirstUnreadMessageIndex('user1');
      expect(firstUnreadIndex, isNull);
    });

    test('用户不存在时应该返回null', () {
      final conversation = _createTestConversation();
      final firstUnreadIndex =
          conversation.getFirstUnreadMessageIndex('nonexistent_user');
      expect(firstUnreadIndex, isNull);
    });

    test('应该正确返回第一条未读消息的查询范围信息', () {
      final conversation = _createTestConversation();
      conversation.lastMessageIndex = 100;

      // 用户已读到第70条消息，有30条未读
      final participant = conversation.participants.first;
      participant.readMessageIndex = 70;

      final info = conversation.getFirstUnreadMessageIdInfo('user1');

      expect(info['hasUnread'], isTrue);
      expect(info['firstUnreadIndex'], equals(71));
      expect(info['canQuery'], isTrue);
      expect(info['unreadCount'], equals(30));
      expect(info['searchRange']['startIndex'], equals(71));
      expect(info['searchRange']['endIndex'], equals(100));
      expect(info['searchRange']['conversationId'], equals('conv1'));
    });

    test('没有未读消息时查询范围信息应该正确', () {
      final conversation = _createTestConversation();
      conversation.lastMessageIndex = 50;

      // 用户已读到最新消息
      final participant = conversation.participants.first;
      participant.readMessageIndex = 50;

      final info = conversation.getFirstUnreadMessageIdInfo('user1');

      expect(info['hasUnread'], isFalse);
      expect(info['firstUnreadIndex'], isNull);
      expect(info['canQuery'], isFalse);
      expect(info['searchRange'], isNull);
    });
  });

  /// 💢💢💢 新增：getUnreadMessage方法测试
  group('getUnreadMessage Tests', () {
    test('没有repository时应该返回null', () async {
      final conversation = _createTestConversation();
      conversation.lastMessageIndex = 100;

      // 用户已读到第80条消息，有20条未读
      final participant = conversation.participants.first;
      participant.readMessageIndex = 80;

      // 不提供repository
      final messageId = await conversation.getUnreadMessage('user1');
      expect(messageId, isNull);
    });

    test('没有未读消息时应该返回null', () async {
      final conversation = _createTestConversation();
      conversation.lastMessageIndex = 50;

      // 用户已读到最新消息
      final participant = conversation.participants.first;
      participant.readMessageIndex = 50;

      // Mock repository
      final mockRepository = MockRepository();
      final messageId =
          await conversation.getUnreadMessage('user1', mockRepository);
      expect(messageId, isNull);
    });

    test('用户不存在时应该返回null', () async {
      final conversation = _createTestConversation();
      final mockRepository = MockRepository();

      final messageId = await conversation.getUnreadMessage(
          'nonexistent_user', mockRepository);
      expect(messageId, isNull);
    });

    test('有未读消息且提供repository时应该调用repository方法', () async {
      final conversation = _createTestConversation();
      conversation.lastMessageIndex = 100;

      // 用户已读到第80条消息，有20条未读
      final participant = conversation.participants.first;
      participant.readMessageIndex = 80;

      // Mock repository，模拟返回消息ID
      final mockRepository = MockRepository();
      mockRepository.mockMessageId = 'test_message_id_81';

      final messageId =
          await conversation.getUnreadMessage('user1', mockRepository);
      expect(messageId, equals('test_message_id_81'));
      expect(mockRepository.calledWith['conversationId'], equals('conv1'));
      expect(mockRepository.calledWith['userId'], equals('user1'));
    });
  });

  /// 💢💢💢 新增：getUnreadMessageCount和getUnreadMessageIndex测试
  group('Utility Methods Tests', () {
    test('getUnreadMessageCount应该返回正确的未读数量', () {
      final conversation = _createTestConversation();
      conversation.lastMessageIndex = 100;

      // 用户已读到第70条消息，有30条未读
      final participant = conversation.participants.first;
      participant.readMessageIndex = 70;

      final count = conversation.getUnreadMessageCount('user1');
      expect(count, equals(30));
    });

    test('getUnreadMessageIndex应该返回正确的索引', () {
      final conversation = _createTestConversation();
      conversation.lastMessageIndex = 100;

      // 用户已读到第80条消息，第一条未读应该是81
      final participant = conversation.participants.first;
      participant.readMessageIndex = 80;

      final index = conversation.getUnreadMessageIndex('user1');
      expect(index, equals(81));
    });
  });
}
