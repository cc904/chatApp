import 'package:fixnum/fixnum.dart';
import 'package:cc/core/database/models/message.dart';
import 'package:cc/core/proto/generated/message.pb.dart' as proto;

/// 🚀 消息适配器 - 支持Index-based同步的转换器
///
/// 负责在Protocol Buffer消息和数据库消息之间进行转换。
/// 新版本重点支持messageIndex字段，用于替代复杂的时间戳游标系统。
///
/// ## 🎯 核心功能
/// 1. **Proto ↔ Database 转换**：双向转换消息对象
/// 2. **Index字段处理**：正确处理服务器分配的消息序列号
/// 3. **位置功能移除**：不再处理位置相关字段
///
/// ## 🔥 Index方案优势
/// ```dart
/// // 旧方案：复杂的时间戳排序
/// messages.sortByCreatedAtDesc().sortByMessageId()
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
/// - ~~LOCATION: 位置消息（已移除）~~
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
      ..status = protoMessage.hasStatus()
          ? protoMessage.status.name.toLowerCase()
          : 'sent'
      ..type =
          protoMessage.hasType() ? protoMessage.type.name.toLowerCase() : 'text'
      ..text = protoMessage.hasText() ? protoMessage.text : null
      ..mediaUrl = protoMessage.hasMediaUrl() ? protoMessage.mediaUrl : null
      ..localPath = protoMessage.hasLocalPath() ? protoMessage.localPath : null
      ..duration = protoMessage.hasDuration() ? protoMessage.duration : null
      ..fileSize = protoMessage.hasFileSize() ? protoMessage.fileSize : null
      ..fileName = protoMessage.hasFileName() ? protoMessage.fileName : null
      ..thumbnailUrl =
          protoMessage.hasThumbnailUrl() ? protoMessage.thumbnailUrl : null
      ..quotedMessageId = protoMessage.hasQuotedMessageId()
          ? protoMessage.quotedMessageId
          : null;

    return message;
  }

  /// 将数据库对象转换为Protocol Buffer对象
  ///
  /// 用于将Message对象转换为可序列化的Proto对象
  /// 便于网络传输和存储
  ///
  /// [message] - 数据库消息对象
  /// 返回：转换后的Protocol Buffer对象
  static proto.MessageProto toProto(Message message) {
    // 将字符串类型转换为枚举类型
    final messageType = _stringToMessageType(message.type);
    final messageStatus = _stringToMessageStatus(message.status);

    return proto.MessageProto(
      messageId: message.messageId,
      conversationId: message.conversationId,
      index: Int64(message.messageIndex),
      senderId: message.senderId,
      senderName: message.senderName,
      senderAvatar: message.senderAvatar,
      createdAt: Int64(message.createdAt.millisecondsSinceEpoch),
      status: messageStatus,
      type: messageType,
      text: message.text,
      mediaUrl: message.mediaUrl,
      localPath: message.localPath,
      duration: message.duration,
      fileSize: message.fileSize,
      fileName: message.fileName,
      thumbnailUrl: message.thumbnailUrl,
      quotedMessageId: message.quotedMessageId,
    );
  }

  /// 批量转换：从Proto列表转换为Message列表
  static List<Message> fromProtoList(List<proto.MessageProto> protoList) {
    return protoList.map((proto) => fromProto(proto)).toList();
  }

  /// 批量转换：从Message列表转换为Proto列表
  static List<proto.MessageProto> toProtoList(List<Message> messages) {
    return messages.map((message) => toProto(message)).toList();
  }

  /// 将字符串类型转换为Proto的枚举类型
  static proto.MessageType _stringToMessageType(String type) {
    switch (type.toLowerCase()) {
      case 'text':
        return proto.MessageType.TEXT;
      case 'image':
        return proto.MessageType.IMAGE;
      case 'voice':
        return proto.MessageType.VOICE;
      case 'video':
        return proto.MessageType.VIDEO;
      case 'file':
        return proto.MessageType.FILE;
      case 'system':
        return proto.MessageType.SYSTEM;
      default:
        return proto.MessageType.TEXT;
    }
  }

  /// 将字符串状态转换为Proto的枚举类型
  static proto.MessageStatus _stringToMessageStatus(String status) {
    switch (status.toLowerCase()) {
      case 'sending':
        return proto.MessageStatus.SENDING;
      case 'sent':
        return proto.MessageStatus.SENT;
      case 'delivered':
        return proto.MessageStatus.DELIVERED;
      case 'read':
        return proto.MessageStatus.READ;
      case 'failed':
        return proto.MessageStatus.FAILED;
      default:
        return proto.MessageStatus.SENT;
    }
  }

  /// 将Proto枚举类型转换为字符串类型
  static String messageTypeToString(proto.MessageType type) {
    switch (type) {
      case proto.MessageType.TEXT:
        return 'text';
      case proto.MessageType.IMAGE:
        return 'image';
      case proto.MessageType.VOICE:
        return 'voice';
      case proto.MessageType.VIDEO:
        return 'video';
      case proto.MessageType.FILE:
        return 'file';
      case proto.MessageType.SYSTEM:
        return 'system';
      default:
        return 'text';
    }
  }

  /// 将Proto枚举状态转换为字符串状态
  static String messageStatusToString(proto.MessageStatus status) {
    switch (status) {
      case proto.MessageStatus.SENDING:
        return 'sending';
      case proto.MessageStatus.SENT:
        return 'sent';
      case proto.MessageStatus.DELIVERED:
        return 'delivered';
      case proto.MessageStatus.READ:
        return 'read';
      case proto.MessageStatus.FAILED:
        return 'failed';
      default:
        return 'sent';
    }
  }
}
