import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cc/core/database/models/user.dart';
import 'package:cc/core/database/models/message.dart';

import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/services/media_service.dart';
import 'package:cc/core/services/file_upload_service.dart';
import 'package:cc/core/services/ui_notification_service.dart';

import 'package:cc/features/home/presentation/cubit/home_cubit.dart';
import 'package:cc/features/home/presentation/cubit/home_state.dart';
import 'package:cc/features/chat/presentation/pages/chat_info_page.dart';

class ChatDetailPage extends StatefulWidget {
  final String conversationId;
  final User contact;

  const ChatDetailPage({
    super.key,
    required this.conversationId,
    required this.contact,
  });

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage>
    with TickerProviderStateMixin {
  final _logger = LogService.instance;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  bool _isLoadingMore = false;
  bool _dataInitialized = false;
  String? _targetMessageId; // 目标消息ID,用于滚动定位
  final List<Message> _messages = []; // 缓存的消息列表
  final bool _isJumpingToDate = false; // 控制日期跳转加载指示器

  // 录音波形动画控制
  late AnimationController _waveformController;

  // 媒体服务
  final MediaService _mediaService = MediaService();
  final FileUploadService _fileUploadService = FileUploadService();

  // 录音状态
  Timer? _recordingTimer;

  // 添加选择的附件状态
  File? _selectedAttachment;
  String? _attachmentType;
  String? _attachmentName;
  double? _attachmentSize;

  // 添加语音动画控制器
  late AnimationController _voiceAnimationController;

  @override
  void initState() {
    super.initState();
    _logger.i('初始化ChatDetailPage: conversationId=${widget.conversationId}');
    // 加载会话消息
    _loadConversation();

    // 监听滚动事件,用于加载历史消息
    _scrollController.addListener(_scrollListener);

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
    // 移除监听器和控制器
    _messageController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _focusNode.dispose();
    _waveformController.dispose();
    _voiceAnimationController.dispose();

    // 清理录音计时器
    _recordingTimer?.cancel();

    // 在微任务中安排媒体服务清理,避免在Navigator处于locked状态时执行
    Future.microtask(() {
      try {
        // 尝试停止所有音频播放
        _mediaService.stopAudio();
        _mediaService.disposeAudio();
      } catch (error) {
        _logger.e('清理媒体服务时出错: $error');
      }
    });

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
      final homeCubit = BlocProvider.of<HomeCubit>(context);

      // 设置当前会话ID
      homeCubit.loadMessagesForConversation(widget.conversationId);
    } catch (error) {
      _logger.e('加载会话失败: $error');
      UINotificationService().showError('加载会话失败: $error');
    }
  }

  // 滚动到底部
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      // 使用更激进的滚动策略,确保到达底部
      _scrollController.jumpTo(0);
      // 然后使用动画滚动确保UI平滑
      _scrollController.animateTo(
        0, // 因为reverse=true, 所以0是底部
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // 滚动监听器,用于加载更多历史消息
  void _scrollListener() {
    // 检测是否到达底部
    if (_scrollController.hasClients) {
      // 检测是否到达顶部（旧消息方向）,用于加载更多历史消息
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent * 0.9 &&
          !_isLoadingMore) {
        _loadMoreMessages();
      }
    }
  }

  // 加载更多历史消息
  Future<void> _loadMoreMessages() async {
    // 获取当前会话的消息
    final messages = context
            .read<HomeCubit>()
            .state
            .messagesByConversation[widget.conversationId] ??
        [];
    if (messages.isEmpty) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      // 获取最早的消息时间作为加载更多的基准
      final earliestMessage =
          messages.reduce((a, b) => a.createdAt.isBefore(b.createdAt) ? a : b);

      // TODO: 实现通过HomeCubit加载更早消息的逻辑
      // 暂时不支持加载更多历史消息，需要扩展HomeCubit以支持此功能
    } catch (error) {
      _logger.e('加载更多消息失败: $error');
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

    // 如果有选择的附件,发送附件
    if (_selectedAttachment != null && _attachmentType != null) {
      _sendAttachment();
      return;
    }

    // 否则发送文本消息
    if (message.isEmpty) return;

    // 创建消息对象
    final newMessage = Message()
      ..conversationId = widget.conversationId
      ..text = message;

    // 发送消息
    context.read<HomeCubit>().sendMessage(newMessage);

    _messageController.clear();

    // 强制设置为底部标志,确保新消息出现时滚动到底部
    setState(() {});

    // 滚动到底部
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  // 发送附件
  Future<void> _sendAttachment() async {
    if (_selectedAttachment == null || _attachmentType == null) return;

    try {
      // TODO: 实现通过HomeCubit发送附件的逻辑
      // 暂时不支持发送附件，需要扩展HomeCubit以支持此功能
      UINotificationService().showWarning('暂不支持发送附件');

      // 清除附件
      if (mounted) {
        setState(() {
          _selectedAttachment = null;
          _attachmentType = null;
          _attachmentName = null;
          _attachmentSize = null;
        });
      }
    } catch (error) {
      if (mounted) {
        UINotificationService().showError('发送附件失败: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (previous, current) =>
          previous.messagesByConversation != current.messagesByConversation ||
          previous.currentConversationId != current.currentConversationId ||
          previous.isLoadingMessages != current.isLoadingMessages,
      builder: (context, state) {
        // 获取当前会话的消息
        final messages =
            state.messagesByConversation[widget.conversationId] ?? [];

        return Scaffold(
          appBar: AppBar(
            title: Text(widget.contact.name),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () {
                  final homeCubit = context.read<HomeCubit>();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BlocProvider.value(
                        value: homeCubit,
                        child: ChatInfoPage(
                          conversationId: widget.conversationId,
                          contact: widget.contact,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          body: Column(
            children: [
              // 加载指示器
              if (state.isLoadingMessages) const LinearProgressIndicator(),

              // 消息列表
              Expanded(
                child: messages.isEmpty
                    ? const Center(child: Text('没有消息'))
                    : ListView.builder(
                        controller: _scrollController,
                        reverse: true,
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[index];
                          // 构建消息气泡
                          return ListTile(
                            title: Text(message.text ?? ''),
                            subtitle: Text(message.createdAt.toString()),
                          );
                        },
                      ),
              ),

              // 输入区域
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, -1),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.attach_file),
                      onPressed: () {
                        // TODO: 实现附件选择逻辑
                      },
                    ),
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        focusNode: _focusNode,
                        decoration: const InputDecoration(
                          hintText: '输入消息...',
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: _sendMessage,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
