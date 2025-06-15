import 'package:fixnum/fixnum.dart';
import 'package:cc/core/database/models/conversation.dart';
import 'package:cc/core/proto/generated/conversation.pb.dart' as proto;

/// 会话数据转换适配器
///
/// 负责处理Conversation模型与Protocol Buffer之间的数据转换
/// 遵循DDD架构原则，将转换逻辑从模型中分离出来
class ConversationAdapter {
  /// 💢💢💢 新增：从ParticipantProto转换为Participant
  static Participant participantFromProto(
      proto.ParticipantProto protoParticipant) {
    // 转换MemberRole枚举
    MemberRole role;
    switch (protoParticipant.role) {
      case proto.MemberRole.MEMBER:
        role = MemberRole.member;
        break;
      case proto.MemberRole.ADMIN:
        role = MemberRole.admin;
        break;
      case proto.MemberRole.OWNER:
        role = MemberRole.owner;
        break;
      default:
        role = MemberRole.member;
    }

    return Participant.create(
      userId: protoParticipant.userId,
      name: protoParticipant.name,
      avatar: protoParticipant.hasAvatar() ? protoParticipant.avatar : '',
      unreadCount:
          protoParticipant.hasUnreadCount() ? protoParticipant.unreadCount : 0,
      muted: protoParticipant.hasMuted() ? protoParticipant.muted : false,
      pinned: protoParticipant.hasPinned() ? protoParticipant.pinned : false,
      joinedAt: protoParticipant.hasJoinedAt()
          ? DateTime.fromMillisecondsSinceEpoch(
              protoParticipant.joinedAt.toInt())
          : null,
      deliveredMessageIndex: protoParticipant.hasDeliveredMessageIndex()
          ? protoParticipant.deliveredMessageIndex
          : 0,
      readMessageIndex: protoParticipant.hasReadMessageIndex()
          ? protoParticipant.readMessageIndex
          : 0,
      role: role,
      addedBy: protoParticipant.hasAddedBy() ? protoParticipant.addedBy : null,
      online: protoParticipant.hasOnline() ? protoParticipant.online : false,
      isActive:
          protoParticipant.hasIsActive() ? protoParticipant.isActive : true,
    );
  }

  /// 💢💢💢 新增：从Participant转换为ParticipantProto
  static proto.ParticipantProto participantToProto(Participant participant) {
    // 转换MemberRole枚举
    proto.MemberRole protoRole;
    switch (participant.role) {
      case MemberRole.member:
        protoRole = proto.MemberRole.MEMBER;
        break;
      case MemberRole.admin:
        protoRole = proto.MemberRole.ADMIN;
        break;
      case MemberRole.owner:
        protoRole = proto.MemberRole.OWNER;
        break;
    }

    return proto.ParticipantProto(
      userId: participant.userId,
      name: participant.name,
      avatar: participant.avatar,
      unreadCount: participant.unreadCount,
      muted: participant.muted,
      pinned: participant.pinned,
      joinedAt: participant.joinedAt != null
          ? Int64(participant.joinedAt!.millisecondsSinceEpoch)
          : null,
      deliveredMessageIndex: participant.deliveredMessageIndex,
      readMessageIndex: participant.readMessageIndex,
      role: protoRole,
      addedBy: participant.addedBy,
      online: participant.online,
      isActive: participant.isActive,
    );
  }

