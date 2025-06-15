import 'package:flutter_test/flutter_test.dart';
import 'package:cc/features/chat/domain/repositories/chat_repository_send.dart';

void main() {
  group('MessageSendEvent Tests', () {
    test('should create sendStarted event correctly', () {
      // Act
      final event = MessageSendEvent.sendStarted(
        messageId: 'msg_123',
        conversationId: 'conv_456',
      );

      // Assert
      expect(event.type, equals(MessageSendEventType.sendStarted));
      expect(event.messageId, equals('msg_123'));
      expect(event.conversationId, equals('conv_456'));
      expect(event.data, isNull);
      expect(event.timestamp, isA<DateTime>());
    });

    test('should create sendSuccess event correctly', () {
      // Act
      final event = MessageSendEvent.sendSuccess(
        messageId: 'temp_123',
        conversationId: 'conv_456',
        serverMessageId: 'server_msg_789',
        messageIndex: 100,
      );

      // Assert
      expect(event.type, equals(MessageSendEventType.sendSuccess));
      expect(event.messageId, equals('temp_123'));
      expect(event.conversationId, equals('conv_456'));
      expect(event.data?['serverMessageId'], equals('server_msg_789'));
      expect(event.data?['messageIndex'], equals(100));
      expect(event.timestamp, isA<DateTime>());
    });

    test('should create sendFailed event correctly', () {
      // Act
      final event = MessageSendEvent.sendFailed(
        messageId: 'msg_123',
        conversationId: 'conv_456',
        errorReason: 'Network error',
      );

      // Assert
      expect(event.type, equals(MessageSendEventType.sendFailed));
      expect(event.messageId, equals('msg_123'));
      expect(event.conversationId, equals('conv_456'));
      expect(event.data?['errorReason'], equals('Network error'));
      expect(event.timestamp, isA<DateTime>());
    });

    test('should create sendTimeout event correctly', () {
      // Act
      final event = MessageSendEvent.sendTimeout(
        messageId: 'msg_123',
        conversationId: 'conv_456',
      );

      // Assert
      expect(event.type, equals(MessageSendEventType.sendTimeout));
      expect(event.messageId, equals('msg_123'));
      expect(event.conversationId, equals('conv_456'));
      expect(event.data, isNull);
      expect(event.timestamp, isA<DateTime>());
    });

    test('should convert event to string correctly', () {
      // Arrange
      final event = MessageSendEvent.sendFailed(
        messageId: 'msg_123',
        conversationId: 'conv_456',
        errorReason: 'Test error',
      );

      // Act
      final eventString = event.toString();

      // Assert
      expect(eventString, contains('MessageSendEvent'));
      expect(eventString, contains('sendFailed'));
      expect(eventString, contains('msg_123'));
      expect(eventString, contains('conv_456'));
    });
  });

  group('MessageSendEventType Tests', () {
    test('should have all expected event types', () {
      const allTypes = MessageSendEventType.values;

      expect(allTypes, contains(MessageSendEventType.sendStarted));
      expect(allTypes, contains(MessageSendEventType.sendSuccess));
      expect(allTypes, contains(MessageSendEventType.sendFailed));
      expect(allTypes, contains(MessageSendEventType.sendTimeout));
      expect(allTypes, contains(MessageSendEventType.uploadStarted));
      expect(allTypes, contains(MessageSendEventType.uploadProgress));
      expect(allTypes, contains(MessageSendEventType.uploadCompleted));
      expect(allTypes, contains(MessageSendEventType.uploadFailed));
    });
  });
}
