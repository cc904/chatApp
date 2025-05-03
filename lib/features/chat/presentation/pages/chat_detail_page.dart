import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as dev;
import 'package:cc/core/database/models/conversation.dart';
import 'package:cc/core/database/models/message.dart';
import 'package:cc/core/services/media_service.dart';
import 'package:cc/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:cc/features/chat/presentation/cubit/chat_state.dart';
import 'package:cc/core/services/file_upload_service.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import 'package:cc/core/services/ui_notification_service.dart'; // 导入UI通知服务
import 'package:cc/features/chat/presentation/pages/chat_info_page.dart'; // 导入聊天信息页面

class ChatDetailPage extends StatefulWidget {
  final String conversationId;

  const ChatDetailPage({
    super.key,
    required this.conversationId,
  });

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  bool _isAttachmentMenuOpen = false;
  bool _isAtBottom = true;
  bool _isLoadingMore = false;
  bool _dataInitialized = false;
// 新增：语音输入模式标志
// 新增：是否正在录音
// 新增：是否正在取消录音
// 新增：录音开始时间

  // 录音波形动画控制
  late AnimationController _waveformController;

  // 媒体服务
  final MediaService _mediaService = MediaService();
  final FileUploadService _fileUploadService = FileUploadService();

  // 录音状态
  Timer? _recordingTimer;

  // 添加选择的附件状态
  File? _selectedAttachment;
  MessageType? _attachmentType;
  String? _attachmentName;
  double? _attachmentSize;

  // 语音消息播放相关状态

  // 添加语音动画控制器
  late AnimationController _voiceAnimationController;

  @override
  void initState() {
    super.initState();
    // 加载会话消息
    _loadConversation();

    // 监听滚动事件，用于加载历史消息
    _scrollController.addListener(_scrollListener);

    // 监听焦点变化，输入框获得焦点时关闭附件菜单
    _focusNode.addListener(_onFocusChange);

    // 初始化波形动画控制器
    _waveformController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..addListener(() {
        setState(() {});
      });
    _waveformController.repeat();

    // 初始化语音动画控制器
    _voiceAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );
    _voiceAnimationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    // 停止所有音频播放
    _mediaService.stopAudio();
    _mediaService.disposeAudio();

    _messageController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose(); // 确保添加这行
    _waveformController.dispose();
    _voiceAnimationController.dispose();

    // 清理录音计时器
    _recordingTimer?.cancel();

    super.dispose();
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

  // 加载会话和消息
  void _loadConversation() {
    try {
      final chatCubit = context.read<ChatCubit>();
      chatCubit.setCurrentConversation(widget.conversationId);
    } catch (e) {
      dev.log('加载会话失败: $e');
      UINotificationService().showError('加载会话失败: $e');
    }
  }

  // 滚动到底部
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      // 使用更激进的滚动策略，确保到达底部
      _scrollController.jumpTo(0);
      // 然后使用动画滚动确保UI平滑
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
    // 在异步操作前保存必要的实例
    final chatCubit = context.read<ChatCubit>();
    final state = chatCubit.state;
    final messages = state.messagesByConversation[widget.conversationId] ?? [];

    if (messages.isEmpty) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      // 获取最早的消息时间作为加载更多的基准
      final earliestMessage = messages.reduce((a, b) => a.createdAt.isBefore(b.createdAt) ? a : b);

