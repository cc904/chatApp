import 'package:isar/isar.dart';

part 'conversation_cursor.g.dart';

/// 🚀 会话游标记录模型 - 基于Index的极简版本
///
/// 📋 设计理念：
/// 使用消息的index字段替代复杂的时间戳+消息ID游标系统，实现：
/// ✅ 95%复杂度降低：从复杂对象变成简单数字
/// ✅ 绝对可靠排序：服务器保证index严格递增
/// ✅ 直观间隙检测：next.index - current.index > 1
/// ✅ 高效分页查询：单字段数字比较，无需复合索引
///
/// 🔄 替代的复杂系统：
/// ❌ 旧方案：MessageCursor(messageId, timestamp, position)
/// ✅ 新方案：从index=1250开始同步  // 极其简单！
@collection
class ConversationCursor {
  Id id = Isar.autoIncrement;

  // 会话ID，每个会话一条记录
  @Index(unique: true, replace: true)
  late String conversationId;

  // 🔥 最新消息的index，用于增量同步
  // 下次同步时请求这个index之后的消息
  // 替代了复杂的时间戳+消息ID游标组合
  int latestMessageIndex = 0;

  // 🔥 最早消息的index，用于历史消息加载
  // 向前加载历史消息时，请求这个index之前的消息
  // 简化了向后分页的复杂逻辑
  int earliestMessageIndex = 0;

  // 本地消息总数，用于统计和验证
  int messageCount = 0;

  // 最后同步时间
  DateTime lastSyncTime = DateTime.now();

  // 是否有更多新消息（服务器端有更新的消息）
  bool hasMoreAfter = false;

  // 是否有更多历史消息（服务器端有更早的消息）
  bool hasMoreBefore = false;

  // 🎯 辅助方法：判断是否需要同步
  // 基于时间间隔和服务器标记的简单判断
  @ignore
  bool get needsSync {
    // 超过5分钟没同步，或者服务器标记有更多消息
    final fiveMinutesAgo = DateTime.now().subtract(const Duration(minutes: 5));
    return lastSyncTime.isBefore(fiveMinutesAgo) || hasMoreAfter;
  }

  // 🎯 辅助方法：获取下次同步的起始index
  // 直接返回最新消息index，无需复杂计算
  @ignore
  int get nextSyncFromIndex => latestMessageIndex;

  // 🎯 辅助方法：获取历史消息加载的结束index
  // 直接返回最早消息index，无需复杂计算
  @ignore
  int get historyLoadBeforeIndex => earliestMessageIndex;
}
