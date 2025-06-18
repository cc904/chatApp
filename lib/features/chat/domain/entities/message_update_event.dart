import 'package:equatable/equatable.dart';
import 'package:cc/core/database/models/message.dart';

/// 消息插入位置枚举
enum MessageInsertPosition {
  before, // 插入到当前消息列表前面（历史消息）
  after, // 插入到当前消息列表后面（新消息）
  replace, // 完全替换当前消息列表
  merge, // 智能合并到当前列表
}

/// 加载上下文枚举
enum LoadingContext {
  initial, // 初始加载
  loadMoreBefore, // 加载历史消息
  loadMoreAfter, // 加载新消息
  search, // 搜索相关
  refresh, // 刷新
  sendMessage, // 发送消息
  fetchMessages, // 网络获取消息
}

/// 消息范围定义，用于精确描述加载的数据范围
class MessageRange extends Equatable {
  final int? startMessageIndex;
  final int? endMessageIndex;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? anchorMessageId;
  final int? contextSize;

  const MessageRange({
    this.startMessageIndex,
    this.endMessageIndex,
    this.startTime,
    this.endTime,
    this.anchorMessageId,
    this.contextSize,
  });

  /// 从锚点消息创建范围
  factory MessageRange.fromAnchor({
    required String anchorMessageId,
    int contextSize = 25,
  }) =>
      MessageRange(
        anchorMessageId: anchorMessageId,
        contextSize: contextSize,
      );

  /// 从时间范围创建
  factory MessageRange.fromTimeRange({
    required DateTime startTime,
    required DateTime endTime,
  }) =>
      MessageRange(
        startTime: startTime,
        endTime: endTime,
      );

  /// 从索引范围创建
  factory MessageRange.fromIndexRange({
    required int startIndex,
    required int endIndex,
  }) =>
      MessageRange(
        startMessageIndex: startIndex,
        endMessageIndex: endIndex,
      );

  @override
  List<Object?> get props => [
        startMessageIndex,
        endMessageIndex,
        startTime,
        endTime,
        anchorMessageId,
        contextSize,
      ];
}

/// 消息更新事件的基类
abstract class MessageUpdateEvent extends Equatable {
  final String conversationId;
  final DateTime timestamp;

  const MessageUpdateEvent({
    required this.conversationId,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [conversationId, timestamp];
}

/// 消息添加事件
class MessageAddedEvent extends MessageUpdateEvent {
  final List<Message> newMessages;
  final MessageInsertPosition position;

  MessageAddedEvent({
    required super.conversationId,
    required this.newMessages,
    required this.position,
    DateTime? timestamp,
  }) : super(timestamp: timestamp ?? DateTime.now());

  @override
  List<Object?> get props => [...super.props, newMessages, position];
}

/// 消息更新事件
class MessageUpdatedEvent extends MessageUpdateEvent {
  final Message updatedMessage;

  MessageUpdatedEvent({
    required super.conversationId,
    required this.updatedMessage,
    DateTime? timestamp,
  }) : super(timestamp: timestamp ?? DateTime.now());

  @override
  List<Object?> get props => [...super.props, updatedMessage];
}

/// 消息移除事件
class MessageRemovedEvent extends MessageUpdateEvent {
  final String messageId;

  MessageRemovedEvent({
    required super.conversationId,
    required this.messageId,
    DateTime? timestamp,
  }) : super(timestamp: timestamp ?? DateTime.now());

  @override
  List<Object?> get props => [...super.props, messageId];
}

/// 消息范围加载事件
class MessagesRangeLoadedEvent extends MessageUpdateEvent {
  final List<Message> messages;
  final MessageRange range;
  final bool shouldReplace; // 是否完全替换当前列表

  MessagesRangeLoadedEvent({
    required super.conversationId,
    required this.messages,
    required this.range,
    required this.shouldReplace,
    DateTime? timestamp,
  }) : super(timestamp: timestamp ?? DateTime.now());

  @override
  List<Object?> get props => [...super.props, messages, range, shouldReplace];
}

/// 详细的加载状态更新
class LoadingStateUpdate extends Equatable {
  final String conversationId;
  final LoadingContext context;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? metadata;
  final DateTime timestamp;

  LoadingStateUpdate({
    required this.conversationId,
    required this.context,
    required this.isLoading,
    this.error,
    this.metadata,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// 开始加载
  factory LoadingStateUpdate.start({
    required String conversationId,
    required LoadingContext context,
    Map<String, dynamic>? metadata,
  }) =>
      LoadingStateUpdate(
        conversationId: conversationId,
        context: context,
        isLoading: true,
        metadata: metadata,
      );

  /// 完成加载
  factory LoadingStateUpdate.complete({
    required String conversationId,
    required LoadingContext context,
    Map<String, dynamic>? metadata,
  }) =>
      LoadingStateUpdate(
        conversationId: conversationId,
        context: context,
        isLoading: false,
        metadata: metadata,
      );

  /// 加载错误
  factory LoadingStateUpdate.error({
    required String conversationId,
    required LoadingContext context,
    required String error,
    Map<String, dynamic>? metadata,
  }) =>
      LoadingStateUpdate(
        conversationId: conversationId,
        context: context,
        isLoading: false,
        error: error,
        metadata: metadata,
      );

  @override
  List<Object?> get props => [
        conversationId,
        context,
        isLoading,
        error,
        metadata,
        timestamp,
      ];
}
