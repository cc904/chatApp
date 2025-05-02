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
import 'package:path/path.dart' as path;
import 'package:intl/intl.dart';
import 'package:cc/features/chat/presentation/widgets/media_viewer.dart';
import 'package:video_player/video_player.dart';

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

  // 媒体服务
  final MediaService _mediaService = MediaService();
  final FileUploadService _fileUploadService = FileUploadService();

  // 录音状态
  bool _isRecordingVoice = false;

  // 添加选择的附件状态
  File? _selectedAttachment;
  MessageType? _attachmentType;
  String? _attachmentName;
  double? _attachmentSize;

  // 语音消息播放相关状态
  bool _isPlayingVoiceMessage = false;
  String? _currentPlayingVoiceId;
  double _voicePlayProgress = 0.0;

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

      switch (_attachmentType) {
        case MessageType.image:
          // 上传图片
          final uploadResult = await _fileUploadService.uploadImage(_selectedAttachment!);
          if (uploadResult == null) {
            _showErrorMessage('图片上传失败');
            return;
          }

          // 打印上传结果以便调试
          dev.log('图片上传成功: localPath=${uploadResult.localPath}, remoteUrl=${uploadResult.remoteUrl}');

          // 发送图片消息
          await context.read<ChatCubit>().sendImageMessage(
                widget.conversationId,
                uploadResult.localPath,
                mediaUrl: uploadResult.remoteUrl,
              );
          break;

        case MessageType.file:
          // 上传文件
          final uploadResult = await _fileUploadService.uploadFile(_selectedAttachment!);
          if (uploadResult == null) {
            _showErrorMessage('文件上传失败');
            return;
          }

          // 发送文件消息
          await context.read<ChatCubit>().sendFileMessage(
                widget.conversationId,
                uploadResult.localPath,
                _attachmentName ?? '未知文件',
                _attachmentSize ?? _selectedAttachment!.lengthSync().toDouble(),
                mediaUrl: uploadResult.remoteUrl,
              );
          break;

        case MessageType.video:
          // 上传视频
          final uploadResult = await _fileUploadService.uploadVideo(_selectedAttachment!);
          if (uploadResult == null) {
            _showErrorMessage('视频上传失败');
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
          await context.read<ChatCubit>().sendVideoMessage(
                widget.conversationId,
                uploadResult.localPath,
                videoDuration,
                thumbnailUrl: uploadResult.thumbnailUrl,
                mediaUrl: uploadResult.remoteUrl,
                isServerProcessed: uploadResult.serverProcessed,
              );

          dev.log(
              '视频发送成功: localPath=${uploadResult.localPath}, mediaUrl=${uploadResult.remoteUrl}, thumbnailUrl=${uploadResult.thumbnailUrl}, serverProcessed=${uploadResult.serverProcessed}');
          break;

        default:
          _showErrorMessage('不支持的附件类型');
          return;
      }

      // 清除附件
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
        _scrollToBottom();
      });

      // 再添加一次延迟滚动，以处理可能的数据库延迟
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _scrollToBottom();
        }
      });
    } catch (e) {
      _showErrorMessage('发送附件失败: $e');
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
                  else if (message.type == MessageType.video)
                    _buildVideoMessage(message)
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
    // 打印图片消息信息，便于调试
    dev.log('图片消息路径信息: localPath=${message.localPath}, mediaUrl=${message.mediaUrl}');

    // 优先使用本地路径
    if (message.localPath != null && message.localPath!.isNotEmpty) {
      return GestureDetector(
        onTap: () {
          MediaViewer.openImage(
            context,
            imagePath: message.localPath!,
            mediaUrl: message.mediaUrl,
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            File(message.localPath!),
            width: 200,
            height: 150,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              dev.log('本地图片加载失败: $error, 尝试加载mediaUrl');
              return _buildImageFromMediaUrl(message.mediaUrl);
            },
          ),
        ),
      );
    }

    // 尝试使用mediaUrl
    return _buildImageFromMediaUrl(message.mediaUrl);
  }

  // 从mediaUrl构建图片
  Widget _buildImageFromMediaUrl(String? mediaUrl) {
    if (mediaUrl == null || mediaUrl.isEmpty) {
      return _buildImageErrorPlaceholder();
    }

    // 处理file://协议的URL
    if (mediaUrl.startsWith('file://')) {
      final filePath = mediaUrl.substring(7); // 去除file://前缀
      dev.log('从file://URL加载本地图片: $filePath');

      return GestureDetector(
        onTap: () {
          MediaViewer.openImage(
            context,
            imagePath: filePath,
            mediaUrl: mediaUrl,
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            File(filePath),
            width: 200,
            height: 150,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              dev.log('file://URL图片加载失败: $error, 路径: $filePath');
              return _buildImageErrorPlaceholder();
            },
          ),
        ),
      );
    }

    // 处理网络URL
    return GestureDetector(
      onTap: () {
        MediaViewer.openImage(
          context,
          imagePath: "",
          mediaUrl: mediaUrl,
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          mediaUrl,
          width: 200,
          height: 150,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            dev.log('网络图片加载失败: $error');
            return _buildImageErrorPlaceholder();
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

  // 图片加载失败的占位符
  Widget _buildImageErrorPlaceholder() {
    return Container(
      width: 200,
      height: 150,
      color: Colors.grey[300],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.broken_image, color: Colors.grey, size: 48),
          const SizedBox(height: 8),
          Text(
            '图片加载失败',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // 构建视频消息
  Widget _buildVideoMessage(Message message) {
    // 打印视频消息信息，便于调试
    dev.log('视频消息路径信息: localPath=${message.localPath}, mediaUrl=${message.mediaUrl}, thumbnailUrl=${message.thumbnailUrl}, status=${message.status}');

    // 视频缩略图容器
    return GestureDetector(
      onTap: () {
        // 如果视频正在处理中，不允许播放
        if (message.status == 'processing') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('视频缩略图正在处理中，请稍后再试')),
          );
          return;
        }

        final localPath = message.localPath;
        final mediaUrl = message.mediaUrl;

        if (localPath == null && mediaUrl == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('无法播放：找不到视频文件')),
          );
          return;
        }

        // 使用工厂方法打开视频查看器
        MediaViewer.openVideo(
          context,
          videoPath: localPath ?? "",
          mediaUrl: mediaUrl,
        );
      },
      child: Container(
        width: 200,
        height: 150,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 根据消息状态显示不同的缩略图
            if (message.status == 'processing')
              _buildProcessingThumbnail()
            else if (message.thumbnailUrl != null && message.thumbnailUrl!.isNotEmpty)
              _buildVideoThumbnail(message.thumbnailUrl!)
            else if (message.status == 'thumbnail_failed')
              _buildThumbnailFailedPlaceholder()
            else
              _buildVideoPlaceholder(message),

            // 播放按钮
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 32,
              ),
            ),

            // 视频时长
            if (message.duration != null)
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _formatDuration(message.duration!),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // 构建处理中状态的缩略图
  Widget _buildProcessingThumbnail() {
    return Container(
      width: 200,
      height: 150,
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "服务器处理中...",
            style: TextStyle(color: Colors.white70, fontSize: 12),
          )
        ],
      ),
    );
  }

  // 构建缩略图处理失败的占位图
  Widget _buildThumbnailFailedPlaceholder() {
    return Container(
      width: 200,
      height: 150,
      decoration: BoxDecoration(
        color: Colors.red.shade800,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.white,
            size: 40,
          ),
          const SizedBox(height: 10),
          Text(
            "缩略图处理失败",
            style: TextStyle(color: Colors.white, fontSize: 12),
          )
        ],
      ),
    );
  }

  // 构建视频缩略图
  Widget _buildVideoThumbnail(String thumbnailUrl) {
    // 处理file://协议的URL
    if (thumbnailUrl.startsWith('file://')) {
      final filePath = thumbnailUrl.substring(7); // 去除file://前缀
      dev.log('从file://URL加载本地视频缩略图: $filePath');

      // 检查文件是否存在
      if (!File(filePath).existsSync()) {
        dev.log('本地视频缩略图文件不存在: $filePath');
        return _buildDefaultVideoThumbnail();
      }

      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          File(filePath),
          width: 200,
          height: 150,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            dev.log('本地视频缩略图加载失败: $error');
            return _buildDefaultVideoThumbnail();
          },
        ),
      );
    } else {
      // 处理网络URL
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          thumbnailUrl,
          width: 200,
          height: 150,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            dev.log('网络视频缩略图加载失败: $error');
            return _buildDefaultVideoThumbnail();
          },
        ),
      );
    }
  }

  // 构建默认视频缩略图
  Widget _buildDefaultVideoThumbnail() {
    return Container(
      width: 200,
      height: 150,
      decoration: BoxDecoration(
        color: Colors.blue.shade800,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Icon(
          Icons.videocam,
          color: Colors.white,
          size: 48,
        ),
      ),
    );
  }

  // 构建视频占位符，使用视频名称
  Widget _buildVideoPlaceholder(Message message) {
    final String fileName = _extractFileNameFromPath(message.localPath ?? message.mediaUrl ?? "未知视频");

    return Container(
      width: 200,
      height: 150,
      decoration: BoxDecoration(
        color: Colors.blue.shade800,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.videocam,
            color: Colors.white,
            size: 48,
          ),
          const SizedBox(height: 8),
          if (fileName.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                fileName.length > 20 ? '${fileName.substring(0, 17)}...' : fileName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  // 从路径中提取文件名
  String _extractFileNameFromPath(String path) {
    if (path.isEmpty) return "";

    try {
      if (path.startsWith('file://')) {
        path = path.substring(7);
      }

      return path.split('/').last;
    } catch (e) {
      dev.log('提取文件名失败: $e');
      return path;
    }
  }

  // 构建语音消息
  Widget _buildVoiceMessage(Message message) {
    final duration = message.duration ?? 0;
    final seconds = (duration / 1000).round();

    return GestureDetector(
      onTap: () => _playVoiceMessage(message),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _isPlayingVoiceMessage && _currentPlayingVoiceId == message.messageId ? Icons.pause : Icons.play_arrow,
              color: Colors.grey[700],
              size: 24,
            ),
            const SizedBox(width: 8),
            // 进度条
            Container(
              width: 80.0 + (seconds > 60 ? 80.0 : seconds.toDouble()),
              height: 2,
              decoration: BoxDecoration(
                gradient: _isPlayingVoiceMessage && _currentPlayingVoiceId == message.messageId
                    ? LinearGradient(
                        colors: [Colors.green, Colors.grey[400]!],
                        stops: [_voicePlayProgress, _voicePlayProgress],
                      )
                    : null,
                color: _isPlayingVoiceMessage && _currentPlayingVoiceId == message.messageId ? null : Colors.grey[400],
                borderRadius: BorderRadius.circular(1),
              ),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('无法打开：找不到文件')),
      );
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
        if (await file.exists()) {
          // 检查文件类型
          final extension = effectivePath.split('.').last.toLowerCase();

          // 特定类型使用特定查看器
          if (['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension)) {
            // 图片使用图片查看器
            MediaViewer.openImage(
              context,
              imagePath: effectivePath,
              mediaUrl: mediaUrl,
            );
          } else if (['mp4', 'mov', 'avi', 'mkv', 'webm'].contains(extension)) {
            // 视频使用视频查看器
            MediaViewer.openVideo(
              context,
              videoPath: effectivePath,
              mediaUrl: mediaUrl,
            );
          } else {
            // 其他文件尝试使用系统打开
            // 实际项目中，可以使用open_file或url_launcher等插件
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('尝试打开文件: $effectivePath')),
            );
            dev.log('打开文件: $effectivePath');
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('文件不存在')),
          );
        }
      } else if (mediaUrl != null) {
        // 处理网络文件
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('正在打开网络文件: $mediaUrl')),
        );
        dev.log('打开网络文件: $mediaUrl');
      }
    } catch (e) {
      dev.log('打开文件失败: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('打开文件失败: $e')),
      );
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
              color: Colors.black.withAlpha(26),
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
                  icon: const Icon(Icons.keyboard_voice),
                  color: Colors.grey[600],
                  onPressed: _handleRecordVoice,
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
                  onPressed: (_messageController.text.trim().isNotEmpty || _selectedAttachment != null) ? _sendMessage : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
    setState(() {
      _selectedAttachment = file;
      _attachmentType = MessageType.image;
      _attachmentName = path.basename(file.path);
      _attachmentSize = file.lengthSync().toDouble();
    });
  }

  // 处理拍照
  Future<void> _handleTakePhoto() async {
    _closeAttachmentMenu();

    final file = await _mediaService.pickImage(fromCamera: true);
    if (file == null) return;

    // 设置拍摄的照片附件
    setState(() {
      _selectedAttachment = file;
      _attachmentType = MessageType.image;
      _attachmentName = '拍摄的照片';
      _attachmentSize = file.lengthSync().toDouble();
    });
  }

  // 处理视频选择
  Future<void> _handlePickVideo() async {
    _closeAttachmentMenu();

    final file = await _mediaService.pickVideo(fromCamera: false);
    if (file == null) return;

    // 设置选择的视频附件
    setState(() {
      _selectedAttachment = file;
      _attachmentType = MessageType.video;
      _attachmentName = path.basename(file.path);
      _attachmentSize = file.lengthSync().toDouble();
    });
  }

  // 处理文件选择
  Future<void> _handlePickFile() async {
    _closeAttachmentMenu();

    final file = await _mediaService.pickFile();
    if (file == null) return;

    // 获取文件名
    final fileName = file.path.split('/').last;

    // 设置选择的文件附件
    setState(() {
      _selectedAttachment = file;
      _attachmentType = MessageType.file;
      _attachmentName = fileName;
      _attachmentSize = file.lengthSync().toDouble();
    });
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
          title: const Text('语音录制'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _isRecordingVoice ? Icons.mic : Icons.mic_none,
                size: 48,
                color: _isRecordingVoice ? Colors.red : Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                _isRecordingVoice ? '正在录音，点击停止...' : '点击开始录音',
                style: TextStyle(
                  color: _isRecordingVoice ? Colors.red : Colors.grey[600],
                ),
              ),
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
                  final success = await _mediaService.startRecording();
                  if (success) {
                    setState(() {
                      _isRecordingVoice = true;
                    });
                  } else {
                    _showErrorMessage('无法开始录音');
                    Navigator.of(context).pop(false);
                  }
                } else {
                  // 停止录音并处理录音结果
                  final result = await _mediaService.stopRecording();
                  setState(() {
                    _isRecordingVoice = false;
                  });

                  if (result == null) {
                    Navigator.of(context).pop(false);
                    return;
                  }

                  // 上传语音文件
                  final uploadResult = await _fileUploadService.uploadVoice(
                    result.file,
                    result.duration,
                  );

                  if (uploadResult == null) {
                    _showErrorMessage('语音上传失败');
                    Navigator.of(context).pop(false);
                    return;
                  }

                  // 发送语音消息
                  await context.read<ChatCubit>().sendVoiceMessage(
                        widget.conversationId,
                        uploadResult.localPath,
                        uploadResult.duration ?? 0,
                        mediaUrl: uploadResult.remoteUrl,
                      );

                  // 滚动到底部
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollToBottom();
                  });

                  Navigator.of(context).pop(true);
                }
              },
              child: Text(_isRecordingVoice ? '停止' : '开始'),
            ),
          ],
        );
      },
    );
  }

  // 显示错误消息
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // 播放语音消息
  Future<void> _playVoiceMessage(Message message) async {
    final localPath = message.localPath;
    final mediaUrl = message.mediaUrl;

    if (localPath == null && mediaUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('无法播放：找不到语音文件')),
      );
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

      if (_isPlayingVoiceMessage && _currentPlayingVoiceId == message.messageId) {
        // 正在播放当前语音，暂停
        _mediaService.pauseAudio();
        setState(() {
          _isPlayingVoiceMessage = false;
        });
        return;
      }

      // 停止之前的播放
      if (_isPlayingVoiceMessage) {
        _mediaService.stopAudio();
      }

      if (effectivePath != null) {
        // 开始播放
        final file = File(effectivePath);
        if (await file.exists()) {
          setState(() {
            _isPlayingVoiceMessage = true;
            _currentPlayingVoiceId = message.messageId;
            _voicePlayProgress = 0.0;
          });

          // 播放语音
          await _mediaService.playAudio(
            effectivePath,
            onProgress: (progress) {
              if (mounted) {
                setState(() {
                  _voicePlayProgress = progress;
                });
              }
            },
            onComplete: () {
              if (mounted) {
                setState(() {
                  _isPlayingVoiceMessage = false;
                  _currentPlayingVoiceId = null;
                  _voicePlayProgress = 0.0;
                });
              }
            },
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('语音文件不存在')),
          );
        }
      } else if (mediaUrl != null) {
        // 处理网络语音
        setState(() {
          _isPlayingVoiceMessage = true;
          _currentPlayingVoiceId = message.messageId;
          _voicePlayProgress = 0.0;
        });

        // 播放网络语音
        await _mediaService.playAudioFromUrl(
          mediaUrl,
          onProgress: (progress) {
            if (mounted) {
              setState(() {
                _voicePlayProgress = progress;
              });
            }
          },
          onComplete: () {
            if (mounted) {
              setState(() {
                _isPlayingVoiceMessage = false;
                _currentPlayingVoiceId = null;
                _voicePlayProgress = 0.0;
              });
            }
          },
        );
      }
    } catch (e) {
      dev.log('播放语音失败: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('播放语音失败: $e')),
      );
      setState(() {
        _isPlayingVoiceMessage = false;
        _currentPlayingVoiceId = null;
        _voicePlayProgress = 0.0;
      });
    }
  }

  // 格式化视频时长
  String _formatDuration(int milliseconds) {
    final duration = Duration(milliseconds: milliseconds);
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
