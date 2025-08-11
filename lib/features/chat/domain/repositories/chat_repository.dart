import 'package:cc/core/database/drift_database.dart';
import 'package:cc/features/chat/presentation/cubit/chat_state.dart';
import 'package:cc/features/chat/domain/entities/message_update_event.dart';
import 'package:cc/features/chat/domain/entities/conversation_update_event.dart';

/// 搜索结果类
/// 包含搜索相关的所有信息
class SearchResult {
  /// 匹配的消息ID列表（按时间顺序排列）
  final List<int> matchedMessageIndexes;

  /// 搜索结果总数
  final int totalCount;

  const SearchResult({
    required this.matchedMessageIndexes,
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

  /// 请求服务器获取指定范围的消息
  /// [conversationId] - 会话ID
  /// [indexA] - 开始索引（包含）
  /// [indexB] - 结束索引（包含）
  /// [jumpIndex] - 必选,不需要传入0
  Future<bool> requestMessages(
      String conversationId, int indexA, int indexB, jumpIndex);

  /// 加载指定范围的消息
  /// [conversationId] - 会话ID
  /// [indexA] - 开始索引（包含）
  /// [indexB] - 结束索引（包含）
  /// [jumpIndex] - 跳转目标索引（用于滚动定位，0表示无跳转）
  Future<bool> loadMessages(
      String conversationId, int indexA, int indexB, int jumpIndex);

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
  /// [targetMessageIndex] - 目标消息索引
  /// [contextSize] - 上下文大小（前后各取多少条消息）
  /// 返回目标消息附近的消息列表
  Future<List<Message>> getMessagesAroundSearchResult({
    required String conversationId,
    required int targetMessageIndex,
    int contextSize = 25,
  });

  /// 编辑消息
  /// [messageId] - 消息ID
  /// [conversationId] - 会话ID
  /// [newText] - 新的文本内容
  Future<bool> editMessage(
      String messageId, String conversationId, String newText);

  /// 撤回消息
  /// [messageId] - 消息ID
  /// [conversationId] - 会话ID
  Future<bool> revokeMessage(String messageId, String conversationId);

  /// 删除消息
  /// [messageId] - 消息ID
  /// [conversationId] - 会话ID
  Future<bool> deleteMessage(String messageId, String conversationId);

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

  /// 💢💢💢💢💢💢💢💢💢💢💢💢💢💢   新Stream架构   💢💢💢💢💢💢💢💢💢💢💢💢💢💢

  /// 💢💢💢 核心Stream：消息更新事件流
  /// 替代原来的数据库监听，通过精确的事件通知Cubit进行增量更新
  /// [conversationId] - 会话ID
  /// 返回该会话的消息更新事件流
  Stream<MessagesEvent> getMessageUpdateStream(String conversationId);

  /// 💢💢💢 会话级加载状态流
  /// 替代原来的手动状态管理，通过事件通知UI更新加载状态
  /// [conversationId] - 会话ID
  /// 返回该会话的加载状态更新流
  Stream<LoadingStateUpdate> getConversationLoadingStateStream(
      String conversationId);

  /// 💢💢💢 会话更新事件流
  /// 用于监听特定会话的状态变化（如会话移除等）
  /// [conversationId] - 会话ID
  /// 返回该会话的更新事件流
  Stream<ConversationUpdateEvent> getConversationUpdateStream(
      String conversationId);

  /// 💢💢💢💢💢💢💢💢💢💢💢💢💢💢  会话成员管理  💢💢💢💢💢💢💢💢💢💢💢💢💢💢

  /// 更新成员角色
  /// [conversationId] - 会话ID
  /// [userId] - 用户ID
  /// [action] - 操作类型 (promote/demote)
  Future<bool> updateMemberRole(
      String conversationId, String userId, String action);

  /// 移除会话成员
  /// [conversationId] - 会话ID
  /// [userId] - 用户ID
  Future<bool> removeMemberFromConversation(
      String conversationId, String userId);

  /// 屏蔽会话成员
  /// [conversationId] - 会话ID
  /// [userId] - 用户ID
  Future<bool> blockMemberInConversation(String conversationId, String userId);

  /// 添加会话成员
  /// [conversationId] - 会话ID
  /// [userId] - 目标用户ID
  Future<bool> addMemberToConversation(String conversationId, String userId);

  /// 💢💢💢💢💢💢💢💢💢💢💢💢💢💢    其他功能    💢💢💢💢💢💢💢💢💢💢💢💢💢💢

  /// 清空会话消息
  Future<void> clearConversationMessages(String conversationId);

  /// 用户进入会话页面
  Future<void> joinConversationRoom(String conversationId);

  /// 用户离开会话页面
  Future<void> leaveConversationRoom(String conversationId);

  /// 💢💢💢 新增：退出会话（真正退出，从数据库移除）
  /// [conversationId] - 会话ID
  /// [reason] - 退出原因（可选）
  Future<bool> exitConversation(String conversationId, {String? reason});

  /// 💢💢💢 新增：外部通知消息更新事件
  /// 允许其他Repository组件（如ChatRepositorySend）通知消息变化
  /// [event] - 消息更新事件
  void notifyMessageUpdate(MessagesEvent event);

  /// 💢💢💢 新增：清理指定会话的控制器
  /// 当会话页面关闭或不再需要时调用，避免内存泄漏和无效控制器警告
  /// [conversationId] - 要清理的会话ID
  void cleanupConversationControllers(String conversationId);
}
