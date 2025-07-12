import 'dart:convert';
import 'package:fixnum/fixnum.dart';
import 'package:cc/core/proto/generated/message.pb.dart' as message_proto;
// import 'package:cc/core/proto/generated/common.pb.dart' as common_proto;
import 'package:cc/core/database/models/message.dart';
import 'package:cc/core/utils/timezone_utils.dart';

/// 🚀 消息适配器 - 支持Index-based同步的转换器
///
/// 负责在Protocol Buffer消息和数据库消息之间进行转换。
/// 新版本重点支持messageIndex字段，用于替代复杂的时间戳游标系统。
///
/// ## 🎯 核心功能
/// 1. **Proto ↔ Database 转换**：双向转换消息对象
/// 2. **Index字段处理**：正确处理服务器分配的消息序列号
/// 3. **嵌套结构处理**：支持proto的oneof content结构
///
/// ## 🔥 Index方案优势
/// ```dart
/// // 旧方案：复杂的时间戳排序
/// messages.sortByMessageIndexDesc()  // ❌ 已废弃
///
/// // 新方案：使用服务器时间戳排序，确保跨客户端一致性
/// messages.sortByCreatedAtDesc()  // 🚀 一行搞定！
/// ```
///
/// ## 📋 支持的消息类型
/// - TEXT: 文本消息
/// - IMAGE: 图片消息
/// - VOICE: 语音消息
/// - FILE: 文件消息
/// - VIDEO: 视频消息
/// - SYSTEM: 系统消息
///
/// ## 🔄 转换示例
/// ```dart
/// // Protocol Buffer → Database
/// final message = MessageAdapter.fromProto(protoMessage);
/// print('Index: ${message.messageIndex}');  // 🔥 核心排序字段
///
/// // Database → Protocol Buffer
/// final proto = MessageAdapter.toProto(dbMessage);
/// print('Proto Index: ${proto.index}');     // 🔥 同步依据
/// ```
class MessageAdapter {
  /// 从 Protocol Buffer对象创建数据库对象
  ///
  /// 直接从MessageProto对象创建Message实例
  ///
  /// [proto] - 原始的Protocol Buffer对象
  /// 返回：转换后的数据库对象
  static Message fromProto(message_proto.MessageProto protoMessage) {
    final message = Message()
      ..messageId = protoMessage.messageId
      ..conversationId = protoMessage.conversationId
      ..messageIndex = protoMessage.hasIndex() ? protoMessage.index.toInt() : 0
      ..senderId = protoMessage.senderId
      ..senderName =
          protoMessage.hasSenderName() ? protoMessage.senderName : null
      ..senderAvatar =
          protoMessage.hasSenderAvatar() ? protoMessage.senderAvatar : null
      ..createdAt = protoMessage.hasCreatedAt()
          ? TimezoneUtils.fromServerTimestamp(
              protoMessage.createdAt.toInt()) // 🌍 使用UTC时间戳处理
          : TimezoneUtils.nowUtc() // 🌍 默认使用UTC时间
      ..updatedAt = protoMessage.hasUpdatedAt()
          ? TimezoneUtils.fromServerTimestamp(
              protoMessage.updatedAt.toInt()) // 🌍 使用UTC时间戳处理
          : null
      ..status = _determineMessageStatus(protoMessage)
      ..type = protoMessage.hasType()
          ? _protoTypeToMessageType(protoMessage.type)
          : MessageType.text
      ..quotedMessageId = protoMessage.hasQuotedMessageId()
          ? protoMessage.quotedMessageId
          : null
      ..isEdited = protoMessage.hasIsEdited() ? protoMessage.isEdited : false
      ..editedAt = protoMessage.hasEditedAt()
          ? TimezoneUtils.fromServerTimestamp(
              protoMessage.editedAt.toInt()) // 🌍 使用UTC时间戳处理
          : null
      ..repliedToMessageId = protoMessage.hasRepliedToMessageId()
          ? protoMessage.repliedToMessageId
          : null
      ..forwardedFromConversationId =
          protoMessage.hasForwardedFromConversationId()
              ? protoMessage.forwardedFromConversationId
              : null
      ..forwardedFromMessageId = protoMessage.hasForwardedFromMessageId()
          ? protoMessage.forwardedFromMessageId
          : null
      ..reactions = protoMessage.reactions.isNotEmpty
          ? jsonEncode(protoMessage.reactions)
          : null
      ..tags =
          protoMessage.tags.isNotEmpty ? jsonEncode(protoMessage.tags) : null
      ..isPinned = protoMessage.hasIsPinned() ? protoMessage.isPinned : false;

    // 处理不同类型的消息内容
    _extractContentFromProto(protoMessage, message);

    return message;
  }

