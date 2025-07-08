import 'package:flutter/material.dart';
import 'package:cc/core/database/models/message.dart';
import 'package:cc/core/utils/timezone_utils.dart';

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
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
          decoration: BoxDecoration(
            color: const Color(0xFFE7F3E7), // 使用和系统消息相同的淡绿色
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: FutureBuilder<String>(
            future: _formatDate(date),
            builder: (context, snapshot) {
              return Text(
                snapshot.data ?? '...',
                style: TextStyle(
                  fontSize: 11.0, // 和系统消息相同的字体大小
                  color: Colors.grey[600],
                  fontStyle: FontStyle.normal, // 和系统消息相同的字体样式
                ),
                textAlign: TextAlign.center,
              );
            },
          ),
        ),
      ),
    );
  }

  Future<String> _formatDate(DateTime date) async {
    // 🌍 使用TimezoneUtils格式化日期分隔符
    return await TimezoneUtils.formatDateSeparator(date);
  }
}
