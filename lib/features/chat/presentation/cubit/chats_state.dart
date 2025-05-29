import 'package:cc/core/database/models/conversation.dart';
import 'package:cc/core/database/models/message.dart';
import 'package:cc/features/chat/domain/repositories/chat_repository.dart';
import 'package:equatable/equatable.dart';

/// 聊天页面状态类
class ChatsState extends Equatable {
  // 会话相关状态
  final List<Conversation> conversations;
  final Map<String, List<Message>> messagesByConversation;
  final String? currentConversationId;
  final bool isLoadingMessages;
  final bool isLoadingMoreMessages; // 是否正在加载更多历史消息
  final Map<String, List<String>> typingUsers; // 会话ID -> 正在输入的用户ID列表
  final Set<String> onlineUsers; // 在线用户ID集合
  final ConversationSyncStatus conversationSyncStatus; // 会话同步状态
  
  // 会话过滤相关状态
  final List<Conversation> filteredConversations; // 过滤后的会话列表
  final int selectedTabIndex; // 当前选中的标签索引
  final String searchQuery; // 当前搜索关键词

  // 错误信息
  final String? errorMessage;

  const ChatsState({
    // 会话相关状态
    this.conversations = const [],
    this.messagesByConversation = const {},
    this.currentConversationId,
    this.isLoadingMessages = false,
    this.isLoadingMoreMessages = false,
    this.typingUsers = const {},
    this.onlineUsers = const {},
    this.conversationSyncStatus = ConversationSyncStatus.idle,
    
    // 会话过滤相关状态
    this.filteredConversations = const [],
    this.selectedTabIndex = 0,
    this.searchQuery = "",
    
    // 错误信息
    this.errorMessage,
  });

  /// 初始状态
  static ChatsState initial() {
    return const ChatsState();
  }

  /// 复制并更新状态
  ChatsState copyWith({
    // 会话相关状态
    List<Conversation>? conversations,
    Map<String, List<Message>>? messagesByConversation,
    String? currentConversationId,
    bool? isLoadingMessages,
    bool? isLoadingMoreMessages,
    Map<String, List<String>>? typingUsers,
    Set<String>? onlineUsers,
    ConversationSyncStatus? conversationSyncStatus,
    
    // 会话过滤相关状态
    List<Conversation>? filteredConversations,
    int? selectedTabIndex,
    String? searchQuery,
    
    // 错误信息
    String? errorMessage,
  }) {
    return ChatsState(
      // 会话相关状态
      conversations: conversations ?? this.conversations,
      messagesByConversation: messagesByConversation ?? this.messagesByConversation,
      currentConversationId: currentConversationId ?? this.currentConversationId,
      isLoadingMessages: isLoadingMessages ?? this.isLoadingMessages,
      isLoadingMoreMessages: isLoadingMoreMessages ?? this.isLoadingMoreMessages,
      typingUsers: typingUsers ?? this.typingUsers,
      onlineUsers: onlineUsers ?? this.onlineUsers,
      conversationSyncStatus: conversationSyncStatus ?? this.conversationSyncStatus,
      
      // 会话过滤相关状态
      filteredConversations: filteredConversations ?? this.filteredConversations,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      searchQuery: searchQuery ?? this.searchQuery,
      
      // 错误信息
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        // 会话相关状态
        conversations,
        messagesByConversation,
        currentConversationId,
        isLoadingMessages,
        isLoadingMoreMessages,
        typingUsers,
        onlineUsers,
        conversationSyncStatus,
        
        // 会话过滤相关状态
        filteredConversations,
        selectedTabIndex,
        searchQuery,
        
        // 错误信息
        errorMessage,
      ];
}
