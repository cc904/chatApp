import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cc/core/database/models/message.dart';
import 'package:cc/core/widgets/user_avatar.dart';

/// 消息类型常量
class MessageType {
  // 基础类型
  static const String text = 'text';
  static const String image = 'image';
  static const String voice = 'voice';
  static const String video = 'video';
  static const String file = 'file';
  static const String location = 'location';

  // 系统消息类型
  static const String system = 'system';
  static const String systemUserJoined = 'system_user_joined';
  static const String systemUserLeft = 'system_user_left';
  static const String systemGroupCreated = 'system_group_created';
  static const String systemGroupRenamed = 'system_group_renamed';

  // 特殊消息类型
  static const String recalled = 'recalled'; // 撤销消息
  static const String deleted = 'deleted'; // 删除消息
  static const String edited = 'edited'; // 编辑消息
  static const String reply = 'reply'; // 回复消息
  static const String forward = 'forward'; // 转发消息

  // 富媒体类型
  static const String sticker = 'sticker'; // 表情包
  static const String gif = 'gif'; // GIF动图
  static const String contact = 'contact'; // 联系人名片
  static const String poll = 'poll'; // 投票
  static const String link = 'link'; // 链接预览
}

/// 高级消息气泡组件
class AdvancedMessageBubble extends StatefulWidget {
  final Message message;
  final bool isMe;
  final String currentUserId;
  final Message? quotedMessage; // 被引用的消息
  final Message? repliedMessage; // 被回复的消息
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onQuoteTap; // 点击引用消息
  final Function(String)? onUserMentionTap; // 点击用户@
  final Function(String)? onReaction; // 添加反应
  final bool showSenderInfo; // 是否显示发送者信息
  final bool isHighlighted; // 是否高亮
  final bool isSelected; // 是否被选中
  final bool showTimestamp; // 是否显示时间戳

  const AdvancedMessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.currentUserId,
    this.quotedMessage,
    this.repliedMessage,
    this.onTap,
    this.onLongPress,
    this.onQuoteTap,
    this.onUserMentionTap,
    this.onReaction,
    this.showSenderInfo = false,
    this.isHighlighted = false,
    this.isSelected = false,
    this.showTimestamp = true,
  });

  @override
  State<AdvancedMessageBubble> createState() => _AdvancedMessageBubbleState();
}

