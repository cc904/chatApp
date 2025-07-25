import 'dart:convert';
import 'package:fixnum/fixnum.dart';
import 'package:cc/core/proto/generated/message.pb.dart' as message_proto;
import 'package:cc/core/database/drift_database.dart';

/// 🚀 消息适配器 - 支持Index-based同步的转换器 (Drift版本)
///
/// 负责在Protocol Buffer消息和Drift数据库消息之间进行转换。
/// 新版本重点支持messageIndex字段，用于替代复杂的时间戳游标系统。
/// 
/// 在新的Drift设计中，消息内容存储为JSON字符串，支持proto的oneof content结构
///
/// ## 🎯 核心功能
/// 1. **Proto ↔ Database 转换**：双向转换消息对象
/// 2. **Index字段处理**：正确处理服务器分配的消息序列号
/// 3. **JSON内容处理**：支持proto的oneof content结构存储为JSON
///
/// ## 🔥 数据存储方式
/// ```dart
/// // 消息内容存储示例
/// message.content = jsonEncode({
///   'text_message': {'text': 'Hello World', 'mentions': []},
///   // 或
///   'media_message': {'media_url': 'url', 'file_size': 1024},
///   // 或
///   'system_message': {'text': 'User joined', 'event_type': 'MEMBER_JOINED'}
/// });
/// ```
class MessageAdapter {
  /// 从 Protocol Buffer对象创建数据库对象
  ///
  /// 直接从MessageProto对象创建Message实例
  ///
  /// [proto] - 原始的Protocol Buffer对象
  /// 返回：转换后的数据库对象
  static Message fromProto(message_proto.MessageProto protoMessage) {
    
    // 将oneof content结构转换为JSON存储
    final contentJson = _extractContentToJson(protoMessage);
    
    return Message(
      messageId: protoMessage.messageId,
      conversationId: protoMessage.conversationId,
      senderId: protoMessage.senderId,
      senderName: protoMessage.hasSenderName() ? protoMessage.senderName : null,
      senderAvatar: protoMessage.hasSenderAvatar() ? protoMessage.senderAvatar : null,
      createdAt: protoMessage.hasCreatedAt() 
          ? DateTime.fromMillisecondsSinceEpoch(protoMessage.createdAt.toInt())
          : DateTime.now(),
      updatedAt: protoMessage.hasUpdatedAt() 
          ? DateTime.fromMillisecondsSinceEpoch(protoMessage.updatedAt.toInt())
          : null,
      messageIndex: protoMessage.hasIndex() ? protoMessage.index.toInt() : 0,
      messageType: _protoTypeToString(protoMessage.type),
      messageStatus: _protoStatusToString(protoMessage.status),
      quotedMessageId: protoMessage.hasQuotedMessageId() 
          ? protoMessage.quotedMessageId 
          : null,
      repliedToMessageId: protoMessage.hasRepliedToMessageId()
          ? protoMessage.repliedToMessageId
          : null,
      forwardedFromConversationId: protoMessage.hasForwardedFromConversationId()
          ? protoMessage.forwardedFromConversationId
          : null,
      forwardedFromMessageId: protoMessage.hasForwardedFromMessageId()
          ? protoMessage.forwardedFromMessageId
          : null,
      isEdited: protoMessage.hasIsEdited() ? protoMessage.isEdited : false,
      editedAt: protoMessage.hasEditedAt() 
          ? DateTime.fromMillisecondsSinceEpoch(protoMessage.editedAt.toInt())
          : null,
      isPinned: protoMessage.hasIsPinned() ? protoMessage.isPinned : false,
      reactions: protoMessage.reactions.isNotEmpty 
          ? jsonEncode(protoMessage.reactions) 
          : null,
      tags: protoMessage.tags.isNotEmpty 
          ? jsonEncode(protoMessage.tags) 
          : null,
      content: contentJson,
    );
  }

