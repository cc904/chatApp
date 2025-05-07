import 'package:isar/isar.dart';
import 'conversation.dart';

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
}