class _AdvancedMessageBubbleState extends State<AdvancedMessageBubble>
    with TickerProviderStateMixin {
  late AnimationController _highlightController;
  late AnimationController _selectionController;
  late Animation<Color?> _highlightAnimation;
  late Animation<double> _selectionAnimation;

  @override
  void initState() {
    super.initState();

    // 高亮动画控制器
    _highlightController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // 选择动画控制器
    _selectionController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    // 高亮颜色动画
    _highlightAnimation = ColorTween(
      begin: Colors.transparent,
      end: Colors.yellow.withAlpha(128),
    ).animate(CurvedAnimation(
      parent: _highlightController,
      curve: Curves.easeInOut,
    ));

    // 选择缩放动画
    _selectionAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _selectionController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(AdvancedMessageBubble oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 处理高亮状态变化
    if (widget.isHighlighted != oldWidget.isHighlighted) {
      if (widget.isHighlighted) {
        _highlightController.forward().then((_) {
          _highlightController.reverse();
        });
      }
    }

    // 处理选择状态变化
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _selectionController.forward();
      } else {
        _selectionController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _highlightController.dispose();
    _selectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 处理撤销消息 - 使用status字段判断
    if (widget.message.status == 'revoked') {
      return _buildRevokedMessage();
    }

    // 处理删除消息（仅发送者可见） - 使用status字段判断
    if (widget.message.status == 'deleted' && !widget.isMe) {
      return const SizedBox.shrink(); // 对其他人不可见
    }

    // 处理系统消息
    if (widget.message.type == MessageType.system) {
      return _buildSystemMessage();
    }

    return AnimatedBuilder(
      animation: Listenable.merge([_highlightController, _selectionController]),
      builder: (context, child) {
        return Transform.scale(
          scale: _selectionAnimation.value,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
            decoration: BoxDecoration(
              color: _highlightAnimation.value,
              borderRadius: BorderRadius.circular(8),
            ),
            child: _buildMessageContent(),
          ),
        );
      },
    );
  }

  Widget _buildMessageContent() {
    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: Row(
        mainAxisAlignment:
            widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 左侧时间（非自己的消息）
          if (!widget.isMe && widget.showTimestamp) _buildTimestamp(),

          // 主要消息内容
          Flexible(
            child: Column(
              crossAxisAlignment: widget.isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                // 回复消息引用
                if (widget.message.quotedMessageId != null)
                  _buildQuotedMessage(),

                // 主消息气泡
                _buildMainBubble(),

                // 消息反应 - 暂时注释掉，因为Message模型中没有reactions字段
                // if (widget.message.reactions?.isNotEmpty == true)
                //   _buildReactions(),

                // 消息状态指示器
                if (widget.isMe) _buildMessageStatus(),
              ],
            ),
          ),

          // 右侧时间（自己的消息）
          if (widget.isMe && widget.showTimestamp) _buildTimestamp(),
        ],
      ),
    );
  }

  Widget _buildMainBubble() {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      decoration: BoxDecoration(
        color: _getBubbleColor(),
        borderRadius: _getBubbleBorderRadius(),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 发送者信息（群聊中非自己的消息）
          if (widget.showSenderInfo && !widget.isMe) _buildSenderInfo(),

          // 消息内容
          _buildMessageTypeContent(),
        ],
      ),
    );
  }

  Widget _buildMessageTypeContent() {
    switch (widget.message.type) {
      case MessageType.text:
        return _buildTextContent();
      case MessageType.image:
        return _buildImageContent();
      case MessageType.voice:
        return _buildVoiceContent();
      case MessageType.video:
        return _buildVideoContent();
      case MessageType.file:
        return _buildFileContent();
      case MessageType.location:
        return _buildLocationContent();
      case MessageType.sticker:
        return _buildStickerContent();
      case MessageType.contact:
        return _buildContactContent();
      case MessageType.poll:
        return _buildPollContent();
      default:
        return _buildTextContent();
    }
  }

  // 文本消息内容
  Widget _buildTextContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: SelectableText(
        widget.message.text ?? '',
        style: TextStyle(
          fontSize: 16,
          color: widget.isMe ? Colors.white : Colors.black87,
        ),
        onTap: () {
          // 处理文本选择
          HapticFeedback.selectionClick();
        },
      ),
    );
  }

  // 图片消息内容
  Widget _buildImageContent() {
    return ClipRRect(
      borderRadius: _getBubbleBorderRadius(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 图片
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.6,
              maxHeight: 300,
            ),
            child: widget.message.mediaUrl != null
                ? Image.network(
                    widget.message.mediaUrl!,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 200,
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: Icon(Icons.error, color: Colors.red),
                        ),
                      );
                    },
                  )
                : Container(
                    height: 200,
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: Icon(Icons.image, size: 48, color: Colors.grey),
                    ),
                  ),
          ),

          // 图片说明文字
          if (widget.message.text?.isNotEmpty == true)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                widget.message.text!,
                style: TextStyle(
                  fontSize: 14,
                  color: widget.isMe ? Colors.white : Colors.black87,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 语音消息内容
  Widget _buildVoiceContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.play_arrow,
            color: widget.isMe ? Colors.white : Colors.blue,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 20,
              decoration: BoxDecoration(
                color: (widget.isMe ? Colors.white : Colors.blue).withAlpha(51),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: List.generate(20, (index) {
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      decoration: BoxDecoration(
                        color: widget.isMe ? Colors.white : Colors.blue,
                        borderRadius: BorderRadius.circular(1),
                      ),
                      height: (index % 4 + 1) * 4.0,
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            widget.message.duration != null
                ? _formatDurationFromMilliseconds(widget.message.duration!)
                : '0:00',
            style: TextStyle(
              fontSize: 12,
              color: widget.isMe ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  // 视频消息内容
  Widget _buildVideoContent() {
    return ClipRRect(
      borderRadius: _getBubbleBorderRadius(),
      child: Stack(
        children: [
          // 视频缩略图
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.6,
              maxHeight: 300,
            ),
            child: widget.message.thumbnailUrl != null
                ? Image.network(
                    widget.message.thumbnailUrl!,
                    fit: BoxFit.cover,
                  )
                : Container(
                    height: 200,
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: Icon(Icons.videocam, size: 48, color: Colors.grey),
                    ),
                  ),
          ),

          // 播放按钮
          Positioned.fill(
            child: Center(
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(128),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            ),
          ),

          // 视频时长
          if (widget.message.duration != null)
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(128),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _formatDurationFromMilliseconds(widget.message.duration!),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 文件消息内容
  Widget _buildFileContent() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: (widget.isMe ? Colors.white : Colors.blue).withAlpha(51),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getFileIcon(widget.message.fileName),
              color: widget.isMe ? Colors.white : Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.message.fileName ?? '未知文件',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: widget.isMe ? Colors.white : Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget.message.fileSize != null)
                  Text(
                    _formatFileSize(widget.message.fileSize!.toInt()),
                    style: TextStyle(
                      fontSize: 12,
                      color: widget.isMe ? Colors.white70 : Colors.black54,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 位置消息内容
  Widget _buildLocationContent() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.location_on,
            color: widget.isMe ? Colors.white : Colors.red,
            size: 24,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '位置信息',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: widget.isMe ? Colors.white : Colors.black87,
                  ),
                ),
                if (widget.message.locationAddress != null)
                  Text(
                    widget.message.locationAddress!,
                    style: TextStyle(
                      fontSize: 12,
                      color: widget.isMe ? Colors.white70 : Colors.black54,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 表情包内容
  Widget _buildStickerContent() {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 120,
        maxHeight: 120,
      ),
      child: widget.message.mediaUrl != null
          ? Image.network(
              widget.message.mediaUrl!,
              fit: BoxFit.contain,
            )
          : const Icon(Icons.emoji_emotions, size: 48),
    );
  }

  // 联系人名片内容
  Widget _buildContactContent() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          UserAvatar(
            avatarUrl: widget.message.senderAvatar,
            name: widget.message.senderName ?? '',
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.message.senderName ?? '未知联系人',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: widget.isMe ? Colors.white : Colors.black87,
                  ),
                ),
                if (widget.message.text != null)
                  Text(
                    widget.message.text!,
                    style: TextStyle(
                      fontSize: 12,
                      color: widget.isMe ? Colors.white70 : Colors.black54,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 投票内容
  Widget _buildPollContent() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.poll,
                color: widget.isMe ? Colors.white : Colors.blue,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '投票',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: widget.isMe ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.message.text ?? '投票问题',
            style: TextStyle(
              fontSize: 14,
              color: widget.isMe ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // 撤销消息显示
  Widget _buildRevokedMessage() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey.withAlpha(51),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.block,
                size: 14,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 6),
              Text(
                widget.isMe
                    ? '你撤回了一条消息'
                    : '${widget.message.senderName ?? "对方"}撤回了一条消息',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 系统消息显示
  Widget _buildSystemMessage() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(51),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            widget.message.text ?? '',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  // 引用消息显示
  Widget _buildQuotedMessage() {
    return GestureDetector(
      onTap: widget.onQuoteTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.withAlpha(51),
          borderRadius: BorderRadius.circular(8),
          border: Border(
            left: BorderSide(
              color: widget.isMe ? Colors.white : Colors.blue,
              width: 3,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '引用消息',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: widget.isMe ? Colors.white70 : Colors.blue,
              ),
            ),
            Text(
              '消息ID: ${widget.message.quotedMessageId}',
              style: TextStyle(
                fontSize: 13,
                color: widget.isMe ? Colors.white70 : Colors.black54,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // 消息反应显示 - 注释掉因为Message模型中没有reactions字段
  // Widget _buildReactions() {
  //   final reactions = widget.message.reactions!;
  //   // ... 实现代码
  // }

  // 消息状态指示器
  Widget _buildMessageStatus() {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 根据status字段判断状态
          if (widget.message.status == 'read')
            Icon(
              Icons.done_all,
              size: 14.0,
              color: Colors.blue.shade200,
            ),
          if (widget.message.status == 'delivered')
            const Icon(
              Icons.done_all,
              size: 14.0,
              color: Colors.grey,
            ),
        ],
      ),
    );
  }

  // 发送者信息
  Widget _buildSenderInfo() {
    return Padding(
      padding: const EdgeInsets.only(left: 12, top: 8, bottom: 4),
      child: Text(
        widget.message.senderName ?? '未知用户',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: widget.isMe ? Colors.white70 : Colors.blue,
        ),
      ),
    );
  }

  // 时间戳
  Widget _buildTimestamp() {
    return Padding(
      padding: EdgeInsets.only(
        left: widget.isMe ? 8 : 0,
        right: widget.isMe ? 0 : 8,
        bottom: 4,
      ),
      child: Text(
        _formatTime(widget.message.createdAt),
        style: const TextStyle(
          fontSize: 10,
          color: Colors.white70,
        ),
      ),
    );
  }

  Color _getBubbleColor() {
    if (widget.message.status == 'deleted' && widget.isMe) {
      return Colors.grey.withAlpha(128); // 已删除消息显示为灰色
    }

    if (widget.isSelected) {
      return widget.isMe ? Colors.green.shade400 : Colors.blue.shade100;
    }

    return widget.isMe ? Colors.green.shade300 : Colors.white;
  }

  BorderRadius _getBubbleBorderRadius() {
    return BorderRadius.circular(16).copyWith(
      bottomLeft:
          widget.isMe ? const Radius.circular(16) : const Radius.circular(4),
      bottomRight:
          widget.isMe ? const Radius.circular(4) : const Radius.circular(16),
    );
  }

  IconData _getFileIcon(String? fileName) {
    if (fileName == null) return Icons.insert_drive_file;

    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'zip':
      case 'rar':
        return Icons.archive;
      case 'mp3':
      case 'wav':
        return Icons.audiotrack;
      case 'mp4':
      case 'avi':
        return Icons.video_file;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${dateTime.month}/${dateTime.day}';
    } else {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  String _formatDurationFromMilliseconds(int milliseconds) {
    final minutes = (milliseconds / 60000).floor();
    final seconds = ((milliseconds % 60000) / 1000).floor();
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
