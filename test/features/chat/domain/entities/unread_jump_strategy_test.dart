import 'package:flutter_test/flutter_test.dart';
import 'package:cc/core/database/models/message.dart';
import 'package:cc/features/chat/domain/entities/unread_jump_strategy.dart';

void main() {
  group('UnreadJumpStrategy 修正后的业务逻辑测试', () {
    // 测试用的消息创建工具
    Message createTestMessage(String id, DateTime time, {bool isRead = false}) {
      final message = Message()
        ..messageId = id
        ..text = '测试消息 $id'
        ..senderId = 'user123'
        ..createdAt = time
        ..type = MessageType.text;
      return message;
    }

    group('场景1: 有新消息+无未读', () {
      test('应该显示到最新消息', () {
        // 安排：无未读消息，但有最新消息
        final latestMessage = createTestMessage(
          'msg_latest',
          DateTime.now(),
        );

        // 行动：分析未读消息策略
        final decision = UnreadJumpStrategy.analyzeUnreadMessages(
          [], // 无未读消息
          latestMessage: latestMessage,
        );

        // 断言：应该跳转到最新消息
        expect(decision.strategy, equals(UnreadJumpStrategy.jumpToLatest));
        expect(decision.reason, contains('有新消息但无未读'));
        expect(decision.targetMessageId, equals('msg_latest'));
        expect(decision.totalUnreadCount, equals(0));
        expect(decision.hasUnreadMessages, isFalse);
        expect(decision.confidence, equals(1.0));
      });
    });

    group('场景2: 有未读消息', () {
      test('单条未读消息 - 应该显示到最新消息', () {
        // 安排：1条未读消息
        final unreadMessage = createTestMessage(
          'msg_unread_1',
          DateTime.now(),
        );

        // 行动：分析未读消息策略
        final decision = UnreadJumpStrategy.analyzeUnreadMessages(
          [unreadMessage],
        );

        // 断言：应该跳转到最新消息（最新的未读消息）
        expect(decision.strategy, equals(UnreadJumpStrategy.jumpToLatest));
        expect(decision.reason, contains('有1条未读消息，显示到最新消息'));
        expect(decision.targetMessageId, equals('msg_unread_1'));
        expect(decision.totalUnreadCount, equals(1));
        expect(decision.hasUnreadMessages, isTrue);
        expect(decision.confidence, equals(1.0));
      });

      test('多条未读消息 - 应该显示到最新消息（最新的未读消息）', () {
        // 安排：5条未读消息
        final baseTime = DateTime.now().subtract(const Duration(hours: 2));
        final unreadMessages = List.generate(5, (index) {
          return createTestMessage(
            'msg_unread_${index + 1}',
            baseTime.add(Duration(minutes: index * 10)),
          );
        });

        // 行动：分析未读消息策略
        final decision = UnreadJumpStrategy.analyzeUnreadMessages(
          unreadMessages,
        );

        // 断言：应该跳转到最新消息（最后一条未读消息）
        expect(decision.strategy, equals(UnreadJumpStrategy.jumpToLatest));
        expect(decision.reason, contains('有5条未读消息，显示到最新消息'));
        expect(decision.targetMessageId, equals('msg_unread_5')); // 最新的未读消息
        expect(decision.totalUnreadCount, equals(5));
        expect(decision.hasUnreadMessages, isTrue);
        expect(decision.confidence, equals(1.0));
      });

      test('大量未读消息 - 应该显示到最新消息', () {
        // 安排：100条未读消息
        final baseTime = DateTime.now().subtract(const Duration(days: 3));
        final unreadMessages = List.generate(100, (index) {
          return createTestMessage(
            'msg_unread_${index + 1}',
            baseTime.add(Duration(minutes: index * 5)),
          );
        });

        // 行动：分析未读消息策略
        final decision = UnreadJumpStrategy.analyzeUnreadMessages(
          unreadMessages,
        );

        // 断言：应该跳转到最新消息
        expect(decision.strategy, equals(UnreadJumpStrategy.jumpToLatest));
        expect(decision.reason, contains('有100条未读消息，显示到最新消息'));
        expect(decision.targetMessageId, equals('msg_unread_100'));
        expect(decision.totalUnreadCount, equals(100));
        expect(decision.hasUnreadMessages, isTrue);
        expect(decision.confidence, equals(1.0));
      });
    });

    group('跳转上下文计算', () {
      test('无未读消息的上下文', () {
        // 安排
        final decision = UnreadJumpStrategy.analyzeUnreadMessages([]);

        // 行动：计算跳转上下文
        final context = UnreadJumpStrategy.calculateJumpContext([], decision);

        // 断言
        expect(context.totalUnreadCount, equals(0));
        expect(context.jumpedToIndex, equals(0));
        expect(context.remainingUnreadCount, equals(0));
        expect(context.firstUnreadMessageId, isNull);
        expect(context.lastUnreadMessageId, isNull);
        expect(context.timeSpan, isNull);
      });

      test('多条未读消息的上下文', () {
        // 安排：3条未读消息
        final baseTime = DateTime.now();
        final unreadMessages = [
          createTestMessage(
              'msg_1', baseTime.subtract(const Duration(hours: 2))),
          createTestMessage(
              'msg_2', baseTime.subtract(const Duration(hours: 1))),
          createTestMessage('msg_3', baseTime), // 最新的
        ];

        final decision =
            UnreadJumpStrategy.analyzeUnreadMessages(unreadMessages);

        // 行动：计算跳转上下文
        final context =
            UnreadJumpStrategy.calculateJumpContext(unreadMessages, decision);

        // 断言：跳转到最新消息（索引2）
        expect(context.totalUnreadCount, equals(3));
        expect(context.jumpedToIndex, equals(2)); // 最新消息的索引
        expect(context.remainingUnreadCount, equals(0)); // 跳转到最新后无剩余
        expect(context.firstUnreadMessageId, equals('msg_1'));
        expect(context.lastUnreadMessageId, equals('msg_3'));
        expect(context.timeSpan, equals(const Duration(hours: 2)));
      });
    });

    group('用户友好的描述', () {
      test('无未读消息的描述', () {
        // 安排
        final decision = UnreadJumpStrategy.analyzeUnreadMessages([]);
        final context = UnreadJumpStrategy.calculateJumpContext([], decision);

        // 行动：获取描述
        final description =
            UnreadJumpStrategy.getJumpDescription(decision, context);

        // 断言
        expect(description, equals('显示最新对话'));
      });

      test('单条未读消息的描述', () {
        // 安排
        final unreadMessage = createTestMessage('msg_1', DateTime.now());
        final decision =
            UnreadJumpStrategy.analyzeUnreadMessages([unreadMessage]);
        final context =
            UnreadJumpStrategy.calculateJumpContext([unreadMessage], decision);

        // 行动：获取描述
        final description =
            UnreadJumpStrategy.getJumpDescription(decision, context);

        // 断言
        expect(description, equals('显示最新消息（1条未读）'));
      });

      test('多条未读消息的描述', () {
        // 安排
        final unreadMessages = List.generate(5, (index) {
          return createTestMessage('msg_${index + 1}', DateTime.now());
        });
        final decision =
            UnreadJumpStrategy.analyzeUnreadMessages(unreadMessages);
        final context =
            UnreadJumpStrategy.calculateJumpContext(unreadMessages, decision);

        // 行动：获取描述
        final description =
            UnreadJumpStrategy.getJumpDescription(decision, context);

        // 断言
        expect(description, equals('显示最新消息（5条未读）'));
      });
    });

    group('边界情况', () {
      test('空消息列表应该正常处理', () {
        // 行动
        final decision = UnreadJumpStrategy.analyzeUnreadMessages([]);

        // 断言
        expect(decision.strategy, equals(UnreadJumpStrategy.jumpToLatest));
        expect(decision.totalUnreadCount, equals(0));
        expect(decision.hasUnreadMessages, isFalse);
      });

      test('时间跨度计算应该正确', () {
        // 安排：时间跨度2小时的未读消息
        final baseTime = DateTime.now();
        final unreadMessages = [
          createTestMessage(
              'msg_1', baseTime.subtract(const Duration(hours: 2))),
          createTestMessage('msg_2', baseTime),
        ];

        final decision =
            UnreadJumpStrategy.analyzeUnreadMessages(unreadMessages);
        final context =
            UnreadJumpStrategy.calculateJumpContext(unreadMessages, decision);

        // 断言：时间跨度应该是2小时
        expect(context.timeSpan, equals(const Duration(hours: 2)));
      });
    });
  });
}
