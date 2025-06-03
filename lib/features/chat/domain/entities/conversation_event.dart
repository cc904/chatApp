import 'package:cc/core/database/models/conversation.dart';

/// 会话更新事件类型
enum ConversationUpdateType {
  /// 新增会话
  added,

  /// 更新会话
  updated,

  /// 删除会话
  removed,

  /// 阅读状态更新
  readStatusUpdated,
}

/// 会话更新事件
class ConversationUpdateEvent {
  /// 会话ID
  final String conversationId;

  /// 更新类型
  final ConversationUpdateType type;

  /// 会话对象（新增和更新时有值）
  final Conversation? conversation;

  /// 最后一条消息预览
  final String? lastMessagePreview;

  /// 最后一条消息时间
  final DateTime? lastMessageTime;

  /// 未读消息数
  final int? unreadCount;

  /// 发送者ID
  final String? senderId;

  /// 发送者名称
  final String? senderName;

  /// 是否是静音状态
  final bool? isMuted;

  /// 是否是置顶状态
  final bool? isPinned;

  /// 最后阅读时间（用于阅读状态更新）
  final DateTime? lastReadAt;

  /// 最后阅读的消息ID（用于阅读状态更新）
  final String? lastReadMessageId;

  /// 构造函数
  ConversationUpdateEvent({
    required this.conversationId,
    required this.type,
    this.conversation,
    this.lastMessagePreview,
    this.lastMessageTime,
    this.unreadCount,
    this.senderId,
    this.senderName,
    this.isMuted,
    this.isPinned,
    this.lastReadAt,
    this.lastReadMessageId,
  });

  @override
  String toString() {
    return 'ConversationUpdateEvent{conversationId: $conversationId, type: $type, conversation: ${conversation?.name}, lastMessagePreview: $lastMessagePreview, lastMessageTime: $lastMessageTime, unreadCount: $unreadCount}';
  }
}

enum ConversationSyncType {
  /// 同步开始
  syncStarted,

  /// 同步完成
  syncCompleted,

  /// 同步错误
  syncError,
}

class ConversationSyncEvent {
  final ConversationSyncType type;
  final List<Conversation>? conversations;

  ConversationSyncEvent({required this.type, this.conversations});

  @override
  String toString() {
    return 'ConversationSyncEvent{type: $type, conversations: $conversations}';
  }
}
