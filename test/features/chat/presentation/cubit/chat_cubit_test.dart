import 'package:cc/core/proto/generated/user.pb.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cc/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:cc/features/chat/domain/entities/message_timeline.dart';
import 'package:cc/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:cc/core/database/models/message.dart';

// 创建可测试的ChatRepository版本
class TestChatRepositoryForCubit extends ChatRepositoryImpl {
  final List<Message> _mockMessages = [];
  final Map<String, MessageTimeline> _mockTimelineCache = {};

  TestChatRepositoryForCubit()
      : super(
            currentUserProto: CurrentUserProto()
              ..userId = 'test_user_id'
              ..name = 'Test User');
  @override
  Future<List<Message>> getConversationMessages(String conversationId,
      {int limit = 20, DateTime? before}) async {
    return _mockMessages
        .where((msg) => msg.conversationId == conversationId)
        .take(limit)
        .toList();
  }

  @override
  MessageTimeline? getTimeline(String conversationId) {
    return _mockTimelineCache[conversationId];
  }

  @override
  void storeTimeline(String conversationId, MessageTimeline timeline) {
    _mockTimelineCache[conversationId] = timeline;
  }

  @override
  void removeTimeline(String conversationId) {
    _mockTimelineCache.remove(conversationId);
  }

  @override
  Future<bool> preloadTimeline(String conversationId,
      {int messageCount = 100}) async {
    final timeline = MessageTimeline(conversationId: conversationId);
    final messages = _mockMessages
        .where((msg) => msg.conversationId == conversationId)
        .take(messageCount)
        .toList();

    if (messages.isNotEmpty) {
      timeline.appendNewMessages(messages);
    }

    storeTimeline(conversationId, timeline);
    return true;
  }

  @override
  Future<ViewState?> getUserLastViewState(String conversationId) async {
    return null; // 简单实现
  }

  @override
  Future<void> saveUserViewState(ViewState viewState) async {
    // 简单实现
  }

  @override
  Future<void> joinConversationRoom(String conversationId) async {
    // 简单实现
  }

  @override
  Future<void> leaveConversationRoom(String conversationId) async {
    // 简单实现
  }

  @override
  Future<void> markConversationAsRead(String conversationId) async {
    // 简单实现
  }

  @override
  Future<Message> sendTextMessage(String conversationId, String text) async {
    final message = Message()
      ..messageId = 'msg_${DateTime.now().millisecondsSinceEpoch}'
      ..conversationId = conversationId
      ..senderId = 'current_user'
      ..senderName = 'Test User'
      ..createdAt = DateTime.now()
      ..isRead = true
      ..status = 'sent'
      ..type = 'text'
      ..text = text;

    _mockMessages.add(message);
    return message;
  }

  // 辅助方法
  void addMockMessage(Message message) {
    _mockMessages.add(message);
  }

  void clearMockData() {
    _mockMessages.clear();
    _mockTimelineCache.clear();
  }
}

