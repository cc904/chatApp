import 'package:cc/core/database/models/conversation.dart';
import 'package:cc/core/database/models/user.dart';
import 'package:equatable/equatable.dart';

/// 会话同步状态
enum ConversationSyncStatus {
  /// 初始状态，未同步
  initial,

  /// 同步中
  syncing,

  /// 同步完成
  completed,

  /// 同步错误
  error,
}

/// 聊天列表状态
class ChatsState extends Equatable {
  /// 所有会话列表
  final List<Conversation> conversations;

  /// 过滤后的会话列表
  final List<Conversation> filteredConversations;

  /// 搜索关键词
  final String searchQuery;

  /// 是否正在搜索
  final bool isSearching;

  /// 选中的标签索引
  final int selectedTabIndex;

  /// 当前用户
  final User? currentUser;

  /// 会话同步状态
  final ConversationSyncStatus conversationSyncStatus;

  /// 是否正在加载消息
  final bool isLoadingMessages;

  /// 网络状态
  final String networkStatus;

  /// 是否已连接
  final bool isConnected;

  /// 上次连接时间
  final DateTime? lastConnectionTime;

  /// 连接错误信息
  final String? connectionErrorMessage;

  /// 在线用户集合
  final Set<String> onlineUsers;

  /// 打字用户映射
  final Map<String, List<String>> typingUsers;

  /// 错误信息
  final String? errorMessage;

  const ChatsState({
    required this.conversations,
    required this.filteredConversations,
    required this.searchQuery,
    required this.isSearching,
    required this.selectedTabIndex,
    required this.currentUser,
    required this.conversationSyncStatus,
    required this.isLoadingMessages,
    required this.networkStatus,
    required this.isConnected,
    required this.onlineUsers,
    required this.typingUsers,
    this.lastConnectionTime,
    this.connectionErrorMessage,
    this.errorMessage,
  });

  /// 初始状态
  factory ChatsState.initial() {
    return const ChatsState(
      conversations: [],
      filteredConversations: [],
      searchQuery: '',
      isSearching: false,
      selectedTabIndex: 0,
      currentUser: null,
      conversationSyncStatus: ConversationSyncStatus.initial,
      isLoadingMessages: false,
      networkStatus: kNetworkStatusConnected,
      isConnected: true,
      onlineUsers: {},
      typingUsers: {},
    );
  }

  /// 复制当前状态并更新指定字段
  ChatsState copyWith({
    List<Conversation>? conversations,
    List<Conversation>? filteredConversations,
    String? searchQuery,
    bool? isSearching,
    int? selectedTabIndex,
    User? currentUser,
    ConversationSyncStatus? conversationSyncStatus,
    bool? isLoadingMessages,
    String? networkStatus,
    bool? isConnected,
    DateTime? lastConnectionTime,
    String? connectionErrorMessage,
    Set<String>? onlineUsers,
    Map<String, List<String>>? typingUsers,
    String? errorMessage,
  }) {
    return ChatsState(
      conversations: conversations ?? this.conversations,
      filteredConversations:
          filteredConversations ?? this.filteredConversations,
      searchQuery: searchQuery ?? this.searchQuery,
      isSearching: isSearching ?? this.isSearching,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      currentUser: currentUser ?? this.currentUser,
      conversationSyncStatus:
          conversationSyncStatus ?? this.conversationSyncStatus,
      isLoadingMessages: isLoadingMessages ?? this.isLoadingMessages,
      networkStatus: networkStatus ?? this.networkStatus,
      isConnected: isConnected ?? this.isConnected,
      lastConnectionTime: lastConnectionTime ?? this.lastConnectionTime,
      connectionErrorMessage:
          connectionErrorMessage ?? this.connectionErrorMessage,
      onlineUsers: onlineUsers ?? this.onlineUsers,
      typingUsers: typingUsers ?? this.typingUsers,
      errorMessage: errorMessage,
    );
  }

  // 网络状态常量
  static const String kNetworkStatusConnected = 'connected';
  static const String kNetworkStatusConnecting = 'connecting';
  static const String kNetworkStatusDisconnected = 'disconnected';
  static const String kNetworkStatusError = 'error';

  @override
  List<Object?> get props => [
        conversations,
        filteredConversations,
        searchQuery,
        isSearching,
        selectedTabIndex,
        currentUser,
        conversationSyncStatus,
        isLoadingMessages,
        networkStatus,
        isConnected,
        lastConnectionTime,
        connectionErrorMessage,
        onlineUsers,
        typingUsers,
        errorMessage,
      ];
}
