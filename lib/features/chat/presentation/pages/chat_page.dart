import 'dart:async';
import 'dart:math';
import 'dart:io';
import 'package:flutter/foundation.dart';

import 'package:cc/core/database/models/conversation.dart';
import 'package:cc/core/database/models/current_user.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/widgets/connection_status_indicator.dart';
import 'package:cc/features/chat/presentation/pages/chat_info_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:cc/core/database/models/message.dart';
import 'package:cc/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:cc/features/chat/presentation/cubit/chat_state.dart';
import 'package:cc/features/chat/presentation/widgets/message_item.dart';
import 'package:cc/features/chat/presentation/widgets/message_separators.dart';
import 'package:cc/features/chat/presentation/utils/message_list_processor.dart';
import 'package:cc/core/services/voice_record_service.dart';
import 'package:cc/core/services/file_upload_service.dart';
import 'package:cc/core/services/media_service.dart';
import 'package:cc/core/services/media_upload_integration_service.dart';
import 'package:cc/core/services/audio_player_manager.dart';
import 'package:cc/features/chat/presentation/widgets/unread_indicator_button.dart';
import 'package:mime/mime.dart';
import 'package:cc/core/widgets/user_avatar.dart';
import 'package:cc/core/utils/debug_commands.dart';
import 'package:cc/features/chat/domain/repositories/chat_repository.dart';
import 'package:cc/features/chat/domain/repositories/chats_repository.dart';
import 'package:cc/features/chat/domain/repositories/chat_repository_send.dart';
import 'package:cc/core/l10n/app_localizations.dart';
import 'package:cc/core/constants/app_colors.dart';

/// 聊天页面
///
/// 使用scrollable_positioned_list来实现高性能的消息列表滚动
/// 支持滚动到指定消息位置，适合处理大量历史消息
class ChatPage extends StatefulWidget {
  /// 会话ID
  final String conversationId;

  /// 💢💢💢 初始会话信息（可选）
  /// 从 ChatsPage 传入，避免重复加载
  final Conversation? initialConversation;

