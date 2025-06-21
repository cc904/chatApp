import 'package:flutter_test/flutter_test.dart';
import 'package:cc/core/adapters/conversation_adapter.dart';
import 'package:cc/core/database/models/conversation.dart';
import 'package:cc/core/proto/generated/conversation.pb.dart' as proto;

void main() {
  group('会话同步时服务器数据完全同步测试', () {
    test('模拟服务器同步时完全使用服务器数据', () {
      // 安排：模拟现有本地会话（将被服务器数据覆盖）
      final existingConversation = Conversation()
        ..conversationId = 'conv1'
        ..type = ConversationType.group
        ..lastMessageIndex = 301 // 本地有301条消息
        ..participants = [
          Participant.create(
            userId: 'user1',
            name: 'User 1',
            readMessageIndex: 10, // 用户本地已读到第10条（将被覆盖）
          ),
        ];

      // 模拟服务器发送的同步数据（可能缺少readMessageIndex字段）
      final serverProto = proto.ConversationProto(
        conversationId: 'conv1',
        type: proto.ConversationType.GROUP,
        lastMessageIndex: 301, // 服务器确认有301条消息
        participants: [
          proto.ParticipantProto(
            userId: 'user1',
            name: 'User 1',
            // 注意：服务器Proto中可能没有readMessageIndex字段
            // 或者有过期的readMessageIndex值
          ),
        ],
      );

      // 执行：使用当前的fromProto方法（完全使用服务器数据）
      final syncedConversation = ConversationAdapter.fromProto(
        serverProto,
        currentUserId: 'user1',
      );

      // 验证：readMessageIndex应该使用服务器数据（即0，因为Proto中没有该字段）
      final user1Participant = syncedConversation.participants
          .firstWhere((p) => p.userId == 'user1');

      expect(user1Participant.readMessageIndex, equals(0),
          reason: '应该使用服务器数据，当Proto中没有readMessageIndex时默认为0');

      // 验证：lastMessageIndex应该使用服务器的新值
      expect(syncedConversation.lastMessageIndex, equals(301),
          reason: '应该使用服务器的lastMessageIndex值');

      // 验证：动态计算的未读数量应该正确
      final unreadCount = syncedConversation.unreadCount('user1');
      expect(unreadCount, equals(301), // 301 - 0 = 301
          reason: '动态计算的未读数量应该正确');

      print('✅ 会话同步测试通过:');
      print('   服务器lastMessageIndex: 301');
      print('   服务器readMessageIndex: ${user1Participant.readMessageIndex}');
      print('   计算的未读数量: $unreadCount');
    });

    test('验证Proto字段是否存在的检查', () {
      // 测试hasReadMessageIndex的具体行为
      final protoWithReadIndex = proto.ParticipantProto(
        userId: 'user1',
        name: 'User 1',
        readMessageIndex: 5,
      );

      final protoWithoutReadIndex = proto.ParticipantProto(
        userId: 'user1',
        name: 'User 1',
        // 故意不设置readMessageIndex
      );

      // 验证字段检查
      expect(protoWithReadIndex.hasReadMessageIndex(), isTrue);
      expect(protoWithoutReadIndex.hasReadMessageIndex(), isFalse);

      // 验证默认值行为
      expect(protoWithReadIndex.readMessageIndex, equals(5));
      expect(protoWithoutReadIndex.readMessageIndex, equals(0)); // Proto默认值

      print('✅ Proto字段检查测试通过');
      print(
          '   有readMessageIndex: ${protoWithReadIndex.hasReadMessageIndex()}');
      print(
          '   无readMessageIndex: ${protoWithoutReadIndex.hasReadMessageIndex()}');
    });
  });
}
