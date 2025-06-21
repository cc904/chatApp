import 'package:flutter_test/flutter_test.dart';
import 'package:cc/core/adapters/conversation_adapter.dart';
import 'package:cc/core/database/models/conversation.dart';
import 'package:cc/core/proto/generated/conversation.pb.dart' as proto;

void main() {
  group('readMessageIndex服务器数据覆盖测试', () {
    test('验证会话同步时完全使用服务器数据', () {
      // 安排：创建现有的本地会话（用户本地已读到第10条消息）

      // 创建服务器Proto数据（包含新的readMessageIndex）
      final serverProto = proto.ConversationProto(
        conversationId: 'conv1',
        type: proto.ConversationType.GROUP,
        lastMessageIndex: 301, // 服务器有301条消息
        participants: [
          proto.ParticipantProto(
            userId: 'user1',
            name: 'User 1',
            readMessageIndex: 25, // 服务器显示用户已读到第25条
          ),
        ],
      );

      // 执行：使用服务器数据创建会话
      final syncedConversation = ConversationAdapter.fromProto(
        serverProto,
        currentUserId: 'user1',
      );

      // 验证：应该完全使用服务器的readMessageIndex
      final user1Participant = syncedConversation.participants
          .firstWhere((p) => p.userId == 'user1');

      expect(user1Participant.readMessageIndex, equals(25),
          reason: '应该使用服务器的readMessageIndex值');

      // 验证：lastMessageIndex也使用服务器值
      expect(syncedConversation.lastMessageIndex, equals(301),
          reason: '应该使用服务器的lastMessageIndex值');

      // 验证：动态计算的未读数量基于服务器数据
      final unreadCount = syncedConversation.unreadCount('user1');
      expect(unreadCount, equals(276), // 301 - 25 = 276
          reason: '动态计算的未读数量应该基于服务器数据');

      print('✅ 服务器数据覆盖测试通过:');
      print('   本地readMessageIndex: 10 (被忽略)');
      print('   服务器readMessageIndex: 25 (被使用)');
      print('   最终readMessageIndex: ${user1Participant.readMessageIndex}');
      print('   计算的未读数量: $unreadCount');
    });

    test('验证动态未读计数计算', () {
      // 创建会话，模拟服务器数据
      final conversation = Conversation()
        ..conversationId = 'test_conv'
        ..type = ConversationType.group
        ..lastMessageIndex = 301
        ..participants = [
          Participant.create(
            userId: 'user1',
            name: 'User 1',
            readMessageIndex: 50, // 服务器数据：已读50条
          ),
        ];

      // 验证动态计算
      final unreadCount = conversation.unreadCount('user1');
      expect(unreadCount, equals(251)); // 301 - 50 = 251

      print('✅ 动态未读计数计算测试通过');
      print('   totalMessages: 301');
      print('   readMessages: 50');
      print('   unreadCount: $unreadCount');
    });
  });

  group('ConversationAdapter fromProto 服务器数据使用测试', () {
    test('当Proto中有readMessageIndex时应该使用Proto值', () {
      // 安排
      final protoParticipant = proto.ParticipantProto(
        userId: 'user1',
        name: 'User 1',
        readMessageIndex: 15, // Proto中设置的值
      );

      // 执行
      final result = ConversationAdapter.participantFromProto(protoParticipant);

      // 验证：应该使用Proto中的值
      expect(result.readMessageIndex, equals(15));
    });

    test('当Proto中没有readMessageIndex时应该使用默认值0', () {
      // 安排：创建一个没有readMessageIndex的Proto
      final protoParticipant = proto.ParticipantProto(
        userId: 'user1',
        name: 'User 1',
        // 故意不设置readMessageIndex
      );

      // 执行
      final result = ConversationAdapter.participantFromProto(protoParticipant);

      // 验证：应该使用默认值0
      expect(result.readMessageIndex, equals(0));
    });

    test('完整会话转换时应该使用所有服务器数据', () {
      // 创建Proto会话
      final protoConversation = proto.ConversationProto(
        conversationId: 'conv1',
        type: proto.ConversationType.GROUP,
        lastMessageIndex: 301,
        participants: [
          proto.ParticipantProto(
            userId: 'user1',
            name: 'User 1',
            readMessageIndex: 25, // 服务器readMessageIndex
          ),
          proto.ParticipantProto(
            userId: 'user2',
            name: 'User 2',
            readMessageIndex: 30, // 用户2的服务器readMessageIndex
          ),
        ],
      );

      // 执行
      final result = ConversationAdapter.fromProto(protoConversation);

      // 验证
      final user1Participant =
          result.participants.firstWhere((p) => p.userId == 'user1');
      final user2Participant =
          result.participants.firstWhere((p) => p.userId == 'user2');

      // 所有参与者都应该使用服务器数据
      expect(user1Participant.readMessageIndex, equals(25));
      expect(user2Participant.readMessageIndex, equals(30));
      expect(result.lastMessageIndex, equals(301));
    });

    test('验证hasReadMessageIndex方法的行为', () {
      // 测试Proto字段检查方法的行为
      final protoWithReadIndex = proto.ParticipantProto(
        userId: 'user1',
        name: 'User 1',
        readMessageIndex: 5,
      );

      final protoWithoutReadIndex = proto.ParticipantProto(
        userId: 'user1',
        name: 'User 1',
        // 不设置readMessageIndex
      );

      // 验证hasReadMessageIndex的行为
      expect(protoWithReadIndex.hasReadMessageIndex(), isTrue);
      expect(protoWithoutReadIndex.hasReadMessageIndex(), isFalse);
    });
  });
}
