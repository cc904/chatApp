import 'package:flutter/material.dart';
import 'package:cc/core/database/models/message.dart';
import 'package:intl/intl.dart';

/// 消息显示状态
/// 用于传递预计算的消息状态信息
class MessageDisplayStatus {
  final bool isRead;
  final bool isDelivered;
  final MessageStatus messageStatus;

  const MessageDisplayStatus({
    required this.isRead,
    required this.isDelivered,
    required this.messageStatus,
  });
}

/// 消息项组件
///
/// 用于显示单条消息，支持不同消息类型和发送状态
/// 支持消息分组显示：同一人连续消息只在最后一条显示头像和尾巴
/// 💢💢💢 支持搜索高亮显示
class MessageItem extends StatelessWidget {
  final Message message;
  final bool isCurrentUser;
  final bool showAvatar; // 是否显示头像
  final bool showTail; // 是否显示小尾巴
  final bool isPrivateChat; // 是否为私聊
  final VoidCallback? onTap;
  final VoidCallback? onResend; // 💢💢💢 新增：重发消息回调

  /// 💢💢💢 新增搜索相关参数
  final bool isSearchResult; // 是否为搜索结果
  final bool isCurrentSearchResult; // 是否为当前选中的搜索结果
  final String? searchQuery; // 搜索关键词（用于高亮文本）

  /// 💢💢💢 新增：预计算的消息状态（由外部计算好传入）
  final MessageDisplayStatus? displayStatus;

  const MessageItem({
    super.key,
    required this.message,
    required this.isCurrentUser,
    this.showAvatar = true,
    this.showTail = true,
    this.isPrivateChat = false,
    this.onTap,
    this.onResend, // 💢💢💢 新增参数
    this.isSearchResult = false,
    this.isCurrentSearchResult = false,
    this.searchQuery,
    this.displayStatus, // 💢💢💢 新增参数：预计算的显示状态
  });

