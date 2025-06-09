import 'package:flutter_test/flutter_test.dart';
import 'package:cc/features/chat/domain/entities/message_cursor.dart';

void main() {
  group('MessageCursor', () {
    test('创建空游标', () {
      expect(MessageCursor.empty.isEmpty, true);
      expect(MessageCursor.empty.isValid, false);
    });

    test('从消息数据创建游标', () {
      final timestamp = DateTime.now();
      final cursor = MessageCursor.fromMessageData('msg123', timestamp);

      expect(cursor.messageId, equals('msg123'));
      expect(cursor.timestamp, equals(timestamp));
      expect(cursor.isValid, true);
      expect(cursor.isEmpty, false);
    });

    test('创建带位置的游标', () {
      final timestamp = DateTime.now();
      final cursor = MessageCursor(
        messageId: 'msg456',
        timestamp: timestamp,
        position: 'custom_position',
      );

      expect(cursor.messageId, equals('msg456'));
      expect(cursor.timestamp, equals(timestamp));
      expect(cursor.position, equals('custom_position'));
    });

    test('copyWith方法', () {
      final original =
          MessageCursor(messageId: 'msg1', timestamp: DateTime.now());
      final copied = original.copyWith(messageId: 'msg2');

      expect(original.messageId, equals('msg1'));
      expect(copied.messageId, equals('msg2'));
      expect(copied.timestamp, equals(original.timestamp));
    });

    test('相等性检查', () {
      final timestamp = DateTime.now();
      final cursor1 = MessageCursor(messageId: 'msg1', timestamp: timestamp);
      final cursor2 = MessageCursor(messageId: 'msg1', timestamp: timestamp);
      final cursor3 = MessageCursor(messageId: 'msg2', timestamp: timestamp);

      expect(cursor1, equals(cursor2));
      expect(cursor1, isNot(equals(cursor3)));
    });
  });

  group('CursorSyncResult', () {
    test('成功结果', () {
      final result = CursorSyncResult.success(
        conversationId: 'conv1',
        returnedCount: 10,
        hasMoreBefore: true,
        hasMoreAfter: false,
      );

      expect(result.success, true);
      expect(result.conversationId, equals('conv1'));
      expect(result.returnedCount, equals(10));
      expect(result.hasMoreBefore, true);
      expect(result.hasMoreAfter, false);
    });

    test('失败结果', () {
      final result = CursorSyncResult.failure(
        conversationId: 'conv1',
        errorMessage: '网络错误',
      );

      expect(result.success, false);
      expect(result.conversationId, equals('conv1'));
      expect(result.errorMessage, equals('网络错误'));
    });

    test('copyWith方法', () {
      final original = CursorSyncResult.success(
        conversationId: 'conv1',
        returnedCount: 5,
      );

      final copied = original.copyWith(returnedCount: 10);

      expect(original.returnedCount, equals(5));
      expect(copied.returnedCount, equals(10));
      expect(copied.conversationId, equals('conv1'));
    });
  });
}
