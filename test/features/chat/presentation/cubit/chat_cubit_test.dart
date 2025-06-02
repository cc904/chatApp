import 'package:flutter_test/flutter_test.dart';
import 'package:cc/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:cc/features/chat/domain/repositories/chat_repository.dart';
import 'package:cc/core/database/models/message.dart';
import 'package:cc/core/proto/generated/message.pbenum.dart';

/// 测试用的ChatRepository实现
class TestChatRepositoryForCubit implements ChatRepository {
  final List<Message> _mockMessages = [];
  final Map<String, List<Message>> _messageCache = {};
  bool _shouldFailSend = false;

  // 设置发送失败模拟
  void setShouldFailSend(bool shouldFail) {
    _shouldFailSend = shouldFail;
  }

  @override
  Future<List<Message>> getConversationMessages(String conversationId,
      {int limit = 20, DateTime? before}) async {
    final filteredMessages = _mockMessages
        .where((msg) => msg.conversationId == conversationId)
        .where((msg) => before == null || msg.createdAt.isBefore(before));

    // 按时间降序排列，然后取limit数量
    final sortedMessages = filteredMessages.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return sortedMessages.take(limit).toList();
  }

  @override
  List<Message>? getCachedMessages(String conversationId) {
    return _messageCache[conversationId];
  }

  @override
  void cacheMessages(String conversationId, List<Message> messages) {
    _messageCache[conversationId] = List<Message>.from(messages);
  }

  @override
  void removeCachedMessages(String conversationId) {
    _messageCache.remove(conversationId);
  }

  @override
  void clearMessageCache() {
    _messageCache.clear();
  }

