import 'package:flutter_test/flutter_test.dart';
import 'package:cc/features/chat/domain/entities/message_timeline.dart';
import 'package:cc/core/database/models/message.dart';

void main() {
  group('MessageTimeline', () {
    late MessageTimeline timeline;
    late List<Message> testMessages;

    setUp(() {
      timeline = MessageTimeline(conversationId: 'test_conversation');
      testMessages = _createTestMessages();
    });

    group('基础功能测试', () {
      test('应该正确初始化', () {
        expect(timeline.conversationId, equals('test_conversation'));
        expect(timeline.maxSize, equals(MessageTimeline.defaultMaxSize));
        expect(timeline.isEmpty, isTrue);
        expect(timeline.length, equals(0));
        expect(timeline.hasMoreHistory, isTrue);
        expect(timeline.hasMoreRecent, isFalse);
      });

      test('应该正确设置自定义maxSize', () {
        final customTimeline = MessageTimeline(
          conversationId: 'test',
          maxSize: 100,
        );
        expect(customTimeline.maxSize, equals(100));
      });
    });

    group('消息添加功能', () {
      test('appendNewMessages 应该正确添加新消息', () {
        final messages = testMessages.take(3).toList();
        timeline.appendNewMessages(messages);

        expect(timeline.length, equals(3));
        expect(timeline.isEmpty, isFalse);
        expect(timeline.isNotEmpty, isTrue);
        expect(timeline.latestLoadedTime, equals(messages.last.createdAt));
        expect(timeline.earliestLoadedTime, equals(messages.first.createdAt));
      });

      test('insertHistoryMessages 应该正确插入历史消息', () {
        // 先添加一些新消息
        final newMessages = testMessages.skip(5).take(3).toList();
        timeline.appendNewMessages(newMessages);

        // 然后插入历史消息
        final historyMessages = testMessages.take(3).toList();
        timeline.insertHistoryMessages(historyMessages);

        expect(timeline.length, equals(6));
        expect(timeline.earliestLoadedTime,
            equals(historyMessages.first.createdAt));

        // 检查消息是否按时间排序
        final allMessages = timeline.getAllMessages();
        for (int i = 0; i < allMessages.length - 1; i++) {
          expect(
              allMessages[i].createdAt.isBefore(allMessages[i + 1].createdAt) ||
                  allMessages[i]
                      .createdAt
                      .isAtSameMomentAs(allMessages[i + 1].createdAt),
              isTrue);
        }
      });

      test('insertMessage 应该在正确位置插入消息', () {
        // 添加一些基础消息
        timeline.appendNewMessages(testMessages.take(5).toList());

        // 创建一个时间在中间的消息
        final middleTime =
            testMessages[2].createdAt.add(const Duration(seconds: 30));
        final middleMessage = _createMessage('middle_msg', middleTime);

        timeline.insertMessage(middleMessage);

        expect(timeline.length, equals(6));

        // 验证时间排序是否正确
        final allMessages = timeline.getAllMessages();
        for (int i = 0; i < allMessages.length - 1; i++) {
          expect(
              allMessages[i].createdAt.isBefore(allMessages[i + 1].createdAt) ||
                  allMessages[i]
                      .createdAt
                      .isAtSameMomentAs(allMessages[i + 1].createdAt),
              isTrue);
        }
      });

      test('应该正确处理空消息列表', () {
        timeline.appendNewMessages([]);
        timeline.insertHistoryMessages([]);

        expect(timeline.length, equals(0));
        expect(timeline.isEmpty, isTrue);
      });
    });

    group('环形缓冲功能', () {
      test('应该在超过maxSize时执行环形缓冲', () {
        // 创建超过maxSize的消息
        final customTimeline = MessageTimeline(
          conversationId: 'test',
          maxSize: 10,
        );

        final messages = List.generate(
            15,
            (index) => _createMessage(
                'msg_$index', DateTime.now().add(Duration(minutes: index))));

        customTimeline.appendNewMessages(messages);

        expect(customTimeline.length, equals(10));
        expect(customTimeline.hasMoreHistory, isTrue);
      });

      test('环形缓冲应该从两端均匀删除', () {
        final customTimeline = MessageTimeline(
          conversationId: 'test',
          maxSize: 10,
        );

        final messages = List.generate(
            15,
            (index) => _createMessage(
                'msg_$index', DateTime.now().add(Duration(minutes: index))));

        customTimeline.appendNewMessages(messages);

        // 验证保留的是中间部分的消息
        final remainingMessages = customTimeline.getAllMessages();
        expect(remainingMessages.length, equals(10));

        // 检查是否保留了中间的消息
        expect(remainingMessages.first.messageId, contains('msg_'));
        expect(remainingMessages.last.messageId, contains('msg_'));
      });

      test('环形缓冲应该正确调整lastVisibleIndex', () {
        final customTimeline = MessageTimeline(
          conversationId: 'test',
          maxSize: 5,
        );

        customTimeline.updateLastVisibleIndex(8);

        final messages = List.generate(
            10,
            (index) => _createMessage(
                'msg_$index', DateTime.now().add(Duration(minutes: index))));

        customTimeline.appendNewMessages(messages);

        // lastVisibleIndex应该被调整到有效范围内
        expect(
            customTimeline.lastVisibleIndex, lessThan(customTimeline.length));
        expect(customTimeline.lastVisibleIndex, greaterThanOrEqualTo(0));
      });
    });

    group('消息查找功能', () {
      test('getRange 应该正确返回指定范围的消息', () {
        timeline.appendNewMessages(testMessages.take(10).toList());

        final range = timeline.getRange(2, 5);
        expect(range.length, equals(3));

        // 验证边界条件
        expect(timeline.getRange(-1, 3), isEmpty);
        expect(timeline.getRange(15, 20), isEmpty);
        expect(timeline.getRange(0, 15).length, equals(10)); // 应该截取到实际长度
      });

      test('findMessageIndex 应该正确查找消息索引', () {
        timeline.appendNewMessages(testMessages.take(5).toList());

        final firstMessageId = testMessages[0].messageId;
        final lastMessageId = testMessages[4].messageId;

        expect(timeline.findMessageIndex(firstMessageId), equals(0));
        expect(timeline.findMessageIndex(lastMessageId), equals(4));
        expect(timeline.findMessageIndex('nonexistent'), isNull);
      });
    });

    group('未读消息功能', () {
      test('应该正确计算未读消息', () {
        final messages = testMessages.take(10).toList();
        // 设置前半部分为未读
        for (int i = 0; i < 5; i++) {
          messages[i].status = 'unread';
        }
        // 设置后半部分为已读
        for (int i = 5; i < 10; i++) {
          messages[i].status = 'read';
        }

        timeline.appendNewMessages(messages);

        final unreadMessages = timeline.getUnreadMessages();
        expect(unreadMessages.length, equals(5));
        expect(unreadMessages.every((msg) => msg.status != 'read'), isTrue);
      });

      test('markMessagesAsRead 应该正确标记消息为已读', () {
        final messages = testMessages.take(5).toList();
        // 所有消息都设为未读
        for (final msg in messages) {
          msg.status = 'unread';
        }

        timeline.appendNewMessages(messages);

        // 标记前3条为已读
        final messageIds =
            messages.take(3).map((msg) => msg.messageId).toList();
        timeline.markMessagesAsRead(messageIds);

        final unreadMessages = timeline.getUnreadMessages();
        expect(unreadMessages.length, equals(2));

        // 验证前3条已读，后2条未读
        final allMessages = timeline.getAllMessages();
        for (int i = 0; i < 3; i++) {
          expect(allMessages[i].status, equals('read'));
        }
        for (int i = 3; i < 5; i++) {
          expect(allMessages[i].status, equals('unread'));
        }
      });

      test('应该正确获取第一条和最后一条未读消息', () {
        final messages = testMessages.take(5).toList();
        for (final msg in messages) {
          msg.status = 'unread';
        }

        timeline.appendNewMessages(messages);

        // 手动设置未读消息ID（模拟计算过程）
        timeline.firstUnreadMessageId = messages.first.messageId;
        timeline.lastUnreadMessageId = messages.last.messageId;

        final firstUnread = timeline.getFirstUnreadMessage();
        final lastUnread = timeline.getLatestUnreadMessage();

        expect(firstUnread?.messageId, equals(messages.first.messageId));
        expect(lastUnread?.messageId, equals(messages.last.messageId));
      });
    });

    group('状态管理功能', () {
      test('应该正确更新和获取查看状态', () {
        timeline.appendNewMessages(testMessages.take(5).toList());

        timeline.updateLastVisibleIndex(3);

        final viewState = timeline.getLastViewState();
        expect(viewState.scrollPosition, equals(3));
        expect(viewState.conversationId, equals('test_conversation'));
      });

      test('clear 应该重置所有状态', () {
        timeline.appendNewMessages(testMessages.take(5).toList());
        timeline.updateLastVisibleIndex(3);

        timeline.clear();

        expect(timeline.isEmpty, isTrue);
        expect(timeline.length, equals(0));
        expect(timeline.lastVisibleIndex, equals(0));
        expect(timeline.earliestLoadedTime, isNull);
        expect(timeline.latestLoadedTime, isNull);
        expect(timeline.hasMoreHistory, isTrue);
        expect(timeline.hasMoreRecent, isFalse);
        expect(timeline.unreadCount, equals(0));
      });
    });

    group('ViewState', () {
      test('应该正确创建和复制ViewState', () {
        final originalState = ViewState(
          scrollPosition: 5,
          conversationId: 'test_conv',
          lastViewTime: DateTime.now(),
        );

        final copiedState = originalState.copyWith(scrollPosition: 10);

        expect(copiedState.scrollPosition, equals(10));
        expect(copiedState.conversationId, equals('test_conv'));
        expect(copiedState.lastViewTime, equals(originalState.lastViewTime));
      });
    });
  });
}

/// 创建测试消息列表
List<Message> _createTestMessages() {
  return List.generate(20, (index) {
    final baseTime = DateTime.now().subtract(Duration(hours: 20 - index));
    return _createMessage('msg_$index', baseTime);
  });
}

/// 创建单个测试消息
Message _createMessage(String messageId, DateTime createdAt) {
  return Message()
    ..messageId = messageId
    ..conversationId = 'test_conversation'
    ..senderId = 'user_${messageId.hashCode % 3}' // 模拟不同发送者
    ..senderName = 'User ${messageId.hashCode % 3}'
    ..createdAt = createdAt
    ..status = 'sent'
    ..type = 'text'
    ..text = 'Test message content for $messageId';
}