  /// 从proto的oneof content中提取内容转换为JSON
  static String? _extractContentToJson(message_proto.MessageProto protoMessage) {
    Map<String, dynamic> contentMap = {};

    // 处理文本消息
    if (protoMessage.hasTextMessage()) {
      final textMessage = protoMessage.textMessage;
      contentMap['text_message'] = {
        'text': textMessage.hasText() ? textMessage.text : '',
        'mentions': textMessage.mentions.toList(),
        'hashtags': textMessage.hashtags.toList(),
        'links': textMessage.links.map((link) => {
          'url': link.hasUrl() ? link.url : '',
          'title': link.hasTitle() ? link.title : null,
          'description': link.hasDescription() ? link.description : null,
          'image_url': link.hasImageUrl() ? link.imageUrl : null,
          'site_name': link.hasSiteName() ? link.siteName : null,
          'favicon_url': link.hasFaviconUrl() ? link.faviconUrl : null,
        }).toList(),
      };
    }

    // 处理媒体消息
    if (protoMessage.hasMediaMessage()) {
      final mediaMessage = protoMessage.mediaMessage;
      contentMap['media_message'] = {
        'media_url': mediaMessage.hasMediaUrl() ? mediaMessage.mediaUrl : null,
        'local_path': mediaMessage.hasLocalPath() ? mediaMessage.localPath : null,
        'duration': mediaMessage.hasDuration() ? mediaMessage.duration : null,
        'file_size': mediaMessage.hasFileSize() ? mediaMessage.fileSize : null,
        'file_name': mediaMessage.hasFileName() ? mediaMessage.fileName : null,
        'fs_id': mediaMessage.hasFsId() ? mediaMessage.fsId : null,
        'mime_type': mediaMessage.hasMimeType() ? mediaMessage.mimeType : null,
        'width': mediaMessage.hasWidth() ? mediaMessage.width : null,
        'height': mediaMessage.hasHeight() ? mediaMessage.height : null,
        'caption': mediaMessage.hasCaption() ? mediaMessage.caption : null,
      };
    }

    // 处理系统消息
    if (protoMessage.hasSystemMessage()) {
      final systemMessage = protoMessage.systemMessage;
      contentMap['system_message'] = {
        'text': systemMessage.hasText() ? systemMessage.text : '',
        'event_type': systemMessage.hasEventType() ? systemMessage.eventType.name : null,
        'params': systemMessage.params,
        'affected_user_ids': systemMessage.affectedUserIds.toList(),
        'actor_user_id': systemMessage.hasActorUserId() ? systemMessage.actorUserId : null,
        'event_timestamp': systemMessage.hasEventTimestamp() ? systemMessage.eventTimestamp.toInt() : null,
        'metadata': systemMessage.metadata,
      };
    }

    // 处理成员变动消息
    if (protoMessage.hasMembershipMessage()) {
      final membershipMessage = protoMessage.membershipMessage;
      contentMap['membership_message'] = {
        'event_type': membershipMessage.hasEventType() ? membershipMessage.eventType.name : null,
        'actor': membershipMessage.hasActor() ? {
          'user_id': membershipMessage.actor.hasUserId() ? membershipMessage.actor.userId : null,
          'user_name': membershipMessage.actor.hasUserName() ? membershipMessage.actor.userName : null,
          'user_avatar': membershipMessage.actor.hasUserAvatar() ? membershipMessage.actor.userAvatar : null,
          'role': membershipMessage.actor.hasRole() ? membershipMessage.actor.role : null,
          'joined_at': membershipMessage.actor.hasJoinedAt() ? membershipMessage.actor.joinedAt.toInt() : null,
        } : null,
        'affected_members': membershipMessage.affectedMembers.map((member) => {
          'user_id': member.hasUserId() ? member.userId : null,
          'user_name': member.hasUserName() ? member.userName : null,
          'user_avatar': member.hasUserAvatar() ? member.userAvatar : null,
          'role': member.hasRole() ? member.role : null,
          'joined_at': member.hasJoinedAt() ? member.joinedAt.toInt() : null,
        }).toList(),
        'event_timestamp': membershipMessage.hasEventTimestamp() ? membershipMessage.eventTimestamp.toInt() : null,
        'previous_role': membershipMessage.hasPreviousRole() ? membershipMessage.previousRole : null,
        'new_role': membershipMessage.hasNewRole() ? membershipMessage.newRole : null,
        'removal_reason': membershipMessage.hasRemovalReason() ? membershipMessage.removalReason : null,
        'invite_link': membershipMessage.hasInviteLink() ? membershipMessage.inviteLink : null,
        'metadata': membershipMessage.metadata,
      };
    }

    // 处理表情包消息
    if (protoMessage.hasStickerMessage()) {
      final stickerMessage = protoMessage.stickerMessage;
      contentMap['sticker_message'] = {
        'sticker_id': stickerMessage.hasStickerId() ? stickerMessage.stickerId : null,
        'sticker_url': stickerMessage.hasStickerUrl() ? stickerMessage.stickerUrl : null,
        'sticker_pack_id': stickerMessage.hasStickerPackId() ? stickerMessage.stickerPackId : null,
        'sticker_pack_name': stickerMessage.hasStickerPackName() ? stickerMessage.stickerPackName : null,
      };
    }

    // 处理联系人消息
    if (protoMessage.hasContactMessage()) {
      final contactMessage = protoMessage.contactMessage;
      contentMap['contact_message'] = {
        'contact_id': contactMessage.hasContactId() ? contactMessage.contactId : null,
        'contact_name': contactMessage.hasContactName() ? contactMessage.contactName : null,
        'contact_phone': contactMessage.hasContactPhone() ? contactMessage.contactPhone : null,
        'contact_avatar': contactMessage.hasContactAvatar() ? contactMessage.contactAvatar : null,
        'contact_email': contactMessage.hasContactEmail() ? contactMessage.contactEmail : null,
      };
    }

    // 处理投票消息
    if (protoMessage.hasPollMessage()) {
      final pollMessage = protoMessage.pollMessage;
      contentMap['poll_message'] = {
        'poll_id': pollMessage.hasPollId() ? pollMessage.pollId : null,
        'question': pollMessage.hasQuestion() ? pollMessage.question : null,
        'options': pollMessage.options.map((option) => {
          'option_id': option.hasOptionId() ? option.optionId : null,
          'text': option.hasText() ? option.text : null,
          'vote_count': option.hasVoteCount() ? option.voteCount : 0,
          'voter_ids': option.voterIds.toList(),
        }).toList(),
        'is_multiple_choice': pollMessage.hasIsMultipleChoice() ? pollMessage.isMultipleChoice : false,
        'expires_at': pollMessage.hasExpiresAt() ? pollMessage.expiresAt.toInt() : null,
        'is_anonymous': pollMessage.hasIsAnonymous() ? pollMessage.isAnonymous : false,
      };
    }

    // 处理链接消息
    if (protoMessage.hasLinkMessage()) {
      final linkMessage = protoMessage.linkMessage;
      contentMap['link_message'] = {
        'url': linkMessage.hasUrl() ? linkMessage.url : null,
        'preview': linkMessage.hasPreview() ? {
          'url': linkMessage.preview.hasUrl() ? linkMessage.preview.url : null,
          'title': linkMessage.preview.hasTitle() ? linkMessage.preview.title : null,
          'description': linkMessage.preview.hasDescription() ? linkMessage.preview.description : null,
          'image_url': linkMessage.preview.hasImageUrl() ? linkMessage.preview.imageUrl : null,
          'site_name': linkMessage.preview.hasSiteName() ? linkMessage.preview.siteName : null,
          'favicon_url': linkMessage.preview.hasFaviconUrl() ? linkMessage.preview.faviconUrl : null,
        } : null,
      };
    }

    return contentMap.isNotEmpty ? jsonEncode(contentMap) : null;
  }

