import 'package:cc/core/database/models/conversation.dart';

/// 会话更新事件类型
enum ConversationUpdateType {
  /// 新增会话
  added,
  
  /// 更新会话
  updated,
  
  /// 删除会话
  removed,
}

/// 会话更新事件
class ConversationUpdateEvent {
  /// 会话ID
  final String conversationId;
  
  /// 更新类型
  final ConversationUpdateType type;
  
  /// 会话对象（新增和更新时有值）
  final Conversation? conversation;
  
  /// 构造函数
  ConversationUpdateEvent({
    required this.conversationId,
    required this.type,
    this.conversation,
  });
  
  @override
  String toString() {
    return 'ConversationUpdateEvent{conversationId: $conversationId, type: $type, conversation: ${conversation?.name}}';
  }
}
