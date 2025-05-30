# 聊天UI实现详细设计方案 v1.0

## 概述

本文档详细描述了Flutter WhatsApp克隆项目中聊天页面UI的完整实现方案，包括消息气泡、操作菜单、状态处理、动画效果等所有UI组件的设计和实现。

## 设计目标

- **功能完整性**：支持撤销、引用、删除、编辑等所有消息操作
- **用户体验**：流畅的动画、直观的交互、清晰的状态反馈
- **性能优化**：虚拟化列表、懒加载、高效渲染
- **可扩展性**：易于添加新消息类型和功能
- **响应式设计**：适配各种屏幕尺寸

## 核心架构设计

### 1. 消息状态扩展模型

```dart
// lib/core/database/models/message.dart 新增字段
@collection
class Message {
  // ... 现有字段 ...
  
  // 消息状态扩展
  bool isDeleted = false;              // 是否已删除
  bool isRevoked = false;              // 是否已撤销
  bool isEdited = false;               // 是否已编辑
  DateTime? editedAt;                  // 编辑时间
  DateTime? revokedAt;                 // 撤销时间
  DateTime? deletedAt;                 // 删除时间
  String? originalText;                // 编辑前的原始文本
  
  // 引用消息详细信息（缓存，避免查询）
  String? quotedMessageText;          // 被引用消息的文本内容
  String? quotedMessageSenderName;    // 被引用消息发送者名称
  String? quotedMessageType;          // 被引用消息类型
  
  // 回复和转发
  String? repliedToMessageId;         // 回复的消息ID
  String? forwardedFromConversationId; // 转发来源会话ID
  String? forwardedFromMessageId;     // 转发来源消息ID
  
  // 消息反应（点赞、表情等）
  Map<String, List<String>>? reactions; // 反应类型 -> 用户ID列表
  
  // 消息优先级和标记
  String priority = 'normal';         // 消息优先级: urgent, high, normal, low
  List<String>? tags;                 // 消息标签
  bool isPinned = false;              // 是否置顶
  
  // 临时状态（仅UI使用，不存储）
  @ignore bool isHighlighted = false; // 是否高亮显示
  @ignore bool isSelected = false;    // 是否被选中
  @ignore bool isPlaying = false;     // 语音/视频是否在播放
  @ignore double? uploadProgress;     // 上传进度
}
```

### 2. 消息类型枚举扩展

```dart
// lib/core/constants/message_types.dart
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
  static const String recalled = 'recalled';      // 撤销消息
  static const String deleted = 'deleted';        // 删除消息
  static const String edited = 'edited';          // 编辑消息
  static const String reply = 'reply';            // 回复消息
  static const String forward = 'forward';        // 转发消息
  
  // 富媒体类型
  static const String sticker = 'sticker';        // 表情包
  static const String gif = 'gif';               // GIF动图
  static const String contact = 'contact';        // 联系人名片
  static const String poll = 'poll';             // 投票
  static const String link = 'link';             // 链接预览
}
```

## 核心UI组件设计

### 1. 高级消息气泡组件

