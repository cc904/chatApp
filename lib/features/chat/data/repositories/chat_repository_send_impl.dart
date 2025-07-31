import 'dart:async';

import 'package:cc/core/database/drift_database.dart';
import 'package:cc/core/proto/generated/message.pb.dart';
import 'package:cc/core/database/database_initializer.dart';
import 'package:cc/core/services/communication_service.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/adapters/message_adapter.dart';
import 'package:cc/features/chat/domain/repositories/chat_repository_send.dart';
import 'package:cc/features/chat/domain/repositories/chat_repository.dart';
import 'package:cc/features/chat/domain/entities/message_update_event.dart';
import 'package:cc/core/utils/timezone_utils.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' as drift;
import 'dart:convert';

/// ChatRepositorySend的实现类
/// 专门负责消息发送相关的功能
class ChatRepositorySendImpl implements ChatRepositorySend {
  final CommunicationService _communicationService = CommunicationService();
  final CurrentUser _currentUser;
  final ChatRepository _chatRepository;
  final LogService _logger = LogService.instance;
  final Uuid _uuid = const Uuid(); // 💢💢💢 新增UUID生成器

  // 数据库实例
  AppDatabase get _database => DatabaseInitializer.database;

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
        await _createMessage(conversationId, text, 'TEXT');
    await sendMessageWithTimeout(message);
    return message;
  }

  /// 发送图片消息
  @override
  Future<Message> sendImageMessage(String conversationId, String localPath,
      {String? mediaUrl, String? caption, String? fsId, String? fileName, int? width, int? height, double? fileSize, String? mimeType}) async {
    
    _logger.i('📤 开始构建图片消息', extra: {
      'conversationId': conversationId,
      'localPath': localPath,
      'mediaUrl': mediaUrl,
      'caption': caption,
      'fsId': fsId,
      'fileName': fileName,
      'width': width,
      'height': height,
      'fileSize': fileSize,
      'mimeType': mimeType,
    });

    // 构建媒体内容JSON - 包装在 media_message 字段中
    final content = <String, dynamic>{
      'media_message': {
        'type': 'image',
        'local_path': localPath,
        if (mediaUrl != null) 'media_url': mediaUrl,
        if (caption != null && caption.isNotEmpty) 'caption': caption,
        if (fsId != null) 'fs_id': fsId,
        if (fileName != null) 'file_name': fileName,
        if (width != null) 'width': width,
        if (height != null) 'height': height,
        if (fileSize != null) 'file_size': fileSize,
        if (mimeType != null) 'mime_type': mimeType,
      },
    };
    
    _logger.i('📤 图片消息内容构建完成', extra: {
      'contentJson': jsonEncode(content),
      'mediaMessage_fsId': content['media_message']?['fs_id'],
      'mediaMessage_fileName': content['media_message']?['file_name'],
      'mediaMessage_mediaUrl': content['media_message']?['media_url'],
    });
    
    final message = await _createMessage(conversationId, '', 'IMAGE', content: content);
    
    _logger.i('📤 图片消息对象创建完成', extra: {
      'messageId': message.messageId,
      'messageContent': message.content,
      'messageType': message.messageType,
    });
    
    await sendMessageWithTimeout(message);
    return message;
  }

  /// 发送语音消息
  @override
  Future<Message> sendVoiceMessage(
      String conversationId, String localPath, int duration,
      {String? mediaUrl, String? fsId, String? fileName, double? fileSize, String? mimeType}) async {
    
    // 构建媒体内容JSON - 包装在 media_message 字段中
    final content = <String, dynamic>{
      'media_message': {
        'type': 'voice',
        'local_path': localPath,
        'duration': duration,
        if (mediaUrl != null) 'media_url': mediaUrl,
        if (fsId != null) 'fs_id': fsId,
        if (fileName != null) 'file_name': fileName,
        if (fileSize != null) 'file_size': fileSize,
        if (mimeType != null) 'mime_type': mimeType,
      },
    };
    
    final message = await _createMessage(conversationId, '', 'VOICE', content: content);
    await sendMessageWithTimeout(message);
    return message;
  }

  /// 发送文件消息
  @override
  Future<Message> sendFileMessage(
      String conversationId, String localPath, String fileName, double fileSize,
      {String? mediaUrl}) async {
    
    // 构建媒体内容JSON - 包装在 media_message 字段中
    final content = <String, dynamic>{
      'media_message': {
        'type': 'file',
        'local_path': localPath,
        'file_name': fileName,
        'file_size': fileSize,
        if (mediaUrl != null) 'media_url': mediaUrl,
      },
    };
    
    final message = await _createMessage(conversationId, '', 'FILE', content: content);
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
    
    // 构建媒体内容JSON - 包装在 media_message 字段中
    final content = <String, dynamic>{
      'media_message': {
        'type': 'video',
        'local_path': localPath,
        'duration': duration,
        if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
        if (mediaUrl != null) 'media_url': mediaUrl,
        'is_server_processed': isServerProcessed,
      },
    };
    
    final message = await _createMessage(conversationId, '', 'VIDEO', content: content);
    await sendMessageWithTimeout(message);
    return message;
  }

  /// 创建临时消息
  @override
  Future<Message> createTempMessage(
      String conversationId, String content, MessageType type) async {
    // Convert MessageType enum to string for internal use
    final typeString = type.name;
    return await _createMessage(conversationId, content, typeString);
  }

  /// 发送消息（带超时机制）
  @override
  Future<void> sendMessageWithTimeout(Message message,
      {Duration timeout = const Duration(seconds: 10)}) async {
    // 保存到数据库
    await _database.into(_database.messages).insert(message);

    await _notifyMessageAdded(message);

    // 发送到服务器
    final protoMsg = MessageAdapter.toProto(message);
    
    // 添加详细的发送前调试信息
    _logger.i('💌 准备发送消息到服务器', extra: {
      'messageId': message.messageId,
      'conversationId': message.conversationId,
      'type': message.messageType,
      'protoSize': protoMsg.writeToBuffer().length,
      'hasContent': message.content != null && message.content!.isNotEmpty,
      'contentLength': message.content?.length ?? 0,
      'contentPreview': message.content != null && message.content!.length <= 200 
          ? message.content 
          : '${message.content?.substring(0, 200)}...',
      'senderId': message.senderId,
      'senderName': message.senderName,
      'hasTextMessage': protoMsg.hasTextMessage(),
      'hasMediaMessage': protoMsg.hasMediaMessage(),
    });
    
    final sendSuccess =
        await _communicationService.emitProto('message:send', protoMsg);

    _logger.i('💌 消息发送请求已发出', extra: {
      'messageId': message.messageId, // 💢💢💢 使用messageId
      'sendSuccess': sendSuccess,
      'conversationId': message.conversationId,
      'type': message.messageType,
    });

    // 如果立即发送失败（如网络断开），直接标记为失败
    if (!sendSuccess) {
      _logger.w('💌 消息发送立即失败，网络连接问题', extra: {
        'messageId': message.messageId, // 💢💢💢 使用messageId
      });
      await markMessageAsFailed(
          message.messageId, '网络连接失败'); // 💢💢💢 传递messageId
      return;
    }

    // 超时处理 - 延长超时时间到10秒，给网络更多时间
    Timer(timeout, () async {
      final currentMessage =
          await getMessageById(message.messageId); // 💢💢💢 使用messageId查找
      if (currentMessage?.messageStatus == 'SENDING') {
        _logger.w('💌 消息发送超时', extra: {
          'messageId': message.messageId, // 💢💢💢 使用messageId
          'timeoutSeconds': timeout.inSeconds,
        });
        await markMessageAsFailed(message.messageId,
            '发送超时(${timeout.inSeconds}秒)'); // 💢💢💢 传递messageId
      }
    });
  }

  /// 重新发送失败的消息
  @override
  Future<String> resendMessage(String messageId) async {
    final message = await getMessageById(messageId);
    if (message == null) throw Exception('找不到消息');

    await updateMessageStatus(messageId, MessageStatus.SENDING);
    await sendMessageWithTimeout(message);
    return messageId;
  }

  /// 标记消息为失败状态
  @override
  Future<void> markMessageAsFailed(String messageId, String errorReason) async {
    await updateMessageStatus(messageId, MessageStatus.FAILED);
  }

  /// 根据消息ID获取消息
  @override
  Future<Message?> getMessageById(String messageId) async {
    // 💢💢💢 直接按messageId查找
    return await (_database.select(_database.messages)
        ..where((m) => m.messageId.equals(messageId))).getSingleOrNull();
  }

  /// 更新消息状态
  @override
  Future<void> updateMessageStatus(String messageId, MessageStatus status) async {
    // Convert MessageStatus enum to string for internal use
    final statusString = status.name;
    final message = await getMessageById(messageId);
    if (message == null) return;

    // 检查是否可以更新状态：已删除或撤回的消息状态不能被其他状态覆盖
    bool shouldUpdateStatus = true;
    if (message.messageStatus == 'DELETED' || message.messageStatus == 'REVOKED') {
      if (statusString == 'DELETED' || statusString == 'REVOKED') {
        // 允许删除/撤回状态之间的转换
        shouldUpdateStatus = true;
      } else {
        // 不允许从删除/撤回状态变为其他状态
        shouldUpdateStatus = false;
        _logger.w('消息已删除或撤回，跳过状态更新', extra: {
          'messageId': messageId,
          'currentStatus': message.messageStatus,
          'attemptedStatus': statusString,
        });
      }
    }

    if (shouldUpdateStatus) {
      final updatedMessage = message.copyWith(
        messageStatus: statusString,
        updatedAt: drift.Value(TimezoneUtils.nowUtc()),
      );
      await _database.update(_database.messages).replace(updatedMessage);
      await _notifyMessagesEventd(updatedMessage);
    }
  }

  /// 获取消息发送状态流
  @override
  Stream<MessageSendEvent> getMessageSendStatusStream() {
    return _messageSendStatusController.stream;
  }

  /// 创建消息对象
  Future<Message> _createMessage(String conversationId, String text, String type, {Map<String, dynamic>? content}) async {
    // 使用UUID生成唯一的消息ID
    final messageId = _uuid.v4();
    final now = TimezoneUtils.nowUtc();
    
    // 🔧 修复：将内容转换为MessageAdapter期望的JSON格式
    String? contentJson;
    if (content != null) {
      // 媒体消息等，直接使用现有内容
      if (type == 'IMAGE' || type == 'VOICE' || type == 'VIDEO' || type == 'FILE') {
        // 直接使用传入的content，它已经是正确的格式
        contentJson = jsonEncode(content);
      } else {
        contentJson = jsonEncode(content);
      }
    } else if (text.isNotEmpty) {
      // 🔧 修复：文本消息使用正确的格式
      contentJson = jsonEncode({
        'text_message': {
          'text': text,
          'mentions': <String>[],
          'hashtags': <String>[],
          'links': <Map<String, dynamic>>[],
        }
      });
    }

    final message = Message(
      messageId: messageId,
      conversationId: conversationId,
      senderId: _currentUser.userId,
      senderName: _currentUser.name,
      senderAvatar: _currentUser.avatar,
      senderRoleId: _currentUser.roleId, // 使用当前用户的roleId
      createdAt: now,
      updatedAt: null,
      messageIndex: 0, // 初始为0，等待服务器返回真实索引
      messageType: type,
      messageStatus: 'SENDING',
      quotedMessageId: null,
      repliedToMessageId: null,
      forwardedFromConversationId: null,
      forwardedFromMessageId: null,
      isEdited: false,
      editedAt: null,
      isPinned: false,
      reactions: null,
      tags: null,
      content: contentJson,
    );

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
  Future<void> _notifyMessagesEventd(Message message) async {
    try {
      // 💢💢💢 直接使用messageId
      _chatRepository.notifyMessageUpdate(MessageUpdatedEvent(
        conversationId: message.conversationId,
        messageId: message.messageId, // 💢💢💢 使用messageId
        updatedFields: {
          'status': message.messageStatus,
          'updatedAt': message.updatedAt?.toIso8601String(),
        },
      ));
    } catch (error) {
      // 如果通知失败，记录错误但不影响消息更新
      _logger.e('通知消息更新事件失败', error: error);
    }
  }
}
