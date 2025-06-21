import 'dart:async';
import 'package:cc/core/database/models/current_user.dart';
import 'package:cc/core/database/models/message.dart';
import 'package:cc/core/database/database_initializer.dart';
import 'package:cc/core/services/communication_service.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/adapters/message_adapter.dart';
import 'package:cc/features/chat/domain/repositories/chat_repository_send.dart';
import 'package:cc/features/chat/domain/repositories/chat_repository.dart';
import 'package:cc/features/chat/domain/entities/message_update_event.dart';
import 'package:cc/core/proto/generated/message.pb.dart' show LoadingType;
import 'package:isar/isar.dart';

/// ChatRepositorySend的实现类
/// 专门负责消息发送相关的功能
class ChatRepositorySendImpl implements ChatRepositorySend {
  final CommunicationService _communicationService = CommunicationService();
  final CurrentUser _currentUser;
  final ChatRepository _chatRepository;
  final LogService _logger = LogService.instance;

  // 数据库实例
  Isar get _isar => DatabaseInitializer.isar;
  IsarCollection<Message> get _messages => _isar.messages;

  // 消息发送状态流控制器
  final _messageSendStatusController =
      StreamController<MessageSendEvent>.broadcast();

  /// 构造函数
  ChatRepositorySendImpl({
    required CurrentUser currentUser,
    required ChatRepository chatRepository,
  })  : _currentUser = currentUser,
        _chatRepository = chatRepository;

  /// 发送文本消息
  @override
  Future<Message> sendTextMessage(String conversationId, String text) async {
    final message =
        await _createMessage(conversationId, text, MessageType.text);
    await sendMessageWithTimeout(message);
    return message;
  }

  /// 发送图片消息
  @override
  Future<Message> sendImageMessage(String conversationId, String localPath,
      {String? mediaUrl}) async {
    final message = await _createMessage(conversationId, '', MessageType.image);
    message.localPath = localPath;
    message.mediaUrl = mediaUrl;
    await sendMessageWithTimeout(message);
    return message;
  }

  /// 发送语音消息
  @override
  Future<Message> sendVoiceMessage(
      String conversationId, String localPath, int duration,
      {String? mediaUrl}) async {
    final message = await _createMessage(conversationId, '', MessageType.voice);
    message.localPath = localPath;
    message.mediaUrl = mediaUrl;
    message.duration = duration;
    await sendMessageWithTimeout(message);
    return message;
  }

  /// 发送文件消息
  @override
  Future<Message> sendFileMessage(
      String conversationId, String localPath, String fileName, double fileSize,
      {String? mediaUrl}) async {
    final message = await _createMessage(conversationId, '', MessageType.file);
    message.localPath = localPath;
    message.fileName = fileName;
    message.fileSize = fileSize;
    message.mediaUrl = mediaUrl;
    await sendMessageWithTimeout(message);
    return message;
  }

  /// 发送视频消息
  @override
  Future<Message> sendVideoMessage(
      String conversationId, String localPath, int duration,
      {String? thumbnailUrl,
      String? mediaUrl,
      bool isServerProcessed = false}) async {
    final message = await _createMessage(conversationId, '', MessageType.video);
    message.localPath = localPath;
    message.mediaUrl = mediaUrl;
    message.thumbnailUrl = thumbnailUrl;
    message.duration = duration;
    await sendMessageWithTimeout(message);
    return message;
  }

  /// 创建临时消息
  @override
  Future<Message> createTempMessage(
      String conversationId, String content, MessageType type) async {
    return await _createMessage(conversationId, content, type);
  }

