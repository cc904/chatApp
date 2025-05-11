import 'package:cc/core/database/models/message.dart';
import 'package:cc/core/database/models/conversation.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:isar/isar.dart';

/// 数据库管理器
/// 提供统一的接口用于操作数据库中的消息、会话等数据
class DatabaseManager {
  final LogService _logger = LogService.instance;
  late final Isar _isar;

  // 单例模式
  static final DatabaseManager _instance = DatabaseManager._internal();
  factory DatabaseManager() => _instance;
  DatabaseManager._internal();

  /// 初始化
  Future<void> init(Isar isar) async {
    _isar = isar;
    _logger.i('数据库管理器初始化成功');
  }

  /// 保存消息到数据库
  Future<String> saveMessage(Message message) async {
    try {
      await _isar.writeTxn(() async {
        message.id = await _isar.messages.put(message);
      });
      return message.messageId;
    } catch (error) {
      _logger.e('保存消息失败', extra: {'error': error.toString()});
      throw Exception('保存消息失败: ${error.toString()}');
    }
  }

  /// 更新会话的最后一条消息
  Future<void> updateConversationLastMessage(
    String conversationId,
    String messageId,
    DateTime messageTime,
  ) async {
    try {
      final conversation = await _isar.conversations.filter().conversationIdEqualTo(conversationId).findFirst();

      if (conversation != null) {
        await _isar.writeTxn(() async {
          conversation.lastMessageId = messageId;
          conversation.lastMessageTime = messageTime;
          await _isar.conversations.put(conversation);
        });
      }
    } catch (error) {
      _logger.e('更新会话最后消息失败', extra: {'error': error.toString()});
    }
  }

  /// 根据ID获取消息
  Future<Message?> getMessageById(String messageId) async {
    return await _isar.messages.filter().messageIdEqualTo(messageId).findFirst();
  }

  /// 获取会话所有消息
  Future<List<Message>> getConversationMessages(String conversationId) async {
    return await _isar.messages.filter().conversationIdEqualTo(conversationId).sortByCreatedAt().findAll();
  }

  /// 根据ID获取会话
  Future<Conversation?> getConversationById(String conversationId) async {
    return await _isar.conversations.filter().conversationIdEqualTo(conversationId).findFirst();
  }

  /// 获取所有会话
  Future<List<Conversation>> getAllConversations() async {
    return await _isar.conversations.filter().optional(true, (q) => q.lastMessageTimeIsNotNull().sortByLastMessageTimeDesc()).findAll();
  }
}
