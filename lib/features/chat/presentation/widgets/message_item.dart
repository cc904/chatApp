import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cc/core/database/drift_database.dart';
import 'package:cc/core/utils/user_display_utils.dart';
import 'package:cc/core/adapters/message_adapter.dart';
import 'voice_message_widget.dart';
import 'image_message_widget.dart';
import 'video_message_widget.dart';
import 'package:cc/core/constants/app_colors.dart';
import 'package:cc/core/widgets/user_avatar.dart';

/// 消息显示状态
class MessageDisplayStatus {
  final bool isRead;
  final bool isDelivered;
  final String messageStatus;

  const MessageDisplayStatus({
    required this.isRead,
    required this.isDelivered,
    required this.messageStatus,
  });
}

/// 消息项组件
class MessageItem extends StatelessWidget {
  final Message message;
  final bool isCurrentUser;
  final bool showAvatar;
  final bool showTail;
  final bool isNotGroupChat;
  final bool isChannel;
  final VoidCallback? onTap;
  final VoidCallback? onResend;

  // 长按菜单回调
  final VoidCallback? onLongPress;
  final VoidCallback? onReply;
  final VoidCallback? onForward;
  final VoidCallback? onCopy;
  final VoidCallback? onRevoke;
  final VoidCallback? onDelete;

  // 搜索相关参数
  final bool isSearchResult;
  final bool isCurrentSearchResult;
  final String? searchQuery;
  final MessageDisplayStatus? displayStatus;

  // 高亮相关参数
  final bool isHighlighted;

  // 获取被回复消息的回调
  final Message? Function(String messageId)? getQuotedMessage;

  const MessageItem({
    super.key,
    required this.message,
    required this.isCurrentUser,
    this.showAvatar = true,
    this.showTail = true,
    this.isNotGroupChat = false,
    this.isChannel = false,
    this.onTap,
    this.onResend,
    this.isSearchResult = false,
    this.isCurrentSearchResult = false,
    this.searchQuery,
    this.onLongPress,
    this.onReply,
    this.onForward,
    this.onCopy,
    this.onRevoke,
    this.onDelete,
    this.displayStatus,
    this.isHighlighted = false,
    this.getQuotedMessage,
  });

  /// Helper method to extract text from message content JSON
  String? _getTextFromMessage() {
    // 🔧 修复：使用MessageAdapter的extractTextFromContent方法
    return MessageAdapter.extractTextFromContent(message.content);
  }

  /// Helper method to extract fileName from message content JSON
  String? _getFileNameFromMessage() {
    // 🔧 修复：使用MessageAdapter的extractMediaInfo方法
    final mediaInfo = MessageAdapter.extractMediaInfo(message.content);
    return mediaInfo?['file_name'] as String?;
  }

