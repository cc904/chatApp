import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cc/core/database/models/message.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:cc/core/services/log_service.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'voice_message_widget.dart';
import 'image_message_widget.dart';
import 'video_message_widget.dart';

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

    // 🆕 系统消息和成员变动消息使用特殊样式：居中显示，无头像，无气泡
    if (message.type == MessageType.system ||
        message.type == MessageType.membership) {
      return _buildSystemMessage(context);
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
          _buildMessageContentWithTime(context),
        ],
      ),
    );
  }

  /// 构建消息内容和时间（智能布局）
  Widget _buildMessageContentWithTime(BuildContext context) {
    // 对于文本消息，尝试将时间显示在同一行
    if (message.type == MessageType.text) {
      return _buildTextMessageWithInlineTime(context);
    }

    // 对于其他类型的消息，使用传统的分行布局
    return Column(
      crossAxisAlignment:
          isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        _buildMessageContent(context),
        const SizedBox(height: 2.0),
        _buildTimeAndStatusRow(),
      ],
    );
  }

  /// 构建文本消息的内联时间布局
  Widget _buildTextMessageWithInlineTime(BuildContext context) {
    final messageText = message.text ?? '';

    // 计算消息文本的宽度
    final textPainter = TextPainter(
      text: TextSpan(
        text: messageText,
        style: TextStyle(
          fontSize: 14.0,
          color: isCurrentUser ? Colors.white : Colors.black87,
        ),
      ),
      maxLines: null,
      textDirection: Directionality.of(context),
    );
    textPainter.layout(maxWidth: MediaQuery.of(context).size.width * 0.6);

    // 计算时间和状态的宽度
    final timeText = _formatTime(message.createdAt);
    final timeAndStatusPainter = TextPainter(
      text: TextSpan(
        text:
            '${message.isMessageEdited ? '已编辑 ' : ''}$timeText${isCurrentUser ? ' ✓' : ''}',
        style: TextStyle(
          fontSize: 11.0,
          color: isCurrentUser ? Colors.white.withAlpha(179) : Colors.grey[600],
        ),
      ),
      textDirection: Directionality.of(context),
    );
    timeAndStatusPainter.layout();

    // 判断是否可以在同一行显示
    final maxWidth = MediaQuery.of(context).size.width * 0.6;
    final canInline =
        textPainter.width + timeAndStatusPainter.width + 16 <= maxWidth &&
            textPainter.height <= 20; // 单行文本的高度大约是20

    if (canInline) {
      // 在同一行显示文本和时间
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: _buildHighlightedText(
              messageText,
              baseStyle: TextStyle(
                fontSize: 14.0,
                color: isCurrentUser ? Colors.white : Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          _buildTimeAndStatusRow(),
        ],
      );
    } else {
      // 分行显示
      return Column(
        crossAxisAlignment:
            isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          _buildHighlightedText(
            messageText,
            baseStyle: TextStyle(
              fontSize: 14.0,
              color: isCurrentUser ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 2.0),
          _buildTimeAndStatusRow(),
        ],
      );
    }
  }

  /// 构建时间和状态行
  Widget _buildTimeAndStatusRow() {
    return Row(
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
            color:
                isCurrentUser ? Colors.white.withAlpha(179) : Colors.grey[600],
          ),
        ),
        // 💢💢💢 将已读状态移到时间后面（仅当前用户消息显示）
        if (isCurrentUser) ...[
          const SizedBox(width: 4.0),
          _buildMessageStatusInline(),
        ],
      ],
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
            ImageMessageWidget(
              message: message,
              isCurrentUser: isCurrentUser,
              maxWidth: MediaQuery.of(context).size.width * 0.6,
              maxHeight: MediaQuery.of(context).size.height * 0.4,
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
        return VoiceMessageWidget(
          message: message,
          isCurrentUser: isCurrentUser,
        );

      case MessageType.video:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            VideoMessageWidget(
              message: message,
              isCurrentUser: isCurrentUser,
              maxWidth: MediaQuery.of(context).size.width * 0.6,
              maxHeight: MediaQuery.of(context).size.height * 0.4,
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
        return GestureDetector(
          onTap: () => _showFileDetailsDialog(context),
          child: Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: isCurrentUser
                  ? Colors.white.withAlpha(25)
                  : Colors.grey.withAlpha(25),
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: isCurrentUser
                    ? Colors.white.withAlpha(76)
                    : Colors.grey.withAlpha(76),
                width: 1.0,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.insert_drive_file,
                  color: isCurrentUser ? Colors.white : Colors.grey[700],
                  size: 24.0,
                ),
                const SizedBox(width: 12.0),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.fileName ?? '未知文件',
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                          color: isCurrentUser ? Colors.white : Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2.0),
                      Row(
                        children: [
                          if (message.fileSize != null) ...[
                            Text(
                              _formatFileSize(message.fileSize!),
                              style: TextStyle(
                                fontSize: 12.0,
                                color: isCurrentUser
                                    ? Colors.white.withAlpha(179)
                                    : Colors.grey[600],
                              ),
                            ),
                            const SizedBox(width: 8.0),
                          ],
                          Text(
                            '点击查看',
                            style: TextStyle(
                              fontSize: 11.0,
                              color: isCurrentUser
                                  ? Colors.white.withAlpha(153)
                                  : Colors.blue[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8.0),
                Icon(
                  Icons.arrow_forward_ios,
                  color: isCurrentUser
                      ? Colors.white.withAlpha(153)
                      : Colors.grey[500],
                  size: 16.0,
                ),
              ],
            ),
          ),
        );

      case MessageType.system:
      case MessageType.membership:
        // 这些消息类型在build方法中已经被特殊处理，不会到达这里
        return const SizedBox.shrink();
    }
  }

  /// 格式化时间
  String _formatTime(DateTime dateTime) {
    // 只显示时间点，不显示日期信息
    return DateFormat('HH:mm').format(dateTime);
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

  /// 🆕 构建系统消息（居中小字样式，无头像无气泡）
  Widget _buildSystemMessage(BuildContext context) {
    Widget content;

    if (message.type == MessageType.membership) {
      content = _buildMembershipMessageContent();
    } else {
      // 普通系统消息
      content = Text(
        message.displayText,
        style: TextStyle(
          fontSize: 11.0,
          color: Colors.grey[600],
          fontStyle: FontStyle.normal,
        ),
        textAlign: TextAlign.center,
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
          decoration: BoxDecoration(
            color: const Color(0xFFE7F3E7), // 使用和聊天背景相同的淡绿色
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: content,
        ),
      ),
    );
  }

  /// 🆕 构建成员变动消息内容
  Widget _buildMembershipMessageContent() {
    // 解析成员变动信息
    final eventType = message.membershipEventType ?? 'MEMBER_JOINED';
    final actorInfo = message.membershipActorMap;
    final affectedMembers = message.membershipAffectedMembersList;

    // 构建显示文本
    String displayText = '';

    final actorName = actorInfo?['userName'] ?? '未知用户';
    final affectedNames =
        affectedMembers.map((member) => member['userName'] ?? '未知用户').join('、');

    switch (eventType) {
      case 'MEMBER_JOINED':
        displayText = affectedMembers.length > 1
            ? '$actorName 邀请 $affectedNames 加入了群聊'
            : '$affectedNames 加入了群聊';
        break;
      case 'MEMBER_LEFT':
        displayText = '$affectedNames 离开了群聊';
        break;
      case 'MEMBER_REMOVED':
        displayText = '$actorName 将 $affectedNames 移出了群聊';
        break;
      case 'MEMBER_PROMOTED':
        displayText = '$actorName 将 $affectedNames 提升为管理员';
        break;
      case 'MEMBER_DEMOTED':
        displayText = '$actorName 将 $affectedNames 降级为普通成员';
        break;
      case 'CONVERSATION_CREATED':
        displayText = '$actorName 创建了群聊';
        break;
      case 'CONVERSATION_NAME_CHANGED':
        displayText = '$actorName 修改了群聊名称';
        break;
      case 'CONVERSATION_AVATAR_CHANGED':
        displayText = '$actorName 更换了群聊头像';
        break;
      default:
        displayText = message.text ?? '未知事件';
    }

    // 成员变动消息使用简洁的文本样式，不显示图标
    return Text(
      displayText,
      style: TextStyle(
        fontSize: 13.0,
        color: Colors.grey[600],
        fontStyle: FontStyle.italic,
      ),
      textAlign: TextAlign.center,
    );
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

  void _showFileDetailsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _FileDetailsDialog(message: message),
    );
  }
}

