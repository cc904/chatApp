import 'package:cc/core/database/models/message.dart';
import 'package:cc/core/database/models/conversation.dart';
import 'package:cc/core/database/models/current_user.dart';
import 'package:equatable/equatable.dart';

/// 当前滚动位置信息
/// 用于保存和恢复用户的查看位置
class CurrentScrollPosition extends Equatable {
  /// 锚点消息ID
  final String? messageId;

  /// 锚点消息在列表中的索引
  final int? messageIndex;

  /// 消息在屏幕中的相对位置 (0.0 - 1.0)
  /// 0.0 表示消息顶部对齐屏幕顶部，1.0 表示消息底部对齐屏幕底部
  final double? relativePosition;

  /// 精确的滚动位置（像素）
  final double? scrollOffset;

  /// 位置保存时间戳
  final DateTime? timestamp;

  /// 是否是有效的位置信息
  bool get isValid => messageId != null && messageIndex != null;

  const CurrentScrollPosition({
    this.messageId,
    this.messageIndex,
    this.relativePosition,
    this.scrollOffset,
    this.timestamp,
  });

  /// 创建空的滚动位置
  const CurrentScrollPosition.empty()
      : messageId = null,
        messageIndex = null,
        relativePosition = null,
        scrollOffset = null,
        timestamp = null;

  /// 从锚点消息创建位置信息
  factory CurrentScrollPosition.fromAnchor({
    required String messageId,
    required int messageIndex,
    double? relativePosition,
    double? scrollOffset,
    bool includeTimestamp = false,
  }) {
    return CurrentScrollPosition(
      messageId: messageId,
      messageIndex: messageIndex,
      relativePosition: relativePosition ?? 0.0,
      scrollOffset: scrollOffset,
      timestamp: includeTimestamp ? DateTime.now() : null,
    );
  }

