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

  const ChatState({
    this.conversations = const [],
    this.contacts = const [],
    this.messagesByConversation = const {},
    this.currentConversationId,
    this.isLoading = false,
    this.error,
    this.searchQuery,
    this.searchResults = const [],
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
      ];
}
