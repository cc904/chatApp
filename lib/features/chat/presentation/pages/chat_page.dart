import 'dart:async';

import 'package:cc/core/database/models/conversation.dart';
import 'package:cc/core/database/models/user.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:cc/core/database/models/message.dart';
import 'package:cc/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:cc/features/chat/presentation/cubit/chat_state.dart';
import 'package:cc/features/chat/presentation/widgets/message_item.dart';

/// 聊天页面
///
/// 使用scrollable_positioned_list来实现高性能的消息列表滚动
/// 支持滚动到指定消息位置，适合处理大量历史消息
class ChatPage extends StatefulWidget {
  final Conversation conversation;
  final User contact;

  const ChatPage({
    super.key,
    required this.conversation,
    required this.contact,
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

  @override
  void initState() {
    super.initState();

    // 监听滚动位置变化
    _itemPositionsListener.itemPositions.addListener(_onScrollPositionChanged);

    _init();
  }

  Future<void> _init() async {
    // await context.read<ChatCubit>().init();
    // _restoreToScrollPositionByState();
  }

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
      // 更新当前滚动位置到状态中

      _scrollDebounceTimer?.cancel();
      _scrollDebounceTimer = Timer(const Duration(milliseconds: 200), () {
        _updateCurrentScrollPosition();
      });

      // 检查是否需要加载更多历史消息
      final firstVisibleIndex = positions.first.index;
      if (firstVisibleIndex <= 5) {
        _logger.i('检查是否需要加载更多历史消息', extra: {
          'firstVisibleIndex': firstVisibleIndex,
        });
        _loadMoreHistoryWithPositionMaintenance();
      }
    }
  }

  /// 💢💢💢 更新ChatState中的当前滚动位置
  void _updateCurrentScrollPosition() {
    final positions = _itemPositionsListener.itemPositions.value;
    final state = context.read<ChatCubit>().state;

    if (positions.isEmpty || state.messages.isEmpty) {
      return;
    }

    context.read<ChatCubit>().updateCurrentScrollPosition(positions);
  }

  /// TODO 加载更多历史消息并保持位置
  void _loadMoreHistoryWithPositionMaintenance() async {
    final state = context.read<ChatCubit>().state;
    if (!state.canLoadMoreHistory || state.isLoadingMoreMessages) {
      return;
    }

    // 记录当前精确的滚动位置
    final positionInfo = state.currentScrollPosition;

    _logger.i('开始加载更多历史消息（精确位置模式）', extra: {
      'anchorMessageId': positionInfo.messageId,
      'anchorIndex': positionInfo.messageIndex,
      'relativePosition': positionInfo.relativePosition,
    });

    // 使用带回调的加载方法
    // ignore: use_build_context_synchronously
    final success =
        await context.read<ChatCubit>().loadMoreMessagesWithCallback(
              anchorMessageId: positionInfo.messageId,
              onLoadComplete: () {
                // 加载完成后恢复到精确位置
                _restoreToScrollPosition(positionInfo);
              },
            );

    if (!success) {
      _logger.w('加载更多历史消息失败');
    }
  }

  /// 恢复到保存的滚动位置
  Future<void> _restoreToScrollPositionByState() async {
    final currentScrollPosition =
        context.read<ChatCubit>().state.currentScrollPosition;
    _restoreToScrollPosition(currentScrollPosition);
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

      // 发送后自动滚动到底部
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollToBottom();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: _buildMessagesList(),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  /// 构建应用栏
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.conversation.name ?? '未知联系人',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          BlocBuilder<ChatCubit, ChatState>(
            builder: (context, state) {
              if (state.typingUsers.isNotEmpty) {
                return Text(
                  '正在输入...',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                );
              }
              return Text(
                _getLastSeenText(state),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              );
            },
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.call),
          onPressed: () {
            // TODO 实现语音通话
          },
        ),
        IconButton(
          icon: const Icon(Icons.videocam),
          onPressed: () {
            // TODO 实现视频通话
          },
        ),
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () {
            // TODO 显示更多选项
          },
        ),
      ],
    );
  }

  /// 构建消息列表 💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢
  Widget _buildMessagesList() {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        if (state.isLoadingMessages && state.messages.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state.messages.isEmpty) {
          return const Center(
            child: Text(
              '还没有消息\n发送第一条消息开始聊天吧！',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          );
        }

        return Column(
          children: [
            // 加载更多历史消息指示器
            if (state.isLoadingMoreMessages)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),

            // 消息列表 💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢
            Expanded(
              child: ScrollablePositionedList.builder(
                itemCount: state.messages.length,
                itemBuilder: (context, index) {
                  final message = state.messages[index];
                  return MessageItem(
                    key: ValueKey(message.messageId),
                    message: message,
                    isCurrentUser: _isCurrentUserMessage(message, state),
                    onTap: () => _onMessageTap(message),
                  );
                },
                itemScrollController: _itemScrollController,
                itemPositionsListener: _itemPositionsListener,
                initialScrollIndex:
                    state.currentScrollPosition.messageIndex ?? 0,
                initialAlignment:
                    state.currentScrollPosition.relativePosition ?? 0.0,
                reverse: false, // 不反转，正常顺序显示
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
              ),
            ),
          ],
        );
      },
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
}
