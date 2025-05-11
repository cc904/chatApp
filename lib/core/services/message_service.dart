import 'package:cc/core/database/database_initializer.dart';
import 'package:cc/core/database/models/message.dart';
import 'package:cc/core/database/models/conversation.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/constants/message_types.dart';
import 'package:isar/isar.dart';

/// 消息服务
/// 负责处理消息的发送、接收和存储
class MessageService {
  static final _logger = LogService.instance;
  static final _isar = DatabaseInitializer.isar;

  /// 发送消息
  static Future<Message?> sendMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String type,
    String? text,
    String? mediaUrl,
    String? localPath,
    int? duration,
    double? fileSize,
    String? fileName,
    String? thumbnailUrl,
    double? latitude,
    double? longitude,
    String? locationAddress,
    String? quotedMessageId,
  }) async {
    try {
      _logger.i('开始发送消息', extra: {
        'conversationId': conversationId,
        'senderId': senderId,
        'type': type,
      });

      // 创建消息对象
      final message = Message()
        ..conversationId = conversationId
        ..senderId = senderId
        ..senderName = senderName
        ..type = type
        ..text = text
        ..mediaUrl = mediaUrl
        ..localPath = localPath
        ..duration = duration
        ..fileSize = fileSize
        ..fileName = fileName
        ..thumbnailUrl = thumbnailUrl
        ..latitude = latitude
        ..longitude = longitude
        ..locationAddress = locationAddress
        ..quotedMessageId = quotedMessageId
        ..status = 'sending';

      // 保存消息
      await _isar.writeTxn(() async {
        message.id = await _isar.messages.put(message);
        message.messageId = message.id.toString();
        await _isar.messages.put(message);

        // 更新会话的最后一条消息
        final convId = int.tryParse(conversationId);
        if (convId != null) {
          final conversation = await _isar.conversations.get(convId);
          if (conversation != null) {
            conversation.lastMessageTime = message.createdAt;
            conversation.lastMessagePreview = _getMessagePreview(message);
            await _isar.conversations.put(conversation);
          }
        }
      });

      _logger.i('消息发送成功', extra: {'messageId': message.messageId});
      return message;
    } catch (error) {
      _logger.e('发送消息失败', error: error, stackTrace: StackTrace.current);
      return null;
    }
  }

  /// 获取消息预览文本
  static String _getMessagePreview(Message message) {
    switch (message.type) {
      case MessageType.text:
        return message.text ?? '';
      case MessageType.image:
        return '[图片]';
      case MessageType.voice:
        return '[语音]';
      case MessageType.file:
        return '[文件]';
      case MessageType.video:
        return '[视频]';
      case MessageType.location:
        return '[位置]';
      case MessageType.system:
        return '[系统消息]';
      default:
        return '[未知消息]';
    }
  }

  /// 获取会话的消息列表
  static Future<List<Message>> getMessages(String conversationId, {int limit = 20, int offset = 0}) async {
    try {
      _logger.i('获取会话消息', extra: {
        'conversationId': conversationId,
        'limit': limit,
        'offset': offset,
      });

      final messages = await _isar.messages.where().filter().conversationIdEqualTo(conversationId).sortByCreatedAt().offset(offset).limit(limit).findAll();

      _logger.i('获取消息成功', extra: {'count': messages.length});
      return messages;
    } catch (error) {
      _logger.e('获取消息失败', error: error, stackTrace: StackTrace.current);
      return [];
    }
  }

  /// 标记消息为已读
  static Future<void> markMessagesAsRead(String conversationId) async {
    try {
      _logger.i('标记消息为已读', extra: {'conversationId': conversationId});

      await _isar.writeTxn(() async {
        // 更新消息状态
        final messages = await _isar.messages.where().filter().conversationIdEqualTo(conversationId).isReadEqualTo(false).findAll();

        for (final message in messages) {
          message.isRead = true;
          await _isar.messages.put(message);
        }

        // 更新会话未读计数
        final convId = int.tryParse(conversationId);
        if (convId != null) {
          final conversation = await _isar.conversations.get(convId);
          if (conversation != null) {
            conversation.unreadCount = 0;
            conversation.safeUnreadCount = 0;
            await _isar.conversations.put(conversation);
          }
        }
      });

      _logger.i('消息已标记为已读');
    } catch (error) {
      _logger.e('标记消息为已读失败', error: error, stackTrace: StackTrace.current);
    }
  }

  /// 删除消息
  static Future<bool> deleteMessage(String messageId) async {
    try {
      _logger.i('删除消息', extra: {'messageId': messageId});

      final id = int.tryParse(messageId);
      if (id == null) return false;

      final success = await _isar.writeTxn(() async {
        final message = await _isar.messages.get(id);
        if (message == null) return false;

        await _isar.messages.delete(id);
        return true;
      });

      _logger.i('消息删除成功');
      return success;
    } catch (error) {
      _logger.e('删除消息失败', error: error, stackTrace: StackTrace.current);
      return false;
    }
  }
}
