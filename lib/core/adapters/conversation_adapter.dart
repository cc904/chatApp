import 'package:fixnum/fixnum.dart';
import 'package:cc/core/database/drift_database.dart';
import 'package:cc/core/proto/generated/conversation.pb.dart' as proto;
import 'package:cc/core/services/log_service.dart';
import 'dart:convert';

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
  static Conversation fromProto(proto.ConversationProto protoConv,
      {String? currentUserId}) {
    
    final _logger = LogService.instance;
    
    // 🔥🔥🔥 详细记录参与者转换过程
    _logger.i('🔄🔄🔄 ConversationAdapter.fromProto开始转换', extra: {
      'conversationId': protoConv.conversationId,
      'type': protoConv.type.toString(),
      'currentUserId': currentUserId,
      'participantsCount': protoConv.participants.length,
    });
    
    // 将参与者Proto列表转换为JSON字符串
    final participantMaps = protoConv.participants.map((p) {
      final participantMap = _participantProtoToMap(p);
      _logger.i('👤👤👤 参与者Proto转Map', extra: {
        'userId': p.userId,
        'name': p.name,
        'hasRole': p.hasRole(),
        'role': p.hasRole() ? p.role.value : 0,
        'participantMap': participantMap,
      });
      return participantMap;
    }).toList();
    
    final participantsJson = jsonEncode(participantMaps);
    
    _logger.i('📝📝📝 参与者JSON生成完成', extra: {
      'participantsJson': participantsJson,
    });
    
    // Extract current user's participant settings
    final currentUserParticipant = currentUserId != null 
        ? getParticipantInfo(participantsJson, currentUserId)
        : null;
    
    return Conversation(
      conversationId: protoConv.conversationId,
      type: _protoTypeToString(protoConv.type),
      name: protoConv.hasName() ? protoConv.name : null,
      avatar: protoConv.hasAvatar() ? protoConv.avatar : null,
      createdAt: protoConv.hasCreatedAt()
          ? DateTime.fromMillisecondsSinceEpoch(protoConv.createdAt.toInt())
          : DateTime.now(),
      createdBy: protoConv.hasCreatedBy() ? protoConv.createdBy : null,
      firstMessageIndex: protoConv.hasFirstMessageIndex() ? protoConv.firstMessageIndex : 0,
      lastMessageIndex: protoConv.hasLastMessageIndex() ? protoConv.lastMessageIndex : 0,
      lastMessageTime: protoConv.hasLastMessageTime() ? DateTime.fromMillisecondsSinceEpoch(protoConv.lastMessageTime.toInt()) : null,
      lastMessagePreview: protoConv.hasLastMessagePreview() ? protoConv.lastMessagePreview : null,
      lastMessageName: protoConv.hasLastMessageName() ? protoConv.lastMessageName : null,
      participants: participantsJson,
      description: protoConv.hasDescription() ? protoConv.description : null,
      requiresApproval: protoConv.hasRequiresApproval() ? protoConv.requiresApproval : false,
      // Current user's participant settings
      muted: currentUserParticipant?['muted'] as bool? ?? false,
      pinned: currentUserParticipant?['pinned'] as bool? ?? false,
      readMessageIndex: currentUserParticipant?['read_message_index'] as int? ?? 0,
      unreadCount: _calculateUnreadCount(protoConv, currentUserParticipant),
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
    // 从JSON字符串解析参与者列表
    final participants = _parseParticipantsFromJson(conversation.participants);
    
    final protoConversation = proto.ConversationProto(
      conversationId: conversation.conversationId,
      type: _stringToProtoType(conversation.type),
      name: conversation.name,
      avatar: conversation.avatar,
      description: conversation.description,
      lastMessagePreview: conversation.lastMessagePreview,
      lastMessageTime: conversation.lastMessageTime != null
          ? Int64(conversation.lastMessageTime!.millisecondsSinceEpoch)
          : null,
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
      'user_id': participant.userId,
      'name': participant.name,
      'avatar': participant.hasAvatar() ? participant.avatar : null,
      'role': participant.role.value,
      'joined_at': participant.hasJoinedAt() ? participant.joinedAt.toInt() : null,
      'added_by': participant.hasAddedBy() ? participant.addedBy : null,
      'muted': participant.hasMuted() ? participant.muted : false,
      'pinned': participant.hasPinned() ? participant.pinned : false,
      'online': participant.hasOnline() ? participant.online : false,
      'is_active': participant.hasIsActive() ? participant.isActive : true,
      'delivered_message_index': participant.hasDeliveredMessageIndex() ? participant.deliveredMessageIndex : 0,
      'read_message_index': participant.hasReadMessageIndex() ? participant.readMessageIndex : 0,
      'role_id': participant.hasRole() ? participant.role.value : 0,
    };
  }

  /// 从Map创建ParticipantProto
  static proto.ParticipantProto _mapToParticipantProto(Map<String, dynamic> map) {
    return proto.ParticipantProto(
      userId: map['user_id'] as String,
      name: map['name'] as String,
      avatar: map['avatar'] as String?,
      role: _intToMemberRole(map['role_id'] as int? ?? 0),
      joinedAt: map['joined_at'] != null ? Int64(map['joined_at'] as int) : null,
      addedBy: map['added_by'] as String?,
      muted: map['muted'] as bool? ?? false,
      pinned: map['pinned'] as bool? ?? false,
      online: map['online'] as bool? ?? false,
      isActive: map['is_active'] as bool? ?? true,
      deliveredMessageIndex: map['delivered_message_index'] as int? ?? 0,
      readMessageIndex: map['read_message_index'] as int? ?? 0,
    );
  }

  /// 将整数转换为MemberRole枚举
  static proto.MemberRole _intToMemberRole(int roleId) {
    switch (roleId) {
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

  /// 从JSON字符串解析参与者列表
  static List<proto.ParticipantProto> _parseParticipantsFromJson(String participantsJson) {
    try {
      final List<dynamic> participantsList = jsonDecode(participantsJson);
      return participantsList
          .cast<Map<String, dynamic>>()
          .map((map) => _mapToParticipantProto(map))
          .toList();
    } catch (e) {
      // 如果解析失败，返回空列表
      return [];
    }
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
  static List<Conversation> fromProtoList(
      List<proto.ConversationProto> protoList, {String? currentUserId}) {
    return protoList.map((proto) => fromProto(proto, currentUserId: currentUserId)).toList();
  }

  /// 批量转换：从Conversation列表转换为Proto列表
  static List<proto.ConversationProto> toProtoList(
      List<Conversation> conversations) {
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

  /// 从参与者JSON中提取特定用户的信息
  /// 
  /// [participantsJson] - 参与者JSON字符串
  /// [userId] - 用户ID
  /// 返回：用户的参与者信息，如果不存在则返回null
  static Map<String, dynamic>? getParticipantInfo(String participantsJson, String userId) {
    try {
      final List<dynamic> participantsList = jsonDecode(participantsJson);
      final participantsMap = participantsList.cast<Map<String, dynamic>>();
      
      return participantsMap.firstWhere(
        (participant) => participant['user_id'] == userId,
        orElse: () => {},
      );
    } catch (e) {
      return null;
    }
  }

  /// 检查用户是否在会话中
  /// 
  /// [participantsJson] - 参与者JSON字符串
  /// [userId] - 用户ID
  /// 返回：如果用户在会话中返回true，否则返回false
  static bool isUserInConversation(String participantsJson, String userId) {
    final participantInfo = getParticipantInfo(participantsJson, userId);
    return participantInfo != null && participantInfo.isNotEmpty;
  }

  /// 获取用户在会话中的角色
  /// 
  /// [participantsJson] - 参与者JSON字符串
  /// [userId] - 用户ID
  /// 返回：用户角色（0=MEMBER, 1=ADMIN, 2=OWNER），如果用户不在会话中返回null
  static int? getUserRole(String participantsJson, String userId) {
    final participantInfo = getParticipantInfo(participantsJson, userId);
    return participantInfo?['role'] as int?;
  }

  /// 检查用户是否已读到指定消息
  /// 
  /// [participantsJson] - 参与者JSON字符串
  /// [userId] - 用户ID
  /// [messageIndex] - 消息索引
  /// 返回：如果用户已读到该消息返回true，否则返回false
  static bool hasUserReadMessage(String participantsJson, String userId, int messageIndex) {
    final participantInfo = getParticipantInfo(participantsJson, userId);
    if (participantInfo == null) return false;
    
    final readMessageIndex = participantInfo['read_message_index'] as int? ?? 0;
    return readMessageIndex >= messageIndex;
  }

  /// 计算用户的未读消息数量
  /// 
  /// [protoConv] - 会话Proto对象
  /// [currentUserParticipant] - 当前用户的参与者信息
  /// 返回：未读消息数量
  static int _calculateUnreadCount(proto.ConversationProto protoConv, Map<String, dynamic>? currentUserParticipant) {
    if (currentUserParticipant == null) return 0;
    
    final lastMessageIndex = protoConv.hasLastMessageIndex() ? protoConv.lastMessageIndex : 0;
    final readMessageIndex = currentUserParticipant['read_message_index'] as int? ?? 0;
    
    return (lastMessageIndex - readMessageIndex).clamp(0, double.infinity).toInt();
  }

  /// 获取会话头像应该显示的用户的roleId
  /// 
  /// [participantsJson] - 参与者JSON字符串
  /// [conversationType] - 会话类型
  /// [currentUserId] - 当前用户ID
  /// 返回：应该显示的用户roleId，私聊返回对方roleId，群聊返回null
  static int? getDisplayRoleId(String participantsJson, String conversationType, String currentUserId) {
    final _logger = LogService.instance;
    
    try {
      _logger.i('💬💬💬 ConversationAdapter获取显示RoleId', extra: {
        'conversationType': conversationType,
        'currentUserId': currentUserId,
        'participantsJsonLength': participantsJson.length,
        'participantsJson': participantsJson,
      });
      
      // 只有私聊才显示对方的roleId
      if (conversationType != 'PRIVATE') {
        _logger.i('非私聊会话，不显示roleId', extra: {'type': conversationType});
        return null;
      }

      final List<dynamic> participantsList = jsonDecode(participantsJson);
      final participantsMap = participantsList.cast<Map<String, dynamic>>();
      
      _logger.i('解析参与者列表', extra: {
        'participantsCount': participantsMap.length,
        'participants': participantsMap,
      });
      
      // 在私聊中找到对方用户的roleId
      for (final participant in participantsMap) {
        final userId = participant['user_id'] as String?;
        final roleId = participant['role_id'] as int? ?? 0;
        final userName = participant['name'] as String? ?? 'Unknown';
        
        _logger.i('检查参与者', extra: {
          'userId': userId,
          'userName': userName,
          'roleId': roleId,
          'isCurrentUser': userId == currentUserId,
        });
        
        if (userId != null && userId != currentUserId) {
          _logger.i('🎯🎯🎯 找到对方用户，返回roleId', extra: {
            'otherUserId': userId,
            'otherUserName': userName,
            'otherUserRoleId': roleId,
          });
          return roleId;
        }
      }
      
      _logger.w('未找到对方用户');
      return null;
    } catch (e) {
      _logger.e('获取显示RoleId失败', error: e);
      return null;
    }
  }
}