  /// 将数据库对象转换为Protocol Buffer对象
  ///
  /// 用于将Message对象转换为可序列化的Proto对象
  /// 便于网络传输和存储
  ///
  /// [message] - 数据库消息对象
  /// 返回：转换后的Protocol Buffer对象
  static message_proto.MessageProto toProto(Message message) {
    final protoMessage = message_proto.MessageProto(
      messageId: message.messageId,
      conversationId: message.conversationId,
      index: message.messageIndex,
      senderId: message.senderId,
      senderName: message.senderName,
      senderAvatar: message.senderAvatar,
      createdAt: Int64(message.createdAt.millisecondsSinceEpoch),
      updatedAt: message.updatedAt != null ? Int64(message.updatedAt!.millisecondsSinceEpoch) : null,
      status: _stringToProtoStatus(message.messageStatus),
      type: _stringToProtoType(message.messageType),
      quotedMessageId: message.quotedMessageId,
      isEdited: message.isEdited,
      editedAt: message.editedAt != null ? Int64(message.editedAt!.millisecondsSinceEpoch) : null,
      repliedToMessageId: message.repliedToMessageId,
      forwardedFromConversationId: message.forwardedFromConversationId,
      forwardedFromMessageId: message.forwardedFromMessageId,
      tags: message.tags != null ? _parseJsonStringList(message.tags!) : [],
      isPinned: message.isPinned,
    );

    // 设置reactions字段
    if (message.reactions != null && message.reactions!.isNotEmpty) {
      final reactionsMap = _parseJsonMapStringInt(message.reactions!);
      protoMessage.reactions.addAll(reactionsMap);
    }

    // 从JSON内容创建对应的proto content结构
    _createProtoContentFromJson(message.content, protoMessage);

    return protoMessage;
  }