```dart
// lib/features/chat/presentation/widgets/advanced_message_bubble.dart
class AdvancedMessageBubble extends StatefulWidget {
  final Message message;
  final bool isMe;
  final String currentUserId;
  final Message? quotedMessage;     // 被引用的消息
  final Message? repliedMessage;    // 被回复的消息
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onQuoteTap;   // 点击引用消息
  final Function(String)? onUserMentionTap; // 点击用户@
  final Function(String)? onReaction; // 添加反应
  final bool showSenderInfo;        // 是否显示发送者信息
  final bool isHighlighted;         // 是否高亮
  final bool isSelected;            // 是否被选中
  
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
    
    // 选中动画控制器
    _selectionController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _highlightAnimation = ColorTween(
      begin: Colors.transparent,
      end: Colors.yellow.withAlpha(128),
    ).animate(CurvedAnimation(
      parent: _highlightController,
      curve: Curves.easeInOut,
    ));
    
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
    
    // 处理选中状态变化
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _selectionController.forward();
      } else {
        _selectionController.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 处理撤销消息
    if (widget.message.isRevoked) {
      return _buildRevokedMessage();
    }
    
    // 处理删除消息（仅发送者可见）
    if (widget.message.isDeleted && !widget.isMe) {
      return const SizedBox.shrink(); // 对其他人不可见
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
        mainAxisAlignment: widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 左侧时间（非自己的消息）
          if (!widget.isMe) _buildTimestamp(),
          
          // 主要消息内容
          Flexible(
            child: Column(
              crossAxisAlignment: widget.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // 回复消息引用
                if (widget.message.quotedMessageId != null) 
                  _buildQuotedMessage(),
                
                // 主消息气泡
                _buildMainBubble(),
                
                // 消息反应
                if (widget.message.reactions?.isNotEmpty == true)
                  _buildReactions(),
                
                // 消息状态指示器
                if (widget.isMe) _buildMessageStatus(),
              ],
            ),
          ),
          
          // 右侧时间（自己的消息）
          if (widget.isMe) _buildTimestamp(),
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
                widget.isMe ? '你撤回了一条消息' : '${widget.message.senderName ?? "对方"}撤回了一条消息',
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
            if (widget.message.quotedMessageSenderName != null)
              Text(
                widget.message.quotedMessageSenderName!,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: widget.isMe ? Colors.white70 : Colors.blue,
                ),
              ),
            Text(
              widget.message.quotedMessageText ?? '[${widget.message.quotedMessageType ?? '消息'}]',
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

  // 消息反应显示
  Widget _buildReactions() {
    final reactions = widget.message.reactions!;
    
    return Container(
      margin: const EdgeInsets.only(top: 4),
      child: Wrap(
        spacing: 4,
        runSpacing: 2,
        children: reactions.entries.map((entry) {
          final emoji = entry.key;
          final users = entry.value;
          final hasMyReaction = users.contains(widget.currentUserId);
          
          return GestureDetector(
            onTap: () => widget.onReaction?.call(emoji),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: hasMyReaction ? Colors.blue.withAlpha(51) : Colors.grey.withAlpha(51),
                borderRadius: BorderRadius.circular(12),
                border: hasMyReaction ? Border.all(color: Colors.blue, width: 1) : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 14)),
                  if (users.length > 1) ...[
                    const SizedBox(width: 2),
                    Text(
                      users.length.toString(),
                      style: TextStyle(
                        fontSize: 10,
                        color: hasMyReaction ? Colors.blue : Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // 其他辅助方法实现...
  Widget _buildMainBubble() { /* 实现主气泡 */ return Container(); }
  Widget _buildTimestamp() { /* 实现时间戳 */ return Container(); }
  Widget _buildMessageStatus() { /* 实现状态指示 */ return Container(); }
}
```

### 2. 消息操作菜单

