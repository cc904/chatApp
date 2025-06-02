import 'package:flutter_test/flutter_test.dart';
import 'package:cc/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:cc/features/chat/domain/repositories/chat_repository.dart';
import 'package:cc/core/database/models/message.dart';
import 'package:cc/core/proto/generated/message.pbenum.dart';

/// 测试用的ChatRepository实现
class TestChatRepository implements ChatRepository {
  final List<Message> _messages = [];
  final Map<String, List<Message>> _messageCache = {};

  bool shouldThrowError = false;
  String? errorMessage;

  @override
  Future<List<Message>> getConversationMessages(String conversationId,
      {int limit = 20, DateTime? before}) async {
    if (shouldThrowError) throw Exception(errorMessage ?? '测试错误');
    return _messages.where((m) => m.conversationId == conversationId).toList();
  }

  @override
  Future<List<Message>> searchMessages(String keyword,
      {String? conversationId}) async {
    if (shouldThrowError) throw Exception(errorMessage ?? '测试错误');
    return _messages
        .where((m) =>
            m.text?.contains(keyword) == true &&
            (conversationId == null || m.conversationId == conversationId))
        .toList();
  }

  @override
  Future<Message> sendTextMessage(String conversationId, String text) async {
    if (shouldThrowError) throw Exception(errorMessage ?? '测试错误');

    final message = Message()
      ..messageId = 'msg_${DateTime.now().millisecondsSinceEpoch}'
      ..conversationId = conversationId
      ..type = 'text'
      ..text = text
      ..senderId = 'test_user'
      ..senderName = '测试用户'
      ..createdAt = DateTime.now()
      ..status = 'sent';

    _messages.add(message);
    return message;
  }

  @override
  Future<Message> sendImageMessage(String conversationId, String localPath,
      {String? mediaUrl}) async {
    if (shouldThrowError) throw Exception(errorMessage ?? '测试错误');

    final message = Message()
      ..messageId = 'img_${DateTime.now().millisecondsSinceEpoch}'
      ..conversationId = conversationId
      ..type = 'image'
      ..localPath = localPath
      ..mediaUrl = mediaUrl
      ..senderId = 'test_user'
      ..senderName = '测试用户'
      ..createdAt = DateTime.now()
      ..status = 'sent';

    _messages.add(message);
    return message;
  }

  @override
  Future<Message> sendVoiceMessage(
      String conversationId, String localPath, int duration,
      {String? mediaUrl}) async {
    if (shouldThrowError) throw Exception(errorMessage ?? '测试错误');

    final message = Message()
      ..messageId = 'voice_${DateTime.now().millisecondsSinceEpoch}'
      ..conversationId = conversationId
      ..type = 'voice'
      ..localPath = localPath
      ..mediaUrl = mediaUrl
      ..duration = duration
      ..senderId = 'test_user'
      ..senderName = '测试用户'
      ..createdAt = DateTime.now()
      ..status = 'sent';

    _messages.add(message);
    return message;
  }

  @override
  Future<Message> sendFileMessage(
      String conversationId, String localPath, String fileName, double fileSize,
      {String? mediaUrl}) async {
    if (shouldThrowError) throw Exception(errorMessage ?? '测试错误');

    final message = Message()
      ..messageId = 'file_${DateTime.now().millisecondsSinceEpoch}'
      ..conversationId = conversationId
      ..type = 'file'
      ..localPath = localPath
      ..mediaUrl = mediaUrl
      ..fileName = fileName
      ..fileSize = fileSize
      ..senderId = 'test_user'
      ..senderName = '测试用户'
      ..createdAt = DateTime.now()
      ..status = 'sent';

    _messages.add(message);
    return message;
  }

