import 'package:flutter/material.dart';
import 'package:cc/core/database/models/message.dart';
import 'package:intl/intl.dart';

/// 消息项组件
///
/// 用于显示单条消息，支持不同消息类型和发送状态
class MessageItem extends StatelessWidget {
  final Message message;
  final bool isCurrentUser;
  final VoidCallback? onTap;

  const MessageItem({
    super.key,
    required this.message,
    required this.isCurrentUser,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 4.0,
          horizontal: 8.0,
        ),
        child: Row(
          mainAxisAlignment:
              isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isCurrentUser) ...[
              _buildAvatar(),
              const SizedBox(width: 8.0),
            ],
            Flexible(
              child: _buildMessageBubble(context),
            ),
            if (isCurrentUser) ...[
              const SizedBox(width: 8.0),
              _buildMessageStatus(),
            ],
          ],
        ),
      ),
    );
  }

  /// 构建头像
  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 16.0,
      backgroundColor: Colors.grey[300],
      backgroundImage: message.senderAvatar != null
          ? NetworkImage(message.senderAvatar!)
          : null,
      child: message.senderAvatar == null
          ? Text(
              message.senderName?.isNotEmpty == true
                  ? message.senderName![0].toUpperCase()
                  : 'X',
              style: const TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
    );
  }

  /// 构建消息气泡
  Widget _buildMessageBubble(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.7,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 12.0,
        vertical: 8.0,
      ),
      decoration: BoxDecoration(
        color:
            isCurrentUser ? Theme.of(context).primaryColor : Colors.grey[200],
        borderRadius: BorderRadius.circular(18.0),
      ),
      child: Column(
        crossAxisAlignment:
            isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isCurrentUser && message.senderName != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Text(
                message.senderName!,
                style: TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ),
          _buildMessageContent(context),
          const SizedBox(height: 2.0),
          Text(
            _formatTime(message.createdAt),
            style: TextStyle(
              fontSize: 11.0,
              color: isCurrentUser
                  ? Colors.white.withAlpha(179) // 替代过时的withOpacity
                  : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建消息内容
  Widget _buildMessageContent(BuildContext context) {
    switch (message.type) {
      case 'text':
        return Text(
          message.text ?? '',
          style: TextStyle(
            fontSize: 14.0,
            color: isCurrentUser ? Colors.white : Colors.black87,
          ),
        );

      case 'image':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 200.0,
              height: 150.0,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: message.mediaUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        message.mediaUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(
                              Icons.broken_image,
                              color: Colors.grey,
                              size: 40.0,
                            ),
                          );
                        },
                      ),
                    )
                  : const Center(
                      child: Icon(
                        Icons.image,
                        color: Colors.grey,
                        size: 40.0,
                      ),
                    ),
            ),
            if (message.text?.isNotEmpty == true) ...[
              const SizedBox(height: 4.0),
              Text(
                message.text!,
                style: TextStyle(
                  fontSize: 14.0,
                  color: isCurrentUser ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ],
        );

      case 'voice':
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.mic,
              color: isCurrentUser ? Colors.white : Colors.grey[700],
              size: 20.0,
            ),
            const SizedBox(width: 8.0),
            Text(
              _formatDuration(message.duration ?? 0),
              style: TextStyle(
                fontSize: 14.0,
                color: isCurrentUser ? Colors.white : Colors.black87,
              ),
            ),
          ],
        );

      case 'file':
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.attachment,
              color: isCurrentUser ? Colors.white : Colors.grey[700],
              size: 20.0,
            ),
            const SizedBox(width: 8.0),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.fileName ?? '未知文件',
                    style: TextStyle(
                      fontSize: 14.0,
                      color: isCurrentUser ? Colors.white : Colors.black87,
                    ),
                  ),
                  if (message.fileSize != null)
                    Text(
                      _formatFileSize(message.fileSize!),
                      style: TextStyle(
                        fontSize: 12.0,
                        color: isCurrentUser
                            ? Colors.white.withAlpha(179) // 替代过时的withOpacity
                            : Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ),
          ],
        );

      default:
        return Text(
          message.text ?? '不支持的消息类型',
          style: TextStyle(
            fontSize: 14.0,
            color: isCurrentUser ? Colors.white : Colors.black87,
            fontStyle: FontStyle.italic,
          ),
        );
    }
  }

  /// 构建消息状态
  Widget _buildMessageStatus() {
    IconData iconData;
    Color color;

    switch (message.status) {
      case 'sending':
        iconData = Icons.access_time;
        color = Colors.grey;
        break;
      case 'sent':
        iconData = Icons.check;
        color = Colors.grey;
        break;
      case 'delivered':
        iconData = Icons.done_all;
        color = Colors.grey;
        break;
      case 'read':
        iconData = Icons.done_all;
        color = Colors.blue;
        break;
      case 'failed':
        iconData = Icons.error;
        color = Colors.red;
        break;
      default:
        iconData = Icons.check;
        color = Colors.grey;
    }

    return Icon(
      iconData,
      size: 16.0,
      color: color,
    );
  }

  /// 格式化时间
  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      // 今天：显示时间
      return DateFormat('HH:mm').format(dateTime);
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      // 昨天：显示"昨天 HH:mm"
      return '昨天 ${DateFormat('HH:mm').format(dateTime)}';
    } else if (now.difference(dateTime).inDays < 7) {
      // 一周内：显示星期几和时间
      return DateFormat('E HH:mm', 'zh_CN').format(dateTime);
    } else {
      // 更早：显示日期和时间
      return DateFormat('MM/dd HH:mm').format(dateTime);
    }
  }

  /// 格式化时长
  String _formatDuration(int milliseconds) {
    final seconds = milliseconds ~/ 1000;
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;

    if (minutes > 0) {
      return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
    } else {
      return '0:${remainingSeconds.toString().padLeft(2, '0')}';
    }
  }

  /// 格式化文件大小
  String _formatFileSize(double sizeInKB) {
    if (sizeInKB < 1024) {
      return '${sizeInKB.toStringAsFixed(1)} KB';
    } else {
      final sizeInMB = sizeInKB / 1024;
      return '${sizeInMB.toStringAsFixed(1)} MB';
    }
  }
}
