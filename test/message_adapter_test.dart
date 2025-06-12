import 'package:flutter_test/flutter_test.dart';
import 'package:cc/core/adapters/message_adapter.dart';
import 'package:cc/core/database/models/message.dart';
import 'package:cc/core/proto/generated/message.pb.dart' as proto;
import 'package:fixnum/fixnum.dart';

void main() {
  group('MessageAdapter Tests', () {
    test('应该正确从Proto转换为Message', () {
      // 创建测试用的Proto对象
      final protoMessage = proto.MessageProto(
        messageId: 'test_message_id',
        conversationId: 'test_conversation_id',
        senderId: 'test_sender_id',
        senderName: 'Test Sender',
        createdAt: Int64(DateTime.now().millisecondsSinceEpoch),
        status: proto.MessageStatus.SENT,
        type: proto.MessageType.TEXT,
        textMessage: proto.TextMessage(
          text: 'Hello, World!',
        ),
      );

      // 转换为Message对象
      final message = MessageAdapter.fromProto(protoMessage);

      // 验证转换结果
      expect(message.messageId, equals('test_message_id'));
      expect(message.conversationId, equals('test_conversation_id'));
      expect(message.senderId, equals('test_sender_id'));
      expect(message.senderName, equals('Test Sender'));
      expect(message.status, equals(MessageStatus.sent));
      expect(message.type, equals('text'));
      expect(message.text, equals('Hello, World!'));
    });

    test('应该正确从Message转换为Proto', () {
      // 创建测试用的Message对象
      final message = Message()
        ..messageId = 'test_message_id'
        ..conversationId = 'test_conversation_id'
        ..senderId = 'test_sender_id'
        ..senderName = 'Test Sender'
        ..createdAt = DateTime.now()
        ..status = MessageStatus.sent
        ..type = MessageType.text
        ..text = 'Hello, World!';

      // 转换为Proto对象
      final protoMessage = MessageAdapter.toProto(message);

      // 验证转换结果
      expect(protoMessage.messageId, equals('test_message_id'));
      expect(protoMessage.conversationId, equals('test_conversation_id'));
      expect(protoMessage.senderId, equals('test_sender_id'));
      expect(protoMessage.senderName, equals('Test Sender'));
      expect(protoMessage.status, equals(proto.MessageStatus.SENT));
      expect(protoMessage.type, equals(proto.MessageType.TEXT));
      expect(protoMessage.textMessage.text, equals('Hello, World!'));
    });

    test('应该正确处理批量转换', () {
      // 创建测试用的Proto列表
      final protoList = [
        proto.MessageProto(
          messageId: 'msg1',
          conversationId: 'conv1',
          senderId: 'user1',
          type: proto.MessageType.TEXT,
          textMessage: proto.TextMessage(
            text: 'Message 1',
          ),
        ),
        proto.MessageProto(
          messageId: 'msg2',
          conversationId: 'conv1',
          senderId: 'user2',
          type: proto.MessageType.TEXT,
          textMessage: proto.TextMessage(
            text: 'Message 2',
          ),
        ),
      ];

      // 批量转换
      final messages = MessageAdapter.fromProtoList(protoList);

      // 验证结果
      expect(messages.length, equals(2));
      expect(messages[0].messageId, equals('msg1'));
      expect(messages[1].messageId, equals('msg2'));
    });

    test('应该正确处理枚举类型转换', () {
      // 测试所有消息类型
      final types = [
        {'string': 'text', 'proto': proto.MessageType.TEXT},
        {'string': 'image', 'proto': proto.MessageType.IMAGE},
        {'string': 'voice', 'proto': proto.MessageType.VOICE},
        {'string': 'video', 'proto': proto.MessageType.VIDEO},
        {'string': 'file', 'proto': proto.MessageType.FILE},
        // 位置消息测试已移除
        // expect(MessageAdapter.messageTypeToString(proto.MessageType.LOCATION), 'location'),
      ];

      for (final typeTest in types) {
        final protoMessage = proto.MessageProto(
          messageId: 'test',
          conversationId: 'test',
          senderId: 'test',
          type: typeTest['proto'] as proto.MessageType,
        );

        final message = MessageAdapter.fromProto(protoMessage);
        expect(message.type, equals(typeTest['string']));

        final backToProto = MessageAdapter.toProto(message);
        expect(backToProto.type, equals(typeTest['proto']));
      }
    });

    test('应该正确处理可选字段', () {
      // 创建只有必需字段的Proto对象
      final protoMessage = proto.MessageProto(
        messageId: 'test_message_id',
        conversationId: 'test_conversation_id',
        senderId: 'test_sender_id',
      );

      // 转换为Message对象
      final message = MessageAdapter.fromProto(protoMessage);

      // 验证可选字段为null或默认值
      expect(message.senderName, isNull);
      expect(message.text, isNull);
      expect(message.mediaUrl, isNull);
      expect(message.status, equals(MessageStatus.sent)); // 默认值
      expect(message.type, equals('text')); // 默认值
    });
  });
}
