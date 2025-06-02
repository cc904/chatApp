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
import 'package:scrollview_observer/scrollview_observer.dart';

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
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final LogService _logger = LogService.instance;
  final MediaService _mediaService = MediaService();
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  // ScrollView Observer 控制器
  late ListObserverController _observerController;
  late ScrollController _scrollController;
  late ChatScrollObserver _chatObserver;
  late AnimationController _voiceAnimationController;
  late AnimationController _waveformController;

  // 状态变量
  bool _isLoadingMore = false;
  Timer? _readStatusDebounceTimer;
  final ValueNotifier<int> _unreadMsgCount = ValueNotifier<int>(0);
  double? _lastLoggedPosition; // 用于滚动日志的位置记录

  // 添加选择的附件状态
  File? _selectedAttachment;
  String? _attachmentType;

  // 页面覆盖层相关
  BuildContext? _pageOverlayContext;

  @override
  void initState() {
    super.initState();

    _logger.d('🏗️ ChatDetailPage: initState开始');

    // 添加生命周期观察者
    WidgetsBinding.instance.addObserver(this);

    // 初始化控制器
    _scrollController = ScrollController()..addListener(_scrollListener);
    _observerController = ListObserverController(controller: _scrollController)
      ..cacheJumpIndexOffset = false;

    // 初始化ChatScrollObserver
    _chatObserver = ChatScrollObserver(_observerController)
      ..fixedPositionOffset = 5
      ..toRebuildScrollViewCallback = () {
        _logger.d('🔄 ChatScrollObserver: 触发重建回调');
        if (mounted) {
          setState(() {});
        }
      };

    // 添加调试日志检查初始状态
    _logger.d('🏗️ ChatScrollObserver初始化完成', extra: {
      'isShrinkWrap': _chatObserver.isShrinkWrap,
      'fixedPositionOffset': _chatObserver.fixedPositionOffset,
    });

    _voiceAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _waveformController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // 初始化完成后滚动到底部
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _logger.d('🔄 initState: PostFrameCallback执行，恢复滚动位置');
      // 不要每次都滚动到底部，而是恢复上次的位置
      // _scrollToBottom();
      _restoreScrollPosition();
      _addUnreadTipView();
    });

    _logger.d('🏗️ ChatDetailPage: initState完成');
  }

  @override
  void dispose() {
    // 移除生命周期观察者
    WidgetsBinding.instance.removeObserver(this);

    // 移除监听器和控制器
    _messageController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _focusNode.dispose();
    _waveformController.dispose();
    _voiceAnimationController.dispose();
    _unreadMsgCount.dispose();

    // 清理防抖定时器
    _readStatusDebounceTimer?.cancel();

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

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();

    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    _logger.d('⌨️ didChangeMetrics: 屏幕尺寸变化', extra: {
      'viewInsetsBottom': viewInsets,
      'isKeyboardVisible': viewInsets > 0,
      'shrinkWrapBefore': _chatObserver.isShrinkWrap,
    });

    // 键盘弹出或收起时更新shrinkWrap
    _chatObserver.observeSwitchShrinkWrap();

    _logger.d('⌨️ didChangeMetrics: shrinkWrap状态更新', extra: {
      'shrinkWrapAfter': _chatObserver.isShrinkWrap,
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        if (viewInsets == 0) {
          _logger.d('⌨️ didChangeMetrics: 键盘收起');
        } else {
          _logger.d('⌨️ didChangeMetrics: 键盘弹出，滚动到底部');
          _scrollToBottom();
        }
      }
    });
  }

  // 滚动到底部（新消息方向）
  void _scrollToBottom() {
    if (!_scrollController.hasClients) {
      _logger.d('🔄 _scrollToBottom: ScrollController没有客户端，跳过滚动');
      return;
    }

    final currentPosition = _scrollController.position.pixels;

    _logger.d('🔄 _scrollToBottom: 开始滚动到底部', extra: {
      'currentPosition': currentPosition,
      'maxScrollExtent': _scrollController.position.maxScrollExtent,
      'targetPosition': 0.0, // reverse=true时，0.0是底部
      'needsScroll': currentPosition > 0.0,
    });

    // 使用更短的动画时间，减少跳转感
    _scrollController
        .animateTo(
      0.0, // reverse=true时，滚动到0.0是底部
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
    )
        .then((_) {
      _logger.d('🔄 _scrollToBottom: 滚动动画完成', extra: {
        'finalPosition': _scrollController.position.pixels,
        'maxScrollExtent': _scrollController.position.maxScrollExtent,
      });
    });
  }

  /// 恢复滚动位置
  void _restoreScrollPosition() {
    try {
      final chatCubit = context.read<ChatCubit>();
      final state = chatCubit.state;

      // 如果有消息缓存且有保存的滚动位置，恢复到该位置
      if (state.messages.isNotEmpty) {
        // 如果有未读消息，设置未读消息计数但保持当前位置
        if (state.unreadCount > 0) {
          _logger.d('🔄 _restoreScrollPosition: 有未读消息，保持位置并显示未读提示', extra: {
            'unreadCount': state.unreadCount,
          });
          _unreadMsgCount.value = state.unreadCount;
          return;
        }
      }

      // 如果没有特殊位置需要恢复，检查是否是新会话
      if (state.messages.isEmpty) {
        _logger.d('🔄 _restoreScrollPosition: 新会话，无需滚动');
        return;
      }

      // 默认情况：保持当前位置，不自动滚动
      _logger.d('🔄 _restoreScrollPosition: 保持当前位置', extra: {
        'currentPosition': _scrollController.position.pixels,
        'messagesCount': state.messages.length,
      });
    } catch (error) {
      _logger.e('恢复滚动位置失败', error: error);
      // 如果恢复失败，保持当前位置
    }
  }

  // 简化的滚动监听器
  void _scrollListener() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;

    // 添加详细的滚动调试日志
    final currentPosition = position.pixels;

    if (_lastLoggedPosition == null ||
        (currentPosition - _lastLoggedPosition!).abs() > 50) {
      _logger.d('📜 滚动监听器: 位置变化', extra: {
        'pixels': currentPosition,
        'minScrollExtent': position.minScrollExtent, // reverse=true时这是底部(0.0)
        'maxScrollExtent': position.maxScrollExtent, // reverse=true时这是顶部
        'viewportDimension': position.viewportDimension,
        'atTop':
            currentPosition >= position.maxScrollExtent - 200, // 接近顶部(历史消息)
        'atBottom': currentPosition <= 50, // 接近底部(最新消息)
        'physics': position.physics.toString(),
        'shrinkWrap': _chatObserver.isShrinkWrap,
        'canScroll': position.maxScrollExtent > 0,
      });
      _lastLoggedPosition = currentPosition;
    }

    // 检测是否接近顶部（加载更多历史消息）
    if (position.pixels >= position.maxScrollExtent - 200 && !_isLoadingMore) {
      _logger.i('📜 滚动监听器: 接近顶部，触发加载更多消息');
      _loadMoreMessages();
    }

    // 检测是否接近底部，重置未读消息计数
    if (position.pixels <= 50) {
      // reverse=true时，接近0就是接近底部
      if (_unreadMsgCount.value > 0) {
        _logger.d('📜 滚动监听器: 接近底部，重置未读消息计数', extra: {
          'previousUnreadCount': _unreadMsgCount.value,
        });
        _unreadMsgCount.value = 0;
      }
    }

    // 延迟更新阅读状态
    _updateLastReadMessageIdDebounced();
  }

  /// 更新最后阅读的消息ID（防抖处理）
  void _updateLastReadMessageIdDebounced() {
    _readStatusDebounceTimer?.cancel();
    _readStatusDebounceTimer = Timer(const Duration(milliseconds: 800), () {
      if (mounted) {
        _updateLastReadMessageIdFromScroll();
      }
    });
  }

  /// 从滚动位置更新最后阅读的消息ID
  void _updateLastReadMessageIdFromScroll() {
    try {
      final chatCubit = context.read<ChatCubit>();
      final messages = chatCubit.state.messages;
      if (messages.isEmpty) return;

      // 简化逻辑：取当前可见区域中间的消息
      final viewportHeight = _scrollController.position.viewportDimension;
      final scrollOffset = _scrollController.position.pixels;
      final middlePosition = scrollOffset + viewportHeight / 2;

      // 估算消息索引（每条消息约80像素高度）
      const estimatedMessageHeight = 80.0;
      final estimatedIndex = (middlePosition / estimatedMessageHeight).floor();

      // 因为消息是升序排列，索引直接对应消息位置
      final visibleIndex =
          math.max(0, math.min(estimatedIndex, messages.length - 1));

      final visibleMessage = messages[visibleIndex];
      if (visibleMessage.messageId.isNotEmpty) {
        chatCubit.updateLastReadMessageId(visibleMessage.messageId);
      }
    } catch (error) {
      _logger.e('更新最后阅读消息ID失败', error: error);
    }
  }

  // 加载更多历史消息（简化版本）
  Future<void> _loadMoreMessages() async {
    final chatCubit = context.read<ChatCubit>();

    if (!chatCubit.state.canLoadMoreHistory) {
      _logger.i('没有更多历史消息可加载');
      return;
    }

    setState(() {
      _isLoadingMore = true;
    });

    try {
      await chatCubit.loadMoreMessages();
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

    _logger.i('💬 发送消息: 开始发送文本消息', extra: {
      'messageLength': message.length,
      'currentScrollPosition': _scrollController.hasClients
          ? _scrollController.position.pixels
          : null,
    });

    // 清空输入框
    _messageController.clear();

    // 调用ChatCubit发送文本消息
    context.read<ChatCubit>().sendTextMessage(message);

    // 延迟滚动，确保消息已经添加到列表中
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted && _scrollController.hasClients) {
        _logger.d('🔄 发送消息: 延迟滚动执行');
        _scrollToBottomAfterMessageSent();
      }
    });
  }

  // 发送消息后滚动到底部的专用方法
  void _scrollToBottomAfterMessageSent() {
    if (!_scrollController.hasClients) {
      _logger.w('🔄 发送消息后滚动: ScrollController没有客户端');
      return;
    }

    // 等待下一帧，确保ListView已经重建
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) {
        _logger.w('🔄 发送消息后滚动: 组件已销毁或ScrollController无效');
        return;
      }

      final beforePosition = _scrollController.position.pixels;

      _logger.d('🔄 发送消息后滚动: 执行滚动', extra: {
        'beforePosition': beforePosition,
        'targetPosition': 0.0,
        'needsScroll': beforePosition > 50, // 如果距离底部超过50像素才滚动
      });

      // 发送消息后总是滚动到底部，因为这是用户主动操作
      _scrollController
          .animateTo(
        0.0, // reverse=true时，滚动到0.0是底部
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      )
          .then((_) {
        _logger.d('🔄 发送消息后滚动: 滚动完成', extra: {
          'finalPosition': _scrollController.hasClients
              ? _scrollController.position.pixels
              : null,
        });
      }).catchError((error) {
        _logger.e('🔄 发送消息后滚动: 滚动失败', error: error);
      });
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
    return BlocBuilder<ChatCubit, ChatState>(
      buildWhen: (previous, current) {
        // 优化重建条件，减少不必要的重建
        // 只有在消息数量变化或重要状态变化时才重建
        bool shouldRebuild =
            previous.messages.length != current.messages.length ||
          previous.isLoadingMessages != current.isLoadingMessages ||
          previous.networkStatus != current.networkStatus ||
                previous.isSending != current.isSending ||
                (previous.conversationId != current.conversationId);

        if (shouldRebuild) {
          _logger.d('🔄 BlocBuilder: 触发重建', extra: {
            'messagesLengthChanged':
                previous.messages.length != current.messages.length,
            'previousMessagesLength': previous.messages.length,
            'currentMessagesLength': current.messages.length,
            'isLoadingChanged':
                previous.isLoadingMessages != current.isLoadingMessages,
            'networkStatusChanged':
                previous.networkStatus != current.networkStatus,
            'isSendingChanged': previous.isSending != current.isSending,
            'conversationChanged':
                previous.conversationId != current.conversationId,
          });

          // 如果消息数量增加了，说明有新消息，需要滚动到底部
          if (previous.messages.length < current.messages.length) {
            _logger.d('🔄 BlocBuilder: 检测到新消息，准备滚动到底部');
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && _scrollController.hasClients) {
                // 检查是否接近底部，如果是则自动滚动
                final position = _scrollController.position;
                final isNearBottom =
                    position.pixels <= 200; // reverse=true时，接近0是底部

                if (isNearBottom) {
                  _logger.d('🔄 BlocBuilder: 用户在底部附近，自动滚动到新消息');
                  _scrollToBottom();
                } else {
                  _logger.d('🔄 BlocBuilder: 用户不在底部，显示未读消息提示', extra: {
                    'currentPosition': position.pixels,
                    'maxScrollExtent': position.maxScrollExtent,
                    'distanceFromBottom':
                        position.pixels, // reverse=true时，pixels就是距离底部的距离
                  });
                  // 增加未读消息计数
                  _unreadMsgCount.value +=
                      (current.messages.length - previous.messages.length);
                }
              }
            });
          }
        }

        return shouldRebuild;
      },
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
                    previous.isLoadingMessages != current.isLoadingMessages,
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
                    isLoading: state.isLoadingMessages,
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
              // 消息缓存状态指示器
              if (state.messages.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(right: 8.0),
                  child: IconButton(
                    icon: Icon(
                      Icons.cached,
                      color: Colors.white.withAlpha(179),
                      size: 20,
                    ),
                    onPressed: () => _showCacheStats(context, state),
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

              // SVG图案背景
              Positioned.fill(
                child: _buildSvgBackground(),
              ),

              // 主要内容
              _buildBody(messages, currentUserId, state),

              // 页面覆盖层
              _buildPageOverlay(),
            ],
          ),
        );
      },
    );
  }

  /// 构建页面覆盖层
  Widget _buildPageOverlay() {
    return Overlay(initialEntries: [
      OverlayEntry(
        builder: (context) {
          _pageOverlayContext = context;
          return Container();
        },
      )
    ]);
  }

  /// 构建主体内容
  Widget _buildBody(
      List<Message> messages, String currentUserId, ChatState state) {
    // 使用GestureDetector处理点击和拖拽时收起键盘
    Widget resultWidget = GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      onPanDown: (_) {
        FocusScope.of(context).unfocus();
      },
      child: Column(
                children: [
                  // 加载指示器
                  if (state.isLoadingMessages)
                    LinearProgressIndicator(
                      backgroundColor: Colors.green.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade400),
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
                          state.isLoadingMessages ? '正在加载消息...' : '没有消息',
                                  style: TextStyle(
                                    color: Colors.white.withAlpha(153),
                                    fontSize: 16,
                                  ),
                                ),
                        if (state.messages.isNotEmpty &&
                                    !state.isLoadingMessages)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                              '使用消息缓存',
                                      style: TextStyle(
                                        color: Colors.white.withAlpha(128),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          )
                        : _buildMessageList(messages, currentUserId),
                  ),

                  // 输入区域
                  _buildInputArea(),
            ],
          ),
        );

    return resultWidget;
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

  /// 显示消息缓存统计信息
  void _showCacheStats(BuildContext context, ChatState state) {
    final stats = context.read<ChatCubit>().getCacheStats();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('消息缓存状态'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('当前消息数: ${state.messages.length}'),
            Text('未读消息: ${state.unreadCount}'),
            if (state.hasMoreHistory) const Text('📚 有更多历史消息'),
            if (state.hasMoreRecent) const Text('📬 有更多新消息'),
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
              context.read<ChatCubit>().forceRefresh();
              Navigator.of(context).pop();
            },
            child: const Text('刷新缓存'),
          ),
          TextButton(
            onPressed: () {
              context.read<ChatCubit>().clearMessageCache();
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

  /// 添加未读消息提示视图
  void _addUnreadTipView() {
    if (_pageOverlayContext == null) return;

    Overlay.of(_pageOverlayContext!).insert(OverlayEntry(
      builder: (BuildContext context) => Positioned(
        bottom: 80, // 在输入框上方
        right: 16, // 右下角
        child: Material(
          type: MaterialType.transparency,
          child: _buildUnreadTipView(),
        ),
      ),
    ));
  }

  /// 构建未读消息提示视图
  Widget _buildUnreadTipView() {
    return ValueListenableBuilder<int>(
      builder: (context, value, child) {
        return ChatUnreadTipView(
          unreadMsgCount: _unreadMsgCount.value,
          onTap: () {
            _logger.d('🔄 未读消息提示: 点击滚动到底部', extra: {
              'unreadCount': _unreadMsgCount.value,
              'currentPosition': _scrollController.hasClients
                  ? _scrollController.position.pixels
                  : null,
            });

            _scrollController
                .animateTo(
              0.0, // reverse=true时，滚动到0.0是底部
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            )
                .then((_) {
              _logger.d('🔄 未读消息提示: 滚动完成');
            });

            _unreadMsgCount.value = 0;
          },
        );
      },
      valueListenable: _unreadMsgCount,
    );
  }

  /// 构建消息列表（使用ChatScrollObserver优化）
  Widget _buildMessageList(List<Message> messages, String currentUserId) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // 添加调试日志
        _logger.d('🏗️ _buildMessageList: 构建消息列表', extra: {
          'messagesCount': messages.length,
          'isShrinkWrap': _chatObserver.isShrinkWrap,
          'constraintsMaxHeight': constraints.maxHeight,
          'constraintsMaxWidth': constraints.maxWidth,
        });

        // 智能判断是否真的需要shrinkWrap
        // 只有在键盘弹出且内容高度小于可用高度时才使用shrinkWrap
        final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
        final isKeyboardVisible = keyboardHeight > 0;
        final shouldUseShrinkWrap =
            isKeyboardVisible && _chatObserver.isShrinkWrap;

        _logger.d('🏗️ _buildMessageList: 智能shrinkWrap判断', extra: {
          'keyboardHeight': keyboardHeight,
          'isKeyboardVisible': isKeyboardVisible,
          'observerShrinkWrap': _chatObserver.isShrinkWrap,
          'shouldUseShrinkWrap': shouldUseShrinkWrap,
        });

        Widget resultWidget = ListView.builder(
          key: const ValueKey('chat_message_list'),
          // 智能选择滚动物理效果：即使在shrinkWrap模式下也保持滚动能力
          physics: shouldUseShrinkWrap
              ? const ClampingScrollPhysics() // 在shrinkWrap模式下使用Clamping物理效果
              : const AlwaysScrollableScrollPhysics(), // 正常模式下使用Always物理效果
          padding: const EdgeInsets.only(
            left: 10,
            right: 10,
            top: 15,
            bottom: 15,
          ),
          // 智能使用shrinkWrap
          shrinkWrap: shouldUseShrinkWrap,
          reverse: true, // 反向滚动，最新消息在底部
          controller: _scrollController,
          itemBuilder: (context, index) {
            // 因为是reverse=true，所以需要反转索引
            final reversedIndex = messages.length - 1 - index;
            final message = messages[reversedIndex];
              final isMe = message.senderId == currentUserId;

              // 检查是否需要显示日期分隔符
            final showDate = reversedIndex == 0 ||
                !_isSameDay(
                    message.createdAt, messages[reversedIndex - 1].createdAt);

            // 检查是否是连续消息的最后一条（需要显示尾巴）
            final isLastInSequence = _isLastMessageInSequence(
                messages, reversedIndex, currentUserId);

              return Padding(
                padding:
                  const EdgeInsets.symmetric(horizontal: 6.0, vertical: 1.0),
                child: Column(
                key: ValueKey('${message.messageId}_$reversedIndex'),
                  children: [
                    // 日期分隔符
                    if (showDate) _buildDateSeparator(message.createdAt),

                    // 消息气泡
                    MessageBubble(
                    key: ValueKey(message.messageId),
                      message: message,
                      isMe: isMe,
                      timeString: _formatMessageTime(message.createdAt),
                      senderName: isMe ? 'You' : widget.contact.name,
                    showTail: isLastInSequence,
                    onRemove: () {
                      // TODO: 实现消息删除逻辑
                    },
                    ),
                  ],
                ),
              );
            },
          itemCount: messages.length,
        );

        // 只在真正需要时使用SingleChildScrollView包装
        if (shouldUseShrinkWrap) {
          _logger.d('🏗️ _buildMessageList: 使用shrinkWrap模式，但保持滚动能力');
          resultWidget = SingleChildScrollView(
            reverse: true,
            physics: const ClampingScrollPhysics(), // 确保可以滚动
            child: Container(
              alignment: Alignment.topCenter,
              height: constraints.maxHeight + 0.001,
              child: resultWidget,
            ),
          );
        } else {
          _logger.d('🏗️ _buildMessageList: 使用正常ListView模式');
        }

        // 包装在ListViewObserver中
        resultWidget = ListViewObserver(
          controller: _observerController,
          child: resultWidget,
        );

        resultWidget = Align(
          alignment: Alignment.topCenter,
          child: resultWidget,
        );

        return resultWidget;
      },
    );
  }

  /// 判断是否是连续消息序列中的最后一条
  bool _isLastMessageInSequence(
      List<Message> messages, int currentIndex, String currentUserId) {
    final currentMessage = messages[currentIndex];

    // 如果是最后一条消息，肯定是序列中的最后一条
    if (currentIndex == messages.length - 1) return true;

    // 检查下一条消息是否是同一发送者
    final nextMessage = messages[currentIndex + 1];

    // 如果下一条消息的发送者不同，则当前消息是序列中的最后一条
    if (currentMessage.senderId != nextMessage.senderId) return true;

    // 如果时间间隔超过5分钟，也认为是不同的消息序列
    final timeDiff = nextMessage.createdAt.difference(currentMessage.createdAt);
    if (timeDiff.inMinutes > 5) return true;

    return false;
  }

  /// 构建输入区域
  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
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
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(24.0),
              ),
              child: TextField(
                controller: _messageController,
                focusNode: _focusNode,
                maxLines: 4,
                minLines: 1,
                decoration: const InputDecoration(
                  hintText: 'Message',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  isCollapsed: true,
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
    );
  }
}

