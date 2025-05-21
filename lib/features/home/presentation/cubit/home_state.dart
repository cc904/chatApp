import 'package:equatable/equatable.dart';
import 'package:cc/core/proto/generated/user.pb.dart';
import 'package:cc/core/database/models/user.dart';
import 'package:cc/core/database/models/conversation.dart';
import 'package:cc/core/database/models/message.dart';

/// HomePage的状态类
class HomeState extends Equatable {
  // 初始化状态
  final bool isInitializing;
  final bool isInitialized;
  final String? errorMessage;
  final CurrentUserProto? currentUser;

  // 聊天相关状态
  final List<Conversation> conversations;
  final Map<String, List<Message>> messagesByConversation;
  final String? currentConversationId;
  final bool isLoadingMessages;
  final Map<String, List<String>> typingUsers; // 会话ID -> 正在输入的用户ID列表
  final Set<String> onlineUsers; // 在线用户ID集合

  // 联系人相关状态
  final List<User> contacts;
  final bool isLoadingContacts;

  // 通话相关状态
  final List<dynamic> calls; // 可以根据实际需求定义Call类型
  final bool isLoadingCalls;

  // 搜索相关状态
  final String? searchQuery;
  final List<dynamic> searchResults; // 可能是联系人、会话或消息
  final bool isSearching;

  const HomeState({
    // 初始化状态
    required this.isInitializing,
    required this.isInitialized,
    this.errorMessage,
    this.currentUser,

    // 聊天相关状态
    this.conversations = const [],
    this.messagesByConversation = const {},
    this.currentConversationId,
    this.isLoadingMessages = false,
    this.typingUsers = const {},
    this.onlineUsers = const {},

    // 联系人相关状态
    this.contacts = const [],
    this.isLoadingContacts = false,

    // 通话相关状态
    this.calls = const [],
    this.isLoadingCalls = false,

    // 搜索相关状态
    this.searchQuery,
    this.searchResults = const [],
    this.isSearching = false,
  });

  /// 初始状态
  factory HomeState.initial() {
    return const HomeState(
      isInitializing: false,
      isInitialized: false,
    );
  }

  /// 初始化中状态
  HomeState toInitializingState() {
    return copyWith(
      isInitializing: true,
      errorMessage: null,
    );
  }

  /// 初始化成功状态
  HomeState toInitializedState({required CurrentUserProto currentUserProto}) {
    return copyWith(
      isInitializing: false,
      isInitialized: true,
      errorMessage: null,
      currentUser: currentUser,
    );
  }

  /// 初始化失败状态
  HomeState toErrorState(String message) {
    return copyWith(
      isInitializing: false,
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
    bool? isInitializing,
    bool? isInitialized,
    String? errorMessage,
    CurrentUserProto? currentUser,

    // 聊天相关状态
    List<Conversation>? conversations,
    Map<String, List<Message>>? messagesByConversation,
    String? currentConversationId,
    bool? isLoadingMessages,
    Map<String, List<String>>? typingUsers,
    Set<String>? onlineUsers,

    // 联系人相关状态
    List<User>? contacts,
    bool? isLoadingContacts,

    // 通话相关状态
    List<dynamic>? calls,
    bool? isLoadingCalls,

    // 搜索相关状态
    String? searchQuery,
    List<dynamic>? searchResults,
    bool? isSearching,
  }) {
    return HomeState(
      // 初始化状态
      isInitializing: isInitializing ?? this.isInitializing,
      isInitialized: isInitialized ?? this.isInitialized,
      errorMessage: errorMessage ?? this.errorMessage,
      currentUser: currentUser ?? this.currentUser,

      // 聊天相关状态
      conversations: conversations ?? this.conversations,
      messagesByConversation:
          messagesByConversation ?? this.messagesByConversation,
      currentConversationId:
          currentConversationId ?? this.currentConversationId,
      isLoadingMessages: isLoadingMessages ?? this.isLoadingMessages,
      typingUsers: typingUsers ?? this.typingUsers,
      onlineUsers: onlineUsers ?? this.onlineUsers,

      // 联系人相关状态
      contacts: contacts ?? this.contacts,
      isLoadingContacts: isLoadingContacts ?? this.isLoadingContacts,

      // 通话相关状态
      calls: calls ?? this.calls,
      isLoadingCalls: isLoadingCalls ?? this.isLoadingCalls,

      // 搜索相关状态
      searchQuery: searchQuery ?? this.searchQuery,
      searchResults: searchResults ?? this.searchResults,
      isSearching: isSearching ?? this.isSearching,
    );
  }

  /// 判断是否有错误
  bool get hasError => errorMessage != null;

  @override
  List<Object?> get props => [
        // 初始化状态
        isInitializing,
        isInitialized,
        errorMessage,
        currentUser,

        // 聊天相关状态
        conversations,
        messagesByConversation,
        currentConversationId,
        isLoadingMessages,
        typingUsers,
        onlineUsers,

        // 联系人相关状态
        contacts,
        isLoadingContacts,

        // 通话相关状态
        calls,
        isLoadingCalls,

        // 搜索相关状态
        searchQuery,
        searchResults,
        isSearching,
      ];
}
