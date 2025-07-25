import 'package:cc/core/database/drift_database.dart';
import 'package:equatable/equatable.dart';

/// 当前滚动位置信息
/// 用于保存和恢复用户的查看位置
class CurrentScrollPosition extends Equatable {
  /// 锚点消息ID
  final String? messageId;

  /// 消息在屏幕中的相对位置 (0.0 - 1.0)
  /// 在 reverse: true 的列表中：
  /// - 使用 itemLeadingEdge 表示消息顶部到视口leading edge（屏幕底部）的距离
  /// - 0.0 表示消息顶部在屏幕底部；1.0 表示消息顶部在屏幕顶部
  /// - 例如 0.095 表示消息顶部距离屏幕底部9.5%的位置
  final double? relativePosition;

  /// 是否需要精确的滚动位置（像素级）
  final bool? needOffset;

  /// 是否是有效的位置信息
  /// 只要存在 messageId 即认为有效，listIndex 可以动态计算
  bool get isValid => messageId != null;

  const CurrentScrollPosition({
    this.messageId,
    this.relativePosition,
    this.needOffset,
  });

  /// 创建空的滚动位置
  const CurrentScrollPosition.empty()
      : messageId = null,
        relativePosition = null,
        needOffset = null;

  /// 从锚点消息创建位置信息
  factory CurrentScrollPosition.fromAnchor({
    required String messageId,
    double? relativePosition,
    bool? needOffset,
  }) {
    return CurrentScrollPosition(
      messageId: messageId,
      relativePosition: relativePosition ?? 0.0,
      needOffset: needOffset,
    );
  }

  CurrentScrollPosition copyWith({
    String? messageId,
    double? relativePosition,
    bool? needOffset,
  }) {
    return CurrentScrollPosition(
      messageId: messageId ?? this.messageId,
      relativePosition: relativePosition ?? this.relativePosition,
      needOffset: needOffset ?? this.needOffset,
    );
  }

  /// 根据当前 messageId 在给定 messages 列表中动态计算 UI 索引
  /// 如果未找到返回 -1
  int getListIndex(List<Message> messages) {
    if (messageId == null) return -1;
    return messages.indexWhere((m) => m.messageId == messageId);
  }

  @override
  List<Object?> get props => [
        messageId,
        relativePosition,
        needOffset,
      ];

