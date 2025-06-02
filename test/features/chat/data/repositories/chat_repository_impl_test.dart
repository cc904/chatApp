import 'package:flutter_test/flutter_test.dart';
import 'package:cc/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:cc/core/database/models/message.dart';
import 'package:cc/core/proto/generated/user.pb.dart';

// 为了测试，我们需要创建一个可测试的ChatRepositoryImpl版本
class TestChatRepositoryImpl extends ChatRepositoryImpl {
  final List<Message> _mockMessages = [];

  TestChatRepositoryImpl()
      : super(
            currentUserProto: CurrentUserProto()
              ..userId = 'test_user_id'
              ..name = 'Test User');

  // 重写数据库查询方法以返回模拟数据
  @override
  Future<List<Message>> getConversationMessages(String conversationId,
      {int limit = 20, DateTime? before}) async {
    return _mockMessages
        .where((msg) => msg.conversationId == conversationId)
        .take(limit)
        .toList();
  }

  // 添加模拟消息
  void addMockMessage(Message message) {
    _mockMessages.add(message);
  }

  // 清空模拟消息
  void clearMockMessages() {
    _mockMessages.clear();
  }
}

void main() {
  group('ChatRepositoryImpl Message Cache Tests', () {
    late TestChatRepositoryImpl repository;

    setUp(() {
      repository = TestChatRepositoryImpl();
    });

    tearDown(() {
      repository.dispose();
    });

    group('基础缓存功能', () {
      test('getCachedMessages 应该在没有缓存时返回null', () {
        final messages = repository.getCachedMessages('test_conversation');
        expect(messages, isNull);
      });

      test('cacheMessages 和 getCachedMessages 应该正确工作', () {
        final testMessages = _createTestMessages().take(5).toList();

        // 缓存消息
        repository.cacheMessages('test_conversation', testMessages);

        // 获取缓存的消息
        final cachedMessages =
            repository.getCachedMessages('test_conversation');

        expect(cachedMessages, isNotNull);
        expect(cachedMessages!.length, equals(5));
        expect(
            cachedMessages.first.conversationId, equals('test_conversation'));
      });

      test('removeCachedMessages 应该正确移除缓存', () {
        final testMessages = _createTestMessages().take(5).toList();
        repository.cacheMessages('test_conversation', testMessages);

        // 确认缓存存在
        expect(repository.getCachedMessages('test_conversation'), isNotNull);

        // 移除缓存
        repository.removeCachedMessages('test_conversation');

        // 确认缓存已移除
        expect(repository.getCachedMessages('test_conversation'), isNull);
      });

      test('clearMessageCache 应该清空所有缓存', () {
        final testMessages = _createTestMessages().take(5).toList();

        // 添加多个会话的缓存
        for (int i = 0; i < 3; i++) {
          repository.cacheMessages('conversation_$i', testMessages);
        }

        // 确认缓存存在
        expect(repository.getCachedMessages('conversation_0'), isNotNull);
        expect(repository.getCachedMessages('conversation_1'), isNotNull);
        expect(repository.getCachedMessages('conversation_2'), isNotNull);

        // 清空缓存
        repository.clearMessageCache();

        // 确认所有缓存已清空
        expect(repository.getCachedMessages('conversation_0'), isNull);
        expect(repository.getCachedMessages('conversation_1'), isNull);
        expect(repository.getCachedMessages('conversation_2'), isNull);
      });
    });

    group('缓存统计功能', () {
      test('getCacheStats 应该返回正确的统计信息', () {
        final testMessages = _createTestMessages().take(5).toList();

        // 添加一些消息缓存
        for (int i = 0; i < 3; i++) {
          repository.cacheMessages('conversation_$i', testMessages);
        }

        final stats = repository.getCacheStats();

        expect(stats['cachedConversations'], equals(3));
        expect(stats['totalMessages'], equals(15)); // 3 * 5
        expect(stats['averageMessagesPerConversation'], equals('5.0'));
        expect(stats['maxCacheSize'], equals(60)); // maxCachedConversations
        expect(stats.containsKey('estimatedMemoryMB'), isTrue);
        expect(stats.containsKey('cacheUtilization'), isTrue);
      });

      test('空缓存的统计信息应该正确', () {
        final stats = repository.getCacheStats();

        expect(stats['cachedConversations'], equals(0));
        expect(stats['totalMessages'], equals(0));
        expect(stats['averageMessagesPerConversation'], equals('0'));
        expect(stats['estimatedMemoryMB'], equals('0.0'));
        expect(stats['cacheUtilization'], equals('0.0%'));
      });
    });

    group('LRU缓存淘汰', () {
      test('应该正确实现LRU淘汰策略', () {
        final testMessages = _createTestMessages().take(5).toList();

        // 添加多个会话的缓存
        for (int i = 0; i < 5; i++) {
          repository.cacheMessages('conversation_$i', testMessages);
        }

        // 访问某些缓存来改变LRU顺序
        repository.getCachedMessages('conversation_0');
        repository.getCachedMessages('conversation_2');

        // 验证缓存仍然存在
        expect(repository.getCachedMessages('conversation_0'), isNotNull);
        expect(repository.getCachedMessages('conversation_2'), isNotNull);
        expect(repository.getCachedMessages('conversation_4'), isNotNull);
      });
    });
  });
}

/// 创建测试消息
List<Message> _createTestMessages() {
  final messages = <Message>[];
  final baseTime = DateTime.now().subtract(const Duration(hours: 1));

  for (int i = 0; i < 20; i++) {
    final message = Message()
      ..messageId = 'msg_$i'
      ..conversationId = 'test_conversation'
      ..senderId = 'user_${i % 2}' // 交替发送者
      ..senderName = 'User ${i % 2}'
      ..type = 'text'
      ..text = 'Test message $i'
      ..createdAt = baseTime.add(Duration(minutes: i))
      ..status = 'sent';

    messages.add(message);
  }

  return messages;
}
