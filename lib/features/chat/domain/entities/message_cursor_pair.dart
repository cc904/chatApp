import 'message_cursor.dart';

/// 消息游标对实体
/// 表示时间线上的一个消息段，包含起始和结束游标
class MessageCursorPair {
  /// 唯一标识符
  final String id;

  /// 会话ID
  final String conversationId;

  /// 游标对类型
  final CursorPairType type;

  /// 起始游标（时间线上较早的位置）
  final MessageCursor startCursor;

  /// 结束游标（时间线上较晚的位置）
  final MessageCursor endCursor;

  /// 该段是否已同步完成
  final bool isSynced;

  /// 该段的消息数量（如果已知）
  final int? messageCount;

  /// 创建时间
  final DateTime createdAt;

  /// 最后更新时间
  final DateTime updatedAt;

  /// 优先级（数字越大优先级越高）
  final int priority;

  /// 附加元数据
  final Map<String, dynamic>? metadata;

  const MessageCursorPair({
    required this.id,
    required this.conversationId,
    required this.type,
    required this.startCursor,
    required this.endCursor,
    this.isSynced = false,
    this.messageCount,
    required this.createdAt,
    required this.updatedAt,
    this.priority = 0,
    this.metadata,
  });

  /// 工厂构造函数：创建空档游标对
  factory MessageCursorPair.gap({
    required String conversationId,
    required MessageCursor startCursor,
    required MessageCursor endCursor,
    int priority = 10, // 空档优先级较高
    Map<String, dynamic>? metadata,
  }) {
    final now = DateTime.now();
    return MessageCursorPair(
      id: 'gap_${startCursor.messageId}_${endCursor.messageId}',
      conversationId: conversationId,
      type: CursorPairType.gap,
      startCursor: startCursor,
      endCursor: endCursor,
      priority: priority,
      createdAt: now,
      updatedAt: now,
      metadata: metadata,
    );
  }

  /// 工厂构造函数：创建历史消息游标对
  factory MessageCursorPair.history({
    required String conversationId,
    required MessageCursor startCursor,
    required MessageCursor endCursor,
    bool isSynced = true,
    int? messageCount,
    int priority = 5,
    Map<String, dynamic>? metadata,
  }) {
    final now = DateTime.now();
    return MessageCursorPair(
      id: 'history_${startCursor.messageId}_${endCursor.messageId}',
      conversationId: conversationId,
      type: CursorPairType.history,
      startCursor: startCursor,
      endCursor: endCursor,
      isSynced: isSynced,
      messageCount: messageCount,
      priority: priority,
      createdAt: now,
      updatedAt: now,
      metadata: metadata,
    );
  }

  /// 工厂构造函数：创建实时消息游标对
  factory MessageCursorPair.realtime({
    required String conversationId,
    required MessageCursor startCursor,
    required MessageCursor endCursor,
    bool isSynced = true,
    int? messageCount,
    int priority = 15,
    Map<String, dynamic>? metadata,
  }) {
    final now = DateTime.now();
    return MessageCursorPair(
      id: 'realtime_${startCursor.messageId}_${endCursor.messageId}',
      conversationId: conversationId,
      type: CursorPairType.realtime,
      startCursor: startCursor,
      endCursor: endCursor,
      isSynced: isSynced,
      messageCount: messageCount,
      priority: priority,
      createdAt: now,
      updatedAt: now,
      metadata: metadata,
    );
  }

  /// 检查是否为有效的游标对
  bool get isValid {
    return startCursor.isValid &&
        endCursor.isValid &&
        startCursor.timestamp!.isBefore(endCursor.timestamp!);
  }

  /// 获取时间跨度（毫秒）
  int get timeSpanMs {
    if (!isValid) return 0;
    return endCursor.timestamp!
        .difference(startCursor.timestamp!)
        .inMilliseconds;
  }