```dart
// lib/features/chat/presentation/widgets/message_action_menu.dart
class MessageActionMenu extends StatelessWidget {
  final Message message;
  final bool isMe;
  final VoidCallback? onReply;
  final VoidCallback? onQuote;
  final VoidCallback? onForward;
  final VoidCallback? onCopy;
  final VoidCallback? onEdit;
  final VoidCallback? onRevoke;
  final VoidCallback? onDelete;
  final VoidCallback? onPin;
  final VoidCallback? onSelect;
  final Function(String)? onReaction;

  const MessageActionMenu({
    super.key,
    required this.message,
    required this.isMe,
    this.onReply,
    this.onQuote,
    this.onForward,
    this.onCopy,
    this.onEdit,
    this.onRevoke,
    this.onDelete,
    this.onPin,
    this.onSelect,
    this.onReaction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(51),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 快速反应表情行
          _buildQuickReactions(),
          
          Divider(height: 1, color: Colors.grey[300]),
          
          // 操作按钮列表
          ..._buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildQuickReactions() {
    const reactions = ['👍', '❤️', '😂', '😮', '😢', '😠'];
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: reactions.map((emoji) {
          return GestureDetector(
            onTap: () => onReaction?.call(emoji),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.withAlpha(51),
              ),
              child: Text(emoji, style: const TextStyle(fontSize: 20)),
            ),
          );
        }).toList(),
      ),
    );
  }

  List<Widget> _buildActionButtons(BuildContext context) {
    final actions = <Widget>[];

    // 回复
    actions.add(_buildActionButton(
      icon: Icons.reply,
      text: '回复',
      onTap: onReply,
    ));

    // 引用
    actions.add(_buildActionButton(
      icon: Icons.format_quote,
      text: '引用',
      onTap: onQuote,
    ));

    // 转发
    actions.add(_buildActionButton(
      icon: Icons.forward,
      text: '转发',
      onTap: onForward,
    ));

    // 复制（仅文本消息）
    if (message.type == MessageType.text && message.text?.isNotEmpty == true) {
      actions.add(_buildActionButton(
        icon: Icons.copy,
        text: '复制',
        onTap: onCopy,
      ));
    }

    // 编辑（仅自己的文本消息，且在一定时间内）
    if (isMe && message.type == MessageType.text && _canEdit()) {
      actions.add(_buildActionButton(
        icon: Icons.edit,
        text: '编辑',
        onTap: onEdit,
      ));
    }

    // 撤销（仅自己的消息，且在一定时间内）
    if (isMe && _canRevoke()) {
      actions.add(_buildActionButton(
        icon: Icons.undo,
        text: '撤销',
        onTap: onRevoke,
        isDestructive: true,
      ));
    }

    // 删除
    actions.add(_buildActionButton(
      icon: Icons.delete,
      text: isMe ? '删除' : '删除（仅自己可见）',
      onTap: onDelete,
      isDestructive: true,
    ));

    // 置顶/取消置顶
    actions.add(_buildActionButton(
      icon: message.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
      text: message.isPinned ? '取消置顶' : '置顶',
      onTap: onPin,
    ));

    // 选择
    actions.add(_buildActionButton(
      icon: Icons.check_circle_outline,
      text: '选择',
      onTap: onSelect,
    ));

    return actions;
  }

  Widget _buildActionButton({
    required IconData icon,
    required String text,
    VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      dense: true,
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : Colors.grey[700],
        size: 20,
      ),
      title: Text(
        text,
        style: TextStyle(
          color: isDestructive ? Colors.red : Colors.black87,
          fontSize: 14,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        onTap?.call();
      },
    );
  }

  bool _canEdit() {
    // 24小时内的消息可以编辑
    return DateTime.now().difference(message.createdAt).inHours < 24;
  }

  bool _canRevoke() {
    // 24小时内的消息可以撤销
    return DateTime.now().difference(message.createdAt).inHours < 24;
  }
}
```

### 3. 智能消息分组Timeline

