import 'dart:io';
import 'dart:async';
import 'dart:math' as math;
import 'package:cc/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:cc/features/chat/presentation/cubit/chat_state.dart';
import 'package:cc/features/chat/presentation/cubit/chats_cubit.dart';
import 'package:cc/features/home/presentation/cubit/home_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cc/core/database/models/user.dart';
import 'package:cc/core/database/models/message.dart';
import 'package:cc/features/chat/presentation/pages/chat_info_page.dart';
import 'package:cc/features/home/presentation/cubit/home_cubit.dart';

import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/services/media_service.dart';
import 'package:cc/core/services/ui_notification_service.dart';

import 'package:cc/core/widgets/user_avatar.dart';
import 'package:cc/features/home/presentation/widgets/network_status_indicator.dart';

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
  final LogService _logger = LogService.instance;
  final MediaService _mediaService = MediaService();
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  // 控制器声明
  late ScrollController _scrollController;
  late AnimationController _voiceAnimationController;
  late AnimationController _waveformController;

  // 状态变量
  bool _dataInitialized = false;
  bool _isLoadingMore = false;
  Timer? _recordingTimer;
  Timer? _debounceTimer; // 防抖定时器，用于限制更新最后阅读消息ID的频率

  // Timeline缓存相关状态
  bool _isRestoringFromCache = false;

  // 添加选择的附件状态
  File? _selectedAttachment;
  String? _attachmentType;

  @override
  void initState() {
    super.initState();
    // 初始化控制器
    _scrollController = ScrollController()..addListener(_scrollListener);
    _voiceAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _waveformController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // 确保数据仅被初始化一次
    if (!_dataInitialized) {
      _dataInitialized = true;

      // 延迟执行，确保ChatCubit完全初始化
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializeFromTimeline();
      });
    }
  }

  /// 从Timeline缓存初始化页面状态
  Future<void> _initializeFromTimeline() async {
    try {
      final chatCubit = context.read<ChatCubit>();
      final state = chatCubit.state;

      // 检查是否有Timeline和滚动位置
      if (state.timeline != null && state.currentScrollPosition != null) {
        setState(() {
          _isRestoringFromCache = true;
        });

        _logger.i('从Timeline缓存恢复页面状态', extra: {
          'scrollPosition': state.currentScrollPosition,
          'messageCount': state.timeline!.length,
        });

        // 等待UI构建完成后恢复滚动位置
        await Future.delayed(const Duration(milliseconds: 100));

        if (_scrollController.hasClients && mounted) {
          // 计算滚动位置（Timeline索引转换为像素位置）
          final pixelPosition =
              _calculateScrollPosition(state.currentScrollPosition!);
          _scrollController.jumpTo(pixelPosition);

          setState(() {
            _isRestoringFromCache = false;
          });
        }
      } else {
        // 没有缓存，滚动到底部
        _scrollToBottom();
      }
    } catch (error) {
      _logger.e('从Timeline缓存恢复失败', error: error);
      setState(() {
        _isRestoringFromCache = false;
      });
      _scrollToBottom();
    }
  }

  /// 计算滚动位置（Timeline索引转换为像素位置）
  double _calculateScrollPosition(int timelineIndex) {
    // 估算每条消息的高度（包括气泡、间距等）
    const estimatedMessageHeight = 80.0;

    // 由于ListView.reverse=true，需要进行位置转换
    final chatCubit = context.read<ChatCubit>();
    final totalMessages = chatCubit.state.messages.length;

    if (totalMessages == 0) return 0.0;

    // 计算从底部的距离
    final distanceFromBottom =
        (totalMessages - timelineIndex - 1) * estimatedMessageHeight;
    return distanceFromBottom.clamp(0.0, double.maxFinite);
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

    // 清理防抖定时器
    _debounceTimer?.cancel();

    // 离开会话由ChatCubit在其close方法中处理

    // 在微任务中安排媒体服务清理
    Future.microtask(() {
      try {
        _mediaService.stopAudio();
        _mediaService.disposeAudio();
      } catch (error) {
        _logger.e('清理媒体服务时出错: $error');
      }
    });

    super.dispose();
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

      // 更新Timeline的滚动位置
      _updateTimelineScrollPosition();

      // 更新最后阅读的消息ID
      _updateLastReadMessageIdFromScroll();
    }
  }

  /// 更新Timeline的滚动位置
  void _updateTimelineScrollPosition() {
    if (!_scrollController.hasClients || _isRestoringFromCache) return;

    try {
      final chatCubit = context.read<ChatCubit>();

      // 只有当有Timeline时才更新
      if (chatCubit.state.timeline != null) {
        // 计算当前可见的Timeline索引
        final timelineIndex = _calculateTimelineIndex();

        // 防抖更新，避免频繁调用
        _debounceTimer?.cancel();
        _debounceTimer = Timer(const Duration(milliseconds: 200), () {
          if (mounted) {
            chatCubit.updateScrollPosition(timelineIndex);
          }
        });
      }
    } catch (error) {
      _logger.e('更新Timeline滚动位置失败', error: error);
    }
  }

  /// 计算当前可见的Timeline索引
  int _calculateTimelineIndex() {
    if (!_scrollController.hasClients) return 0;

    const estimatedMessageHeight = 80.0;
    final scrollPosition = _scrollController.position.pixels;
    final totalMessages = context.read<ChatCubit>().state.messages.length;

    if (totalMessages == 0) return 0;

    // 由于ListView.reverse=true，需要进行位置转换
    final messageIndexFromBottom =
        (scrollPosition / estimatedMessageHeight).floor();
    final timelineIndex = totalMessages - messageIndexFromBottom - 1;

    return timelineIndex.clamp(0, totalMessages - 1);
  }

  /// 从滚动位置更新最后阅读的消息ID
  void _updateLastReadMessageIdFromScroll() {
    // 防抖处理，避免频繁更新
    if (!_scrollController.hasClients ||
        (_debounceTimer != null && _debounceTimer!.isActive)) {
      return;
    }

    // 设置防抖定时器，500毫秒内只处理一次
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      // 获取当前所有消息
      final chatCubit = context.read<ChatCubit>();
      final messages = chatCubit.state.messages;
      if (messages.isEmpty) return;

      // 计算当前可见的消息索引
      // 这里的计算方式是一个估算，假设每条消息高度约为80像素
      final scrollPosition = _scrollController.position.pixels;
      final estimatedIndex = (scrollPosition / 80.0).floor();

      // 确保索引在有效范围内
      final visibleIndex =
          math.max(0, math.min(estimatedIndex, messages.length - 1));
      final visibleMessage = messages[visibleIndex];

      // 更新最后阅读的消息ID
      final messageId = visibleMessage.messageId;
      if (messageId.isNotEmpty) {
        _updateLastReadMessageId(messageId);
      }
    });
  }

  // 加载更多历史消息
  Future<void> _loadMoreMessages() async {
    final chatCubit = context.read<ChatCubit>();
    final state = chatCubit.state;

    // 检查是否可以加载更多历史消息
    if (!state.canLoadMoreHistory) {
      _logger.i('没有更多历史消息可加载');
      return;
    }

    setState(() {
      _isLoadingMore = true;
    });

    try {
      // 如果没有消息，首先尝试从服务器获取历史消息
      if (state.messages.isEmpty) {
        _logger.i('消息列表为空，从服务器加载历史消息');
        await chatCubit.loadHistoryMessagesFromServer();
      } else {
        // 有消息时，使用Timeline的智能加载
        _logger.i('使用Timeline智能加载更多历史消息');

        // 获取最早的消息时间作为基准
        final messages = state.messages;
        final oldestMessage = messages
            .reduce((a, b) => a.createdAt.isBefore(b.createdAt) ? a : b);

        // 保存当前滚动位置
        final currentScrollPosition = _scrollController.hasClients
            ? _scrollController.position.pixels
            : 0.0;

        // 通过ChatCubit加载更多历史消息
        await chatCubit.loadMoreMessages(oldestMessage.createdAt);

        // 恢复滚动位置，考虑新增消息的影响
        if (_scrollController.hasClients && mounted) {
          // 计算新增消息的数量来调整滚动位置
          final newMessageCount =
              chatCubit.state.messages.length - messages.length;
          if (newMessageCount > 0) {
            const estimatedMessageHeight = 80.0;
            final adjustedPosition = currentScrollPosition +
                (newMessageCount * estimatedMessageHeight);

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_scrollController.hasClients && mounted) {
                _scrollController.jumpTo(adjustedPosition);
              }
            });
          }
        }
      }

      _logger.i('加载更多历史消息成功');
    } catch (error) {
      _logger.e('加载更多消息失败: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('加载历史消息失败: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
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

    // 调用ChatCubit发送文本消息
    context.read<ChatCubit>().sendTextMessage(message);

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
      // TODO: 实现通过ChatCubit发送附件的逻辑
      // 暂时不支持发送附件，需要扩展ChatCubit以支持此功能
      UINotificationService().showWarning('暂不支持发送附件');

      // 清除附件
      if (mounted) {
        setState(() {
          _selectedAttachment = null;
          _attachmentType = null;
        });
      }
    } catch (error) {
      if (mounted) {
        UINotificationService().showError('发送附件失败: $error');
      }
    }
  }

  // 格式化消息时间
  String _formatMessageTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(time.year, time.month, time.day);

    if (messageDate == today) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == yesterday) {
      return '昨天 ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else {
      return '${time.month}月${time.day}日 ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    // ChatCubit already provided by the parent, no need to create another one
    return BlocBuilder<ChatCubit, ChatState>(
      buildWhen: (previous, current) =>
          previous.messages != current.messages ||
          previous.isLoadingMessages != current.isLoadingMessages ||
          previous.isPreloading != current.isPreloading ||
          previous.networkStatus != current.networkStatus ||
          previous.timeline != current.timeline ||
          previous.currentScrollPosition != current.currentScrollPosition,
      builder: (context, state) {
        // 获取当前会话的消息
        final messages = state.messages;

        // 获取当前用户ID (从ChatsCubit获取当前用户信息)
        final currentUserId =
            context.read<ChatsCubit>().state.currentUser?.userId ?? '';

        return Scaffold(
          appBar: AppBar(
            title: GestureDetector(
              onTap: () => _openChatInfoPage(context),
              child: BlocBuilder<ChatCubit, ChatState>(
                buildWhen: (previous, current) =>
                    previous.networkStatus != current.networkStatus ||
                    previous.isLoadingMessages != current.isLoadingMessages ||
                    previous.isPreloading != current.isPreloading,
                builder: (context, state) {
                  // 将字符串类型的networkStatus转换为枚举类型
                  NetworkStatus status;
                  switch (state.networkStatus) {
                    case 'connecting':
                      status = NetworkStatus.connecting;
                      break;
                    case 'disconnected':
                      status = NetworkStatus.disconnected;
                      break;
                    case 'error':
                      status = NetworkStatus.error;
                      break;
                    case 'connected':
                    default:
                      status = NetworkStatus.connected;
                      break;
                  }

                  return AppBarTitleWithNetworkStatus(
                    title: widget.contact.name,
                    networkStatus: status,
                    isLoading: state.isLoadingMessages || state.isPreloading,
                    onRetry: () => context.read<ChatCubit>().reconnect(),
                  );
                },
              ),
            ),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            automaticallyImplyLeading: false,
            leading: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                padding: const EdgeInsets.only(left: 8.0),
                alignment: Alignment.centerLeft,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      size: 22,
                    ),
                    SizedBox(width: 2),
                    Text(
                      'Back',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                        fontWeight: FontWeight.normal,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            leadingWidth: 70,
            actions: [
              // Timeline缓存状态指示器
              if (state.timeline != null)
                Container(
                  margin: const EdgeInsets.only(right: 8.0),
                  child: IconButton(
                    icon: Icon(
                      Icons.cached,
                      color: Colors.white.withAlpha(179),
                      size: 20,
                    ),
                    onPressed: () => _showTimelineStats(context, state),
                  ),
                ),

              GestureDetector(
                onTap: () => _openChatInfoPage(context),
                child: Container(
                  margin: const EdgeInsets.only(right: 8.0),
                  child: Hero(
                    tag: 'avatar_${widget.conversationId}',
                    child: UserAvatar(
                      avatarUrl: widget.contact.avatar,
                      name: widget.contact.name,
                      radius: 22,
                      backgroundColor: Colors.cyan,
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: Stack(
            children: [
              // 绿色渐变背景
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.green.shade300,
                      Colors.green.shade100,
                    ],
                  ),
                ),
              ),

              // SVG图案背景 - 使用提供的SVG文件
              Positioned.fill(
                child: _buildSvgBackground(),
              ),

              // 主要内容
              Column(
                children: [
                  // 加载指示器
                  if (state.isLoadingMessages || state.isPreloading)
                    LinearProgressIndicator(
                      backgroundColor: Colors.green.shade100,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.green.shade400),
                    ),

                  // Timeline缓存恢复指示器
                  if (_isRestoringFromCache)
                    Container(
                      color: Colors.blue.shade50,
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.blue.shade400),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '正在从缓存恢复聊天记录...',
                            style: TextStyle(
                              color: Colors.blue.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // 消息列表
                  Expanded(
                    child: messages.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline,
                                  size: 48,
                                  color: Colors.white.withAlpha(153),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  state.isPreloading ? '正在加载消息...' : '没有消息',
                                  style: TextStyle(
                                    color: Colors.white.withAlpha(153),
                                    fontSize: 16,
                                  ),
                                ),
                                if (state.timeline != null &&
                                    !state.isPreloading)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      '使用Timeline缓存',
                                      style: TextStyle(
                                        color: Colors.white.withAlpha(128),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          )
                        : Stack(
                            children: [
                              ListView.builder(
                                controller: _scrollController,
                                reverse: true,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 8.0),
                                itemCount: messages.length,
                                itemBuilder: (context, index) {
                                  final message = messages[index];
                                  final isMe =
                                      message.senderId == currentUserId;

                                  // 检查是否需要显示日期分隔符
                                  final showDate =
                                      index == messages.length - 1 ||
                                          !_isSameDay(message.createdAt,
                                              messages[index + 1].createdAt);

                                  return Column(
                                    children: [
                                      // 日期分隔符
                                      if (showDate)
                                        _buildDateSeparator(message.createdAt),

                                      // 消息气泡
                                      MessageBubble(
                                        message: message,
                                        isMe: isMe,
                                        timeString: _formatMessageTime(
                                            message.createdAt),
                                        senderName:
                                            isMe ? 'You' : widget.contact.name,
                                      ),
                                    ],
                                  );
                                },
                              ),

                              // 加载更多指示器（顶部）
                              if (_isLoadingMore)
                                Positioned(
                                  top: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Center(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16.0, vertical: 8.0),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withAlpha(128),
                                          borderRadius:
                                              BorderRadius.circular(16.0),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(Colors.white),
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              '加载历史消息...',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                  ),

                  // 输入区域
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(26),
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
                          color: Colors.grey.shade600,
                          onPressed: () {
                            // TODO: 实现附件选择逻辑
                          },
                        ),
                        Expanded(
                          child: Container(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(24.0),
                            ),
                            child: TextField(
                              controller: _messageController,
                              focusNode: _focusNode,
                              decoration: const InputDecoration(
                                hintText: 'Message',
                                hintStyle: TextStyle(color: Colors.grey),
                                border: InputBorder.none,
                              ),
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send),
                          color: Colors.green,
                          onPressed: _sendMessage,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// 构建SVG背景
  Widget _buildSvgBackground() {
    // // 随机选择一个SVG图案
    // final random = Random();
    // final patternIndex = random.nextInt(3) + 13; // 从13, 15, 19中选择

    // 根据设备高度决定缩放和重复次数
    return LayoutBuilder(
      builder: (context, constraints) {
        return Opacity(
          opacity: 0.2, // 调整透明度以获得更好的可读性
          child: SvgPicture.asset(
            'assets/images/pattern-13.svg',
            fit: BoxFit.cover,
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            colorFilter: const ColorFilter.mode(
              Colors.white,
              BlendMode.srcIn,
            ),
          ),
        );
      },
    );
  }

  // 判断两个日期是否为同一天
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // 构建日期分隔符
  Widget _buildDateSeparator(DateTime date) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(51),
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Text(
            _formatDateSeparator(date),
            style: const TextStyle(
              fontSize: 12.0,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  // 格式化日期分隔符
  String _formatDateSeparator(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return '今天';
    } else if (dateOnly == yesterday) {
      return '昨天';
    } else {
      final months = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December'
      ];
      return '${months[date.month - 1]} ${date.day}';
    }
  }

  // 打开聊天信息页面
  void _openChatInfoPage(BuildContext context) {
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
  }

  /// 更新最后阅读的消息ID
  void _updateLastReadMessageId(String messageId) {
    _logger.i('更新最后阅读的消息ID: $messageId');
    try {
      final chatCubit = context.read<ChatCubit>();
      // 调用ChatCubit的方法更新最后阅读的消息ID
      chatCubit.updateLastReadMessageId(messageId);
    } catch (error) {
      _logger.e('更新最后阅读的消息ID失败', error: error);
    }
  }

  /// 显示Timeline缓存统计信息
  void _showTimelineStats(BuildContext context, ChatState state) {
    if (state.timeline == null) return;

    final stats = context.read<ChatCubit>().getCacheStats();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Timeline缓存状态'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('总消息数: ${state.timeline!.length}'),
            Text('未读消息: ${state.unreadCount}'),
            Text('滚动位置: ${state.currentScrollPosition ?? 'N/A'}'),
            if (state.timeline!.hasMoreHistory) const Text('📚 有更多历史消息'),
            if (state.timeline!.hasMoreRecent) const Text('📬 有更多新消息'),
            const SizedBox(height: 16),
            const Text('Repository缓存:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text('缓存会话数: ${stats['repository']['cachedConversations']}'),
            Text('总消息数: ${stats['repository']['totalMessages']}'),
            Text('内存使用: ${stats['repository']['estimatedMemoryMB']} MB'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.read<ChatCubit>().refreshTimeline();
              Navigator.of(context).pop();
            },
            child: const Text('刷新缓存'),
          ),
          TextButton(
            onPressed: () {
              context.read<ChatCubit>().clearTimelineCache();
              Navigator.of(context).pop();
            },
            child: const Text('清空缓存'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}

/// 消息气泡组件
class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;
  final String timeString;
  final String senderName;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.timeString,
    required this.senderName,
  });

  @override
  Widget build(BuildContext context) {
    // 判断消息类型
    final isSystemMessage = message.type == 'system';

    // 系统消息居中显示
    if (isSystemMessage) {
      return _buildSystemMessage();
    }

    // 普通消息
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 发送时间（左侧消息）
          if (!isMe && !isSystemMessage)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text(
                timeString,
                style: const TextStyle(
                  fontSize: 10.0,
                  color: Colors.white70,
                ),
              ),
            ),

          // 消息气泡
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            decoration: BoxDecoration(
              color: isMe ? Colors.green.shade300 : Colors.white,
              borderRadius: BorderRadius.circular(16.0).copyWith(
                bottomLeft: isMe
                    ? const Radius.circular(16.0)
                    : const Radius.circular(0.0),
                bottomRight: isMe
                    ? const Radius.circular(0.0)
                    : const Radius.circular(16.0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(13),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 发送者名称（仅群聊且非自己发送的消息显示）
                if (!isMe && _isGroupMessage(message))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Text(
                      senderName,
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.bold,
                        color: isMe ? Colors.white : Colors.blue,
                      ),
                    ),
                  ),

                // 消息内容
                Text(
                  message.text ?? '',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: isMe ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          // 发送时间（右侧消息）
          if (isMe && !isSystemMessage)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                timeString,
                style: const TextStyle(
                  fontSize: 10.0,
                  color: Colors.white70,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 构建系统消息
  Widget _buildSystemMessage() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(51),
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Text(
            message.text ?? '',
            style: const TextStyle(
              fontSize: 12.0,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  // 判断是否为群聊消息
  bool _isGroupMessage(Message message) {
    // 根据消息所属的会话类型判断
    // 在此示例中，简单地假设有发送者名称的消息是群聊消息
    return message.senderName != null;
  }
}
