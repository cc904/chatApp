import 'dart:async';
import 'dart:math';

import 'package:cc/core/database/models/conversation.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/features/chat/presentation/pages/chat_info_page.dart';
import 'package:flutter/material.dart';
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
  // final Conversation conversation;
  // final User contact;

  const ChatPage({
    super.key,
    // required this.conversation,
    // required this.contact,
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

    _init();
  }

  Future<void> _init() async {}

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
        final lastVisibleIndex = positions.lastOrNull?.index;
        // _logger.i('检查是否需要加载更多历史消息', extra: {
        //   'messagesLength': state.messages.length,
        //   'lastVisibleIndex': lastVisibleIndex,
        // });
        if (lastVisibleIndex != null &&
            lastVisibleIndex >= state.messages.length - 10 &&
            state.hasMoreHistory &&
            !state.isSearchMode && // 💢💢💢 搜索模式下不加载历史消息
            !state.isCleaningMessages && // 💢💢💢 清理消息状态下不加载历史消息
            lastVisibleIndex < state.messages.length) {
          // 💢💢💢 确保索引在有效范围内
          _logger.i('检查是否需要加载更多历史消息', extra: {
            'lastVisibleIndex': lastVisibleIndex,
            'messagesLength': state.messages.length,
          });
          _loadMoreHistoryWithPositionMaintenance();
        } else if (lastVisibleIndex != null &&
            lastVisibleIndex >= state.messages.length) {
          // 💢💢💢 索引超出范围，可能是清理消息后的异常状态
          _logger.w('检测到异常滚动位置，跳过加载更多', extra: {
            'lastVisibleIndex': lastVisibleIndex,
            'messagesLength': state.messages.length,
            'isSearchMode': state.isSearchMode,
            'isCleaningMessages': state.isCleaningMessages,
          });
        }
      });
    }
  }

  /// 💢💢💢 更新ChatState中的当前滚动位置
  void _updateCurrentScrollPosition() {
    final positions = _itemPositionsListener.itemPositions.value;
    final state = context.read<ChatCubit>().state;
    _logger.w('更新当前滚动位置', extra: {
      'positions': positions.map((e) => e.index).toList(),
      'lastVisibleIndex': positions.lastOrNull?.index,
      'messageCount': state.messages.length,
    });

    if (positions.isEmpty || state.messages.isEmpty) {
      return;
    }

    context.read<ChatCubit>().updateCurrentScrollPosition(positions);
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

  /// 恢复到保存的滚动位置
  Future<void> _restoreToScrollPosition(
      CurrentScrollPosition positionInfo) async {
    for (int attempt = 0; attempt < 5; attempt++) {
      await Future.delayed(Duration(milliseconds: 100 + (attempt * 50)));

      // ignore: use_build_context_synchronously
      final state = context.read<ChatCubit>().state;
      final messageIndex = state.messages.indexWhere(
        (message) => message.messageId == positionInfo.messageId,
      );

      if (messageIndex != -1) {
        _logger.i('恢复到精确位置', extra: {
          'messageId': positionInfo.messageId,
          'originalIndex': positionInfo.messageIndex,
          'newIndex': messageIndex,
          'indexOffset': messageIndex - (positionInfo.messageIndex ?? 0),
          'relativePosition': positionInfo.relativePosition ?? 0.0,
          'attempt': attempt + 1,
        });

        try {
          // 滚动到消息，保持相对位置
          await _itemScrollController.scrollTo(
            index: messageIndex,
            duration: const Duration(milliseconds: 1), // 极短动画，几乎看不出来
            curve: Curves.linear,
            alignment: positionInfo.relativePosition ?? 0.0,
          );

          break;
        } catch (error) {
          if (attempt == 4) {
            _logger.e('精确位置恢复失败，使用备用方案', error: error);
            // 备用方案：直接跳转
            _itemScrollController.jumpTo(index: messageIndex);
          }
        }
      }
    }
  }

  /// 从ChatState恢复滚动位置 300ms 后恢复
  Future<void> _restoreScrollPositionFromState() async {
    final state = context.read<ChatCubit>().state;
    final scrollPosition = state.currentScrollPosition;

    if (!scrollPosition.isValid) {
      _logger.d('没有有效的滚动位置信息可恢复');
      return;
    }

    _logger.i('从状态恢复滚动位置', extra: {
      'messageId': scrollPosition.messageId,
      'originalIndex': scrollPosition.messageIndex,
      'relativePosition': scrollPosition.relativePosition,
    });

    // 查找消息的当前索引
    final messageIndex = state.messages.indexWhere(
      (message) => message.messageId == scrollPosition.messageId,
    );

    if (messageIndex != -1) {
      try {
        await _itemScrollController.scrollTo(
          index: messageIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          alignment: scrollPosition.relativePosition ?? 0.0,
        );

        _logger.i('滚动位置恢复成功', extra: {
          'messageId': scrollPosition.messageId,
          'targetIndex': messageIndex,
        });
      } catch (error) {
        _logger.e('恢复滚动位置失败', error: error);
        // 备用方案：直接跳转
        _itemScrollController.jumpTo(index: messageIndex);
      }
    } else {
      _logger.w('未找到目标消息，无法恢复位置', extra: {
        'messageId': scrollPosition.messageId,
      });
    }
  }

  /// 滚动到底部
  void _scrollToBottom() {
    final state = context.read<ChatCubit>().state;
    if (state.messages.isNotEmpty) {
      _itemScrollController.scrollTo(
        index: state.messages.length - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  /// 滚动到指定消息
  void _scrollToMessage(String messageId) {
    final state = context.read<ChatCubit>().state;
    final messageIndex = state.messages.indexWhere(
      (message) => message.messageId == messageId,
    );

    if (messageIndex != -1) {
      _itemScrollController.scrollTo(
        index: messageIndex,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
      );
    }
  }


  /// 发送消息
  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      context.read<ChatCubit>().sendTextMessage(text);
      _textController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatCubit, ChatState>(
      buildWhen: (previous, current) {
        return previous.isSearchMode != current.isSearchMode ||
            previous.searchQuery != current.searchQuery;
      },
      builder: (context, state) {
        return Scaffold(
          appBar: state.isSearchMode ? _buildSearchAppBar() : _buildAppBar(),
          body: Column(
            children: [
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
  PreferredSizeWidget _buildAppBar() {
    final state = context.read<ChatCubit>().state;
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
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
          BlocBuilder<ChatCubit, ChatState>(
            builder: (context, state) {
              return Hero(
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
              );
            },
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
        final shouldListen = previous.currentSearchResultIndex !=
                current.currentSearchResultIndex ||
            (previous.searchResultMessageIds.length !=
                    current.searchResultMessageIds.length &&
                current.searchResultMessageIds.isNotEmpty);

        if (shouldListen) {
          _logger.d('💢 BlocListener 条件满足', extra: {
            'prevIndex': previous.currentSearchResultIndex,
            'currentIndex': current.currentSearchResultIndex,
            'prevResultIds': previous.searchResultMessageIds.length,
            'currentResultIds': current.searchResultMessageIds.length,
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

          _logger.d('💢 BlocListener 准备滚动', extra: {
            'targetMessageId': currentResultMessageId,
            'currentIndex': state.currentSearchResultIndex,
          });

          // 延迟执行滚动，等待UI更新完成
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _logger.d('💢 BlocListener 执行滚动回调');
            _scrollToMessage(currentResultMessageId);
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

  /// 💢💢💢
  // CurrentScrollPosition initialScrollPosition(ChatState state) {
  //   final positions = _itemPositionsListener.itemPositions.value;
  //   final position = state.currentScrollPosition;

  //   if (positions.length >= state.messages.length || !position.isValid) {
  //     return const CurrentScrollPosition(
  //       messageId: '',
  //       messageIndex: 0,
  //       relativePosition: 0.0,
  //     );
  //   }
  //   _logger.i('初始滚动位置', extra: {
  //     'positions': positions.map((e) => e.index).toList(),
  //     'lastVisibleIndex': positions.last.index,
  //     'messageCount': state.messages.length,
  //   });
  //   return position;
  // }

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

  /// 判断是否为当前用户的消息
  bool _isCurrentUserMessage(Message message, ChatState state) {
    if (state.currentUser != null) {
      return message.senderId == state.currentUser!.userId;
    }
    // 临时逻辑：假设senderId等于当前用户ID
    return false; // TODO 根据实际逻辑判断
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
      builder: (context, state) {
        // 💢💢💢 获取当前搜索信息
        final searchInfo = context.read<ChatCubit>().getCurrentSearchInfo();
        final hasResults = searchInfo.isNotEmpty;

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
              // 💢💢💢 搜索结果导航栏
              if (hasResults) _buildSearchNavigationBar(searchInfo),

              // 💢💢💢 搜索选项工具栏
              _buildSearchOptionsBar(state),
            ],
          ),
        );
      },
    );
  }

  /// 💢💢💢 新增：搜索结果导航栏
  Widget _buildSearchNavigationBar(Map<String, dynamic> searchInfo) {
    final currentIndex = searchInfo['currentIndex'] as int;
    final totalCount = searchInfo['totalCount'] as int;

    // 💢💢💢 计算按钮的启用状态（线性导航）
    final canGoPrev = currentIndex > 1; // 不是第一个
    final canGoNext = currentIndex < totalCount; // 不是最后一个

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
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

          const Spacer(),

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
                        ? () => context.read<ChatCubit>().goToNextSearchResult()
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
                        ? () => context.read<ChatCubit>().goToPrevSearchResult()
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
      ),
    );
  }

  /// 💢💢💢 新增：搜索选项工具栏
  Widget _buildSearchOptionsBar(ChatState state) {
    return Row(
      children: [
        // 搜索状态指示器
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
        else if (state.searchQuery.trim().isNotEmpty &&
            state.searchResultTotalCount == 0)
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

        // 日期过滤按钮
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => _showDateFilterPicker(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: state.searchDateFilter != null
                    ? Theme.of(context).primaryColor.withAlpha(26)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: state.searchDateFilter != null
                      ? Theme.of(context).primaryColor
                      : Colors.grey.shade300,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: state.searchDateFilter != null
                        ? Theme.of(context).primaryColor
                        : Colors.grey.shade600,
                  ),
                  if (state.searchDateFilter != null) ...[
                    const SizedBox(width: 4),
                    Text(
                      '${state.searchDateFilter!.month}/${state.searchDateFilter!.day}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () =>
                          context.read<ChatCubit>().setSearchDateFilter(null),
                      child: Icon(
                        Icons.close,
                        size: 14,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
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
      // ignore: use_build_context_synchronously
      context.read<ChatCubit>().setSearchDateFilter(selectedDate);
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
                      '只能选择有消息的日期（蓝色标记）',
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
    // 检查上个月和下个月是否有消息
    final prevMonth = DateTime(_displayMonth.year, _displayMonth.month - 1);
    final nextMonth = DateTime(_displayMonth.year, _displayMonth.month + 1);

    final hasPrevMonthMessages = _hasMessagesInMonth(prevMonth);
    final hasNextMonthMessages = _hasMessagesInMonth(nextMonth);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: hasPrevMonthMessages
              ? () {
                  setState(() {
                    _displayMonth = prevMonth;
                  });
                }
              : null,
          icon: Icon(
            Icons.chevron_left,
            color: hasPrevMonthMessages ? null : Colors.grey.shade400,
          ),
        ),
        Text(
          '${_displayMonth.year}年${_displayMonth.month}月',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        IconButton(
          onPressed: hasNextMonthMessages
              ? () {
                  setState(() {
                    _displayMonth = nextMonth;
                  });
                }
              : null,
          icon: Icon(
            Icons.chevron_right,
            color: hasNextMonthMessages ? null : Colors.grey.shade400,
          ),
        ),
      ],
    );
  }

  /// 检查指定月份是否有消息
  bool _hasMessagesInMonth(DateTime month) {
    return widget.availableDates
        .any((date) => date.year == month.year && date.month == month.month);
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
                onTap: hasMessages
                    ? () {
                        setState(() {
                          _currentDate = date;
                        });
                      }
                    : null,
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : (hasMessages
                            ? Colors.blue.shade50
                            : Colors.transparent),
                    borderRadius: BorderRadius.circular(8),
                    border: isToday && hasMessages
                        ? Border.all(
                            color: Theme.of(context).primaryColor, width: 2)
                        : (hasMessages
                            ? Border.all(color: Colors.blue.shade200)
                            : null),
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
                                : Colors.grey.shade400),
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
