import 'package:fixnum/fixnum.dart';
import 'package:cc/core/database/drift_database.dart';
import 'package:cc/core/proto/generated/conversation.pb.dart' as proto;
import 'package:cc/core/services/log_service.dart';
import 'dart:convert';
import 'package:cc/features/chat/domain/entities/participant.dart';

/// 会话数据转换适配器
///
/// 负责处理Conversation模型与Protocol Buffer之间的数据转换
/// 遵循DDD架构原则，将转换逻辑从模型中分离出来
///
/// 在新的Drift设计中，参与者信息存储为JSON字符串
class ConversationAdapter {
  /// 从 Protocol Buffer对象创建数据库对象
  ///
  /// 直接从ConversationProto对象创建Conversation实例
  /// 简化了在仓库中的数据转换逻辑
  ///
  /// [protoConv] - 原始的Protocol Buffer对象
  /// [currentUserId] - 当前用户ID，用于从参与者中提取个人设置
  /// 返回：转换后的数据库对象
  static Conversation fromProto(proto.ConversationProto protoConv, {String? currentUserId}) {
    // 将参与者Proto列表转换为通用结构（Map）后序列化（底层仍为字符串字段）
    final participantMaps = protoConv.participants.map((p) => _participantProtoToMap(p)).toList();
    final participantsData = participantMaps
        .map((m) => Participant.fromMap(m))
        .toList();

    // 提取当前用户的参与者设置（统一走解析函数，兼容 String/List）
    final currentUserParticipant = currentUserId != null ? getParticipantInfo(participantsData, currentUserId) : null;

    return Conversation(
      conversationId: protoConv.conversationId,
      type: _protoTypeToString(protoConv.type),
      name: protoConv.hasName() ? protoConv.name : null,
      avatar: protoConv.hasAvatar() ? protoConv.avatar : null,
      createdAt: protoConv.hasCreatedAt() ? DateTime.fromMillisecondsSinceEpoch(protoConv.createdAt.toInt()) : DateTime.now(),
      createdBy: protoConv.hasCreatedBy() ? protoConv.createdBy : null,
      firstMessageIndex: protoConv.hasFirstMessageIndex() ? protoConv.firstMessageIndex : 0,
      lastMessageIndex: protoConv.hasLastMessageIndex() ? protoConv.lastMessageIndex : 0,
      lastMessageTime: protoConv.hasLastMessageTime() ? DateTime.fromMillisecondsSinceEpoch(protoConv.lastMessageTime.toInt()) : null,
      lastMessagePreview: protoConv.hasLastMessagePreview() ? protoConv.lastMessagePreview : null,
      lastMessageName: protoConv.hasLastMessageName() ? protoConv.lastMessageName : null,
      participants: participantsData,
      description: protoConv.hasDescription() ? protoConv.description : null,
      requiresApproval: protoConv.hasRequiresApproval() ? protoConv.requiresApproval : false,
      // Current user's participant settings
      muted: currentUserParticipant?.muted ?? false,
      pinned: currentUserParticipant?.pinned ?? false,
      readMessageIndex: currentUserParticipant?.readMessageIndex ?? 0,
      unreadCount: _calculateUnreadCount(protoConv, currentUserParticipant?.toMap()),
      lastReadTime: null, // This will be set separately if needed
    );
  }

  /// 将数据库对象转换为Protocol Buffer对象
  ///
  /// 用于将Conversation对象转换为可序列化的Proto对象
  /// 便于网络传输和存储
  ///
  /// [conversation] - 数据库会话对象
  /// 返回：转换后的Protocol Buffer对象
  static proto.ConversationProto toProto(Conversation conversation) {
    // 解析参与者（兼容 String/List）
    final participants = _toProtoParticipants(conversation.participants);

    final protoConversation = proto.ConversationProto(
      conversationId: conversation.conversationId,
      type: _stringToProtoType(conversation.type),
      name: conversation.name,
      avatar: conversation.avatar,
      description: conversation.description,
      lastMessagePreview: conversation.lastMessagePreview,
      lastMessageTime: conversation.lastMessageTime != null ? Int64(conversation.lastMessageTime!.millisecondsSinceEpoch) : null,
      firstMessageIndex: conversation.firstMessageIndex,
      lastMessageIndex: conversation.lastMessageIndex,
      createdAt: Int64(conversation.createdAt.millisecondsSinceEpoch),
      lastMessageName: conversation.lastMessageName,
      createdBy: conversation.createdBy,
      requiresApproval: conversation.requiresApproval,
    );

    // 设置参与者列表
    protoConversation.participants.addAll(participants);

    return protoConversation;
  }

