import 'package:cc/core/database/models/message.dart';
import 'package:cc/core/database/models/user.dart';
import 'package:equatable/equatable.dart';

/// 单个聊天会话的状态
class ChatState extends Equatable {
  /// 当前会话ID
  final String conversationId;

  /// 当前会话中的消息
  final List<Message> messages;

  /// 当前正在输入的用户列表
  final List<String> typingUsers;

  /// 是否正在加载消息
  final bool isLoadingMessages;

  /// 是否正在加载更多消息
  final bool isLoadingMoreMessages;

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

  /// 构造函数
  const ChatState({
    required this.conversationId,
    required this.messages,
    required this.typingUsers,
    required this.isLoadingMessages,
    required this.isLoadingMoreMessages,
    required this.networkStatus,
    this.errorMessage,
    this.contact,
    this.currentUser,
    this.lastReadMessageId,
  });

  /// 初始状态
  factory ChatState.initial(String conversationId) {
    return ChatState(
      conversationId: conversationId,
      messages: const [],
      typingUsers: const [],
      isLoadingMessages: false,
      isLoadingMoreMessages: false,
      networkStatus: 'connected',
      errorMessage: null,
    );
  }

  /// 复制方法
  ChatState copyWith({
    String? conversationId,
    List<Message>? messages,
    List<String>? typingUsers,
    bool? isLoadingMessages,
    bool? isLoadingMoreMessages,
    String? networkStatus,
    String? errorMessage,
    User? contact,
    User? currentUser,
    String? lastReadMessageId,
  }) {
    return ChatState(
      conversationId: conversationId ?? this.conversationId,
      messages: messages ?? this.messages,
      typingUsers: typingUsers ?? this.typingUsers,
      isLoadingMessages: isLoadingMessages ?? this.isLoadingMessages,
      isLoadingMoreMessages:
          isLoadingMoreMessages ?? this.isLoadingMoreMessages,
      networkStatus: networkStatus ?? this.networkStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      contact: contact ?? this.contact,
      currentUser: currentUser ?? this.currentUser,
      lastReadMessageId: lastReadMessageId ?? this.lastReadMessageId,
    );
  }

  // 定义网络状态常量
  static const String kNetworkStatusConnected = 'connected';
  static const String kNetworkStatusConnecting = 'connecting';
  static const String kNetworkStatusDisconnected = 'disconnected';
  static const String kNetworkStatusError = 'error';

  @override
  List<Object?> get props => [
        conversationId,
        messages,
        typingUsers,
        isLoadingMessages,
        isLoadingMoreMessages,
        networkStatus,
        errorMessage,
        contact,
        currentUser,
        lastReadMessageId,
      ];
}
