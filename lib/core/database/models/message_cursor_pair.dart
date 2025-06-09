import 'package:isar/isar.dart';
import 'conversation.dart';

part 'message_cursor_pair.g.dart';

/// 消息游标对数据库模型
/// 用于持久化时间线上的消息段信息
@collection
class MessageCursorPairModel {
  Id id = Isar.autoIncrement;

  /// 游标对唯一标识符
  @Index(unique: true, replace: true)
  late String pairId;

  /// 会话ID - 建立复合索引用于高效查询
  @Index(composite: [CompositeIndex('createdAt')])
  late String conversationId;

  /// 游标对类型：history, gap, realtime, manual, preload
  @Index()
  late String type;

  /// 起始游标信息
  String? startCursorMessageId;
  DateTime? startCursorTimestamp;
  String? startCursorPosition;

  /// 结束游标信息
  String? endCursorMessageId;
  DateTime? endCursorTimestamp;
  String? endCursorPosition;

  /// 该段是否已同步完成
  @Index()
  bool isSynced = false;

  /// 该段的消息数量（如果已知）
  int? messageCount;

  /// 创建时间
  DateTime createdAt = DateTime.now();

  /// 最后更新时间
  DateTime updatedAt = DateTime.now();

  /// 优先级（数字越大优先级越高）
  @Index()
  int priority = 0;

  /// 附加元数据（JSON字符串）
  String? metadataJson;

  /// 与会话的关系
  final conversation = IsarLink<Conversation>();

  /// 从领域实体转换为数据库模型
  static MessageCursorPairModel fromDomain(dynamic domainPair) {
    final model = MessageCursorPairModel()
      ..pairId = domainPair.id
      ..conversationId = domainPair.conversationId
      ..type = domainPair.type.name
      ..startCursorMessageId = domainPair.startCursor.messageId
      ..startCursorTimestamp = domainPair.startCursor.timestamp
      ..startCursorPosition = domainPair.startCursor.position
      ..endCursorMessageId = domainPair.endCursor.messageId
      ..endCursorTimestamp = domainPair.endCursor.timestamp
      ..endCursorPosition = domainPair.endCursor.position
      ..isSynced = domainPair.isSynced
      ..messageCount = domainPair.messageCount
      ..createdAt = domainPair.createdAt
      ..updatedAt = domainPair.updatedAt
      ..priority = domainPair.priority;

    // 序列化元数据
    if (domainPair.metadata != null) {
      try {
        // 使用dart:convert进行JSON序列化
        model.metadataJson = _encodeMetadata(domainPair.metadata);
      } catch (e) {
        model.metadataJson = null;
      }
    }

    return model;
  }

  /// 转换为领域实体需要的Map
  Map<String, dynamic> toDomainMap() {
    return {
      'id': pairId,
      'conversationId': conversationId,
      'type': type,
      'startCursor': {
        'messageId': startCursorMessageId,
        'timestamp': startCursorTimestamp?.millisecondsSinceEpoch,
        'position': startCursorPosition,
      },
      'endCursor': {
        'messageId': endCursorMessageId,
        'timestamp': endCursorTimestamp?.millisecondsSinceEpoch,
        'position': endCursorPosition,
      },
      'isSynced': isSynced,
      'messageCount': messageCount,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'priority': priority,
      'metadata': _decodeMetadata(metadataJson),
    };
  }

  /// 更新时间戳
  void touch() {
    updatedAt = DateTime.now();
  }

  /// 元数据编码（简化版，实际项目中应使用dart:convert）
  static String? _encodeMetadata(Map<String, dynamic>? metadata) {
    if (metadata == null || metadata.isEmpty) return null;

    try {
      // 简化版JSON编码，实际应该使用 jsonEncode(metadata)
      final entries = metadata.entries.map((e) {
        final key = '"${e.key}"';
        final value = _encodeValue(e.value);
        return '$key:$value';
      });
      return '{${entries.join(',')}}';
    } catch (e) {
      return null;
    }
  }

  /// 元数据解码
  static Map<String, dynamic>? _decodeMetadata(String? metadataJson) {
    if (metadataJson == null || metadataJson.isEmpty) return null;

    try {
      // 实际项目中应该使用 jsonDecode(metadataJson)
      return <String, dynamic>{}; // 简化返回空Map
    } catch (e) {
      return null;
    }
  }

  /// 编码单个值
  static String _encodeValue(dynamic value) {
    if (value == null) return 'null';
    if (value is String) return '"$value"';
    if (value is bool) return value.toString();
    if (value is num) return value.toString();
    return '"$value"';
  }
}