  /// 获取时间跨度（人类可读）
  String get timeSpanHuman {
    if (!isValid) return '无效';
    final duration = endCursor.timestamp!.difference(startCursor.timestamp!);
    if (duration.inDays > 0) {
      return '${duration.inDays}天${duration.inHours % 24}小时';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}小时${duration.inMinutes % 60}分钟';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}分钟${duration.inSeconds % 60}秒';
    } else {
      return '${duration.inSeconds}秒';
    }
  }

  /// 检查是否与另一个游标对有重叠
  bool overlapsWith(MessageCursorPair other) {
    if (!isValid || !other.isValid) return false;

    return !(endCursor.timestamp!.isBefore(other.startCursor.timestamp!) ||
        startCursor.timestamp!.isAfter(other.endCursor.timestamp!));
  }

  /// 检查是否可以与另一个游标对合并
  bool canMergeWith(MessageCursorPair other) {
    if (conversationId != other.conversationId || type != other.type) {
      return false;
    }

    // 检查是否相邻或重叠
    return overlapsWith(other) ||
        endCursor.timestamp!.isAtSameMomentAs(other.startCursor.timestamp!) ||
        startCursor.timestamp!.isAtSameMomentAs(other.endCursor.timestamp!);
  }

  /// 与另一个游标对合并
  MessageCursorPair mergeWith(MessageCursorPair other) {
    if (!canMergeWith(other)) {
      throw ArgumentError('无法合并不兼容的游标对');
    }

    final newStartCursor =
        startCursor.timestamp!.isBefore(other.startCursor.timestamp!)
            ? startCursor
            : other.startCursor;
    final newEndCursor =
        endCursor.timestamp!.isAfter(other.endCursor.timestamp!)
            ? endCursor
            : other.endCursor;

    final newMessageCount = (messageCount ?? 0) + (other.messageCount ?? 0);
    final newIsSynced = isSynced && other.isSynced;
    final newPriority = (priority + other.priority) ~/ 2;

    return MessageCursorPair(
      id: 'merged_${newStartCursor.messageId}_${newEndCursor.messageId}',
      conversationId: conversationId,
      type: type,
      startCursor: newStartCursor,
      endCursor: newEndCursor,
      isSynced: newIsSynced,
      messageCount: newMessageCount > 0 ? newMessageCount : null,
      priority: newPriority,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
          (createdAt.millisecondsSinceEpoch +
                  other.createdAt.millisecondsSinceEpoch) ~/
              2),
      updatedAt: DateTime.now(),
      metadata: {...?metadata, ...?other.metadata},
    );
  }

  /// 复制并更新属性
  MessageCursorPair copyWith({
    String? id,
    String? conversationId,
    CursorPairType? type,
    MessageCursor? startCursor,
    MessageCursor? endCursor,
    bool? isSynced,
    int? messageCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? priority,
    Map<String, dynamic>? metadata,
  }) {
    return MessageCursorPair(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      type: type ?? this.type,
      startCursor: startCursor ?? this.startCursor,
      endCursor: endCursor ?? this.endCursor,
      isSynced: isSynced ?? this.isSynced,
      messageCount: messageCount ?? this.messageCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      priority: priority ?? this.priority,
      metadata: metadata ?? this.metadata,
    );
  }

  /// 转换为调试字符串
  @override
  String toString() {
    return 'MessageCursorPair(id: $id, type: $type, span: $timeSpanHuman, synced: $isSynced, messages: $messageCount)';
  }

  /// 转换为Map（用于序列化）
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'conversationId': conversationId,
      'type': type.name,
      'startCursor': startCursor.toMap(),
      'endCursor': endCursor.toMap(),
      'isSynced': isSynced,
      'messageCount': messageCount,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'priority': priority,
      'metadata': metadata,
    };
  }

  /// 从Map创建（用于反序列化）
  factory MessageCursorPair.fromMap(Map<String, dynamic> map) {
    return MessageCursorPair(
      id: map['id'],
      conversationId: map['conversationId'],
      type: CursorPairType.values.firstWhere((e) => e.name == map['type']),
      startCursor: MessageCursor.fromMap(map['startCursor']),
      endCursor: MessageCursor.fromMap(map['endCursor']),
      isSynced: map['isSynced'] ?? false,
      messageCount: map['messageCount'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
      priority: map['priority'] ?? 0,
      metadata: map['metadata']?.cast<String, dynamic>(),
    );
  }
}

/// 游标对类型枚举
enum CursorPairType {
  /// 历史消息段
  history,

  /// 空档段（需要同步）
  gap,

  /// 实时消息段
  realtime,

  /// 用户手动请求的段
  manual,

  /// 系统预加载的段
  preload,
}

/// 游标对类型扩展
extension CursorPairTypeExtension on CursorPairType {
  /// 获取类型描述
  String get description {
    switch (this) {
      case CursorPairType.history:
        return '历史消息段';
      case CursorPairType.gap:
        return '空档段';
      case CursorPairType.realtime:
        return '实时消息段';
      case CursorPairType.manual:
        return '手动请求段';
      case CursorPairType.preload:
        return '预加载段';
    }
  }

  /// 获取默认优先级
  int get defaultPriority {
    switch (this) {
      case CursorPairType.realtime:
        return 15;
      case CursorPairType.gap:
        return 10;
      case CursorPairType.manual:
        return 8;
      case CursorPairType.history:
        return 5;
      case CursorPairType.preload:
        return 3;
    }
  }
}