  @override
  Map<String, dynamic> getCacheStats() {
    return {
      'cachedConversations': _messageCache.length,
      'totalMessages': _messageCache.values
          .fold(0, (sum, messages) => sum + messages.length),
      'estimatedMemoryMB': '0.1',
    };
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
  Future<Message> createTempMessage(
      String conversationId, String content, String type) async {
    final message = Message()
      ..messageId =
          'temp_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}'
      ..conversationId = conversationId
      ..senderId = 'test_user_id'
      ..senderName = 'Test User'
      ..createdAt = DateTime.now()
      ..status = 'sending'
      ..type = type
      ..text = content.isEmpty ? null : content;

    _mockMessages.add(message);
    return message;
  }

  @override
  Future<void> sendMessageWithTimeout(Message message,
      {Duration timeout = const Duration(seconds: 3)}) async {
    // 检查是否应该模拟发送失败
    if (_shouldFailSend) {
      await markMessageAsFailed(message.messageId, '模拟发送失败');
      return;
    }

    // 正常发送逻辑
    await Future.delayed(const Duration(milliseconds: 50));
    message.status = 'sent';
    message.messageId = 'msg_${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Future<void> markMessageAsFailed(String messageId, String errorReason) async {
    final message =
        _mockMessages.firstWhere((msg) => msg.messageId == messageId);
    message.status = 'failed';
    message.errorMessage = errorReason;
  }

  @override
  Future<Message?> getMessageById(String messageId) async {
    try {
      return _mockMessages.firstWhere((msg) => msg.messageId == messageId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> updateMessageStatus(String messageId, String status) async {
    final message =
        _mockMessages.firstWhere((msg) => msg.messageId == messageId);
    message.status = status;
    message.errorMessage = null;
  }

  @override
  Future<Message> sendTextMessage(String conversationId, String text) async {
    final message = Message()
      ..messageId = 'msg_${DateTime.now().millisecondsSinceEpoch}'
      ..conversationId = conversationId
      ..senderId = 'test_user_id'
      ..senderName = 'Test User'
      ..createdAt = DateTime.now()
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
    _messageCache.clear();
  }

  // 实现其他必需的方法（简化版本）
  @override
  Future<List<Message>> searchMessages(String keyword,
          {String? conversationId}) async =>
      [];

  @override
  Future<Message> sendImageMessage(String conversationId, String localPath,
          {String? mediaUrl}) async =>
      throw UnimplementedError();

  @override
  Future<Message> sendVoiceMessage(
          String conversationId, String localPath, int duration,
          {String? mediaUrl}) async =>
      throw UnimplementedError();

  @override
  Future<Message> sendFileMessage(String conversationId, String localPath,
          String fileName, double fileSize,
          {String? mediaUrl}) async =>
      throw UnimplementedError();

  @override
  Future<Message> sendVideoMessage(
          String conversationId, String localPath, int duration,
          {String? thumbnailUrl,
          String? mediaUrl,
          bool isServerProcessed = false}) async =>
      throw UnimplementedError();

  @override
  Future<void> deleteMessage(String messageId) async {}

  @override
  Future<List<Message>> getMessagesByDateRange(
          String conversationId, DateTime startDate, DateTime endDate,
          {int limit = 50}) async =>
      [];

  @override
  Future<List<Message>> getConversationMessagesFromDate(
          String conversationId, DateTime startDate,
          {int limit = 30}) async =>
      [];

  @override
  Future<List<Message>> fetchHistoryMessages(String conversationId,
          {DateTime? before, int limit = 20}) async =>
      [];

  @override
  Future<List<Message>> fetchMessagesFromServer(String conversationId,
          {int limit = 20, DateTime? before}) async =>
      [];

  @override
  Future<void> sendTypingStatus(String conversationId, bool isTyping) async {}

  @override
  Stream<Map<String, dynamic>> getTypingStatusStream() => const Stream.empty();

  @override
  Stream<Map<String, dynamic>> getMessageStatusStream() => const Stream.empty();

  @override
  Future<void> markMessagesAsRead(
      String conversationId, String messageId) async {}

  @override
  Future<void> markCurrentViewMessagesAsRead(
      String conversationId, String latestVisibleMessageId) async {
    // 模拟标记当前查看消息为已读
  }

  @override
  Stream<void> watchConversationMessages(String conversationId) =>
      const Stream.empty();

  @override
  Future<void> clearConversationMessages(String conversationId) async {}

  @override
  Future<void> updateLastReadAt(
      String conversationId, DateTime timestamp) async {}

  @override
  Future<void> updateLastReadMessageId(
      String conversationId, String messageId) async {}

  @override
  Future<bool> syncConversationMessages(
          String conversationId, MessageSyncType syncType,
          {String? anchorMessageId}) async =>
      true;

  @override
  Future<bool> syncRecentMessages(
          String conversationId, String anchorMessageId) async =>
      true;

  @override
  Future<bool> syncUnreadMessages(String conversationId,
          {String? lastReadMessageId}) async =>
      true;

  @override
  Future<Map<String, int>> calculateDailyMessageCounts(
          String conversationId, String anchorMessageId) async =>
      {};

  @override
  Future<int> getMessageCountByDate(
          String conversationId, DateTime date) async =>
      0;

  @override
  Future<bool> isMessageExistsLocally(
          String conversationId, String messageId) async =>
      false;

  @override
  Future<List<bool>> batchSyncMessages(List<ConversationSyncTask> syncTasks,
          {int maxConcurrent = 3}) async =>
      [];

  @override
  Future<String> resendMessage(String messageId) async => messageId;

  @override
  Future<int> cleanupDuplicateMessages(String conversationId) async => 0;

  @override
  Future<Map<String, dynamic>> validateMessageConsistency(
          String conversationId) async =>
      {};

  void dispose() {
    clearMockData();
  }
}

void main() {
  group('ChatCubit with Message Cache Integration', () {
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
      test('应该正确初始化空消息列表', () async {
        cubit = ChatCubit(
          chatRepository: repository,
          conversationId: testConversationId,
        );

        // 等待初始化完成
        await Future.delayed(const Duration(milliseconds: 100));

        expect(cubit.state.conversationId, equals(testConversationId));
        expect(cubit.state.messages, isEmpty);
      });

      test('应该正确加载带有消息的会话', () async {
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

        expect(cubit.state.conversationId, equals(testConversationId));
        expect(cubit.state.messages.length, equals(10));
      });
    });

    group('发送消息功能', () {
      setUp(() {
        cubit = ChatCubit(
          chatRepository: repository,
          conversationId: testConversationId,
        );
      });

      test('应该成功发送文本消息', () async {
        const messageText = '测试消息';

        await cubit.sendTextMessage(messageText);

        expect(cubit.state.messages.length, equals(1));
        expect(cubit.state.messages.first.text, equals(messageText));
        expect(cubit.state.messages.first.type, equals('text'));
      });

      test('应该处理发送失败的情况', () async {
        repository.setShouldFailSend(true);
        const messageText = '失败的消息';

        await cubit.sendTextMessage(messageText);

        expect(cubit.state.errorMessage, isNotNull);
      });
    });

    group('消息缓存功能', () {
      setUp(() {
        cubit = ChatCubit(
          chatRepository: repository,
          conversationId: testConversationId,
        );
      });

      test('应该正确缓存消息', () async {
        // 添加一些消息
        final testMessages = _createTestMessages(testConversationId, 5);
        for (final message in testMessages) {
          repository.addMockMessage(message);
        }

        // 重新加载消息
        await cubit.loadMoreMessages();

        // 检查缓存
        final cachedMessages = repository.getCachedMessages(testConversationId);
        expect(cachedMessages, isNotNull);
        expect(cachedMessages!.length, greaterThan(0));
      });

      test('应该正确获取缓存统计信息', () {
        final stats = cubit.getCacheStats();
        expect(stats, isNotNull);
        expect(stats.containsKey('cachedConversations'), isTrue);
        expect(stats.containsKey('totalMessages'), isTrue);
      });
    });
  });
}

/// 创建测试消息
List<Message> _createTestMessages(String conversationId, int count) {
  final messages = <Message>[];
  final baseTime = DateTime.now().subtract(Duration(hours: count));

  for (int i = 0; i < count; i++) {
    final message = Message()
      ..messageId = 'msg_$i'
      ..conversationId = conversationId
      ..senderId = 'user_${i % 2}'
      ..senderName = 'User ${i % 2}'
      ..type = 'text'
      ..text = 'Test message $i'
      ..createdAt = baseTime.add(Duration(minutes: i))
      ..status = 'sent';

    messages.add(message);
  }

  return messages;
}