  @override
  Future<Message> sendVideoMessage(
      String conversationId, String localPath, int duration,
      {String? thumbnailUrl,
      String? mediaUrl,
      bool isServerProcessed = false}) async {
    if (shouldThrowError) throw Exception(errorMessage ?? '测试错误');

    final message = Message()
      ..messageId = 'video_${DateTime.now().millisecondsSinceEpoch}'
      ..conversationId = conversationId
      ..type = 'video'
      ..localPath = localPath
      ..mediaUrl = mediaUrl
      ..thumbnailUrl = thumbnailUrl
      ..duration = duration
      ..senderId = 'test_user'
      ..senderName = '测试用户'
      ..createdAt = DateTime.now()
      ..status = isServerProcessed ? 'processing' : 'sent';

    _messages.add(message);
    return message;
  }

  @override
  Future<void> markConversationAsRead(String conversationId) async {
    if (shouldThrowError) throw Exception(errorMessage ?? '测试错误');
    // 实现标记已读逻辑
  }

  @override
  Future<void> deleteMessage(String messageId) async {
    if (shouldThrowError) throw Exception(errorMessage ?? '测试错误');
    _messages.removeWhere((m) => m.messageId == messageId);
  }

  @override
  Future<void> clearConversationMessages(String conversationId) async {
    if (shouldThrowError) throw Exception(errorMessage ?? '测试错误');
    _messages.removeWhere((m) => m.conversationId == conversationId);
  }

  @override
  Stream<void> watchConversationMessages(String conversationId) {
    return const Stream.empty();
  }

  @override
  Future<List<Message>> getMessagesByDateRange(
      String conversationId, DateTime startDate, DateTime endDate,
      {int limit = 50}) async {
    if (shouldThrowError) throw Exception(errorMessage ?? '测试错误');
    return _messages
        .where((m) =>
            m.conversationId == conversationId &&
            m.createdAt.isAfter(startDate) &&
            m.createdAt.isBefore(endDate))
        .take(limit)
        .toList();
  }

  @override
  Future<List<Message>> getConversationMessagesFromDate(
      String conversationId, DateTime startDate,
      {int limit = 30}) async {
    if (shouldThrowError) throw Exception(errorMessage ?? '测试错误');
    return _messages
        .where((m) =>
            m.conversationId == conversationId &&
            m.createdAt.isAfter(startDate))
        .take(limit)
        .toList();
  }

  @override
  Future<List<Message>> fetchHistoryMessages(String conversationId,
      {DateTime? before, int limit = 20}) async {
    if (shouldThrowError) throw Exception(errorMessage ?? '测试错误');
    return getConversationMessages(conversationId,
        limit: limit, before: before);
  }

  @override
  Future<List<Message>> fetchMessagesFromServer(String conversationId,
      {int limit = 20, DateTime? before}) async {
    if (shouldThrowError) throw Exception(errorMessage ?? '测试错误');
    return getConversationMessages(conversationId,
        limit: limit, before: before);
  }

  @override
  Future<void> sendTypingStatus(String conversationId, bool isTyping) async {
    if (shouldThrowError) throw Exception(errorMessage ?? '测试错误');
    // 模拟发送打字状态
  }

  @override
  Stream<Map<String, dynamic>> getTypingStatusStream() => const Stream.empty();

  @override
  Stream<Map<String, dynamic>> getMessageStatusStream() => const Stream.empty();

  @override
  Future<void> updateLastReadAt(
      String conversationId, DateTime timestamp) async {
    if (shouldThrowError) throw Exception(errorMessage ?? '测试错误');
    // 模拟更新最后阅读时间
  }

  @override
  Future<void> updateLastReadMessageId(
      String conversationId, String messageId) async {
    if (shouldThrowError) throw Exception(errorMessage ?? '测试错误');
    // 模拟更新最后阅读消息ID
  }

  @override
  Future<void> joinConversationRoom(String conversationId) async {
    if (shouldThrowError) throw Exception(errorMessage ?? '测试错误');
    // 模拟加入房间
  }

  @override
  Future<void> leaveConversationRoom(String conversationId) async {
    if (shouldThrowError) throw Exception(errorMessage ?? '测试错误');
    // 模拟离开房间
  }

