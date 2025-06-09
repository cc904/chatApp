import 'package:fixnum/fixnum.dart';
import 'package:cc/core/database/models/message.dart';
import 'package:cc/core/proto/generated/message.pb.dart' as proto;

/// 消息数据转换适配器
///
/// 负责处理Message模型与Protocol Buffer之间的数据转换
/// 遵循DDD架构原则，将转换逻辑从模型中分离出来
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
      ..latitude = protoMessage.hasLatitude() ? protoMessage.latitude : null
      ..longitude = protoMessage.hasLongitude() ? protoMessage.longitude : null
      ..locationAddress = protoMessage.hasLocationAddress()
          ? protoMessage.locationAddress
          : null
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
      latitude: message.latitude,
      longitude: message.longitude,
      locationAddress: message.locationAddress,
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
      case 'location':
        return proto.MessageType.LOCATION;
      case 'system':
        return proto.MessageType.SYSTEM;
      case 'sticker':
        return proto.MessageType.STICKER;
      case 'gif':
        return proto.MessageType.GIF;
      case 'contact':
        return proto.MessageType.CONTACT;
      case 'poll':
        return proto.MessageType.POLL;
      case 'link':
        return proto.MessageType.LINK;
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
      case proto.MessageType.LOCATION:
        return 'location';
      case proto.MessageType.SYSTEM:
        return 'system';
      case proto.MessageType.STICKER:
        return 'sticker';
      case proto.MessageType.GIF:
        return 'gif';
      case proto.MessageType.CONTACT:
        return 'contact';
      case proto.MessageType.POLL:
        return 'poll';
      case proto.MessageType.LINK:
        return 'link';
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