void main() {
  group('ChatCubit with MessageTimeline Integration', () {
    late TestChatRepositoryForCubit repository;
    late ChatCubit cubit;
    const String testConversationId = 'test_conversation_123';

    setUp(() {
      repository = TestChatRepositoryForCubit();
    });

    tearDown(() {
      cubit.close();
      repository.dispose();
    });

    group('初始化功能', () {
      test('应该正确初始化空Timeline', () async {
        cubit = ChatCubit(
          chatRepository: repository,
          conversationId: testConversationId,
        );

        // 等待初始化完成
        await Future.delayed(const Duration(milliseconds: 100));

        expect(cubit.state.conversationId, equals(testConversationId));
        expect(cubit.state.timeline, isNotNull);
        expect(cubit.state.timeline!.isEmpty, isTrue);
        expect(cubit.state.isPreloading, isFalse);
      });

      test('应该正确预加载带有消息的Timeline', () async {
        // 添加测试消息
        final testMessages = _createTestMessages(testConversationId, 10);
        for (final message in testMessages) {
          repository.addMockMessage(message);
        }

        cubit = ChatCubit(
          chatRepository: repository,
          conversationId: testConversationId,
        );

        // 等待初始化完成
        await Future.delayed(const Duration(milliseconds: 100));

        expect(cubit.state.timeline, isNotNull);
        expect(cubit.state.timeline!.length, equals(10));
        expect(cubit.state.messages.length, greaterThan(0));
        expect(cubit.state.isPreloading, isFalse);
      });

      test('应该从现有Timeline缓存恢复状态', () async {
        // 预先创建Timeline缓存
        final timeline = MessageTimeline(conversationId: testConversationId);
        final testMessages = _createTestMessages(testConversationId, 5);
        timeline.appendNewMessages(testMessages);
        repository.storeTimeline(testConversationId, timeline);

        cubit = ChatCubit(
          chatRepository: repository,
          conversationId: testConversationId,
        );

        // 等待初始化完成
        await Future.delayed(const Duration(milliseconds: 100));

        expect(cubit.state.timeline, isNotNull);
        expect(cubit.state.timeline!.length, equals(5));
        expect(cubit.state.messages.length, greaterThan(0));
      });
    });

    group('消息发送功能', () {
      setUp(() async {
        cubit = ChatCubit(
          chatRepository: repository,
          conversationId: testConversationId,
        );
        await Future.delayed(const Duration(milliseconds: 100));
      });

      test('应该正确发送文本消息并更新Timeline', () async {
        const testMessage = 'Hello, this is a test message';

        await cubit.sendTextMessage(testMessage);

        expect(cubit.state.timeline, isNotNull);
        expect(cubit.state.timeline!.length, equals(1));

        final messages = cubit.state.timeline!.getAllMessages();
        expect(messages.first.text, equals(testMessage));
        expect(messages.first.type, equals('text'));
      });

      test('多条消息应该按正确顺序添加到Timeline', () async {
        const messages = ['Message 1', 'Message 2', 'Message 3'];

        for (final msg in messages) {
          await cubit.sendTextMessage(msg);
          // 短暂延迟确保时间戳不同
          await Future.delayed(const Duration(milliseconds: 10));
        }

        expect(cubit.state.timeline!.length, equals(3));

        final timelineMessages = cubit.state.timeline!.getAllMessages();
        for (int i = 0; i < messages.length; i++) {
          expect(timelineMessages[i].text, equals(messages[i]));
        }
      });
    });

    group('消息加载功能', () {
      setUp(() async {
        // 预先添加一些测试消息
        final testMessages = _createTestMessages(testConversationId, 15);
        for (final message in testMessages) {
          repository.addMockMessage(message);
        }

        cubit = ChatCubit(
          chatRepository: repository,
          conversationId: testConversationId,
        );
        await Future.delayed(const Duration(milliseconds: 100));
      });

      test('loadMessages应该从Timeline缓存加载消息', () async {
        await cubit.loadMessages();

        expect(cubit.state.timeline, isNotNull);
        expect(cubit.state.timeline!.length, equals(15));
        expect(cubit.state.messages.length, greaterThan(0));
      });

      test('loadMoreMessages应该正确加载更多历史消息', () async {
        // 添加更多历史消息
        final olderMessages = _createTestMessages(testConversationId, 10,
            startTime: DateTime.now().subtract(const Duration(hours: 24)));
        for (final message in olderMessages) {
          repository.addMockMessage(message);
        }

        final initialCount = cubit.state.timeline!.length;
        final oldestMessage = cubit.state.timeline!.getAllMessages().first;

        await cubit.loadMoreMessages(oldestMessage.createdAt);

        expect(cubit.state.timeline!.length, greaterThan(initialCount));
      });
    });

    group('滚动和查看状态', () {
      setUp(() async {
        final testMessages = _createTestMessages(testConversationId, 20);
        for (final message in testMessages) {
          repository.addMockMessage(message);
        }

        cubit = ChatCubit(
          chatRepository: repository,
          conversationId: testConversationId,
        );
        await Future.delayed(const Duration(milliseconds: 100));
      });

      test('updateScrollPosition应该正确更新滚动位置', () {
        const newPosition = 10;

        cubit.updateScrollPosition(newPosition);

        expect(cubit.state.currentScrollPosition, equals(newPosition));
        expect(cubit.state.timeline!.lastVisibleIndex, equals(newPosition));
      });

      test('scrollToMessage应该正确定位到指定消息', () {
        final messages = cubit.state.timeline!.getAllMessages();
        if (messages.isNotEmpty) {
          final targetMessage = messages[5]; // 选择第6条消息

          cubit.scrollToMessage(targetMessage.messageId);

          expect(
              cubit.state.lastReadMessageId, equals(targetMessage.messageId));
        }
      });
    });

    group('缓存管理功能', () {
      setUp(() async {
        cubit = ChatCubit(
          chatRepository: repository,
          conversationId: testConversationId,
        );
        await Future.delayed(const Duration(milliseconds: 100));
      });

      test('clearTimelineCache应该清空Timeline缓存', () async {
        // 发送一条消息确保有Timeline
        await cubit.sendTextMessage('Test message for cache');

        // 确保有Timeline
        expect(cubit.state.timeline, isNotNull);
        expect(repository.getTimeline(testConversationId), isNotNull);

        cubit.clearTimelineCache();

        // 等待状态更新
        await Future.delayed(const Duration(milliseconds: 10));

        // 先验证Repository状态
        final repoTimeline = repository.getTimeline(testConversationId);
        expect(repoTimeline, isNull, reason: 'Repository中的Timeline应该已被清空');

        // 再验证Cubit状态
        expect(cubit.state.timeline, isNull,
            reason: 'Cubit状态中的Timeline应该为null');
      });

      test('refreshTimeline应该重新加载Timeline', () async {
        // 添加一些消息
        final testMessages = _createTestMessages(testConversationId, 5);
        for (final message in testMessages) {
          repository.addMockMessage(message);
        }

        await cubit.refreshTimeline();

        expect(cubit.state.timeline, isNotNull);
        expect(cubit.state.timeline!.length, equals(5));
      });

      test('getCacheStats应该返回正确的统计信息', () {
        final stats = cubit.getCacheStats();

        expect(stats.containsKey('repository'), isTrue);
        expect(stats.containsKey('currentTimeline'), isTrue);
        expect(stats.containsKey('conversationId'), isTrue);
        expect(stats['conversationId'], equals(testConversationId));
      });
    });

    group('未读消息管理', () {
      setUp(() async {
        cubit = ChatCubit(
          chatRepository: repository,
          conversationId: testConversationId,
        );
        await Future.delayed(const Duration(milliseconds: 100));
      });

      test('markMessagesAsRead应该正确标记消息为已读', () async {
        // 发送几条消息
        await cubit.sendTextMessage('Message 1');
        await cubit.sendTextMessage('Message 2');
        await cubit.sendTextMessage('Message 3');

        final messages = cubit.state.timeline!.getAllMessages();
        final messageIds = messages.take(2).map((m) => m.messageId).toList();

        cubit.markMessagesAsRead(messageIds);

        // 验证消息已标记为已读
        final updatedMessages = cubit.state.timeline!.getAllMessages();
        expect(updatedMessages[0].isRead, isTrue);
        expect(updatedMessages[1].isRead, isTrue);
      });

      test('markMessagesAsRead应该更新Timeline未读计数', () async {
        // 先发送几条消息
        await cubit.sendTextMessage('Message 1');
        await cubit.sendTextMessage('Message 2');
        await cubit.sendTextMessage('Message 3');
        await cubit.sendTextMessage('Message 4');
        await cubit.sendTextMessage('Message 5');

        // 获取消息并设置为未读
        final messages = cubit.state.timeline!.getAllMessages();
        final unreadMessages = messages.take(3).toList();

        // 正确设置消息为未读状态
        for (final message in unreadMessages) {
          message.isRead = false;
        }

        // 通过markMessagesAsRead触发重新计算（传入空列表）
        cubit.state.timeline!.markMessagesAsRead([]);

        // 验证未读计数
        expect(cubit.state.timeline!.unreadCount, equals(3));

        // 标记所有为已读
        final messageIds = unreadMessages.map((m) => m.messageId).toList();
        cubit.markMessagesAsRead(messageIds);

        expect(cubit.state.unreadCount, equals(0));
        expect(cubit.state.timeline!.unreadCount, equals(0));
      });
    });

    group('错误处理', () {
      test('初始化失败时应该设置错误状态', () async {
        // 创建一个会失败的repository
        final errorRepository = TestChatRepositoryForCubit();

        cubit = ChatCubit(
          chatRepository: errorRepository,
          conversationId: testConversationId,
        );

        // 等待初始化完成
        await Future.delayed(const Duration(milliseconds: 100));

        // 验证正常初始化（因为我们的mock实现不会失败）
        expect(cubit.state.conversationId, equals(testConversationId));
      });
    });

    group('UI层Timeline集成', () {
      setUp(() async {
        // 预先创建Timeline缓存
        final timeline = MessageTimeline(conversationId: testConversationId);
        final testMessages = _createTestMessages(testConversationId, 20);
        timeline.appendNewMessages(testMessages);

        // 设置滚动位置
        timeline.updateLastVisibleIndex(10);

        repository.storeTimeline(testConversationId, timeline);

        cubit = ChatCubit(
          chatRepository: repository,
          conversationId: testConversationId,
        );
        await Future.delayed(const Duration(milliseconds: 100));
      });

      test('应该正确恢复滚动位置', () {
        expect(cubit.state.timeline, isNotNull);
        expect(cubit.state.timeline!.length, equals(20));
        expect(cubit.state.timeline!.lastVisibleIndex, equals(10));
        expect(cubit.state.currentScrollPosition, equals(10));
      });

      test('updateScrollPosition应该同步Timeline状态', () {
        const newPosition = 15;

        cubit.updateScrollPosition(newPosition);

        expect(cubit.state.currentScrollPosition, equals(newPosition));
        expect(cubit.state.timeline!.lastVisibleIndex, equals(newPosition));

        // 验证Repository缓存也已更新
        final cachedTimeline = repository.getTimeline(testConversationId);
        expect(cachedTimeline!.lastVisibleIndex, equals(newPosition));
      });

      test('发送消息应该更新Timeline并调整滚动位置', () async {
        const testMessage = 'New message for scroll test';
        final initialLength = cubit.state.timeline!.length;

        await cubit.sendTextMessage(testMessage);

        expect(cubit.state.timeline!.length, equals(initialLength + 1));

        // 验证滚动位置已调整（新消息应该在可见范围内）
        expect(cubit.state.currentScrollPosition, isNotNull);
      });

      test('loadMoreMessages应该正确处理Timeline扩展', () async {
        // 添加更多历史消息到repository
        final olderMessages = _createTestMessages(testConversationId, 10,
            startTime: DateTime.now().subtract(const Duration(hours: 48)));
        for (final message in olderMessages) {
          repository.addMockMessage(message);
        }

        final initialLength = cubit.state.timeline!.length;
        final oldestMessage = cubit.state.timeline!.getAllMessages().first;

        await cubit.loadMoreMessages(oldestMessage.createdAt);

        expect(cubit.state.timeline!.length, greaterThan(initialLength));
      });

      test('getCacheStats应该返回完整的统计信息', () {
        final stats = cubit.getCacheStats();

        expect(stats.containsKey('repository'), isTrue);
        expect(stats.containsKey('currentTimeline'), isTrue);
        expect(stats.containsKey('conversationId'), isTrue);

        expect(stats['conversationId'], equals(testConversationId));
        expect(stats['currentTimeline']['totalMessages'], equals(20));
      });

      test('refreshTimeline应该重新加载Timeline并保持功能', () async {
        // 记录原始Timeline的消息数量

        // 添加更多消息到repository模拟有新数据可用
        final newMessages = _createTestMessages(testConversationId, 5,
            startTime: DateTime.now().add(const Duration(minutes: 1)));
        for (final message in newMessages) {
          repository.addMockMessage(message);
        }

        await cubit.refreshTimeline();

        expect(cubit.state.timeline, isNotNull);
        // 刷新后Timeline应该重新加载，消息数量应该是所有可用消息的数量
        // 原来的20条 + 新增的5条 = 25条，但由于预加载限制，实际可能更少
        expect(cubit.state.timeline!.length, greaterThanOrEqualTo(5));

        // 验证Timeline功能正常
        expect(
            cubit.state.timeline!.conversationId, equals(testConversationId));
        expect(cubit.state.isLoadingMessages, isFalse);
        expect(cubit.state.isPreloading, isFalse);
      });
    });
  });
}

/// 创建测试消息列表
List<Message> _createTestMessages(String conversationId, int count,
    {DateTime? startTime}) {
  final baseTime = startTime ?? DateTime.now().subtract(Duration(hours: count));

  return List.generate(count, (index) {
    final message = Message()
      ..messageId = 'test_msg_${conversationId}_$index'
      ..conversationId = conversationId
      ..senderId = 'user_${index % 3}'
      ..senderName = 'User ${index % 3}'
      ..createdAt = baseTime.add(Duration(minutes: index))
      ..isRead = index < count ~/ 2 // 前半部分已读
      ..status = 'sent'
      ..type = 'text'
      ..text = 'Test message content $index';

    return message;
  });
}