```dart
// lib/features/chat/presentation/widgets/message_timeline.dart
class MessageTimeline extends StatelessWidget {
  final List<Message> messages;
  final String currentUserId;
  final Message? highlightedMessage;
  final Function(Message)? onMessageTap;
  final Function(Message)? onMessageLongPress;
  final Function(String)? onQuoteTap;
  final ScrollController? scrollController;

  const MessageTimeline({
    super.key,
    required this.messages,
    required this.currentUserId,
    this.highlightedMessage,
    this.onMessageTap,
    this.onMessageLongPress,
    this.onQuoteTap,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      reverse: true,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _getGroupedMessages().length,
      itemBuilder: (context, index) {
        final group = _getGroupedMessages()[index];
        return _buildMessageGroup(group);
      },
    );
  }

  List<MessageGroup> _getGroupedMessages() {
    final groups = <MessageGroup>[];
    MessageGroup? currentGroup;

    for (int i = 0; i < messages.length; i++) {
      final message = messages[i];
      final prevMessage = i > 0 ? messages[i - 1] : null;
      
      // 判断是否需要新建组
      if (_shouldStartNewGroup(message, prevMessage)) {
        // 保存当前组
        if (currentGroup != null) {
          groups.add(currentGroup);
        }
        
        // 创建新组
        currentGroup = MessageGroup(
          senderId: message.senderId,
          senderName: message.senderName,
          senderAvatar: message.senderAvatar,
          messages: [message],
          startTime: message.createdAt,
        );
      } else {
        // 添加到当前组
        currentGroup?.messages.add(message);
      }
    }
    
    // 添加最后一组
    if (currentGroup != null) {
      groups.add(currentGroup);
    }
    
    return groups.reversed.toList(); // 反向以适应reverse ListView
  }

  bool _shouldStartNewGroup(Message current, Message? previous) {
    if (previous == null) return true;
    
    // 不同发送者
    if (current.senderId != previous.senderId) return true;
    
    // 时间间隔超过5分钟
    if (current.createdAt.difference(previous.createdAt).inMinutes > 5) return true;
    
    // 系统消息总是单独成组
    if (current.type == MessageType.system) return true;
    
    // 撤销或删除的消息单独成组
    if (current.isRevoked || current.isDeleted) return true;
    
    return false;
  }

  Widget _buildMessageGroup(MessageGroup group) {
    return Column(
      children: [
        // 时间分隔符
        _buildTimeSeparator(group.startTime),
        
        // 消息组
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: group.senderId == currentUserId 
                ? CrossAxisAlignment.end 
                : CrossAxisAlignment.start,
            children: [
              // 发送者信息（群聊中）
              if (_shouldShowSenderInfo(group))
                _buildSenderInfo(group),
              
              // 消息列表
              ...group.messages.asMap().entries.map((entry) {
                final index = entry.key;
                final message = entry.value;
                final isLast = index == group.messages.length - 1;
                
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: isLast ? 0 : 2,
                  ),
                  child: AdvancedMessageBubble(
                    message: message,
                    isMe: message.senderId == currentUserId,
                    currentUserId: currentUserId,
                    onTap: () => onMessageTap?.call(message),
                    onLongPress: () => onMessageLongPress?.call(message),
                    onQuoteTap: () => onQuoteTap?.call(message.quotedMessageId!),
                    showSenderInfo: false, // 在组级别显示
                    isHighlighted: message.messageId == highlightedMessage?.messageId,
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ],
    );
  }

  // 其他辅助方法...
}

class MessageGroup {
  final String senderId;
  final String? senderName;
  final String? senderAvatar;
  final List<Message> messages;
  final DateTime startTime;

  MessageGroup({
    required this.senderId,
    this.senderName,
    this.senderAvatar,
    required this.messages,
    required this.startTime,
  });
}
```

## 特殊功能组件

### 1. 消息编辑对话框

```dart
// lib/features/chat/presentation/widgets/message_edit_dialog.dart
class MessageEditDialog extends StatefulWidget {
  final Message message;
  final Function(String) onSave;

  const MessageEditDialog({
    super.key,
    required this.message,
    required this.onSave,
  });

  @override
  State<MessageEditDialog> createState() => _MessageEditDialogState();
}

class _MessageEditDialogState extends State<MessageEditDialog> {
  late TextEditingController _controller;
  bool _isChanged = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.message.text);
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {
      _isChanged = _controller.text.trim() != widget.message.text?.trim();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('编辑消息'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 原始消息预览
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.withAlpha(51),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.history, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '原消息: ${widget.message.text}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 编辑输入框
          TextField(
            controller: _controller,
            maxLines: null,
            maxLength: 1000,
            decoration: const InputDecoration(
              hintText: '输入新的消息内容...',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: _isChanged && _controller.text.trim().isNotEmpty
              ? () {
                  widget.onSave(_controller.text.trim());
                  Navigator.pop(context);
                }
              : null,
          child: const Text('保存'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

### 2. 消息选择工具栏

```dart
// lib/features/chat/presentation/widgets/message_selection_bar.dart
class MessageSelectionBar extends StatelessWidget {
  final int selectedCount;
  final VoidCallback? onSelectAll;
  final VoidCallback? onDeselectAll;
  final VoidCallback? onDelete;
  final VoidCallback? onForward;
  final VoidCallback? onCopy;
  final VoidCallback onCancel;

