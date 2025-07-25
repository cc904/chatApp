import 'package:cc/core/database/drift_database.dart';
import 'package:cc/core/proto/generated/message.pb.dart';

/// 消息发送仓库接口
/// 专门负责各种类型消息的发送、重发、状态管理等功能
abstract class ChatRepositorySend {
  /// 💢💢💢💢💢💢💢💢💢💢💢💢💢💢    消息发送    💢💢💢💢💢💢💢💢💢💢💢💢💢💢

  /// 发送文本消息
  /// [conversationId] - 会话ID
  /// [text] - 消息文本内容
  /// 返回创建的消息对象
  Future<Message> sendTextMessage(String conversationId, String text);

  /// 发送图片消息
  /// [conversationId] - 会话ID
  /// [localPath] - 图片本地路径
  /// [mediaUrl] - 可选的媒体URL,如已上传则直接使用
  /// [caption] - 可选的图片说明文字
  /// [fsId] - 文件服务器ID
  /// [fileName] - 服务器文件名
  /// [width] - 图片宽度
  /// [height] - 图片高度
  /// [fileSize] - 文件大小
  /// [mimeType] - MIME类型
  /// 返回创建的消息对象
  Future<Message> sendImageMessage(String conversationId, String localPath,
      {String? mediaUrl, String? caption, String? fsId, String? fileName, int? width, int? height, double? fileSize, String? mimeType});

  /// 发送语音消息
  /// [conversationId] - 会话ID
  /// [localPath] - 语音文件本地路径
  /// [duration] - 语音时长（秒）
  /// [mediaUrl] - 可选的媒体URL,如已上传则直接使用
  /// [fsId] - 文件服务器ID
  /// [fileName] - 服务器文件名
  /// [fileSize] - 文件大小
  /// [mimeType] - MIME类型
  /// 返回创建的消息对象
  Future<Message> sendVoiceMessage(
      String conversationId, String localPath, int duration,
      {String? mediaUrl, String? fsId, String? fileName, double? fileSize, String? mimeType});

  /// 发送文件消息
  /// [conversationId] - 会话ID
  /// [localPath] - 文件本地路径
  /// [fileName] - 文件名
  /// [fileSize] - 文件大小
  /// [mediaUrl] - 可选的媒体URL,如已上传则直接使用
  /// 返回创建的消息对象
  Future<Message> sendFileMessage(
      String conversationId, String localPath, String fileName, double fileSize,
      {String? mediaUrl});

  /// 发送视频消息
  /// [conversationId] - 会话ID
  /// [localPath] - 视频文件本地路径
  /// [duration] - 视频时长（秒）
  /// [thumbnailUrl] - 可选的缩略图URL
  /// [mediaUrl] - 可选的媒体URL,如已上传则直接使用
  /// [isServerProcessed] - 是否由服务器处理缩略图
  /// 返回创建的消息对象
  Future<Message> sendVideoMessage(
      String conversationId, String localPath, int duration,
      {String? thumbnailUrl, String? mediaUrl, bool isServerProcessed = false});

  /// 💢💢💢💢💢💢💢💢💢💢💢💢💢💢    消息管理    💢💢💢💢💢💢💢💢💢💢💢💢💢💢

  /// 创建临时消息（用于发送前显示）
  /// [conversationId] - 会话ID
  /// [content] - 消息内容
  /// [type] - 消息类型
  /// 返回创建的临时消息对象
  Future<Message> createTempMessage(
      String conversationId, String content, MessageType type);

  /// 发送消息（带超时机制，不等待响应）
  /// [message] - 要发送的消息对象
  /// [timeout] - 超时时间，默认5秒
  Future<void> sendMessageWithTimeout(Message message,
      {Duration timeout = const Duration(seconds: 5)});

  /// 重新发送失败的消息
  /// [messageId] - 要重发的消息ID
  /// 返回新的消息ID
  Future<String> resendMessage(String messageId);

  /// 标记消息为失败状态
  /// [messageId] - 消息ID
  /// [errorReason] - 失败原因
  Future<void> markMessageAsFailed(String messageId, String errorReason);

  /// 根据消息ID获取消息
  /// [messageId] - 消息ID
  /// 返回消息对象，如果不存在则返回null
  Future<Message?> getMessageById(String messageId);

  /// 更新消息状态
  /// [messageId] - 消息ID
  /// [status] - 新的消息状态
  Future<void> updateMessageStatus(String messageId, MessageStatus status);

  /// 💢💢💢💢💢💢💢💢💢💢💢💢💢💢    发送状态监听    💢💢💢💢💢💢💢💢💢💢💢💢💢💢

  /// 获取消息发送状态流
  /// 用于监听消息发送、状态更新等事件
  Stream<MessageSendEvent> getMessageSendStatusStream();
}

/// 消息发送事件
class MessageSendEvent {
  /// 事件类型
  final MessageSendEventType type;

  /// 相关的消息ID
  final String messageId;

  /// 会话ID
  final String conversationId;

  /// 事件数据
  final Map<String, dynamic>? data;

  /// 事件时间戳
  final DateTime timestamp;

  const MessageSendEvent({
    required this.type,
    required this.messageId,
    required this.conversationId,
    this.data,
    required this.timestamp,
  });

  factory MessageSendEvent.sendStarted({
    required String messageId,
    required String conversationId,
  }) {
    return MessageSendEvent(
      type: MessageSendEventType.sendStarted,
      messageId: messageId,
      conversationId: conversationId,
      timestamp: DateTime.now(),
    );
  }

  factory MessageSendEvent.sendSuccess({
    required String messageId,
    required String conversationId,
    String? serverMessageId,
    int? messageIndex,
  }) {
    return MessageSendEvent(
      type: MessageSendEventType.sendSuccess,
      messageId: messageId,
      conversationId: conversationId,
      data: {
        'serverMessageId': serverMessageId,
        'messageIndex': messageIndex,
      },
      timestamp: DateTime.now(),
    );
  }

  factory MessageSendEvent.sendFailed({
    required String messageId,
    required String conversationId,
    required String errorReason,
  }) {
    return MessageSendEvent(
      type: MessageSendEventType.sendFailed,
      messageId: messageId,
      conversationId: conversationId,
      data: {'errorReason': errorReason},
      timestamp: DateTime.now(),
    );
  }

  factory MessageSendEvent.sendTimeout({
    required String messageId,
    required String conversationId,
  }) {
    return MessageSendEvent(
      type: MessageSendEventType.sendTimeout,
      messageId: messageId,
      conversationId: conversationId,
      timestamp: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'MessageSendEvent('
        'type: $type, '
        'messageId: $messageId, '
        'conversationId: $conversationId, '
        'timestamp: $timestamp'
        ')';
  }
}

/// 消息发送事件类型
enum MessageSendEventType {
  /// 开始发送
  sendStarted,

  /// 发送成功
  sendSuccess,

  /// 发送失败
  sendFailed,

  /// 发送超时
  sendTimeout,

  /// 文件上传开始
  uploadStarted,

  /// 文件上传进度
  uploadProgress,

  /// 文件上传完成
  uploadCompleted,

  /// 文件上传失败
  uploadFailed,
}
