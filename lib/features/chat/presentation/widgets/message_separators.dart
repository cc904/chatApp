import 'package:flutter/material.dart';

/// 日期分隔符组件
/// 用于在消息列表中显示日期分组
class DateSeparator extends StatelessWidget {
  final DateTime date;

  const DateSeparator({
    super.key,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 6.0,
          ),
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(13), // 替代过时的withOpacity(0.05)
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Text(
            _formatDate(date),
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 13.0,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  /// 格式化日期显示
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return '今天';
    } else if (messageDate == yesterday) {
      return '昨天';
    } else {
      return '${date.month}月${date.day}日';
    }
  }
}

/// 消息列表项的基类
/// 用于统一管理消息和分隔符的渲染
abstract class MessageListItem {
  const MessageListItem();
}

/// 消息列表项 - 实际消息
class MessageListItemData extends MessageListItem {
  final dynamic message; // Message 对象
  final bool isCurrentUser;
  final bool showAvatar; // 是否显示头像
  final bool showTail; // 是否显示小尾巴
  final bool isPrivateChat; // 是否为私聊

  const MessageListItemData({
    required this.message,
    required this.isCurrentUser,
    this.showAvatar = true,
    this.showTail = true,
    this.isPrivateChat = false,
  });
}

/// 消息列表项 - 日期分隔符
class MessageListItemDateSeparator extends MessageListItem {
  final DateTime date;

  const MessageListItemDateSeparator({
    required this.date,
  });
}