  /// 将ParticipantProto转换为Map（用于JSON存储）
  static Map<String, dynamic> _participantProtoToMap(proto.ParticipantProto participant) {
    return {
      'userId': participant.userId,
      'name': participant.name,
      'avatar': participant.hasAvatar() ? participant.avatar : null,
      'role': participant.hasRole() ? _memberRoleToInt(participant.role) : 0,
      'joinedAt': participant.hasJoinedAt() ? participant.joinedAt.toInt() : null,
      'addedBy': participant.hasAddedBy() ? participant.addedBy : null,
      'muted': participant.hasMuted() ? participant.muted : false,
      'pinned': participant.hasPinned() ? participant.pinned : false,
      'online': participant.hasOnline() ? participant.online : false,
      'isActive': participant.hasIsActive() ? participant.isActive : true,
      'deliveredMessageIndex': participant.hasDeliveredMessageIndex() ? participant.deliveredMessageIndex : 0,
      'readMessageIndex': participant.hasReadMessageIndex() ? participant.readMessageIndex : 0,
      'roleId': participant.hasRoleId() ? participant.roleId : 2,
    };
  }

  /// 从Map创建ParticipantProto
  static proto.ParticipantProto _mapToParticipantProto(Map<String, dynamic> map) {
    // 兼容蛇形 -> 驼峰
    final readMessageIndex = (map['readMessageIndex'] as int?) ?? (map['read_message_index'] as int? ?? 0);
    final deliveredMessageIndex = (map['deliveredMessageIndex'] as int?) ?? (map['delivered_message_index'] as int? ?? 0);
    final joinedAt = (map['joinedAt'] as int?) ?? (map['joined_at'] as int?);
    final addedBy = (map['addedBy'] as String?) ?? (map['added_by'] as String?);
    final isActive = (map['isActive'] as bool?) ?? (map['is_active'] as bool? ?? true);

    return proto.ParticipantProto(
      userId: map['userId'] as String,
      name: map['name'] as String,
      avatar: map['avatar'] as String?,
      role: _intToMemberRole(map['role'] as int? ?? 0),
      joinedAt: joinedAt != null ? Int64(joinedAt) : null,
      addedBy: addedBy,
      muted: map['muted'] as bool? ?? false,
      pinned: map['pinned'] as bool? ?? false,
      online: map['online'] as bool? ?? false,
      isActive: isActive,
      deliveredMessageIndex: deliveredMessageIndex,
      readMessageIndex: readMessageIndex,
      roleId: map['roleId'] as int? ?? 2,
    );
  }

  /// 将整数转换为MemberRole枚举
  static proto.MemberRole _intToMemberRole(int roleValue) {
    switch (roleValue) {
      case 0:
        return proto.MemberRole.MEMBER;
      case 1:
        return proto.MemberRole.ADMIN;
      case 2:
        return proto.MemberRole.OWNER;
      default:
        return proto.MemberRole.MEMBER;
    }
  }

  /// 将MemberRole枚举转换为整数
  static int _memberRoleToInt(proto.MemberRole role) {
    switch (role) {
      case proto.MemberRole.MEMBER:
        return 0;
      case proto.MemberRole.ADMIN:
        return 1;
      case proto.MemberRole.OWNER:
        return 2;
      default:
        return 0;
    }
  }

  /// 将通用 participants 解析为 Proto 列表
  static List<proto.ParticipantProto> _toProtoParticipants(dynamic participants) {
    final list = parseParticipants(participants);
    return list.map((p) => _mapToParticipantProto(p.toMap())).toList();
  }

  /// 将Proto会话类型转换为字符串
  static String _protoTypeToString(proto.ConversationType type) {
    switch (type) {
      case proto.ConversationType.PRIVATE:
        return 'PRIVATE';
      case proto.ConversationType.GROUP:
        return 'GROUP';
      case proto.ConversationType.CHANNEL:
        return 'CHANNEL';
      default:
        return 'PRIVATE';
    }
  }

  /// 将字符串转换为Proto会话类型
  static proto.ConversationType _stringToProtoType(String type) {
    switch (type) {
      case 'PRIVATE':
        return proto.ConversationType.PRIVATE;
      case 'GROUP':
        return proto.ConversationType.GROUP;
      case 'CHANNEL':
        return proto.ConversationType.CHANNEL;
      default:
        return proto.ConversationType.PRIVATE;
    }
  }

  /// 批量转换：从Proto列表转换为Conversation列表
  ///
  /// [protoList] - Proto对象列表
  /// [currentUserId] - 当前用户ID
  static List<Conversation> fromProtoList(List<proto.ConversationProto> protoList, {String? currentUserId}) {
    return protoList.map((proto) => fromProto(proto, currentUserId: currentUserId)).toList();
  }

  /// 批量转换：从Conversation列表转换为Proto列表
  static List<proto.ConversationProto> toProtoList(List<Conversation> conversations) {
    return conversations.map((conversation) => toProto(conversation)).toList();
  }

  /// 将Proto枚举类型转换为字符串类型
  static String conversationTypeToString(proto.ConversationType type) {
    return _protoTypeToString(type);
  }

  /// 将字符串类型转换为Proto枚举类型
  static proto.ConversationType stringToConversationType(String type) {
    return _stringToProtoType(type);
  }

