import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(25),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Text(
          _formatDate(date),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12.0,
            fontWeight: FontWeight.w500,
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
    final targetDate = DateTime(date.year, date.month, date.day);

    if (targetDate == today) {
      return '今天';
    } else if (targetDate == yesterday) {
      return '昨天';
    } else if (now.year == date.year) {
      // 同一年，显示月日
      return DateFormat('MM月dd日', 'zh_CN').format(date);
    } else {
      // 不同年，显示年月日
      return DateFormat('yyyy年MM月dd日', 'zh_CN').format(date);
    }
  }
}

/// 未读消息分隔符组件
/// 用于标识未读消息的开始位置
class UnreadMessageSeparator extends StatelessWidget {
  const UnreadMessageSeparator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 12.0),
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0.0),
      // decoration: BoxDecoration(
      //   // color: Theme.of(context).primaryColor,
      // ),
      child: const Row(
        children: [
          Expanded(
            child: Divider(
              color: Colors.white,
              thickness: 1.0,
              height: 1.0,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(
              '未读消息',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Divider(
              color: Colors.white,
              thickness: 1.0,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
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

  const MessageListItemData({
    required this.message,
    required this.isCurrentUser,
  });
}

/// 消息列表项 - 日期分隔符
class MessageListItemDateSeparator extends MessageListItem {
  final DateTime date;

  const MessageListItemDateSeparator({
    required this.date,
  });
}

/// 消息列表项 - 未读消息分隔符
class MessageListItemUnreadSeparator extends MessageListItem {
  const MessageListItemUnreadSeparator();
}
