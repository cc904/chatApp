import 'dart:convert';
import 'package:fixnum/fixnum.dart';
import 'package:cc/core/proto/generated/message.pb.dart' as proto;
import 'package:cc/core/database/models/message.dart';

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
/// messages.sortByCreatedAtDesc().sortByMessageId()  // ❌ 已废弃
///
/// // 新方案：简单的Index排序，绝对可靠
/// messages.sortByMessageIndexDesc()  // 🚀 一行搞定！
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
  static Message fromProto(proto.MessageProto protoMessage) {
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
          ? DateTime.fromMillisecondsSinceEpoch(protoMessage.createdAt.toInt())
          : DateTime.now()
      ..updatedAt = protoMessage.hasUpdatedAt()
          ? DateTime.fromMillisecondsSinceEpoch(protoMessage.updatedAt.toInt())
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
          ? DateTime.fromMillisecondsSinceEpoch(protoMessage.editedAt.toInt())
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
      proto.MessageProto protoMessage, Message message) {
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
      message.action = systemMessage.hasAction() ? systemMessage.action : null;
      message.params = systemMessage.params.isNotEmpty
          ? jsonEncode(systemMessage.params)
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
          ? DateTime.fromMillisecondsSinceEpoch(pollMessage.expiresAt.toInt())
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
  static proto.MessageProto toProto(Message message) {
    final protoMessage = proto.MessageProto(
      messageId: message.messageId,
      conversationId: message.conversationId,
      index: Int64(message.messageIndex),
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
      Message message, proto.MessageProto protoMessage) {
    switch (message.type) {
      case MessageType.text:
        if (message.text != null) {
          final textMessage = proto.TextMessage(
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
        final mediaMessage = proto.MediaMessage();
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
        final systemMessage = proto.SystemMessage();
        if (message.text != null) systemMessage.text = message.text!;
        if (message.action != null) systemMessage.action = message.action!;
        if (message.params != null) {
          final paramsMap = _parseJsonMapStringString(message.params!);
          systemMessage.params.addAll(paramsMap);
        }
        protoMessage.systemMessage = systemMessage;
        break;
    }
  }

  /// 批量转换：从Proto列表转换为Message列表
  static List<Message> fromProtoList(List<proto.MessageProto> protoList) {
    return protoList.map((proto) => fromProto(proto)).toList();
  }

  /// 批量转换：从Message列表转换为Proto列表
  static List<proto.MessageProto> toProtoList(List<Message> messages) {
    return messages.map((message) => toProto(message)).toList();
  }

  /// 将Proto枚举类型转换为MessageType枚举
  static MessageType _protoTypeToMessageType(proto.MessageType type) {
    switch (type) {
      case proto.MessageType.TEXT:
        return MessageType.text;
      case proto.MessageType.IMAGE:
        return MessageType.image;
      case proto.MessageType.VOICE:
        return MessageType.voice;
      case proto.MessageType.VIDEO:
        return MessageType.video;
      case proto.MessageType.FILE:
        return MessageType.file;
      case proto.MessageType.SYSTEM:
        return MessageType.system;
      default:
        return MessageType.text;
    }
  }

  /// 将MessageType枚举转换为Proto枚举类型
  static proto.MessageType _messageTypeToProtoType(MessageType type) {
    switch (type) {
      case MessageType.text:
        return proto.MessageType.TEXT;
      case MessageType.image:
        return proto.MessageType.IMAGE;
      case MessageType.voice:
        return proto.MessageType.VOICE;
      case MessageType.video:
        return proto.MessageType.VIDEO;
      case MessageType.file:
        return proto.MessageType.FILE;
      case MessageType.system:
        return proto.MessageType.SYSTEM;
    }
  }

  /// 根据proto消息确定MessageStatus状态
  static MessageStatus _determineMessageStatus(
      proto.MessageProto protoMessage) {
    if (protoMessage.hasStatus()) {
      return _protoStatusToMessageStatus(protoMessage.status);
    }
    return MessageStatus.sent;
  }

  /// 将Proto状态转换为MessageStatus枚举
  static MessageStatus _protoStatusToMessageStatus(proto.MessageStatus status) {
    switch (status) {
      case proto.MessageStatus.SENDING:
        return MessageStatus.sending;
      case proto.MessageStatus.SENT:
        return MessageStatus.sent;
      case proto.MessageStatus.DELIVERED:
        return MessageStatus.delivered;
      case proto.MessageStatus.READ:
        return MessageStatus.read;
      case proto.MessageStatus.FAILED:
        return MessageStatus.failed;
      // case proto.MessageStatus.DELETED:
      //   return MessageStatus.deleted;
      // case proto.MessageStatus.REVOKED:
      //   return MessageStatus.revoked;
      default:
        return MessageStatus.sent;
    }
  }

  /// 将MessageStatus枚举转换为Proto状态
  static proto.MessageStatus _messageStatusToProtoStatus(MessageStatus status) {
    switch (status) {
      case MessageStatus.sending:
        return proto.MessageStatus.SENDING;
      case MessageStatus.sent:
        return proto.MessageStatus.SENT;
      case MessageStatus.delivered:
        return proto.MessageStatus.DELIVERED;
      case MessageStatus.read:
        return proto.MessageStatus.READ;
      case MessageStatus.failed:
        return proto.MessageStatus.FAILED;
      case MessageStatus.deleted:
        return proto.MessageStatus.DELETED;
      case MessageStatus.revoked:
        return proto.MessageStatus.REVOKED;
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