  /// 从参与者中提取特定用户的信息（支持 String/List）
  static Participant? getParticipantInfo(dynamic participants, String userId) {
    final list = parseParticipants(participants);
    for (final p in list) {
      if (p.userId == userId) return p;
    }
    return null;
  }

  /// 解析参与者为 List<Participant>
  /// - String: 按 JSON 解码
  /// - List<Participant>: 直接返回
  /// - List<Map<String,dynamic>>: 转换为 Participant 列表
  static List<Participant> parseParticipants(dynamic participants) {
    if (participants is List<Participant>) return participants;
    if (participants is String) {
      try {
        final decoded = jsonDecode(participants);
        if (decoded is List) {
          return decoded
              .whereType<Map<String, dynamic>>()
              .map((m) => Participant.fromMap(m))
              .toList();
        }
      } catch (_) {}
      return const [];
    }
    if (participants is List) {
      return participants
          .whereType<Map<String, dynamic>>()
          .map((m) => Participant.fromMap(m))
          .toList();
    }
    return const [];
  }

  /// 检查用户是否在会话中
  ///
  /// [participantsJson] - 参与者JSON字符串
  /// [userId] - 用户ID
  /// 返回：如果用户在会话中返回true，否则返回false
  static bool isUserInConversation(dynamic participants, String userId) {
    final participantInfo = getParticipantInfo(participants, userId);
    return participantInfo != null;
  }

  /// 获取用户在会话中的角色
  ///
  /// [participantsJson] - 参与者JSON字符串
  /// [userId] - 用户ID
  /// 返回：用户角色（0=MEMBER, 1=ADMIN, 2=OWNER），如果用户不在会话中返回null
  static int? getUserRole(dynamic participants, String userId) {
    final participantInfo = getParticipantInfo(participants, userId);
    return participantInfo?.role;
  }

  /// 检查用户是否已读到指定消息
  ///
  /// [participantsJson] - 参与者JSON字符串
  /// [userId] - 用户ID
  /// [messageIndex] - 消息索引
  /// 返回：如果用户已读到该消息返回true，否则返回false
  static bool hasUserReadMessage(dynamic participants, String userId, int messageIndex) {
    final participantInfo = getParticipantInfo(participants, userId);
    if (participantInfo == null) return false;
    return participantInfo.readMessageIndex >= messageIndex;
  }

  /// 计算用户的未读消息数量
  ///
  /// [protoConv] - 会话Proto对象
  /// [currentUserParticipant] - 当前用户的参与者信息
  /// 返回：未读消息数量
  static int _calculateUnreadCount(proto.ConversationProto protoConv, Map<String, dynamic>? currentUserParticipant) {
    if (currentUserParticipant == null) return 0;

    final lastMessageIndex = protoConv.hasLastMessageIndex() ? protoConv.lastMessageIndex : 0;
    final readMessageIndex = currentUserParticipant['readMessageIndex'] as int? ?? 0;

    return (lastMessageIndex - readMessageIndex).clamp(0, double.infinity).toInt();
  }

  /// 获取会话头像应该显示的用户的roleId
  ///
  /// [participantsJson] - 参与者JSON字符串
  /// [conversationType] - 会话类型
  /// [currentUserId] - 当前用户ID
  /// 返回：应该显示的用户roleId，私聊返回对方roleId，群聊返回null
  static int? getDisplayRoleId(dynamic participants, String conversationType, String currentUserId) {
    final _logger = LogService.instance;

    try {
      // 只有私聊才显示对方的roleId
      if (conversationType != 'PRIVATE') {
        return null;
      }

      final list = parseParticipants(participants);
      final other = list.firstWhere(
        (p) => p.userId != currentUserId,
        orElse: () => const Participant(
          userId: '', name: '', role: 0, muted: false, pinned: false, online: false, isActive: true, deliveredMessageIndex: 0, readMessageIndex: 0, roleId: 2,
        ),
      );
      if (other.userId.isNotEmpty) return other.roleId;

      return null;
    } catch (e) {
      _logger.e('获取显示RoleId失败', error: e);
      return null;
    }
  }

  /// 获取私聊对方的名称
  ///
  /// [participantsJson] - 参与者JSON字符串
  /// [conversationType] - 会话类型
  /// [currentUserId] - 当前用户ID
  /// 返回：私聊对方的名称，如果不是私聊或找不到对方则返回null
  static String? getPrivateChatPartnerName(dynamic participants, String conversationType, String currentUserId) {
    final _logger = LogService.instance;

    try {
      // 只有私聊才获取对方名称
      if (conversationType != 'PRIVATE') {
        return null;
      }

      final list = parseParticipants(participants);
      final other = list.firstWhere(
        (p) => p.userId != currentUserId,
        orElse: () => const Participant(
          userId: '', name: '', role: 0, muted: false, pinned: false, online: false, isActive: true, deliveredMessageIndex: 0, readMessageIndex: 0, roleId: 2,
        ),
      );
      if (other.userId.isNotEmpty) return other.name;

      return null;
    } catch (e) {
      _logger.e('获取私聊对方名称失败', error: e);
      return null;
    }
  }
}
