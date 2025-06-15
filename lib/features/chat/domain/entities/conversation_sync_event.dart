import 'package:cc/core/database/models/conversation.dart';

/// 会话同步类型枚举
enum ConversationSyncType {
  /// 同步开始
  syncStarted,

  /// 同步完成
  syncCompleted,

  /// 同步错误
  syncError,
}

/// 会话同步事件
/// 用于通知会话同步状态的变化
class ConversationSyncEvent {
  /// 同步类型
  final ConversationSyncType type;

  /// 同步的会话列表（可能为null）
  final List<Conversation>? conversations;

  /// 错误信息（同步失败时）
  final String? error;

  const ConversationSyncEvent({
    required this.type,
    this.conversations,
    this.error,
  });

  @override
  String toString() =>
      'ConversationSyncEvent{type: $type, conversationsCount: ${conversations?.length}, error: $error}';
}
