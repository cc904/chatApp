import 'package:cc/core/database/models/conversation.dart';

/// 会话更新类型枚举
enum ConversationUpdateType {
  /// 添加会话
  added,

  /// 更新会话
  updated,

  /// 删除会话
  deleted,
}

/// 会话更新事件
class ConversationUpdateEvent {
  /// 会话ID
  final String conversationId;

  /// 更新类型
  final ConversationUpdateType type;

  /// 会话数据（添加和更新时有值）
  final Conversation? conversation;

  /// 构造函数
  const ConversationUpdateEvent({
    required this.conversationId,
    required this.type,
    this.conversation,
  });
}
