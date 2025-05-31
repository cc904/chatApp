import 'package:cc/core/database/models/message.dart';
import 'package:cc/core/database/models/user.dart';
import 'package:cc/features/chat/domain/entities/message_timeline.dart';
import 'package:equatable/equatable.dart';

/// 用于区分null值和未传值的包装类
class NullableValue<T> {
  final T? value;
  final bool hasValue;

  const NullableValue(this.value) : hasValue = true;
  const NullableValue.absent()
      : value = null,
        hasValue = false;
}

/// 单个聊天会话的状态
class ChatState extends Equatable {
  /// 当前会话ID
  final String conversationId;

  /// 当前会话中的消息（从Timeline获取的可视消息）
  final List<Message> messages;

  /// MessageTimeline缓存实例
  final MessageTimeline? timeline;

  /// 当前正在输入的用户列表
  final List<String> typingUsers;

  /// 是否正在加载消息
  final bool isLoadingMessages;

  /// 是否正在加载更多消息
  final bool isLoadingMoreMessages;

  /// 是否正在预加载缓存
  final bool isPreloading;

  /// 是否正在发送消息
  final bool isSending;

  /// 网络状态
  final String networkStatus;

  /// 错误信息
  final String? errorMessage;

  /// 联系人信息
  final User? contact;

  /// 当前用户信息
  final User? currentUser;

  /// 最后阅读的消息ID
  final String? lastReadMessageId;

  /// 当前滚动位置（用于缓存恢复）
  final int? currentScrollPosition;

  /// 是否有更多历史消息可加载
  final bool hasMoreHistory;

  /// 是否有更多新消息可加载
  final bool hasMoreRecent;

  /// 未读消息数量
  final int unreadCount;

  /// 第一条未读消息ID
  final String? firstUnreadMessageId;

  /// 构造函数
  const ChatState({
    required this.conversationId,
    required this.messages,
    this.timeline,
    required this.typingUsers,
    required this.isLoadingMessages,
    required this.isLoadingMoreMessages,
    required this.isPreloading,
    required this.isSending,
    required this.networkStatus,
    this.errorMessage,
    this.contact,
    this.currentUser,
    this.lastReadMessageId,
    this.currentScrollPosition,
    required this.hasMoreHistory,
    required this.hasMoreRecent,
    required this.unreadCount,
    this.firstUnreadMessageId,
  });

  /// 初始状态
  factory ChatState.initial(String conversationId) {
    return ChatState(
      conversationId: conversationId,
      messages: const [],
      timeline: null,
      typingUsers: const [],
      isLoadingMessages: false,
      isLoadingMoreMessages: false,
      isPreloading: false,
      isSending: false,
      networkStatus: 'connected',
      errorMessage: null,
      hasMoreHistory: true,
      hasMoreRecent: false,
      unreadCount: 0,
    );
  }

