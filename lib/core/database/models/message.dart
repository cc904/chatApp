import 'package:isar/isar.dart';
import 'package:fixnum/fixnum.dart';
import 'conversation.dart';
import 'package:cc/core/proto/generated/message.pb.dart' as proto;

part 'message.g.dart';

@collection
class Message {
  // Isar ID
  Id id = Isar.autoIncrement;

  // 消息ID (来自服务器)
  String messageId = '';

  @Index(composite: [CompositeIndex('createdAt')])
  late String conversationId;

  late String senderId;
  String? senderName;
  String? senderAvatar;

  DateTime createdAt = DateTime.now();
  bool isRead = false;

  // 消息发送状态：sending, sent, delivered, read, failed
  String status = 'sent';

  // 消息类型: text, image, voice, file, video, location, system
  late String type;

  // 消息内容(根据类型存储不同内容)
  String? text;

  // 媒体消息相关字段
  String? mediaUrl;
  String? localPath;
  int? duration; // 语音/视频时长(毫秒)
  double? fileSize; // 文件大小(KB)
  String? fileName; // 文件名
  String? thumbnailUrl; // 缩略图URL

  // 位置消息
  double? latitude;
  double? longitude;
  String? locationAddress;

  // 引用消息
  String? quotedMessageId;

  // 索引文本内容用于搜索
  @Index(type: IndexType.value, caseSensitive: false)
  String? get textForSearch => text;

  // 与会话的关系
  final conversation = IsarLink<Conversation>();

  /// 从 Protocol Buffer对象创建数据库对象
  ///
  /// 直接从MessageProto对象创建Message实例
  ///
  /// [proto] - 原始的Protocol Buffer对象
  /// 返回：转换后的数据库对象
  static Message fromProto(proto.MessageProto proto) {
    return Message()
      ..messageId = proto.messageId
      ..conversationId = proto.conversationId
      ..senderId = proto.senderId
      ..senderName = proto.hasSenderName() ? proto.senderName : null
      ..senderAvatar = proto.hasSenderAvatar() ? proto.senderAvatar : null
      ..createdAt = proto.hasCreatedAt()
          ? DateTime.fromMillisecondsSinceEpoch(proto.createdAt.toInt())
          : DateTime.now()
      ..isRead = proto.hasIsRead() ? proto.isRead : false
      ..status = proto.hasStatus() ? proto.status : 'sent'
      ..type = proto.hasType() ? proto.type.name : 'text'
      ..text = proto.hasText() ? proto.text : null
      ..mediaUrl = proto.hasMediaUrl() ? proto.mediaUrl : null
      ..localPath = proto.hasLocalPath() ? proto.localPath : null
      ..duration = proto.hasDuration() ? proto.duration : null
      ..fileSize = proto.hasFileSize() ? proto.fileSize : null
      ..fileName = proto.hasFileName() ? proto.fileName : null
      ..thumbnailUrl = proto.hasThumbnailUrl() ? proto.thumbnailUrl : null
      ..latitude = proto.hasLatitude() ? proto.latitude : null
      ..longitude = proto.hasLongitude() ? proto.longitude : null
      ..locationAddress =
          proto.hasLocationAddress() ? proto.locationAddress : null
      ..quotedMessageId =
          proto.hasQuotedMessageId() ? proto.quotedMessageId : null;
  }

  /// 将数据库对象转换为Protocol Buffer对象
  ///
  /// 用于将Message对象转换为可序列化的Proto对象
  /// 便于网络传输和存储
  ///
  /// 返回：转换后的Protocol Buffer对象
  proto.MessageProto toProto() {
    // 将字符串类型转换为枚举类型
    final messageType = _stringToMessageType(type);

    return proto.MessageProto(
      messageId: messageId,
      conversationId: conversationId,
      senderId: senderId,
      senderName: senderName,
      senderAvatar: senderAvatar,
      createdAt: Int64(createdAt.millisecondsSinceEpoch),
      isRead: isRead,
      status: status,
      type: messageType,
      text: text,
      mediaUrl: mediaUrl,
      localPath: localPath,
      duration: duration,
      fileSize: fileSize,
      fileName: fileName,
      thumbnailUrl: thumbnailUrl,
      latitude: latitude,
      longitude: longitude,
      locationAddress: locationAddress,
      quotedMessageId: quotedMessageId,
    );
  }

  /// 将字符串类型转换为Proto的枚举类型
  static proto.MessageType _stringToMessageType(String type) {
    switch (type.toLowerCase()) {
      case 'text':
        return proto.MessageType.text;
      case 'image':
        return proto.MessageType.image;
      case 'voice':
        return proto.MessageType.voice;
      case 'video':
        return proto.MessageType.video;
      case 'file':
        return proto.MessageType.file;
      case 'location':
        return proto.MessageType.location;
      case 'system':
        return proto.MessageType.system;
      default:
        return proto.MessageType.text;
    }
  }
}
