import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as dev;
import 'package:cc/core/database/models/conversation.dart';
import 'package:cc/core/database/models/message.dart';
import 'package:cc/core/services/media_service.dart';
import 'package:cc/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:cc/features/chat/presentation/cubit/chat_state.dart';
import 'package:cc/core/services/file_upload_service.dart';
import 'package:path/path.dart' as path;
import 'package:cc/features/chat/presentation/widgets/media_overlay_viewer.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import 'package:cc/core/services/ui_notification_service.dart'; // 导入UI通知服务
import 'package:cc/features/chat/presentation/pages/chat_info_page.dart';

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
  bool _isVoiceInputMode = false; // 新增：语音输入模式标志
  bool _isRecordingAudio = false; // 新增：是否正在录音
  bool _isCancellingRecord = false; // 新增：是否正在取消录音
  DateTime? _recordStartTime; // 新增：录音开始时间

  // 录音波形动画控制
  late AnimationController _waveformController;
  double _waveformValue = 0.0;

  // 媒体服务
  final MediaService _mediaService = MediaService();
  final FileUploadService _fileUploadService = FileUploadService();

  // 录音状态
  bool _isRecordingVoice = false;
  double? _recordingDuration;
  DateTime? _recordingStartTime;
  Timer? _recordingTimer;

  // 添加选择的附件状态
  File? _selectedAttachment;
  MessageType? _attachmentType;
  String? _attachmentName;
  double? _attachmentSize;

  // 语音消息播放相关状态
  bool _isPlayingVoiceMessage = false;
  String? _currentPlayingVoiceId;
  double _voicePlayProgress = 0.0;

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
        setState(() {
          _waveformValue = _waveformController.value;
        });
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
                    style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8)),
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
                  color: Colors.black.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _formatMessageTime(message.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black.withOpacity(0.7),
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

  // 构建图片气泡
  Widget _buildImageBubble(Message message, bool isMe) {
    final localPath = message.localPath;
    final mediaUrl = message.mediaUrl;

    // 图片已有缓存或已本地保存
    if (localPath != null && File(localPath).existsSync()) {
      final imageFile = File(localPath);

      return Container(
        constraints: const BoxConstraints(
          maxWidth: 220,
          maxHeight: 300,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isMe ? Colors.blue.shade100 : Colors.grey.shade200,
        ),
        clipBehavior: Clip.antiAlias,
        child: GestureDetector(
          onTap: () => _handleMessageTap(message),
          child: Hero(
            tag: 'image_${message.messageId}',
            child: Image.file(
              imageFile,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                dev.log('图片加载失败: $error');
                return Container(
                  width: 200,
                  height: 200,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.broken_image, size: 64, color: Colors.grey),
                );
              },
            ),
          ),
        ),
      );
    }

    // 仅有远程URL
    if (mediaUrl != null && mediaUrl.isNotEmpty) {
      final filePath = mediaUrl.startsWith('file://') ? mediaUrl.substring(7) : '';
      final fileExists = filePath.isNotEmpty && File(filePath).existsSync();

      // 本地文件存在
      if (fileExists) {
        final imageFile = File(filePath);

        return Container(
          constraints: const BoxConstraints(
            maxWidth: 220,
            maxHeight: 300,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isMe ? Colors.blue.shade100 : Colors.grey.shade200,
          ),
          clipBehavior: Clip.antiAlias,
          child: GestureDetector(
            onTap: () => _handleMessageTap(message),
            child: Hero(
              tag: 'image_${message.messageId}',
              child: Image.file(
                imageFile,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  dev.log('图片加载失败: $error');
                  return Container(
                    width: 200,
                    height: 200,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.broken_image, size: 64, color: Colors.grey),
                  );
                },
              ),
            ),
          ),
        );
      }

      // 网络URL
      return Container(
        constraints: const BoxConstraints(
          maxWidth: 220,
          maxHeight: 300,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isMe ? Colors.blue.shade100 : Colors.grey.shade200,
        ),
        clipBehavior: Clip.antiAlias,
        child: GestureDetector(
          onTap: () => _handleMessageTap(message),
          child: Hero(
            tag: 'image_${message.messageId}',
            child: Image.network(
              mediaUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: 200,
                  height: 200,
                  color: Colors.grey.shade200,
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 200,
                  height: 200,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.broken_image, size: 64, color: Colors.grey),
                );
              },
            ),
          ),
        ),
      );
    }

    // 没有可用图片
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade300,
      ),
      child: GestureDetector(
        onTap: () => _handleMessageTap(message),
        child: const Center(
          child: Icon(Icons.broken_image, size: 64, color: Colors.grey),
        ),
      ),
    );
  }

  // 构建视频气泡
  Widget _buildVideoBubble(Message message, bool isMe) {
    final thumbnailUrl = message.thumbnailUrl;
    final duration = message.duration;

    Widget thumbnailWidget = Container(
      width: 200,
      height: 150,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Icon(Icons.play_circle_outline, size: 48, color: Colors.white),
      ),
    );

    // 如果有缩略图
    if (thumbnailUrl != null && thumbnailUrl.isNotEmpty) {
      // 检查是否是本地文件URL
      if (thumbnailUrl.startsWith('file://')) {
        final file = File(thumbnailUrl.substring(7));
        if (file.existsSync()) {
          thumbnailWidget = Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  file,
                  width: 200,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.play_arrow, color: Colors.white, size: 30),
              ),
              if (duration != null && duration > 0)
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _formatDuration(duration),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
            ],
          );
        }
      } else {
        // 网络缩略图
        thumbnailWidget = Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                thumbnailUrl,
                width: 200,
                height: 150,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: 200,
                    height: 150,
                    color: Colors.black,
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 200,
                    height: 150,
                    color: Colors.black,
                    child: const Center(
                      child: Icon(Icons.error_outline, size: 48, color: Colors.white),
                    ),
                  );
                },
              ),
            ),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.play_arrow, color: Colors.white, size: 30),
            ),
            if (duration != null && duration > 0)
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _formatDuration(duration),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
          ],
        );
      }
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isMe ? Colors.blue.shade100 : Colors.grey.shade200,
      ),
      clipBehavior: Clip.antiAlias,
      child: GestureDetector(
        onTap: () => _handleMessageTap(message),
        child: Hero(
          tag: 'video_${message.messageId}',
          child: thumbnailWidget,
        ),
      ),
    );
  }

  // 构建语音消息
  Widget _buildVoiceMessage(Message message) {
    final duration = message.duration ?? 0;
    final seconds = (duration / 1000).round();
    final isPlaying = _isPlayingVoiceMessage && _currentPlayingVoiceId == message.messageId;

    // 计算剩余时间
    int remainingSeconds = seconds;
    if (isPlaying && seconds > 0) {
      remainingSeconds = (seconds * (1 - _voicePlayProgress)).round();
    }

    return GestureDetector(
      onTap: () => _playVoiceMessage(message),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.transparent, // 微信风格语音气泡背景透明
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 播放/暂停图标
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isPlaying ? Colors.green : Colors.grey[400],
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 14,
              ),
            ),
            const SizedBox(width: 8),

            // 语音条形图标(更接近微信的风格)
            AnimatedBuilder(
              animation: _voiceAnimationController,
              builder: (context, child) {
                return Row(
                  children: List.generate(4, (index) {
                    double height;
                    if (isPlaying) {
                      // 播放时使用动画高度，错开每个条的动画相位
                      final baseHeight = 4.0 + index * 2.0; // 基础高度随索引递增
                      final animValue = _voiceAnimationController.value;
                      // 每个条使用不同的相位偏移，创造波浪效果
                      final phaseOffset = index * 0.25;
                      final adjustedValue = (animValue + phaseOffset) % 1.0;

                      // 正弦动画效果
                      final sinValue = math.sin(adjustedValue * math.pi * 2);
                      height = baseHeight + 4.0 * sinValue.abs();
                    } else {
                      // 静态高度，微信风格各条高度不同
                      height = 4.0 + (index * 1.5);
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1.5),
                      child: Container(
                        width: 2,
                        height: height,
                        decoration: BoxDecoration(
                          color: isPlaying ? Colors.green : Colors.grey[500],
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),

            const SizedBox(width: 8),

            // 时间显示和倒计时 - 微信风格
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                isPlaying ? '$remainingSeconds″' : '$seconds″',
                key: ValueKey<bool>(isPlaying),
                style: TextStyle(
                  fontSize: 12,
                  color: isPlaying ? Colors.green : Colors.grey[600],
                  fontWeight: isPlaying ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 构建文件消息
  Widget _buildFileMessage(Message message) {
    final fileName = message.fileName ?? '未知文件';
    final fileSize = message.fileSize ?? 0;

    // 文件大小格式化
    String formattedSize;
    if (fileSize < 1024) {
      formattedSize = '${fileSize.toStringAsFixed(0)} B';
    } else if (fileSize < 1024 * 1024) {
      formattedSize = '${(fileSize / 1024).toStringAsFixed(1)} KB';
    } else if (fileSize < 1024 * 1024 * 1024) {
      formattedSize = '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      formattedSize = '${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }

    return Container(
      width: 200,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_getFileIcon(fileName), color: Colors.blue[700], size: 32),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      formattedSize,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => _openFile(message),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.blue[700],
              side: BorderSide(color: Colors.blue[300]!),
              minimumSize: const Size(double.infinity, 30),
              padding: const EdgeInsets.symmetric(vertical: 0),
            ),
            child: const Text('打开', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  // 获取文件图标
  IconData _getFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();

    // 根据文件扩展名返回对应图标
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.grid_on;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'bmp':
        return Icons.image;
      case 'mp3':
      case 'wav':
      case 'aac':
        return Icons.audiotrack;
      case 'mp4':
      case 'mov':
      case 'avi':
        return Icons.movie;
      case 'zip':
      case 'rar':
      case '7z':
        return Icons.folder_zip;
      case 'txt':
        return Icons.text_snippet;
      default:
        return Icons.insert_drive_file;
    }
  }

  // 打开文件
  Future<void> _openFile(Message message) async {
    final localPath = message.localPath;
    final mediaUrl = message.mediaUrl;

    // 检查是否有有效路径
    if (localPath == null && mediaUrl == null) {
      UINotificationService().showError('无法打开：找不到文件');
      return;
    }

    try {
      String? effectivePath;

      // 确定有效路径
      if (localPath != null && localPath.isNotEmpty) {
        effectivePath = localPath;
      } else if (mediaUrl != null && mediaUrl.startsWith('file://')) {
        effectivePath = mediaUrl.substring(7); // 去除file://前缀
      }

      if (effectivePath != null) {
        final file = File(effectivePath);

        // 提前获取需要的实例和变量，避免后续使用BuildContext
        final senderId = message.senderId;
        final chatCubit = context.read<ChatCubit>();

        final bool fileExists = await file.exists();
        if (!mounted) return;

        if (fileExists) {
          // 检查文件类型
          final extension = effectivePath.split('.').last.toLowerCase();

          // 特定类型使用特定查看器
          if (['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension)) {
            // 图片使用图片查看器
            if (mounted) {
              MediaOverlayViewer.show(
                context,
                imagePath: effectivePath,
                mediaUrl: mediaUrl,
                onDelete: senderId == '1'
                    ? () {
                        chatCubit.deleteMessage(message.messageId);
                      }
                    : null,
              );
            }
          } else if (['mp4', 'mov', 'avi', 'mkv', 'webm'].contains(extension)) {
            // 视频使用视频查看器
            if (mounted) {
              MediaOverlayViewer.show(
                context,
                videoPath: effectivePath,
                mediaUrl: mediaUrl,
                onDelete: senderId == '1'
                    ? () {
                        chatCubit.deleteMessage(message.messageId);
                      }
                    : null,
              );
            }
          } else {
            // 其他文件尝试使用系统打开
            // 实际项目中，可以使用open_file或url_launcher等插件
            UINotificationService().showMessage('尝试打开文件: $effectivePath');
            dev.log('打开文件: $effectivePath');
          }
        } else {
          UINotificationService().showError('文件不存在');
        }
      } else if (mediaUrl != null) {
        // 处理网络文件
        UINotificationService().showMessage('正在打开网络文件: $mediaUrl');
        dev.log('打开网络文件: $mediaUrl');
      }
    } catch (e) {
      dev.log('打开文件失败: $e');
      UINotificationService().showError('打开文件失败: $e');
    }
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
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 附件预览
            if (_selectedAttachment != null)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    // 附件类型图标
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getAttachmentColor(),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: _getAttachmentPreview(),
                    ),
                    const SizedBox(width: 8),
                    // 附件信息
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _attachmentName ?? '附件',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (_attachmentSize != null)
                            Text(
                              _formatFileSize(_attachmentSize!),
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                        ],
                      ),
                    ),
                    // 删除按钮
                    IconButton(
                      icon: const Icon(Icons.close),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        setState(() {
                          _selectedAttachment = null;
                          _attachmentType = null;
                          _attachmentName = null;
                          _attachmentSize = null;
                        });
                      },
                    ),
                  ],
                ),
              ),

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
                              _buildAttachmentOption(
                                Icons.image,
                                '图片',
                                Colors.green,
                                onTap: _handlePickImage,
                              ),
                              _buildAttachmentOption(
                                Icons.camera_alt,
                                '拍摄',
                                Colors.blue,
                                onTap: _handleTakePhoto,
                              ),
                              _buildAttachmentOption(
                                Icons.videocam,
                                '视频',
                                Colors.orange,
                                onTap: _handlePickVideo,
                              ),
                              _buildAttachmentOption(
                                Icons.location_on,
                                '位置',
                                Colors.red,
                                onTap: () {
                                  // 暂未实现位置分享功能
                                  dev.log('位置分享功能暂未实现');
                                  _closeAttachmentMenu();
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          // 第二行4个选项
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildAttachmentOption(
                                Icons.mic,
                                '语音',
                                Colors.purple,
                                onTap: _handleRecordVoice,
                              ),
                              _buildAttachmentOption(
                                Icons.text_snippet,
                                '文件',
                                Colors.brown,
                                onTap: _handlePickFile,
                              ),
                              _buildAttachmentOption(
                                Icons.person,
                                '名片',
                                Colors.indigo,
                                onTap: () {
                                  // 暂未实现名片分享功能
                                  dev.log('名片分享功能暂未实现');
                                  _closeAttachmentMenu();
                                },
                              ),
                              _buildAttachmentOption(
                                Icons.money,
                                '收付款',
                                Colors.teal,
                                onTap: () {
                                  // 暂未实现收付款功能
                                  dev.log('收付款功能暂未实现');
                                  _closeAttachmentMenu();
                                },
                              ),
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
                  icon: Icon(_isVoiceInputMode ? Icons.keyboard : Icons.keyboard_voice),
                  color: Colors.grey[600],
                  onPressed: () {
                    setState(() {
                      _isVoiceInputMode = !_isVoiceInputMode;
                      if (_isVoiceInputMode) {
                        _focusNode.unfocus(); // 切换到语音模式时收起键盘
                      }
                    });
                  },
                ),
                const SizedBox(width: 10),

                // 根据模式显示不同的输入控件
                Expanded(
                  child: _isVoiceInputMode
                      ? _buildVoiceRecordButton() // 语音模式：显示长按录音按钮
                      : TextField(
                          // 文本模式：显示文本输入框
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

                // 发送按钮，在语音模式或有内容时显示
                IconButton(
                  icon: const Icon(Icons.send),
                  color: (_messageController.text.trim().isNotEmpty || _selectedAttachment != null) ? Colors.green : Colors.grey[400],
                  onPressed: (_messageController.text.trim().isNotEmpty || _selectedAttachment != null) ? _sendMessage : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 构建语音录制按钮
  Widget _buildVoiceRecordButton() {
    return GestureDetector(
      // 长按录音，松开结束
      onLongPress: _startRecording,
      onLongPressUp: () => _stopRecording(true), // 松开发送
      onLongPressCancel: () => _stopRecording(false), // 取消发送
      // 记录手指位置，用于判断上滑取消
      onLongPressMoveUpdate: (details) {
        // 如果正在录音且向上滑动超过一定距离，显示"松开手指取消发送"
        if (_isRecordingAudio && details.offsetFromOrigin.dy < -50) {
          // 设置取消标志
          if (!_isCancellingRecord) {
            setState(() {
              _isCancellingRecord = true;
            });
            // 震动反馈
            HapticFeedback.lightImpact();
          }
        } else if (_isCancellingRecord) {
          // 恢复正常录音状态
          setState(() {
            _isCancellingRecord = false;
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 48,
        decoration: BoxDecoration(
          color: _isRecordingAudio ? (_isCancellingRecord ? Colors.red.withOpacity(0.2) : Colors.green.withOpacity(0.1)) : Colors.grey[200],
          borderRadius: BorderRadius.circular(24),
          border: _isRecordingAudio ? Border.all(color: _isCancellingRecord ? Colors.red : Colors.green.withOpacity(0.5), width: _isCancellingRecord ? 2.0 : 1.5) : null,
          boxShadow: _isRecordingAudio
              ? [
                  BoxShadow(
                    color: _isCancellingRecord ? Colors.red.withOpacity(0.4) : Colors.green.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 录音图标
              Icon(
                _isRecordingAudio ? (_isCancellingRecord ? Icons.delete : Icons.mic) : Icons.mic,
                color: _isRecordingAudio ? (_isCancellingRecord ? Colors.red : Colors.green) : Colors.grey[700],
                size: 20,
              ),
              const SizedBox(width: 8),

              // 录音指示 (替换原来的波形)
              if (_isRecordingAudio && !_isCancellingRecord) ...[
                Row(
                  children: List.generate(4, (index) {
                    // 使用正弦函数创建高度变化，模拟微信风格的简单动画
                    final phase = index * 0.25;
                    final adjustedValue = (_waveformValue + phase) % 1.0;
                    final height = 6.0 + 6.0 * math.sin(adjustedValue * math.pi * 2).abs();

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      width: 2.5,
                      height: height,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(1.0),
                      ),
                    );
                  }),
                ),
                const SizedBox(width: 8),
              ],

              // 提示文字
              Text(
                _isRecordingAudio ? (_isCancellingRecord ? '松开手指，取消发送' : '松开发送，上滑取消') : '按住说话',
                style: TextStyle(
                  color: _isRecordingAudio ? (_isCancellingRecord ? Colors.red : Colors.green) : Colors.grey[700],
                  fontSize: 16,
                  fontWeight: _isCancellingRecord ? FontWeight.bold : FontWeight.normal,
                ),
              ),

              // 录音时长
              if (_isRecordingAudio && !_isCancellingRecord) ...[
                const SizedBox(width: 8),
                Text(
                  _getRecordDuration(),
                  style: TextStyle(
                    color: Colors.green[700],
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // 获取录音时长文本
  String _getRecordDuration() {
    if (_recordStartTime == null) return "0:00";

    final duration = DateTime.now().difference(_recordStartTime!);
    final seconds = duration.inSeconds;
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;

    return "$minutes:${remainingSeconds.toString().padLeft(2, '0')}";
  }

  // 获取附件预览颜色
  Color _getAttachmentColor() {
    switch (_attachmentType) {
      case MessageType.image:
        return Colors.green[100]!;
      case MessageType.file:
        return Colors.blue[100]!;
      case MessageType.video:
        return Colors.orange[100]!;
      default:
        return Colors.grey[300]!;
    }
  }

  // 获取附件预览图标或图片
  Widget _getAttachmentPreview() {
    if (_attachmentType == MessageType.image && _selectedAttachment != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.file(
          _selectedAttachment!,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
        ),
      );
    }

    IconData iconData;
    Color iconColor;

    switch (_attachmentType) {
      case MessageType.image:
        iconData = Icons.image;
        iconColor = Colors.green;
        break;
      case MessageType.video:
        iconData = Icons.videocam;
        iconColor = Colors.orange;
        break;
      case MessageType.file:
        iconData = Icons.insert_drive_file;
        iconColor = Colors.blue;
        break;
      default:
        iconData = Icons.attach_file;
        iconColor = Colors.grey;
    }

    return Icon(
      iconData,
      color: iconColor,
      size: 24,
    );
  }

  // 格式化文件大小
  String _formatFileSize(double fileSize) {
    if (fileSize < 1024) {
      return '${fileSize.toStringAsFixed(0)} B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    } else if (fileSize < 1024 * 1024 * 1024) {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  // 构建附件选项
  Widget _buildAttachmentOption(IconData icon, String label, Color color, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
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
      ),
    );
  }

  // 显示更多选项菜单
  void _showMoreOptions(BuildContext context, Conversation conversation) {
    // 导航到聊天信息页面，而不是显示底部菜单
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChatInfoPage(conversationId: widget.conversationId),
      ),
    );
  }

  // 关闭附件菜单
  void _closeAttachmentMenu() {
    setState(() {
      _isAttachmentMenuOpen = false;
    });
  }

  // 处理图片选择
  Future<void> _handlePickImage() async {
    _closeAttachmentMenu();

    final file = await _mediaService.pickImage(fromCamera: false);
    if (file == null) return;

    // 设置选择的图片附件
    if (mounted) {
      setState(() {
        _selectedAttachment = file;
        _attachmentType = MessageType.image;
        _attachmentName = path.basename(file.path);
        _attachmentSize = file.lengthSync().toDouble();
      });
    }
  }

  // 处理拍照
  Future<void> _handleTakePhoto() async {
    _closeAttachmentMenu();

    final file = await _mediaService.pickImage(fromCamera: true);
    if (file == null) return;

    // 设置拍摄的照片附件
    if (mounted) {
      setState(() {
        _selectedAttachment = file;
        _attachmentType = MessageType.image;
        _attachmentName = '拍摄的照片';
        _attachmentSize = file.lengthSync().toDouble();
      });
    }
  }

  // 处理视频选择
  Future<void> _handlePickVideo() async {
    _closeAttachmentMenu();

    final file = await _mediaService.pickVideo(fromCamera: false);
    if (file == null) return;

    // 设置选择的视频附件
    if (mounted) {
      setState(() {
        _selectedAttachment = file;
        _attachmentType = MessageType.video;
        _attachmentName = path.basename(file.path);
        _attachmentSize = file.lengthSync().toDouble();
      });
    }
  }

  // 处理文件选择
  Future<void> _handlePickFile() async {
    _closeAttachmentMenu();

    final file = await _mediaService.pickFile();
    if (file == null) return;

    // 获取文件名
    final fileName = file.path.split('/').last;

    // 设置选择的文件附件
    if (mounted) {
      setState(() {
        _selectedAttachment = file;
        _attachmentType = MessageType.file;
        _attachmentName = fileName;
        _attachmentSize = file.lengthSync().toDouble();
      });
    }
  }

  // 处理语音录制
  Future<void> _handleRecordVoice() async {
    _closeAttachmentMenu();

    // 显示录音对话框
    bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildVoiceRecordingDialog(),
    );

    if (result != true) return;

    // 录音结果在对话框内部处理并发送
  }

  // 构建语音录制对话框
  Widget _buildVoiceRecordingDialog() {
    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: Text(
            _isRecordingVoice ? '正在录音' : '语音录制',
            style: TextStyle(
              color: _isRecordingVoice ? Colors.red : Colors.black,
              fontWeight: _isRecordingVoice ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 录音动画
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.mic,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _isRecordingVoice ? '轻触停止录音' : '轻触开始录音',
                style: TextStyle(
                  color: _isRecordingVoice ? Colors.red : Colors.grey[600],
                ),
              ),
              if (_isRecordingVoice) ...[
                const SizedBox(height: 16),
                Text(
                  '录音时长: ${_recordingDuration?.toInt() ?? 0}秒',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // 如果正在录音，先停止录音
                if (_isRecordingVoice) {
                  _mediaService.stopRecording();
                }
                Navigator.of(context).pop(false);
              },
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () async {
                if (!_isRecordingVoice) {
                  // 开始录音
                  final navigator = Navigator.of(context); // 提前获取navigator引用
                  final success = await _mediaService.startRecording();
                  if (!mounted) return;

                  if (success) {
                    setState(() {
                      _isRecordingVoice = true;
                      _recordingDuration = 0.0;
                      _recordingStartTime = DateTime.now();
                    });

                    // 启动计时器更新录音时长
                    _recordingTimer?.cancel();
                    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
                      final duration = DateTime.now().difference(_recordingStartTime!).inSeconds.toDouble();
                      setState(() {
                        _recordingDuration = duration;
                      });
                    });
                  } else {
                    UINotificationService().showError('无法开始录音');
                    if (!mounted) return;

                    navigator.pop(false); // 使用提前获取的navigator
                    return;
                  }
                } else {
                  // 停止录音并处理录音结果
                  _recordingTimer?.cancel();
                  _recordingTimer = null;

                  // 提前获取需要的引用
                  final navigator = Navigator.of(context);
                  final chatCubit = context.read<ChatCubit>();
                  final conversationId = widget.conversationId;

                  final result = await _mediaService.stopRecording();
                  if (!mounted) return;

                  setState(() {
                    _isRecordingVoice = false;
                  });

                  if (result == null) {
                    if (!mounted) return;

                    navigator.pop(false); // 使用提前获取的navigator
                    return;
                  }

                  // 上传语音文件
                  final uploadResult = await _fileUploadService.uploadVoice(
                    result.file,
                    result.duration,
                  );

                  if (!mounted) return;

                  if (uploadResult == null) {
                    UINotificationService().showError('语音上传失败');
                    if (!mounted) return;

                    navigator.pop(false); // 使用提前获取的navigator
                    return;
                  }

                  // 发送语音消息
                  await chatCubit.sendVoiceMessage(
                    conversationId,
                    uploadResult.localPath,
                    uploadResult.duration ?? 0,
                    mediaUrl: uploadResult.remoteUrl,
                  );

                  if (!mounted) return;

                  // 隐藏处理中提示
                  UINotificationService().hideCurrentMessage();

                  // 关闭对话框，返回true表示成功
                  navigator.pop(true);

                  // 滚动到底部
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      _scrollToBottom();
                    }
                  });
                }
              },
              child: Text(_isRecordingVoice ? '停止' : '开始'),
            ),
          ],
        );
      },
    );
  }

  // 播放语音消息
  Future<void> _playVoiceMessage(Message message) async {
    final localPath = message.localPath;
    final mediaUrl = message.mediaUrl;
    final messageId = message.messageId;

    if (localPath == null && mediaUrl == null) {
      UINotificationService().showError('无法播放：找不到语音文件');
      return;
    }

    try {
      // 如果正在播放当前语音，暂停/停止
      if (_isPlayingVoiceMessage && _currentPlayingVoiceId == messageId) {
        // 完全停止当前播放，避免使用暂停功能
        await _mediaService.stopAudio();
        if (!mounted) return;

        setState(() {
          _isPlayingVoiceMessage = false;
          _currentPlayingVoiceId = null;
          _voicePlayProgress = 0.0;

          // 停止语音动画
          _voiceAnimationController.stop();
        });
        return;
      }

      // 先停止任何正在播放的音频
      if (_isPlayingVoiceMessage) {
        await _mediaService.stopAudio();
        if (!mounted) return;
      }

      // 设置播放状态
      setState(() {
        _isPlayingVoiceMessage = true;
        _currentPlayingVoiceId = messageId;
        _voicePlayProgress = 0.0;

        // 开始语音动画
        if (!_voiceAnimationController.isAnimating) {
          _voiceAnimationController.repeat(reverse: true);
        }
      });

      // 添加日志
      dev.log('准备播放语音消息: ID=$messageId, 本地路径=$localPath, URL=$mediaUrl');

      // 确定播放路径并播放
      try {
        if (localPath != null && localPath.isNotEmpty) {
          // 本地文件优先
          dev.log('使用本地文件路径播放: $localPath');
          await _mediaService.playAudio(
            localPath,
            onProgress: (progress) {
              if (mounted && _currentPlayingVoiceId == messageId) {
                setState(() {
                  _voicePlayProgress = progress;
                });
              }
            },
            onComplete: () {
              if (mounted && _currentPlayingVoiceId == messageId) {
                setState(() {
                  _isPlayingVoiceMessage = false;
                  _currentPlayingVoiceId = null;
                  _voicePlayProgress = 0.0;

                  // 停止语音动画
                  _voiceAnimationController.stop();
                });
              }
            },
          );
        } else if (mediaUrl != null) {
          // 使用媒体URL
          dev.log('使用媒体URL播放: $mediaUrl');
          await _mediaService.playAudioFromUrl(
            mediaUrl,
            onProgress: (progress) {
              if (mounted && _currentPlayingVoiceId == messageId) {
                setState(() {
                  _voicePlayProgress = progress;
                });
              }
            },
            onComplete: () {
              if (mounted && _currentPlayingVoiceId == messageId) {
                setState(() {
                  _isPlayingVoiceMessage = false;
                  _currentPlayingVoiceId = null;
                  _voicePlayProgress = 0.0;

                  // 停止语音动画
                  _voiceAnimationController.stop();
                });
              }
            },
          );
        }
      } catch (playError) {
        dev.log('播放语音过程中发生错误: $playError');
        // 如果播放过程中发生错误，重置状态
        if (mounted) {
          setState(() {
            _isPlayingVoiceMessage = false;
            _currentPlayingVoiceId = null;
            _voicePlayProgress = 0.0;

            // 停止语音动画
            _voiceAnimationController.stop();
          });
        }
        rethrow;
      }
    } catch (e) {
      dev.log('播放语音失败: $e');
      UINotificationService().showError('播放语音失败: $e');

      // 确保状态被重置
      if (mounted) {
        setState(() {
          _isPlayingVoiceMessage = false;
          _currentPlayingVoiceId = null;
          _voicePlayProgress = 0.0;

          // 停止语音动画
          _voiceAnimationController.stop();
        });
      }

      // 确保资源被释放
      _mediaService.stopAudio();
    }
  }

  // 格式化视频时长
  String _formatDuration(int? seconds) {
    if (seconds == null || seconds <= 0) {
      return '00:00';
    }

    final minutes = (seconds / 60).floor();
    final remainingSeconds = seconds % 60;

    final minutesStr = minutes.toString().padLeft(2, '0');
    final secondsStr = remainingSeconds.toString().padLeft(2, '0');

    return '$minutesStr:$secondsStr';
  }

  // 处理消息点击
  void _handleMessageTap(Message message) {
    try {
      if (message.type == MessageType.image) {
        _openImageMessage(message);
      } else if (message.type == MessageType.video) {
        _openVideoMessage(message);
      } else if (message.type == MessageType.file) {
        _openFile(message);
      } else if (message.type == MessageType.voice) {
        _playVoiceMessage(message);
      }
    } catch (e) {
      dev.log('处理消息点击失败: $e');
      UINotificationService().showError('打开媒体失败: $e');
    }
  }

  // 打开图片消息
  void _openImageMessage(Message message) {
    try {
      final String localPath = message.localPath ?? '';
      final String? mediaUrl = message.mediaUrl;
      final String mediaMsgId = message.id.toString();
      final bool isCurrentUserSender = message.senderId == '1'; // 假设'1'是当前用户ID

      // 使用弹出浮窗方式查看图片
      if (!mounted) return;

      MediaOverlayViewer.show(
        context,
        imagePath: localPath,
        mediaUrl: mediaUrl,
        onDelete: isCurrentUserSender ? () => _deleteMessageById(mediaMsgId) : null,
      );
    } catch (e) {
      dev.log('打开图片消息失败: $e');
      UINotificationService().showError('无法打开图片: $e');
    }
  }

  // 打开视频消息
  void _openVideoMessage(Message message) {
    try {
      final String localPath = message.localPath ?? '';
      final String? mediaUrl = message.mediaUrl;
      final String mediaMsgId = message.id.toString();
      final bool isCurrentUserSender = message.senderId == '1'; // 假设'1'是当前用户ID

      // 使用弹出浮窗方式查看视频
      if (!mounted) return;

      MediaOverlayViewer.show(
        context,
        videoPath: localPath,
        mediaUrl: mediaUrl,
        onDelete: isCurrentUserSender ? () => _deleteMessageById(mediaMsgId) : null,
      );
    } catch (e) {
      dev.log('打开视频消息失败: $e');
      UINotificationService().showError('无法打开视频: $e');
    }
  }

  // 删除消息
  void _deleteMessageById(String messageId) {
    try {
      final chatCubit = context.read<ChatCubit>();
      chatCubit.deleteMessage(messageId);
    } catch (e) {
      dev.log('删除消息失败: $e');
      UINotificationService().showError('删除消息失败: $e');
    }
  }

  // 开始录音
  void _startRecording() async {
    // 已经在录音则不重复开始
    if (_isRecordingAudio) return;

    final success = await _mediaService.startRecording();
    if (!mounted) return;

    if (success) {
      // 添加触感反馈
      HapticFeedback.mediumImpact();

      // 震动屏幕反馈
      Future.delayed(const Duration(milliseconds: 50), () {
        HapticFeedback.vibrate();
      });

      // 显示录音开始提示
      UINotificationService().showSuccess('录音已开始', duration: const Duration(milliseconds: 500));

      setState(() {
        _isRecordingAudio = true;
        _isCancellingRecord = false;
        _recordStartTime = DateTime.now();
      });

      // 重新启动波形动画
      _waveformController.reset();
      _waveformController.repeat();
    } else {
      UINotificationService().showError('无法开始录音');
    }
  }

  // 停止录音
  void _stopRecording(bool send) async {
    if (!_isRecordingAudio) return;

    // 添加触感反馈
    HapticFeedback.mediumImpact();

    // 如果是在取消状态下停止录音，强制将send设为false
    if (_isCancellingRecord) {
      send = false;
    }

    // 重置录音状态
    setState(() {
      _isRecordingAudio = false;
      _isCancellingRecord = false;
    });

    if (!send) {
      // 取消录音
      _mediaService.stopRecording();
      // 使用通知服务，不需要检查mounted
      UINotificationService().showWarning('录音已取消');
      return;
    }

    // 显示处理中提示
    UINotificationService().showProcessing('正在处理语音消息...');

    // 计算录音时长
    final now = DateTime.now();
    final recordDuration = now.difference(_recordStartTime!).inMilliseconds;

    // 如果录音时间太短（小于1.5秒），显示提示
    if (recordDuration < 1500) {
      _mediaService.stopRecording();
      UINotificationService().hideCurrentMessage();
      UINotificationService().showError('录音时间太短，请至少录制1.5秒');
      return;
    }

    // 提前获取ChatCubit实例
    final chatCubit = context.read<ChatCubit>();
    final conversationId = widget.conversationId;

    // 停止录音并获取结果
    final result = await _mediaService.stopRecording();
    if (!mounted) return;

    if (result == null) {
      UINotificationService().hideCurrentMessage();
      UINotificationService().showError('录音失败');
      return;
    }

    // 上传语音文件
    final uploadResult = await _fileUploadService.uploadVoice(
      result.file,
      result.duration,
    );
    if (!mounted) return;

    if (uploadResult == null) {
      UINotificationService().hideCurrentMessage();
      UINotificationService().showError('语音上传失败');
      return;
    }

    // 发送语音消息
    await chatCubit.sendVoiceMessage(
      conversationId,
      uploadResult.localPath,
      uploadResult.duration ?? 0,
      mediaUrl: uploadResult.remoteUrl,
    );
    if (!mounted) return;

    // 隐藏处理中提示
    UINotificationService().hideCurrentMessage();

    // 滚动到底部
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _scrollToBottom();
      }
    });
  }

  // 格式化消息时间 - 遵循微信风格
  String _formatMessageTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final difference = today.difference(messageDate).inDays;

    // 格式化时间部分
    final timeStr = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

    if (messageDate == today) {
      // 今天的消息只显示时间
      return timeStr;
    } else if (messageDate == yesterday) {
      // 昨天的消息显示昨天+时间
      return '昨天 $timeStr';
    } else if (difference < 7) {
      // 一周内的消息显示星期几
      const weekdays = ['星期日', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六'];
      return '${weekdays[dateTime.weekday % 7]} $timeStr';
    } else if (dateTime.year == now.year) {
      // 同一年的消息显示月日+时间
      return '${dateTime.month}月${dateTime.day}日 $timeStr';
    } else {
      // 不同年的消息显示年月日+时间
      return '${dateTime.year}年${dateTime.month}月${dateTime.day}日 $timeStr';
    }
  }
}
