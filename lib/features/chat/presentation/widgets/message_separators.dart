import 'package:flutter/material.dart';
import 'package:cc/core/database/models/message.dart';
import 'package:intl/intl.dart';

/// 消息列表项的抽象基类
abstract class MessageListItem {}

/// 消息数据项
class MessageListItemData extends MessageListItem {
  final Message message;
  final bool isCurrentUser;
  final bool showAvatar;
  final bool showTail;
  final bool isPrivateChat;

  MessageListItemData({
    required this.message,
    required this.isCurrentUser,
    required this.showAvatar,
    required this.showTail,
    required this.isPrivateChat,
  });
}

/// 日期分隔符项
class MessageListItemDateSeparator extends MessageListItem {
  final DateTime date;

  MessageListItemDateSeparator({required this.date});
}

/// 日期分隔符组件
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
      child: Row(
        children: [
          const Expanded(child: Divider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 6.0,
              ),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Text(
                _formatDate(date),
                style: TextStyle(
                  fontSize: 12.0,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return '今天';
    } else if (messageDate == yesterday) {
      return '昨天';
    } else if (now.difference(messageDate).inDays < 7) {
      // 一周内显示星期几
      final weekdays = ['星期一', '星期二', '星期三', '星期四', '星期五', '星期六', '星期日'];
      return weekdays[date.weekday - 1];
    } else {
      // 超过一周显示具体日期
      return DateFormat('MM月dd日').format(date);
    }
  }
}