  CurrentScrollPosition copyWith({
    String? messageId,
    int? messageIndex,
    double? relativePosition,
    double? scrollOffset,
    DateTime? timestamp,
  }) {
    return CurrentScrollPosition(
      messageId: messageId ?? this.messageId,
      messageIndex: messageIndex ?? this.messageIndex,
      relativePosition: relativePosition ?? this.relativePosition,
      scrollOffset: scrollOffset ?? this.scrollOffset,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  List<Object?> get props => [
        messageId,
        messageIndex,
        relativePosition,
        scrollOffset,
      ];

  @override
  String toString() {
    return 'CurrentScrollPosition(messageId: $messageId, index: $messageIndex, '
        'relativePos: $relativePosition, offset: $scrollOffset, '
        'timestamp: $timestamp)';
  }
}

/// 单个聊天会话的状态
class ChatState extends Equatable {
  /// 当前会话
  final Conversation conversation;

  /// 当前会话中的消息（按时间降序排列，最旧的在顶部）
  final List<Message> messages;

  /// 是否正在加载消息
  final bool isLoadingMessages;

  /// 是否正在加载更多消息
  final bool isLoadingMoreMessages;

  /// 是否正在发送消息
  final bool isSending;

  /// 网络状态
  final String networkStatus;

  /// 错误信息
  final String? errorMessage;

  /// 当前用户信息
  final CurrentUser? currentUser;

  /// 最后阅读的消息ID
  final String? lastReadMessageId;

  /// 是否有更多历史消息可加载
  final bool hasMoreHistory;

  /// 是否有更多新消息可加载
  final bool hasMoreRecent;

  /// 未读消息数量
  final int unreadCount;

  /// 第一条未读消息ID
  final String? firstUnreadMessageId;

  /// 当前滚动位置信息
  /// 用于保存和恢复用户的查看位置
  final CurrentScrollPosition currentScrollPosition;

  /// 是否处于搜索模式
  final bool isSearchMode;

  /// 搜索关键词
  final String searchQuery;

  /// 搜索结果列表
  final List<Message> searchResults;

  /// 是否正在搜索
  final bool isSearching;

  /// 搜索日期过滤器
  final DateTime? searchDateFilter;

  /// 构造函数
  const ChatState({
    required this.conversation,
    required this.messages,
    required this.isLoadingMessages,
    required this.isLoadingMoreMessages,
    required this.isSending,
    required this.networkStatus,
    this.errorMessage,
    this.currentUser,
    this.lastReadMessageId,
    required this.hasMoreHistory,
    required this.hasMoreRecent,
    required this.unreadCount,
    this.firstUnreadMessageId,
    required this.currentScrollPosition,
    this.isSearchMode = false,
    this.searchQuery = '',
    this.searchResults = const [],
    this.isSearching = false,
    this.searchDateFilter,
  });

  /// 初始状态
  factory ChatState.initial(CurrentUser currentUser) {
    // 创建一个基础的初始状态模板
    // 真正的 conversation 对象会通过 copyWith 方法传入
    final emptyConversation = Conversation()
      ..conversationId = ''
      ..type = ConversationType.private
      ..name = ''
      ..createdAt = DateTime.now();

    return ChatState(
      conversation: emptyConversation, // 这只是一个占位符，会被 copyWith 替换
      messages: const [],
      isLoadingMessages: false,
      isLoadingMoreMessages: false,
      isSending: false,
      networkStatus: 'connected',
      errorMessage: null,
      hasMoreHistory: true,
      hasMoreRecent: false,
      unreadCount: 0,
      currentScrollPosition: const CurrentScrollPosition.empty(),
      currentUser: currentUser,
    );
  }

  /// 复制方法
  ChatState copyWith({
    Conversation? conversation,
    CurrentUser? currentUser,
    List<Message>? messages,
    bool? isLoadingMessages,
    bool? isLoadingMoreMessages,
    bool? isSending,
    String? networkStatus,
    String? errorMessage,
    String? lastReadMessageId,
    bool? hasMoreHistory,
    bool? hasMoreRecent,
    int? unreadCount,
    String? firstUnreadMessageId,
    CurrentScrollPosition? currentScrollPosition,
    bool? isSearchMode,
    String? searchQuery,
    List<Message>? searchResults,
    bool? isSearching,
    DateTime? searchDateFilter,
  }) {
    return ChatState(
      conversation: conversation ?? this.conversation,
      currentUser: currentUser ?? this.currentUser,
      messages: messages ?? this.messages,
      isLoadingMessages: isLoadingMessages ?? this.isLoadingMessages,
      isLoadingMoreMessages:
          isLoadingMoreMessages ?? this.isLoadingMoreMessages,
      isSending: isSending ?? this.isSending,
      networkStatus: networkStatus ?? this.networkStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      lastReadMessageId: lastReadMessageId ?? this.lastReadMessageId,
      hasMoreHistory: hasMoreHistory ?? this.hasMoreHistory,
      hasMoreRecent: hasMoreRecent ?? this.hasMoreRecent,
      unreadCount: unreadCount ?? this.unreadCount,
      firstUnreadMessageId: firstUnreadMessageId ?? this.firstUnreadMessageId,
      currentScrollPosition:
          currentScrollPosition ?? this.currentScrollPosition,
      isSearchMode: isSearchMode ?? this.isSearchMode,
      searchQuery: searchQuery ?? this.searchQuery,
      searchResults: searchResults ?? this.searchResults,
      isSearching: isSearching ?? this.isSearching,
      searchDateFilter: searchDateFilter ?? this.searchDateFilter,
    );
  }

  // 定义网络状态常量
  static const String kNetworkStatusConnected = 'connected';
  static const String kNetworkStatusConnecting = 'connecting';
  static const String kNetworkStatusDisconnected = 'disconnected';
  static const String kNetworkStatusError = 'error';

  /// 获取消息统计信息
  Map<String, dynamic> getMessageStats() {
    return {
      'totalMessages': messages.length,
      'unreadCount': unreadCount,
      'hasMoreHistory': hasMoreHistory,
      'hasMoreRecent': hasMoreRecent,
      'firstMessageTime': messages.isNotEmpty
          ? messages.first.createdAt.toIso8601String()
          : null,
      'lastMessageTime': messages.isNotEmpty
          ? messages.last.createdAt.toIso8601String()
          : null,
    };
  }

  /// 检查是否可以加载更多历史消息
  bool get canLoadMoreHistory => hasMoreHistory;

  /// 检查是否可以加载更多新消息
  bool get canLoadMoreRecent => hasMoreRecent;

  @override
  List<Object?> get props => [
        conversation,
        currentUser,
        messages,
        isLoadingMessages,
        isLoadingMoreMessages,
        isSending,
        networkStatus,
        errorMessage,
        currentUser,
        lastReadMessageId,
        hasMoreHistory,
        hasMoreRecent,
        unreadCount,
        firstUnreadMessageId,
        currentScrollPosition,
        isSearchMode,
        searchQuery,
        searchResults,
        isSearching,
        searchDateFilter,
      ];
}