  /// 从proto的oneof content中提取内容到数据库扁平结构
  static void _extractContentFromProto(
      message_proto.MessageProto protoMessage, Message message) {
    // 处理文本消息
    if (protoMessage.hasTextMessage()) {
      final textMessage = protoMessage.textMessage;
      message.text = textMessage.hasText() ? textMessage.text : null;
      message.mentions = textMessage.mentions.isNotEmpty
          ? jsonEncode(textMessage.mentions)
          : null;
      message.hashtags = textMessage.hashtags.isNotEmpty
          ? jsonEncode(textMessage.hashtags)
          : null;
    }

    // 处理媒体消息
    if (protoMessage.hasMediaMessage()) {
      final mediaMessage = protoMessage.mediaMessage;
      message.mediaUrl =
          mediaMessage.hasMediaUrl() ? mediaMessage.mediaUrl : null;
      message.localPath =
          mediaMessage.hasLocalPath() ? mediaMessage.localPath : null;
      message.duration =
          mediaMessage.hasDuration() ? mediaMessage.duration : null;
      message.fileSize =
          mediaMessage.hasFileSize() ? mediaMessage.fileSize : null;
      message.fileName =
          mediaMessage.hasFileName() ? mediaMessage.fileName : null;
      message.thumbnailUrl =
          mediaMessage.hasThumbnailUrl() ? mediaMessage.thumbnailUrl : null;
      message.mimeType =
          mediaMessage.hasMimeType() ? mediaMessage.mimeType : null;
      message.width = mediaMessage.hasWidth() ? mediaMessage.width : null;
      message.height = mediaMessage.hasHeight() ? mediaMessage.height : null;
      message.caption = mediaMessage.hasCaption() ? mediaMessage.caption : null;
    }

    // 处理系统消息
    if (protoMessage.hasSystemMessage()) {
      final systemMessage = protoMessage.systemMessage;
      message.text = systemMessage.hasText() ? systemMessage.text : null;
      // 🆕 使用新的eventType字段替代action字段
      if (systemMessage.hasEventType()) {
        message.eventType = systemMessage.eventType.name;
        // 保持向后兼容性
        message.action = systemMessage.eventType.name;
      }
      message.params = systemMessage.params.isNotEmpty
          ? jsonEncode(systemMessage.params)
          : null;

      // 🆕 新增系统事件字段
      message.affectedUserIds = systemMessage.affectedUserIds.isNotEmpty
          ? jsonEncode(systemMessage.affectedUserIds)
          : null;
      message.actorUserId =
          systemMessage.hasActorUserId() ? systemMessage.actorUserId : null;
      message.eventTimestamp = systemMessage.hasEventTimestamp()
          ? TimezoneUtils.fromServerTimestamp(
              systemMessage.eventTimestamp.toInt()) // 🌍 使用UTC时间戳处理
          : null;
      message.metadata = systemMessage.metadata.isNotEmpty
          ? jsonEncode(systemMessage.metadata)
          : null;
    }

    // 🆕 处理成员变动消息
    if (protoMessage.hasMembershipMessage()) {
      final membershipMessage = protoMessage.membershipMessage;
      // 设置成员变动事件类型
      if (membershipMessage.hasEventType()) {
        message.membershipEventType = membershipMessage.eventType.name;
      }

      // 设置操作者信息
      if (membershipMessage.hasActor()) {
        final actor = membershipMessage.actor;
        message.membershipActor = jsonEncode({
          'userId': actor.hasUserId() ? actor.userId : null,
          'userName': actor.hasUserName() ? actor.userName : null,
          'userAvatar': actor.hasUserAvatar() ? actor.userAvatar : null,
          'role': actor.hasRole() ? actor.role : null,
          'joinedAt': actor.hasJoinedAt() ? actor.joinedAt.toInt() : null,
        });
      }

      // 设置受影响的成员列表
      if (membershipMessage.affectedMembers.isNotEmpty) {
        final affectedMembers = membershipMessage.affectedMembers
            .map((member) => {
                  'userId': member.hasUserId() ? member.userId : null,
                  'userName': member.hasUserName() ? member.userName : null,
                  'userAvatar':
                      member.hasUserAvatar() ? member.userAvatar : null,
                  'role': member.hasRole() ? member.role : null,
                  'joinedAt':
                      member.hasJoinedAt() ? member.joinedAt.toInt() : null,
                })
            .toList();
        message.membershipAffectedMembers = jsonEncode(affectedMembers);
      }

      // 设置时间戳和角色变更信息
      message.eventTimestamp = membershipMessage.hasEventTimestamp()
          ? TimezoneUtils.fromServerTimestamp(
              membershipMessage.eventTimestamp.toInt()) // 🌍 使用UTC时间戳处理
          : null;
      message.membershipPreviousRole = membershipMessage.hasPreviousRole()
          ? membershipMessage.previousRole
          : null;
      message.membershipNewRole =
          membershipMessage.hasNewRole() ? membershipMessage.newRole : null;
      message.membershipRemovalReason = membershipMessage.hasRemovalReason()
          ? membershipMessage.removalReason
          : null;
      message.membershipInviteLink = membershipMessage.hasInviteLink()
          ? membershipMessage.inviteLink
          : null;
      message.membershipMetadata = membershipMessage.metadata.isNotEmpty
          ? jsonEncode(membershipMessage.metadata)
          : null;
    }

    // 处理表情包消息
    if (protoMessage.hasStickerMessage()) {
      final stickerMessage = protoMessage.stickerMessage;
      message.stickerId =
          stickerMessage.hasStickerId() ? stickerMessage.stickerId : null;
      message.stickerUrl =
          stickerMessage.hasStickerUrl() ? stickerMessage.stickerUrl : null;
      message.stickerPackId = stickerMessage.hasStickerPackId()
          ? stickerMessage.stickerPackId
          : null;
      message.stickerPackName = stickerMessage.hasStickerPackName()
          ? stickerMessage.stickerPackName
          : null;
    }

    // 处理联系人消息
    if (protoMessage.hasContactMessage()) {
      final contactMessage = protoMessage.contactMessage;
      message.contactId =
          contactMessage.hasContactId() ? contactMessage.contactId : null;
      message.contactName =
          contactMessage.hasContactName() ? contactMessage.contactName : null;
      message.contactPhone =
          contactMessage.hasContactPhone() ? contactMessage.contactPhone : null;
      message.contactAvatar = contactMessage.hasContactAvatar()
          ? contactMessage.contactAvatar
          : null;
      message.contactEmail =
          contactMessage.hasContactEmail() ? contactMessage.contactEmail : null;
    }

    // 处理投票消息
    if (protoMessage.hasPollMessage()) {
      final pollMessage = protoMessage.pollMessage;
      message.pollId = pollMessage.hasPollId() ? pollMessage.pollId : null;
      message.question =
          pollMessage.hasQuestion() ? pollMessage.question : null;
      message.isMultipleChoice = pollMessage.hasIsMultipleChoice()
          ? pollMessage.isMultipleChoice
          : null;
      message.expiresAt = pollMessage.hasExpiresAt()
          ? TimezoneUtils.fromServerTimestamp(
              pollMessage.expiresAt.toInt()) // 🌍 使用UTC时间戳处理
          : null;
      message.isAnonymous =
          pollMessage.hasIsAnonymous() ? pollMessage.isAnonymous : null;
    }

    // 处理链接消息
    if (protoMessage.hasLinkMessage()) {
      final linkMessage = protoMessage.linkMessage;
      message.linkUrl = linkMessage.hasUrl() ? linkMessage.url : null;
      if (linkMessage.hasPreview()) {
        final preview = linkMessage.preview;
        message.linkTitle = preview.hasTitle() ? preview.title : null;
        message.linkDescription =
            preview.hasDescription() ? preview.description : null;
        message.linkImageUrl = preview.hasImageUrl() ? preview.imageUrl : null;
        message.siteName = preview.hasSiteName() ? preview.siteName : null;
        message.faviconUrl =
            preview.hasFaviconUrl() ? preview.faviconUrl : null;
      }
    }
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
      updatedAt: message.updatedAt != null
          ? Int64(message.updatedAt!.millisecondsSinceEpoch)
          : Int64(0),
      status: _messageStatusToProtoStatus(message.status),
      type: _messageTypeToProtoType(message.type),
      quotedMessageId: message.quotedMessageId,
      isEdited: message.isEdited,
      editedAt: message.editedAt != null
          ? Int64(message.editedAt!.millisecondsSinceEpoch)
          : Int64(0),
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

    // 创建对应的oneof content结构
    _createProtoContent(message, protoMessage);

    return protoMessage;
  }

