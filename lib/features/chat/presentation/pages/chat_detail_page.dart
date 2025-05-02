import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as dev;
import 'package:cc/core/database/models/conversation.dart';
import 'package:cc/core/database/models/message.dart';
import 'package:cc/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:cc/features/chat/presentation/cubit/chat_state.dart';

class ChatDetailPage extends StatefulWidget {
  final String conversationId;

  const ChatDetailPage({
    super.key,
    required this.conversationId,
  });

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  bool _isAttachmentMenuOpen = false;
  bool _isAtBottom = true;
  bool _isLoadingMore = false;
  bool _dataInitialized = false;

  @override
  void initState() {
    super.initState();
    // 加载会话消息
    _loadConversation();

    // 监听滚动事件，用于加载历史消息
    _scrollController.addListener(_scrollListener);

    // 监听焦点变化，输入框获得焦点时关闭附件菜单
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 确保数据仅被初始化一次
    if (!_dataInitialized) {
      _dataInitialized = true;
      // 确保消息加载完成后滚动到底部
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  // 加载会话和消息
  void _loadConversation() {
    final chatCubit = context.read<ChatCubit>();
    chatCubit.setCurrentConversation(widget.conversationId);
  }

  // 滚动到底部
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0, // 因为reverse=true, 所以0是底部
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // 滚动监听器，用于加载更多历史消息
  void _scrollListener() {
    // 检测是否到达底部
    if (_scrollController.hasClients) {
      _isAtBottom = _scrollController.position.pixels == 0; // 因为reverse=true，所以0是底部位置

      // 检测是否到达顶部（旧消息方向），用于加载更多历史消息
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.9 && !_isLoadingMore) {
        _loadMoreMessages();
      }
    }
  }

  // 加载更多历史消息
  Future<void> _loadMoreMessages() async {
    final state = context.read<ChatCubit>().state;
    final messages = state.messagesByConversation[widget.conversationId] ?? [];

    if (messages.isEmpty) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      // 获取最早的消息时间作为加载更多的基准
      final earliestMessage = messages.reduce((a, b) => a.createdAt.isBefore(b.createdAt) ? a : b);

      // 加载更早的消息
      await context.read<ChatCubit>().loadMessagesForConversation(
            widget.conversationId,
            before: earliestMessage.createdAt,
            limit: 20,
          );
    } catch (e) {
      dev.log('加载更多消息失败: $e');
    } finally {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  // 发送消息
  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    context.read<ChatCubit>().sendTextMessage(widget.conversationId, message);
    _messageController.clear();

    // 滚动到底部
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus && _isAttachmentMenuOpen) {
      setState(() {
        _isAttachmentMenuOpen = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        // 获取当前会话
        final conversation = state.conversations.firstWhere(
          (c) => c.id.toString() == widget.conversationId,
          orElse: () => Conversation()..name = '未知会话',
        );

        // 获取消息列表
        final messages = state.messagesByConversation[widget.conversationId] ?? [];

        // 当消息加载完成后自动滚动到底部
        if (messages.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients && _isAtBottom) {
              _scrollToBottom();
            }
          });
        }

        return Scaffold(
          // 确保键盘不会将输入框顶起
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  conversation.name ?? '未知会话',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                if (conversation.type == ConversationType.private)
                  Text(
                    '在线', // 这里可以显示对方的状态
                    style: TextStyle(fontSize: 12, color: Colors.white.withAlpha(204)),
                  ),
              ],
            ),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.videocam),
                onPressed: () {
                  dev.log('视频通话');
                },
              ),
              IconButton(
                icon: const Icon(Icons.call),
                onPressed: () {
                  dev.log('语音通话');
                },
              ),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  _showMoreOptions(context, conversation);
                },
              ),
            ],
          ),
          body: Column(
            children: [
              // 加载更多指示器
              if (_isLoadingMore)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ),

              // 消息列表
              Expanded(
                child: messages.isEmpty
                    ? _buildEmptyChat()
                    : ScrollConfiguration(
                        // 自定义滚动行为，隐藏滚动条
                        behavior: ScrollConfiguration.of(context).copyWith(
                          scrollbars: false,
                        ),
                        child: ListView.builder(
                          controller: _scrollController,
                          reverse: true, // 最新消息在底部
                          physics: const BouncingScrollPhysics(),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            if (index >= messages.length) {
                              return const SizedBox(); // 防止索引越界
                            }

                            final message = messages[index];
                            final isFromMe = message.senderId == '1'; // 假设当前用户ID为1

                            return _buildMessageItem(message, isFromMe);
                          },
                        ),
                      ),
              ),

              // 消息输入区域
              _buildMessageInput(),
            ],
          ),
        );
      },
    );
  }

  // 构建空聊天状态
  Widget _buildEmptyChat() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '没有消息',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '发送消息开始聊天吧',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  // 构建消息项
  Widget _buildMessageItem(Message message, bool isFromMe) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Row(
        mainAxisAlignment: isFromMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 发送者头像（仅在非自己发送的消息显示）
          if (!isFromMe)
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey[300],
              backgroundImage: message.senderAvatar != null && message.senderAvatar!.isNotEmpty ? NetworkImage(message.senderAvatar!) : null,
              child: message.senderAvatar == null || message.senderAvatar!.isEmpty
                  ? Text(
                      message.senderName != null && message.senderName!.isNotEmpty ? message.senderName![0].toUpperCase() : '?',
                      style: const TextStyle(color: Colors.white),
                    )
                  : null,
            ),

          if (!isFromMe) const SizedBox(width: 8),

          // 消息气泡
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isFromMe ? Colors.green[100] : Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 消息内容
                  if (message.type == MessageType.text)
                    Text(
                      message.text ?? '',
                      style: const TextStyle(fontSize: 16),
                    )
                  else if (message.type == MessageType.image)
                    _buildImageMessage(message)
                  else if (message.type == MessageType.voice)
                    _buildVoiceMessage(message)
                  else
                    Text(
                      '[${message.type.toString().split('.').last}]',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),

                  // 消息时间
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatMessageTime(message.createdAt),
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (isFromMe) ...[
                          const SizedBox(width: 4),
                          Icon(
                            message.status == 'sent' ? Icons.done_all : Icons.done,
                            size: 12,
                            color: message.isRead ? Colors.blue : Colors.grey[600],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (isFromMe) const SizedBox(width: 8),

          // 自己的头像（仅在自己发送的消息显示）
          if (isFromMe)
            const CircleAvatar(
              radius: 16,
              backgroundColor: Colors.green,
              child: Text(
                '我',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  // 构建图片消息
  Widget _buildImageMessage(Message message) {
    return GestureDetector(
      onTap: () {
        // 查看大图
        dev.log('查看图片: ${message.mediaUrl}');
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          message.mediaUrl ?? '',
          width: 200,
          height: 150,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 200,
              height: 150,
              color: Colors.grey[300],
              child: const Center(
                child: Icon(Icons.broken_image, color: Colors.grey),
              ),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: 200,
              height: 150,
              color: Colors.grey[200],
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null,
                  color: Colors.green,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // 构建语音消息
  Widget _buildVoiceMessage(Message message) {
    final duration = message.duration ?? 0;
    final seconds = (duration / 1000).round();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.play_arrow,
            color: Colors.grey[700],
          ),
          const SizedBox(width: 8),
          Container(
            width: 80.0 + (seconds > 60 ? 80.0 : seconds.toDouble()),
            height: 2,
            color: Colors.grey[400],
          ),
          const SizedBox(width: 8),
          Text(
            '$seconds秒',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  // 构建消息输入区域
  Widget _buildMessageInput() {
    // 计算键盘高度，确保输入框不会被键盘遮挡
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: Container(
        padding: EdgeInsets.only(
          left: 10,
          right: 10,
          top: 10,
          bottom: bottomInset > 0 ? 8 : 10, // 根据键盘是否显示调整底部间距
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(26),
              blurRadius: 4,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 附件菜单
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: _isAttachmentMenuOpen ? 150 : 0,
              // 动画过程中剪裁溢出内容
              clipBehavior: Clip.hardEdge,
              decoration: const BoxDecoration(),
              child: _isAttachmentMenuOpen
                  ? SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 10),
                          // 第一行4个选项
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildAttachmentOption(Icons.image, '图片', Colors.green),
                              _buildAttachmentOption(Icons.camera_alt, '拍摄', Colors.blue),
                              _buildAttachmentOption(Icons.videocam, '视频', Colors.orange),
                              _buildAttachmentOption(Icons.location_on, '位置', Colors.red),
                            ],
                          ),
                          const SizedBox(height: 14),
                          // 第二行4个选项
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildAttachmentOption(Icons.mic, '语音', Colors.purple),
                              _buildAttachmentOption(Icons.text_snippet, '文件', Colors.brown),
                              _buildAttachmentOption(Icons.person, '名片', Colors.indigo),
                              _buildAttachmentOption(Icons.money, '收付款', Colors.teal),
                            ],
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            // 输入栏
            Row(
              children: [
                // 语音/键盘切换按钮
                IconButton(
                  icon: const Icon(Icons.keyboard_voice),
                  color: Colors.grey[600],
                  onPressed: () {
                    dev.log('切换到语音输入');
                  },
                ),

                // 消息输入框
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    focusNode: _focusNode,
                    maxLines: 4,
                    minLines: 1,
                    decoration: InputDecoration(
                      hintText: '输入消息...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    onChanged: (value) {
                      // 如何有需要，可以在这里处理输入变化
                    },
                  ),
                ),

                // 附件按钮
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  color: Colors.grey[600],
                  onPressed: () {
                    // 切换附件菜单状态
                    setState(() {
                      _isAttachmentMenuOpen = !_isAttachmentMenuOpen;
                      // 如果打开附件菜单，则让输入框失去焦点
                      if (_isAttachmentMenuOpen) {
                        _focusNode.unfocus();
                      }
                    });
                  },
                ),

                // 发送按钮
                IconButton(
                  icon: const Icon(Icons.send),
                  color: Colors.green,
                  onPressed: _messageController.text.trim().isNotEmpty ? _sendMessage : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 构建附件选项
  Widget _buildAttachmentOption(IconData icon, String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color.withAlpha(26),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: color,
            size: 18,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[700],
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  // 显示更多选项菜单
  void _showMoreOptions(BuildContext context, Conversation conversation) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('查看资料'),
              onTap: () {
                Navigator.pop(context);
                dev.log('查看资料');
              },
            ),
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text('搜索聊天记录'),
              onTap: () {
                Navigator.pop(context);
                dev.log('搜索聊天记录');
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications_off),
              title: const Text('消息免打扰'),
              onTap: () {
                Navigator.pop(context);
                dev.log('消息免打扰');
              },
            ),
            if (conversation.type == ConversationType.group)
              ListTile(
                leading: const Icon(Icons.group),
                title: const Text('查看群成员'),
                onTap: () {
                  Navigator.pop(context);
                  dev.log('查看群成员');
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('清空聊天记录', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  // 显示删除确认对话框
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清空聊天记录'),
        content: const Text('确定要清空聊天记录吗？此操作不可恢复。'),
        actions: [
          TextButton(
            child: const Text('取消'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          TextButton(
            child: const Text('清空', style: TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.pop(context);
              dev.log('清空聊天记录');
              // TODO: 实现清空聊天记录功能
            },
          ),
        ],
      ),
    );
  }

  // 格式化消息时间
  String _formatMessageTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      // 今天的消息显示时间
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == yesterday) {
      // 昨天的消息
      return '昨天 ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      // 其他日期的消息
      return '${dateTime.month}-${dateTime.day} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}
