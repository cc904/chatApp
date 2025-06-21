import 'package:equatable/equatable.dart';
import 'package:cc/core/database/models/message.dart';
import 'package:cc/core/proto/generated/message.pb.dart' show LoadingType;

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
  final LoadingType loadingType;

  MessageAddedEvent({
    required super.conversationId,
    required this.newMessages,
    required this.loadingType,
    DateTime? timestamp,
  }) : super(timestamp: timestamp ?? DateTime.now());

  @override
  List<Object?> get props => [...super.props, newMessages, loadingType];
}

/// 消息更新事件
class MessageUpdatedEvent extends MessageUpdateEvent {
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

/// 消息发送更新事件
class UpdateSendEvent extends MessageUpdateEvent {
  final String tempId;
  final String messageId;
  final int messageIndex;

  UpdateSendEvent({
    required super.conversationId,
    required this.tempId,
    required this.messageId,
    required this.messageIndex,
    DateTime? timestamp,
  }) : super(timestamp: timestamp ?? DateTime.now());

  @override
  List<Object?> get props => [...super.props, tempId, messageId, messageIndex];
}

/// 详细的加载状态更新
class LoadingStateUpdate extends Equatable {
  final String conversationId;
  final LoadingType loadingType;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? metadata;
  final DateTime timestamp;

  LoadingStateUpdate({
    required this.conversationId,
    required this.loadingType,
    required this.isLoading,
    this.error,
    this.metadata,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// 开始加载
  factory LoadingStateUpdate.start({
    required String conversationId,
    required LoadingType loadingType,
    Map<String, dynamic>? metadata,
  }) =>
      LoadingStateUpdate(
        conversationId: conversationId,
        loadingType: loadingType,
        isLoading: true,
        metadata: metadata,
      );

  /// 完成加载
  factory LoadingStateUpdate.complete({
    required String conversationId,
    required LoadingType loadingType,
    Map<String, dynamic>? metadata,
  }) =>
      LoadingStateUpdate(
        conversationId: conversationId,
        loadingType: loadingType,
        isLoading: false,
        metadata: metadata,
      );

  /// 加载错误
  factory LoadingStateUpdate.error({
    required String conversationId,
    required LoadingType loadingType,
    required String error,
    Map<String, dynamic>? metadata,
  }) =>
      LoadingStateUpdate(
        conversationId: conversationId,
        loadingType: loadingType,
        isLoading: false,
        error: error,
        metadata: metadata,
      );

  @override
  List<Object?> get props => [
        conversationId,
        loadingType,
        isLoading,
        error,
        metadata,
        timestamp,
      ];
}
