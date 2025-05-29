import 'package:cc/core/database/models/conversation.dart';
import 'package:cc/core/database/models/message.dart';
import 'package:cc/core/database/models/user.dart';
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
  
  // 网络相关状态
  // 网络状态常量
  static const String kNetworkStatusConnected = 'connected';
  static const String kNetworkStatusConnecting = 'connecting';
  static const String kNetworkStatusDisconnected = 'disconnected';
  static const String kNetworkStatusError = 'error';
  final String networkStatus; // 网络状态
  final bool isConnected; // 是否连接到网络
  final DateTime? lastConnectionTime; // 最后一次连接时间
  final String? connectionErrorMessage; // 连接错误信息
  
  // 用户相关状态
  final User? currentUser; // 当前用户
  
  // 会话过滤相关状态
  final List<Conversation> filteredConversations; // 过滤后的会话列表
  final int selectedTabIndex; // 当前选中的标签索引
  final String searchQuery; // 当前搜索关键词
  final bool isSearching; // 是否处于搜索状态

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
    
    // 网络相关状态
    this.networkStatus = 'connected',
    this.isConnected = true,
    this.lastConnectionTime,
    this.connectionErrorMessage,
    
    // 用户相关状态
    this.currentUser,
    
    // 会话过滤相关状态
    this.filteredConversations = const [],
    this.selectedTabIndex = 0,
    this.searchQuery = "",
    this.isSearching = false,
    
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
    
    // 网络相关状态
    String? networkStatus,
    bool? isConnected,
    DateTime? lastConnectionTime,
    String? connectionErrorMessage,
    
    // 用户相关状态
    User? currentUser,
    
    // 会话过滤相关状态
    List<Conversation>? filteredConversations,
    int? selectedTabIndex,
    String? searchQuery,
    bool? isSearching,
    
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
      
      // 网络相关状态
      networkStatus: networkStatus ?? this.networkStatus,
      isConnected: isConnected ?? this.isConnected,
      lastConnectionTime: lastConnectionTime ?? this.lastConnectionTime,
      connectionErrorMessage: connectionErrorMessage ?? this.connectionErrorMessage,
      
      // 用户相关状态
      currentUser: currentUser ?? this.currentUser,
      
      // 会话过滤相关状态
      filteredConversations: filteredConversations ?? this.filteredConversations,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      searchQuery: searchQuery ?? this.searchQuery,
      isSearching: isSearching ?? this.isSearching,
      
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
        
        // 网络相关状态
        networkStatus,
        isConnected,
        lastConnectionTime,
        connectionErrorMessage,
        
        // 用户相关状态
        currentUser,
        conversationSyncStatus,
        
        // 会话过滤相关状态
        filteredConversations,
        selectedTabIndex,
        searchQuery,
        isSearching,
        
        // 错误信息
        errorMessage,
      ];
}
