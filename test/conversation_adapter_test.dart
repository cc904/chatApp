import 'package:flutter_test/flutter_test.dart';
import 'package:cc/core/adapters/conversation_adapter.dart';
import 'package:cc/core/database/models/conversation.dart';
import 'package:cc/core/proto/generated/conversation.pb.dart' as proto;
import 'package:fixnum/fixnum.dart';

void main() {
  group('ConversationAdapter Tests', () {
    test('应该正确从Proto转换为Conversation', () {
      // 创建测试用的Proto对象
      final protoConversation = proto.ConversationProto(
        conversationId: 'test_conversation_id',
        type: proto.ConversationType.PRIVATE,
        name: 'Test Conversation',
        avatar: 'test_avatar_url',
        createdAt: Int64(DateTime.now().millisecondsSinceEpoch),
        lastMessagePreview: 'Hello, World!',
        lastMessageTime: Int64(DateTime.now().millisecondsSinceEpoch),
        unreadCount: 5,
        contactUserId: 'test_contact_id',
        muted: false,
        pinned: true,
      );

      // 转换为Conversation对象
      final conversation = ConversationAdapter.fromProto(protoConversation);

      // 验证转换结果
      expect(conversation.conversationId, equals('test_conversation_id'));
      expect(conversation.type, equals(ConversationType.private));
      expect(conversation.name, equals('Test Conversation'));
      expect(conversation.avatar, equals('test_avatar_url'));
      expect(conversation.lastMessagePreview, equals('Hello, World!'));
      expect(conversation.unreadCount, equals(5));
      expect(conversation.contactUserId, equals('test_contact_id'));
      expect(conversation.isMuted, equals(false));
      expect(conversation.isPinned, equals(true));
    });

    test('应该正确从Conversation转换为Proto', () {
      // 创建测试用的Conversation对象
      final conversation = Conversation()
        ..conversationId = 'test_conversation_id'
        ..type = ConversationType.group
        ..name = 'Test Group'
        ..avatar = 'test_avatar_url'
        ..createdAt = DateTime.now()
        ..lastMessagePreview = 'Group message'
        ..lastMessageTime = DateTime.now()
        ..unreadCount = 3
        ..isMuted = true
        ..isPinned = false
        ..createdBy = 'test_creator_id';

      // 转换为Proto对象
      final protoConversation = ConversationAdapter.toProto(conversation);

      // 验证转换结果
      expect(protoConversation.conversationId, equals('test_conversation_id'));
      expect(protoConversation.type, equals(proto.ConversationType.GROUP));
      expect(protoConversation.name, equals('Test Group'));
      expect(protoConversation.avatar, equals('test_avatar_url'));
      expect(protoConversation.lastMessagePreview, equals('Group message'));
      expect(protoConversation.unreadCount, equals(3));
      expect(protoConversation.muted, equals(true));
      expect(protoConversation.pinned, equals(false));
      expect(protoConversation.createdBy, equals('test_creator_id'));
    });

    test('应该正确处理批量转换', () {
      // 创建测试用的Proto列表
      final protoList = [
        proto.ConversationProto(
          conversationId: 'conv1',
          type: proto.ConversationType.PRIVATE,
          name: 'Conversation 1',
        ),
        proto.ConversationProto(
          conversationId: 'conv2',
          type: proto.ConversationType.GROUP,
          name: 'Conversation 2',
        ),
      ];

      // 批量转换
      final conversations = ConversationAdapter.fromProtoList(protoList);

      // 验证结果
      expect(conversations.length, equals(2));
      expect(conversations[0].conversationId, equals('conv1'));
      expect(conversations[0].type, equals(ConversationType.private));
      expect(conversations[1].conversationId, equals('conv2'));
      expect(conversations[1].type, equals(ConversationType.group));
    });

    test('应该正确处理会话类型转换', () {
      // 测试所有会话类型
      final types = [
        {
          'local': ConversationType.private,
          'proto': proto.ConversationType.PRIVATE
        },
        {
          'local': ConversationType.group,
          'proto': proto.ConversationType.GROUP
        },
        {
          'local': ConversationType.channel,
          'proto': proto.ConversationType.CHANNEL
        },
      ];

      for (final typeTest in types) {
        // 测试本地枚举到Proto枚举
        final protoType = ConversationAdapter.localTypeToProto(
            typeTest['local'] as ConversationType);
        expect(protoType, equals(typeTest['proto']));

        // 测试Proto枚举到本地枚举
        final localType = ConversationAdapter.protoTypeToLocal(
            typeTest['proto'] as proto.ConversationType);
        expect(localType, equals(typeTest['local']));
      }
    });

    test('应该正确处理字符串类型转换', () {
      // 测试字符串到Proto枚举
      expect(ConversationAdapter.stringToConversationType('private'),
          equals(proto.ConversationType.PRIVATE));
      expect(ConversationAdapter.stringToConversationType('group'),
          equals(proto.ConversationType.GROUP));
      expect(ConversationAdapter.stringToConversationType('channel'),
          equals(proto.ConversationType.CHANNEL));

      // 测试Proto枚举到字符串
      expect(
          ConversationAdapter.conversationTypeToString(
              proto.ConversationType.PRIVATE),
          equals('private'));
      expect(
          ConversationAdapter.conversationTypeToString(
              proto.ConversationType.GROUP),
          equals('group'));
      expect(
          ConversationAdapter.conversationTypeToString(
              proto.ConversationType.CHANNEL),
          equals('channel'));
    });

    test('应该正确处理可选字段', () {
      // 创建只有必需字段的Proto对象
      final protoConversation = proto.ConversationProto(
        conversationId: 'test_conversation_id',
        type: proto.ConversationType.PRIVATE,
      );

      // 转换为Conversation对象
      final conversation = ConversationAdapter.fromProto(protoConversation);

      // 验证可选字段为null或默认值
      expect(conversation.name, isNull);
      expect(conversation.avatar, isNull);
      expect(conversation.lastMessagePreview, isNull);
      expect(conversation.contactUserId, isNull);
      expect(conversation.unreadCount, equals(0)); // 默认值
      expect(conversation.isMuted, equals(false)); // 默认值
      expect(conversation.isPinned, equals(false)); // 默认值
    });

    test('应该正确处理时间戳转换', () {
      final now = DateTime.now();
      final timestamp = Int64(now.millisecondsSinceEpoch);

      // 创建包含时间戳的Proto对象
      final protoConversation = proto.ConversationProto(
        conversationId: 'test_conversation_id',
        type: proto.ConversationType.PRIVATE,
        createdAt: timestamp,
        lastMessageTime: timestamp,
        lastReadAt: timestamp,
      );

      // 转换为Conversation对象
      final conversation = ConversationAdapter.fromProto(protoConversation);

      // 验证时间戳转换（允许1秒误差）
      expect(conversation.createdAt.millisecondsSinceEpoch,
          closeTo(now.millisecondsSinceEpoch, 1000));
      expect(conversation.lastMessageTime?.millisecondsSinceEpoch,
          closeTo(now.millisecondsSinceEpoch, 1000));
      expect(conversation.lastReadAt?.millisecondsSinceEpoch,
          closeTo(now.millisecondsSinceEpoch, 1000));
    });
  });
}
