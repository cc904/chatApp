import 'package:cc/core/database/models/message.dart';
import 'package:cc/features/chat/presentation/widgets/message_separators.dart';

/// 消息列表处理器
/// 负责将原始消息列表转换为包含日期分隔符和未读消息分隔符的混合列表
class MessageListProcessor {
  /// 处理消息列表，插入日期分隔符和未读消息分隔符
  ///
  /// [messages] - 原始消息列表（按时间降序排列，最新的在前）
  /// [currentUserId] - 当前用户ID，用于判断消息是否为当前用户发送
  /// [firstUnreadMessageId] - 第一条未读消息ID，用于插入未读消息分隔符
  ///
  /// 返回处理后的混合列表，包含消息和分隔符
  static List<MessageListItem> processMessages({
    required List<Message> messages,
    required String currentUserId,
    String? firstUnreadMessageId,
  }) {
    if (messages.isEmpty) {
      return [];
    }

    final List<MessageListItem> result = [];
    bool unreadSeparatorAdded = false;

    // 遍历消息列表（注意：消息列表是按时间降序排列的，最新的在前）
    for (int i = 0; i < messages.length; i++) {
      final message = messages[i];
      final isCurrentUser = message.senderId == currentUserId;

      // 检查是否需要插入未读消息分隔符
      if (!unreadSeparatorAdded &&
          firstUnreadMessageId != null &&
          message.messageId == firstUnreadMessageId) {
        result.add(const MessageListItemUnreadSeparator());
        unreadSeparatorAdded = true;
      }

      // 添加消息本身
      result.add(MessageListItemData(
        message: message,
        isCurrentUser: isCurrentUser,
      ));

      // 检查是否需要在消息之后插入日期分隔符
      // 对于倒置列表，我们需要在每个日期组的最后一条消息后插入日期分隔符
      final currentMessageDate = _getDateOnly(message.createdAt);

      // 查看下一条消息的日期
      if (i + 1 < messages.length) {
        final nextMessage = messages[i + 1];
        final nextMessageDate = _getDateOnly(nextMessage.createdAt);

        // 如果下一条消息的日期不同，则在当前消息后插入日期分隔符
        if (!_isSameDate(currentMessageDate, nextMessageDate)) {
          result.add(MessageListItemDateSeparator(date: currentMessageDate));
        }
      } else {
        // 这是最后一条消息（最旧的消息），总是添加日期分隔符
        result.add(MessageListItemDateSeparator(date: currentMessageDate));
      }
    }

    return result;
  }

  /// 获取日期的年月日部分，忽略时分秒
  static DateTime _getDateOnly(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  /// 判断两个日期是否为同一天
  static bool _isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// 根据消息ID查找消息在列表中的索引
  ///
  /// [messages] - 消息列表
  /// [messageId] - 要查找的消息ID
  ///
  /// 返回消息在列表中的索引，如果未找到则返回-1
  static int findMessageIndex(List<Message> messages, String messageId) {
    return messages.indexWhere((message) => message.messageId == messageId);
  }

  /// 计算未读消息数量
  ///
  /// [messages] - 消息列表
  /// [currentUserId] - 当前用户ID
  /// [lastReadMessageId] - 最后已读消息ID
  ///
  /// 返回未读消息数量
  static int calculateUnreadCount({
    required List<Message> messages,
    required String currentUserId,
    String? lastReadMessageId,
  }) {
    if (lastReadMessageId == null || messages.isEmpty) {
      // 如果没有已读消息ID，则统计所有非当前用户发送的消息
      return messages.where((msg) => msg.senderId != currentUserId).length;
    }

    // 找到最后已读消息的索引
    final lastReadIndex = findMessageIndex(messages, lastReadMessageId);
    if (lastReadIndex == -1) {
      // 如果找不到最后已读消息，则统计所有非当前用户发送的消息
      return messages.where((msg) => msg.senderId != currentUserId).length;
    }

    // 统计最后已读消息之后的未读消息
    int unreadCount = 0;
    for (int i = 0; i < lastReadIndex; i++) {
      final message = messages[i];
      if (message.senderId != currentUserId) {
        unreadCount++;
      }
    }

    return unreadCount;
  }

  /// 查找第一条未读消息ID
  ///
  /// [messages] - 消息列表（按时间降序排列）
  /// [currentUserId] - 当前用户ID
  /// [lastReadMessageId] - 最后已读消息ID
  ///
  /// 返回第一条未读消息的ID，如果没有未读消息则返回null
  static String? findFirstUnreadMessageId({
    required List<Message> messages,
    required String currentUserId,
    String? lastReadMessageId,
  }) {
    if (lastReadMessageId == null || messages.isEmpty) {
      // 如果没有已读消息ID，则第一条非当前用户发送的消息就是第一条未读消息
      final firstUnreadMessage = messages.lastWhere(
        (msg) => msg.senderId != currentUserId,
        orElse: () => messages.last,
      );
      return firstUnreadMessage.messageId;
    }

    // 找到最后已读消息的索引
    final lastReadIndex = findMessageIndex(messages, lastReadMessageId);
    if (lastReadIndex == -1) {
      return null;
    }

    // 从最后已读消息之后开始查找第一条未读消息
    // 由于列表是降序排列的，我们需要从后往前找
    for (int i = lastReadIndex - 1; i >= 0; i--) {
      final message = messages[i];
      if (message.senderId != currentUserId) {
        return message.messageId;
      }
    }

    return null;
  }
}
