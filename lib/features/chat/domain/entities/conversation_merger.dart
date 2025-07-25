import 'package:cc/core/database/drift_database.dart';
import 'package:cc/features/chat/domain/entities/conversation_update_event.dart';

/// 会话列表智能合并工具
/// 提供各种会话更新场景下的列表合并逻辑
class ConversationMerger {
  /// 智能合并会话列表
  /// 根据会话ID去重并保持排序
  static List<Conversation> smartMergeConversations(
    List<Conversation> existingConversations,
    List<Conversation> newConversations,
  ) {
    // 使用Map来去重，conversationId作为key
    final conversationMap = <String, Conversation>{};

    // 先添加现有会话
    for (final conversation in existingConversations) {
      conversationMap[conversation.conversationId] = conversation;
    }

    // 再添加新会话（会覆盖重复的）
    for (final conversation in newConversations) {
      conversationMap[conversation.conversationId] = conversation;
    }

    // 转换为列表并排序（最后消息时间倒序）
    final mergedList = conversationMap.values.toList();
    sortConversations(mergedList);

    return mergedList;
  }

  /// 更新单个会话
  static List<Conversation> updateSingleConversation(
    List<Conversation> conversations,
    Conversation updatedConversation,
  ) {
    final updatedList = List<Conversation>.from(conversations);

    final index = updatedList.indexWhere(
      (c) => c.conversationId == updatedConversation.conversationId,
    );

    if (index != -1) {
      updatedList[index] = updatedConversation;
    } else {
      // 如果找不到，则添加新会话
      updatedList.add(updatedConversation);
    }

    // 重新排序
    sortConversations(updatedList);
    return updatedList;
  }

  /// 添加新会话
  static List<Conversation> addConversation(
    List<Conversation> conversations,
    Conversation newConversation,
  ) {
    final updatedList = List<Conversation>.from(conversations);

    // 检查是否已存在
    final existingIndex = updatedList.indexWhere(
      (c) => c.conversationId == newConversation.conversationId,
    );

    if (existingIndex == -1) {
      updatedList.add(newConversation);
      sortConversations(updatedList);
    }

    return updatedList;
  }

  /// 移除会话
  static List<Conversation> removeConversation(
    List<Conversation> conversations,
    String conversationId,
  ) {
    return conversations
        .where((c) => c.conversationId != conversationId)
        .toList();
  }

  /// 根据事件类型处理会话更新
  static List<Conversation> handleConversationUpdate(
    List<Conversation> currentConversations,
    ConversationUpdateEvent event,
  ) {
    switch (event) {
      case ConversationAddedEvent(:final conversation):
        return addConversation(currentConversations, conversation);

      case ConversationUpdatedEvent(:final updatedConversation):
        return updateSingleConversation(
            currentConversations, updatedConversation);

      case ConversationRemovedEvent(:final conversationId):
        return removeConversation(currentConversations, conversationId);

      case ConversationsReloadedEvent(:final conversations):
        // 完全重载
        final sortedList = List<Conversation>.from(conversations);
        sortConversations(sortedList);
        return sortedList;

      case ConversationParticipantSettingsUpdatedEvent():
        // 参与者设置更新通常会通过ConversationUpdatedEvent处理
        return currentConversations;

      default:
        return currentConversations;
    }
  }

  /// 统一的会话排序方法
  /// 按最后消息时间倒序排列，没有消息的会话按创建时间排序
  static void sortConversations(List<Conversation> conversations) {
    conversations.sort((a, b) {
      // 如果两个会话都没有最后消息时间，按创建时间倒序排序
      if (a.lastMessageTime == null && b.lastMessageTime == null) {
        return b.createdAt.compareTo(a.createdAt);
      }
      // 如果 a 没有最后消息时间，排在后面
      if (a.lastMessageTime == null) {
        return 1;
      }
      // 如果 b 没有最后消息时间，排在后面
      if (b.lastMessageTime == null) {
        return -1;
      }
      // 都有最后消息时间，按时间倒序排序（最新的在前）
      return b.lastMessageTime!.compareTo(a.lastMessageTime!);
    });
  }
}
