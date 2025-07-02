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
      {String? mediaUrl, String? caption}) async {
    final message = await _createMessage(conversationId, '', MessageType.image);
    message.localPath = localPath;
    message.mediaUrl = mediaUrl;
    if (caption != null && caption.isNotEmpty) {
      message.caption = caption;
    }
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
      {Duration timeout = const Duration(seconds: 10)}) async {
    // 保存到数据库
    await _isar.writeTxn(() async {
      message.id = await _messages.put(message);
    });

    await _notifyMessageAdded(message);

    // 发送到服务器
    final protoMsg = MessageAdapter.toProto(message);
    final sendSuccess =
        await _communicationService.emitProto('message:send', protoMsg);

    _logger.i('💌 消息发送请求已发出', extra: {
      'tempId': message.tempId, // 💢💢💢 使用临时ID
      'sendSuccess': sendSuccess,
      'conversationId': message.conversationId,
      'type': message.type.name,
    });

    // 如果立即发送失败（如网络断开），直接标记为失败
    if (!sendSuccess) {
      _logger.w('💌 消息发送立即失败，网络连接问题', extra: {
        'tempId': message.tempId, // 💢💢💢 使用临时ID
      });
      await markMessageAsFailed(message.tempId!, '网络连接失败'); // 💢💢💢 传递tempId
      return;
    }

    // 超时处理 - 延长超时时间到10秒，给网络更多时间
    Timer(timeout, () async {
      final currentMessage =
          await getMessageById(message.tempId!); // 💢💢💢 使用tempId查找
      if (currentMessage?.status == MessageStatus.sending) {
        _logger.w('💌 消息发送超时', extra: {
          'tempId': message.tempId, // 💢💢💢 使用临时ID
          'timeoutSeconds': timeout.inSeconds,
        });
        await markMessageAsFailed(
            message.tempId!, '发送超时(${timeout.inSeconds}秒)'); // 💢💢💢 传递tempId
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
    // 💢💢💢 如果是临时ID，按tempId查找
    if (messageId.startsWith('temp_')) {
      return await _messages.filter().tempIdEqualTo(messageId).findFirst();
    }
    // 否则按正常messageId查找
    return await _messages.filter().messageIdEqualTo(messageId).findFirst();
  }

  /// 更新消息状态
  @override
  Future<void> updateMessageStatus(
      String messageId, MessageStatus status) async {
    final message = await getMessageById(messageId);
    if (message == null) return;

    // 💢💢💢 检查是否可以更新状态：已删除或撤回的消息状态不能被其他状态覆盖
    bool shouldUpdateStatus = true;
    if (message.status == MessageStatus.deleted ||
        message.status == MessageStatus.revoked) {
      if (status == MessageStatus.deleted || status == MessageStatus.revoked) {
        // 允许删除/撤回状态之间的转换
        shouldUpdateStatus = true;
      } else {
        // 不允许从删除/撤回状态变为其他状态
        shouldUpdateStatus = false;
        _logger.w('消息已删除或撤回，跳过状态更新', extra: {
          'messageId': messageId,
          'currentStatus': message.status.name,
          'attemptedStatus': status.name,
        });
      }
    }

    await _isar.writeTxn(() async {
      if (shouldUpdateStatus) {
        message.status = status;
      }
      // 更新其他字段，如更新时间
      message.updatedAt = DateTime.now();
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
    // 💢💢💢 生成临时ID，用于客户端本地标识
    final tempId =
        'temp_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';

    final message = Message()
      ..messageId = '' // 💢💢💢 初始时为空，等待服务器返回真实ID
      ..tempId = tempId // 💢💢💢 设置临时ID
      ..conversationId = conversationId
      ..senderId = _currentUser.userId
      ..senderName = _currentUser.name
      ..type = type
      ..text = text.isEmpty ? null : text
      ..status = MessageStatus.sending
      ..messageIndex = 0 // 💢💢💢 临时消息使用0值，排序时0值排在最前面
      ..createdAt = DateTime.now();

    return message;
  }

  /// 💢💢💢 新增：通知ChatRepository发出消息添加事件
  Future<void> _notifyMessageAdded(Message message) async {
    try {
      // 💢💢💢 使用公共接口方法
      _chatRepository.notifyMessageUpdate(MessageAddedEvent(
        conversationId: message.conversationId,
        newMessages: [message],
        addedEventType: AddedEventType.newMessage, // 🆕 新发送的消息
      ));
    } catch (error) {
      // 如果通知失败，记录错误但不影响消息发送
      _logger.e('通知消息添加事件失败', error: error);
    }
  }

  /// 💢💢💢 新增：通知ChatRepository发出消息更新事件
  Future<void> _notifyMessageUpdated(Message message) async {
    try {
      // 💢💢💢 修复：如果messageId为空，使用tempId
      final messageIdentifier =
          message.messageId.isNotEmpty ? message.messageId : message.tempId;

      if (messageIdentifier == null || messageIdentifier.isEmpty) {
        _logger.w('消息缺少有效标识符，无法发送更新事件', extra: {
          'messageId': message.messageId,
          'tempId': message.tempId,
        });
        return;
      }

      // 💢💢💢 使用公共接口方法，传递messageId和tempId
      _chatRepository.notifyMessageUpdate(MessageUpdatedEvent(
        conversationId: message.conversationId,
        messageId: message.messageId.isNotEmpty
            ? message.messageId
            : '', // 💢💢💢 messageId，可能为空
        tempId: message.tempId, // 💢💢💢 传递tempId
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