  @override
  String toString() {
    return 'CurrentScrollPosition(messageId: $messageId, '
        'relativePos: $relativePosition, needOffset: $needOffset)';
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

  /// 💢💢💢 新增：是否正在网络请求获取消息
  final bool isFetching;

  /// 是否正在发送消息
  final bool isSending;

  /// 网络状态
  final String networkStatus;

  /// 错误信息
  final String? errorMessage;

  /// 当前用户信息
  final CurrentUser currentUser;

  /// 最后阅读的消息ID
  final String? lastReadMessageId;

  /// 是否有更多历史消息可加载
  final bool hasMoreBefore;

  /// 是否有更多新消息可加载
  final bool hasMoreAfter;

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

  /// 💢💢💢 新增搜索相关字段
  /// 搜索结果中匹配的消息ID列表（按时间顺序排列）
  final List<int> searchResultMessageIndexes;

  /// 当前查看的搜索结果索引（从0开始）
  final int currentSearchResultIndex;

  /// 是否以列表形式显示搜索结果
  final bool isShowingSearchAsList;

  /// 搜索结果总数
  final int searchResultTotalCount;

  /// 💢💢💢 新增：搜索前的原始消息列表备份（用于退出搜索模式时恢复）
  final List<Message>? originalMessages;

  /// 💢💢💢 新增：是否正在清理多余消息（用于避免误触发加载更多）
  final bool isCleaningMessages;

  /// 💢💢💢 新增：消息更新触发器（用于触发UI刷新）
  /// 当消息状态发生变化时，这个值会改变，从而触发BlocBuilder重建
  final int messageUpdateTrigger;

  /// 🔄 并发同步相关字段
  /// 是否正在进行消息同步
  final bool isSyncing;

  /// 同步期间暂存的新消息队列
  final List<Message> pendingMessages;

  /// 🎯 锚点滚动相关字段
  /// 当前会话ID
  final String conversationId;

  /// 是否正在加载
  final bool isLoading;

  /// 总消息数量
  final int totalMessageCount;

  /// 💢💢💢 新增：附件相关字段
  /// 媒体消息列表（图片、视频）
  final List<Message> mediaMessages;

  /// 文件消息列表
  final List<Message> fileMessages;

  /// 语音消息列表
  final List<Message> voiceMessages;

  /// 链接消息列表
  final List<Message> linkMessages;

  /// 是否正在加载媒体消息
  final bool isLoadingMedia;

  /// 是否正在加载文件消息
  final bool isLoadingFiles;

  /// 是否正在加载语音消息
  final bool isLoadingVoice;

  /// 是否正在加载链接消息
  final bool isLoadingLinks;

  /// 💢💢💢 新增：是否需要导航回上一页
  final bool shouldNavigateBack;

  /// 💢💢💢 新增：高亮显示的消息ID
  final String? highlightedMessageId;

  /// 构造函数
  const ChatState({
    required this.conversation,
    required this.messages,
    required this.isLoadingMessages,
    required this.isLoadingMoreMessages,
    required this.isFetching,
    required this.isSending,
    required this.networkStatus,
    this.errorMessage,
    required this.currentUser,
    this.lastReadMessageId,
    required this.hasMoreBefore,
    required this.hasMoreAfter,
    this.firstUnreadMessageId,
    required this.currentScrollPosition,
    this.isSearchMode = false,
    this.searchQuery = '',
    this.searchResults = const [],
    this.isSearching = false,
    this.searchDateFilter,
    required this.searchResultMessageIndexes,
    required this.currentSearchResultIndex,
    required this.isShowingSearchAsList,
    required this.searchResultTotalCount,
    this.originalMessages,
    this.isCleaningMessages = false,
    this.messageUpdateTrigger = 0,
    this.isSyncing = false,
    this.pendingMessages = const [],
    this.conversationId = '',
    this.isLoading = false,
    this.totalMessageCount = 0,
    required this.mediaMessages,
    required this.fileMessages,
    required this.voiceMessages,
    required this.linkMessages,
    required this.isLoadingMedia,
    required this.isLoadingFiles,
    required this.isLoadingVoice,
    required this.isLoadingLinks,
    this.shouldNavigateBack = false,
    this.highlightedMessageId,
  });

  /// 初始状态
  factory ChatState.initial(CurrentUser currentUser) {
    // 创建一个基础的初始状态模板
    // 真正的 conversation 对象会通过 copyWith 方法传入
    final emptyConversation = Conversation(
      conversationId: '',
      type: 'PRIVATE', // ConversationType.PRIVATE 对应的字符串值
      name: '',
      avatar: null,
      createdAt: DateTime.now(),
      createdBy: null,
      firstMessageIndex: 0,
      lastMessageIndex: 0,
      lastMessageTime: null,
      lastMessagePreview: null,
      lastMessageName: null,
      participants: '[]', // 空的参与者JSON数组
      description: null,
      requiresApproval: false,
      // 当前用户的参与者设置
      muted: false,
      pinned: false,
      readMessageIndex: 0,
      unreadCount: 0,
      lastReadTime: null,
    );

    return ChatState(
      conversation: emptyConversation, // 这只是一个占位符，会被 copyWith 替换
      messages: const [],
      isLoadingMessages: false,
      isLoadingMoreMessages: false,
      isFetching: false,
      isSending: false,
      networkStatus: 'connected',
      errorMessage: null,
      hasMoreBefore: true,
      hasMoreAfter: false,
      currentScrollPosition: const CurrentScrollPosition.empty(),
      currentUser: currentUser,
      searchResultMessageIndexes: const [],
      currentSearchResultIndex: 0,
      isShowingSearchAsList: false,
      searchResultTotalCount: 0,
      originalMessages: null,
      isCleaningMessages: false,
      messageUpdateTrigger: 0,
      isSyncing: false,
      pendingMessages: const [],
      conversationId: '',
      isLoading: false,
      totalMessageCount: 0,
      mediaMessages: const [],
      fileMessages: const [],
      voiceMessages: const [],
      linkMessages: const [],
      isLoadingMedia: false,
      isLoadingFiles: false,
      isLoadingVoice: false,
      isLoadingLinks: false,
      shouldNavigateBack: false,
      highlightedMessageId: null,
    );
  }

  /// 复制方法
  ChatState copyWith({
    Conversation? conversation,
    CurrentUser? currentUser,
    List<Message>? messages,
    bool? isLoadingMessages,
    bool? isLoadingMoreMessages,
    bool? isFetching,
    bool? isSending,
    String? networkStatus,
    String? errorMessage,
    String? lastReadMessageId,
    bool? hasMoreBefore,
    bool? hasMoreAfter,
    String? firstUnreadMessageId,
    CurrentScrollPosition? currentScrollPosition,
    bool? isSearchMode,
    String? searchQuery,
    List<Message>? searchResults,
    bool? isSearching,
    DateTime? searchDateFilter,
    bool clearSearchDateFilter = false,
    List<int>? searchResultMessageIndexes,
    int? currentSearchResultIndex,
    bool? isShowingSearchAsList,
    int? searchResultTotalCount,
    List<Message>? originalMessages,
    bool? isCleaningMessages,
    int? messageUpdateTrigger,
    bool? isSyncing,
    List<Message>? pendingMessages,
    String? conversationId,
    bool? isLoading,
    int? totalMessageCount,
    List<Message>? mediaMessages,
    List<Message>? fileMessages,
    List<Message>? voiceMessages,
    List<Message>? linkMessages,
    bool? isLoadingMedia,
    bool? isLoadingFiles,
    bool? isLoadingVoice,
    bool? isLoadingLinks,
    bool? shouldNavigateBack,
    String? highlightedMessageId,
    bool clearHighlightedMessageId = false,
  }) {
    return ChatState(
      conversation: conversation ?? this.conversation,
      currentUser: currentUser ?? this.currentUser,
      messages: messages ?? this.messages,
      isLoadingMessages: isLoadingMessages ?? this.isLoadingMessages,
      isLoadingMoreMessages:
          isLoadingMoreMessages ?? this.isLoadingMoreMessages,
      isFetching: isFetching ?? this.isFetching,
      isSending: isSending ?? this.isSending,
      networkStatus: networkStatus ?? this.networkStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      lastReadMessageId: lastReadMessageId ?? this.lastReadMessageId,
      hasMoreBefore: hasMoreBefore ?? this.hasMoreBefore,
      hasMoreAfter: hasMoreAfter ?? this.hasMoreAfter,
      firstUnreadMessageId: firstUnreadMessageId ?? this.firstUnreadMessageId,
      currentScrollPosition:
          currentScrollPosition ?? this.currentScrollPosition,
      isSearchMode: isSearchMode ?? this.isSearchMode,
      searchQuery: searchQuery ?? this.searchQuery,
      searchResults: searchResults ?? this.searchResults,
      isSearching: isSearching ?? this.isSearching,
      searchDateFilter: clearSearchDateFilter
          ? null
          : (searchDateFilter ?? this.searchDateFilter),
      searchResultMessageIndexes:
          searchResultMessageIndexes ?? this.searchResultMessageIndexes,
      currentSearchResultIndex:
          currentSearchResultIndex ?? this.currentSearchResultIndex,
      isShowingSearchAsList:
          isShowingSearchAsList ?? this.isShowingSearchAsList,
      searchResultTotalCount:
          searchResultTotalCount ?? this.searchResultTotalCount,
      originalMessages: originalMessages ?? this.originalMessages,
      isCleaningMessages: isCleaningMessages ?? this.isCleaningMessages,
      messageUpdateTrigger: messageUpdateTrigger ?? this.messageUpdateTrigger,
      isSyncing: isSyncing ?? this.isSyncing,
      pendingMessages: pendingMessages ?? this.pendingMessages,
      conversationId: conversationId ?? this.conversationId,
      isLoading: isLoading ?? this.isLoading,
      totalMessageCount: totalMessageCount ?? this.totalMessageCount,
      mediaMessages: mediaMessages ?? this.mediaMessages,
      fileMessages: fileMessages ?? this.fileMessages,
      voiceMessages: voiceMessages ?? this.voiceMessages,
      linkMessages: linkMessages ?? this.linkMessages,
      isLoadingMedia: isLoadingMedia ?? this.isLoadingMedia,
      isLoadingFiles: isLoadingFiles ?? this.isLoadingFiles,
      isLoadingVoice: isLoadingVoice ?? this.isLoadingVoice,
      isLoadingLinks: isLoadingLinks ?? this.isLoadingLinks,
      shouldNavigateBack: shouldNavigateBack ?? this.shouldNavigateBack,
      highlightedMessageId: clearHighlightedMessageId
          ? null
          : (highlightedMessageId ?? this.highlightedMessageId),
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
      'hasMoreBefore': hasMoreBefore,
      'hasMoreAfter': hasMoreAfter,
      'firstMessageTime': messages.isNotEmpty
          ? messages.first.createdAt.toIso8601String()
          : null,
      'lastMessageTime': messages.isNotEmpty
          ? messages.last.createdAt.toIso8601String()
          : null,
    };
  }

  /// 检查是否可以加载更多历史消息
  bool get canLoadMoreHistory => hasMoreBefore;

  /// 检查是否可以加载更多新消息
  bool get canLoadMoreRecent => hasMoreAfter;

  @override
  List<Object?> get props => [
        conversation,
        currentUser,
        messages,
        isLoadingMessages,
        isLoadingMoreMessages,
        isFetching,
        isSending,
        networkStatus,
        errorMessage,
        currentUser,
        lastReadMessageId,
        hasMoreBefore,
        hasMoreAfter,
        firstUnreadMessageId,
        currentScrollPosition,
        isSearchMode,
        searchQuery,
        searchResults,
        isSearching,
        searchDateFilter,
        searchResultMessageIndexes,
        currentSearchResultIndex,
        isShowingSearchAsList,
        searchResultTotalCount,
        originalMessages,
        isCleaningMessages,
        messageUpdateTrigger,
        isSyncing,
        pendingMessages,
        conversationId,
        isLoading,
        totalMessageCount,
        mediaMessages,
        fileMessages,
        voiceMessages,
        linkMessages,
        isLoadingMedia,
        isLoadingFiles,
        isLoadingVoice,
        isLoadingLinks,
        shouldNavigateBack,
        highlightedMessageId,
      ];
}