/// 未读消息提示组件
class ChatUnreadTipView extends StatelessWidget {
  final int unreadMsgCount;
  final VoidCallback? onTap;

  const ChatUnreadTipView({
    super.key,
    required this.unreadMsgCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (unreadMsgCount == 0) return const SizedBox.shrink();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16, right: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.green.shade600,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(51),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.keyboard_arrow_down,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              '$unreadMsgCount 条新消息',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
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
  final bool showTail; // 是否显示小尾巴
  final VoidCallback? onRemove;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.timeString,
    required this.senderName,
    required this.showTail,
    this.onRemove,
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
    Widget resultWidget = Padding(
      padding: EdgeInsets.only(
        top: 2.0,
        bottom: showTail ? 8.0 : 2.0, // 有尾巴的消息底部间距更大
        left: isMe ? 50.0 : 0.0, // 自己的消息左侧留更多空间
        right: isMe ? 0.0 : 50.0, // 对方的消息右侧留更多空间
      ),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 消息气泡
          Flexible(
            child: GestureDetector(
              onTap: () => _handleMessageTap(context),
              child: Container(
            constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                  minWidth: 60.0, // 最小宽度确保时间显示
            ),
            decoration: BoxDecoration(
                  color: _getMessageBubbleColor(),
                  borderRadius: _getBorderRadius(),
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
                  mainAxisSize: MainAxisSize.min,
              children: [
                    // 消息内容
                    if (message.text?.isNotEmpty == true)
                      Text(
                        message.text!,
                        style: TextStyle(
                          fontSize: 16.0,
                          color: _getMessageTextColor(),
                        ),
                      ),

                    // 错误信息（仅失败消息显示）
                    if (message.status == 'failed' &&
                        message.errorMessage != null)
                  Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                          message.errorMessage!,
                      style: TextStyle(
                        fontSize: 12.0,
                            color: Colors.red.shade300,
                            fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),

                    // 时间和状态显示在气泡内部右下角
                    const SizedBox(height: 4.0),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Spacer(),
                Text(
                          timeString,
                  style: TextStyle(
                            fontSize: 11.0,
                            color: _getTimeTextColor(),
                          ),
                        ),
                        // 状态指示器（仅自己的消息）
                        if (isMe) ...[
                          const SizedBox(width: 4.0),
                          _buildMessageStatusIcon(),
                        ],
                      ],
                    ),
                  ],
                ),
                ),
              ),
            ),
        ],
      ),
    );

    // 添加滑动删除功能
    if (onRemove != null) {
      resultWidget = Dismissible(
        key: UniqueKey(),
        onDismissed: (_) {
          onRemove?.call();
        },
        child: resultWidget,
      );
    }

    return resultWidget;
  }

  /// 处理消息点击事件
  void _handleMessageTap(BuildContext context) {
    if (isMe && message.status == 'failed') {
      // 失败的消息显示重发选项
      _showResendDialog(context);
    }
  }

  /// 显示重发对话框
  void _showResendDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('消息发送失败'),
        content: Text(message.errorMessage ?? '发送失败，是否重新发送？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<ChatCubit>().resendMessage(message.messageId);
            },
            child: const Text('重发'),
          ),
        ],
      ),
    );
  }

  /// 获取消息气泡颜色
  Color _getMessageBubbleColor() {
    if (message.status == 'failed') {
      return isMe ? Colors.red.shade300 : Colors.white;
    }
    return isMe ? Colors.green.shade400 : Colors.white;
  }

  /// 获取消息文本颜色
  Color _getMessageTextColor() {
    if (message.status == 'failed') {
      return isMe ? Colors.white : Colors.black87;
    }
    return isMe ? Colors.white : Colors.black87;
  }

  /// 获取时间文本颜色
  Color _getTimeTextColor() {
    if (message.status == 'failed') {
      return isMe ? Colors.white.withAlpha(179) : Colors.grey.shade600;
    }
    return isMe ? Colors.white.withAlpha(179) : Colors.grey.shade600;
  }

  /// 构建消息状态图标
  Widget _buildMessageStatusIcon() {
    switch (message.status) {
      case 'pending':
      case 'sending':
        return SizedBox(
          width: 14.0,
          height: 14.0,
          child: CircularProgressIndicator(
            strokeWidth: 2.0,
            valueColor: AlwaysStoppedAnimation<Color>(
              Colors.white.withAlpha(179),
            ),
          ),
        );
      case 'failed':
        return Icon(
          Icons.error_outline,
          size: 14.0,
          color: Colors.red.shade200,
        );
      case 'sent':
        return Icon(
          Icons.done,
          size: 14.0,
          color: Colors.white.withAlpha(179),
        );
      case 'delivered':
        return Icon(
          Icons.done_all,
          size: 14.0,
          color: Colors.white.withAlpha(179),
        );
      case 'read':
        return Icon(
          Icons.done_all,
          size: 14.0,
          color: Colors.blue.shade200,
        );
      default:
        if (message.status == 'read') {
          return Icon(
            Icons.done_all,
            size: 14.0,
            color: Colors.blue.shade200,
          );
        } else {
          return Icon(
            Icons.done,
            size: 14.0,
            color: Colors.white.withAlpha(179),
          );
        }
    }
  }

  /// 获取气泡的圆角设置
  BorderRadius _getBorderRadius() {
    const radius = Radius.circular(18.0);
    const smallRadius = Radius.circular(4.0);

    if (showTail) {
      // 有尾巴的消息，对应角设为小圆角
      return BorderRadius.only(
        topLeft: radius,
        topRight: radius,
        bottomLeft: isMe ? radius : smallRadius,
        bottomRight: isMe ? smallRadius : radius,
      );
    } else {
      // 连续消息中间的消息，发送方向的上下角都是小圆角
      return BorderRadius.only(
        topLeft: isMe ? radius : smallRadius,
        topRight: isMe ? smallRadius : radius,
        bottomLeft: isMe ? radius : smallRadius,
        bottomRight: isMe ? smallRadius : radius,
      );
    }
  }

  /// 构建系统消息
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
}
