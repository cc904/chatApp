import 'package:flutter_test/flutter_test.dart';
import 'package:cc/core/database/models/conversation.dart';

void main() {
  group('会话未读消息计数测试', () {
    late Conversation testConversation;
    const String testUserId = 'test_user_123';

    setUp(() {
      testConversation = Conversation()
        ..conversationId = 'conv_123'
        ..type = ConversationType.private
        ..name = 'Test Chat'
        ..firstMessageIndex = 1
        ..lastMessageIndex = 300
        ..participants = [
          Participant.create(
            userId: testUserId,
            name: 'Test User',
            readMessageIndex: 7, // 已读到第7条消息
            deliveredMessageIndex: 50,
            muted: false,
            pinned: true,
          ),
        ];
    });

    test('应该正确计算未读消息数量', () {
      // lastMessageIndex: 300, readMessageIndex: 7
      // 期望未读数量: 300 - 7 = 293
      final unreadCount = testConversation.unreadCount(testUserId);
      expect(unreadCount, 293);
    });

    test('应该正确判断是否有未读消息', () {
      final hasUnread = testConversation.hasUnread(testUserId);
      expect(hasUnread, true);
    });

    test('应该正确获取第一条未读消息索引', () {
      // 第一条未读消息索引应该是 readMessageIndex + 1 = 7 + 1 = 8
      final firstUnreadIndex =
          testConversation.getFirstUnreadMessageIndex(testUserId);
      expect(firstUnreadIndex, 8);
    });

    test('应该正确获取参与者信息', () {
      final participant = testConversation.getParticipant(testUserId);
      expect(participant, isNotNull);
      expect(participant!.userId, testUserId);
      expect(participant.readMessageIndex, 7);
      expect(participant.pinned, true);
    });

    test('应该正确获取未读消息详细信息', () {
      final info = testConversation.getUnreadMessageInfo(testUserId);
      expect(info['unreadCount'], 293);
      expect(info['hasUnread'], true);
      expect(info['lastReadIndex'], 7);
      expect(info['lastMessageIndex'], 300);
      expect(info['participantFound'], true);
    });

    test('当没有未读消息时应该返回0', () {
      // 更新已读索引到最新消息
      testConversation.updateCurrentUserSettings(
        currentUserId: testUserId,
        readMessageIndex: 300,
      );

      final unreadCount = testConversation.unreadCount(testUserId);
      expect(unreadCount, 0);

      final hasUnread = testConversation.hasUnread(testUserId);
      expect(hasUnread, false);

      final firstUnreadIndex =
          testConversation.getFirstUnreadMessageIndex(testUserId);
      expect(firstUnreadIndex, null);
    });

    test('当用户不存在时应该返回0', () {
      final unreadCount = testConversation.unreadCount('non_existent_user');
      expect(unreadCount, 0);

      final hasUnread = testConversation.hasUnread('non_existent_user');
      expect(hasUnread, false);
    });

    test('测试模拟日志中的实际数据', () {
      // 模拟日志中的实际数据
      testConversation.lastMessageIndex = 301;
      testConversation.updateCurrentUserSettings(
        currentUserId: testUserId,
        readMessageIndex: 7,
      );

      final unreadCount = testConversation.unreadCount(testUserId);
      print('📊 测试结果:');
      print('  lastMessageIndex: ${testConversation.lastMessageIndex}');
      print(
          '  readMessageIndex: ${testConversation.getParticipant(testUserId)?.readMessageIndex}');
      print('  计算的未读数量: $unreadCount');

      expect(unreadCount, 294); // 301 - 7 = 294
    });
  });
}