  @override
  Widget build(BuildContext context) {
    if (message.messageType == 'SYSTEM') {
      return _buildSystemMessage(context);
    }

    return GestureDetector(
      onTap: onTap,
      onLongPress: () => _showContextMenu(context),
      onSecondaryTap: () => _showContextMenu(context),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
        child: Row(
          mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // 他人消息或私聊中对方消息：头像在左侧
            if (!isCurrentUser)
              if (!isNotGroupChat && showAvatar) ...[
                _buildAvatar(),
                const SizedBox(width: 8.0),
              ] else if (!isNotGroupChat)
                const SizedBox(width: 40.0), // 占位空间，保持对齐
            Flexible(child: _buildMessageBubble(context)),
            // 当前用户消息：不显示头像，只保留适当的右侧间距
            if (isCurrentUser) ...[
              const SizedBox(width: 0.0), // 增加右侧间距，替代头像空间
            ],
          ],
        ),
      ),
    );
  }

  void _showContextMenu(BuildContext context) {
    HapticFeedback.lightImpact();

    if (onLongPress == null && onRevoke == null && onDelete == null && onReply == null && onForward == null && onCopy == null) {
      return;
    }

    final List<_MessageMenuAction> actions = _getAvailableActions();
    if (actions.isEmpty) return;

    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final Offset position = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;
    final Size screenSize = MediaQuery.of(context).size;

    double menuX;
    double menuY = position.dy + size.height / 2;

    if (isCurrentUser) {
      menuX = position.dx + size.width - 200;
      if (menuX < 16) menuX = 16;
    } else {
      menuX = position.dx + 60;
      if (menuX + 200 > screenSize.width - 16) {
        menuX = screenSize.width - 216;
      }
    }

    final menuHeight = actions.length * 48.0 + 16;
    if (menuY + menuHeight > screenSize.height - 100) {
      menuY = position.dy - menuHeight / 2;
    }
    if (menuY < 100) {
      menuY = 100;
    }

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(menuX, menuY, menuX + 200, menuY + 40),
      items: actions
          .map((action) => PopupMenuItem<String>(
                value: action.label,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        action.label,
                        style: TextStyle(
                          color: action.isDestructive ? Colors.red : Colors.black87,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      action.icon,
                      size: 18,
                      color: action.isDestructive ? Colors.red : Colors.grey[600],
                    ),
                  ],
                ),
              ))
          .toList(),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ).then((selectedAction) {
      if (selectedAction != null) {
        final action = actions.firstWhere(
          (a) => a.label == selectedAction,
          orElse: () => actions.first,
        );
        action.onTap();
      }
    });
  }

  List<_MessageMenuAction> _getAvailableActions() {
    final List<_MessageMenuAction> actions = [];

    if (onReply != null && message.messageStatus != 'DELETED') {
      actions.add(_MessageMenuAction(
        icon: Icons.reply,
        label: '回复',
        onTap: onReply!,
      ));
    }

    if (onForward != null && message.messageStatus != 'DELETED' && message.messageType != 'SYSTEM') {
      actions.add(_MessageMenuAction(
        icon: Icons.forward,
        label: '转发',
        onTap: onForward!,
      ));
    }

    if (onCopy != null &&
        message.messageType == 'TEXT' &&
        message.messageStatus != 'DELETED' &&
        message.messageStatus != 'REVOKED' &&
        (_getTextFromMessage()?.isNotEmpty ?? false)) {
      actions.add(_MessageMenuAction(
        icon: Icons.copy,
        label: '复制',
        onTap: onCopy!,
      ));
    }

    if (onRevoke != null && isCurrentUser && message.messageStatus != 'REVOKED' && message.messageStatus != 'DELETED' && message.messageType != 'SYSTEM') {
      actions.add(_MessageMenuAction(
        icon: Icons.undo,
        label: '撤回',
        onTap: onRevoke!,
        isDestructive: true,
      ));
    }

    if (onDelete != null && isCurrentUser && message.messageStatus != 'DELETED' && message.messageType != 'SYSTEM') {
      actions.add(_MessageMenuAction(
        icon: Icons.delete,
        label: '删除',
        onTap: onDelete!,
        isDestructive: true,
      ));
    }

    return actions;
  }

  Widget _buildAvatar() {
    return UserAvatar(
      name: message.senderName ?? 'Unknown',
      avatarUrl: message.senderAvatar,
      userId: message.senderId,
      radius: 16.0,
      backgroundColor: UserDisplayUtils.generateUserColor(message.senderName),
      // roleId: message.senderRoleId, // 字段已移除
    );
  }

  Widget _buildMessageBubble(BuildContext context) {
    Color? highlightBorderColor;
    double borderWidth = 0.0;

    // 高亮优先级：临时高亮 > 当前搜索结果 > 搜索结果
    if (isHighlighted) {
      highlightBorderColor = Colors.amber;
      borderWidth = 2.5;
    } else if (isCurrentSearchResult) {
      highlightBorderColor = Colors.orange;
      borderWidth = 2.0;
    } else if (isSearchResult) {
      highlightBorderColor = AppColors.primary.withAlpha(128);
      borderWidth = 1.5;
    }

    // 动态计算消息气泡的最大宽度（基于实际布局空间计算）
    final screenWidth = MediaQuery.of(context).size.width;
    double maxWidth;

    if (isNotGroupChat || isChannel) {
      // 私聊或者频道：屏幕宽度 - 预留边距(16px) = 屏幕宽度 - 24px
      maxWidth = screenWidth - 30.0;
    } else if (isCurrentUser) {
      // 当前用户消息：屏幕宽度 - 左右外层间距(4px×2) - 右侧间距(16px) - 预留边距(16px) = 屏幕宽度 - 40px
      maxWidth = screenWidth - 65.0;
    } else {
      // 群聊他人消息：屏幕宽度 - 左右外层间距(4px×2) - 头像(32px) - 头像间距(8px) - 预留边距(16px) = 屏幕宽度 - 64px
      maxWidth = screenWidth - 80.0;
    }

    // 检查是否为媒体消息（图片或视频）
    final isMediaMessage = message.messageType == 'IMAGE' || message.messageType == 'VIDEO';

    if (isMediaMessage) {
      // 媒体消息：白色背景，图片顶部和两侧边距1px，底部无圆角
      return Container(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18.0),
            topRight: const Radius.circular(18.0),
            bottomLeft: isCurrentUser
                ? const Radius.circular(18.0)
                : showTail
                    ? const Radius.circular(2.0)
                    : const Radius.circular(18.0),
            bottomRight: isCurrentUser
                ? showTail
                    ? const Radius.circular(2.0)
                    : const Radius.circular(18.0)
                : const Radius.circular(18.0),
          ),
          border: highlightBorderColor != null ? Border.all(color: highlightBorderColor, width: borderWidth) : null,
          boxShadow: isHighlighted
              ? [
                  BoxShadow(
                    color: Colors.amber.withAlpha(128),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ]
              : isCurrentSearchResult
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
          crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // 置顶标签（如果需要）
            if (message.isPinned)
              const Padding(
                padding: EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 2.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.push_pin,
                      size: 12.0,
                      color: Colors.orange,
                    ),
                    SizedBox(width: 4.0),
                    Text(
                      '置顶',
                      style: TextStyle(
                        fontSize: 10.0,
                        color: Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            // 媒体消息不显示发送者名称
            // 媒体内容（顶部和两侧边距1px）
            Padding(
              padding: const EdgeInsets.fromLTRB(1.0, 1.0, 1.0, 0.0),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: message.isPinned ? const Radius.circular(0.0) : const Radius.circular(17.0),
                  topRight: message.isPinned ? const Radius.circular(0.0) : const Radius.circular(17.0),
                  bottomLeft: const Radius.circular(0.0),
                  bottomRight: const Radius.circular(0.0),
                ),
                child: _buildMessageContent(context),
              ),
            ),
            // 底部时间和状态区域
            Padding(
              padding: const EdgeInsets.fromLTRB(12.0, 2.0, 12.0, 8.0),
              child: _buildTimeAndStatusRow(),
            ),
          ],
        ),
      );
    } else {
      // 非媒体消息：统一白色背景
      return Container(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18.0),
            topRight: const Radius.circular(18.0),
            bottomLeft: isCurrentUser
                ? const Radius.circular(18.0)
                : showTail
                    ? const Radius.circular(2.0)
                    : const Radius.circular(18.0),
            bottomRight: isCurrentUser
                ? showTail
                    ? const Radius.circular(2.0)
                    : const Radius.circular(18.0)
                : const Radius.circular(18.0),
          ),
          border: highlightBorderColor != null ? Border.all(color: highlightBorderColor, width: borderWidth) : null,
          boxShadow: isHighlighted
              ? [
                  BoxShadow(
                    color: Colors.amber.withAlpha(128),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ]
              : isCurrentSearchResult
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
          crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (message.isPinned)
              const Padding(
                padding: EdgeInsets.only(bottom: 2.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.push_pin,
                      size: 12.0,
                      color: Colors.orange,
                    ),
                    SizedBox(width: 4.0),
                    Text(
                      '置顶',
                      style: TextStyle(
                        fontSize: 10.0,
                        color: Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            if (message.senderName != null && (!isNotGroupChat || isChannel) && !isCurrentUser)
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  message.senderName!,
                  style: TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.bold,
                    color: UserDisplayUtils.generateUserColor(message.senderName),
                  ),
                ),
              ),
            // 显示回复的消息
            if (message.quotedMessageId != null) _buildQuotedMessage(context),
            _buildMessageContent(context),
            const SizedBox(height: 2.0),
            _buildTimeAndStatusRow(),
          ],
        ),
      );
    }
  }

  Widget _buildMessageContent(BuildContext context) {
    // 💢💢💢 如果消息已撤回，统一显示撤回提示，不管类型
    if (message.messageStatus == 'REVOKED') {
      return Text(
        '此消息已被撤回',
        style: TextStyle(
          color: Colors.grey[600],
          fontStyle: FontStyle.italic,
          fontSize: 14.0,
        ),
      );
    }

    // 💢💢💢 如果消息已删除，统一显示删除提示，不管类型
    if (message.messageStatus == 'DELETED') {
      return Text(
        '消息已删除',
        style: TextStyle(
          color: Colors.grey[600],
          fontStyle: FontStyle.italic,
          fontSize: 14.0,
        ),
      );
    }

    switch (message.messageType) {
      case 'TEXT':
        return _buildTextContent(context);
      case 'IMAGE':
        return ImageMessageWidget(message: message, isCurrentUser: isCurrentUser);
      case 'VIDEO':
        return VideoMessageWidget(message: message, isCurrentUser: isCurrentUser);
      case 'VOICE':
        return VoiceMessageWidget(message: message, isCurrentUser: isCurrentUser);
      case 'FILE':
        return _buildFileContent(context);
      default:
        return _buildTextContent(context);
    }
  }

  Widget _buildTextContent(BuildContext context) {
    // 💢💢💢 撤回和删除处理已移至_buildMessageContent统一处理
    // 此方法只处理正常的文本显示
    return Text(
      _getTextFromMessage() ?? '',
      style: const TextStyle(
        color: Colors.black87,
        fontSize: 16.0,
      ),
    );
  }

  Widget _buildFileContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.file_present,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 8.0),
          Flexible(
            child: Text(
              _getFileNameFromMessage() ?? '未知文件',
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemMessage(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
        padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Text(
          _getTextFromMessage() ?? '',
          style: TextStyle(color: Colors.grey[700], fontSize: 12.0),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildTimeAndStatusRow() {
    final timeText = _formatMessageTimeSync(message.createdAt);

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          timeText,
          style: TextStyle(
            fontSize: 11.0,
            color: Colors.grey[600],
          ),
        ),
        // 只有私聊的当前用户消息才显示阅读状态
        if (isCurrentUser && isNotGroupChat) ...[
          const SizedBox(width: 4.0),
          _buildMessageStatusIcon(),
        ],
      ],
    );
  }

  Widget _buildMessageStatusIcon() {
    if (displayStatus != null) {
      return _buildStatusIcon(
        displayStatus!.messageStatus,
        displayStatus!.isDelivered,
        displayStatus!.isRead,
      );
    }

    return _buildStatusIcon(message.messageStatus, false, false);
  }

  Widget _buildStatusIcon(String status, bool isDelivered, bool isRead) {
    switch (status) {
      case 'SENDING':
        return Icon(Icons.schedule, size: 14.0, color: Colors.grey[600]);
      case 'SENT':
        if (isRead) {
          return const Icon(Icons.done_all, size: 14.0, color: AppColors.primary);
        } else if (isDelivered) {
          return Icon(Icons.done_all, size: 14.0, color: Colors.grey[600]);
        } else {
          return Icon(Icons.done, size: 14.0, color: Colors.grey[600]);
        }
      case 'FAILED':
        return const Icon(Icons.error_outline, size: 14.0, color: Colors.red);
      case 'DELETED':
        return const Icon(Icons.delete_outline, size: 14.0, color: Colors.orange);
      case 'REVOKED':
        return const Icon(Icons.undo, size: 14.0, color: Colors.orange);
      default:
        return const SizedBox.shrink();
    }
  }

  /// 构建被回复的消息显示
  Widget _buildQuotedMessage(BuildContext context) {
    final quotedSenderName = _getQuotedMessageSenderName();
    final quotedPreview = _getQuotedMessagePreview();

    // 计算自适应宽度，基于内容长度和屏幕宽度
    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth = screenWidth * 0.7; // 最大宽度为屏幕宽度的70%
    final minWidth = screenWidth * 0.3; // 最小宽度为屏幕宽度的30%

    // 根据内容长度估算宽度
    final contentLength = quotedSenderName.length + quotedPreview.length;
    double estimatedWidth = (contentLength * 8.0) + 60.0; // 每个字符约8像素 + 内边距

    // 限制在最小和最大宽度之间
    estimatedWidth = estimatedWidth.clamp(minWidth, maxWidth);

    return Container(
      margin: const EdgeInsets.only(bottom: 6.0),
      child: IntrinsicWidth(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: minWidth,
            maxWidth: maxWidth,
          ),
          child: Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8.0),
              border: Border(
                left: BorderSide(
                  color: isCurrentUser ? AppColors.primary : Colors.grey[400]!,
                  width: 3.0,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.reply,
                      size: 12.0,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4.0),
                    Flexible(
                      child: Text(
                        quotedSenderName,
                        style: TextStyle(
                          fontSize: 11.0,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2.0),
                Text(
                  quotedPreview,
                  style: TextStyle(
                    fontSize: 13.0,
                    color: Colors.grey[700],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 获取被回复消息发送者的名称
  String _getQuotedMessageSenderName() {
    if (message.quotedMessageId == null || getQuotedMessage == null) {
      return '未知用户';
    }

    try {
      final quotedMessage = getQuotedMessage!(message.quotedMessageId!);
      if (quotedMessage == null) {
        return '未知用户';
      }

      return quotedMessage.senderName ?? '未知用户';
    } catch (e) {
      return '未知用户';
    }
  }

  /// 获取被回复消息的预览文本
  String _getQuotedMessagePreview() {
    if (message.quotedMessageId == null || getQuotedMessage == null) {
      return '原始消息内容...';
    }

    try {
      final quotedMessage = getQuotedMessage!(message.quotedMessageId!);
      if (quotedMessage == null) {
        return '消息已删除或不存在';
      }

      // 根据消息类型返回不同的预览文本
      switch (quotedMessage.messageType) {
        case 'TEXT':
          final text = MessageAdapter.extractTextFromContent(quotedMessage.content);
          return text?.isNotEmpty == true ? text! : '[文本消息]';
        case 'IMAGE':
          return '[图片]';
        case 'VIDEO':
          return '[视频]';
        case 'VOICE':
          return '[语音]';
        case 'FILE':
          final mediaInfo = MessageAdapter.extractMediaInfo(quotedMessage.content);
          final fileName = mediaInfo?['file_name'] as String?;
          return fileName != null ? '[文件] $fileName' : '[文件]';
        case 'SYSTEM':
          final text = MessageAdapter.extractTextFromContent(quotedMessage.content);
          return text?.isNotEmpty == true ? text! : '[系统消息]';
        default:
          return '[未知消息类型]';
      }
    } catch (e) {
      return '获取消息失败';
    }
  }

  /// 同步时间格式化方法，避免FutureBuilder导致的布局跳变
  String _formatMessageTimeSync(DateTime timestamp) {
    try {
      // 使用简单的本地时间格式化，避免异步操作
      final now = DateTime.now();
      final localTime = timestamp.toLocal();

      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final messageDate = DateTime(localTime.year, localTime.month, localTime.day);

      String formattedTime;
      if (messageDate == today) {
        // 今天：只显示时间
        formattedTime = '${localTime.hour.toString().padLeft(2, '0')}:${localTime.minute.toString().padLeft(2, '0')}';
      } else if (messageDate == yesterday) {
        // 昨天：显示"昨天 HH:mm"
        formattedTime = '昨天 ${localTime.hour.toString().padLeft(2, '0')}:${localTime.minute.toString().padLeft(2, '0')}';
      } else if (now.difference(messageDate).inDays < 7) {
        // 一周内：显示"星期X HH:mm"
        final weekdays = ['星期一', '星期二', '星期三', '星期四', '星期五', '星期六', '星期日'];
        final weekday = weekdays[localTime.weekday - 1];
        formattedTime = '$weekday ${localTime.hour.toString().padLeft(2, '0')}:${localTime.minute.toString().padLeft(2, '0')}';
      } else if (localTime.year == now.year) {
        // 今年：显示"MM月dd日 HH:mm"
        formattedTime = '${localTime.month}月${localTime.day}日 ${localTime.hour.toString().padLeft(2, '0')}:${localTime.minute.toString().padLeft(2, '0')}';
      } else {
        // 更早：显示"yyyy年MM月dd日 HH:mm"
        formattedTime = '${localTime.year}年${localTime.month}月${localTime.day}日 ${localTime.hour.toString().padLeft(2, '0')}:${localTime.minute.toString().padLeft(2, '0')}';
      }

      return formattedTime;
    } catch (e) {
      // 格式化失败时返回简单格式
      final localTime = timestamp.toLocal();
      final simpleFormat = '${localTime.hour.toString().padLeft(2, '0')}:${localTime.minute.toString().padLeft(2, '0')}';

      return simpleFormat;
    }
  }
}

class _MessageMenuAction {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _MessageMenuAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });
}
