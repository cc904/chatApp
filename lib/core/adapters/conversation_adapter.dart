import 'package:fixnum/fixnum.dart';
import 'package:cc/core/database/models/conversation.dart';
import 'package:cc/core/proto/generated/conversation.pb.dart' as proto;

/// 会话数据转换适配器
///
/// 负责处理Conversation模型与Protocol Buffer之间的数据转换
/// 遵循DDD架构原则，将转换逻辑从模型中分离出来
class ConversationAdapter {
  /// 从 Protocol Buffer对象创建数据库对象
  ///
  /// 直接从ConversationProto对象创建Conversation实例
  /// 简化了在仓库中的数据转换逻辑
  ///
  /// [protoConv] - 原始的Protocol Buffer对象
  /// 返回：转换后的数据库对象
  static Conversation fromProto(proto.ConversationProto protoConv) {
    // 确定会话类型
    final protoType = protoConv.type;
    ConversationType convType;

    switch (protoType.value) {
      case 0:
        convType = ConversationType.private;
        break;
      case 1:
        convType = ConversationType.group;
        break;
      case 2:
        convType = ConversationType.channel;
        break;
      default:
        convType = ConversationType.private;
    }

    final conversation = Conversation()
      ..conversationId = protoConv.conversationId
      ..type = convType
      ..name = protoConv.hasName() ? protoConv.name : null
      ..avatar = protoConv.hasAvatar() ? protoConv.avatar : null
      ..lastMessagePreview = protoConv.hasLastMessagePreview()
          ? protoConv.lastMessagePreview
          : null
      ..lastMessageTime = protoConv.hasLastMessageTime()
          ? DateTime.fromMillisecondsSinceEpoch(
              protoConv.lastMessageTime.toInt())
          : null
      ..lastMessageIndex = protoConv.hasLastMessageIndex()
          ? protoConv.lastMessageIndex.toInt()
          : null
      ..createdAt = protoConv.hasCreatedAt()
          ? DateTime.fromMillisecondsSinceEpoch(protoConv.createdAt.toInt())
          : DateTime.now()
      ..unreadCount = protoConv.hasUnreadCount() ? protoConv.unreadCount : 0
      ..contactUserId =
          protoConv.hasContactUserId() ? protoConv.contactUserId : null
      ..lastMessageId = null // 已移除lastReadMessageId字段
      ..isMuted = protoConv.hasMuted() ? protoConv.muted : false
      ..lastMessageName =
          protoConv.hasLastMessageName() ? protoConv.lastMessageName : null
      ..isPinned = protoConv.hasPinned() ? protoConv.pinned : false
      ..lastReadAtIndex = protoConv.hasLastReadAtIndex()
          ? protoConv.lastReadAtIndex.toInt()
          : null
      ..createdBy = protoConv.hasCreatedBy() ? protoConv.createdBy : null;

    return conversation;
  }

  /// 将数据库对象转换为Protocol Buffer对象
  ///
  /// 用于将Conversation对象转换为可序列化的Proto对象
  /// 便于网络传输和存储
  ///
  /// [conversation] - 数据库会话对象
  /// 返回：转换后的Protocol Buffer对象
  static proto.ConversationProto toProto(Conversation conversation) {
    proto.ConversationType protoType;

    switch (conversation.type) {
      case ConversationType.private:
        protoType = proto.ConversationType.PRIVATE;
        break;
      case ConversationType.group:
        protoType = proto.ConversationType.GROUP;
        break;
      case ConversationType.channel:
        protoType = proto.ConversationType.CHANNEL;
        break;
    }

    // 将参与者转换为ParticipantProto对象列表
    final participantProtos = <proto.ParticipantProto>[];
    for (final user in conversation.participants) {
      participantProtos.add(proto.ParticipantProto(
        userId: user.userId,
        name: user.name,
        avatar: user.avatar,
        // 注意：这里只添加了基本字段，如果需要更多字段，请根据实际情况添加
        // 例如：role、joinedAt、lastReadAt等
      ));
    }

    return proto.ConversationProto(
      conversationId: conversation.conversationId,
      type: protoType,
      name: conversation.name,
      avatar: conversation.avatar,
      lastMessagePreview: conversation.lastMessagePreview,
      lastMessageTime: conversation.lastMessageTime != null
          ? Int64(conversation.lastMessageTime!.millisecondsSinceEpoch)
          : null,
      lastMessageIndex: conversation.lastMessageIndex != null
          ? Int64(conversation.lastMessageIndex!)
          : null,
      createdAt: Int64(conversation.createdAt.millisecondsSinceEpoch),
      unreadCount: conversation.unreadCount,
      contactUserId: conversation.contactUserId,
      lastMessageName: conversation.lastMessageName,
      participants: participantProtos,
      muted: conversation.isMuted,
      pinned: conversation.isPinned,
      lastReadAtIndex: conversation.lastReadAtIndex != null
          ? Int64(conversation.lastReadAtIndex!)
          : null,
      createdBy: conversation.createdBy,
    );
  }

  /// 批量转换：从Proto列表转换为Conversation列表
  static List<Conversation> fromProtoList(
      List<proto.ConversationProto> protoList) {
    return protoList.map((proto) => fromProto(proto)).toList();
  }

  /// 批量转换：从Conversation列表转换为Proto列表
  static List<proto.ConversationProto> toProtoList(
      List<Conversation> conversations) {
    return conversations.map((conversation) => toProto(conversation)).toList();
  }

  /// 将Proto枚举类型转换为字符串类型
  static String conversationTypeToString(proto.ConversationType type) {
    switch (type) {
      case proto.ConversationType.PRIVATE:
        return 'private';
      case proto.ConversationType.GROUP:
        return 'group';
      case proto.ConversationType.CHANNEL:
        return 'channel';
      default:
        return 'private';
    }
  }

  /// 将字符串类型转换为Proto枚举类型
  static proto.ConversationType stringToConversationType(String type) {
    switch (type.toLowerCase()) {
      case 'private':
        return proto.ConversationType.PRIVATE;
      case 'group':
        return proto.ConversationType.GROUP;
      case 'channel':
        return proto.ConversationType.CHANNEL;
      default:
        return proto.ConversationType.PRIVATE;
    }
  }

  /// 将本地枚举转换为Proto枚举
  static proto.ConversationType localTypeToProto(ConversationType type) {
    switch (type) {
      case ConversationType.private:
        return proto.ConversationType.PRIVATE;
      case ConversationType.group:
        return proto.ConversationType.GROUP;
      case ConversationType.channel:
        return proto.ConversationType.CHANNEL;
    }
  }

  /// 将Proto枚举转换为本地枚举
  static ConversationType protoTypeToLocal(proto.ConversationType type) {
    switch (type) {
      case proto.ConversationType.PRIVATE:
        return ConversationType.private;
      case proto.ConversationType.GROUP:
        return ConversationType.group;
      case proto.ConversationType.CHANNEL:
        return ConversationType.channel;
      default:
        return ConversationType.private;
    }
  }
}
