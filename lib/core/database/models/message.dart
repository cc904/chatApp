import 'package:isar/isar.dart';
import 'package:fixnum/fixnum.dart';
import 'conversation.dart';
import 'package:cc/core/proto/generated/message.pb.dart' as proto;
import 'package:cc/core/proto/generated/message.pbenum.dart';

part 'message.g.dart';

/*
## 📊 Message数据库模型 - 索引优化说明

### 🎯 索引设计理念

在聊天应用中，消息查询的性能至关重要。Isar数据库中的数据并不是按时间顺序自动存储的，
因此我们需要通过合理的索引设计来确保查询效率。

### 🔍 索引配置

1. **messageId**: `@Index(unique: true)`
   - 唯一索引，确保消息ID不重复
   - 用于快速查找特定消息

2. **conversationId + createdAt**: `@Index(composite: [CompositeIndex('createdAt')])`
   - 复合索引，优化最常见的查询模式
   - 支持按会话ID查询并按时间排序
   - 这是最关键的索引，支持以下查询：
     * 获取会话的最新/最早消息
     * 按时间范围查询消息
     * 分页查询会话消息

3. **textForSearch**: `@Index(type: IndexType.value, caseSensitive: false)`
   - 全文搜索索引，支持消息内容搜索
   - 不区分大小写

### 🚀 性能优化效果

```dart
// ✅ 高效查询 - 利用复合索引
final messages = await _messages
    .filter()
    .conversationIdEqualTo(conversationId)  // 使用索引过滤
    .sortByCreatedAtDesc()                  // 使用索引排序
    .limit(20)
    .findAll();

// ✅ 高效查询 - 获取时间范围
final earliest = await _messages
    .filter()
    .conversationIdEqualTo(conversationId)
    .sortByCreatedAt()                      // 索引排序
    .limit(1)
    .findFirst();
```

### 📈 查询复杂度

- **无索引**: O(n) - 需要扫描所有消息
- **有索引**: O(log n) - 利用B+树快速定位

对于包含10万条消息的会话，索引可以将查询时间从几百毫秒降低到几毫秒。
*/

@collection
class Message {
  // Isar ID
  Id id = Isar.autoIncrement;

  // 消息ID (来自服务器)
  @Index(unique: true, replace: true)
  String messageId = '';

  // 会话ID和创建时间的复合索引 - 优化按会话查询和时间排序
  @Index(composite: [CompositeIndex('createdAt')])
  late String conversationId;

  late String senderId;
  String? senderName;
  String? senderAvatar;

  // 创建时间 - 用于时间排序
  DateTime createdAt = DateTime.now();

  bool isRead = false;
  bool isDelivered = false;

  // 消息发送状态：sending, sent, delivered, read, failed
  String status = 'sent';

  // 错误信息（发送失败时使用）
  String? errorMessage;

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
    final message = Message()
      ..messageId = proto.messageId
      ..conversationId = proto.conversationId
      ..senderId = proto.senderId
      ..senderName = proto.hasSenderName() ? proto.senderName : null
      ..senderAvatar = proto.hasSenderAvatar() ? proto.senderAvatar : null
      ..createdAt = proto.hasCreatedAt()
          ? DateTime.fromMillisecondsSinceEpoch(proto.createdAt.toInt())
          : DateTime.now()
      ..status = proto.hasStatus() ? proto.status.name.toLowerCase() : 'sent'
      ..type = proto.hasType() ? proto.type.name.toLowerCase() : 'text'
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

    // 根据status设置isRead和isDelivered字段
    if (proto.hasStatus()) {
      switch (proto.status) {
        case MessageStatus.READ:
          message.isRead = true;
          message.isDelivered = true;
          break;
        case MessageStatus.DELIVERED:
          message.isRead = false;
          message.isDelivered = true;
          break;
        case MessageStatus.SENT:
        case MessageStatus.SENDING:
        case MessageStatus.FAILED:
        default:
          message.isRead = false;
          message.isDelivered = false;
          break;
      }
    }

    return message;
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
    final messageStatus = _stringToMessageStatus(status);

    return proto.MessageProto(
      messageId: messageId,
      conversationId: conversationId,
      senderId: senderId,
      senderName: senderName,
      senderAvatar: senderAvatar,
      createdAt: Int64(createdAt.millisecondsSinceEpoch),
      status: messageStatus,
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
}
