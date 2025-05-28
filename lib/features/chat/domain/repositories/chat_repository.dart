import 'package:cc/core/database/models/user.dart';
import 'package:cc/core/database/models/conversation.dart';
import 'package:cc/core/database/models/message.dart';
import 'package:cc/features/chat/domain/entities/conversation_update_event.dart';

/// 聊天仓库接口
/// 定义了聊天功能所需的各种操作方法
abstract class ChatRepository {
  /// 注册事件处理器
  /// 设置与通信服务的事件监听，用于接收和处理服务器发送的Proto消息
  Future<void> registerEventHandlers();

  // /// 注册特定会话的事件处理器
  // /// 当用户进入会话页面时调用，用于监听与该会话相关的事件
  // /// [conversationId] - 会话ID
  // void registerConversationEventHandlers(String conversationId);

  // /// 移除特定会话的事件处理器
  // /// 当用户离开会话页面时调用，用于移除与该会话相关的事件监听
  // /// [conversationId] - 会话ID
  // void unregisterConversationEventHandlers(String conversationId);

  /// 获取单个联系人信息
  /// 注：此方法仅用于支持聊天功能,不应用于联系人管理
  Future<User?> getContactById(String userId);

  /// 获取所有会话
  /// 从本地数据库获取所有会话
  /// 返回会话列表
  Future<List<Conversation>> getAllConversations();

  /// 获取单个会话信息
  Future<Conversation?> getConversationById(String conversationId);

  /// 获取或创建私聊会话
  Future<Conversation> getOrCreatePrivateConversation(String contactUserId);

  /// 创建群聊会话
  Future<Conversation> createGroupConversation(
      String name, List<String> memberIds,
      {String? avatar});

  /// 获取会话消息(支持分页)
  Future<List<Message>> getConversationMessages(String conversationId,
      {int limit = 20, DateTime? before});

  /// 搜索消息
  Future<List<Message>> searchMessages(String keyword,
      {String? conversationId});

  /// 发送文本消息
  Future<Message> sendTextMessage(String conversationId, String text);

  /// 发送图片消息
  Future<Message> sendImageMessage(String conversationId, String localPath,
      {String? mediaUrl});

  /// 发送语音消息
  Future<Message> sendVoiceMessage(
      String conversationId, String localPath, int duration,
      {String? mediaUrl});

  /// 发送文件消息
  Future<Message> sendFileMessage(
      String conversationId, String localPath, String fileName, double fileSize,
      {String? mediaUrl});

  /// 发送视频消息
  Future<Message> sendVideoMessage(
      String conversationId, String localPath, int duration,
      {String? thumbnailUrl, String? mediaUrl, bool isServerProcessed = false});

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
  
  /// 监听会话更新事件
  Stream<ConversationUpdateEvent> get conversationUpdateStream;

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
  
  /// 从服务器获取历史消息
  /// 当本地数据库没有消息或需要加载更多历史消息时使用
  /// [参数]
  /// [conversationId] - 会话 ID
  /// [before] - 可选，获取此时间之前的消息
  /// [limit] - 可选，每次获取的消息数量限制，默认 20 条
  Future<List<Message>> fetchHistoryMessages(String conversationId, {DateTime? before, int limit = 20});
  Future<List<Message>> getConversationMessagesFromDate(
    String conversationId,
    DateTime startDate, {
    int limit = 30,
  });

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
  Stream<ConversationSyncStatus> getSyncConversationStatusStream();

  /// 同步会话列表
  /// 从服务器同步最新的会话数据
  /// 该方法只发送同步请求，不返回会话列表
  /// 会话数据将通过事件通知并由状态管理系统更新UI
  Future<void> syncConversations();

  /// 从服务器获取消息
  /// 获取指定会话的消息列表,支持分页
  /// [conversationId] - 会话ID
  /// [limit] - 获取消息的最大数量
  /// [before] - 可选的时间点,获取此时间之前的消息
  /// 返回消息列表
  Future<List<Message>> fetchMessagesFromServer(String conversationId,
      {int limit = 20, DateTime? before});

  /// 更新会话的静音状态
  Future<void> updateConversationMuteStatus(
      String conversationId, bool isMuted);

  /// 更新会话的置顶状态
  Future<void> updateConversationPinStatus(
      String conversationId, bool isPinned);

  /// 更新会话的最后阅读时间
  Future<void> updateLastReadAt(String conversationId, DateTime timestamp);

  /// 更新会话的最后阅读消息ID
  Future<void> updateLastReadMessageId(String conversationId, String messageId);

  /// 用户进入会话页面，加入对应的Socket.io会话房间
  Future<void> joinConversationRoom(String conversationId);

  /// 用户离开会话页面，离开对应的Socket.io会话房间
  Future<void> leaveConversationRoom(String conversationId);
  
  /// 根据标签过滤会话
  ///
  /// 根据标签类型过滤会话列表
  /// [tabIndex] - 标签索引
  /// 返回过滤后的会话列表
  Future<List<Conversation>> filterConversationsByTab(int tabIndex);

  /// 更新会话设置
  ///
  /// 更新会话的静音或置顶状态
  /// [conversationId] - 会话ID
  /// [muted] - 是否静音
  /// [pinned] - 是否置顶
  /// 返回是否更新成功
  Future<bool> updateConversationSettings(String conversationId, {bool? muted, bool? pinned});
}

/// 同步状态枚举
enum ConversationSyncStatus {
  idle, // 空闲
  syncing, // 同步中
  completed, // 完成
  error, // 错误
}
