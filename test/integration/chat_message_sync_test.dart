import 'package:flutter_test/flutter_test.dart';
import 'package:cc/core/database/models/message.dart';
import 'package:cc/core/database/models/conversation.dart';
import 'package:cc/core/database/models/current_user.dart';
import 'package:cc/features/chat/presentation/cubit/chat_state.dart';
import 'package:cc/features/chat/domain/entities/unread_jump_strategy.dart';

void main() {
  group('聊天消息同步集成测试 - 业务逻辑验证', () {
    // 测试用的消息创建工具
    Message createTestMessage(String id, DateTime time, String content) {
      final message = Message()
        ..messageId = id
        ..text = content
        ..senderId = 'user123'
        ..createdAt = time
        ..type = 'text'
        ..status = 'sent';
      return message;
    }

    // 测试用的会话创建工具
    Conversation createTestConversation(String id) {
      final conversation = Conversation()
        ..conversationId = id
        ..type = ConversationType.private
        ..name = '测试会话'
        ..createdAt = DateTime.now();
      return conversation;
    }

    // 测试用的用户创建工具
    CurrentUser createTestUser() {
      final user = CurrentUser()
        ..userId = 'user123'
        ..name = '测试用户'
        ..token = 'test_token'
        ..status = 'online';
      return user;
    }

    group('场景1: 首次进入聊天', () {
      testWidgets('应该显示到最新消息，位置在UI底部第一条', (WidgetTester tester) async {
        // 安排：创建30条测试消息（模拟首次加载）
        final baseTime = DateTime.now().subtract(const Duration(hours: 1));
        final messages = List.generate(30, (index) {
          return createTestMessage(
            'msg_${index + 1}',
            baseTime.add(Duration(minutes: index * 2)),
            '这是第${index + 1}条消息',
          );
        });

        // 使用UnreadJumpStrategy分析
        final decision = UnreadJumpStrategy.analyzeUnreadMessages(
          [], // 首次进入，无未读消息
          latestMessage: messages.last, // 最新消息
        );

        // 断言：应该跳转到最新消息
        expect(decision.strategy, equals(UnreadJumpStrategy.jumpToLatest));
        expect(decision.reason, contains('有新消息但无未读'));
        expect(decision.targetMessageId, equals('msg_30'));
        expect(decision.hasUnreadMessages, isFalse);

        // 验证滚动位置设置
        final scrollPosition = CurrentScrollPosition.fromAnchor(
          messageId: decision.targetMessageId!,
          messageIndex: 0, // 最新消息在索引0
          relativePosition: 0.0, // UI底部第一条
        );

        expect(scrollPosition.messageId, equals('msg_30'));
        expect(scrollPosition.messageIndex, equals(0));
        expect(scrollPosition.relativePosition, equals(0.0));

        print('✅ 场景1测试通过：首次进入显示到最新消息(${decision.targetMessageId})');
      });
    });

    group('场景2: 有新消息+无未读', () {
      testWidgets('应该显示到最新消息，位置在UI底部第一条', (WidgetTester tester) async {
        // 安排：模拟用户之前看过消息，现在有新消息但无未读状态
        final baseTime = DateTime.now().subtract(const Duration(hours: 2));
        final existingMessages = List.generate(20, (index) {
          return createTestMessage(
            'existing_${index + 1}',
            baseTime.add(Duration(minutes: index * 3)),
            '之前的消息${index + 1}',
          );
        });

        // 新增的消息（增量同步获取）
        final newMessages = List.generate(5, (index) {
          return createTestMessage(
            'new_${index + 1}',
            baseTime.add(Duration(hours: 1, minutes: index * 2)),
            '新消息${index + 1}',
          );
        });

        final allMessages = [...existingMessages, ...newMessages];

        // 使用UnreadJumpStrategy分析
        final decision = UnreadJumpStrategy.analyzeUnreadMessages(
          [], // 无未读消息
          latestMessage: allMessages.last, // 最新消息
        );

        // 断言：应该跳转到最新消息
        expect(decision.strategy, equals(UnreadJumpStrategy.jumpToLatest));
        expect(decision.reason, contains('有新消息但无未读'));
        expect(decision.targetMessageId, equals('new_5'));
        expect(decision.hasUnreadMessages, isFalse);

        print('✅ 场景2测试通过：有新消息无未读显示到最新消息(${decision.targetMessageId})');
      });
    });

    group('场景3: 有未读消息', () {
      testWidgets('单条未读消息 - 应该显示到最新消息', (WidgetTester tester) async {
        // 安排：1条未读消息
        final unreadMessage = createTestMessage(
          'unread_1',
          DateTime.now(),
          '未读消息内容',
        );

        // 使用UnreadJumpStrategy分析
        final decision =
            UnreadJumpStrategy.analyzeUnreadMessages([unreadMessage]);

        // 断言：应该跳转到最新消息（即这条未读消息）
        expect(decision.strategy, equals(UnreadJumpStrategy.jumpToLatest));
        expect(decision.reason, contains('有1条未读消息，显示到最新消息'));
        expect(decision.targetMessageId, equals('unread_1'));
        expect(decision.hasUnreadMessages, isTrue);
        expect(decision.totalUnreadCount, equals(1));

        print('✅ 场景3a测试通过：单条未读消息显示到最新消息(${decision.targetMessageId})');
      });

      testWidgets('多条未读消息 - 应该显示到最新消息（最新的未读消息）', (WidgetTester tester) async {
        // 安排：5条未读消息
        final baseTime = DateTime.now().subtract(const Duration(hours: 1));
        final unreadMessages = List.generate(5, (index) {
          return createTestMessage(
            'unread_${index + 1}',
            baseTime.add(Duration(minutes: index * 10)),
            '未读消息${index + 1}',
          );
        });

        // 使用UnreadJumpStrategy分析
        final decision =
            UnreadJumpStrategy.analyzeUnreadMessages(unreadMessages);

        // 断言：应该跳转到最新消息（最后一条未读消息）
        expect(decision.strategy, equals(UnreadJumpStrategy.jumpToLatest));
        expect(decision.reason, contains('有5条未读消息，显示到最新消息'));
        expect(decision.targetMessageId, equals('unread_5')); // 最新的未读消息
        expect(decision.hasUnreadMessages, isTrue);
        expect(decision.totalUnreadCount, equals(5));

        // 验证跳转上下文
        final context =
            UnreadJumpStrategy.calculateJumpContext(unreadMessages, decision);
        expect(context.totalUnreadCount, equals(5));
        expect(context.jumpedToIndex, equals(4)); // 最新消息的索引
        expect(context.remainingUnreadCount, equals(0)); // 跳转到最新后无剩余

        print('✅ 场景3b测试通过：多条未读消息显示到最新消息(${decision.targetMessageId})');
      });

      testWidgets('大量未读消息 - 应该显示到最新消息', (WidgetTester tester) async {
        // 安排：50条未读消息
        final baseTime = DateTime.now().subtract(const Duration(days: 2));
        final unreadMessages = List.generate(50, (index) {
          return createTestMessage(
            'unread_${index + 1}',
            baseTime.add(Duration(minutes: index * 5)),
            '未读消息${index + 1}',
          );
        });

        // 使用UnreadJumpStrategy分析
        final decision =
            UnreadJumpStrategy.analyzeUnreadMessages(unreadMessages);

        // 断言：应该跳转到最新消息
        expect(decision.strategy, equals(UnreadJumpStrategy.jumpToLatest));
        expect(decision.reason, contains('有50条未读消息，显示到最新消息'));
        expect(decision.targetMessageId, equals('unread_50'));
        expect(decision.hasUnreadMessages, isTrue);
        expect(decision.totalUnreadCount, equals(50));

        print('✅ 场景3c测试通过：大量未读消息显示到最新消息(${decision.targetMessageId})');
      });
    });

    group('UI滚动位置验证', () {
      testWidgets('验证滚动位置计算逻辑', (WidgetTester tester) async {
        // 安排：创建ChatState来测试滚动位置
        final testUser = createTestUser();
        final testConversation = createTestConversation('test_conv_1');

        final baseTime = DateTime.now();
        final messages = List.generate(10, (index) {
          return createTestMessage(
            'msg_${index + 1}',
            baseTime.add(Duration(minutes: index)),
            '消息${index + 1}',
          );
        });

        // 按时间降序排列（最新消息在前）
        messages.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        // 创建初始状态
        final initialState = ChatState.initial(testUser).copyWith(
          conversation: testConversation,
          messages: messages,
        );

        // 验证最新消息在列表第一位（因为按时间降序排列）
        expect(initialState.messages.first.messageId, equals('msg_10'));
        expect(initialState.messages.last.messageId, equals('msg_1'));

        // 测试滚动位置设置
        final latestMessage = initialState.messages.first;
        final scrollPosition = CurrentScrollPosition.fromAnchor(
          messageId: latestMessage.messageId,
          messageIndex: 0, // 最新消息总是在索引0
          relativePosition: 0.0, // 在UI底部第一条显示
        );

        // 更新状态
        final updatedState = initialState.copyWith(
          currentScrollPosition: scrollPosition,
        );

        // 断言：滚动位置设置正确
        expect(updatedState.currentScrollPosition.messageId, equals('msg_10'));
        expect(updatedState.currentScrollPosition.messageIndex, equals(0));
        expect(
            updatedState.currentScrollPosition.relativePosition, equals(0.0));

        print('✅ UI滚动位置验证通过：最新消息(${latestMessage.messageId})在底部第一条');
      });
    });

    group('用户友好的描述验证', () {
      test('各种场景的描述应该正确', () {
        // 场景1：无未读消息
        final decision1 = UnreadJumpStrategy.analyzeUnreadMessages([]);
        final context1 = UnreadJumpStrategy.calculateJumpContext([], decision1);
        final description1 =
            UnreadJumpStrategy.getJumpDescription(decision1, context1);
        expect(description1, equals('显示最新对话'));

        // 场景2：单条未读消息
        final unreadMessage = createTestMessage('msg1', DateTime.now(), '测试');
        final decision2 =
            UnreadJumpStrategy.analyzeUnreadMessages([unreadMessage]);
        final context2 =
            UnreadJumpStrategy.calculateJumpContext([unreadMessage], decision2);
        final description2 =
            UnreadJumpStrategy.getJumpDescription(decision2, context2);
        expect(description2, equals('显示最新消息（1条未读）'));

        // 场景3：多条未读消息
        final unreadMessages = List.generate(5, (index) {
          return createTestMessage('msg${index + 1}', DateTime.now(), '测试');
        });
        final decision3 =
            UnreadJumpStrategy.analyzeUnreadMessages(unreadMessages);
        final context3 =
            UnreadJumpStrategy.calculateJumpContext(unreadMessages, decision3);
        final description3 =
            UnreadJumpStrategy.getJumpDescription(decision3, context3);
        expect(description3, equals('显示最新消息（5条未读）'));

        print('✅ 用户友好描述验证通过');
      });
    });
  });
}