/// 文件详情对话框
class _FileDetailsDialog extends StatefulWidget {
  final Message message;

  const _FileDetailsDialog({required this.message});

  @override
  State<_FileDetailsDialog> createState() => _FileDetailsDialogState();
}

class _FileDetailsDialogState extends State<_FileDetailsDialog> {
  bool _isDownloading = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 标题栏
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                border:
                    Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue, size: 24),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      '文件详情',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    style: IconButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(32, 32),
                    ),
                  ),
                ],
              ),
            ),

            // 文件信息
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 文件图标
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey.withAlpha(25),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: Colors.grey.withAlpha(51), width: 2),
                      ),
                      child: const Icon(Icons.insert_drive_file,
                          size: 40, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),

                    // 文件信息表格
                    _buildInfoTable(),
                  ],
                ),
              ),
            ),

            // 操作按钮
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('关闭'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isDownloading ? null : _downloadFile,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      icon: _isDownloading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.download, size: 18),
                      label: Text(_isDownloading ? '下载中...' : '下载'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.withAlpha(12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withAlpha(25)),
      ),
      child: Column(
        children: [
          _buildInfoRow('文件名', widget.message.fileName ?? '未知文件'),
          _buildDivider(),
          _buildInfoRow('文件大小', _formatFileSize(widget.message.fileSize ?? 0)),
          _buildDivider(),
          _buildInfoRow('文件类型', 'FILE'),
          _buildDivider(),
          _buildInfoRow('发送时间', _formatDateTime(widget.message.createdAt)),
          if (widget.message.mediaUrl != null) ...[
            _buildDivider(),
            _buildInfoRow('下载链接', '可用', isStatus: true),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isStatus = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: isStatus
                ? Row(
                    children: [
                      Icon(Icons.check_circle,
                          size: 16, color: Colors.green[600]),
                      const SizedBox(width: 6),
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.green[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  )
                : Text(
                    value,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey.withAlpha(25),
      indent: 16,
      endIndent: 16,
    );
  }

  String _formatFileSize(double bytes) {
    if (bytes < 1024) {
      return '${bytes.toStringAsFixed(0)} B';
    } else if (bytes < 1024 * 1024) {
      final sizeInKB = bytes / 1024;
      return '${sizeInKB.toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      final sizeInMB = bytes / (1024 * 1024);
      return '${sizeInMB.toStringAsFixed(1)} MB';
    } else {
      final sizeInGB = bytes / (1024 * 1024 * 1024);
      return '${sizeInGB.toStringAsFixed(2)} GB';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _downloadFile() async {
    final logger = LogService.instance;

    logger.i('开始下载文件');
    logger.i('文件URL: ${widget.message.mediaUrl}');
    logger.i('文件名: ${widget.message.fileName}');

    // 如果没有真实URL，使用测试文件URL来验证下载功能
    String? downloadUrl = widget.message.mediaUrl;
    if (downloadUrl == null || downloadUrl.isEmpty) {
      logger.w('使用测试URL进行下载演示');
      downloadUrl = 'https://httpbin.org/bytes/1024'; // 1KB测试文件
    }

    setState(() {
      _isDownloading = true;
    });

    try {
      // 先进行 HEAD 请求测试连通性
      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(minutes: 10),
        sendTimeout: const Duration(seconds: 15),
        headers: {
          'User-Agent': 'Flutter App',
        },
      ));
      try {
        logger.i('开始 HEAD 请求测试连通性');
        final headResponse = await dio.head(downloadUrl);
        logger.i(
            'HEAD 状态码: ${headResponse.statusCode}, Content-Length: ${headResponse.headers.value('content-length')}');
      } catch (e) {
        logger.w('HEAD 请求失败: $e');
      }

      logger.i('开始真正下载...');

      // 使用dio.download直接写文件，避免内存占用
      final Directory? downloadsDir = await getDownloadsDirectory();
      Directory targetDir;

      if (downloadsDir != null) {
        targetDir = downloadsDir;
        logger.i('使用系统下载目录: ${targetDir.path}');
      } else {
        // 回退到应用文档目录
        targetDir = await getApplicationDocumentsDirectory();
        logger.i('回退到应用文档目录: ${targetDir.path}');
      }

      // 创建文件名及路径
      String fileName = widget.message.fileName ?? 'downloaded_file';
      if (!fileName.contains('.')) {
        fileName += '.bin';
      }
      final String filePath = '${targetDir.path}/$fileName';
      logger.i('保存路径: $filePath');

      await dio.download(
        downloadUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            final percent = (received / total * 100).toStringAsFixed(1);
            logger.i('下载进度: $percent% ($received/$total bytes)');
          } else {
            logger.i('已下载: $received bytes (总大小未知)');
          }
        },
      );

      logger.i('文件下载并保存成功');

      if (mounted) {
        Navigator.of(context).pop();
        _showSuccessSnackBar('文件已保存到: ${targetDir.path}');
        HapticFeedback.lightImpact();
      }
    } catch (e, stackTrace) {
      logger.e('下载失败: $e', error: e, stackTrace: stackTrace);
      if (mounted) {
        _showErrorSnackBar('下载失败: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