  /// 从JSON内容创建对应的proto content结构
  static void _createProtoContentFromJson(String? contentJson, message_proto.MessageProto protoMessage) {
    if (contentJson == null || contentJson.isEmpty) return;

    try {
      final Map<String, dynamic> contentMap = jsonDecode(contentJson);

      // 处理文本消息
      if (contentMap.containsKey('text_message')) {
        final textData = contentMap['text_message'] as Map<String, dynamic>;
        final textMessage = message_proto.TextMessage(
          text: textData['text'] as String? ?? '',
          mentions: (textData['mentions'] as List<dynamic>?)?.cast<String>() ?? [],
          hashtags: (textData['hashtags'] as List<dynamic>?)?.cast<String>() ?? [],
        );
        
        // 处理链接预览
        if (textData['links'] != null) {
          final links = (textData['links'] as List<dynamic>).map((linkData) {
            final link = linkData as Map<String, dynamic>;
            return message_proto.LinkPreview(
              url: link['url'] as String? ?? '',
              title: link['title'] as String?,
              description: link['description'] as String?,
              imageUrl: link['image_url'] as String?,
              siteName: link['site_name'] as String?,
              faviconUrl: link['favicon_url'] as String?,
            );
          }).toList();
          textMessage.links.addAll(links);
        }
        
        protoMessage.textMessage = textMessage;
      }

      // 处理媒体消息
      if (contentMap.containsKey('media_message')) {
        final mediaData = contentMap['media_message'] as Map<String, dynamic>;
        final mediaMessage = message_proto.MediaMessage(
          mediaUrl: mediaData['media_url'] as String?,
          localPath: mediaData['local_path'] as String?,
          duration: mediaData['duration'] as int?,
          fileSize: (mediaData['file_size'] as num?)?.toDouble(),
          fileName: mediaData['file_name'] as String?,
          fsId: mediaData['fs_id'] as String?,
          mimeType: mediaData['mime_type'] as String?,
          width: mediaData['width'] as int?,
          height: mediaData['height'] as int?,
          caption: mediaData['caption'] as String?,
        );
        protoMessage.mediaMessage = mediaMessage;
      }

      // 处理系统消息
      if (contentMap.containsKey('system_message')) {
        final systemData = contentMap['system_message'] as Map<String, dynamic>;
        final systemMessage = message_proto.SystemMessage(
          text: systemData['text'] as String? ?? '',
          actorUserId: systemData['actor_user_id'] as String?,
          eventTimestamp: systemData['event_timestamp'] != null 
              ? Int64(systemData['event_timestamp'] as int) 
              : null,
        );

        // 设置事件类型
        if (systemData['event_type'] != null) {
          try {
            final eventType = message_proto.SystemEventType.values.firstWhere(
              (e) => e.name == systemData['event_type'],
              orElse: () => message_proto.SystemEventType.CONVERSATION_CREATED,
            );
            systemMessage.eventType = eventType;
          } catch (e) {
            systemMessage.eventType = message_proto.SystemEventType.CONVERSATION_CREATED;
          }
        }

        // 设置参数和用户列表
        if (systemData['params'] != null) {
          final params = systemData['params'] as Map<String, dynamic>;
          systemMessage.params.addAll(params.map((k, v) => MapEntry(k, v.toString())));
        }
        if (systemData['affected_user_ids'] != null) {
          final userIds = (systemData['affected_user_ids'] as List<dynamic>).cast<String>();
          systemMessage.affectedUserIds.addAll(userIds);
        }
        if (systemData['metadata'] != null) {
          final metadata = systemData['metadata'] as Map<String, dynamic>;
          systemMessage.metadata.addAll(metadata.map((k, v) => MapEntry(k, v.toString())));
        }

        protoMessage.systemMessage = systemMessage;
      }

      // 可以继续添加其他消息类型的处理...

    } catch (e) {
      // JSON解析失败，跳过内容设置
    }
  }

  /// 将Proto消息类型转换为字符串
  static String _protoTypeToString(message_proto.MessageType type) {
    switch (type) {
      case message_proto.MessageType.TEXT:
        return 'TEXT';
      case message_proto.MessageType.IMAGE:
        return 'IMAGE';
      case message_proto.MessageType.VOICE:
        return 'VOICE';
      case message_proto.MessageType.VIDEO:
        return 'VIDEO';
      case message_proto.MessageType.FILE:
        return 'FILE';
      case message_proto.MessageType.SYSTEM:
        return 'SYSTEM';
      default:
        return 'TEXT';
    }
  }

  /// 将字符串转换为Proto消息类型
  static message_proto.MessageType _stringToProtoType(String type) {
    switch (type) {
      case 'TEXT':
        return message_proto.MessageType.TEXT;
      case 'IMAGE':
        return message_proto.MessageType.IMAGE;
      case 'VOICE':
        return message_proto.MessageType.VOICE;
      case 'VIDEO':
        return message_proto.MessageType.VIDEO;
      case 'FILE':
        return message_proto.MessageType.FILE;
      case 'SYSTEM':
        return message_proto.MessageType.SYSTEM;
      default:
        return message_proto.MessageType.TEXT;
    }
  }

