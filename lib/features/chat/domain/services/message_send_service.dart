import 'package:cc/core/database/models/message.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/features/chat/domain/repositories/chat_repository.dart';

/// 消息发送服务
///
/// 统一管理消息发送逻辑，包括：
/// - 消息验证
/// - 发送状态管理
/// - 错误处理
/// - 重试机制
class MessageSendService {
  static final _instance = MessageSendService._internal();
  factory MessageSendService() => _instance;
  MessageSendService._internal();

  static final _logger = LogService.instance;

  /// 发送文本消息
  ///
  /// [repository] - 聊天仓库
  /// [conversationId] - 会话ID
  /// [text] - 消息文本
  /// [onProgress] - 发送进度回调
  /// [onSuccess] - 发送成功回调
  /// [onError] - 发送失败回调
  Future<Message> sendTextMessage({
    required ChatRepository repository,
    required String conversationId,
    required String text,
    void Function(Message message)? onProgress,
    void Function(Message message, String serverId)? onSuccess,
    void Function(Message message, String error)? onError,
  }) async {
    // 1. 验证输入
    final validatedText = _validateText(text);
    if (validatedText == null) {
      throw ArgumentError('消息文本无效');
    }

    _logger.d('开始发送文本消息', extra: {
      'conversationId': conversationId,
      'textLength': validatedText.length,
    });

    // 2. 创建临时消息
    final message = await repository.createTempMessage(
      conversationId,
      validatedText,
      'text',
    );

    try {
      // 3. 通知发送进度
      onProgress?.call(message);

      // 4. 发送到服务器
      await repository.sendMessageWithTimeout(
        message,
        timeout: const Duration(seconds: 5),
      );

      _logger.i('文本消息发送成功', extra: {
        'messageId': message.messageId,
      });

      return message;
    } catch (error) {
      _logger.e('文本消息发送失败', error: error);

      // 通知发送失败
      onError?.call(message, error.toString());

      rethrow;
    }
  }

  /// 重发消息
  ///
  /// [repository] - 聊天仓库
  /// [messageId] - 消息ID
  /// [onProgress] - 发送进度回调
  /// [onSuccess] - 发送成功回调
  /// [onError] - 发送失败回调
  Future<void> resendMessage({
    required ChatRepository repository,
    required String messageId,
    void Function(Message message)? onProgress,
    void Function(Message message, String serverId)? onSuccess,
    void Function(Message message, String error)? onError,
  }) async {
    _logger.d('开始重发消息', extra: {'messageId': messageId});

    // 1. 获取消息
    final message = await repository.getMessageById(messageId);
    if (message == null) {
      throw ArgumentError('消息不存在: $messageId');
    }

    if (message.status != 'failed') {
      throw StateError('只能重发失败的消息，当前状态: ${message.status}');
    }

    try {
      // 2. 重置消息状态
      await repository.updateMessageStatus(messageId, 'sending');

      // 3. 通知发送进度
      onProgress?.call(message);

      // 4. 重新发送
      await repository.sendMessageWithTimeout(
        message,
        timeout: const Duration(seconds: 5),
      );

      _logger.i('消息重发成功', extra: {'messageId': messageId});
    } catch (error) {
      _logger.e('消息重发失败', error: error);

      // 重新标记为失败
      await repository.markMessageAsFailed(
          messageId, '重发失败: ${error.toString()}');

      // 通知发送失败
      onError?.call(message, error.toString());

      rethrow;
    }
  }

  /// 验证文本消息
  String? _validateText(String text) {
    final trimmedText = text.trim();

    // 检查是否为空
    if (trimmedText.isEmpty) {
      _logger.w('消息文本为空');
      return null;
    }

    // 检查长度限制
    if (trimmedText.length > 4000) {
      _logger.w('消息文本过长', extra: {'length': trimmedText.length});
      throw ArgumentError('消息内容过长，请控制在4000字符以内');
    }

    return trimmedText;
  }

  /// 获取消息发送状态描述
  static String getStatusDescription(String status) {
    switch (status) {
      case 'sending':
        return '发送中...';
      case 'sent':
        return '已发送';
      case 'delivered':
        return '已送达';
      case 'read':
        return '已读';
      case 'failed':
        return '发送失败';
      default:
        return '未知状态';
    }
  }

  /// 检查消息是否可以重发
  static bool canResend(Message message) {
    return message.status == 'failed';
  }

  /// 检查消息是否正在发送
  static bool isSending(Message message) {
    return message.status == 'sending';
  }
}