  /// 根据数据库消息创建对应的proto content结构
  static void _createProtoContent(
      Message message, message_proto.MessageProto protoMessage) {
    switch (message.type) {
      case MessageType.text:
        if (message.text != null) {
          final textMessage = message_proto.TextMessage(
            text: message.text!,
            mentions: message.mentions != null
                ? _parseJsonStringList(message.mentions!)
                : [],
            hashtags: message.hashtags != null
                ? _parseJsonStringList(message.hashtags!)
                : [],
          );
          protoMessage.textMessage = textMessage;
        }
        break;

      case MessageType.image:
      case MessageType.voice:
      case MessageType.video:
      case MessageType.file:
        final mediaMessage = message_proto.MediaMessage();
        if (message.mediaUrl != null) {
          mediaMessage.mediaUrl = message.mediaUrl!;
        }
        if (message.localPath != null) {
          mediaMessage.localPath = message.localPath!;
        }
        if (message.duration != null) mediaMessage.duration = message.duration!;
        if (message.fileSize != null) mediaMessage.fileSize = message.fileSize!;
        if (message.fileName != null) mediaMessage.fileName = message.fileName!;
        if (message.thumbnailUrl != null) {
          mediaMessage.thumbnailUrl = message.thumbnailUrl!;
        }
        if (message.mimeType != null) mediaMessage.mimeType = message.mimeType!;
        if (message.width != null) mediaMessage.width = message.width!;
        if (message.height != null) mediaMessage.height = message.height!;
        if (message.caption != null) mediaMessage.caption = message.caption!;
        protoMessage.mediaMessage = mediaMessage;
        break;

      case MessageType.system:
        final systemMessage = message_proto.SystemMessage();
        if (message.text != null) systemMessage.text = message.text!;

        // 🆕 使用新的eventType字段
        if (message.eventType != null) {
          try {
            // 将字符串转换为SystemEventType枚举
            final eventType = message_proto.SystemEventType.values.firstWhere(
              (e) => e.name == message.eventType,
              orElse: () => message_proto.SystemEventType.CONVERSATION_CREATED,
            );
            systemMessage.eventType = eventType;
          } catch (e) {
            // 如果解析失败，使用默认值
            systemMessage.eventType =
                message_proto.SystemEventType.CONVERSATION_CREATED;
          }
        }

        if (message.params != null) {
          final paramsMap = _parseJsonMapStringString(message.params!);
          systemMessage.params.addAll(paramsMap);
        }

        // 🆕 新增系统事件字段
        if (message.affectedUserIds != null) {
          final affectedUserIds =
              _parseJsonStringList(message.affectedUserIds!);
          systemMessage.affectedUserIds.addAll(affectedUserIds);
        }
        if (message.actorUserId != null) {
          systemMessage.actorUserId = message.actorUserId!;
        }
        if (message.eventTimestamp != null) {
          systemMessage.eventTimestamp =
              Int64(message.eventTimestamp!.millisecondsSinceEpoch);
        }
        if (message.metadata != null) {
          final metadataMap = _parseJsonMapStringString(message.metadata!);
          systemMessage.metadata.addAll(metadataMap);
        }

        protoMessage.systemMessage = systemMessage;
        break;
    }
  }