  @override
  Widget build(BuildContext context) {
    // 💢💢💢 删除的消息完全不显示
    if (message.isMessageDeleted) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 2.0, // 减小垂直间距以支持消息分组
          horizontal: 4.0, // 减少水平内边距，配合列表内边距调整
        ),
        child: Row(
          mainAxisAlignment:
              isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isCurrentUser) ...[
              // 只有在非私聊且需要显示头像时才显示
              if (!isPrivateChat && showAvatar)
                _buildAvatar()
              else if (!isPrivateChat)
                const SizedBox(width: 32.0), // 占位符保持对齐
              const SizedBox(width: 8.0),
            ],
            Flexible(
              child: _buildMessageBubble(context),
            ),
            if (isCurrentUser) ...[
              const SizedBox(width: 8.0),
              // 💢💢💢 已读状态已移到消息气泡内部，这里不再显示
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
    // 💢💢💢 计算搜索高亮样式
    Color? highlightBorderColor;
    double borderWidth = 0.0;

    if (isCurrentSearchResult) {
      // 当前搜索结果：橙色高亮边框
      highlightBorderColor = Colors.orange;
      borderWidth = 2.0;
    } else if (isSearchResult) {
      // 普通搜索结果：淡蓝色边框
      highlightBorderColor = Colors.blue.shade300;
      borderWidth = 1.5;
    }

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
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18.0),
          topRight: const Radius.circular(18.0),
          bottomLeft: isCurrentUser
              ? const Radius.circular(18.0)
              : showTail
                  ? const Radius.circular(2.0) // 更明显的小尾巴
                  : const Radius.circular(18.0),
          bottomRight: isCurrentUser
              ? showTail
                  ? const Radius.circular(2.0) // 更明显的小尾巴
                  : const Radius.circular(18.0)
              : const Radius.circular(18.0),
        ),
        // 💢💢💢 添加搜索高亮边框
        border: highlightBorderColor != null
            ? Border.all(color: highlightBorderColor, width: borderWidth)
            : null,
        // 💢💢💢 当前搜索结果添加发光效果
        boxShadow: isCurrentSearchResult
            ? [
                BoxShadow(
                  color: Colors.orange.withAlpha(102),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment:
            isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // 💢💢💢 置顶消息指示器
          if (message.isMessagePinned)
            Padding(
              padding: const EdgeInsets.only(bottom: 2.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.push_pin,
                    size: 12.0,
                    color: isCurrentUser ? Colors.white70 : Colors.orange,
                  ),
                  const SizedBox(width: 4.0),
                  Text(
                    '置顶',
                    style: TextStyle(
                      fontSize: 10.0,
                      color: isCurrentUser ? Colors.white70 : Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          if (!isCurrentUser && message.senderName != null && !isPrivateChat)
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
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (message.isMessageEdited) ...[
                Text(
                  '已编辑',
                  style: TextStyle(
                    fontSize: 10.0,
                    color: isCurrentUser
                        ? Colors.white.withAlpha(128)
                        : Colors.grey[500],
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(width: 4.0),
              ],
              Text(
                _formatTime(message.createdAt),
                style: TextStyle(
                  fontSize: 11.0,
                  color: isCurrentUser
                      ? Colors.white.withAlpha(179) // 替代过时的withOpacity
                      : Colors.grey[600],
                ),
              ),
              // 💢💢💢 将已读状态移到时间后面（仅当前用户消息显示）
              if (isCurrentUser) ...[
                const SizedBox(width: 4.0),
                _buildMessageStatusInline(),
              ],
            ],
          ),
        ],
      ),
    );
  }

  /// 构建消息内容
  Widget _buildMessageContent(BuildContext context) {
    switch (message.type) {
      case MessageType.text:
        return _buildHighlightedText(
          message.text ?? '', // 使用displayText代替text，自动处理撤销/删除状态
          baseStyle: TextStyle(
            fontSize: 14.0,
            color: isCurrentUser ? Colors.white : Colors.black87,
          ),
        );

      case MessageType.image:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth:
                    MediaQuery.of(context).size.width * 0.6, // 最大宽度为屏幕的60%
                maxHeight:
                    MediaQuery.of(context).size.height * 0.4, // 最大高度为屏幕的40%
                minWidth: 120.0, // 最小宽度
                minHeight: 80.0, // 最小高度
              ),
              child: AspectRatio(
                aspectRatio: _calculateImageAspectRatio(), // 计算合适的宽高比
                child: Container(
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
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
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
              ),
            ),
            if (message.caption?.isNotEmpty == true) ...[
              const SizedBox(height: 4.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: _buildHighlightedText(
                  message.caption!, // 图片消息使用caption字段
                  baseStyle: TextStyle(
                    fontSize: 14.0,
                    color: isCurrentUser ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ],
          ],
        );

      case MessageType.voice:
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

      case MessageType.video:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.6,
                maxHeight: MediaQuery.of(context).size.height * 0.4,
                minWidth: 120.0,
                minHeight: 80.0,
              ),
              child: AspectRatio(
                aspectRatio: _calculateImageAspectRatio(),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // 视频缩略图
                      if (message.thumbnailUrl != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            message.thumbnailUrl!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.video_library,
                                color: Colors.grey,
                                size: 40.0,
                              );
                            },
                          ),
                        )
                      else
                        const Icon(
                          Icons.video_library,
                          color: Colors.grey,
                          size: 40.0,
                        ),
                      // 播放按钮覆盖层
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(128),
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(12.0),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 24.0,
                        ),
                      ),
                      // 时长显示
                      if (message.duration != null)
                        Positioned(
                          bottom: 8.0,
                          right: 8.0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6.0,
                              vertical: 2.0,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withAlpha(179),
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            child: Text(
                              _formatDuration(message.duration!),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12.0,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            if (message.caption?.isNotEmpty == true) ...[
              const SizedBox(height: 4.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: _buildHighlightedText(
                  message.caption!,
                  baseStyle: TextStyle(
                    fontSize: 14.0,
                    color: isCurrentUser ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ],
          ],
        );

      case MessageType.file:
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

      case MessageType.system:
        return Text(
          message.displayText, // 系统消息使用displayText
          style: TextStyle(
            fontSize: 14.0,
            color: isCurrentUser ? Colors.white70 : Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        );
    }
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
    if (sizeInKB < 1) {
      return '${(sizeInKB * 1024).toStringAsFixed(0)} B';
    } else if (sizeInKB < 1024) {
      return '${sizeInKB.toStringAsFixed(1)} KB';
    } else if (sizeInKB < 1024 * 1024) {
      final sizeInMB = sizeInKB / 1024;
      return '${sizeInMB.toStringAsFixed(1)} MB';
    } else {
      final sizeInGB = sizeInKB / (1024 * 1024);
      return '${sizeInGB.toStringAsFixed(2)} GB';
    }
  }

  /// 计算图片的宽高比
  double _calculateImageAspectRatio() {
    // 如果没有尺寸信息，根据图片类型或URL判断可能的宽高比
    if (message.mediaUrl != null) {
      final url = message.mediaUrl!.toLowerCase();

      // 根据文件名或URL推测可能的宽高比
      if (url.contains('portrait') || url.contains('vertical')) {
        return 0.75; // 3:4 竖图比例
      } else if (url.contains('landscape') || url.contains('horizontal')) {
        return 1.5; // 3:2 横图比例
      } else if (url.contains('square')) {
        return 1.0; // 1:1 正方形
      }

      // 根据文件扩展名推测可能的宽高比
      if (url.contains('.jpg') || url.contains('.jpeg')) {
        return 1.3; // JPEG 通常是相机拍摄，4:3 比例较常见
      } else if (url.contains('.png')) {
        return 1.0; // PNG 通常是图标或截图，接近正方形
      } else if (url.contains('.gif')) {
        return 1.2; // GIF 通常是动图，略微横向
      }
    }

    // 默认使用略微横向的比例，适合大多数照片
    return 1.3; // 4:3 比例，接近手机拍照的默认比例
  }

  /// 构建高亮文本
  Widget _buildHighlightedText(String text, {required TextStyle baseStyle}) {
    if (searchQuery == null || searchQuery!.isEmpty) {
      return Text(
        text,
        style: baseStyle,
      );
    }

    final RegExp regExp = RegExp(searchQuery!, caseSensitive: false);
    final List<TextSpan> spans = [];
    int lastIndex = 0;

    for (final match in regExp.allMatches(text)) {
      final start = match.start;
      final end = match.end;

      if (start > lastIndex) {
        spans.add(TextSpan(
          text: text.substring(lastIndex, start),
          style: baseStyle,
        ));
      }

      spans.add(TextSpan(
        text: text.substring(start, end),
        style: baseStyle.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.orange,
        ),
      ));

      lastIndex = end;
    }

    if (lastIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastIndex),
        style: baseStyle,
      ));
    }

    return Text.rich(
      TextSpan(
        children: spans,
      ),
    );
  }

  /// 构建消息状态（内联版本，用于显示在消息气泡内）
  Widget _buildMessageStatusInline() {
    // 💢💢💢 撤销的消息不显示发送状态
    if (message.isMessageRevoked) {
      return const SizedBox.shrink();
    }

    // 💢💢💢 新逻辑：根据会话参与者信息计算已读状态
    if (displayStatus != null) {
      return _buildStatusByDisplayStatus();
    }

    // 💢💢💢 回退到原有逻辑（群聊或缺少会话信息时）
    return _buildStatusByMessageStatus();
  }

  /// 根据显示状态构建状态（预计算专用）
  Widget _buildStatusByDisplayStatus() {
    if (displayStatus == null) {
      return const SizedBox.shrink();
    }

    IconData iconData;
    Color color;

    // 根据预计算的状态判断显示
    if (displayStatus!.isRead) {
      // 已读
      iconData = Icons.done_all;
      color = isCurrentUser ? Colors.white : Colors.blue;
    } else if (displayStatus!.isDelivered) {
      // 已送达但未读
      iconData = Icons.done_all;
      color = isCurrentUser ? Colors.white.withAlpha(179) : Colors.grey;
    } else {
      // 根据消息本身的状态判断
      switch (displayStatus!.messageStatus) {
        case MessageStatus.sending:
          iconData = Icons.access_time;
          color = isCurrentUser ? Colors.white.withAlpha(179) : Colors.grey;
          break;
        case MessageStatus.sent:
          iconData = Icons.check;
          color = isCurrentUser ? Colors.white.withAlpha(179) : Colors.grey;
          break;
        case MessageStatus.failed:
          return const Icon(
            Icons.error,
            size: 12.0,
            color: Colors.red,
          );
        default:
          iconData = Icons.check;
          color = isCurrentUser ? Colors.white.withAlpha(179) : Colors.grey;
      }
    }

    return Icon(
      iconData,
      size: 12.0,
      color: color,
    );
  }

  /// 根据消息状态构建状态（群聊或回退逻辑）
  Widget _buildStatusByMessageStatus() {
    IconData iconData;
    Color color;

    switch (message.status) {
      case MessageStatus.sending:
        iconData = Icons.access_time;
        color = isCurrentUser ? Colors.white.withAlpha(179) : Colors.grey;
        break;
      case MessageStatus.sent:
        iconData = Icons.check;
        color = isCurrentUser ? Colors.white.withAlpha(179) : Colors.grey;
        break;
      case MessageStatus.delivered:
        iconData = Icons.done_all;
        color = isCurrentUser ? Colors.white.withAlpha(179) : Colors.grey;
        break;
      case MessageStatus.read:
        iconData = Icons.done_all;
        color = isCurrentUser ? Colors.white : Colors.blue;
        break;
      case MessageStatus.failed:
        return const Icon(
          Icons.error,
          size: 12.0,
          color: Colors.red,
        );
      default:
        iconData = Icons.check;
        color = isCurrentUser ? Colors.white.withAlpha(179) : Colors.grey;
    }

    return Icon(
      iconData,
      size: 12.0,
      color: color,
    );
  }
}
