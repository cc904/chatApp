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

  /// 滚动控制器 - 用于控制列表滚动位置
  final ItemScrollController _itemScrollController = ItemScrollController();

  /// 位置监听器 - 用于监听当前可见项的位置
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();

  /// 文本输入控制器
  final TextEditingController _textController = TextEditingController();

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
    _focusNode.dispose();
    _scrollDebounceTimer?.cancel();
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
            state.hasMoreHistory) {
          _logger.i('检查是否需要加载更多历史消息', extra: {
            'lastVisibleIndex': lastVisibleIndex,
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
        duration: const Duration(milliseconds: 500),
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

  /// 💢💢💢💢💢💢💢💢💢💢💢💢💢💢   构建消息列表   💢💢💢💢💢💢💢💢💢💢💢💢💢💢
  Widget _buildMessagesList() {
    return BlocBuilder<ChatCubit, ChatState>(
      buildWhen: (previous, current) {
        return previous.messages.length != current.messages.length ||
            previous.isSearchMode != current.isSearchMode ||
            previous.isSearching != current.isSearching ||
            previous.searchQuery != current.searchQuery;
      },
      builder: (context, state) {
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

          if (state.searchQuery.trim().isNotEmpty && displayMessages.isEmpty) {
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
                    return MessageItem(
                      key: ValueKey(message.messageId),
                      message: message,
                      isCurrentUser: item.isCurrentUser,
                      showAvatar: item.showAvatar,
                      showTail: item.showTail,
                      isPrivateChat: item.isPrivateChat,
                      onTap: () => _onMessageTap(message),
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
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () {
          context.read<ChatCubit>().exitSearchMode();
        },
      ),
      title: TextField(
        autofocus: true,
        decoration: const InputDecoration(
          hintText: '搜索消息...',
          border: InputBorder.none,
          hintStyle: TextStyle(color: Colors.grey),
        ),
        style: const TextStyle(color: Colors.black, fontSize: 16),
        onChanged: (query) {
          context.read<ChatCubit>().performSearch(query);
        },
      ),
      actions: [
        TextButton(
          onPressed: () {
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
        return Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border(
              top: BorderSide(
                color: Colors.grey.withAlpha(51),
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // 日期过滤按钮
              IconButton(
                icon: Icon(
                  Icons.calendar_today,
                  color: state.searchDateFilter != null
                      ? Theme.of(context).primaryColor
                      : Colors.grey,
                ),
                onPressed: () {
                  _showDateFilterPicker(context);
                },
              ),
              // 显示当前过滤的日期
              if (state.searchDateFilter != null) ...[
                const SizedBox(width: 8),
                Chip(
                  label: Text(
                    '${state.searchDateFilter!.month}/${state.searchDateFilter!.day}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  onDeleted: () {
                    context.read<ChatCubit>().setSearchDateFilter(null);
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  /// 显示日期选择器
  Future<void> _showDateFilterPicker(BuildContext context) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (selectedDate != null && mounted) {
      // ignore: use_build_context_synchronously
      context.read<ChatCubit>().setSearchDateFilter(selectedDate);
    }
  }
}