  /// 批量转换：从Proto列表转换为Message列表
  static List<Message> fromProtoList(
      List<message_proto.MessageProto> protoList) {
    return protoList.map((proto) => fromProto(proto)).toList();
  }

  /// 批量转换：从Message列表转换为Proto列表
  static List<message_proto.MessageProto> toProtoList(List<Message> messages) {
    return messages.map((message) => toProto(message)).toList();
  }

  /// 将Proto枚举类型转换为MessageType枚举
  static MessageType _protoTypeToMessageType(message_proto.MessageType type) {
    switch (type) {
      case message_proto.MessageType.TEXT:
        return MessageType.text;
      case message_proto.MessageType.IMAGE:
        return MessageType.image;
      case message_proto.MessageType.VOICE:
        return MessageType.voice;
      case message_proto.MessageType.VIDEO:
        return MessageType.video;
      case message_proto.MessageType.FILE:
        return MessageType.file;
      case message_proto.MessageType.SYSTEM:
        return MessageType.system;
      default:
        return MessageType.text;
    }
  }

  /// 将MessageType枚举转换为Proto枚举类型
  static message_proto.MessageType _messageTypeToProtoType(MessageType type) {
    switch (type) {
      case MessageType.text:
        return message_proto.MessageType.TEXT;
      case MessageType.image:
        return message_proto.MessageType.IMAGE;
      case MessageType.voice:
        return message_proto.MessageType.VOICE;
      case MessageType.video:
        return message_proto.MessageType.VIDEO;
      case MessageType.file:
        return message_proto.MessageType.FILE;
      case MessageType.system:
        return message_proto.MessageType.SYSTEM;
    }
  }

