import 'package:equatable/equatable.dart';
import 'package:cc/core/database/models/user.dart';
import 'package:cc/core/database/models/conversation.dart';
import 'package:cc/core/database/models/message.dart';

/// 聊天状态类
class ChatState extends Equatable {
  final List<Conversation> conversations;
  final List<User> contacts;
  final Map<String, List<Message>> messagesByConversation;
  final String? currentConversationId;
  final bool isLoading;
  final String? error;
  final String? searchQuery;
  final List<dynamic> searchResults; // 可能是联系人、会话或消息
  // 页面间交互数据
  final Map<String, dynamic>? navigationData;

  const ChatState({
    this.conversations = const [],
    this.contacts = const [],
    this.messagesByConversation = const {},
    this.currentConversationId,
    this.isLoading = false,
    this.error,
    this.searchQuery,
    this.searchResults = const [],
    this.navigationData,
  });

  /// 获取当前会话
  Conversation? get currentConversation {
    if (currentConversationId == null) return null;
    try {
      return conversations.firstWhere(
        (conversation) => conversation.id.toString() == currentConversationId,
      );
    } catch (e) {
      return null;
    }
  }

  /// 获取当前会话的消息
  List<Message> get currentMessages {
    if (currentConversationId == null) return [];
    return messagesByConversation[currentConversationId] ?? [];
  }

  /// 创建初始状态
  factory ChatState.initial() {
    return const ChatState();
  }

  /// 创建加载中状态
  ChatState copyWithLoading() {
    return ChatState(
      conversations: conversations,
      contacts: contacts,
      messagesByConversation: messagesByConversation,
      currentConversationId: currentConversationId,
      isLoading: true,
      error: null,
      searchQuery: searchQuery,
      searchResults: searchResults,
      navigationData: navigationData,
    );
  }

  /// 创建错误状态
  ChatState copyWithError(String errorMessage) {
    return ChatState(
      conversations: conversations,
      contacts: contacts,
      messagesByConversation: messagesByConversation,
      currentConversationId: currentConversationId,
      isLoading: false,
      error: errorMessage,
      searchQuery: searchQuery,
      searchResults: searchResults,
      navigationData: navigationData,
    );
  }

  /// 复制状态，更新指定字段
  ChatState copyWith({
    List<Conversation>? conversations,
    List<User>? contacts,
    Map<String, List<Message>>? messagesByConversation,
    String? currentConversationId,
    bool? isLoading,
    String? error,
    String? searchQuery,
    List<dynamic>? searchResults,
    Map<String, dynamic>? navigationData,
  }) {
    return ChatState(
      conversations: conversations ?? this.conversations,
      contacts: contacts ?? this.contacts,
      messagesByConversation: messagesByConversation ?? this.messagesByConversation,
      currentConversationId: currentConversationId ?? this.currentConversationId,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      searchQuery: searchQuery ?? this.searchQuery,
      searchResults: searchResults ?? this.searchResults,
      navigationData: navigationData ?? this.navigationData,
    );
  }

  /// 复制状态，但仅更新某个会话的消息
  ChatState copyWithMessagesForConversation(String conversationId, List<Message> messages) {
    final newMessagesByConversation = Map<String, List<Message>>.from(messagesByConversation);
    newMessagesByConversation[conversationId] = messages;

    return ChatState(
      conversations: conversations,
      contacts: contacts,
      messagesByConversation: newMessagesByConversation,
      currentConversationId: currentConversationId,
      isLoading: isLoading,
      error: error,
      searchQuery: searchQuery,
      searchResults: searchResults,
      navigationData: navigationData,
    );
  }

  /// 复制状态，并将新的消息添加到指定会话的现有消息列表中
  ChatState copyWithAdditionalMessagesForConversation(String conversationId, List<Message> additionalMessages) {
    final newMessagesByConversation = Map<String, List<Message>>.from(messagesByConversation);

    // 获取现有消息
    final existingMessages = newMessagesByConversation[conversationId] ?? [];

    // 合并消息并去重
    final allMessageIds = <String>{};
    final mergedMessages = <Message>[];

    // 添加现有消息
    for (final message in existingMessages) {
      if (!allMessageIds.contains(message.id.toString())) {
        allMessageIds.add(message.id.toString());
        mergedMessages.add(message);
      }
    }

    // 添加新消息，确保不重复
    for (final message in additionalMessages) {
      if (!allMessageIds.contains(message.id.toString())) {
        allMessageIds.add(message.id.toString());
        mergedMessages.add(message);
      }
    }

    // 按时间排序
    mergedMessages.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // 更新消息列表
    newMessagesByConversation[conversationId] = mergedMessages;

    return ChatState(
      conversations: conversations,
      contacts: contacts,
      messagesByConversation: newMessagesByConversation,
      currentConversationId: currentConversationId,
      isLoading: isLoading,
      error: error,
      searchQuery: searchQuery,
      searchResults: searchResults,
      navigationData: navigationData,
    );
  }

  /// 清除导航数据但保留其他状态
  ChatState copyWithClearedNavigationData() {
    return ChatState(
      conversations: conversations,
      contacts: contacts,
      messagesByConversation: messagesByConversation,
      currentConversationId: currentConversationId,
      isLoading: isLoading,
      error: error,
      searchQuery: searchQuery,
      searchResults: searchResults,
      navigationData: null,
    );
  }

  @override
  List<Object?> get props => [
        conversations,
        contacts,
        messagesByConversation,
        currentConversationId,
        isLoading,
        error,
        searchQuery,
        searchResults,
        navigationData,
      ];
}
