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

  /// 当前会话中的消息（按时间升序排列，最新的在底部）
  final List<Message> messages;

  /// MessageTimeline缓存实例
  final MessageTimeline? timeline;

  /// 当前正在输入的用户列表
  final List<String> typingUsers;

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

  /// 联系人信息
  final User? contact;

  /// 当前用户信息
  final User? currentUser;

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

  /// 构造函数
  const ChatState({
    required this.conversationId,
    required this.messages,
    this.timeline,
    required this.typingUsers,
    required this.isLoadingMessages,
    required this.isLoadingMoreMessages,
    required this.isSending,
    required this.networkStatus,
    this.errorMessage,
    this.contact,
    this.currentUser,
    this.lastReadMessageId,
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
    bool? isSending,
    String? networkStatus,
    String? errorMessage,
    User? contact,
    User? currentUser,
    String? lastReadMessageId,
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

    return ChatState(
      conversationId: conversationId ?? this.conversationId,
      messages: messages ?? this.messages,
      timeline: newTimeline,
      typingUsers: typingUsers ?? this.typingUsers,
      isLoadingMessages: isLoadingMessages ?? this.isLoadingMessages,
      isLoadingMoreMessages:
          isLoadingMoreMessages ?? this.isLoadingMoreMessages,
      isSending: isSending ?? this.isSending,
      networkStatus: networkStatus ?? this.networkStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      contact: contact ?? this.contact,
      currentUser: currentUser ?? this.currentUser,
      lastReadMessageId: lastReadMessageId ?? this.lastReadMessageId,
      hasMoreHistory: hasMoreHistory ?? this.hasMoreHistory,
      hasMoreRecent: hasMoreRecent ?? this.hasMoreRecent,
      unreadCount: unreadCount ?? this.unreadCount,
      firstUnreadMessageId: firstUnreadMessageId ?? this.firstUnreadMessageId,
    );
  }

  /// 便利方法：创建一个表示null值的timeline包装
  static NullableValue<MessageTimeline> get nullTimeline =>
      const NullableValue<MessageTimeline>(null);

  // 定义网络状态常量
  static const String kNetworkStatusConnected = 'connected';
  static const String kNetworkStatusConnecting = 'connecting';
  static const String kNetworkStatusDisconnected = 'disconnected';
  static const String kNetworkStatusError = 'error';

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
        isSending,
        networkStatus,
        errorMessage,
        contact,
        currentUser,
        lastReadMessageId,
        hasMoreHistory,
        hasMoreRecent,
        unreadCount,
        firstUnreadMessageId,
      ];
}
