import 'package:cc/core/database/drift_database.dart';
import 'package:cc/features/chat/presentation/widgets/message_separators.dart';

/// 消息列表处理器
/// 负责将原始消息列表转换为包含日期分隔符的混合列表
/// 并处理消息分组显示逻辑
class MessageListProcessor {
  /// 处理消息列表，插入日期分隔符并设置分组显示属性
  ///
  /// [messages] - 原始消息列表（按时间降序排列，最新的在前）
  /// [currentUserId] - 当前用户ID，用于判断消息是否为当前用户发送
  /// [isPrivateChat] - 是否为私聊
  ///
  /// 返回处理后的混合列表，包含消息和分隔符
  static List<MessageListItem> processMessages({
    required List<Message> messages,
    required String currentUserId,
    bool isNotGroupChat = false,
  }) {
    if (messages.isEmpty) {
      return [];
    }

    final List<MessageListItem> result = [];

    // 遍历消息列表（注意：消息列表是按时间降序排列的，最新的在前）
    for (int i = 0; i < messages.length; i++) {
      final message = messages[i];
      final isCurrentUser = message.senderId == currentUserId;

      // 判断是否显示头像和小尾巴
      final shouldShowAvatar =
          _shouldShowAvatar(messages, i, currentUserId, isNotGroupChat);
      final shouldShowTail = _shouldShowTail(messages, i, currentUserId);

      // 添加消息本身
      result.add(MessageListItemData(
        message: message,
        isCurrentUser: isCurrentUser,
        showAvatar: shouldShowAvatar,
        showTail: shouldShowTail,
        isNotGroupChat: isNotGroupChat,
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
  /// 注意：输入的dateTime可能是UTC时间，需要转换为本地时区
  static DateTime _getDateOnly(DateTime dateTime) {
    // 统一按 UTC 日期分组，避免本地/UTC转换导致分隔符错位从而引发索引映射抖动
    final utc = dateTime.toUtc();
    return DateTime.utc(utc.year, utc.month, utc.day);
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

  /// 判断是否应该显示头像
  /// 在反向列表中，只有连续消息的第一条（最新的）才显示头像
  static bool _shouldShowAvatar(List<Message> messages, int currentIndex,
      String currentUserId, bool isPrivateChat) {
    if (isPrivateChat) {
      return false; // 私聊不显示头像
    }

    final currentMessage = messages[currentIndex];
    final isCurrentUser = currentMessage.senderId == currentUserId;

    if (isCurrentUser) {
      return false; // 自己的消息不显示头像
    }

    // 在反向列表中，检查前一条更新的消息（currentIndex - 1）
    if (currentIndex - 1 >= 0) {
      final previousMessage = messages[currentIndex - 1];
      final previousIsCurrentUser = previousMessage.senderId == currentUserId;

      // 如果前一条消息是不同的发送者，或者是自己发送的，则显示头像
      if (previousIsCurrentUser ||
          previousMessage.senderId != currentMessage.senderId) {
        return true;
      }

      // 如果时间间隔超过5分钟，也显示头像
      final timeDiff =
          previousMessage.createdAt.difference(currentMessage.createdAt);
      if (timeDiff.inMinutes >= 5) {
        return true;
      }

      return false;
    }

    // 这是第一条消息（最新的），显示头像
    return true;
  }

  /// 判断是否应该显示小尾巴
  /// 在反向列表中，连续消息的第一条（最新的）才显示小尾巴
  static bool _shouldShowTail(
      List<Message> messages, int currentIndex, String currentUserId) {
    final currentMessage = messages[currentIndex];

    // 在反向列表中，检查前一条更新的消息（currentIndex - 1）
    if (currentIndex - 1 >= 0) {
      final previousMessage = messages[currentIndex - 1];

      // 如果前一条消息是不同的发送者，则显示尾巴
      if (previousMessage.senderId != currentMessage.senderId) {
        return true;
      }

      // 如果时间间隔超过5分钟，也显示尾巴
      final timeDiff =
          previousMessage.createdAt.difference(currentMessage.createdAt);
      if (timeDiff.inMinutes >= 5) {
        return true;
      }

      return false;
    }

    // 这是第一条消息（最新的），显示尾巴
    return true;
  }
}