  const ChatPage({
    super.key,
    required this.conversationId,
    this.initialConversation,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
  static final _logger = LogService.instance;
  Timer? _scrollDebounceTimer;
  Timer? _searchDebounceTimer; // 💢💢💢 新增：搜索防抖Timer

  /// 滚动控制器 - 用于控制列表滚动位置
  final ItemScrollController _itemScrollController = ItemScrollController();

  /// 位置监听器 - 用于监听当前可见项的位置
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();

  /// 文本输入控制器
  final TextEditingController _textController = TextEditingController();

  /// 💢💢💢 新增：搜索输入控制器
  final TextEditingController _searchController = TextEditingController();

  /// 焦点控制器
  final FocusNode _focusNode = FocusNode();

  /// 输入框文本变化通知器
  final ValueNotifier<String> _textNotifier = ValueNotifier<String>('');

  /// 新增：输入模式状态
  bool _isVoiceMode = false;
  bool _showMoreOptions = false;
  bool _showEmojiPanel = false;
  bool _isRecording = false;

  /// 录制时间相关
  Timer? _recordingTimer;
  int _recordingSeconds = 0;

  /// 💢💢💢 首次渲染检查标志
  bool _hasCheckedInitialPosition = false;

  /// 格式化录制时间
  String _formatRecordingTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  /// 随机数生成器 - 用于随机选择SVG背景图案
  final Random _random = Random();

  /// SVG背景图案列表
  final List<String> _svgPatterns = [
    'assets/images/pattern-19.svg',
    'assets/images/pattern-13.svg',
    'assets/images/pattern-15.svg',
  ];

  /// 当前选择的SVG图案
  late String _selectedSvgPattern;

  @override
  void initState() {
    super.initState();

    // 随机选择一个SVG图案
    _selectedSvgPattern = _svgPatterns[_random.nextInt(_svgPatterns.length)];

    // 初始化动画控制器
    _waveAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(); // 无限循环

    // 监听滚动位置变化
    _itemPositionsListener.itemPositions.addListener(_onScrollPositionChanged);

    // 监听文本控制器变化
    _textController.addListener(() {
      _textNotifier.value = _textController.text;
    });

    // 初始化媒体上传服务
    _initializeMediaServices();

    // 页面初始化后，同步当前会话详情
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ChatCubit>().syncCurrentConversation();
      }
    });
  }

  /// 初始化媒体服务
  void _initializeMediaServices() {
    // 在Widget构建完成后初始化媒体上传服务
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatCubit = context.read<ChatCubit>();

      // 获取ChatRepositorySend实例
      final chatRepositorySend = chatCubit.chatRepositorySend;

      // 初始化媒体上传集成服务
      // UploadApiService应该已经通过AuthTokenSyncService配置了认证token
      _mediaUploadIntegrationService.initialize(chatRepositorySend);

      _logger.i('MediaUploadIntegrationService已初始化');
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _searchController.dispose();
    _focusNode.dispose();
    _textNotifier.dispose();
    _waveAnimationController.dispose();
    _scrollDebounceTimer?.cancel();
    _searchDebounceTimer?.cancel();
    _recordingTimer?.cancel();
    // 释放媒体录制服务
    _voiceRecordService.dispose();
    // 🆕 停止音频播放
    AudioPlayerManager().stopAll();
    super.dispose();
  }

  /// 调试ChatState状态
  void _debugChatState() {
    try {
      final chatCubit = context.read<ChatCubit>();
      DebugCommands.diagnoseChatStateWithCubit(chatCubit);
      final localizations = AppLocalizations.of(context);

      // 显示提示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.debugStateOutputToConsole),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (error) {
      _logger.e('调试ChatState失败', error: error);
      final localizations = AppLocalizations.of(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${localizations.debugStateFailed}: $error'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// 💢💢💢 滚动位置变化监听
  void _onScrollPositionChanged() {
    final positions = _itemPositionsListener.itemPositions.value;
    if (positions.isNotEmpty) {
      // 💢💢💢 首次渲染后检查位置
      _checkInitialPositionAfterRender();

      // 💢💢💢 保留基本防抖，ChatCubit层的去重逻辑已足够防止不必要的重绘
      _scrollDebounceTimer?.cancel();
      _scrollDebounceTimer = Timer(const Duration(milliseconds: 200), () {
        context.read<ChatCubit>().updateCurrentScrollPosition(positions);
      });
    }
  }

  /// 💢💢💢 检查初始渲染后的滚动位置
  void _checkInitialPositionAfterRender() {
    if (_hasCheckedInitialPosition) return;

    final state = context.read<ChatCubit>().state;
    final currentScrollPosition = state.currentScrollPosition;

    // 只在 relativePosition == 1.0 时进行检查
    if (currentScrollPosition.relativePosition != 1.0) {
      _hasCheckedInitialPosition = true;
      return;
    }

    // 延迟检查，确保列表已完全渲染
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _performInitialPositionCheck();
    });
  }

  /// 💢💢💢 执行初始位置检查
  void _performInitialPositionCheck() {
    if (_hasCheckedInitialPosition || !_itemScrollController.isAttached) {
      return;
    }

    try {
      final positions = _itemPositionsListener.itemPositions.value;
      if (positions.isEmpty) return;

      // 查找最新消息（索引为0的项目）
      final newestItemPosition = positions.cast<ItemPosition?>().firstWhere(
            (pos) => pos?.index == 0,
            orElse: () => null,
          );

      if (newestItemPosition == null) return;

      // 检查最新消息是否贴底
      // 在 reverse: true 中，itemLeadingEdge 接近 0.0 表示消息在屏幕底部
      final isAtBottom = newestItemPosition.itemLeadingEdge <= 0.1;

      _logger.d('💢 初始位置检查', extra: {
        'newestItemIndex': newestItemPosition.index,
        'itemLeadingEdge': newestItemPosition.itemLeadingEdge,
        'itemTrailingEdge': newestItemPosition.itemTrailingEdge,
        'isAtBottom': isAtBottom,
      });

      if (!isAtBottom) {
        // 最新消息没有贴底，需要重新滚动到底部
        _logger.i('检测到消息列表未贴底，执行底部对齐');

        _itemScrollController.jumpTo(
          index: 0,
          alignment: 0.0, // 消息顶部对齐屏幕底部
        );
      }

      _hasCheckedInitialPosition = true;
    } catch (e) {
      _logger.w('初始位置检查失败', extra: {'error': e.toString()});
      _hasCheckedInitialPosition = true;
    }
  }

  /// 💢💢💢 完善的滚动到指定消息方法
  Future<void> _scrollToMessage(
    int targetMessageIndex, {
    Duration? duration,
    Curve? curve,
    double? alignment,
    bool showHighlight = false,
    bool jumpImmediately = false, // 💢💢💢 新增：立即跳转参数
  }) async {
    try {
      final state = context.read<ChatCubit>().state;

      _logger.i('开始滚动到消息', extra: {
        'targetMessageIndex': targetMessageIndex,
        'totalMessages': state.messages.length,
        'showHighlight': showHighlight,
        'jumpImmediately': jumpImmediately,
      });

      // 查找消息在当前列表中的索引
      final messageListIndex = state.messages.indexWhere(
        (message) => message.messageIndex == targetMessageIndex,
      );

      if (messageListIndex == -1) {
        _logger.w('消息未在当前列表中找到', extra: {
          'targetMessageIndex': targetMessageIndex,
          'searchInDatabase': true,
        });

        // 💢💢💢 如果消息不在当前列表中，尝试从数据库加载
        await _loadMessageAndScroll(targetMessageIndex);
        return;
      }

      // 💢💢💢 处理消息列表，添加分隔符，以获取正确的processedItems索引
      final currentUserId = state.currentUser.userId;
      final isPrivateChat = state.conversation.type == ConversationType.private;
      final processedItems = MessageListProcessor.processMessages(
        messages: state.messages,
        currentUserId: currentUserId,
        isPrivateChat: isPrivateChat,
      );

      // Get the actual message for further operations
      final targetMessage = state.messages[messageListIndex];

      // 💢💢💢 在processedItems中查找对应的索引
      final processedIndex = processedItems.indexWhere((item) {
        return item is MessageListItemData &&
            item.message.messageIndex == targetMessageIndex;
      });

      if (processedIndex == -1) {
        _logger.w('消息在processedItems中未找到', extra: {
          'messageId': targetMessage.messageId,
          'targetMessageIndex': targetMessageIndex,
        });
        return;
      }

      // 💢💢💢 检查滚动控制器是否可用
      if (!_itemScrollController.isAttached) {
        _logger.w('滚动控制器未附加，延迟执行滚动');

        // 等待下一帧再尝试滚动
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToMessage(
            targetMessageIndex,
            duration: duration,
            curve: curve,
            alignment: alignment,
            showHighlight: showHighlight,
            jumpImmediately: jumpImmediately,
          );
        });
        return;
      }

      // 💢💢💢 根据参数选择立即跳转或动画滚动
      if (jumpImmediately) {
        // 立即跳转，无动画
        _itemScrollController.jumpTo(
          index: processedIndex,
          alignment: alignment ?? 0.5,
        );

        _logger.i('立即跳转完成', extra: {
          'messageId': targetMessage.messageId,
          'targetMessageIndex': targetMessageIndex,
          'processedIndex': processedIndex,
          'alignment': alignment ?? 0.5,
        });
      } else {
        // 动画滚动
        await _itemScrollController.scrollTo(
          index: processedIndex,
          duration: duration ?? const Duration(milliseconds: 300),
          curve: curve ?? Curves.easeInOut,
          alignment: alignment ?? 0.5,
        );

        _logger.i('动画滚动完成', extra: {
          'messageId': targetMessage.messageId,
          'targetMessageIndex': targetMessageIndex,
          'processedIndex': processedIndex,
          'alignment': alignment ?? 0.5,
        });
      }

      // 💢💢💢 可选的高亮效果
      if (showHighlight) {
        _highlightMessage(targetMessage.messageId);
      }
    } catch (error) {
      _logger.e('滚动到消息失败', error: error, extra: {
        'targetMessageIndex': targetMessageIndex,
      });
    }
  }

  /// 💢💢💢 新增：加载消息并滚动（当消息不在当前列表中时）
  Future<void> _loadMessageAndScroll(int messageIndex) async {
    try {
      _logger.i('消息不在当前列表，尝试加载消息', extra: {
        'messageIndex': messageIndex,
      });

      // 💢💢💢 重置首次位置检查标志，因为要加载新的消息列表
      _hasCheckedInitialPosition = false;

      final chatCubit = context.read<ChatCubit>();

      // 💢💢💢 尝试加载包含目标消息的消息段
      final success = await chatCubit.loadMessagesAroundMessage(messageIndex);

      if (success) {
        // 加载成功后，等待UI更新，然后再次尝试滚动
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToMessage(messageIndex, showHighlight: true);
        });
      } else {
        _logger.w('无法加载包含目标消息的消息段', extra: {
          'messageIndex': messageIndex,
        });

        // 显示提示信息
        if (mounted) {
          final localizations = AppLocalizations.of(context);
          final messenger = ScaffoldMessenger.of(context);
          messenger.showSnackBar(
            SnackBar(
              content: Text(localizations.cannotLocateMessage),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (error) {
      _logger.e('加载消息并滚动失败', error: error, extra: {
        'messageIndex': messageIndex,
      });
    }
  }

  /// 💢💢💢 新增：高亮显示消息（可选功能）
  void _highlightMessage(String messageId) {
    // TODO: 实现消息高亮效果
    // 可以通过更新ChatCubit的状态来实现临时高亮
    _logger.d('高亮消息', extra: {
      'messageId': messageId,
    });
  }

  /// 🆕 检查用户是否在聊天底部
  /// 返回true表示用户在底部，应该在发送新消息时自动滚动
  bool _isUserAtBottom() {
    // 如果滚动控制器没有附加，认为在底部（初始状态）
    if (!_itemScrollController.isAttached) {
      _logger.d('滚动控制器未附加，认为在底部');
      return true;
    }

    try {
      final state = context.read<ChatCubit>().state;
      final positions = _itemPositionsListener.itemPositions.value;

      if (positions.isEmpty || state.messages.isEmpty) {
        _logger.d('没有位置信息或消息为空，认为在底部');
        return true;
      }

      // 处理消息列表，获取processedItems
      final currentUserId = state.currentUser.userId;
      final isPrivateChat = state.conversation.type == ConversationType.private;
      final processedItems = MessageListProcessor.processMessages(
        messages: state.messages,
        currentUserId: currentUserId,
        isPrivateChat: isPrivateChat,
      );

      if (processedItems.isEmpty) {
        _logger.d('processedItems为空，认为在底部');
        return true;
      }

      // 检查第一个item（最新消息）是否可见
      // 在reverse列表中，index 0 是最新的消息
      final firstItemPosition =
          positions.where((pos) => pos.index == 0).firstOrNull;

      if (firstItemPosition != null) {
        // 如果最新消息可见且其trailing edge >= 0.8，认为用户在底部
        final isAtBottom = firstItemPosition.itemTrailingEdge >= 0.8;

        _logger.d('检查底部位置', extra: {
          'firstItemIndex': firstItemPosition.index,
          'itemTrailingEdge': firstItemPosition.itemTrailingEdge,
          'isAtBottom': isAtBottom,
          'threshold': 0.8,
        });

        return isAtBottom;
      }

      // 如果第一个item不可见，检查是否有其他靠近顶部的item
      final topPositions = positions.where((pos) => pos.index <= 2).toList();
      if (topPositions.isNotEmpty) {
        // 如果前几个item可见，认为接近底部
        final isNearBottom =
            topPositions.any((pos) => pos.itemTrailingEdge >= 0.5);

        _logger.d('检查是否接近底部', extra: {
          'topPositions': topPositions
              .map((p) => {
                    'index': p.index,
                    'trailingEdge': p.itemTrailingEdge,
                  })
              .toList(),
          'isNearBottom': isNearBottom,
        });

        return isNearBottom;
      }

      _logger.d('无法确定位置，认为不在底部');
      return false;
    } catch (error) {
      _logger.e('检查底部位置失败', error: error);
      // 出错时保守地认为不在底部，避免不必要的滚动
      return false;
    }
  }

  /// 🆕 滚动到最新消息（发送消息后使用）
  Future<void> _scrollToBottom({bool animated = true}) async {
    try {
      final state = context.read<ChatCubit>().state;

      if (state.messages.isEmpty) {
        _logger.d('没有消息，无需滚动');
        return;
      }

      // 获取最新消息
      final latestMessage = state.messages.first; // messages是按时间降序排列的

      if (animated) {
        await _scrollToMessage(
          latestMessage.messageIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          alignment: 1.0, // 💢💢💢 修正：在reverse列表中，1.0表示滚动到物理屏幕顶部
        );
      } else {
        await _scrollToMessage(
          latestMessage.messageIndex,
          alignment: 1.0, // 💢💢💢 修正：在reverse列表中，1.0表示滚动到物理屏幕顶部
          jumpImmediately: true,
        );
      }

      _logger.i('滚动到最新消息完成', extra: {
        'messageId': latestMessage.messageId,
        'animated': animated,
      });
    } catch (error) {
      _logger.e('滚动到最新消息失败', error: error);
    }
  }

  /// 发送消息
  void _sendMessage() {
    final text = _textController.text.trim();

    // 验证输入
    if (text.isEmpty) {
      return;
    }

    // 验证文本长度
    if (text.length > 4000) {
      final localizations = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.messageTooLongDetails),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    // 🆕 在发送消息前检查用户是否在底部
    final wasAtBottom = _isUserAtBottom();

    _logger.i('发送消息前检查位置', extra: {
      'wasAtBottom': wasAtBottom,
      'textLength': text.length,
    });

    // 发送消息
    try {
      context.read<ChatCubit>().sendTextMessage(text);
      _textController.clear();

      // 🆕 如果用户在底部，发送成功后自动滚动到新消息
      if (wasAtBottom) {
        // 延迟一点时间，确保新消息已经添加到列表中
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // 再次检查确保消息已添加
          Timer(const Duration(milliseconds: 100), () {
            if (mounted) {
              _scrollToBottom(animated: true);
            }
          });
        });
      }

      // 收起键盘
      FocusScope.of(context).unfocus();

      // 轻微震动反馈
      HapticFeedback.lightImpact();
    } catch (error) {
      _logger.e('发送消息失败', error: error);

      // 显示错误提示
      if (mounted) {
        final localizations = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${localizations.sendFailed}: ${error.toString()}'),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: localizations.retry,
              onPressed: () {
                _textController.text = text;
                _sendMessage();
              },
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatCubit, ChatState>(
      buildWhen: (previous, current) {
        return previous.isSearchMode != current.isSearchMode ||
            previous.searchQuery != current.searchQuery ||
            previous.conversation.isMuted != current.conversation.isMuted ||
            previous.conversation.name != current.conversation.name ||
            previous.networkStatus != current.networkStatus;
      },
      builder: (context, state) {
        return Scaffold(
          appBar:
              state.isSearchMode ? _buildSearchAppBar() : _buildAppBar(state),
          body: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: _buildMessagesList(),
                  ),
                  state.isSearchMode
                      ? _buildSearchBottomBar()
                      : _buildInputArea(),
                ],
              ),
              // 录制动画覆盖层
              if (_isRecording) _buildRecordingOverlay(),
              // 🆕 未读消息指示器
              _buildUnreadIndicator(state),
            ],
          ),
        );
      },
    );
  }

  /// 构建应用栏
  PreferredSizeWidget _buildAppBar(ChatState state) {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 主标题行：连接状态 + 会话名称 + 静音图标
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const ConnectionStatusIndicator(size: 14),
              const SizedBox(width: 4),
              Hero(
                tag: 'chat_title_${state.conversation.conversationId}',
                child: Material(
                  color: Colors.transparent,
                  child: Text(
                    state.conversation.displayName(state.currentUser.userId),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              // 静音图标（只在静音时显示）
              if (state.conversation.isMuted(state.currentUser.userId))
                const Padding(
                  padding: EdgeInsets.only(left: 6.0),
                  child: Icon(
                    Icons.volume_off,
                    size: 16,
                    color: Colors.grey,
                  ),
                ),
            ],
          ),
          // 副标题：在线状态
          Hero(
            tag: 'chat_subtitle_${state.conversation.conversationId}',
            child: Material(
              color: Colors.transparent,
              child: Text(
                _getLastSeenText(state),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
      actions: [
        // 调试按钮
        if (kDebugMode)
          IconButton(
            icon: const Icon(Icons.bug_report, size: 20),
            onPressed: () => _debugChatState(),
            tooltip: 'Debug Chat State',
          ),
        // 会话头像
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: GestureDetector(
            onTap: () {
              final chatCubit = context.read<ChatCubit>();
              final chatRepository = context.read<ChatRepository>();
              final chatsRepository = context.read<ChatsRepository>();
              final chatRepositorySend = context.read<ChatRepositorySend>();

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MultiRepositoryProvider(
                    providers: [
                      RepositoryProvider<ChatRepository>.value(
                          value: chatRepository),
                      RepositoryProvider<ChatsRepository>.value(
                          value: chatsRepository),
                      RepositoryProvider<ChatRepositorySend>.value(
                          value: chatRepositorySend),
                    ],
                    child: BlocProvider<ChatCubit>.value(
                      value: chatCubit,
                      child: const ChatInfoPage(),
                    ),
                  ),
                ),
              );
            },
            child: Hero(
              tag: 'chat_avatar_${state.conversation.conversationId}',
              child: UserAvatar(
                avatarUrl: state.conversation.avatar,
                name: state.conversation.displayName(state.currentUser.userId),
                radius: 18.0,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 构建SVG背景图案
  Widget _buildSvgBackground() {
    return SvgPicture.asset(
      _selectedSvgPattern,
      fit: BoxFit.cover,
      colorFilter: ColorFilter.mode(
        Colors.white.withAlpha(26), // 非常淡的白色，让图案不那么明显
        BlendMode.modulate,
      ),
    );
  }

  /// 💢💢💢💢💢💢💢💢💢💢💢💢💢💢   构建消息列表   💢💢💢💢💢💢💢💢💢💢💢💢💢💢
  Widget _buildMessagesList() {
    return BlocListener<ChatCubit, ChatState>(
      listenWhen: (previous, current) {
        // 💢💢💢 监听搜索结果索引变化，触发自动滚动
        final searchResultChanged = previous.currentSearchResultIndex !=
                current.currentSearchResultIndex ||
            (previous.searchResultMessageIndexes.length !=
                    current.searchResultMessageIndexes.length &&
                current.searchResultMessageIndexes.isNotEmpty);

        // 💢💢💢 监听滚动位置变化（初始化时自动滚动到最新消息）
        final scrollPositionChanged =
            previous.currentScrollPosition.messageId !=
                    current.currentScrollPosition.messageId &&
                current.currentScrollPosition.messageId != null &&
                !current.isSearchMode; // 非搜索模式下才响应滚动位置变化

        // 💢💢💢 新增：监听消息列表更新，以恢复滚动位置
        final messageListUpdated =
            previous.messages.length != current.messages.length &&
                current.currentScrollPosition.messageId != null &&
                !current.isSearchMode &&
                !current.isCleaningMessages; // 清理消息时不触发

        // 🆕 监听新消息到达（用于自动滚动）
        final newMessageArrived = !current.isSearchMode &&
            !current.isCleaningMessages &&
            current.messages.length > previous.messages.length &&
            current.messages.isNotEmpty;

        final shouldListen = searchResultChanged ||
            scrollPositionChanged ||
            messageListUpdated ||
            newMessageArrived;

        return shouldListen;
      },
      listener: (context, state) {
        // 💢💢💢 自动滚动到当前搜索结果
        if (state.isSearchMode &&
            state.searchResultMessageIndexes.isNotEmpty &&
            state.currentSearchResultIndex <
                state.searchResultMessageIndexes.length) {
          final currentResultMessageIndex =
              state.searchResultMessageIndexes[state.currentSearchResultIndex];

          _logger.d('💢 BlocListener 搜索模式滚动', extra: {
            'targetMessageIndex': currentResultMessageIndex,
            'currentIndex': state.currentSearchResultIndex,
          });

          // 延迟执行滚动，等待UI更新完成
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _logger.d('💢 BlocListener 执行搜索滚动回调');
            _scrollToMessage(currentResultMessageIndex);
          });
        }
        // 🆕 新消息自动滚动逻辑
        else if (!state.isSearchMode &&
            !state.isCleaningMessages &&
            state.messages.isNotEmpty) {}
      },
      child: BlocBuilder<ChatCubit, ChatState>(
        buildWhen: (previous, current) {
          // 💢💢💢 合并后的BlocBuilder：统一处理所有相关状态变化

          // 1. 消息列表变化（最重要的重建条件）
          if (!identical(previous.messages, current.messages)) {
            _logger.i('💢 BlocBuilder：消息列表变化', extra: {
              'previousLength': previous.messages.length,
              'currentLength': current.messages.length,
              'lengthDiff': current.messages.length - previous.messages.length,
            });
            return true;
          }

          // 2. 搜索状态变化（影响消息高亮和显示）
          if (previous.isSearchMode != current.isSearchMode ||
              previous.searchQuery != current.searchQuery ||
              previous.currentSearchResultIndex !=
                  current.currentSearchResultIndex ||
              !identical(previous.searchResultMessageIndexes,
                  current.searchResultMessageIndexes)) {
            _logger.i('💢 BlocBuilder：搜索状态变化');
            return true;
          }

          // 3. 会话信息变化（影响消息显示状态和类型判断）
          if (previous.conversation.conversationId !=
                  current.conversation.conversationId ||
              previous.conversation.type != current.conversation.type) {
            _logger.i('💢 BlocBuilder：会话信息变化');
            return true;
          }

          // 5. 消息更新触发器变化（强制更新机制）
          if (previous.messageUpdateTrigger != current.messageUpdateTrigger) {
            _logger.i('💢 BlocBuilder：消息更新触发器变化', extra: {
              'prevTrigger': previous.messageUpdateTrigger,
              'currTrigger': current.messageUpdateTrigger,
            });
            return true;
          }

          _logger.d('💢 BlocBuilder：无相关状态变化');
          return false;
        },
        builder: (context, state) {
          _logger.i('💢 BlocBuilder 重绘',
              extra: {
                'messageCount': state.messages.length,
                'currentScrollPositionMessageID':
                    state.currentScrollPosition.messageId,
                'currentScrollPositionIndex':
                    state.currentScrollPosition.getListIndex(state.messages),
              },
              stackTrace: StackTrace.current);

          // 💢💢💢 每次重建时重置首次位置检查标志
          _hasCheckedInitialPosition = false;

          // 处理消息列表，添加分隔符
          final currentUserId = state.currentUser.userId;
          final isPrivateChat =
              state.conversation.type == ConversationType.private;
          final processedItems = MessageListProcessor.processMessages(
            messages: state.messages, // 直接使用state中的消息列表
            currentUserId: currentUserId,
            isPrivateChat: isPrivateChat,
          );

          return Stack(
            children: [
              _buildBackground(),
              // 消息列表内容
              Column(
                children: [
                  // 消息列表 💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢
                  Expanded(
                    child: ScrollablePositionedList.builder(
                      key: ValueKey(
                          'message_list_${state.messages.length}_${state.currentScrollPosition.messageId ?? "empty"}_${state.messageUpdateTrigger}'),
                      itemCount: processedItems.length,
                      itemBuilder: (context, index) {
                        final item = processedItems[index];

                        // 根据类型渲染不同的组件
                        if (item is MessageListItemData) {
                          final message = item.message;

                          // 💢💢💢 检查消息是否为搜索结果
                          final chatCubit = context.read<ChatCubit>();
                          final isSearchResult =
                              chatCubit.isSearchResult(message.messageIndex);
                          final isCurrentSearchResult = chatCubit
                              .isCurrentSearchResult(message.messageIndex);
                          final searchQuery =
                              state.isSearchMode ? state.searchQuery : null;

                          // 💢💢💢 计算消息显示状态（仅当前用户消息需要显示状态）
                          MessageDisplayStatus? displayStatus;
                          if (item.isCurrentUser) {
                            displayStatus = _calculateMessageDisplayStatus(
                              message,
                              state.conversation,
                              state.currentUser,
                              item.isPrivateChat,
                            );
                          }

                          return MessageItem(
                            key: ValueKey(message.messageId),
                            message: message,
                            isCurrentUser: item.isCurrentUser,
                            showAvatar: item.showAvatar,
                            showTail: item.showTail,
                            isPrivateChat: item.isPrivateChat,
                            onTap: () => _onMessageTap(message),
                            onResend: message.status == MessageStatus.failed &&
                                    item.isCurrentUser
                                ? () => _onResendMessage(message.messageId)
                                : null, // 💢💢💢 新增：重发回调
                            // 💢💢💢 新增搜索相关参数
                            isSearchResult: isSearchResult,
                            isCurrentSearchResult: isCurrentSearchResult,
                            // 🔥 新增：长按菜单回调
                            onReply: () => _onReplyMessage(message),
                            onForward: () => _onForwardMessage(message),
                            onCopy: () => _onCopyMessage(message),
                            onRevoke: () => _onRevokeMessage(message),
                            onDelete: () => _onDeleteMessage(message),
                            searchQuery: searchQuery,
                            displayStatus: displayStatus, // 💢💢💢 新增：预计算的显示状态
                          );
                        } else if (item is MessageListItemDateSeparator) {
                          return DateSeparator(
                            key: ValueKey(
                                'date_${item.date.millisecondsSinceEpoch}'),
                            date: item.date,
                          );
                        } else {
                          // 未知类型，返回空容器
                          return const SizedBox.shrink();
                        }
                      },
                      itemScrollController: _itemScrollController,
                      itemPositionsListener: _itemPositionsListener,
                      // 💢💢💢 动态计算初始滚动索引，确保不返回-1
                      initialScrollIndex: (() {
                        final anchorId = state.currentScrollPosition.messageId;
                        if (anchorId != null) {
                          // 在 processedItems 中查找锚点消息对应的索引
                          final anchorIndex = processedItems.indexWhere((item) {
                            if (item is MessageListItemData) {
                              if (item.message.messageId == anchorId) {
                                _logger.d('💢 初始滚动索引计算', extra: {
                                  'anchorMessageIndex':
                                      item.message.messageIndex,
                                  'foundAnchorMessageId': anchorId,
                                });
                                return true; // 🔥 找到匹配的消息，返回 true
                              }
                            }
                            return false; // 🔥 没有匹配，返回 false
                          });

                          _logger.d('💢 初始滚动索引计算', extra: {
                            'anchorIndex': anchorIndex,
                          });
                          if (anchorIndex >= 0) {
                            return anchorIndex;
                          }
                        }
                        // 默认返回0，避免-1导致RangeError
                        return 0;
                      })(),

                      // 💢💢💢 计算初始对齐：有锚点使用精确位置；否则让消息贴底
                      initialAlignment: (() {
                        final itemLeadingEdge =
                            state.currentScrollPosition.relativePosition ?? 0.0;
                        // 💢💢💢 reverse: true 中的对齐恢复逻辑
                        // 保存的 itemLeadingEdge 表示在反向列表中消息底部的逻辑位置：
                        // - 0.0: 消息底部在物理屏幕底部（反向列表的逻辑起点）
                        // - 1.0: 消息底部在物理屏幕顶部（反向列表的逻辑终点）
                        // - 0.907: 消息底部在物理屏幕顶部附近（90.7%位置）
                        // 恢复时直接使用 itemLeadingEdge 作为 initialAlignment
                        _logger.d('💢 初始对齐计算',
                            extra: {'itemLeadingEdge': itemLeadingEdge});
                        return itemLeadingEdge;
                      })(),
                      reverse: true,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4.0,
                        vertical: 8.0,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  /// 构建背景
  Widget _buildBackground() {
    return Stack(
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
      ],
    );
  }

  /// 构建输入区域
  Widget _buildInputArea() {
    return BlocBuilder<ChatCubit, ChatState>(
      buildWhen: (previous, current) {
        // 只在发送状态或网络状态变化时重建
        return previous.isSending != current.isSending ||
            previous.networkStatus != current.networkStatus;
      },
      builder: (context, state) {
        final isEnabled =
            state.networkStatus == ChatState.kNetworkStatusConnected &&
                !state.isSending;

        return Column(
          children: [
            // 主输入栏
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                border: Border(
                  top: BorderSide(
                    color: Colors.grey.withAlpha(51),
                    width: 0.5,
                  ),
                ),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    // 语音/键盘切换按钮
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isVoiceMode = !_isVoiceMode;
                          if (_isVoiceMode) {
                            _focusNode.unfocus();
                            _showMoreOptions = false;
                          } else {
                            _focusNode.requestFocus();
                          }
                        });
                      },
                      child: SizedBox(
                        width: 36,
                        height: 36,
                        child: Icon(
                          _isVoiceMode ? Icons.keyboard : Icons.mic,
                          size: 32,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // 输入框或语音按钮
                    Expanded(
                      child: _isVoiceMode
                          ? _buildVoiceButton(isEnabled)
                          : _buildTextInput(isEnabled),
                    ),

                    const SizedBox(width: 8),

                    // 表情按钮
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _showEmojiPanel = !_showEmojiPanel;
                          if (_showEmojiPanel) {
                            _showMoreOptions = false;
                            _focusNode.unfocus();
                          }
                        });
                      },
                      child: SizedBox(
                        width: 36,
                        height: 36,
                        // decoration: BoxDecoration(
                        //   color: Colors.grey.shade100,
                        //   borderRadius: BorderRadius.circular(18),
                        // ),
                        child: Icon(
                          Icons.emoji_emotions_outlined,
                          size: 32,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // 发送按钮或添加按钮
                    ValueListenableBuilder<String>(
                      valueListenable: _textNotifier,
                      builder: (context, text, child) {
                        return text.isNotEmpty && !_isVoiceMode
                            ? _buildSendButton(state, isEnabled)
                            : _buildAddButton();
                      },
                    ),
                  ],
                ),
              ),
            ),

            // 功能面板或表情面板
            if (_showMoreOptions)
              _buildMoreOptionsPanel()
            else if (_showEmojiPanel)
              _buildEmojiPanel(),
          ],
        );
      },
    );
  }

  /// 构建文本输入框
  Widget _buildTextInput(bool isEnabled) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 0.5,
        ),
      ),
      child: TextField(
        controller: _textController,
        focusNode: _focusNode,
        enabled: isEnabled,
        maxLines: 5,
        minLines: 1,
        decoration: InputDecoration(
          hintText: isEnabled
              ? AppLocalizations.of(context).inputMessage
              : AppLocalizations.of(context).connecting,
          hintStyle: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 16,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
        ),
        style: const TextStyle(
          fontSize: 20,
          color: Colors.black87,
          height: 1.4, // 调整行高以适应更大的表情
        ),
        textInputAction: TextInputAction.send,
        onSubmitted: isEnabled ? (text) => _sendMessage() : null,
        onChanged: (text) {
          // 文本变化已通过ValueNotifier自动处理，无需setState
        },
        onTap: () {
          setState(() {
            _showMoreOptions = false;
            _showEmojiPanel = false;
          });
        },
      ),
    );
  }

  /// 构建语音按钮
  Widget _buildVoiceButton(bool isEnabled) {
    return GestureDetector(
      onLongPressStart: (_) async {
        if (isEnabled) {
          await _startRecording();
        }
      },
      onLongPressMoveUpdate: (details) {
        // 保持录制状态，可以在这里添加其他手势逻辑
      },
      onLongPressEnd: (_) async {
        if (_isRecording) {
          await _stopRecording();
        }
      },
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: _isRecording ? Colors.green.shade100 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isRecording ? Colors.green.shade300 : Colors.grey.shade300,
            width: 0.5,
          ),
        ),
        child: Center(
          child: Text(
            _isRecording
                ? AppLocalizations.of(context).releaseToFinish
                : AppLocalizations.of(context).holdToSpeakButtonText,
            style: TextStyle(
              fontSize: 16,
              color:
                  _isRecording ? Colors.green.shade700 : Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }

  /// 开始录制（语音）
  Future<void> _startRecording() async {
    try {
      _logger.i('用户开始录音');

      final success = await _voiceRecordService.startRecording();
      if (success) {
        setState(() {
          _isRecording = true;
          _recordingSeconds = 0;
        });

        // 启动录制计时器，最大60秒
        _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (mounted) {
            setState(() {
              _recordingSeconds++;
            });

            // 🔧 录音时长限制：最大60秒
            if (_recordingSeconds >= VoiceRecordService.maxRecordingDuration) {
              _logger.i(
                  '录音达到最大时长${VoiceRecordService.maxRecordingDuration}秒，自动停止');
              timer.cancel();
              _stopRecording();

              // 显示提示
              final localizations = AppLocalizations.of(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      '${localizations.recordingAutoSend}(${VoiceRecordService.maxRecordingDuration}秒)'),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          }
        });

        HapticFeedback.lightImpact();
        _logger.i('录音开始成功');
      } else {
        _logger.w('录音开始失败');
        if (mounted) {
          final localizations = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(localizations.recordingFailedPermission),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      _logger.e('录音开始异常', error: e);
      if (mounted) {
        final localizations = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${localizations.recordingFailed}: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// 视频录制功能（暂时禁用，等camera插件问题解决）
  Future<void> _startVideoRecording() async {
    _logger.w('视频录制功能暂时禁用');
    if (mounted) {
      final localizations = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.videoRecordingComingSoon),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// 显示图片选择选项
  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading:
                  const Icon(Icons.photo_library, color: AppColors.primary),
              title: Text(AppLocalizations.of(context).selectFromGallery),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.green),
              title: Text(AppLocalizations.of(context).takePhoto),
              onTap: () {
                Navigator.pop(context);
                _takePicture();
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  /// 从相册选择图片
  Future<void> _pickImageFromGallery() async {
    try {
      _logger.i('开始从相册选择图片');

      final pickedFile = await _mediaService.pickImage(fromCamera: false);
      if (pickedFile != null) {
        _logger.i('图片选择成功', extra: {
          'filePath': pickedFile.path,
          'fileSize': await pickedFile.length(),
        });

        await _showImagePreviewAndSend(pickedFile);
      } else {
        _logger.i('用户取消了图片选择');
      }
    } catch (error) {
      _logger.e('选择图片失败', error: error, stackTrace: StackTrace.current);
      if (mounted) {
        final localizations = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${localizations.imageSendFailed}: $error'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// 拍照功能
  Future<void> _takePicture() async {
    try {
      _logger.i('开始拍照');

      // 在macOS上提示用户将从相册选择
      if (Platform.isMacOS && mounted) {
        final localizations = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.macOSGalleryTip),
            duration: const Duration(seconds: 2),
          ),
        );
      }

      final pickedFile = await _mediaService.pickImage(fromCamera: true);
      if (pickedFile != null) {
        _logger.i('图片选择成功', extra: {
          'filePath': pickedFile.path,
          'fileSize': await pickedFile.length(),
        });

        await _showImagePreviewAndSend(pickedFile);
      } else {
        _logger.i('用户取消了图片选择');
      }
    } catch (error) {
      _logger.e('图片选择失败', error: error, stackTrace: StackTrace.current);
      if (mounted) {
        final localizations = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${localizations.imageSelectionFailed}: $error'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// 显示图片预览并发送
  Future<void> _showImagePreviewAndSend(File imageFile) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _ImagePreviewDialog(imageFile: imageFile),
    );

    if (result != null && result['confirmed'] == true) {
      final caption = result['caption'] as String?;
      await _uploadAndSendImage(imageFile, caption: caption);
    }
  }

  /// 上传并发送图片消息
  Future<void> _uploadAndSendImage(File imageFile, {String? caption}) async {
    try {
      _logger.i('开始上传图片', extra: {
        'filePath': imageFile.path,
        'caption': caption,
      });

      // 显示上传进度
      final localizations = AppLocalizations.of(context);
      _showUploadProgress(localizations.sendingImage);

      // 使用MediaUploadIntegrationService发送图片消息
      await _mediaUploadIntegrationService.sendImageMessage(
        imageFile: imageFile,
        conversationId: widget.conversationId,
        caption: caption,
        onUploadProgress: (progress) {
          _updateUploadProgress('${localizations.uploadingImage} $progress%');
        },
        onStatusUpdate: (status) {
          _updateUploadProgress(status);
        },
      );

      _logger.i('图片消息发送成功');

      // 清除进度提示
      _hideUploadProgress();

      // 触觉反馈
      HapticFeedback.lightImpact();
    } catch (error) {
      _logger.e('图片消息发送失败', error: error, stackTrace: StackTrace.current);

      _hideUploadProgress();

      if (mounted) {
        final localizations = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${localizations.imageSendFailed}: $error'),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: localizations.retry,
              onPressed: () => _uploadAndSendImage(imageFile, caption: caption),
            ),
          ),
        );
      }
    }
  }

  /// 显示上传进度
  void _showUploadProgress(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(message)),
            ],
          ),
          duration: const Duration(minutes: 5), // 长时间显示
        ),
      );
    }
  }

  /// 更新上传进度
  void _updateUploadProgress(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      _showUploadProgress(message);
    }
  }

  /// 隐藏上传进度
  void _hideUploadProgress() {
    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
    }
  }

  /// 停止录音并发送
  Future<void> _stopRecording() async {
    try {
      _logger.i('用户停止录音');

      setState(() {
        _isRecording = false;
      });

      // 停止录制计时器
      _recordingTimer?.cancel();
      _recordingTimer = null;

      final result = await _voiceRecordService.stopRecording();
      if (result != null) {
        _logger.i('录音结束', extra: {
          'duration': result.duration,
          'fileSize': result.fileSize,
          'filePath': result.filePath,
        });

        // 检查录音时长
        if (result.duration < 1) {
          _logger.w('录音时间太短，删除录音文件');
          // 删除录音文件
          final file = File(result.filePath);
          if (await file.exists()) {
            await file.delete();
          }

          if (mounted) {
            final localizations = AppLocalizations.of(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(localizations.recordingTooShort),
                duration: const Duration(seconds: 1),
              ),
            );
          }
          return;
        }

        // 上传并发送语音消息
        await _uploadAndSendVoice(result);
      } else {
        _logger.w('录音结果为空');
        if (mounted) {
          final localizations = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(localizations.recordingFailed),
              duration: const Duration(seconds: 1),
            ),
          );
        }
      }
    } catch (e) {
      _logger.e('录音停止异常', error: e);
      setState(() {
        _isRecording = false;
      });

      // 停止录制计时器
      _recordingTimer?.cancel();
      _recordingTimer = null;

      if (mounted) {
        final localizations = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${localizations.recordingFailed}: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// 上传并发送语音消息
  Future<void> _uploadAndSendVoice(VoiceRecordResult recordResult) async {
    try {
      _logger.i('开始上传语音文件', extra: {
        'filePath': recordResult.filePath,
        'duration': recordResult.duration,
        'fileSize': recordResult.fileSize,
      });

      // 在异步操作前获取ChatCubit引用
      final chatCubit = context.read<ChatCubit>();

      // 显示上传中提示
      if (mounted) {
        final localizations = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 12),
                Text(localizations.sendingVoice),
              ],
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }

      // 上传语音文件
      final uploadResult = await _fileUploadService.uploadVoice(
        File(recordResult.filePath),
        recordResult.duration * 1000, // 🔧 转换为毫秒，与数据库和proto保持一致
      );

      if (uploadResult != null) {
        _logger.i('语音文件上传成功', extra: {
          'localPath': uploadResult.localPath,
          'remoteUrl': uploadResult.remoteUrl,
          'duration': uploadResult.duration,
        });

        // 发送语音消息
        await chatCubit.sendVoiceMessage(
          recordResult.filePath,
          recordResult.duration * 1000, // 🔧 转换为毫秒
          mediaUrl: uploadResult.remoteUrl,
        );

        _logger.i('语音消息发送成功');

        // 清除上传提示
        if (mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
        }

        // 触觉反馈
        HapticFeedback.lightImpact();
      } else {
        final localizations = AppLocalizations.of(context);
        throw Exception(localizations.fileUploadFailed);
      }
    } catch (e) {
      _logger.e('语音消息发送失败', error: e);

      // 删除录音文件
      try {
        final file = File(recordResult.filePath);
        if (await file.exists()) {
          await file.delete();
          _logger.i('已删除失败的录音文件');
        }
      } catch (deleteError) {
        _logger.w('删除录音文件失败', extra: {
          'error': deleteError,
        });
      }

      if (mounted) {
        final localizations = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${localizations.voiceSendFailed}: $e'),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: localizations.retry,
              onPressed: () => _uploadAndSendVoice(recordResult),
            ),
          ),
        );
      }
    }
  }

  /// 选择并发送文件
  Future<void> _pickAndSendFile() async {
    try {
      _logger.i('开始选择文件');

      final pickedFile = await _mediaService.pickFile();
      if (pickedFile != null) {
        // 获取文件MIME类型用于调试
        final mimeType = lookupMimeType(pickedFile.path);
        _logger.i('文件选择成功', extra: {
          'filePath': pickedFile.path,
          'fileSize': await pickedFile.length(),
          'mimeType': mimeType,
          'fileName': pickedFile.path.split('/').last,
        });

        await _showFilePreviewAndSend(pickedFile);
      } else {
        _logger.i('用户取消了文件选择');
      }
    } catch (error) {
      _logger.e('文件选择失败', error: error, stackTrace: StackTrace.current);
      if (mounted) {
        final localizations = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${localizations.fileSelectionFailed}: $error'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// 显示文件预览并发送
  Future<void> _showFilePreviewAndSend(File file) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _FilePreviewDialog(file: file),
    );

    if (result != null && result['confirmed'] == true) {
      final caption = result['caption'] as String?;
      await _uploadAndSendFile(file, caption: caption);
    }
  }

  /// 上传并发送文件消息
  Future<void> _uploadAndSendFile(File file, {String? caption}) async {
    try {
      _logger.i('开始上传文件', extra: {
        'filePath': file.path,
        'caption': caption,
      });

      // 显示上传进度
      final localizations = AppLocalizations.of(context);
      _showUploadProgress(localizations.sendingFile);

      // 使用MediaUploadIntegrationService发送文件消息
      await _mediaUploadIntegrationService.sendDocumentMessage(
        documentFile: file,
        conversationId: widget.conversationId,
        caption: caption,
        onUploadProgress: (progress) {
          _updateUploadProgress('${localizations.uploadingFile} $progress%');
        },
        onStatusUpdate: (status) {
          _updateUploadProgress(status);
        },
      );

      _logger.i('文件消息发送成功');

      // 清除进度提示
      _hideUploadProgress();

      // 触觉反馈
      HapticFeedback.lightImpact();
    } catch (error) {
      _logger.e('文件消息发送失败', error: error, stackTrace: StackTrace.current);

      _hideUploadProgress();

      if (mounted) {
        final localizations = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${localizations.fileSendFailed}: $error'),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: localizations.retry,
              onPressed: () => _uploadAndSendFile(file, caption: caption),
            ),
          ),
        );
      }
    }
  }

  /// 构建发送按钮
  Widget _buildSendButton(ChatState state, bool isEnabled) {
    return SizedBox(
      width: 36,
      height: 36,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: isEnabled ? _sendMessage : null,
          child: state.isSending
              ? const SizedBox(
                  width: 32,
                  height: 32,
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                )
              : const Icon(
                  Icons.send,
                  color: Colors.grey,
                  size: 32,
                ),
        ),
      ),
    );
  }

  /// 构建添加按钮
  Widget _buildAddButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showMoreOptions = !_showMoreOptions;
          if (_showMoreOptions) {
            _focusNode.unfocus();
            _showEmojiPanel = false;
          }
        });
      },
      child: Icon(
        _showMoreOptions ? Icons.close : Icons.add,
        size: 40,
        color: Colors.grey.shade600,
      ),
    );
  }

  /// 构建功能面板
  Widget _buildMoreOptionsPanel() {
    final localizations = AppLocalizations.of(context);
    final options = [
      {'icon': Icons.photo_library, 'label': localizations.picture},
      {'icon': Icons.camera_alt, 'label': localizations.shoot},
      {'icon': Icons.insert_drive_file, 'label': localizations.fileOption},
      {'icon': Icons.person, 'label': localizations.contactOption},
    ];

    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFFF2F2F7), // 使用ChatInfoPage相同的背景色
        border: Border(
          top: BorderSide(
            color: Color(0xFFE0E0E0),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: options.map((option) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    _handleMoreOptionTap(option['label'] as String);
                  },
                  child: Container(
                    height: 90,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          option['icon'] as IconData,
                          color: AppColors.primary,
                          size: 26,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          option['label'] as String,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 构建表情面板
  Widget _buildEmojiPanel() {
    // 基础表情列表
    final emojis = [
      '😀',
      '😃',
      '😄',
      '😁',
      '😆',
      '😅',
      '😂',
      '🤣',
      '🥲',
      '☺️',
      '😊',
      '😇',
      '🙂',
      '🙃',
      '😉',
      '😌',
      '😍',
      '🥰',
      '😘',
      '😗',
      '😙',
      '😚',
      '😋',
      '😛',
      '😝',
      '😜',
      '🤪',
      '🤨',
      '🧐',
      '🤓',
      '😎',
      '🥸',
      '🤩',
      '🥳',
      '😏',
      '😒',
      '😞',
      '😔',
      '😟',
      '😕',
      '🙁',
      '☹️',
      '😣',
      '😖',
      '😫',
      '😩',
      '🥺',
      '😢',
      '😭',
      '😤',
      '😠',
      '😡',
      '🤬',
      '🤯',
      '😳',
      '🥵',
      '🥶',
      '😶',
      '😐',
      '😑',
      '😬',
      '🙄',
      '😯',
      '😦',
      '😧',
      '😮',
      '😲',
      '🥱',
      '😴',
      '🤤',
      '😪',
      '😵',
      '🤐',
      '🥴',
      '🤢',
      '🤮',
      '🤧',
      '😷',
      '🤒',
      '🤕',
    ];

    return Container(
      height: 240,
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        color: Color(0xFFF2F2F7),
        border: Border(
          top: BorderSide(
            color: Color(0xFFE0E0E0),
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        children: [
          // 表情标题和关闭按钮
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context).allEmojis,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showEmojiPanel = false;
                    });
                  },
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // 表情网格
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
                childAspectRatio: 1.0,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: emojis.length,
              itemBuilder: (context, index) {
                final emoji = emojis[index];
                return GestureDetector(
                  onTap: () {
                    _insertEmoji(emoji);
                  },
                  child: Center(
                    child: Text(
                      emoji,
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 构建录制覆盖层
  Widget _buildRecordingOverlay() {
    return Positioned(
      bottom: 200,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.green.shade200, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(25),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 音频示波器动画
              _buildAudioWaveAnimation(),
              const SizedBox(width: 12),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppLocalizations.of(context).recording,
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatRecordingTime(_recordingSeconds),
                        style: TextStyle(
                          color: Colors.green.shade600,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                      Text(
                        ' / ${_formatRecordingTime(VoiceRecordService.maxRecordingDuration)}',
                        style: TextStyle(
                          color: Colors.green.shade400,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 动画控制器
  late AnimationController _waveAnimationController;

  /// 语音录制服务
  final VoiceRecordService _voiceRecordService = VoiceRecordService();

  /// 文件上传服务
  final FileUploadService _fileUploadService = FileUploadService();

  /// 媒体服务
  final MediaService _mediaService = MediaService();

  /// 媒体上传集成服务
  final MediaUploadIntegrationService _mediaUploadIntegrationService =
      MediaUploadIntegrationService();

  /// 音频示波器动画效果
  Widget _buildAudioWaveAnimation() {
    return Container(
      width: 90,
      height: 35,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.green.shade100.withAlpha(100),
        border: Border.all(
          color: Colors.green.shade200,
          width: 0.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: AnimatedBuilder(
          animation: _waveAnimationController,
          builder: (context, child) {
            return CustomPaint(
              painter:
                  AudioWavePainter(progress: _waveAnimationController.value),
            );
          },
        ),
      ),
    );
  }

  /// 插入表情到输入框
  void _insertEmoji(String emoji) {
    final currentText = _textController.text;
    final currentPosition = _textController.selection.baseOffset;

    if (currentPosition == -1) {
      // 如果没有光标位置，就添加到末尾
      _textController.text = currentText + emoji;
      _textController.selection = TextSelection.fromPosition(
        TextPosition(offset: _textController.text.length),
      );
    } else {
      // 在光标位置插入表情
      final newText = currentText.substring(0, currentPosition) +
          emoji +
          currentText.substring(currentPosition);
      _textController.text = newText;
      _textController.selection = TextSelection.fromPosition(
        TextPosition(offset: currentPosition + emoji.length),
      );
    }

    // 更新UI状态
    setState(() {});
  }

  /// 处理功能选项点击
  void _handleMoreOptionTap(String label) {
    setState(() {
      _showMoreOptions = false;
    });

    final localizations = AppLocalizations.of(context);

    if (label == localizations.picture) {
      _showImagePickerOptions();
    } else if (label == localizations.shoot) {
      _showMediaCaptureOptions();
    } else if (label == localizations.fileOption) {
      _pickAndSendFile();
    } else if (label == localizations.contactOption) {
      // TODO: 分享联系人
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.contactFeatureComingSoon)),
      );
    }
  }

  /// 显示媒体拍摄选项
  void _showMediaCaptureOptions() {
    final localizations = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primary),
              title: Text(localizations.takePhoto),
              onTap: () {
                Navigator.pop(context);
                _takePicture();
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam, color: Colors.red),
              title: Text(localizations.recordVideo),
              onTap: () {
                Navigator.pop(context);
                _showVideoRecordingDialog();
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  /// 显示视频录制对话框
  void _showVideoRecordingDialog() {
    final localizations = AppLocalizations.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(localizations.recordVideo),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(localizations.longPressToRecord),
            const SizedBox(height: 20),
            GestureDetector(
              onLongPressStart: (_) => _startVideoRecording(),
              onLongPressEnd: (_) => _stopRecording(),
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: _isRecording ? Colors.red : AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.videocam,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _isRecording
                  ? localizations.recordingInProgress
                  : localizations.longPressRecord,
              style: TextStyle(
                color: _isRecording ? Colors.red : Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(localizations.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                // TODO: 实现撤回功能
                // context.read<ChatCubit>().revokeMessage(message.messageId);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(localizations.revokeFeatureComingSoon)),
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(localizations.messageRevoked)),
                  );
                }
              } catch (error) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text("${localizations.revokeFailed}: $error")),
                  );
                }
              }
            },
            child: Text(localizations.confirm),
          ),
        ],
      ),
    );
  }

  /// 消息点击事件
  void _onMessageTap(Message message) {
    // TODO 实现消息点击逻辑，如显示消息详情、复制等
  }

  /// 回复消息
  void _onReplyMessage(Message message) {
    _logger.d('回复消息', extra: {'messageId': message.messageId});
    // TODO: 实现回复功能
  }

  /// 转发消息
  void _onForwardMessage(Message message) {
    _logger.d('转发消息', extra: {'messageId': message.messageId});
    // TODO: 实现转发功能
  }

  /// 复制消息
  void _onCopyMessage(Message message) {
    _logger.d('复制消息', extra: {'messageText': message.text});
    if (message.text?.isNotEmpty == true) {
      Clipboard.setData(ClipboardData(text: message.text!));
      final localizations = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.copiedToClipboard)),
      );
    }
  }

  /// 撤回消息
  void _onRevokeMessage(Message message) {
    _logger.d('撤回消息', extra: {'messageId': message.messageId});

    // 💢💢💢 检查撤回时间限制（2分钟内可撤回）
    const revokeTimeLimit = Duration(minutes: 2);
    final timeSinceMessage = DateTime.now().difference(message.createdAt);

    if (timeSinceMessage > revokeTimeLimit) {
      // 超过时间限制，显示提示
      final localizations = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.messageExpiredCannotRevoke),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    // 💢💢💢 检查网络连接状态
    final chatCubit = context.read<ChatCubit>();
    final state = chatCubit.state;

    // 💢💢💢 预先获取messenger引用，避免Provider上下文问题
    final messenger = ScaffoldMessenger.of(context);

    if (state.networkStatus != ChatState.kNetworkStatusConnected) {
      final localizations = AppLocalizations.of(context);
      messenger.showSnackBar(
        SnackBar(
          content: Text(localizations.networkErrorCannotRevoke),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    // 💢💢💢 计算剩余撤回时间
    final remainingTime = revokeTimeLimit - timeSinceMessage;
    final remainingMinutes = remainingTime.inMinutes;
    final remainingSeconds = remainingTime.inSeconds % 60;

    String timeText;
    if (remainingMinutes > 0) {
      timeText = '$remainingMinutes分$remainingSeconds秒';
    } else {
      timeText = '$remainingSeconds秒';
    }

    // 显示确认对话框
    final localizations = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(localizations.revokeMessage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(localizations.confirmRevokeMessage),
            const SizedBox(height: 8),
            Text(
              "${localizations.revokeTimeRemaining}：$timeText",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              localizations.revokeInstructions,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(localizations.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();

              // 💢💢💢 显示撤回中状态
              messenger.showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 12),
                      Text(localizations.revokingMessage),
                    ],
                  ),
                  duration: const Duration(seconds: 10), // 给撤回操作足够时间
                ),
              );

              try {
                // 调用ChatCubit的撤回方法（使用UUID作为messageId）
                await chatCubit.revokeMessage(message.messageId);

                // 💢💢💢 撤回成功
                if (mounted) {
                  messenger.clearSnackBars();
                  messenger.showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle,
                              color: Colors.green, size: 20),
                          const SizedBox(width: 8),
                          Text(localizations.messageRevoked),
                        ],
                      ),
                      duration: const Duration(seconds: 2),
                      backgroundColor: Colors.green,
                    ),
                  );
                }

                // 💢💢💢 触觉反馈
                HapticFeedback.lightImpact();

                _logger.i('消息撤回成功', extra: {
                  'messageId': message.messageId,
                });
              } catch (error) {
                _logger.e('撤回消息失败', error: error, extra: {
                  'messageId': message.messageId,
                });

                if (mounted) {
                  messenger.clearSnackBars();
                  messenger.showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.error,
                              color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                                '${localizations.revokeFailed}: ${error.toString()}'),
                          ),
                        ],
                      ),
                      duration: const Duration(seconds: 3),
                      backgroundColor: Colors.red,
                      action: SnackBarAction(
                        label: localizations.retry,
                        textColor: Colors.white,
                        onPressed: () => _onRevokeMessage(message),
                      ),
                    ),
                  );
                }
              }
            },
            child: Text(localizations.confirm),
          ),
        ],
      ),
    );
  }

  /// 删除消息
  void _onDeleteMessage(Message message) {
    _logger.d('删除消息', extra: {'messageId': message.messageId});

    // 💢💢💢 在对话框外部获取ChatCubit引用，避免Provider上下文问题
    final chatCubit = context.read<ChatCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final localizations = AppLocalizations.of(context);

    // 显示确认对话框
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(localizations.deleteMessage),
        content: Text(localizations.confirmDeleteMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(localizations.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();

              // 💢💢💢 显示删除中状态
              messenger.showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 12),
                      Text(localizations.deletingMessage),
                    ],
                  ),
                  duration: const Duration(seconds: 10),
                ),
              );

              try {
                // 使用预先获取的ChatCubit引用（使用UUID作为messageId）
                await chatCubit.deleteMessage(message.messageId);

                // 💢💢💢 删除成功
                if (mounted) {
                  messenger.clearSnackBars();
                  messenger.showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle,
                              color: Colors.green, size: 20),
                          const SizedBox(width: 8),
                          Text(localizations.messageDeleted),
                        ],
                      ),
                      duration: const Duration(seconds: 2),
                      backgroundColor: Colors.green,
                    ),
                  );
                }

                // 💢💢💢 触觉反馈
                HapticFeedback.lightImpact();

                _logger.i('消息删除成功', extra: {
                  'messageId': message.messageId,
                });
              } catch (error) {
                _logger.e('删除消息失败', error: error, extra: {
                  'messageId': message.messageId,
                });

                if (mounted) {
                  messenger.clearSnackBars();
                  messenger.showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.error,
                              color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                                '${localizations.deleteFailed}: ${error.toString()}'),
                          ),
                        ],
                      ),
                      duration: const Duration(seconds: 3),
                      backgroundColor: Colors.red,
                      action: SnackBarAction(
                        label: localizations.retry,
                        textColor: Colors.white,
                        onPressed: () => _onDeleteMessage(message),
                      ),
                    ),
                  );
                }
              }
            },
            child: Text(localizations.confirm),
          ),
        ],
      ),
    );
  }

  /// 获取最后在线时间文本
  String _getLastSeenText(ChatState state) {
    final localizations = AppLocalizations.of(context);
    if (state.networkStatus == ChatState.kNetworkStatusConnected) {
      return localizations.onlineStatus;
    } else if (state.networkStatus == ChatState.kNetworkStatusConnecting) {
      return localizations.connecting;
    } else {
      return localizations.offlineStatus;
    }
  }

  /// 构建搜索模式的应用栏
  PreferredSizeWidget _buildSearchAppBar() {
    return AppBar(
      title: Row(
        children: [
          const ConnectionStatusIndicator(size: 14),
          const SizedBox(width: 4),
          Expanded(
            child: TextField(
              controller: _searchController, // 💢💢💢 使用专用的搜索控制器
              autofocus: true,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context).searchMessages,
                border: InputBorder.none,
                hintStyle: const TextStyle(color: Colors.grey),
              ),
              style: const TextStyle(color: Colors.black, fontSize: 16),
              onChanged: (query) {
                // 💢💢💢 实现搜索防抖（1秒）
                _searchDebounceTimer?.cancel();
                _searchDebounceTimer = Timer(
                  const Duration(milliseconds: 1000),
                  () {
                    context.read<ChatCubit>().performSearch(query);
                  },
                );
              },
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            // 💢💢💢 退出搜索时清空搜索框和取消防抖Timer
            _searchController.clear();
            _searchDebounceTimer?.cancel();
            context.read<ChatCubit>().exitSearchMode();
          },
          child: Text(
            AppLocalizations.of(context).cancel,
            style: const TextStyle(color: AppColors.primary, fontSize: 16),
          ),
        ),
      ],
    );
  }

  /// 构建搜索模式的底部栏
  Widget _buildSearchBottomBar() {
    return BlocBuilder<ChatCubit, ChatState>(
      buildWhen: (previous, current) {
        // 💢💢💢 确保在搜索相关状态变化时重建UI
        return previous.searchDateFilter != current.searchDateFilter ||
            previous.searchResultTotalCount != current.searchResultTotalCount ||
            previous.currentSearchResultIndex !=
                current.currentSearchResultIndex ||
            previous.isSearching != current.isSearching ||
            previous.searchQuery != current.searchQuery;
      },
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border(
              top: BorderSide(
                color: Colors.grey.withAlpha(51),
                width: 0.5,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
                offset: const Offset(0, -1),
                blurRadius: 4,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 💢💢💢 搜索选项工具栏（合并了导航功能）
              _buildSearchOptionsBar(state),
            ],
          ),
        );
      },
    );
  }

  /// 💢💢💢 新增：搜索选项工具栏（合并了导航功能）
  Widget _buildSearchOptionsBar(ChatState state) {
    // 获取搜索结果信息
    final hasResults = state.searchResultTotalCount > 0;
    final currentIndex = state.currentSearchResultIndex;
    final totalCount = state.searchResultTotalCount;

    // 计算导航按钮的启用状态
    final canGoPrev = hasResults && currentIndex > 1;
    final canGoNext = hasResults && currentIndex < totalCount;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          // 💢💢💢 左侧：日期跳转按钮
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => _showDateFilterPicker(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      AppLocalizations.of(context).jumpToDate,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 💢💢💢 中间：搜索状态指示器
          const SizedBox(width: 12),
          if (state.isSearching)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context).searching,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            )
          else if (state.searchQuery.trim().isNotEmpty && !hasResults)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.search_off,
                  size: 16,
                  color: Colors.grey.shade500,
                ),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context).noMatchFound,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),

          const Spacer(),

          // 💢💢💢 右侧：搜索结果导航
          if (hasResults) ...[
            // 搜索结果计数器
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                '$currentIndex / $totalCount',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
            ),

            const SizedBox(width: 8),

            // 导航按钮组
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 上一个结果按钮（因为列表反向，这里是下一个搜索结果）
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                      ),
                      onTap: canGoNext
                          ? () =>
                              context.read<ChatCubit>().goToNextSearchResult()
                          : null,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          Icons.keyboard_arrow_up,
                          size: 20,
                          color: canGoNext
                              ? Colors.grey.shade700
                              : Colors.grey.shade400,
                        ),
                      ),
                    ),
                  ),

                  // 分隔线
                  Container(
                    width: 1,
                    height: 24,
                    color: Colors.grey.shade300,
                  ),

                  // 下一个结果按钮（因为列表反向，这里是上一个搜索结果）
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                      onTap: canGoPrev
                          ? () =>
                              context.read<ChatCubit>().goToPrevSearchResult()
                          : null,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          size: 20,
                          color: canGoPrev
                              ? Colors.grey.shade700
                              : Colors.grey.shade400,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 显示日期选择器
  Future<void> _showDateFilterPicker(BuildContext context) async {
    final chatCubit = context.read<ChatCubit>();
    final availableDates = chatCubit.getAvailableDates();

    if (availableDates.isEmpty) {
      // 如果没有可用日期，显示提示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(AppLocalizations.of(context).noMessagesInChat)),
        );
      }
      return;
    }

    // 使用自定义日期选择器
    final selectedDate = await showDialog<DateTime>(
      context: context,
      builder: (context) => _CustomDatePickerDialog(
        availableDates: availableDates,
        initialDate: DateTime.now(),
      ),
    );

    if (selectedDate != null && mounted) {
      // 💢💢💢 修改逻辑：跳转到指定日期的第一条消息，而不是过滤
      // ignore: use_build_context_synchronously
      await _jumpToDateFirstMessage(context, selectedDate);
    }
  }

  /// 💢💢💢 新增：跳转到指定日期的第一条消息
  Future<void> _jumpToDateFirstMessage(
      BuildContext context, DateTime selectedDate) async {
    final chatCubit = context.read<ChatCubit>();
    final messenger = ScaffoldMessenger.of(context);

    try {
      // 查找指定日期的第一条消息
      final firstMessageOfDate =
          await chatCubit.findFirstMessageOfDate(selectedDate);

      if (firstMessageOfDate != null) {
        // 如果找到消息，滚动到该消息
        _scrollToMessage(firstMessageOfDate.messageIndex);

        // 显示成功提示
        if (mounted) {
          messenger.showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).jumpedToFirstMessage),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        // 如果没有找到消息，显示提示
        if (mounted) {
          final localizations = AppLocalizations.of(context);
          messenger.showSnackBar(
            SnackBar(
              content: Text(
                  '${selectedDate.month}/${selectedDate.day} ${localizations.noMessagesFoundOnDate}'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (error) {
      _logger.e('跳转到日期消息失败', error: error);
      if (mounted) {
        final localizations = AppLocalizations.of(context);
        messenger.showSnackBar(
          SnackBar(
            content: Text(localizations.jumpFailed),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// 💢💢💢 新增：重发消息
  void _onResendMessage(String messageId) {
    _logger.d('重发消息', extra: {
      'messageId': messageId,
    });

    // 调用ChatCubit的重发方法
    context.read<ChatCubit>().resendMessage(messageId);

    // 提供用户反馈
    final localizations = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(localizations.resendingMessage),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// 💢💢💢 新增：计算消息显示状态
  MessageDisplayStatus _calculateMessageDisplayStatus(
    Message message,
    Conversation conversation,
    CurrentUser? currentUser,
    bool isPrivateChat,
  ) {
    // 如果是私聊且有会话和当前用户信息，使用参与者信息计算
    if (isPrivateChat && currentUser != null) {
      // 获取对方参与者信息（私聊中除当前用户外的另一个参与者）
      final otherParticipant = conversation.participants
          .where((p) => p.userId != currentUser.userId)
          .firstOrNull;

      if (otherParticipant != null) {
        final messageIndex = message.messageIndex;
        final deliveredIndex = otherParticipant.deliveredMessageIndex;
        final readIndex = otherParticipant.readMessageIndex;

        final isRead = messageIndex <= readIndex;
        final isDelivered = messageIndex <= deliveredIndex;

        return MessageDisplayStatus(
          isRead: isRead,
          isDelivered: isDelivered,
          messageStatus: message.status,
        );
      }
    }

    // 回退到消息本身的状态
    return MessageDisplayStatus(
      isRead: message.status == MessageStatus.read,
      isDelivered: message.status == MessageStatus.delivered ||
          message.status == MessageStatus.read,
      messageStatus: message.status,
    );
  }

  /// 🆕 构建未读消息指示器
  Widget _buildUnreadIndicator(ChatState state) {
    // 在搜索模式下不显示未读指示器
    if (state.isSearchMode) {
      return const SizedBox.shrink();
    }

    // 计算未读消息信息
    final unreadInfo = _calculateUnreadIndicatorInfo(state);

    // 如果没有未读消息，不显示指示器
    if (!unreadInfo.hasUnread) {
      return const SizedBox.shrink();
    }

    // 获取输入框区域的高度估算
    // 基础输入框高度：padding(16) + 内容(52) + padding(16) = 84
    // 如果有表情面板或功能面板，还需要加上面板高度
    double inputAreaHeight = 84;
    if (_showMoreOptions || _showEmojiPanel) {
      inputAreaHeight += 120; // 面板高度估算
    }

    return Positioned(
      bottom: inputAreaHeight + 50, // 相对于输入框顶部向上16像素
      right: 0,
      child: UnreadIndicatorButton(
        unreadCount: unreadInfo.unreadCount,
        text: unreadInfo.indicatorText,
        isVisible: true,
        onTap: () => _scrollToLastUnreadMessage(state), // 🔄 修改：点击跳转到最新未读消息
      ),
    );
  }

  /// 🆕 计算未读指示器信息
  _UnreadIndicatorInfo _calculateUnreadIndicatorInfo(ChatState state) {
    final currentUserId = state.currentUser.userId;
    final conversation = state.conversation;

    // 获取未读数量
    final unreadCount = conversation.unreadCount(currentUserId);
    if (unreadCount <= 0) {
      return const _UnreadIndicatorInfo(
        hasUnread: false,
        unreadCount: 0,
        direction: _UnreadDirection.none,
        indicatorText: '',
      );
    }

    // 获取最新未读消息的索引（用于方向判断）
    final lastUnreadIndex =
        conversation.getLastUnreadMessageIndex(currentUserId);
    if (lastUnreadIndex == null) {
      return const _UnreadIndicatorInfo(
        hasUnread: false,
        unreadCount: 0,
        direction: _UnreadDirection.none,
        indicatorText: '',
      );
    }

    // 判断未读消息相对于当前滚动位置的方向（基于最新未读消息）
    final direction = _determineUnreadDirection(state, lastUnreadIndex);

    // 生成指示器文本
    final indicatorText = _generateUnreadIndicatorText(unreadCount, direction);

    return _UnreadIndicatorInfo(
      hasUnread: true,
      unreadCount: unreadCount,
      direction: direction,
      indicatorText: indicatorText,
      firstUnreadIndex: lastUnreadIndex, // 🔄 现在存储最新未读消息索引
    );
  }

  /// 🆕 判断未读消息相对于当前滚动位置的方向
  _UnreadDirection _determineUnreadDirection(
      ChatState state, int firstUnreadIndex) {
    // 如果没有当前滚动位置信息，认为未读消息在上方（历史消息方向）
    if (state.currentScrollPosition.messageId == null) {
      return _UnreadDirection.up;
    }

    // 获取当前滚动位置的消息索引
    final currentScrollIndex =
        state.currentScrollPosition.getListIndex(state.messages);
    if (currentScrollIndex == -1) {
      return _UnreadDirection.up;
    }

    final currentMessage = state.messages[currentScrollIndex];
    final currentMessageIndex = currentMessage.messageIndex;

    // 比较消息索引来判断方向
    if (firstUnreadIndex > currentMessageIndex) {
      // 第一条未读消息的索引更大，说明在更新的位置（下方）
      return _UnreadDirection.down;
    } else {
      // 第一条未读消息的索引更小，说明在更老的位置（上方）
      return _UnreadDirection.up;
    }
  }

  /// 🆕 生成未读指示器文本
  String _generateUnreadIndicatorText(
      int unreadCount, _UnreadDirection direction) {
    final countText = unreadCount.toString();

    switch (direction) {
      case _UnreadDirection.up:
        return '$countText ↑';
      case _UnreadDirection.down:
        return '$countText ↓';
      case _UnreadDirection.none:
        return countText;
    }
  }

  /// 🆕 滚动到最新的未读消息（会话中的最后一条消息）
  Future<void> _scrollToLastUnreadMessage(ChatState state) async {
    try {
      final currentUserId = state.currentUser.userId;
      final conversation = state.conversation;

      // 获取最新未读消息的索引（即最后一条消息的索引）
      final lastUnreadIndex =
          conversation.getLastUnreadMessageIndex(currentUserId);
      if (lastUnreadIndex == null) {
        _logger.w('没有找到最新未读消息的索引');
        return;
      }

      // 在当前消息列表中查找对应的消息
      final lastUnreadMessage = state.messages
          .where((msg) => msg.messageIndex == lastUnreadIndex)
          .firstOrNull;

      if (lastUnreadMessage != null) {
        // 如果消息在当前列表中，直接滚动到该消息
        await _scrollToMessage(
          lastUnreadMessage.messageIndex,
          alignment: 0.5, // 在屏幕中央显示
          showHighlight: true,
        );

        _logger.i('滚动到最新未读消息成功', extra: {
          'messageId': lastUnreadMessage.messageId,
          'messageIndex': lastUnreadIndex,
          'isLastMessage': true,
        });
      } else {
        _logger.w('最新未读消息不在当前列表中，使用jumpToMessageIndex加载', extra: {
          'lastUnreadIndex': lastUnreadIndex,
          'messageRange': state.messages.isEmpty
              ? 'empty'
              : '${state.messages.last.messageIndex}-${state.messages.first.messageIndex}',
        });

        // 使用jumpToMessageIndex来加载并跳转到最新未读消息
        await context.read<ChatCubit>().jumpToMessageIndex(lastUnreadIndex);

        _logger.i('已请求跳转到最新未读消息', extra: {
          'targetIndex': lastUnreadIndex,
        });
      }

      // 触觉反馈
      HapticFeedback.lightImpact();
    } catch (error) {
      _logger.e('滚动到最新未读消息失败', error: error);

      if (mounted) {
        final localizations = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.jumpToLatestFailed),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// 🆕 滚动到第一条未读消息（备用方法，暂时保留以备将来双重跳转功能使用）
  // ignore: unused_element
  Future<void> _scrollToFirstUnreadMessage(ChatState state) async {
    try {
      final currentUserId = state.currentUser.userId;
      final conversation = state.conversation;

      // 获取第一条未读消息的索引
      final firstUnreadIndex =
          conversation.getFirstUnreadMessageIndex(currentUserId);
      if (firstUnreadIndex == null) {
        _logger.w('没有找到第一条未读消息的索引');
        return;
      }

      // 在当前消息列表中查找对应的消息
      final firstUnreadMessage = state.messages
          .where((msg) => msg.messageIndex == firstUnreadIndex)
          .firstOrNull;

      if (firstUnreadMessage != null) {
        // 如果消息在当前列表中，直接滚动到该消息
        await _scrollToMessage(
          firstUnreadMessage.messageIndex,
          alignment: 0.5, // 在屏幕中央显示
          showHighlight: true,
        );

        _logger.i('滚动到第一条未读消息成功', extra: {
          'messageId': firstUnreadMessage.messageId,
          'messageIndex': firstUnreadIndex,
        });
      } else {
        _logger.w('第一条未读消息不在当前列表中', extra: {
          'firstUnreadIndex': firstUnreadIndex,
          'messageRange': state.messages.isEmpty
              ? 'empty'
              : '${state.messages.last.messageIndex}-${state.messages.first.messageIndex}',
        });

        // 显示提示
        if (mounted) {
          final localizations = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(localizations.unreadNotInList),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }

      // 触觉反馈
      HapticFeedback.lightImpact();
    } catch (error) {
      _logger.e('滚动到第一条未读消息失败', error: error);

      if (mounted) {
        final localizations = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.jumpToUnreadFailed),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }
}

/// 自定义日期选择器对话框
class _CustomDatePickerDialog extends StatefulWidget {
  final Set<DateTime> availableDates;
  final DateTime initialDate;

  const _CustomDatePickerDialog({
    required this.availableDates,
    required this.initialDate,
  });

  @override
  State<_CustomDatePickerDialog> createState() =>
      _CustomDatePickerDialogState();
}

class _CustomDatePickerDialogState extends State<_CustomDatePickerDialog> {
  late DateTime _currentDate;
  late DateTime _displayMonth;

  @override
  void initState() {
    super.initState();

    // 如果有可用日期，选择最新的日期；否则使用初始日期
    if (widget.availableDates.isNotEmpty) {
      final sortedDates = widget.availableDates.toList()
        ..sort((a, b) => b.compareTo(a)); // 按日期降序排列
      _currentDate = sortedDates.first; // 选择最新的日期
    } else {
      _currentDate = widget.initialDate;
    }

    _displayMonth = DateTime(_currentDate.year, _currentDate.month);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context).selectDate),
      content: SizedBox(
        width: 300,
        height: 450,
        child: Column(
          children: [
            // 提示文本
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(13),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: AppColors.primary),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '蓝色标记的日期有消息，选择日期可跳转到当天第一条消息',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // 月份导航
            _buildMonthNavigation(),
            const SizedBox(height: 16),
            // 日历网格
            Expanded(child: _buildCalendarGrid()),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context).cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _currentDate),
          child: Text(AppLocalizations.of(context).confirm),
        ),
      ],
    );
  }

  Widget _buildMonthNavigation() {
    // 💢💢💢 允许导航到所有月份，不限制只有消息的月份
    final prevMonth = DateTime(_displayMonth.year, _displayMonth.month - 1);
    final nextMonth = DateTime(_displayMonth.year, _displayMonth.month + 1);
    final now = DateTime.now();

    // 设置合理的时间范围：过去5年到未来1年
    final minDate = DateTime(now.year - 5, 1, 1);
    final maxDate = DateTime(now.year + 1, 12, 31);

    final canGoPrev = prevMonth.isAfter(minDate) ||
        prevMonth.isAtSameMomentAs(DateTime(minDate.year, minDate.month));
    final canGoNext = nextMonth.isBefore(maxDate) ||
        nextMonth.isAtSameMomentAs(DateTime(maxDate.year, maxDate.month));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: canGoPrev
              ? () {
                  setState(() {
                    _displayMonth = prevMonth;
                  });
                }
              : null,
          icon: Icon(
            Icons.chevron_left,
            color: canGoPrev ? null : Colors.grey.shade400,
          ),
        ),
        Text(
          '${_displayMonth.year}年${_displayMonth.month}月',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        IconButton(
          onPressed: canGoNext
              ? () {
                  setState(() {
                    _displayMonth = nextMonth;
                  });
                }
              : null,
          icon: Icon(
            Icons.chevron_right,
            color: canGoNext ? null : Colors.grey.shade400,
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarGrid() {
    final daysInMonth =
        DateTime(_displayMonth.year, _displayMonth.month + 1, 0).day;
    final firstDayOfMonth =
        DateTime(_displayMonth.year, _displayMonth.month, 1);
    final weekdayOfFirstDay =
        firstDayOfMonth.weekday % 7; // 0 = Sunday, 6 = Saturday

    return Column(
      children: [
        // 星期标题
        SizedBox(
          height: 30,
          child: Row(
            children: ['日', '一', '二', '三', '四', '五', '六']
                .map((day) => Expanded(
                      child: Center(
                        child: Text(
                          day,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: 8),
        // 日历网格
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.0,
            ),
            itemCount: daysInMonth + weekdayOfFirstDay,
            itemBuilder: (context, index) {
              if (index < weekdayOfFirstDay) {
                return const SizedBox(); // 空白位置
              }

              final day = index - weekdayOfFirstDay + 1;
              final date =
                  DateTime(_displayMonth.year, _displayMonth.month, day);
              final hasMessages = widget.availableDates.contains(date);
              final isSelected = date.isAtSameMomentAs(DateTime(
                  _currentDate.year, _currentDate.month, _currentDate.day));
              final isToday = _isSameDay(date, DateTime.now());

              return GestureDetector(
                onTap: () {
                  // 💢💢💢 允许选择任何日期，不限制只有消息的日期
                  setState(() {
                    _currentDate = date;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : (hasMessages
                            ? AppColors.primary.withAlpha(13)
                            : Colors.transparent),
                    borderRadius: BorderRadius.circular(8),
                    border: isToday
                        ? Border.all(
                            color: Theme.of(context).primaryColor, width: 2)
                        : (hasMessages
                            ? Border.all(color: AppColors.primary.withAlpha(51))
                            : Border.all(color: Colors.grey.shade200)),
                  ),
                  child: Center(
                    child: Text(
                      '$day',
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : (hasMessages
                                ? (isToday
                                    ? Theme.of(context).primaryColor
                                    : AppColors.primary)
                                : (isToday
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey.shade600)),
                        fontWeight: isSelected || isToday
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// 检查两个日期是否是同一天
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}

/// 音频波形绘制器
class AudioWavePainter extends CustomPainter {
  final double progress;

  AudioWavePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green.shade400
      ..strokeWidth = 1.5;

    const barCount = 12;
    const barWidth = 2.0;
    final spacing = (size.width - (barCount * barWidth)) / (barCount - 1);

    for (int i = 0; i < barCount; i++) {
      final x = i * (barWidth + spacing);

      // 创建动态高度效果
      final baseHeight = size.height * 0.3;
      final animatedHeight = size.height *
          0.7 *
          (0.5 + 0.5 * sin((progress * 2 * pi) + (i * 0.5)));

      final height = baseHeight + animatedHeight;
      final y = (size.height - height) / 2;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barWidth, height),
          const Radius.circular(1),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// 图片预览对话框
class _ImagePreviewDialog extends StatefulWidget {
  final File imageFile;

  const _ImagePreviewDialog({required this.imageFile});

  @override
  State<_ImagePreviewDialog> createState() => _ImagePreviewDialogState();
}

class _ImagePreviewDialogState extends State<_ImagePreviewDialog> {
  final TextEditingController _captionController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 标题栏
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey, width: 0.5),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '发送图片',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            // 图片预览
            Flexible(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    widget.imageFile,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.broken_image,
                                  size: 48, color: Colors.grey),
                              const SizedBox(height: 8),
                              Text(AppLocalizations.of(context).imageLoadFailed,
                                  style: const TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // 图片说明输入框
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _captionController,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context).addImageCaption,
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                maxLines: 2,
                maxLength: 200,
              ),
            ),

            // 操作按钮
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _isLoading ? null : () => Navigator.of(context).pop(),
                      child: Text(AppLocalizations.of(context).cancel),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _sendImage,
                      child: _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(AppLocalizations.of(context).send),
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

  void _sendImage() {
    setState(() {
      _isLoading = true;
    });

    // 返回确认结果和图片说明
    Navigator.of(context).pop({
      'confirmed': true,
      'caption': _captionController.text.trim().isEmpty
          ? null
          : _captionController.text.trim(),
    });
  }
}

/// 文件预览对话框
class _FilePreviewDialog extends StatefulWidget {
  final File file;

  const _FilePreviewDialog({required this.file});

  @override
  State<_FilePreviewDialog> createState() => _FilePreviewDialogState();
}

class _FilePreviewDialogState extends State<_FilePreviewDialog> {
  final TextEditingController _captionController = TextEditingController();
  bool _isLoading = false;
  late String _fileName;
  late String _fileSize;
  late String _fileExtension;
  IconData _fileIcon = Icons.insert_drive_file;

  @override
  void initState() {
    super.initState();
    _initFileInfo();
  }

  void _initFileInfo() {
    _fileName = widget.file.path.split('/').last;

    final fileSizeBytes = widget.file.lengthSync();
    _fileSize = _formatFileSize(fileSizeBytes);

    // 文件模式：统一使用通用文件图标
    _fileIcon = Icons.insert_drive_file;
    _fileExtension = 'FILE'; // 统一显示为FILE类型
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  Color _getFileIconColor(String extension) {
    // 文件模式：统一使用灰色
    return Colors.grey;
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 标题栏
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey, width: 0.5),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context).sendFile,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            // 文件信息预览
            Flexible(
              child: Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 文件图标
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: _getFileIconColor(_fileExtension)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _fileIcon,
                        size: 40,
                        color: _getFileIconColor(_fileExtension),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 文件名
                    Text(
                      _fileName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // 文件大小
                    Text(
                      _fileSize,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // 文件类型
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getFileIconColor(_fileExtension)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _fileExtension.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          color: _getFileIconColor(_fileExtension),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 文件说明输入框
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _captionController,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context).addFileCaption,
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                maxLines: 2,
                maxLength: 200,
              ),
            ),

            // 操作按钮
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _isLoading ? null : () => Navigator.of(context).pop(),
                      child: Text(AppLocalizations.of(context).cancel),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _sendFile,
                      child: _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(AppLocalizations.of(context).send),
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

  void _sendFile() {
    setState(() {
      _isLoading = true;
    });

    // 返回确认结果和文件说明
    Navigator.of(context).pop({
      'confirmed': true,
      'caption': _captionController.text.trim().isEmpty
          ? null
          : _captionController.text.trim(),
    });
  }
}

/// 🆕 未读指示器信息
class _UnreadIndicatorInfo {
  final bool hasUnread;
  final int unreadCount;
  final _UnreadDirection direction;
  final String indicatorText;
  final int? firstUnreadIndex; // 💡 注意：现在实际存储的是最新未读消息索引，保持向后兼容

  const _UnreadIndicatorInfo({
    required this.hasUnread,
    required this.unreadCount,
    required this.direction,
    required this.indicatorText,
    this.firstUnreadIndex,
  });
}

/// 🆕 未读消息方向
enum _UnreadDirection {
  up, // 未读消息在当前位置上方（历史消息方向）
  down, // 未读消息在当前位置下方（新消息方向）
  none, // 无方向或无法确定
}