  // 消息缓存方法
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
      'timelineCount': 0,
      'messageCount': _messages.length,
      'cachedConversations': _messageCache.length,
      'totalMessages': _messageCache.values
          .fold(0, (sum, messages) => sum + messages.length),
      'estimatedMemoryMB': '0.1',
    };
  }

  @override
  Future<bool> syncConversationMessages(
    String conversationId,
    MessageSyncType syncType, {
    String? anchorMessageId,
  }) async {
    if (shouldThrowError) throw Exception(errorMessage ?? '测试错误');
    return true;
  }

  @override
  Future<bool> syncUnreadMessages(
    String conversationId, {
    String? lastReadMessageId,
  }) async {
    if (shouldThrowError) throw Exception(errorMessage ?? '测试错误');
    return true;
  }

  @override
  Future<bool> syncRecentMessages(
    String conversationId,
    String anchorMessageId,
  ) async {
    if (shouldThrowError) throw Exception(errorMessage ?? '测试错误');
    return true;
  }

  @override
  Future<List<bool>> batchSyncMessages(
    List<ConversationSyncTask> syncTasks, {
    int maxConcurrent = 3,
  }) async {
    if (shouldThrowError) throw Exception(errorMessage ?? '测试错误');
    return syncTasks.map((task) => true).toList();
  }

  Future<DateTime?> getMessageTimestamp(
      String conversationId, String messageId) async {
    if (shouldThrowError) throw Exception(errorMessage ?? '测试错误');
    final message = _messages.firstWhere(
      (m) => m.conversationId == conversationId && m.messageId == messageId,
      orElse: () => Message(),
    );
    return message.messageId.isNotEmpty ? message.createdAt : null;
  }

  @override
  Future<bool> isMessageExistsLocally(
      String conversationId, String messageId) async {
    if (shouldThrowError) throw Exception(errorMessage ?? '测试错误');
    return _messages.any(
      (m) => m.conversationId == conversationId && m.messageId == messageId,
    );
  }

  Future<DateTimeRange?> getLocalMessageTimeRange(String conversationId) async {
    if (shouldThrowError) throw Exception(errorMessage ?? '测试错误');
    final conversationMessages =
        _messages.where((m) => m.conversationId == conversationId).toList();

    if (conversationMessages.isEmpty) return null;

    conversationMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return DateTimeRange(
      start: conversationMessages.first.createdAt,
      end: conversationMessages.last.createdAt,
    );
  }

  @override
  Future<Map<String, int>> calculateDailyMessageCounts(
      String conversationId, String anchorMessageId) async {
    return {};
  }

  @override
  Future<int> getMessageCountByDate(
      String conversationId, DateTime date) async {
    return 0;
  }

  @override
  Future<int> cleanupDuplicateMessages(String conversationId) async {
    return 0;
  }

  @override
  Future<Map<String, dynamic>> validateMessageConsistency(
      String conversationId) async {
    return {
      'totalMessages': 0,
      'duplicateMessageIds': 0,
      'emptyMessageIds': 0,
      'timeOrderIssues': 0,
    };
  }

  @override
  Future<void> markMessagesAsRead(
      String conversationId, String messageId) async {
    if (shouldThrowError) throw Exception(errorMessage ?? '测试错误');
    // 模拟标记消息为已读
  }

  @override
  Future<Message> createTempMessage(
      String conversationId, String content, String type) async {
    if (shouldThrowError) throw Exception(errorMessage ?? '测试错误');
    return Message()
      ..messageId = 'temp_${DateTime.now().millisecondsSinceEpoch}'
      ..conversationId = conversationId
      ..type = type
      ..text = content
      ..senderId = 'test_user'
      ..senderName = '测试用户'
      ..createdAt = DateTime.now()
      ..status = 'sending';
  }

  @override
  Future<Message?> getMessageById(String messageId) async {
    if (shouldThrowError) throw Exception(errorMessage ?? '测试错误');
    try {
      return _messages.firstWhere((m) => m.messageId == messageId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> markMessageAsFailed(String messageId, String errorReason) async {
    if (shouldThrowError) throw Exception(errorMessage ?? '测试错误');
    final message = _messages.firstWhere((m) => m.messageId == messageId);
    message.status = 'failed';
    message.errorMessage = errorReason;
  }

  @override
  Future<String> resendMessage(String messageId) async {
    if (shouldThrowError) throw Exception(errorMessage ?? '测试错误');
    final message = _messages.firstWhere((m) => m.messageId == messageId);
    message.status = 'sent';
    message.errorMessage = null;
    return messageId;
  }

  @override
  Future<void> sendMessageWithTimeout(Message message,
      {Duration timeout = const Duration(seconds: 3)}) async {
    if (shouldThrowError) throw Exception(errorMessage ?? '测试错误');
    message.status = 'sent';
    _messages.add(message);
  }

  @override
  Future<void> updateMessageStatus(String messageId, String status) async {
    if (shouldThrowError) throw Exception(errorMessage ?? '测试错误');
    final message = _messages.firstWhere((m) => m.messageId == messageId);
    message.status = status;
  }

  @override
  Future<bool> preloadTimeline(String conversationId,
      {int messageCount = 100}) async {
    if (shouldThrowError) return false;

    // 模拟预加载
    final messages =
        await getConversationMessages(conversationId, limit: messageCount);
    return true;
  }

  @override
  Future<void> markCurrentViewMessagesAsRead(
      String conversationId, String latestVisibleMessageId) async {
    if (shouldThrowError) throw Exception(errorMessage ?? '测试错误');
    // 模拟标记当前查看消息为已读
    return;
  }
}

void main() {
  group('ChatCubit 媒体消息测试', () {
    late ChatCubit chatCubit;
    late TestChatRepository testRepository;
    late String testConversationId;

    setUp(() {
      testRepository = TestChatRepository();
      testConversationId = 'test_conversation_123';
      chatCubit = ChatCubit(
        conversationId: testConversationId,
        chatRepository: testRepository,
      );
    });

    tearDown(() {
      chatCubit.close();
    });

    group('发送图片消息', () {
      test('应该成功发送图片消息', () async {
        // Arrange
        const localPath = '/test/image.jpg';
        const mediaUrl = 'https://example.com/image.jpg';

        // Act
        await chatCubit.sendImageMessage(localPath, mediaUrl: mediaUrl);

        // Assert
        expect(chatCubit.state.isSending, false);
        expect(chatCubit.state.errorMessage, isNull);
        expect(testRepository._messages.length, 1);
        expect(testRepository._messages.first.type, 'image');
        expect(testRepository._messages.first.localPath, localPath);
        expect(testRepository._messages.first.mediaUrl, mediaUrl);
      });

      test('应该处理图片发送失败', () async {
        // Arrange
        const localPath = '/test/image.jpg';
        testRepository.shouldThrowError = true;
        testRepository.errorMessage = '网络错误';

        // Act
        await chatCubit.sendImageMessage(localPath);

        // Assert
        expect(chatCubit.state.isSending, false);
        expect(chatCubit.state.errorMessage, isNotNull);
        expect(chatCubit.state.errorMessage, contains('网络错误'));
      });
    });

    group('发送语音消息', () {
      test('应该成功发送语音消息', () async {
        // Arrange
        const localPath = '/test/voice.aac';
        const duration = 30000; // 30秒
        const mediaUrl = 'https://example.com/voice.aac';

        // Act
        await chatCubit.sendVoiceMessage(localPath, duration,
            mediaUrl: mediaUrl);

        // Assert
        expect(chatCubit.state.isSending, false);
        expect(chatCubit.state.errorMessage, isNull);
        expect(testRepository._messages.length, 1);
        expect(testRepository._messages.first.type, 'voice');
        expect(testRepository._messages.first.localPath, localPath);
        expect(testRepository._messages.first.mediaUrl, mediaUrl);
        expect(testRepository._messages.first.duration, duration);
      });

      test('应该处理语音发送失败', () async {
        // Arrange
        const localPath = '/test/voice.aac';
        const duration = 30000;
        testRepository.shouldThrowError = true;
        testRepository.errorMessage = '上传失败';

        // Act
        await chatCubit.sendVoiceMessage(localPath, duration);

        // Assert
        expect(chatCubit.state.isSending, false);
        expect(chatCubit.state.errorMessage, isNotNull);
        expect(chatCubit.state.errorMessage, contains('上传失败'));
      });
    });

    group('发送视频消息', () {
      test('应该成功发送视频消息', () async {
        // Arrange
        const localPath = '/test/video.mp4';
        const duration = 120000; // 2分钟
        const thumbnailUrl = 'https://example.com/thumbnail.jpg';
        const mediaUrl = 'https://example.com/video.mp4';

        // Act
        await chatCubit.sendVideoMessage(
          localPath,
          duration,
          thumbnailUrl: thumbnailUrl,
          mediaUrl: mediaUrl,
        );

        // Assert
        expect(chatCubit.state.isSending, false);
        expect(chatCubit.state.errorMessage, isNull);
        expect(testRepository._messages.length, 1);
        expect(testRepository._messages.first.type, 'video');
        expect(testRepository._messages.first.localPath, localPath);
        expect(testRepository._messages.first.mediaUrl, mediaUrl);
        expect(testRepository._messages.first.thumbnailUrl, thumbnailUrl);
        expect(testRepository._messages.first.duration, duration);
      });

      test('应该支持服务器处理模式', () async {
        // Arrange
        const localPath = '/test/video.mp4';
        const duration = 120000;
        const mediaUrl = 'https://example.com/video.mp4';

        // Act
        await chatCubit.sendVideoMessage(
          localPath,
          duration,
          mediaUrl: mediaUrl,
          isServerProcessed: true,
        );

        // Assert
        expect(chatCubit.state.isSending, false);
        expect(chatCubit.state.errorMessage, isNull);
        expect(testRepository._messages.length, 1);
        expect(testRepository._messages.first.status, 'processing');
      });
    });

    group('发送文件消息', () {
      test('应该成功发送文件消息', () async {
        // Arrange
        const localPath = '/test/document.pdf';
        const fileName = 'document.pdf';
        const fileSize = 1024.5; // KB
        const mediaUrl = 'https://example.com/document.pdf';

        // Act
        await chatCubit.sendFileMessage(
          localPath,
          fileName,
          fileSize,
          mediaUrl: mediaUrl,
        );

        // Assert
        expect(chatCubit.state.isSending, false);
        expect(chatCubit.state.errorMessage, isNull);
        expect(testRepository._messages.length, 1);
        expect(testRepository._messages.first.type, 'file');
        expect(testRepository._messages.first.localPath, localPath);
        expect(testRepository._messages.first.mediaUrl, mediaUrl);
        expect(testRepository._messages.first.fileName, fileName);
        expect(testRepository._messages.first.fileSize, fileSize);
      });
    });

    group('通用发送消息方法', () {
      test('应该根据消息类型调用正确的发送方法', () async {
        // Arrange - 图片消息
        final imageMessage = Message()
          ..type = 'image'
          ..localPath = '/test/image.jpg'
          ..mediaUrl = 'https://example.com/image.jpg';

        // Act
        await chatCubit.sendMessage(imageMessage);

        // Assert
        expect(testRepository._messages.length, 1);
        expect(testRepository._messages.first.type, 'image');
      });

      test('应该处理不支持的消息类型', () async {
        // Arrange
        final unsupportedMessage = Message()
          ..type = 'unsupported'
          ..text = '不支持的消息类型';

        // Act
        await chatCubit.sendMessage(unsupportedMessage);

        // Assert
        expect(chatCubit.state.errorMessage, isNotNull);
        expect(chatCubit.state.errorMessage, contains('不支持的消息类型'));
      });
    });

    group('消息集成测试', () {
      test('应该将新消息添加到消息列表', () async {
        // Arrange
        const localPath = '/test/image.jpg';

        // Act
        await chatCubit.sendImageMessage(localPath);

        // Assert
        expect(chatCubit.state.messages, isNotEmpty);
        expect(chatCubit.state.messages.length, equals(1));
        expect(chatCubit.state.messages.first.type, equals('image'));
      });
    });
  });
}
