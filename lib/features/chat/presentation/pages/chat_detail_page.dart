import 'dart:io';
import 'dart:async';
import 'dart:math' as math;
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

import 'package:cc/features/home/presentation/cubit/home_state.dart';
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

  // 添加HomeCubit引用
  late HomeCubit _homeCubit;

  // 控制器声明
  late ScrollController _scrollController;
  late AnimationController _voiceAnimationController;
  late AnimationController _waveformController;

  // 状态变量
  bool _dataInitialized = false;
  bool _isLoadingMore = false;
  Timer? _recordingTimer;
  Timer? _debounceTimer; // 防抖定时器，用于限制更新最后阅读消息ID的频率

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

    // 初始化数据
    _init();
  }

  Future<void> _init() async {
    _logger.i('初始化会话');
    try {
      final homeCubit = context.read<HomeCubit>();

      // 1. 进入会话（加入房间和注册事件处理器）
      await homeCubit.enterConversation(widget.conversationId);
      
      // 2. 获取当前会话和消息
      final conversation = homeCubit.state.currentConversation;
      final messages = homeCubit.state.currentMessages;
      
      // 3. 定位到上次阅读位置
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (conversation?.lastReadMessageId != null && messages.isNotEmpty) {
          // 如果有上次阅读位置，则滚动到该位置
          _scrollToMessage(conversation!.lastReadMessageId!);
          _logger.i('滚动到上次阅读位置: ${conversation.lastReadMessageId}');
        } else if (messages.isNotEmpty) {
          // 如果没有上次阅读位置但有消息，则滚动到底部
          _scrollToBottom();
          _logger.i('没有上次阅读位置，滚动到底部');
        }
      });
    } catch (error) {
      _logger.e('初始化会话失败: $error');
      UINotificationService().showError('初始化会话失败: $error');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // 保存HomeCubit引用，避免在dispose中查找
    _homeCubit = context.read<HomeCubit>();

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

    // 离开会话 - 使用已保存的HomeCubit引用
    final conversationId = widget.conversationId;
    Future.microtask(() {
      try {
        _homeCubit.leaveConversation(conversationId);
      } catch (e) {
        // 忽略可能的错误
      }
    });

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
      
      // 更新最后阅读的消息ID
      _updateLastReadMessageIdFromScroll();
    }
  }
  
  /// 从滚动位置更新最后阅读的消息ID
  void _updateLastReadMessageIdFromScroll() {
    // 防抖处理，避免频繁更新
    if (!_scrollController.hasClients || (_debounceTimer != null && _debounceTimer!.isActive)) {
      return;
    }
    
    // 设置防抖定时器，500毫秒内只处理一次
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      // 获取当前所有消息
      final homeCubit = context.read<HomeCubit>();
      final messages = homeCubit.state.messagesByConversation[widget.conversationId] ?? [];
      if (messages.isEmpty) return;
      
      // 计算当前可见的消息索引
      // 这里的计算方式是一个估算，假设每条消息高度约为80像素
      final scrollPosition = _scrollController.position.pixels;
      final estimatedIndex = (scrollPosition / 80.0).floor();
      
      // 确保索引在有效范围内
      final visibleIndex = math.max(0, math.min(estimatedIndex, messages.length - 1));
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
    // 获取当前会话的消息
    final homeCubit = context.read<HomeCubit>();
    final messages = homeCubit.state.messagesByConversation[widget.conversationId] ?? [];
    
    // 如果没有消息，尝试从服务器获取历史消息
    if (messages.isEmpty) {
      setState(() {
        _isLoadingMore = true;
      });
      
      try {
        // 从服务器获取历史消息
        await homeCubit.loadHistoryMessagesFromServer(widget.conversationId);
        _logger.i('从服务器加载历史消息成功');
      } catch (error) {
        _logger.e('从服务器加载历史消息失败: $error');
      } finally {
        if (mounted) {
          setState(() {
            _isLoadingMore = false;
          });
        }
      }
      return;
    }

    setState(() {
      _isLoadingMore = true;
    });

    try {
      // 获取最早的消息时间作为加载更多的基准
      final oldestMessage = messages.reduce((a, b) => a.createdAt.isBefore(b.createdAt) ? a : b);
      
      // 通过HomeCubit加载更多历史消息
      await homeCubit.loadMoreMessagesForConversation(widget.conversationId, oldestMessage.createdAt);
      _logger.i('加载更多历史消息成功');
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
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (previous, current) =>
          previous.messagesByConversation != current.messagesByConversation ||
          previous.currentConversationId != current.currentConversationId ||
          previous.isLoadingMessages != current.isLoadingMessages,
      builder: (context, state) {
        // 获取当前会话的消息
        final messages =
            state.messagesByConversation[widget.conversationId] ?? [];

        // 获取当前用户ID
        final currentUserId = state.currentUser?.userId ?? '';

        return Scaffold(
          appBar: AppBar(
            title: GestureDetector(
              onTap: () => _openChatInfoPage(context),
              child: BlocBuilder<HomeCubit, HomeState>(
                buildWhen: (previous, current) => 
                  previous.networkStatus != current.networkStatus ||
                  previous.isLoadingMessages != current.isLoadingMessages,
                builder: (context, state) {
                  return AppBarTitleWithNetworkStatus(
                    title: widget.contact.name,
                    networkStatus: state.networkStatus,
                    isLoading: state.isLoadingMessages,
                    onRetry: () => context.read<HomeCubit>().reconnect(),
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
                  if (state.isLoadingMessages) const LinearProgressIndicator(),

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
                                  '没有消息',
                                  style: TextStyle(
                                    color: Colors.white.withAlpha(153),
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            reverse: true,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              final message = messages[index];
                              final isMe = message.senderId == currentUserId;

                              // 检查是否需要显示日期分隔符
                              final showDate = index == messages.length - 1 ||
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
                                    timeString:
                                        _formatMessageTime(message.createdAt),
                                    senderName:
                                        isMe ? 'You' : widget.contact.name,
                                  ),
                                ],
                              );
                            },
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

  // 滚动到特定消息
  /// 更新最后阅读的消息ID
  void _updateLastReadMessageId(String messageId) {
    _logger.i('更新最后阅读的消息ID: $messageId');
    try {
      final homeCubit = context.read<HomeCubit>();
      // 调用ChatRepository的方法更新最后阅读的消息ID
      homeCubit.updateLastReadMessageId(widget.conversationId, messageId);
    } catch (error) {
      _logger.e('更新最后阅读的消息ID失败', error: error);
    }
  }

  /// 滚动到指定消息
  void _scrollToMessage(String messageId) {
    _logger.i('滚动到消息: $messageId');

    // 查找消息在列表中的位置
    final homeCubit = context.read<HomeCubit>();
    final messages =
        homeCubit.state.messagesByConversation[widget.conversationId] ?? [];

    final messageIndex = messages.indexWhere((m) => m.messageId == messageId);
    if (messageIndex != -1) {
      // 计算滚动位置
      final scrollPosition = messageIndex * 80.0; // 假设每条消息高度约为80

      // 滚动到指定位置
      _scrollController.animateTo(
        scrollPosition,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
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