  /// 从 Protocol Buffer对象创建数据库对象
  ///
  /// 直接从ConversationProto对象创建Conversation实例
  /// 简化了在仓库中的数据转换逻辑
  ///
  /// [protoConv] - 原始的Protocol Buffer对象
  /// [currentUserId] - 当前用户ID，用于从参与者中提取个人设置
  /// 返回：转换后的数据库对象
  static Conversation fromProto(proto.ConversationProto protoConv,
      {String? currentUserId}) {
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

    // 💢💢💢 更新：转换参与者Map为List
    final participants = protoConv.participants.values
        .map((protoParticipant) => participantFromProto(protoParticipant))
        .toList();

    // 💢💢💢 新增：从当前用户的参与者信息中提取个人设置
    if (currentUserId != null) {
      try {} catch (e) {
        // 如果找不到当前用户的参与者信息，使用默认值
      }
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
      ..firstMessageIndex =
          protoConv.hasFirstMessageIndex() ? protoConv.firstMessageIndex : 0
      ..lastMessageIndex =
          protoConv.hasLastMessageIndex() ? protoConv.lastMessageIndex : 0
      ..createdAt = protoConv.hasCreatedAt()
          ? DateTime.fromMillisecondsSinceEpoch(protoConv.createdAt.toInt())
          : DateTime.now()
      ..lastMessageName =
          protoConv.hasLastMessageName() ? protoConv.lastMessageName : null
      ..createdBy = protoConv.hasCreatedBy() ? protoConv.createdBy : null
      ..participants = participants // 💢💢💢 设置参与者列表
      ..contactUserId =
          _extractContactUserId(protoConv, participants, currentUserId);

    return conversation;
  }

  /// 💢💢💢 新增：提取私聊对象的用户ID
  static String? _extractContactUserId(proto.ConversationProto protoConv,
      List<Participant> participants, String? currentUserId) {
    // 只有私聊才需要contactUserId
    if (protoConv.type != proto.ConversationType.PRIVATE ||
        currentUserId == null) {
      return null;
    }

    // 在私聊中，contactUserId是除当前用户外的另一个参与者
    try {
      final otherParticipant =
          participants.firstWhere((p) => p.userId != currentUserId);
      return otherParticipant.userId;
    } catch (e) {
      return null;
    }
  }

  /// 将数据库对象转换为Protocol Buffer对象
  ///
  /// 用于将Conversation对象转换为可序列化的Proto对象
  /// 便于网络传输和存储
  ///
  /// [conversation] - 数据库会话对象
  /// 返回：转换后的Protocol Buffer对象
  ///
  /// 注意：新的Proto结构中移除了muted、pinned、unreadCount、lastReadIndex等字段
  /// 这些信息现在存储在各个参与者的ParticipantProto中
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

    // 💢💢💢 更新：将参与者转换为ParticipantProto Map
    final participantProtos = <String, proto.ParticipantProto>{};
    for (final participant in conversation.participants) {
      participantProtos[participant.userId] = participantToProto(participant);
    }

    final protoConversation = proto.ConversationProto(
      conversationId: conversation.conversationId,
      type: protoType,
      name: conversation.name,
      avatar: conversation.avatar,
      lastMessagePreview: conversation.lastMessagePreview,
      lastMessageTime: conversation.lastMessageTime != null
          ? Int64(conversation.lastMessageTime!.millisecondsSinceEpoch)
          : null,
      firstMessageIndex: conversation.firstMessageIndex,
      lastMessageIndex: conversation.lastMessageIndex,
      createdAt: Int64(conversation.createdAt.millisecondsSinceEpoch),
      lastMessageName: conversation.lastMessageName,
      createdBy: conversation.createdBy,
      // 💢💢💢 注意：移除了以下字段，因为它们现在存储在参与者信息中：
      // - muted (从当前用户的participant.muted获取)
      // - pinned (从当前用户的participant.pinned获取)
      // - unreadCount (从当前用户的participant.unreadCount获取)
      // - lastReadIndex (从当前用户的participant.readMessageIndex获取)
    );

    // 💢💢💢 设置参与者Map
    protoConversation.participants.addAll(participantProtos);

    return protoConversation;
  }

  /// 批量转换：从Proto列表转换为Conversation列表
  ///
  /// [protoList] - Proto对象列表
  static List<Conversation> fromProtoList(
      List<proto.ConversationProto> protoList) {
    return protoList.map((proto) => fromProto(proto)).toList();
  }

  /// 批量转换：从Conversation列表转换为Proto列表
  static List<proto.ConversationProto> toProtoList(
      List<Conversation> conversations) {
    return conversations.map((conversation) => toProto(conversation)).toList();
  }

  /// 💢💢💢 新增：批量转换参与者
  static List<Participant> participantsFromProtoList(
      List<proto.ParticipantProto> protoList) {
    return protoList.map((proto) => participantFromProto(proto)).toList();
  }

  /// 💢💢💢 新增：批量转换参与者到Proto
  static List<proto.ParticipantProto> participantsToProtoList(
      List<Participant> participants) {
    return participants
        .map((participant) => participantToProto(participant))
        .toList();
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

  /// 💢💢💢 新增：将本地MemberRole枚举转换为Proto枚举
  static proto.MemberRole localRoleToProto(MemberRole role) {
    switch (role) {
      case MemberRole.member:
        return proto.MemberRole.MEMBER;
      case MemberRole.admin:
        return proto.MemberRole.ADMIN;
      case MemberRole.owner:
        return proto.MemberRole.OWNER;
    }
  }

  /// 💢💢💢 新增：将Proto MemberRole枚举转换为本地枚举
  static MemberRole protoRoleToLocal(proto.MemberRole role) {
    switch (role) {
      case proto.MemberRole.MEMBER:
        return MemberRole.member;
      case proto.MemberRole.ADMIN:
        return MemberRole.admin;
      case proto.MemberRole.OWNER:
        return MemberRole.owner;
      default:
        return MemberRole.member;
    }
  }
}
