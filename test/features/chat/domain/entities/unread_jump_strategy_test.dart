import 'package:flutter_test/flutter_test.dart';
import 'package:cc/features/chat/domain/entities/unread_jump_strategy.dart';
import 'package:cc/core/database/models/message.dart';

void main() {
  group('UnreadJumpStrategy Tests', () {
    late DateTime baseTime;

    setUp(() {
      baseTime = DateTime(2024, 1, 1, 12, 0, 0);
    });

    List<Message> createTestMessages(
      int count, {
      DateTime? startTime,
      Duration? interval,
    }) {
      startTime ??= baseTime;
      interval ??= const Duration(minutes: 10);

      return List.generate(count, (index) {
        final message = Message()
          ..messageId = 'msg_$index'
          ..conversationId = 'test_conversation'
          ..senderId = 'sender_$index'
          ..createdAt = startTime!.add(interval! * index)
          ..text = 'Test message $index'
          ..isRead = false;
        return message;
      });
    }

    group('少量未读消息策略 (≤5条)', () {
      testWidgets('1条未读消息应该跳转到第一条', (WidgetTester tester) async {
        final messages = createTestMessages(1);

        final decision = UnreadJumpStrategy.analyzeUnreadMessages(
          messages,
          currentTime: baseTime.add(const Duration(hours: 1)),
        );

        expect(decision.strategy, UnreadJumpStrategy.jumpToFirst);
        expect(decision.confidence, 0.9);
        expect(decision.targetMessageId, 'msg_0');
        expect(decision.reason, contains('未读消息较少(1条)'));
      });

      testWidgets('5条未读消息应该跳转到第一条', (WidgetTester tester) async {
        final messages = createTestMessages(5);

        final decision = UnreadJumpStrategy.analyzeUnreadMessages(
          messages,
          currentTime: baseTime.add(const Duration(hours: 1)),
        );

        expect(decision.strategy, UnreadJumpStrategy.jumpToFirst);
        expect(decision.confidence, 0.9);
        expect(decision.targetMessageId, 'msg_0');
        expect(decision.reason, contains('未读消息较少(5条)'));
      });
    });

    group('中等数量未读消息策略 (6-20条)', () {
      testWidgets('10条未读消息，短时间跨度应该跳转到第一条', (WidgetTester tester) async {
        final messages =
            createTestMessages(10, interval: const Duration(minutes: 5));

        final decision = UnreadJumpStrategy.analyzeUnreadMessages(
          messages,
          currentTime: baseTime.add(const Duration(hours: 1)),
        );

        expect(decision.strategy, UnreadJumpStrategy.jumpToFirst);
        expect(decision.confidence, 0.85);
        expect(decision.targetMessageId, 'msg_0');
        expect(decision.reason, contains('时间跨度较短'));
      });

      testWidgets('15条未读消息，中等时间跨度应该提供二次选择', (WidgetTester tester) async {
        final messages =
            createTestMessages(15, interval: const Duration(hours: 1));

        final decision = UnreadJumpStrategy.analyzeUnreadMessages(
          messages,
          currentTime: baseTime.add(const Duration(hours: 20)),
        );

        expect(decision.strategy, UnreadJumpStrategy.showSecondaryOption);
        expect(decision.confidence, 0.8);
        expect(decision.targetMessageId, 'msg_0');
        expect(decision.secondaryTargetId, 'msg_14');
        expect(decision.reason, contains('提供选择'));
      });

      testWidgets('12条未读消息，长时间跨度应该跳转到最新', (WidgetTester tester) async {
        final messages =
            createTestMessages(12, interval: const Duration(hours: 6));

        final decision = UnreadJumpStrategy.analyzeUnreadMessages(
          messages,
          currentTime: baseTime.add(const Duration(days: 5)),
        );

        expect(decision.strategy, UnreadJumpStrategy.jumpToLatest);
        expect(decision.confidence, 0.75);
        expect(decision.targetMessageId, 'msg_11');
        expect(decision.reason, contains('时间跨度较长'));
      });
    });

    group('大量未读消息策略 (21-50条)', () {
      testWidgets('30条未读消息，最新消息很新应该提供二次选择', (WidgetTester tester) async {
        final messages =
            createTestMessages(30, interval: const Duration(minutes: 30));

        final decision = UnreadJumpStrategy.analyzeUnreadMessages(
          messages,
          currentTime: baseTime.add(const Duration(minutes: 45)), // 最新消息15分钟前
        );

        expect(decision.strategy, UnreadJumpStrategy.showSecondaryOption);
        expect(decision.confidence, 0.9);
        expect(decision.targetMessageId, 'msg_29'); // 跳转到最新
        expect(decision.secondaryTargetId, 'msg_0'); // 二次选择第一条
        expect(decision.reason, contains('有新消息'));
      });

      testWidgets('25条未读消息，最新消息较旧应该跳转到最新', (WidgetTester tester) async {
        final messages =
            createTestMessages(25, interval: const Duration(hours: 1));

        final decision = UnreadJumpStrategy.analyzeUnreadMessages(
          messages,
          currentTime: baseTime.add(const Duration(hours: 30)),
        );

        expect(decision.strategy, UnreadJumpStrategy.jumpToLatest);
        expect(decision.confidence, 0.85);
        expect(decision.targetMessageId, 'msg_24');
        expect(decision.reason, contains('未读消息较多(25条)'));
      });
    });

    group('超大量未读消息策略 (>50条)', () {
      testWidgets('100条未读消息应该总是跳转到最新', (WidgetTester tester) async {
        final messages = createTestMessages(100);

        final decision = UnreadJumpStrategy.analyzeUnreadMessages(
          messages,
          currentTime: baseTime.add(const Duration(hours: 1)),
        );

        expect(decision.strategy, UnreadJumpStrategy.jumpToLatest);
        expect(decision.confidence, 0.95);
        expect(decision.targetMessageId, 'msg_99');
        expect(decision.reason, contains('未读消息过多(100条)'));
      });
    });

    group('边界情况', () {
      testWidgets('空未读消息列表应该跳转到最新', (WidgetTester tester) async {
        final decision = UnreadJumpStrategy.analyzeUnreadMessages(
          [],
          currentTime: baseTime,
        );

        expect(decision.strategy, UnreadJumpStrategy.jumpToLatest);
        expect(decision.confidence, 1.0);
        expect(decision.reason, '无未读消息');
      });

      testWidgets('6条消息边界测试', (WidgetTester tester) async {
        final messages = createTestMessages(6);

        final decision = UnreadJumpStrategy.analyzeUnreadMessages(
          messages,
          currentTime: baseTime.add(const Duration(hours: 1)),
        );

        // 6条消息应该进入中等数量策略，短时间跨度跳转到第一条
        expect(decision.strategy, UnreadJumpStrategy.jumpToFirst);
        expect(decision.targetMessageId, 'msg_0');
      });

      testWidgets('21条消息边界测试', (WidgetTester tester) async {
        final messages = createTestMessages(21);

        final decision = UnreadJumpStrategy.analyzeUnreadMessages(
          messages,
          currentTime: baseTime.add(const Duration(hours: 2)),
        );

        // 21条消息应该进入大量消息策略，但由于最新消息很新(2小时内)，会提供二次选择
        expect(decision.strategy, UnreadJumpStrategy.showSecondaryOption);
        expect(decision.targetMessageId, 'msg_20'); // 跳转到最新
        expect(decision.secondaryTargetId, 'msg_0'); // 二次选择第一条
      });
    });

    group('JumpContext计算', () {
      testWidgets('应该正确计算跳转到第一条的上下文', (WidgetTester tester) async {
        final messages = createTestMessages(10);
        const decision = JumpDecision(
          strategy: UnreadJumpStrategy.jumpToFirst,
          reason: 'test',
          confidence: 0.9,
          targetMessageId: 'msg_0',
        );

        final context =
            UnreadJumpStrategy.calculateJumpContext(messages, decision);

        expect(context.totalUnreadCount, 10);
        expect(context.jumpedToIndex, 0);
        expect(context.remainingUnreadCount, 9);
        expect(context.firstUnreadMessageId, 'msg_0');
        expect(context.lastUnreadMessageId, 'msg_9');
      });

      testWidgets('应该正确计算跳转到最新的上下文', (WidgetTester tester) async {
        final messages = createTestMessages(5);
        const decision = JumpDecision(
          strategy: UnreadJumpStrategy.jumpToLatest,
          reason: 'test',
          confidence: 0.9,
          targetMessageId: 'msg_4',
        );

        final context =
            UnreadJumpStrategy.calculateJumpContext(messages, decision);

        expect(context.totalUnreadCount, 5);
        expect(context.jumpedToIndex, 4);
        expect(context.remainingUnreadCount, 0);
        expect(context.firstUnreadMessageId, 'msg_0');
        expect(context.lastUnreadMessageId, 'msg_4');
      });

      testWidgets('应该正确计算空消息列表的上下文', (WidgetTester tester) async {
        const decision = JumpDecision(
          strategy: UnreadJumpStrategy.jumpToLatest,
          reason: 'test',
          confidence: 1.0,
        );

        final context = UnreadJumpStrategy.calculateJumpContext([], decision);

        expect(context.totalUnreadCount, 0);
        expect(context.jumpedToIndex, 0);
        expect(context.remainingUnreadCount, 0);
      });
    });

    group('跳转描述', () {
      testWidgets('应该生成正确的跳转到第一条描述', (WidgetTester tester) async {
        const decision = JumpDecision(
          strategy: UnreadJumpStrategy.jumpToFirst,
          reason: 'test',
          confidence: 0.9,
        );
        const context = JumpContext(
          totalUnreadCount: 5,
          jumpedToIndex: 0,
          remainingUnreadCount: 4,
        );

        final description =
            UnreadJumpStrategy.getJumpDescription(decision, context);

        expect(description, '跳转到第一条未读消息，还有4条未读');
      });

      testWidgets('应该生成正确的跳转到最新描述', (WidgetTester tester) async {
        const decision = JumpDecision(
          strategy: UnreadJumpStrategy.jumpToLatest,
          reason: 'test',
          confidence: 0.9,
        );
        const context = JumpContext(
          totalUnreadCount: 10,
          jumpedToIndex: 9,
          remainingUnreadCount: 0,
        );

        final description =
            UnreadJumpStrategy.getJumpDescription(decision, context);

        expect(description, '跳转到最新消息，共10条未读');
      });

      testWidgets('应该生成正确的二次选择描述', (WidgetTester tester) async {
        const decision = JumpDecision(
          strategy: UnreadJumpStrategy.showSecondaryOption,
          reason: 'test',
          confidence: 0.8,
        );
        const context = JumpContext(
          totalUnreadCount: 15,
          jumpedToIndex: 0,
          remainingUnreadCount: 14,
        );

        final description =
            UnreadJumpStrategy.getJumpDescription(decision, context);

        expect(description, '有15条未读消息，可选择跳转位置');
      });

      testWidgets('应该处理唯一未读消息的描述', (WidgetTester tester) async {
        const decision = JumpDecision(
          strategy: UnreadJumpStrategy.jumpToFirst,
          reason: 'test',
          confidence: 0.9,
        );
        const context = JumpContext(
          totalUnreadCount: 1,
          jumpedToIndex: 0,
          remainingUnreadCount: 0,
        );

        final description =
            UnreadJumpStrategy.getJumpDescription(decision, context);

        expect(description, '跳转到唯一的未读消息');
      });
    });

    group('时间阈值测试', () {
      testWidgets('应该正确识别短时间跨度', (WidgetTester tester) async {
        final messages =
            createTestMessages(10, interval: const Duration(minutes: 5));

        final decision = UnreadJumpStrategy.analyzeUnreadMessages(
          messages,
          currentTime: baseTime.add(const Duration(minutes: 90)), // 1.5小时后
        );

        expect(decision.strategy, UnreadJumpStrategy.jumpToFirst);
        expect(decision.reason, contains('时间跨度较短'));
      });

      testWidgets('应该正确识别中等时间跨度', (WidgetTester tester) async {
        final messages =
            createTestMessages(15, interval: const Duration(hours: 1));

        final decision = UnreadJumpStrategy.analyzeUnreadMessages(
          messages,
          currentTime: baseTime.add(const Duration(hours: 20)), // 20小时后
        );

        expect(decision.strategy, UnreadJumpStrategy.showSecondaryOption);
        expect(decision.reason, contains('时间跨度中等'));
      });

      testWidgets('应该正确识别长时间跨度', (WidgetTester tester) async {
        final messages =
            createTestMessages(12, interval: const Duration(hours: 12));

        final decision = UnreadJumpStrategy.analyzeUnreadMessages(
          messages,
          currentTime: baseTime.add(const Duration(days: 10)), // 10天后
        );

        expect(decision.strategy, UnreadJumpStrategy.jumpToLatest);
        expect(decision.reason, contains('时间跨度较长'));
      });
    });
  });
}
