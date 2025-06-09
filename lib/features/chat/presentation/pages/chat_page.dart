import 'dart:async';
import 'dart:math';

import 'package:cc/core/database/models/conversation.dart';
import 'package:cc/core/services/log_service.dart';
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

class _ChatPageState extends State<ChatPage> {
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

    // 监听滚动位置变化
    _itemPositionsListener.itemPositions.addListener(_onScrollPositionChanged);
  }

  @override
  void dispose() {
    _textController.dispose();
    _searchController.dispose();
    _focusNode.dispose();
    _scrollDebounceTimer?.cancel();
    _searchDebounceTimer?.cancel();
    super.dispose();
  }

  /// 💢💢💢 滚动位置变化监听
  void _onScrollPositionChanged() {
    final positions = _itemPositionsListener.itemPositions.value;
    if (positions.isNotEmpty) {
      _scrollDebounceTimer?.cancel();
      _scrollDebounceTimer = Timer(const Duration(milliseconds: 200), () {
        _updateCurrentScrollPosition();

        // 检查是否需要加载更多历史消息
        final state = context.read<ChatCubit>().state;

        // 💢💢💢 过滤掉超出消息列表范围的位置
        final validPositions = positions
            .where((position) =>
                position.index >= 0 && position.index < state.messages.length)
            .toList();

        final lastVisibleIndex = validPositions.lastOrNull?.index;

        if (lastVisibleIndex != null &&
            lastVisibleIndex >= state.messages.length - 10 &&
            state.hasMoreHistory &&
            !state.isSearchMode && // 💢💢💢 搜索模式下不加载历史消息
            !state.isCleaningMessages) {
          // 💢💢💢 清理消息状态下不加载历史消息
          _logger.i('检查是否需要加载更多历史消息', extra: {
            'lastVisibleIndex': lastVisibleIndex,
            'messagesLength': state.messages.length,
          });
          _loadMoreHistoryWithPositionMaintenance();
        }
      });
    }
  }

  /// 💢💢💢 更新ChatState中的当前滚动位置
  void _updateCurrentScrollPosition() {
    final positions = _itemPositionsListener.itemPositions.value;
    final state = context.read<ChatCubit>().state;

    // 💢💢💢 过滤掉超出消息列表范围的位置
    final validPositions = positions
        .where((position) =>
            position.index >= 0 && position.index < state.messages.length)
        .toList();

    _logger.w('更新当前滚动位置', extra: {
      'originalPositions': positions.map((e) => e.index).toList(),
      'validPositions': validPositions.map((e) => e.index).toList(),
      'lastVisibleIndex': validPositions.lastOrNull?.index,
      'messageCount': state.messages.length,
    });

    if (validPositions.isEmpty || state.messages.isEmpty) {
      return;
    }

    // 💢💢💢 只传递有效的位置给ChatCubit
    context.read<ChatCubit>().updateCurrentScrollPosition(validPositions);
  }

  /// 💢💢💢 加载更多历史消息 💢💢💢 调用前已防抖
  void _loadMoreHistoryWithPositionMaintenance() async {
    final state = context.read<ChatCubit>().state;
    if (!state.canLoadMoreHistory || state.isLoadingMoreMessages) {
      return;
    }
    _logger.i('加载更多历史消息', extra: {
      'conversationId': state.conversation.id,
    });
    context.read<ChatCubit>().loadMoreMessages();
  }

  /// 💢💢💢 完善的滚动到指定消息方法
  Future<void> _scrollToMessage(
    String messageId, {
    Duration? duration,
    Curve? curve,
    double? alignment,
    bool showHighlight = false,
  }) async {
    try {
      final state = context.read<ChatCubit>().state;

      _logger.i('开始滚动到消息', extra: {
        'messageId': messageId,
        'totalMessages': state.messages.length,
        'showHighlight': showHighlight,
      });

      // 查找消息在当前列表中的索引
      final messageIndex = state.messages.indexWhere(
        (message) => message.messageId == messageId,
      );

      if (messageIndex == -1) {
        _logger.w('消息未在当前列表中找到', extra: {
          'messageId': messageId,
          'searchInDatabase': true,
        });

        // 💢💢💢 如果消息不在当前列表中，尝试从数据库加载
        await _loadMessageAndScroll(messageId);
        return;
      }

      // 💢💢💢 检查滚动控制器是否可用
      if (!_itemScrollController.isAttached) {
        _logger.w('滚动控制器未附加，延迟执行滚动');

        // 等待下一帧再尝试滚动
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToMessage(
            messageId,
            duration: duration,
            curve: curve,
            alignment: alignment,
            showHighlight: showHighlight,
          );
        });
        return;
      }

      // 💢💢💢 执行滚动
      await _itemScrollController.scrollTo(
        index: messageIndex,
        duration: duration ?? const Duration(milliseconds: 300),
        curve: curve ?? Curves.easeInOut,
        alignment: alignment ?? 0.5, // 默认居中显示
      );

      _logger.i('滚动完成', extra: {
        'messageId': messageId,
        'messageIndex': messageIndex,
        'alignment': alignment ?? 0.5,
      });

      // 💢💢💢 可选的高亮效果
      if (showHighlight) {
        _highlightMessage(messageId);
      }
    } catch (error) {
      _logger.e('滚动到消息失败', error: error, extra: {
        'messageId': messageId,
      });
    }
  }

  /// 💢💢💢 新增：加载消息并滚动（当消息不在当前列表中时）
  Future<void> _loadMessageAndScroll(String messageId) async {
    try {
      _logger.i('消息不在当前列表，尝试加载消息', extra: {
        'messageId': messageId,
      });

      final chatCubit = context.read<ChatCubit>();

      // 💢💢💢 尝试加载包含目标消息的消息段
      final success = await chatCubit.loadMessagesAroundMessage(messageId);

      if (success) {
        // 加载成功后，等待UI更新，然后再次尝试滚动
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToMessage(messageId, showHighlight: true);
        });
      } else {
        _logger.w('无法加载包含目标消息的消息段', extra: {
          'messageId': messageId,
        });

        // 显示提示信息
        if (mounted) {
          final messenger = ScaffoldMessenger.of(context);
          messenger.showSnackBar(
            const SnackBar(
              content: Text('无法定位到该消息'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (error) {
      _logger.e('加载消息并滚动失败', error: error, extra: {
        'messageId': messageId,
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

  /// 发送消息
  void _sendMessage() {
    final text = _textController.text.trim();

    // 验证输入
    if (text.isEmpty) {
      return;
    }

    // 验证文本长度
    if (text.length > 4000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('消息内容过长，请控制在4000字符以内'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // 发送消息
    try {
      context.read<ChatCubit>().sendTextMessage(text);
      _textController.clear();

      // 收起键盘
      FocusScope.of(context).unfocus();

      // 轻微震动反馈
      HapticFeedback.lightImpact();
    } catch (error) {
      _logger.e('发送消息失败', error: error);

      // 显示错误提示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('发送失败: ${error.toString()}'),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: '重试',
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
          body: Column(
            children: [
              // 🔄 新增：同步状态横幅
              if (state.isSyncing)
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Colors.blue.withAlpha(20),
                  child: const Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.blue),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        '正在同步消息...',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              // 🔄 新增：同步期间新消息提示
              if (state.hasNewMessagesDuringSync)
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Colors.orange.withAlpha(20),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.message,
                        size: 16,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '有 ${state.pendingMessages.length} 条新消息正在同步中...',
                          style: const TextStyle(
                            color: Colors.orange,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      // 可选：提供手动刷新按钮
                      TextButton(
                        onPressed: () {
                          // 触发强制同步
                          // TODO: 实现强制同步方法
                        },
                        style: TextButton.styleFrom(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          '刷新',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              // 🔄 新增：增量同步指示器
              if (state.isIncrementalSyncing)
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  color: Colors.green.withAlpha(10),
                  child: const Row(
                    children: [
                      SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          valueColor: AlwaysStoppedAnimation(Colors.green),
                        ),
                      ),
                      SizedBox(width: 6),
                      Text(
                        '检查新消息...',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: _buildMessagesList(),
              ),
              state.isSearchMode ? _buildSearchBottomBar() : _buildInputArea(),
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
          // 主标题行：会话名称 + 静音图标
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Hero(
                tag: 'chat_title_${state.conversation.conversationId}',
                child: Material(
                  color: Colors.transparent,
                  child: Text(
                    state.conversation.name ?? '未知联系人',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              // 静音图标（只在静音时显示）
              if (state.conversation.isMuted)
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
        // 会话头像
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: GestureDetector(
            onTap: () {
              final chatCubit = context.read<ChatCubit>();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BlocProvider<ChatCubit>.value(
                    value: chatCubit,
                    child: const ChatInfoPage(),
                  ),
                ),
              );
            },
            child: Hero(
              tag: 'chat_avatar_${state.conversation.conversationId}',
              child: CircleAvatar(
                radius: 18.0,
                backgroundColor: Colors.grey[300],
                backgroundImage: state.conversation.avatar != null
                    ? NetworkImage(state.conversation.avatar!)
                    : null,
                child: state.conversation.avatar == null
                    ? Text(
                        state.conversation.name?.isNotEmpty == true
                            ? state.conversation.name![0].toUpperCase()
                            : 'X',
                        style: const TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
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

  /// 💢💢💢💢💢💢💢💢💢💢💢💢💢💢   构建消息列表   💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢
  Widget _buildMessagesList() {
    return BlocListener<ChatCubit, ChatState>(
      listenWhen: (previous, current) {
        // 💢💢💢 监听搜索结果索引变化，触发自动滚动
        final searchResultChanged = previous.currentSearchResultIndex !=
                current.currentSearchResultIndex ||
            (previous.searchResultMessageIds.length !=
                    current.searchResultMessageIds.length &&
                current.searchResultMessageIds.isNotEmpty);

        // 💢💢💢 监听滚动位置变化（初始化时自动滚动到最新消息）
        final scrollPositionChanged =
            previous.currentScrollPosition.messageId !=
                    current.currentScrollPosition.messageId &&
                current.currentScrollPosition.messageId != null &&
                !current.isSearchMode; // 非搜索模式下才响应滚动位置变化

        final shouldListen = searchResultChanged || scrollPositionChanged;

        if (shouldListen) {
          _logger.d('💢 BlocListener 条件满足', extra: {
            'searchResultChanged': searchResultChanged,
            'scrollPositionChanged': scrollPositionChanged,
            'prevScrollMessageId': previous.currentScrollPosition.messageId,
            'currentScrollMessageId': current.currentScrollPosition.messageId,
            'prevIndex': previous.currentSearchResultIndex,
            'currentIndex': current.currentSearchResultIndex,
          });
        }

        return shouldListen;
      },
      listener: (context, state) {
        _logger.d('💢💢💢💢💢💢💢 BlocListener 被触发');

        // 💢💢💢 自动滚动到当前搜索结果
        if (state.isSearchMode &&
            state.searchResultMessageIds.isNotEmpty &&
            state.currentSearchResultIndex <
                state.searchResultMessageIds.length) {
          final currentResultMessageId =
              state.searchResultMessageIds[state.currentSearchResultIndex];

          _logger.d('💢 BlocListener 搜索模式滚动', extra: {
            'targetMessageId': currentResultMessageId,
            'currentIndex': state.currentSearchResultIndex,
          });

          // 延迟执行滚动，等待UI更新完成
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _logger.d('💢 BlocListener 执行搜索滚动回调');
            _scrollToMessage(currentResultMessageId);
          });
        }
        // 💢💢💢 自动滚动到设置的位置（初始化时滚动到最新消息）
        else if (!state.isSearchMode &&
            state.currentScrollPosition.messageId != null) {
          final targetMessageId = state.currentScrollPosition.messageId!;
          final targetIndex = state.currentScrollPosition.messageIndex ?? 0;
          final alignment = state.currentScrollPosition.relativePosition ?? 0.0;

          _logger.i('💢 BlocListener 初始化滚动到最新消息', extra: {
            'targetMessageId': targetMessageId,
            'targetIndex': targetIndex,
            'alignment': alignment,
            'reason': '根据业务逻辑显示最新消息',
          });

          // 延迟执行滚动，等待UI更新完成
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _logger.d('💢 BlocListener 执行初始化滚动回调');
            _scrollToMessage(
              targetMessageId,
              alignment: alignment,
              duration: const Duration(milliseconds: 100), // 快速滚动
            );
          });
        }
      },
      child: BlocBuilder<ChatCubit, ChatState>(
        buildWhen: (previous, current) {
          // 检查搜索模式状态变化
          if (previous.currentSearchResultIndex !=
              current.currentSearchResultIndex) {
            _logger.i('💢 BlocBuilder 搜索模式状态变化');
            return true;
          }

          // 检查消息列表是否发生变化
          // 1. 首先检查长度是否不同
          if (previous.messages.length != current.messages.length) {
            _logger.i('💢 BlocBuilder 长度变化');
            return true;
          }

          // 2. 长度相同时，检查内容是否相同（使用identical判断引用是否相同）
          if (!identical(previous.messages, current.messages)) {
            _logger.i('💢 BlocBuilder 内容变化');
            return true;
          }

          // 💢💢💢 新增：检查消息更新触发器
          if (previous.messageUpdateTrigger != current.messageUpdateTrigger) {
            _logger.i('💢 BlocBuilder 消息更新触发器变化', extra: {
              'prevTrigger': previous.messageUpdateTrigger,
              'currTrigger': current.messageUpdateTrigger,
            });
            return true;
          }

          _logger.d('💢 BlocBuilder 无变化');
          return false;
        },
        builder: (context, state) {
          _logger.w('💢 BlocBuilder builder 被调用', extra: {
            'stateHash': state.hashCode,
            'messagesLength': state.messages.length,
            'isSearchMode': state.isSearchMode,
            'isSearching': state.isSearching,
          });

          _logger.i('💢 BlocBuilder 重绘');

          // 获取当前应该显示的消息列表
          final displayMessages =
              context.read<ChatCubit>().getCurrentDisplayMessages();

          // 搜索模式下的特殊状态处理
          if (state.isSearchMode) {
            if (state.isSearching) {
              return Stack(
                children: [
                  _buildBackground(),
                  const Center(child: CircularProgressIndicator()),
                ],
              );
            }

            if (state.searchQuery.trim().isNotEmpty &&
                displayMessages.isEmpty) {
              return Stack(
                children: [
                  _buildBackground(),
                  const Center(
                    child: Text(
                      '没有找到匹配的消息',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ),
                ],
              );
            }
          }

          // 正常模式下的状态处理
          if (!state.isSearchMode) {
            if (state.isLoadingMessages && state.messages.isEmpty) {
              return Stack(
                children: [
                  _buildBackground(),
                  const Center(child: CircularProgressIndicator()),
                ],
              );
            }

            if (state.messages.isEmpty) {
              return Stack(
                children: [
                  _buildBackground(),
                  const Center(
                    child: Text(
                      '还没有消息\n发送第一条消息开始聊天吧！',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              );
            }
          }

          // 显示消息列表内容
          return _buildMessagesContent(displayMessages, state);
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

  /// 构建消息内容
  Widget _buildMessagesContent(List<Message> messages, ChatState state) {
    // 处理消息列表，添加分隔符
    final currentUserId = state.currentUser?.userId ?? '';
    final isPrivateChat = state.conversation.conversationId.isNotEmpty
        ? state.conversation.type == ConversationType.private
        : true; // 默认值，当会话还未初始化时
    final processedItems = MessageListProcessor.processMessages(
      messages: messages,
      currentUserId: currentUserId,
      isPrivateChat: isPrivateChat,
    );

    return Stack(
      children: [
        _buildBackground(),
        // 消息列表内容
        Column(
          children: [
            // 加载更多历史消息指示器 (仅在非搜索模式下显示)
            if (!state.isSearchMode && state.isLoadingMoreMessages)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),

            // 消息列表 💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢
            Expanded(
              child: ScrollablePositionedList.builder(
                itemCount: processedItems.length,
                itemBuilder: (context, index) {
                  final item = processedItems[index];

                  // 根据类型渲染不同的组件
                  if (item is MessageListItemData) {
                    final message = item.message as Message;

                    // 💢💢💢 检查消息是否为搜索结果
                    final chatCubit = context.read<ChatCubit>();
                    final isSearchResult =
                        chatCubit.isSearchResult(message.messageId);
                    final isCurrentSearchResult =
                        chatCubit.isCurrentSearchResult(message.messageId);
                    final searchQuery =
                        state.isSearchMode ? state.searchQuery : null;

                    return MessageItem(
                      key: ValueKey(message.messageId),
                      message: message,
                      isCurrentUser: item.isCurrentUser,
                      showAvatar: item.showAvatar,
                      showTail: item.showTail,
                      isPrivateChat: item.isPrivateChat,
                      onTap: () => _onMessageTap(message),
                      onResend: message.status == 'failed' && item.isCurrentUser
                          ? () => _onResendMessage(message.messageId)
                          : null, // 💢💢💢 新增：重发回调
                      // 💢💢💢 新增搜索相关参数
                      isSearchResult: isSearchResult,
                      isCurrentSearchResult: isCurrentSearchResult,
                      searchQuery: searchQuery,
                    );
                  } else if (item is MessageListItemDateSeparator) {
                    return DateSeparator(
                      key: ValueKey('date_${item.date.millisecondsSinceEpoch}'),
                      date: item.date,
                    );
                  } else {
                    // 未知类型，返回空容器
                    return const SizedBox.shrink();
                  }
                },
                itemScrollController: _itemScrollController,
                itemPositionsListener: _itemPositionsListener,
                initialScrollIndex:
                    state.currentScrollPosition.messageIndex ?? 0,
                initialAlignment:
                    state.currentScrollPosition.relativePosition ?? 0.0,
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
  }

  /// 构建输入区域
  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          top: BorderSide(
            color: Colors.grey.withAlpha(51), // 替代过时的withOpacity
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.attach_file),
            onPressed: () {
              // TODO 实现文件附件功能
            },
          ),
          Expanded(
            child: TextField(
              controller: _textController,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: '输入消息...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.withAlpha(51), // 替代过时的withOpacity
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8.0),
          BlocBuilder<ChatCubit, ChatState>(
            builder: (context, state) {
              return IconButton(
                icon: Icon(
                  Icons.send,
                  color: state.isSending
                      ? Colors.grey
                      : Theme.of(context).primaryColor,
                ),
                onPressed: state.isSending ? null : _sendMessage,
              );
            },
          ),
        ],
      ),
    );
  }

  /// 消息点击事件
  void _onMessageTap(Message message) {
    // TODO 实现消息点击逻辑，如显示消息详情、复制等
  }

  /// 获取最后在线时间文本
  String _getLastSeenText(ChatState state) {
    if (state.networkStatus == ChatState.kNetworkStatusConnected) {
      return '在线';
    } else if (state.networkStatus == ChatState.kNetworkStatusConnecting) {
      return '连接中...';
    } else {
      return '离线';
    }
  }

  /// 构建搜索模式的应用栏
  PreferredSizeWidget _buildSearchAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      automaticallyImplyLeading: false, // 禁用自动添加的leading按钮
      title: TextField(
        controller: _searchController, // 💢💢💢 使用专用的搜索控制器
        autofocus: true,
        decoration: const InputDecoration(
          hintText: '搜索消息...',
          border: InputBorder.none,
          hintStyle: TextStyle(color: Colors.grey),
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
      actions: [
        TextButton(
          onPressed: () {
            // 💢💢💢 退出搜索时清空搜索框和取消防抖Timer
            _searchController.clear();
            _searchDebounceTimer?.cancel();
            context.read<ChatCubit>().exitSearchMode();
          },
          child: const Text(
            '取消',
            style: TextStyle(color: Colors.blue, fontSize: 16),
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
                      '跳转到日期',
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
                  '搜索中...',
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
                  '无匹配结果',
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
          const SnackBar(content: Text('当前会话暂无消息')),
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
        _scrollToMessage(firstMessageOfDate.messageId);

        // 显示成功提示
        if (mounted) {
          messenger.showSnackBar(
            SnackBar(
              content:
                  Text('已跳转到 ${selectedDate.month}/${selectedDate.day} 的第一条消息'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        // 如果没有找到消息，显示提示
        if (mounted) {
          messenger.showSnackBar(
            SnackBar(
              content: Text('${selectedDate.month}/${selectedDate.day} 没有找到消息'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (error) {
      _logger.e('跳转到日期消息失败', error: error);
      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('跳转失败，请重试'),
            duration: Duration(seconds: 2),
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('正在重发消息...'),
        duration: Duration(seconds: 2),
      ),
    );
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
      title: const Text('选择日期'),
      content: SizedBox(
        width: 300,
        height: 450,
        child: Column(
          children: [
            // 提示文本
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      size: 16, color: Colors.blue.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '蓝色标记的日期有消息，选择日期可跳转到当天第一条消息',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade600,
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
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _currentDate),
          child: const Text('确定'),
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
                            ? Colors.blue.shade50
                            : Colors.transparent),
                    borderRadius: BorderRadius.circular(8),
                    border: isToday
                        ? Border.all(
                            color: Theme.of(context).primaryColor, width: 2)
                        : (hasMessages
                            ? Border.all(color: Colors.blue.shade200)
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
                                    : Colors.blue.shade700)
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
