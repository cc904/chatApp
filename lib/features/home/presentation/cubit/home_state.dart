import 'package:cc/features/chat/domain/repositories/chat_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:cc/core/proto/generated/user.pb.dart';
import 'package:cc/core/database/models/user.dart';
import 'package:cc/core/database/models/conversation.dart';
import 'package:cc/core/database/models/message.dart';
import 'package:cc/features/contacts/domain/repositories/contacts_repository.dart';

/// 网络状态枚举
enum NetworkStatus {
  /// 已连接
  connected,
  
  /// 连接中
  connecting,
  
  /// 断开连接
  disconnected,
  
  /// 连接错误
  error
}

/// HomePage的状态类
class HomeState extends Equatable {
  // 初始化状态
  final bool homePageIsInitializing;
  final bool homePageIsInitialized;
  final String? errorMessage;
  final CurrentUserProto? currentUser;

  // 聊天相关状态
  final List<Conversation> conversations;
  final Map<String, List<Message>> messagesByConversation;
  final String? currentConversationId;
  final bool isLoadingMessages;
  final bool isLoadingMoreMessages; // 是否正在加载更多历史消息
  final Map<String, List<String>> typingUsers; // 会话ID -> 正在输入的用户ID列表
  final Set<String> onlineUsers; // 在线用户ID集合
  final Set<String> updatedConversationIds; // 更新的会话ID集合
  final Set<String> removedConversationIds; // 删除的会话ID集合
  final ConversationSyncStatus conversationSyncStatus; // 会话同步状态
  
  // 会话过滤相关状态
  final List<Conversation> filteredConversations; // 过滤后的会话列表
  final int selectedTabIndex; // 当前选中的标签索引
  final String searchQuery; // 当前搜索关键词

  // 联系人相关状态
  final List<User> contacts;
  final bool isLoadingContacts;
  final ContactsSyncStatus contactsSyncStatus; // 联系人同步状态
  final DateTime? lastContactsSyncTime; // 最后同步时间
  final String? contactsErrorMessage; // 联系人错误信息

  // 网络相关状态
  final bool isConnected; // 是否连接到网络
  final NetworkStatus networkStatus; // 网络状态
  final DateTime? lastConnectionTime; // 最后一次连接时间
  final String? connectionErrorMessage; // 连接错误信息

  // 搜索相关状态
  final List<dynamic> searchResults; // 可能是联系人、会话或消息
  final bool isSearching;

  const HomeState({
    // 初始化状态
    this.homePageIsInitializing = false,
    this.homePageIsInitialized = false,
    this.errorMessage,
    this.currentUser,

    // 聊天相关状态
    this.conversations = const [],
    this.messagesByConversation = const {},
    this.currentConversationId,
    this.isLoadingMessages = false,
    this.isLoadingMoreMessages = false,
    this.typingUsers = const {},
    this.onlineUsers = const {},
    this.updatedConversationIds = const {},
    this.removedConversationIds = const {},
    this.conversationSyncStatus = ConversationSyncStatus.idle,

    // 会话过滤相关状态
    this.filteredConversations = const [],
    this.selectedTabIndex = 0,
    this.searchQuery = "",

    // 联系人相关状态
    this.contacts = const [],
    this.isLoadingContacts = false,
    this.contactsSyncStatus = ContactsSyncStatus.idle,
    this.lastContactsSyncTime,
    this.contactsErrorMessage,

    // 网络相关状态
    this.isConnected = true,
    this.networkStatus = NetworkStatus.connected,
    this.lastConnectionTime,
    this.connectionErrorMessage,

    // 搜索相关状态
    this.searchResults = const [],
    this.isSearching = false,
  });

  /// 初始状态
  static HomeState initial() {
    return const HomeState(
      homePageIsInitializing: false,
      homePageIsInitialized: false,
      conversations: [],
      messagesByConversation: {},
      typingUsers: {},
      onlineUsers: {},
      updatedConversationIds: {},
      removedConversationIds: {},
      filteredConversations: [],
      selectedTabIndex: 0,
      searchQuery: "",
    );
  }

  /// 初始化中状态
  HomeState toInitializingState() {
    return copyWith(
      homePageIsInitializing: true,
      errorMessage: null,
    );
  }

  /// 初始化成功状态
  HomeState toInitializedState({required CurrentUserProto currentUserProto}) {
    return copyWith(
      homePageIsInitializing: false,
      homePageIsInitialized: true,
      errorMessage: null,
      currentUser: currentUserProto,
    );
  }

  /// 初始化失败状态
  HomeState toErrorState(String message) {
    return copyWith(
      homePageIsInitializing: false,
      errorMessage: message,
    );
  }

  /// 获取当前会话
  Conversation? get currentConversation {
    if (currentConversationId == null) return null;
    try {
      return conversations.firstWhere(
        (conversation) => conversation.conversationId == currentConversationId,
      );
    } catch (error) {
      return null;
    }
  }

