import 'package:cc/core/database/models/message.dart';
import 'package:cc/features/chat/domain/entities/message_cursor.dart';
import 'package:cc/core/proto/generated/message.pb.dart' as message_proto;
import 'package:cc/features/chat/presentation/cubit/chat_state.dart';

/// 搜索结果类
/// 包含搜索相关的所有信息
class SearchResult {
  /// 匹配的消息ID列表（按时间顺序排列）
  final List<String> matchedMessageIds;

  /// 搜索结果总数
  final int totalCount;

  const SearchResult({
    required this.matchedMessageIds,
    required this.totalCount,
  });

  /// 是否有搜索结果
  bool get hasResults => totalCount > 0;

  /// 是否为空结果
  bool get isEmpty => totalCount == 0;
}

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
  Future<void> getConversationMessages(String conversationId,
      {int limit = 20, DateTime? before});

  /// 搜索消息
  Future<List<Message>> searchMessages(String keyword,
      {String? conversationId});

  /// 💢💢💢 新增：在数据库中搜索消息并返回结果信息
  /// 直接从数据库搜索，返回匹配消息的ID列表和完整的消息范围
  /// [query] - 搜索关键词
  /// [conversationId] - 会话ID
  /// [dateFilter] - 可选的日期过滤器
  /// 返回搜索结果信息
  Future<SearchResult> searchMessagesInDatabase({
    required String query,
    required String conversationId,
    DateTime? dateFilter,
  });

  /// 💢💢💢 新增：根据搜索结果获取完整的消息范围
  /// 从最老的搜索结果到最新的搜索结果之间的所有消息
  /// [conversationId] - 会话ID
  /// [searchResultIds] - 搜索结果消息ID列表
  /// 返回完整的消息列表
  Future<List<Message>> getMessagesRangeForSearch({
    required String conversationId,
    required List<String> searchResultIds,
  });

  /// 💢💢💢 新增：加载指定搜索结果附近的消息
  /// 替换式加载，只获取目标搜索结果前后指定数量的消息
  /// [conversationId] - 会话ID
  /// [targetMessageId] - 目标搜索结果消息ID
  /// [contextSize] - 上下文大小（前后各取多少条消息）
  /// 返回目标消息附近的消息列表和时间范围
  Future<({List<Message> messages, DateTimeRange timeRange})>
      getMessagesAroundSearchResult({
    required String conversationId,
    required String targetMessageId,
    int contextSize = 25,
  });

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
  Future<void> markMessagesAsReadBySelf(
      String conversationId, String messageId);

  /// 标记当前查看的消息为已读
  Future<void> markMessagesAsReadByOther(
      String conversationId, String messageId);

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

  /// 💢💢💢💢💢💢💢💢💢💢💢💢💢💢   网络请求   💢💢💢💢💢💢💢��💢💢💢💢💢💢

  /// 💢💢💢💢💢💢💢💢💢💢💢💢💢💢 新的游标同步方法 💢💢💢💢💢💢💢💢💢💢💢💢💢💢

  /// 向前游标同步（获取新消息）
  /// [conversationId] - 会话ID
  /// [cursor] - 起始游标位置
  /// [limit] - 获取消息数量限制
  /// 返回同步结果
  Future<CursorSyncResult> syncMessagesForward(
    String conversationId, {
    MessageCursor? cursor,
    int limit = 20,
  });

  /// 向后游标同步（获取历史消息）
  /// [conversationId] - 会话ID
  /// [cursor] - 起始游标位置
  /// [limit] - 获取消息数量限制
  /// 返回同步结果
  Future<CursorSyncResult> syncMessagesBackward(
    String conversationId, {
    MessageCursor? cursor,
    int limit = 20,
  });

  /// 双向游标同步（获取上下文消息）
  /// [conversationId] - 会话ID
  /// [cursor] - 中心游标位置
  /// [beforeCount] - 游标前消息数量
  /// [afterCount] - 游标后消息数量
  /// [includeCursor] - 是否包含游标消息本身
  /// 返回同步结果
  Future<CursorSyncResult> syncMessagesAround(
    String conversationId, {
    required MessageCursor cursor,
    int beforeCount = 10,
    int afterCount = 10,
    bool includeCursor = true,
  });

  /// 初始加载消息
  /// [conversationId] - 会话ID
  /// [limit] - 获取消息数量限制
  /// 返回同步结果
  Future<CursorSyncResult> syncMessagesInitial(
    String conversationId, {
    int limit = 20,
  });

  /// 💢💢💢💢💢💢💢💢💢💢💢💢💢💢 游标管理方法 💢💢💢💢💢💢💢💢💢💢💢💢💢💢

  /// 获取本地游标
  /// [conversationId] - 会话ID
  /// 返回本地游标信息
  Future<MessageCursor> getLocalCursor(String conversationId);

  /// 更新本地游标
  /// [conversationId] - 会话ID
  /// [cursor] - 新的游标位置
  Future<void> updateLocalCursor(String conversationId, MessageCursor cursor);

  /// 获取同步游标
  /// [conversationId] - 会话ID
  /// 返回同步游标信息
  Future<MessageCursor> getSyncCursor(String conversationId);

  /// 更新同步游标
  /// [conversationId] - 会话ID
  /// [cursor] - 新的游标位置
  Future<void> updateSyncCursor(String conversationId, MessageCursor cursor);

  /// 💢💢💢💢💢💢💢💢💢💢💢💢💢💢 辅助方法 💢💢💢💢💢💢💢💢💢💢💢💢💢💢

  /// 检查消息是否存在于本地数据库
  Future<bool> isMessageExistsLocally(String conversationId, String messageId);

  /// 检查会话是否有本地消息
  /// [conversationId] - 会话ID
  /// 返回是否有本地消息
  Future<bool> hasLocalMessages(String conversationId);

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

  /// 💢💢💢💢💢💢💢💢💢💢💢💢💢💢 新增：无缝消息同步 💢💢💢💢💢💢💢💢💢💢💢💢💢💢

  /// 执行无缝消息同步
  /// 解决进入房间和历史同步之间的消息空档期问题
  /// [conversationId] - 会话ID
  /// [joinTimestamp] - 用户进入房间的时间戳
  /// [lastLocalMessageTimestamp] - 本地最新消息的时间戳
  Future<bool> performSeamlessSync(
    String conversationId,
    DateTime joinTimestamp,
    DateTime? lastLocalMessageTimestamp,
  );
}

/// 会话同步任务（更新支持游标）
class ConversationSyncTask {
  final String conversationId;
  final message_proto.MessageSyncType type;
  final String? anchorMessageId; // 保留兼容性
  final MessageCursor? cursor; // 新增游标支持
  final int priority;
  final int? limit;

  ConversationSyncTask({
    required this.conversationId,
    required this.type,
    this.anchorMessageId,
    this.cursor,
    this.priority = 0,
    this.limit,
  });

  /// 创建游标任务
  factory ConversationSyncTask.cursor({
    required String conversationId,
    required message_proto.MessageSyncType type,
    MessageCursor? cursor,
    int priority = 0,
    int? limit,
  }) {
    return ConversationSyncTask(
      conversationId: conversationId,
      type: type,
      cursor: cursor,
      priority: priority,
      limit: limit,
    );
  }
}
