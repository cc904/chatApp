import 'package:isar/isar.dart';
import 'conversation.dart';

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
  @Index(composite: [CompositeIndex('createdAt'), CompositeIndex('messageId')])
  late String conversationId;

  late String senderId;
  String? senderName;
  String? senderAvatar;

  // 创建时间 - 用于时间排序
  DateTime createdAt = DateTime.now();

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

  // 辅助方法：判断消息是否已读
  @ignore
  bool get isRead => status == 'read';

  // 辅助方法：判断消息是否已送达
  @ignore
  bool get isDelivered => status == 'delivered' || status == 'read';

  // 与会话的关系
  final conversation = IsarLink<Conversation>();
}
