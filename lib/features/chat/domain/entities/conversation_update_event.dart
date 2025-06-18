import 'package:cc/core/database/models/conversation.dart';

/// 会话更新事件的基类
abstract class ConversationUpdateEvent {
  final String conversationId;
  final DateTime timestamp;

  const ConversationUpdateEvent({
    required this.conversationId,
    required this.timestamp,
  });
}

/// 会话添加事件
class ConversationAddedEvent extends ConversationUpdateEvent {
  final Conversation conversation;

  ConversationAddedEvent({
    required this.conversation,
    required DateTime timestamp,
  }) : super(
          conversationId: conversation.conversationId,
          timestamp: timestamp,
        );
}

/// 会话更新事件
class ConversationUpdatedEvent extends ConversationUpdateEvent {
  final Conversation updatedConversation;
  final List<String> updatedFields;

  ConversationUpdatedEvent({
    required this.updatedConversation,
    required this.updatedFields,
    required DateTime timestamp,
  }) : super(
          conversationId: updatedConversation.conversationId,
          timestamp: timestamp,
        );
}

/// 会话删除事件
class ConversationRemovedEvent extends ConversationUpdateEvent {
  const ConversationRemovedEvent({
    required String conversationId,
    required DateTime timestamp,
  }) : super(
          conversationId: conversationId,
          timestamp: timestamp,
        );
}

/// 会话列表重载事件（用于初始加载或大批量更新）
class ConversationsReloadedEvent extends ConversationUpdateEvent {
  final List<Conversation> conversations;

  const ConversationsReloadedEvent({
    required this.conversations,
    required DateTime timestamp,
  }) : super(
          conversationId: '', // 列表事件不针对特定会话
          timestamp: timestamp,
        );
}

/// 会话参与者设置更新事件
class ConversationParticipantSettingsUpdatedEvent
    extends ConversationUpdateEvent {
  final String userId;
  final Map<String, dynamic> updatedSettings;

  const ConversationParticipantSettingsUpdatedEvent({
    required String conversationId,
    required this.userId,
    required this.updatedSettings,
    required DateTime timestamp,
  }) : super(
          conversationId: conversationId,
          timestamp: timestamp,
        );
}
