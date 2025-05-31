import 'package:cc/core/database/models/message.dart';
import '../entities/message_timeline.dart';

/// 单个聊天会话仓库接口
/// 定义了单个聊天会话所需的各种操作方法
abstract class ChatRepository {
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

  /// 清空会话中的所有消息但保留会话
  Future<void> clearConversationMessages(String conversationId);

  /// 监听特定会话中的消息变化
  Stream<void> watchConversationMessages(String conversationId);

  /// 根据日期范围获取消息
  Future<List<Message>> getMessagesByDateRange(
    String conversationId,
    DateTime startDate,
    DateTime endDate, {
    int limit = 50,
  });

  /// 从指定日期开始获取会话消息
  Future<List<Message>> getConversationMessagesFromDate(
    String conversationId,
    DateTime startDate, {
    int limit = 30,
  });

  /// 从服务器获取历史消息
  Future<List<Message>> fetchHistoryMessages(String conversationId,
      {DateTime? before, int limit = 20});

  /// 从服务器获取消息
  Future<List<Message>> fetchMessagesFromServer(String conversationId,
      {int limit = 20, DateTime? before});

  /// 发送正在输入状态
  Future<void> sendTypingStatus(String conversationId, bool isTyping);

  /// 获取正在输入状态流
  Stream<Map<String, dynamic>> getTypingStatusStream();

  /// 获取消息状态流（已送达、已读）
  Stream<Map<String, dynamic>> getMessageStatusStream();

  /// 更新会话的最后阅读时间
  Future<void> updateLastReadAt(String conversationId, DateTime timestamp);

  /// 更新会话的最后阅读消息ID
  Future<void> updateLastReadMessageId(String conversationId, String messageId);

  /// 用户进入会话页面，加入对应的Socket.io会话房间
  Future<void> joinConversationRoom(String conversationId);

  /// 用户离开会话页面，离开对应的Socket.io会话房间
  Future<void> leaveConversationRoom(String conversationId);

  // ==================== MessageTimeline 缓存方法 ====================

  /// 获取缓存的MessageTimeline
  ///
  /// [conversationId] 会话ID
  /// 返回缓存的MessageTimeline，如果没有缓存则返回null
  MessageTimeline? getTimeline(String conversationId);

  /// 存储MessageTimeline到缓存
  ///
  /// [conversationId] 会话ID
  /// [timeline] 要缓存的MessageTimeline
  void storeTimeline(String conversationId, MessageTimeline timeline);

  /// 移除指定会话的Timeline缓存
  ///
  /// [conversationId] 会话ID
  void removeTimeline(String conversationId);

  /// 清空所有Timeline缓存
  void clearTimelineCache();

  /// 获取缓存状态信息
  ///
  /// 返回包含缓存统计信息的Map，用于调试和监控
  Map<String, dynamic> getCacheStats();

  /// 预加载指定会话的消息到Timeline
  ///
  /// [conversationId] 会话ID
  /// [messageCount] 预加载的消息数量，默认为100
  /// 返回是否预加载成功
  Future<bool> preloadTimeline(String conversationId, {int messageCount = 100});

  /// 获取用户上次查看状态
  ///
  /// [conversationId] 会话ID
  /// 返回用户的ViewState，如果没有记录则返回null
  Future<ViewState?> getUserLastViewState(String conversationId);

  /// 保存用户查看状态
  ///
  /// [viewState] 要保存的查看状态
  Future<void> saveUserViewState(ViewState viewState);
}
