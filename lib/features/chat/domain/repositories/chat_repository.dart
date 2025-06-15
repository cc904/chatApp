import 'package:cc/core/database/models/message.dart';
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

/// 聊天仓库接口
/// 定义了单个聊天会话相关的数据操作方法
abstract class ChatRepository {
  /// 💢💢💢💢💢💢💢💢💢💢💢💢💢💢    消息相关    💢💢💢💢💢💢💢💢💢💢💢💢💢💢

  /// 请求服务器获取更多消息
  /// [conversationId] - 会话ID
  /// [messageIndex] - 起始消息索引
  /// [limit] - 获取消息数量限制
  /// [isBefore] - 是否获取指定索引之前的消息
  Future<void> requestMoreMessages(String conversationId,
      {int? messageIndex, int limit = 50, bool? isBefore = false});

  /// 基于锚点消息Index获取消息 前50条 后50条
  /// [conversationId] - 会话ID
  /// [anchorMessageIndex] - 锚点消息Index
  /// 返回消息列表
  Future<List<Message>> getMessagesByAnchorMessageIndex(String conversationId,
      int? anchorMessageIndex, int firstMessageIndex, int lastMessageIndex);

  /// 加载本地最新的消息 前50条 后50条
  /// [conversationId] - 会话ID
  /// [anchorMessageIndex] - 锚点消息Index
  /// [firstMessageIndex] - 会话中的第一条消息的索引
  /// [lastMessageIndex] - 会话中的最后一条消息的索引
  /// [limit] - 获取消息数量限制
  /// [isBefore] - 是否获取指定索引之前的消息
  Future<List<Message>> loadMoreMessages(String conversationId,
      int anchorMessageIndex, int firstMessageIndex, int lastMessageIndex,
      {int limit = 50, bool? isBefore = false});

  /// 获取会话中的消息数量
  Future<int> getConversationMessageCount(String conversationId);

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

  /// 删除消息
  Future<void> deleteMessage(String messageId);

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
    int limit = 50,
  });

  /// 💢💢💢💢💢💢💢💢💢💢💢💢💢💢  输入状态相关  💢💢💢💢💢💢💢💢💢💢💢💢💢💢

  /// 发送正在输入状态
  Future<void> sendTypingStatus(String conversationId, bool isTyping);

  /// 获取输入状态流
  Stream<Map<String, dynamic>> getTypingStatusStream();

  /// 💢💢💢💢💢💢💢💢💢💢💢💢💢💢    其他功能    💢💢💢💢💢💢💢💢💢💢💢💢💢💢

  /// 清空会话消息
  Future<void> clearConversationMessages(String conversationId);

  /// 用户进入会话页面
  Future<void> joinConversationRoom(String conversationId);

  /// 用户离开会话页面
  Future<void> leaveConversationRoom(String conversationId);

  /// 💢💢💢 新增：监听指定会话的消息变化
  /// 返回变化触发信号，当数据库中的消息发生变化时触发通知（不传输具体数据）
  /// [conversationId] - 会话ID
  /// 返回该会话消息的变化触发流
  Stream<void> watchMessages(String conversationId);

  /// 💢💢💢 新增：监听指定会话的消息数量变化
  /// 用于高效监听消息数量变化，避免传输大量消息数据
  /// [conversationId] - 会话ID
  /// 返回消息数量变化流
  Stream<int> watchMessageCount(String conversationId);

  /// 💢💢💢 新增：获取加载状态流
  /// 返回消息加载状态变化的流
  Stream<Map<String, dynamic>> getLoadingStatusStream();
}