  /// 将Proto消息状态转换为字符串
  static String _protoStatusToString(message_proto.MessageStatus status) {
    switch (status) {
      case message_proto.MessageStatus.SENDING:
        return 'SENDING';
      case message_proto.MessageStatus.SENT:
        return 'SENT';
      case message_proto.MessageStatus.DELIVERED:
        return 'DELIVERED';
      case message_proto.MessageStatus.READ:
        return 'READ';
      case message_proto.MessageStatus.FAILED:
        return 'FAILED';
      case message_proto.MessageStatus.DELETED:
        return 'DELETED';
      case message_proto.MessageStatus.REVOKED:
        return 'REVOKED';
      default:
        return 'SENT';
    }
  }

  /// 将字符串转换为Proto消息状态
  static message_proto.MessageStatus _stringToProtoStatus(String status) {
    switch (status) {
      case 'SENDING':
        return message_proto.MessageStatus.SENDING;
      case 'SENT':
        return message_proto.MessageStatus.SENT;
      case 'DELIVERED':
        return message_proto.MessageStatus.DELIVERED;
      case 'read':
        return message_proto.MessageStatus.READ;
      case 'FAILED':
        return message_proto.MessageStatus.FAILED;
      case 'DELETED':
        return message_proto.MessageStatus.DELETED;
      case 'REVOKED':
        return message_proto.MessageStatus.REVOKED;
      default:
        return message_proto.MessageStatus.SENT;
    }
  }

  /// 批量转换：从Proto列表转换为Message列表
  static List<Message> fromProtoList(List<message_proto.MessageProto> protoList) {
    return protoList.map((proto) => fromProto(proto)).toList();
  }

  /// 批量转换：从Message列表转换为Proto列表
  static List<message_proto.MessageProto> toProtoList(List<Message> messages) {
    return messages.map((message) => toProto(message)).toList();
  }

  /// 解析JSON字符串为字符串列表
  static List<String> _parseJsonStringList(String jsonString) {
    try {
      final List<dynamic> list = jsonDecode(jsonString);
      return list.cast<String>();
    } catch (e) {
      return [];
    }
  }

  /// 解析JSON字符串为Map<String, int>
  static Map<String, int> _parseJsonMapStringInt(String jsonString) {
    try {
      final Map<String, dynamic> map = jsonDecode(jsonString);
      return map.map((key, value) => MapEntry(key, value as int));
    } catch (e) {
      return {};
    }
  }

  /// 从消息内容JSON中提取文本
  /// 
  /// [contentJson] - 消息内容JSON字符串
  /// 返回：提取的文本内容，如果不存在则返回null
  static String? extractTextFromContent(String? contentJson) {
    if (contentJson == null || contentJson.isEmpty) return null;

    try {
      final Map<String, dynamic> contentMap = jsonDecode(contentJson);
      
      // 检查文本消息
      if (contentMap.containsKey('text_message')) {
        final textData = contentMap['text_message'] as Map<String, dynamic>;
        return textData['text'] as String?;
      }
      
      // 检查媒体消息的说明文字
      if (contentMap.containsKey('media_message')) {
        final mediaData = contentMap['media_message'] as Map<String, dynamic>;
        return mediaData['caption'] as String?;
      }
      
      // 检查系统消息
      if (contentMap.containsKey('system_message')) {
        final systemData = contentMap['system_message'] as Map<String, dynamic>;
        return systemData['text'] as String?;
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 检查消息是否包含媒体内容
  /// 
  /// [contentJson] - 消息内容JSON字符串
  /// 返回：如果包含媒体内容返回true，否则返回false
  static bool hasMediaContent(String? contentJson) {
    if (contentJson == null || contentJson.isEmpty) return false;

    try {
      final Map<String, dynamic> contentMap = jsonDecode(contentJson);
      return contentMap.containsKey('media_message');
    } catch (e) {
      return false;
    }
  }

  /// 从消息内容JSON中提取媒体信息
  /// 
  /// [contentJson] - 消息内容JSON字符串
  /// 返回：媒体信息Map，如果不存在则返回null
  static Map<String, dynamic>? extractMediaInfo(String? contentJson) {
    if (contentJson == null || contentJson.isEmpty) return null;

    try {
      final Map<String, dynamic> contentMap = jsonDecode(contentJson);
      
      if (contentMap.containsKey('media_message')) {
        return contentMap['media_message'] as Map<String, dynamic>;
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }
}