import 'package:equatable/equatable.dart';
import 'package:cc/core/database/drift_database.dart';

/// 加载状态类型枚举
enum LoadingStateType {
  /// 本地消息加载（loadMessages方法）
  isLoading,

  /// 服务器消息获取（requestMessages/_handleMessagesFetchResponse）
  isFetching,
}

/// 消息添加事件类型枚举
enum AddedEventType {
  load,

  /// 新消息添加（实时接收）
  newMessage,

  /// 搜索结果消息
  searchResult,
}

/// 消息更新事件的基类
abstract class MessagesEvent extends Equatable {
  final String conversationId;
  final DateTime timestamp;

  const MessagesEvent({
    required this.conversationId,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [conversationId, timestamp];
}

/// 消息添加事件
class MessageAddedEvent extends MessagesEvent {
  final List<Message> newMessages;
  final AddedEventType addedEventType; // 🆕 消息添加事件类型
  final int? anchorMessageIndex; // 🆕 锚点消息索引

  MessageAddedEvent({
    required super.conversationId,
    required this.newMessages,
    required this.addedEventType, // 🆕 必需的事件类型
    this.anchorMessageIndex, // 🆕 可选的锚点索引
    DateTime? timestamp,
  }) : super(timestamp: timestamp ?? DateTime.now());

  @override
  List<Object?> get props =>
      [...super.props, newMessages, addedEventType, anchorMessageIndex];
}

/// 消息更新事件
class MessageUpdatedEvent extends MessagesEvent {
  final String messageId;
  final Map<String, dynamic> updatedFields;

  MessageUpdatedEvent({
    required super.conversationId,
    required this.messageId,
    required this.updatedFields,
    DateTime? timestamp,
  }) : super(timestamp: timestamp ?? DateTime.now());

  @override
  List<Object?> get props => [...super.props, messageId, updatedFields];
}

/// 消息删除事件
class MessageRemovedEvent extends MessagesEvent {
  final String messageId;

  MessageRemovedEvent({
    required super.conversationId,
    required this.messageId,
    DateTime? timestamp,
  }) : super(timestamp: timestamp ?? DateTime.now());

  @override
  List<Object?> get props => [...super.props, messageId];
}

/// 消息发送更新事件
class UpdateSendEvent extends MessagesEvent {
  final String messageId;
  final int messageIndex;

  UpdateSendEvent({
    required super.conversationId,
    required this.messageId,
    required this.messageIndex,
    DateTime? timestamp,
  }) : super(timestamp: timestamp ?? DateTime.now());

  @override
  List<Object?> get props => [...super.props, messageId, messageIndex];
}

/// 详细的加载状态更新
class LoadingStateUpdate extends Equatable {
  final String conversationId;
  final LoadingStateType loadingStateType; // 🆕 使用独立的状态类型
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? metadata;
  final DateTime timestamp;

  LoadingStateUpdate({
    required this.conversationId,
    required this.loadingStateType, // 🆕 使用新的状态类型
    required this.isLoading,
    this.error,
    this.metadata,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// 开始加载
  factory LoadingStateUpdate.start({
    required String conversationId,
    required LoadingStateType loadingStateType, // 🆕 使用新的状态类型
    Map<String, dynamic>? metadata,
  }) =>
      LoadingStateUpdate(
        conversationId: conversationId,
        loadingStateType: loadingStateType, // 🆕 使用新的状态类型
        isLoading: true,
        metadata: metadata,
      );

  /// 完成加载
  factory LoadingStateUpdate.complete({
    required String conversationId,
    required LoadingStateType loadingStateType, // 🆕 使用新的状态类型
    Map<String, dynamic>? metadata,
  }) =>
      LoadingStateUpdate(
        conversationId: conversationId,
        loadingStateType: loadingStateType, // 🆕 使用新的状态类型
        isLoading: false,
        metadata: metadata,
      );

  /// 加载错误
  factory LoadingStateUpdate.error({
    required String conversationId,
    required LoadingStateType loadingStateType, // 🆕 使用新的状态类型
    required String error,
    Map<String, dynamic>? metadata,
  }) =>
      LoadingStateUpdate(
        conversationId: conversationId,
        loadingStateType: loadingStateType, // 🆕 使用新的状态类型
        isLoading: false,
        error: error,
        metadata: metadata,
      );

  @override
  List<Object?> get props => [
        conversationId,
        loadingStateType, // 🆕 使用新的状态类型
        isLoading,
        error,
        metadata,
        timestamp,
      ];
}