  /// 发送消息（带超时机制）
  @override
  Future<void> sendMessageWithTimeout(Message message,
      {Duration timeout = const Duration(seconds: 3)}) async {
    // 保存到数据库
    await _isar.writeTxn(() async {
      message.id = await _messages.put(message);
    });

    await _notifyMessageAdded(message);

    // 发送到服务器
    final protoMsg = MessageAdapter.toProto(message);
    _communicationService.emitProto('message:send', protoMsg);

    // 超时处理
    Timer(timeout, () async {
      final currentMessage = await getMessageById(message.messageId);
      if (currentMessage?.status == MessageStatus.sending) {
        await markMessageAsFailed(message.messageId, '发送超时');
      }
    });
  }

  /// 重新发送失败的消息
  @override
  Future<String> resendMessage(String messageId) async {
    final message = await getMessageById(messageId);
    if (message == null) throw Exception('找不到消息');

    await updateMessageStatus(messageId, MessageStatus.sending);
    await sendMessageWithTimeout(message);
    return messageId;
  }

  /// 标记消息为失败状态
  @override
  Future<void> markMessageAsFailed(String messageId, String errorReason) async {
    await updateMessageStatus(messageId, MessageStatus.failed);
  }

  /// 根据消息ID获取消息
  @override
  Future<Message?> getMessageById(String messageId) async {
    return await _messages.filter().messageIdEqualTo(messageId).findFirst();
  }

  /// 更新消息状态
  @override
  Future<void> updateMessageStatus(
      String messageId, MessageStatus status) async {
    final message = await getMessageById(messageId);
    if (message == null) return;

    await _isar.writeTxn(() async {
      message.status = status;
      await _messages.put(message);
    });

    await _notifyMessageUpdated(message);
  }

  /// 获取消息发送状态流
  @override
  Stream<MessageSendEvent> getMessageSendStatusStream() {
    return _messageSendStatusController.stream;
  }

  /// 创建消息
  Future<Message> _createMessage(
      String conversationId, String text, MessageType type) async {
    // 💢💢💢 获取当前会话中最大的messageIndex
    final maxMessageIndex = await _getMaxMessageIndex(conversationId);
    final newMessageIndex = maxMessageIndex + 100;

    final message = Message()
      ..messageId =
          'temp_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}'
      ..conversationId = conversationId
      ..senderId = _currentUser.userId
      ..senderName = _currentUser.name
      ..type = type
      ..text = text.isEmpty ? null : text
      ..status = MessageStatus.sending
      ..messageIndex = newMessageIndex // 💢💢💢 设置messageIndex
      ..createdAt = DateTime.now();

    return message;
  }

  /// 💢💢💢 新增：获取会话中最大的messageIndex
  Future<int> _getMaxMessageIndex(String conversationId) async {
    final maxMessage = await _messages
        .filter()
        .conversationIdEqualTo(conversationId)
        .sortByMessageIndexDesc()
        .limit(1)
        .findFirst();

    return maxMessage?.messageIndex ?? 0;
  }

  /// 💢💢💢 新增：通知ChatRepository发出消息添加事件
  Future<void> _notifyMessageAdded(Message message) async {
    try {
      // 💢💢💢 使用公共接口方法
      _chatRepository.notifyMessageUpdate(MessageAddedEvent(
        conversationId: message.conversationId,
        newMessages: [message],
        loadingType: LoadingType.ADD, // 新发送的消息
      ));
    } catch (error) {
      // 如果通知失败，记录错误但不影响消息发送
      _logger.e('通知消息添加事件失败', error: error);
    }
  }

  /// 💢💢💢 新增：通知ChatRepository发出消息更新事件
  Future<void> _notifyMessageUpdated(Message message) async {
    try {
      // 💢💢💢 使用公共接口方法，传递messageId和更新的字段
      _chatRepository.notifyMessageUpdate(MessageUpdatedEvent(
        conversationId: message.conversationId,
        messageId: message.messageId,
        updatedFields: {
          'status': message.status.name,
          'updatedAt': message.updatedAt?.toIso8601String(),
        },
      ));
    } catch (error) {
      // 如果通知失败，记录错误但不影响消息更新
      _logger.e('通知消息更新事件失败', error: error);
    }
  }
}