  /// 根据proto消息确定MessageStatus状态
  static MessageStatus _determineMessageStatus(
      message_proto.MessageProto protoMessage) {
    if (protoMessage.hasStatus()) {
      return _protoStatusToMessageStatus(protoMessage.status);
    }
    return MessageStatus.sent;
  }

  /// 将Proto状态转换为MessageStatus枚举
  static MessageStatus _protoStatusToMessageStatus(
      message_proto.MessageStatus status) {
    switch (status) {
      case message_proto.MessageStatus.SENDING:
        return MessageStatus.sending;
      case message_proto.MessageStatus.SENT:
        return MessageStatus.sent;
      case message_proto.MessageStatus.DELIVERED:
        return MessageStatus.delivered;
      case message_proto.MessageStatus.READ:
        return MessageStatus.read;
      case message_proto.MessageStatus.FAILED:
        return MessageStatus.failed;
      // case message_proto.MessageStatus.DELETED:
      //   return MessageStatus.deleted;
      // case message_proto.MessageStatus.REVOKED:
      //   return MessageStatus.revoked;
      default:
        return MessageStatus.sent;
    }
  }

  /// 将MessageStatus枚举转换为Proto状态
  static message_proto.MessageStatus _messageStatusToProtoStatus(
      MessageStatus status) {
    switch (status) {
      case MessageStatus.sending:
        return message_proto.MessageStatus.SENDING;
      case MessageStatus.sent:
        return message_proto.MessageStatus.SENT;
      case MessageStatus.delivered:
        return message_proto.MessageStatus.DELIVERED;
      case MessageStatus.read:
        return message_proto.MessageStatus.READ;
      case MessageStatus.failed:
        return message_proto.MessageStatus.FAILED;
      case MessageStatus.deleted:
        return message_proto.MessageStatus.DELETED;
      case MessageStatus.revoked:
        return message_proto.MessageStatus.REVOKED;
    }
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

  /// 解析JSON字符串为Map<String, String>
  static Map<String, String> _parseJsonMapStringString(String jsonString) {
    try {
      final Map<String, dynamic> map = jsonDecode(jsonString);
      return map.map((key, value) => MapEntry(key, value.toString()));
    } catch (e) {
      return {};
    }
  }
}
