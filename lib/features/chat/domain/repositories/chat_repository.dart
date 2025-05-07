import 'package:cc/core/database/models/user.dart';
import 'package:cc/core/database/models/conversation.dart';
import 'package:cc/core/database/models/message.dart';

/// 聊天仓库接口
/// 定义了聊天功能所需的各种操作方法
abstract class ChatRepository {
  /// 获取所有联系人
  Future<List<User>> getAllContacts();

  /// 搜索联系人
  Future<List<User>> searchContacts(String keyword);

  /// 获取单个联系人信息
  Future<User?> getContactById(String userId);

  /// 添加联系人
  Future<void> addContact(User user);

  /// 获取所有会话
  Future<List<Conversation>> getAllConversations();

  /// 获取单个会话信息
  Future<Conversation?> getConversationById(String conversationId);

  /// 获取或创建私聊会话
  Future<Conversation> getOrCreatePrivateConversation(String contactUserId);

  /// 创建群聊会话
  Future<Conversation> createGroupConversation(String name, List<String> memberIds, {String? avatar});

  /// 获取会话消息(支持分页)
  Future<List<Message>> getConversationMessages(String conversationId, {int limit = 20, DateTime? before});

  /// 搜索消息
  Future<List<Message>> searchMessages(String keyword, {String? conversationId});

  /// 发送文本消息
  Future<Message> sendTextMessage(String conversationId, String text);

  /// 发送图片消息
  Future<Message> sendImageMessage(String conversationId, String localPath, {String? mediaUrl});

  /// 发送语音消息
  Future<Message> sendVoiceMessage(String conversationId, String localPath, int duration, {String? mediaUrl});

  /// 发送文件消息
  Future<Message> sendFileMessage(String conversationId, String localPath, String fileName, double fileSize, {String? mediaUrl});

  /// 发送视频消息
  Future<Message> sendVideoMessage(String conversationId, String localPath, int duration, {String? thumbnailUrl, String? mediaUrl, bool isServerProcessed = false});

  /// 标记会话消息为已读
  Future<void> markConversationAsRead(String conversationId);

  /// 删除消息
  Future<void> deleteMessage(String messageId);

  /// 删除会话和会话中的所有消息
  Future<void> deleteConversation(String conversationId);

  /// 清空会话中的所有消息但保留会话
  Future<void> clearConversationMessages(String conversationId);

  /// 监听会话列表变化
  Stream<void> watchConversations();

  /// 监听特定会话中的消息变化
  Stream<void> watchConversationMessages(String conversationId);

  /// 监听联系人列表变化
  Stream<void> watchContacts();

  /// 根据日期范围获取消息
  Future<List<Message>> getMessagesByDateRange(
    String conversationId,
    DateTime startDate,
    DateTime endDate, {
    int limit = 50,
  });

  /// 从指定日期开始获取会话消息（包括该日期当天的消息）
  Future<List<Message>> getConversationMessagesFromDate(
    String conversationId,
    DateTime startDate, {
    int limit = 30,
  });

  /// 初始化实时通信
  /// [userId] - 用户ID
  /// [token] - 认证令牌
  /// [serverUrl] - 服务器URL
  /// [simulationMode] - 是否使用模拟模式
  Future<bool> initRealTimeConnection(
    String userId,
    String token,
    String serverUrl,
    bool simulationMode,
  );

  /// 关闭实时通信连接
  Future<void> closeRealTimeConnection();

  /// 重新连接实时通信
  Future<bool> reconnectRealTime();

  /// 同步联系人列表
  Future<bool> syncContacts();

  /// 创建或获取与用户的对话
  Future<String?> createOrGetConversation(String userId);

  /// 发送正在输入状态
  Future<void> sendTypingStatus(String conversationId, bool isTyping);

  /// 获取正在输入状态流
  Stream<Map<String, dynamic>> getTypingStatusStream();

  /// 获取在线状态流
  Stream<Map<String, dynamic>> getOnlineStatusStream();

  /// 获取消息状态流（已送达、已读）
  Stream<Map<String, dynamic>> getMessageStatusStream();

  /// 获取消息同步状态流
  Stream<SyncStatus> getSyncStatusStream();
}

/// 同步状态枚举
enum SyncStatus {
  idle, // 空闲
  syncing, // 同步中
  completed, // 完成
  error, // 错误
}
