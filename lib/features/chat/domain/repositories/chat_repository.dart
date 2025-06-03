import 'package:cc/core/database/models/message.dart';
import 'package:cc/core/proto/generated/message.pb.dart' as message_proto;
import 'package:cc/features/chat/domain/entities/chat_state_snapshot.dart';
import 'package:cc/features/chat/presentation/cubit/chat_state.dart';

/// 日期时间范围类
class DateTimeRange {
  final DateTime start;
  final DateTime end;

  const DateTimeRange({
    required this.start,
    required this.end,
  });

  Duration get duration => end.difference(start);
}

/// 滚动位置信息类
/// 包含滚动位置相关的数据和计算结果
class ScrollPositionInfo {
  final String conversationId;
  final CurrentScrollPosition currentScrollPosition;
  final double viewportHeight;
  final String? visibleMessageId;
  final int? visibleMessageIndex;
  final DateTime timestamp;

  const ScrollPositionInfo({
    required this.conversationId,
    required this.currentScrollPosition,
    required this.viewportHeight,
    this.visibleMessageId,
    this.visibleMessageIndex,
    required this.timestamp,
  });

  @override
  String toString() {
    return 'ScrollPositionInfo{conversationId: $conversationId, currentScrollPosition: $currentScrollPosition, visibleMessageId: $visibleMessageId, visibleMessageIndex: $visibleMessageIndex}';
  }
}

/// 会话信息类
/// 包含会话的基本元数据信息
class ConversationInfo {
  final String conversationId;
  final String? lastReadMessageId;
  final DateTime? lastReadAt;
  final int unreadCount;

  const ConversationInfo({
    required this.conversationId,
    this.lastReadMessageId,
    this.lastReadAt,
    required this.unreadCount,
  });
}

/// 聊天Repository接口
/// 定义单个聊天会话相关的数据操作接口
abstract class ChatRepository {
  /// 💢💢💢💢💢💢💢💢💢💢💢💢💢💢    消息相关    💢💢💢💢💢💢💢💢💢💢💢💢💢💢

  /// 获取会话消息
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

  /// 删除消息
  Future<void> deleteMessage(String messageId);

  /// 标记当前查看的消息为已读
  Future<void> markMessagesAsReadBySelf(String conversationId, String messageId);

  /// 标记当前查看的消息为已读
  Future<void> markMessagesAsReadByOther(String conversationId, String messageId);

  /// 按日期范围获取消息
  Future<List<Message>> getMessagesByDateRange(
    String conversationId,
    DateTime startDate,
    DateTime endDate, {
    int limit = 50,
  });

  /// 从指定日期获取会话消息
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


  /// 💢💢💢💢💢💢💢💢💢💢💢💢💢💢  输入状态相关  💢💢💢💢💢💢💢💢💢💢💢💢💢💢

  /// 发送正在输入状态
  Future<void> sendTypingStatus(String conversationId, bool isTyping);

  /// 获取输入状态流
  Stream<Map<String, dynamic>> getTypingStatusStream();

  /// 获取消息状态流
  Stream<Map<String, dynamic>> getMessageStatusStream();


  /// 💢💢💢💢💢💢💢💢💢💢💢💢💢💢    其他功能    💢💢💢💢💢💢💢💢💢💢💢💢💢💢

  /// 清空会话消息
  Future<void> clearConversationMessages(String conversationId);

  /// 用户进入会话页面
  Future<void> joinConversationRoom(String conversationId);

  /// 用户离开会话页面
  Future<void> leaveConversationRoom(String conversationId);

  /// 💢💢💢💢💢💢💢💢💢💢💢💢💢💢   网络请求   💢💢💢💢💢💢💢💢💢💢💢💢💢💢

  /// 同步会话消息
  Future<bool> syncConversationMessages(
    String conversationId,
    message_proto.MessageSyncType syncType, {
    String? anchorMessageId,
  });

  /// 日期同步消息
  Future<bool> syncRecentMessages(
    String conversationId,
    String anchorMessageId,
  );

  /// 同步未读消息
  Future<bool> syncUnreadMessages(
    String conversationId, {
    String? lastReadMessageId,
  });

  /// 计算锚点消息前后15天每天的消息数量
  Future<Map<String, int>> calculateDailyMessageCounts(
    String conversationId,
    String anchorMessageId,
  );

  /// 获取指定日期的消息数量
  Future<int> getMessageCountByDate(String conversationId, DateTime date);

  /// 检查消息是否存在于本地
  Future<bool> isMessageExistsLocally(String conversationId, String messageId);

  /// 批量同步多个会话的消息
  Future<List<bool>> batchSyncMessages(
    List<ConversationSyncTask> syncTasks, {
    int maxConcurrent = 3,
  });

  /// 重新发送失败的消息
  Future<String> resendMessage(String messageId);

  /// 创建临时消息（用于发送前显示）
  Future<Message> createTempMessage(
      String conversationId, String content, String type);

  /// 发送消息（带超时机制，不等待响应）
  Future<void> sendMessageWithTimeout(Message message,
      {Duration timeout = const Duration(seconds: 3)});

  /// 标记消息为失败状态
  Future<void> markMessageAsFailed(String messageId, String errorReason);

  /// 根据消息ID获取消息
  Future<Message?> getMessageById(String messageId);

  /// 更新消息状态
  Future<void> updateMessageStatus(String messageId, String status);

  /// 清理重复消息数据
  Future<int> cleanupDuplicateMessages(String conversationId);

  /// 验证消息数据一致性
  Future<Map<String, dynamic>> validateMessageConsistency(
      String conversationId);

  /// 💢💢💢💢💢💢💢💢💢💢💢💢💢💢  状态快照管理  💢💢💢💢💢💢💢💢💢💢💢💢💢💢

  /// 保存会话状态快照
  /// [conversationId] - 会话ID
  /// [messages] - 消息列表
  /// [lastReadMessageId] - 最后已读消息ID
  /// [unreadCount] - 未读消息数量
  /// [currentScrollPosition] - 滚动位置
  /// [visibleMessageId] - 当前可见的消息ID
  /// [hasMoreHistory] - 是否有更多历史消息
  /// [hasMoreRecent] - 是否有更多新消息
  Future<void> saveStateSnapshot({
    required String conversationId,
    required List<Message> messages,
    String? lastReadMessageId,
    required int unreadCount,
    CurrentScrollPosition? currentScrollPosition,
    String? visibleMessageId,
    bool hasMoreHistory = true,
    bool hasMoreRecent = false,
  });

  /// 获取会话状态快照
  /// [conversationId] - 会话ID
  /// 返回状态快照，如果不存在或已过期则返回null
  Future<ChatStateSnapshot?> getStateSnapshot(String conversationId);

  /// 清除指定会话的状态快照
  /// [conversationId] - 会话ID
  Future<void> clearStateSnapshot(String conversationId);

  /// 清除所有过期的状态快照
  Future<void> cleanupExpiredSnapshots();

  /// 💢💢💢💢💢💢💢💢💢💢💢💢💢💢    其他功能    💢💢💢💢��💢💢💢💢💢💢💢💢💢
}

/// 会话同步任务
class ConversationSyncTask {
  final String conversationId;
  final message_proto.MessageSyncType type;
  final String? anchorMessageId;
  final int priority;

  ConversationSyncTask({
    required this.conversationId,
    required this.type,
    this.anchorMessageId,
    this.priority = 0,
  });
}
