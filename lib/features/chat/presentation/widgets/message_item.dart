import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cc/core/database/models/message.dart';
import 'package:intl/intl.dart';
import 'voice_message_widget.dart';
import 'image_message_widget.dart';
import 'video_message_widget.dart';

/// 消息显示状态
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
class MessageItem extends StatelessWidget {
  final Message message;
  final bool isCurrentUser;
  final bool showAvatar;
  final bool showTail;
  final bool isPrivateChat;
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

  const MessageItem({
    super.key,
    required this.message,
    required this.isCurrentUser,
    this.showAvatar = true,
    this.showTail = true,
    this.isPrivateChat = false,
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
  });

  @override
  Widget build(BuildContext context) {
    if (message.type == MessageType.system ||
        message.type == MessageType.membership) {
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
          mainAxisAlignment:
              isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isCurrentUser) ...[
              if (!isPrivateChat && showAvatar)
                _buildAvatar()
              else if (!isPrivateChat)
                const SizedBox(width: 32.0),
              const SizedBox(width: 8.0),
            ],
            Flexible(child: _buildMessageBubble(context)),
            if (isCurrentUser) const SizedBox(width: 8.0),
          ],
        ),
      ),
    );
  }

  void _showContextMenu(BuildContext context) {
    HapticFeedback.lightImpact();
    // print('🔥 MessageItem: 显示长按菜单');

    if (onLongPress == null &&
        onRevoke == null &&
        onDelete == null &&
        onReply == null &&
        onForward == null &&
        onCopy == null) {
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
                          color: action.isDestructive
                              ? Colors.red
                              : Colors.black87,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      action.icon,
                      size: 18,
                      color:
                          action.isDestructive ? Colors.red : Colors.grey[600],
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

    if (onReply != null && !message.isMessageDeleted) {
      actions.add(_MessageMenuAction(
        icon: Icons.reply,
        label: '回复',
        onTap: onReply!,
      ));
    }

    if (onForward != null &&
        !message.isMessageDeleted &&
        message.type != MessageType.system &&
        message.type != MessageType.membership) {
      actions.add(_MessageMenuAction(
        icon: Icons.forward,
        label: '转发',
        onTap: onForward!,
      ));
    }

    if (onCopy != null &&
        message.type == MessageType.text &&
        !message.isMessageDeleted &&
        !message.isMessageRevoked &&
        (message.text?.isNotEmpty ?? false)) {
      actions.add(_MessageMenuAction(
        icon: Icons.copy,
        label: '复制',
        onTap: onCopy!,
      ));
    }

    if (onRevoke != null &&
        isCurrentUser &&
        !message.isMessageRevoked &&
        !message.isMessageDeleted &&
        message.type != MessageType.system &&
        message.type != MessageType.membership) {
      actions.add(_MessageMenuAction(
        icon: Icons.undo,
        label: '撤回',
        onTap: onRevoke!,
        isDestructive: true,
      ));
    }

    if (onDelete != null &&
        isCurrentUser &&
        !message.isMessageDeleted &&
        message.type != MessageType.system &&
        message.type != MessageType.membership) {
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
              style:
                  const TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
            )
          : null,
    );
  }

  Widget _buildMessageBubble(BuildContext context) {
    Color? highlightBorderColor;
    double borderWidth = 0.0;

    if (isCurrentSearchResult) {
      highlightBorderColor = Colors.orange;
      borderWidth = 2.0;
    } else if (isSearchResult) {
      highlightBorderColor = Colors.blue.shade300;
      borderWidth = 1.5;
    }

    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.7,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color:
            isCurrentUser ? Theme.of(context).primaryColor : Colors.grey[200],
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
        border: highlightBorderColor != null
            ? Border.all(color: highlightBorderColor, width: borderWidth)
            : null,
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
          _buildTimeAndStatusRow(),
        ],
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context) {
    // 💢💢💢 如果消息已撤回，统一显示撤回提示，不管类型
    if (message.isMessageRevoked) {
      return Text(
        '此消息已被撤回',
        style: TextStyle(
          color: isCurrentUser ? Colors.white70 : Colors.grey[600],
          fontStyle: FontStyle.italic,
          fontSize: 14.0,
        ),
      );
    }

    // 💢💢💢 如果消息已删除，统一显示删除提示，不管类型
    if (message.isMessageDeleted) {
      return Text(
        '消息已删除',
        style: TextStyle(
          color: isCurrentUser ? Colors.white70 : Colors.grey[600],
          fontStyle: FontStyle.italic,
          fontSize: 14.0,
        ),
      );
    }

    switch (message.type) {
      case MessageType.text:
        return _buildTextContent(context);
      case MessageType.image:
        return ImageMessageWidget(
            message: message, isCurrentUser: isCurrentUser);
      case MessageType.video:
        return VideoMessageWidget(
            message: message, isCurrentUser: isCurrentUser);
      case MessageType.voice:
        return VoiceMessageWidget(
            message: message, isCurrentUser: isCurrentUser);
      case MessageType.file:
        return _buildFileContent(context);
      default:
        return _buildTextContent(context);
    }
  }

  Widget _buildTextContent(BuildContext context) {
    // 💢💢💢 撤回和删除处理已移至_buildMessageContent统一处理
    // 此方法只处理正常的文本显示
    return Text(
      message.text ?? '',
      style: TextStyle(
        color: isCurrentUser ? Colors.white : Colors.black87,
        fontSize: 16.0,
      ),
    );
  }

  Widget _buildFileContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: isCurrentUser ? Colors.white.withAlpha(51) : Colors.grey[100],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.file_present,
            color: isCurrentUser ? Colors.white : Colors.grey[600],
          ),
          const SizedBox(width: 8.0),
          Flexible(
            child: Text(
              message.fileName ?? '未知文件',
              style: TextStyle(
                color: isCurrentUser ? Colors.white : Colors.black87,
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
          message.text ?? '',
          style: TextStyle(color: Colors.grey[700], fontSize: 12.0),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildTimeAndStatusRow() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          _formatMessageTime(message.createdAt),
          style: TextStyle(
            fontSize: 11.0,
            color: isCurrentUser ? Colors.white70 : Colors.grey[600],
          ),
        ),
        if (isCurrentUser) ...[
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

    return _buildStatusIcon(message.status, false, false);
  }

  Widget _buildStatusIcon(MessageStatus status, bool isDelivered, bool isRead) {
    switch (status) {
      case MessageStatus.sending:
        return const Icon(Icons.schedule, size: 14.0, color: Colors.white70);
      case MessageStatus.sent:
        if (isRead) {
          return const Icon(Icons.done_all, size: 14.0, color: Colors.blue);
        } else if (isDelivered) {
          return const Icon(Icons.done_all, size: 14.0, color: Colors.white70);
        } else {
          return const Icon(Icons.done, size: 14.0, color: Colors.white70);
        }
      case MessageStatus.failed:
        return const Icon(Icons.error_outline, size: 14.0, color: Colors.red);
      case MessageStatus.deleted:
        return const Icon(Icons.delete_outline,
            size: 14.0, color: Colors.orange);
      case MessageStatus.revoked:
        return const Icon(Icons.undo, size: 14.0, color: Colors.orange);
      default:
        return const SizedBox.shrink();
    }
  }

  String _formatMessageTime(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate =
        DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (messageDate == today) {
      return DateFormat('HH:mm').format(timestamp);
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return '昨天 ${DateFormat('HH:mm').format(timestamp)}';
    } else if (timestamp.year == now.year) {
      return DateFormat('MM/dd HH:mm').format(timestamp);
    } else {
      return DateFormat('yyyy/MM/dd HH:mm').format(timestamp);
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