  /// 获取当前会话的消息
  List<Message> get currentMessages {
    if (currentConversationId == null) return [];
    return messagesByConversation[currentConversationId] ?? [];
  }

  /// 获取当前会话正在输入的用户ID列表
  List<String> get currentTypingUsers {
    if (currentConversationId == null) return [];
    return typingUsers[currentConversationId] ?? [];
  }

  /// 检查用户是否在线
  bool isUserOnline(String userId) {
    return onlineUsers.contains(userId);
  }

  /// 复制实例方法
  HomeState copyWith({
    // 初始化状态
    bool? homePageIsInitializing,
    bool? homePageIsInitialized,
    String? errorMessage,
    CurrentUserProto? currentUser,

    // 聊天相关状态
    List<Conversation>? conversations,
    Map<String, List<Message>>? messagesByConversation,
    String? currentConversationId,
    bool? isLoadingMessages,
    bool? isLoadingMoreMessages,
    Map<String, List<String>>? typingUsers,
    Set<String>? onlineUsers,
    Set<String>? updatedConversationIds,
    Set<String>? removedConversationIds,
    ConversationSyncStatus? conversationSyncStatus,

    // 会话过滤相关状态
    List<Conversation>? filteredConversations,
    int? selectedTabIndex,
    String? searchQuery,

    // 联系人相关状态
    List<User>? contacts,
    bool? isLoadingContacts,
    ContactsSyncStatus? contactsSyncStatus,
    DateTime? lastContactsSyncTime,
    String? contactsErrorMessage,

    // 网络相关状态
    bool? isConnected,
    NetworkStatus? networkStatus,
    DateTime? lastConnectionTime,
    String? connectionErrorMessage,

    // 搜索相关状态
    List<dynamic>? searchResults,
    bool? isSearching,
  }) {
    return HomeState(
      // 初始化状态
      homePageIsInitializing: homePageIsInitializing ?? this.homePageIsInitializing,
      homePageIsInitialized: homePageIsInitialized ?? this.homePageIsInitialized,
      errorMessage: errorMessage ?? this.errorMessage,
      currentUser: currentUser ?? this.currentUser,

      // 聊天相关状态
      conversations: conversations ?? this.conversations,
      messagesByConversation:
          messagesByConversation ?? this.messagesByConversation,
      currentConversationId:
          currentConversationId ?? this.currentConversationId,
      isLoadingMessages: isLoadingMessages ?? this.isLoadingMessages,
      isLoadingMoreMessages: isLoadingMoreMessages ?? this.isLoadingMoreMessages,
      typingUsers: typingUsers ?? this.typingUsers,
      onlineUsers: onlineUsers ?? this.onlineUsers,
      updatedConversationIds: updatedConversationIds ?? this.updatedConversationIds,
      removedConversationIds: removedConversationIds ?? this.removedConversationIds,

      // 会话过滤相关状态
      filteredConversations: filteredConversations ?? this.filteredConversations,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      searchQuery: searchQuery ?? this.searchQuery,

      // 联系人相关状态
      contacts: contacts ?? this.contacts,
      isLoadingContacts: isLoadingContacts ?? this.isLoadingContacts,
      contactsSyncStatus: contactsSyncStatus ?? this.contactsSyncStatus,
      lastContactsSyncTime: lastContactsSyncTime ?? this.lastContactsSyncTime,
      contactsErrorMessage: contactsErrorMessage ?? this.contactsErrorMessage,

      // 网络相关状态
      isConnected: isConnected ?? this.isConnected,
      networkStatus: networkStatus ?? this.networkStatus,
      lastConnectionTime: lastConnectionTime ?? this.lastConnectionTime,
      connectionErrorMessage: connectionErrorMessage ?? this.connectionErrorMessage,

      // 搜索相关状态
      searchResults: searchResults ?? this.searchResults,
      isSearching: isSearching ?? this.isSearching,
    );
  }

  /// 判断是否有错误
  bool get hasError => errorMessage != null;

  /// 判断联系人同步是否有错误
  bool get hasContactsError => contactsErrorMessage != null;

  @override
  List<Object?> get props => [
        // 初始化状态
        homePageIsInitializing,
        homePageIsInitialized,
        errorMessage,
        currentUser,

        // 聊天相关状态
        conversations,
        messagesByConversation,
        currentConversationId,
        isLoadingMessages,
        typingUsers,
        onlineUsers,
        updatedConversationIds,
        removedConversationIds,

        // 会话过滤相关状态
        filteredConversations,
        selectedTabIndex,
        searchQuery,

        // 联系人相关状态
        contacts,
        isLoadingContacts,
        contactsSyncStatus,
        lastContactsSyncTime,
        contactsErrorMessage,

        // 网络相关状态
        isConnected,
        networkStatus,
        lastConnectionTime,
        connectionErrorMessage,

        // 搜索相关状态
        searchQuery,
        searchResults,
        isSearching,
      ];
}