  const MessageSelectionBar({
    super.key,
    required this.selectedCount,
    this.onSelectAll,
    this.onDeselectAll,
    this.onDelete,
    this.onForward,
    this.onCopy,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      color: Colors.blue,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: onCancel,
          ),
          
          Expanded(
            child: Text(
              '已选择 $selectedCount 条消息',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          
          if (onSelectAll != null)
            IconButton(
              icon: const Icon(Icons.select_all, color: Colors.white),
              onPressed: onSelectAll,
            ),
          
          if (onCopy != null)
            IconButton(
              icon: const Icon(Icons.copy, color: Colors.white),
              onPressed: onCopy,
            ),
          
          if (onForward != null)
            IconButton(
              icon: const Icon(Icons.forward, color: Colors.white),
              onPressed: onForward,
            ),
          
          if (onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: onDelete,
            ),
        ],
      ),
    );
  }
}
```

## 性能优化组件

### 1. 虚拟化消息列表

```dart
// lib/features/chat/presentation/widgets/virtualized_message_list.dart
class VirtualizedMessageList extends StatelessWidget {
  final MessageTimeline timeline;
  final int visibleStart;
  final int visibleEnd;
  final String currentUserId;

  const VirtualizedMessageList({
    super.key,
    required this.timeline,
    required this.visibleStart,
    required this.visibleEnd,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    // 只渲染可见范围内的消息
    final visibleMessages = timeline.getRange(visibleStart, visibleEnd);
    
    return ListView.builder(
      itemCount: visibleMessages.length,
      itemBuilder: (context, index) {
        final message = visibleMessages[index];
        return AdvancedMessageBubble(
          message: message,
          isMe: message.senderId == currentUserId,
          currentUserId: currentUserId,
          // ... 其他参数
        );
      },
    );
  }
}
```

### 2. 懒加载图片组件

```dart
// lib/features/chat/presentation/widgets/lazy_image.dart
class LazyImage extends StatefulWidget {
  final String? imageUrl;
  final String? localPath;
  final double? width;
  final double? height;
  final BoxFit fit;

  const LazyImage({
    super.key,
    this.imageUrl,
    this.localPath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  State<LazyImage> createState() => _LazyImageState();
}

class _LazyImageState extends State<LazyImage> {
  ImageProvider? _imageProvider;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      if (widget.localPath != null && File(widget.localPath!).existsSync()) {
        _imageProvider = FileImage(File(widget.localPath!));
      } else if (widget.imageUrl != null) {
        _imageProvider = NetworkImage(widget.imageUrl!);
      }
      
      if (_imageProvider != null) {
        await precacheImage(_imageProvider!, context);
      }
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildPlaceholder();
    }
    
    if (_hasError || _imageProvider == null) {
      return _buildErrorPlaceholder();
    }
    
    return Image(
      image: _imageProvider!,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.broken_image,
        color: Colors.grey[600],
      ),
    );
  }
}
```

## 集成使用示例

### 完整的ChatPage集成

```dart
// lib/features/chat/presentation/pages/enhanced_chat_page.dart
class EnhancedChatPage extends StatefulWidget {
  final String conversationId;
  final User contact;

  const EnhancedChatPage({
    super.key,
    required this.conversationId,
    required this.contact,
  });

  @override
  State<EnhancedChatPage> createState() => _EnhancedChatPageState();
}

