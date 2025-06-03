import 'package:cc/core/database/models/message.dart';

/// 会话状态快照
///
/// 用于在用户快速切换会话时保存和恢复聊天状态
/// 避免重新加载数据，提升用户体验
class ChatStateSnapshot {
  /// 会话ID
  final String conversationId;

  /// 消息列表
  final List<Message> messages;

  /// 最后已读消息ID
  final String? lastReadMessageId;

  /// 未读消息数量
  final int unreadCount;

  /// 滚动位置（像素）
  final double? scrollPosition;

  /// 当前可见的消息ID
  final String? visibleMessageId;

  /// 创建时间戳
  final DateTime timestamp;

  /// 是否有更多历史消息
  final bool hasMoreHistory;

  /// 是否有更多新消息
  final bool hasMoreRecent;

  const ChatStateSnapshot({
    required this.conversationId,
    required this.messages,
    this.lastReadMessageId,
    required this.unreadCount,
    this.scrollPosition,
    this.visibleMessageId,
    required this.timestamp,
    this.hasMoreHistory = true,
    this.hasMoreRecent = false,
  });

  /// 检查快照是否仍然有效（5分钟内）
  bool get isValid {
    return DateTime.now().difference(timestamp).inMinutes < 5;
  }

  /// 获取快照年龄（秒）
  int get ageInSeconds {
    return DateTime.now().difference(timestamp).inSeconds;
  }

  /// 复制快照并更新字段
  ChatStateSnapshot copyWith({
    String? conversationId,
    List<Message>? messages,
    String? lastReadMessageId,
    int? unreadCount,
    double? scrollPosition,
    String? visibleMessageId,
    DateTime? timestamp,
    bool? hasMoreHistory,
    bool? hasMoreRecent,
  }) {
    return ChatStateSnapshot(
      conversationId: conversationId ?? this.conversationId,
      messages: messages ?? this.messages,
      lastReadMessageId: lastReadMessageId ?? this.lastReadMessageId,
      unreadCount: unreadCount ?? this.unreadCount,
      scrollPosition: scrollPosition ?? this.scrollPosition,
      visibleMessageId: visibleMessageId ?? this.visibleMessageId,
      timestamp: timestamp ?? this.timestamp,
      hasMoreHistory: hasMoreHistory ?? this.hasMoreHistory,
      hasMoreRecent: hasMoreRecent ?? this.hasMoreRecent,
    );
  }

  @override
  String toString() {
    return 'ChatStateSnapshot{conversationId: $conversationId, messageCount: ${messages.length}, scrollPosition: $scrollPosition, age: ${ageInSeconds}s}';
  }
}