  /// 复制方法
  ChatState copyWith({
    String? conversationId,
    List<Message>? messages,
    Object? timeline = const NullableValue.absent(),
    List<String>? typingUsers,
    bool? isLoadingMessages,
    bool? isLoadingMoreMessages,
    bool? isPreloading,
    bool? isSending,
    String? networkStatus,
    String? errorMessage,
    User? contact,
    User? currentUser,
    String? lastReadMessageId,
    Object? currentScrollPosition = const NullableValue.absent(),
    bool? hasMoreHistory,
    bool? hasMoreRecent,
    int? unreadCount,
    String? firstUnreadMessageId,
  }) {
    // 处理timeline字段
    MessageTimeline? newTimeline;
    if (timeline is NullableValue<MessageTimeline>) {
      newTimeline = timeline.hasValue ? timeline.value : this.timeline;
    } else if (timeline is MessageTimeline) {
      newTimeline = timeline;
    } else if (timeline == null) {
      newTimeline = null;
    } else {
      newTimeline = this.timeline;
    }

    // 处理currentScrollPosition字段
    int? newCurrentScrollPosition;
    if (currentScrollPosition is NullableValue<int>) {
      newCurrentScrollPosition = currentScrollPosition.hasValue
          ? currentScrollPosition.value
          : this.currentScrollPosition;
    } else if (currentScrollPosition is int) {
      newCurrentScrollPosition = currentScrollPosition;
    } else if (currentScrollPosition == null) {
      newCurrentScrollPosition = null;
    } else {
      newCurrentScrollPosition = this.currentScrollPosition;
    }

    return ChatState(
      conversationId: conversationId ?? this.conversationId,
      messages: messages ?? this.messages,
      timeline: newTimeline,
      typingUsers: typingUsers ?? this.typingUsers,
      isLoadingMessages: isLoadingMessages ?? this.isLoadingMessages,
      isLoadingMoreMessages:
          isLoadingMoreMessages ?? this.isLoadingMoreMessages,
      isPreloading: isPreloading ?? this.isPreloading,
      isSending: isSending ?? this.isSending,
      networkStatus: networkStatus ?? this.networkStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      contact: contact ?? this.contact,
      currentUser: currentUser ?? this.currentUser,
      lastReadMessageId: lastReadMessageId ?? this.lastReadMessageId,
      currentScrollPosition: newCurrentScrollPosition,
      hasMoreHistory: hasMoreHistory ?? this.hasMoreHistory,
      hasMoreRecent: hasMoreRecent ?? this.hasMoreRecent,
      unreadCount: unreadCount ?? this.unreadCount,
      firstUnreadMessageId: firstUnreadMessageId ?? this.firstUnreadMessageId,
    );
  }

  /// 便利方法：创建一个表示null值的timeline包装
  static NullableValue<MessageTimeline> get nullTimeline =>
      const NullableValue<MessageTimeline>(null);

  /// 便利方法：创建一个表示null值的scrollPosition包装
  static NullableValue<int> get nullScrollPosition =>
      const NullableValue<int>(null);

  // 定义网络状态常量
  static const String kNetworkStatusConnected = 'connected';
  static const String kNetworkStatusConnecting = 'connecting';
  static const String kNetworkStatusDisconnected = 'disconnected';
  static const String kNetworkStatusError = 'error';

  /// 获取当前可见消息范围
  /// [start] 开始索引
  /// [count] 消息数量
  List<Message> getVisibleMessages({int start = 0, int? count}) {
    if (timeline == null) return messages;

    final end = count != null ? start + count : null;
    return timeline!.getRange(start, end ?? timeline!.length);
  }

  /// 获取Timeline统计信息
  Map<String, dynamic> getTimelineStats() {
    if (timeline == null) {
      return {
        'totalMessages': messages.length,
        'unreadCount': unreadCount,
        'hasMoreHistory': hasMoreHistory,
        'hasMoreRecent': hasMoreRecent,
      };
    }

    return {
      'totalMessages': timeline!.length,
      'unreadCount': timeline!.unreadCount,
      'hasMoreHistory': timeline!.hasMoreHistory,
      'hasMoreRecent': timeline!.hasMoreRecent,
      'earliestTime': timeline!.earliestLoadedTime?.toIso8601String(),
      'latestTime': timeline!.latestLoadedTime?.toIso8601String(),
    };
  }

  /// 检查是否需要预加载
  bool get shouldPreload =>
      timeline == null && !isPreloading && !isLoadingMessages;

  /// 检查是否可以加载更多历史消息
  bool get canLoadMoreHistory => timeline?.hasMoreHistory ?? hasMoreHistory;

  /// 检查是否可以加载更多新消息
  bool get canLoadMoreRecent => timeline?.hasMoreRecent ?? hasMoreRecent;

  @override
  List<Object?> get props => [
        conversationId,
        messages,
        timeline,
        typingUsers,
        isLoadingMessages,
        isLoadingMoreMessages,
        isPreloading,
        isSending,
        networkStatus,
        errorMessage,
        contact,
        currentUser,
        lastReadMessageId,
        currentScrollPosition,
        hasMoreHistory,
        hasMoreRecent,
        unreadCount,
        firstUnreadMessageId,
      ];
}