class _EnhancedChatPageState extends State<EnhancedChatPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isSelectionMode = false;
  final Set<String> _selectedMessageIds = {};

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        return Scaffold(
          appBar: _isSelectionMode 
              ? null 
              : _buildAppBar(context, state),
          
          body: Stack(
            children: [
              // 背景
              _buildBackground(),
              
              // 主要内容
              Column(
                children: [
                  // 选择模式工具栏
                  if (_isSelectionMode)
                    MessageSelectionBar(
                      selectedCount: _selectedMessageIds.length,
                      onCancel: _exitSelectionMode,
                      onDelete: _deleteSelectedMessages,
                      onForward: _forwardSelectedMessages,
                      onCopy: _copySelectedMessages,
                    ),
                  
                  // 消息列表
                  Expanded(
                    child: MessageTimeline(
                      messages: state.visibleMessages,
                      currentUserId: state.currentUser?.userId ?? '',
                      highlightedMessage: state.highlightedMessage,
                      scrollController: _scrollController,
                      onMessageTap: _handleMessageTap,
                      onMessageLongPress: _handleMessageLongPress,
                      onQuoteTap: _handleQuoteTap,
                    ),
                  ),
                  
                  // 输入区域
                  _buildInputArea(context, state),
                ],
              ),
              
              // 未读消息指示器（从缓存设计文档集成）
              if (state.showUnreadIndicator)
                Positioned(
                  bottom: 80,
                  right: 16,
                  child: _buildUnreadIndicator(state),
                ),
            ],
          ),
        );
      },
    );
  }

  void _handleMessageTap(Message message) {
    if (_isSelectionMode) {
      _toggleMessageSelection(message.messageId);
    } else {
      // 处理普通点击
    }
  }

  void _handleMessageLongPress(Message message) {
    if (_isSelectionMode) {
      _toggleMessageSelection(message.messageId);
    } else {
      _showMessageActionMenu(message);
    }
  }

  void _showMessageActionMenu(Message message) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MessageActionMenu(
        message: message,
        isMe: message.senderId == context.read<ChatCubit>().state.currentUser?.userId,
        onReply: () => _replyToMessage(message),
        onQuote: () => _quoteMessage(message),
        onEdit: () => _editMessage(message),
        onRevoke: () => _revokeMessage(message),
        onDelete: () => _deleteMessage(message),
        onSelect: () => _enterSelectionMode(message),
        onReaction: (emoji) => _addReaction(message, emoji),
      ),
    );
  }

  // 消息操作实现
  void _replyToMessage(Message message) {
    context.read<ChatCubit>().setReplyTarget(message);
  }

  void _quoteMessage(Message message) {
    context.read<ChatCubit>().setQuoteTarget(message);
  }

  void _editMessage(Message message) {
    showDialog(
      context: context,
      builder: (context) => MessageEditDialog(
        message: message,
        onSave: (newText) {
          context.read<ChatCubit>().editMessage(message.messageId, newText);
        },
      ),
    );
  }

  void _revokeMessage(Message message) {
    context.read<ChatCubit>().revokeMessage(message.messageId);
  }

  void _deleteMessage(Message message) {
    context.read<ChatCubit>().deleteMessage(message.messageId);
  }

  void _addReaction(Message message, String emoji) {
    context.read<ChatCubit>().addReaction(message.messageId, emoji);
  }

  // 选择模式相关方法
  void _enterSelectionMode(Message message) {
    setState(() {
      _isSelectionMode = true;
      _selectedMessageIds.add(message.messageId);
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedMessageIds.clear();
    });
  }

  void _toggleMessageSelection(String messageId) {
    setState(() {
      if (_selectedMessageIds.contains(messageId)) {
        _selectedMessageIds.remove(messageId);
        if (_selectedMessageIds.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedMessageIds.add(messageId);
      }
    });
  }

  // 其他辅助方法...
}
```

## 设计特点总结

### ✅ 功能特点
1. **完整消息状态支持**：撤销、删除、编辑、引用等
2. **丰富交互功能**：长按菜单、快速反应、消息选择
3. **智能消息分组**：相同发送者的连续消息自动分组
4. **高性能渲染**：虚拟化列表、懒加载图片
5. **用户体验优化**：动画效果、状态指示、时间分隔

### ✅ 技术特点
1. **响应式设计**：适配不同屏幕尺寸
2. **可扩展架构**：易于添加新的消息类型和功能
3. **状态管理**：临时UI状态与业务状态分离
4. **动画系统**：流畅的高亮和选择动画
5. **性能优化**：内存控制和渲染优化

### ✅ 用户体验
1. **直观操作**：符合用户习惯的交互模式
2. **视觉反馈**：清晰的状态指示和动画效果
3. **快速响应**：优化的渲染和交互响应
4. **功能完整**：覆盖现代IM应用的所有功能需求

---

*文档版本: v1.0*  
*创建时间: 2024年*  
*配合缓存设计文档使用* 