      // 加载更早的消息
      await chatCubit.loadMessagesForConversation(
        widget.conversationId,
        before: earliestMessage.createdAt,
        limit: 20,
      );
    } catch (e) {
      dev.log('加载更多消息失败: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  // 发送消息
  void _sendMessage() {
    final message = _messageController.text.trim();

    // 如果有选择的附件，发送附件
    if (_selectedAttachment != null && _attachmentType != null) {
      _sendAttachment();
      return;
    }

    // 否则发送文本消息
    if (message.isEmpty) return;

    context.read<ChatCubit>().sendTextMessage(widget.conversationId, message);
    _messageController.clear();

    // 强制设置为底部标志，确保新消息出现时滚动到底部
    setState(() {
      _isAtBottom = true;
    });

    // 滚动到底部
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  // 发送附件
  Future<void> _sendAttachment() async {
    if (_selectedAttachment == null || _attachmentType == null) return;

    try {
      // 强制设置为底部标志，确保新消息出现时滚动到底部
      setState(() {
        _isAtBottom = true;
      });

      // 提前获取ChatCubit实例
      final chatCubit = context.read<ChatCubit>();

      switch (_attachmentType) {
        case MessageType.image:
          // 上传图片
          final uploadResult = await _fileUploadService.uploadImage(_selectedAttachment!);
          if (uploadResult == null) {
            UINotificationService().showError('图片上传失败');
            return;
          }

          // 打印上传结果以便调试
          dev.log('图片上传成功: localPath=${uploadResult.localPath}, remoteUrl=${uploadResult.remoteUrl}');

          // 发送图片消息
          if (mounted) {
            await chatCubit.sendImageMessage(
              widget.conversationId,
              uploadResult.localPath,
              mediaUrl: uploadResult.remoteUrl,
            );
          }
          break;

        case MessageType.file:
          // 上传文件
          final uploadResult = await _fileUploadService.uploadFile(_selectedAttachment!);
          if (uploadResult == null) {
            UINotificationService().showError('文件上传失败');
            return;
          }

          // 发送文件消息
          if (mounted) {
            await chatCubit.sendFileMessage(
              widget.conversationId,
              uploadResult.localPath,
              _attachmentName ?? '未知文件',
              _attachmentSize ?? _selectedAttachment!.lengthSync().toDouble(),
              mediaUrl: uploadResult.remoteUrl,
            );
          }
          break;

        case MessageType.video:
          // 上传视频
          final uploadResult = await _fileUploadService.uploadVideo(_selectedAttachment!);
          if (uploadResult == null) {
            UINotificationService().showError('视频上传失败');
            return;
          }

          // 尝试获取准确的视频时长
          int videoDuration = 30000; // 默认30秒
          try {
            final controller = VideoPlayerController.file(_selectedAttachment!);
            await controller.initialize();
            videoDuration = controller.value.duration.inMilliseconds;
            await controller.dispose();
          } catch (e) {
            dev.log('获取视频时长失败，使用默认值: $e');
          }

          // 发送视频消息
          if (mounted) {
            await chatCubit.sendVideoMessage(
              widget.conversationId,
              uploadResult.localPath,
              videoDuration,
              thumbnailUrl: uploadResult.thumbnailUrl,
              mediaUrl: uploadResult.remoteUrl,
              isServerProcessed: uploadResult.serverProcessed,
            );
          }

          dev.log(
              '视频发送成功: localPath=${uploadResult.localPath}, mediaUrl=${uploadResult.remoteUrl}, thumbnailUrl=${uploadResult.thumbnailUrl}, serverProcessed=${uploadResult.serverProcessed}');
          break;

        default:
          UINotificationService().showError('不支持的附件类型');
          return;
      }

      // 清除附件
      if (mounted) {
        setState(() {
          _selectedAttachment = null;
          _attachmentType = null;
          _attachmentName = null;
          _attachmentSize = null;
        });

        // 清空消息输入框
        _messageController.clear();

        // 滚动到底部 - 使用延迟确保消息已加载
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _scrollToBottom();
          }
        });

        // 再添加一次延迟滚动，以处理可能的数据库延迟
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            _scrollToBottom();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        UINotificationService().showError('发送附件失败: $e');
      }
    }
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
                    style: TextStyle(fontSize: 12, color: Colors.white.withValues(red: 255, green: 255, blue: 255, alpha: 204)),
                  ),
              ],
            ),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.more_horiz), // 使用水平省略号图标，更像微信
                tooltip: '更多选项',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatInfoPage(
                        conversationId: widget.conversationId,
                      ),
                    ),
                  );
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
                    : NotificationListener<ScrollNotification>(
                        // 添加滚动通知监听，更精确地捕获滚动事件
                        onNotification: (scrollInfo) {
                          if (scrollInfo is ScrollEndNotification) {
                            setState(() {
                              _isAtBottom = _scrollController.position.pixels <= 1;
                            });
                          }
                          return false;
                        },
                        child: ScrollConfiguration(
                          // 自定义滚动行为，隐藏滚动条
                          behavior: ScrollConfiguration.of(context).copyWith(
                            scrollbars: false,
                          ),
                          child: ListView.builder(
                            key: ValueKey('message_list_${messages.length}'), // 添加key让Flutter知道列表已更新
                            controller: _scrollController,
                            reverse: true, // 最新消息在底部
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.only(bottom: 8.0), // 添加底部间距
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
    // 检查是否需要显示时间气泡
    final bool showTimeBubble = _shouldShowTimeBubble(message);

    return Column(
      children: [
        // 时间气泡 - 仅在需要时显示
        if (showTimeBubble)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _formatMessageTime(message.createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ),

        // 消息气泡
        Container(
          width: double.infinity, // 让消息容器占满整个宽度
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

              Column(
                crossAxisAlignment: isFromMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 消息内容行 - 包含气泡和状态
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // 自己发送的消息状态（只在气泡左侧显示，删除右侧的）
                      if (isFromMe)
                        Padding(
                          padding: const EdgeInsets.only(right: 4, bottom: 4),
                          child: Text(
                            message.isRead ? '已读' : '已送达',
                            style: TextStyle(
                              fontSize: 10,
                              color: message.isRead ? Colors.blue : Colors.grey[600],
                            ),
                          ),
                        ),

                      // 消息气泡
                      Flexible(
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 250),
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
                                _buildImageBubble(message, isFromMe)
                              else if (message.type == MessageType.video)
                                _buildVideoBubble(message, isFromMe)
                              else if (message.type == MessageType.voice)
                                _buildVoiceMessage(message)
                              else if (message.type == MessageType.file)
                                _buildFileMessage(message)
                              else
                                Text(
                                  '[${message.type.toString().split('.').last}]',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),

                      // 删除右侧的已读/已送达状态显示
                    ],
                  ),
                ],
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
        ),
      ],
    );
  }

  // 添加判断是否显示时间气泡的方法
  bool _shouldShowTimeBubble(Message message) {
    try {
      // 获取当前消息的索引
      final state = context.read<ChatCubit>().state;
      final messages = state.messagesByConversation[widget.conversationId] ?? [];

      // 安全检查：消息列表为空
      if (messages.isEmpty) {
        return true;
      }

      final index = messages.indexOf(message);

      // 安全检查：消息不在列表中
      if (index < 0) {
        return true;
      }

      // 第一条消息始终显示时间
      if (index == messages.length - 1) {
        return true;
      }

      // 获取前一条消息
      final previousMessage = messages[index + 1];

      // 如果与前一条消息时间相差超过5分钟，显示时间
      final timeDifference = message.createdAt.difference(previousMessage.createdAt).inMinutes.abs();
      return timeDifference >= 5;
    } catch (e) {
      // 发生异常时默认显示时间气泡
      dev.log('计算时间气泡显示时发生错误: $e');
      return true;
    }
  }

  // 滚动到特定消息

  // 其他方法实现
  // 实现_buildMessageInput方法
  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(red: 0, green: 0, blue: 0, alpha: 13),
            blurRadius: 3,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            color: Colors.grey[700],
            onPressed: () {
              // 显示附件选择菜单
            },
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: '发送消息...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              maxLines: 5,
              minLines: 1,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            color: Colors.green,
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }

  // 实现_formatMessageTime方法
  String _formatMessageTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      return '今天 ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == yesterday) {
      return '昨天 ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dateTime.month}月${dateTime.day}日 ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  // 实现_buildImageBubble方法
  Widget _buildImageBubble(Message message, bool isFromMe) {
    return GestureDetector(
      onTap: () {
        // 查看大图
      },
      child: Container(
        constraints: const BoxConstraints(maxWidth: 200),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            message.mediaUrl ?? message.localPath ?? '',
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                width: 150,
                height: 150,
                color: Colors.grey[300],
                child: const Center(child: CircularProgressIndicator()),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 150,
                height: 150,
                color: Colors.grey[300],
                child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
              );
            },
          ),
        ),
      ),
    );
  }

  // 实现_buildVideoBubble方法
  Widget _buildVideoBubble(Message message, bool isFromMe) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 200),
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 150,
              height: 150,
              color: Colors.black,
              child: const Icon(Icons.video_library, size: 50, color: Colors.white),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.play_circle_fill, size: 50, color: Colors.white),
            onPressed: () {
              // 播放视频
            },
          ),
        ],
      ),
    );
  }

  // 实现_buildVoiceMessage方法
  Widget _buildVoiceMessage(Message message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.mic, color: Colors.green),
          const SizedBox(width: 8),
          Text('${message.duration ?? 0}″', style: const TextStyle(color: Colors.black87)),
        ],
      ),
    );
  }

  // 实现_buildFileMessage方法
  Widget _buildFileMessage(Message message) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 250),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.insert_drive_file, color: Colors.blue),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.fileName ?? '未知文件',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text('${message.fileSize ?? '未知大小'}'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
