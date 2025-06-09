/// 消息游标信息
/// 用于记录消息同步的位置和状态
class MessageCursor {
  /// 游标消息ID
  final String? messageId;

  /// 游标时间戳
  final DateTime? timestamp;

  /// 游标位置（可选的复合键）
  final String? position;

  const MessageCursor({
    this.messageId,
    this.timestamp,
    this.position,
  });

  /// 从消息ID和时间戳创建游标
  factory MessageCursor.fromMessageData(String messageId, DateTime timestamp) {
    return MessageCursor(
      messageId: messageId,
      timestamp: timestamp,
      position: '${timestamp.millisecondsSinceEpoch}_$messageId',
    );
  }

  /// 空游标
  static const MessageCursor empty = MessageCursor();

  /// 是否为空游标
  bool get isEmpty => messageId == null && timestamp == null;

  /// 是否有效
  bool get isValid => messageId != null && timestamp != null;

  /// 复制并修改
  MessageCursor copyWith({
    String? messageId,
    DateTime? timestamp,
    String? position,
  }) {
    return MessageCursor(
      messageId: messageId ?? this.messageId,
      timestamp: timestamp ?? this.timestamp,
      position: position ?? this.position,
    );
  }

  @override
  String toString() {
    return 'MessageCursor(messageId: $messageId, timestamp: ${timestamp?.toIso8601String()}, position: $position)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MessageCursor &&
        other.messageId == messageId &&
        other.timestamp == timestamp &&
        other.position == position;
  }

  @override
  int get hashCode {
    return Object.hash(messageId, timestamp, position);
  }
}

/// 游标同步结果
/// 包含同步操作的结果信息和分页游标
class CursorSyncResult {
  /// 同步是否成功
  final bool success;

  /// 会话ID
  final String conversationId;

  /// 实际返回的消息数量
  final int returnedCount;

  /// 上一页游标
  final MessageCursor? prevCursor;

  /// 下一页游标
  final MessageCursor? nextCursor;

  /// 是否还有更早的消息
  final bool hasMoreBefore;

  /// 是否还有更新的消息
  final bool hasMoreAfter;

  /// 最旧消息的时间戳
  final DateTime? oldestTimestamp;

  /// 最新消息的时间戳
  final DateTime? newestTimestamp;

  /// 错误信息（失败时）
  final String? errorMessage;

  const CursorSyncResult({
    required this.success,
    required this.conversationId,
    this.returnedCount = 0,
    this.prevCursor,
    this.nextCursor,
    this.hasMoreBefore = false,
    this.hasMoreAfter = false,
    this.oldestTimestamp,
    this.newestTimestamp,
    this.errorMessage,
  });

  /// 成功的同步结果
  factory CursorSyncResult.success({
    required String conversationId,
    required int returnedCount,
    MessageCursor? prevCursor,
    MessageCursor? nextCursor,
    bool hasMoreBefore = false,
    bool hasMoreAfter = false,
    DateTime? oldestTimestamp,
    DateTime? newestTimestamp,
  }) {
    return CursorSyncResult(
      success: true,
      conversationId: conversationId,
      returnedCount: returnedCount,
      prevCursor: prevCursor,
      nextCursor: nextCursor,
      hasMoreBefore: hasMoreBefore,
      hasMoreAfter: hasMoreAfter,
      oldestTimestamp: oldestTimestamp,
      newestTimestamp: newestTimestamp,
    );
  }

  /// 失败的同步结果
  factory CursorSyncResult.failure({
    required String conversationId,
    required String errorMessage,
  }) {
    return CursorSyncResult(
      success: false,
      conversationId: conversationId,
      errorMessage: errorMessage,
    );
  }

  /// 复制并修改
  CursorSyncResult copyWith({
    bool? success,
    String? conversationId,
    int? returnedCount,
    MessageCursor? prevCursor,
    MessageCursor? nextCursor,
    bool? hasMoreBefore,
    bool? hasMoreAfter,
    DateTime? oldestTimestamp,
    DateTime? newestTimestamp,
    String? errorMessage,
  }) {
    return CursorSyncResult(
      success: success ?? this.success,
      conversationId: conversationId ?? this.conversationId,
      returnedCount: returnedCount ?? this.returnedCount,
      prevCursor: prevCursor ?? this.prevCursor,
      nextCursor: nextCursor ?? this.nextCursor,
      hasMoreBefore: hasMoreBefore ?? this.hasMoreBefore,
      hasMoreAfter: hasMoreAfter ?? this.hasMoreAfter,
      oldestTimestamp: oldestTimestamp ?? this.oldestTimestamp,
      newestTimestamp: newestTimestamp ?? this.newestTimestamp,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  String toString() {
    return 'CursorSyncResult(success: $success, conversationId: $conversationId, returnedCount: $returnedCount, hasMoreBefore: $hasMoreBefore, hasMoreAfter: $hasMoreAfter)';
  }
}
