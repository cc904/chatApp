import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cc/core/database/models/message.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/features/chat/domain/repositories/chat_repository.dart';
import 'package:cc/features/chat/domain/repositories/chats_repository.dart';
import 'package:cc/features/chat/presentation/cubit/chat_state.dart';
import 'package:cc/features/chat/domain/entities/chat_state_snapshot.dart';
import 'package:cc/features/contacts/domain/repositories/contacts_repository.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

/// 滚动恢复类型
enum ScrollRestoreType {
  /// 滚动到底部
  bottom,

  /// 滚动到指定消息
  toMessage,

  /// 🔥 直接恢复到精确位置
  exactPosition,
}

/// 滚动恢复信息
class ScrollRestoreInfo {
  /// 滚动类型
  final ScrollRestoreType type;

  /// 目标消息ID
  final String? messageId;

  /// 目标消息在列表中的索引
  final int? messageIndex;

  /// 🔥 精确的滚动位置（像素）
  final double? exactScrollPosition;

  /// 新消息数量（用于显示未读提示）
  final int newMessagesCount;

  const ScrollRestoreInfo({
    required this.type,
    this.messageId,
    this.messageIndex,
    this.exactScrollPosition,
    this.newMessagesCount = 0,
  });
}

/// 单个聊天会话的业务逻辑Cubit
/// 简化版本，使用ChatRepository中的状态快照功能
class ChatCubit extends Cubit<ChatState> {
  final ChatRepository _chatRepository;
  final ChatsRepository _chatsRepository;
  final LogService _logger = LogService.instance;
  final String _conversationId;
  final ChatStateSnapshot? _initialSnapshot;

  // 保存订阅，以便在dispose时取消
  final Map<String, StreamSubscription> _subscriptions = {};

  // 添加恢复状态标记，避免恢复期间的干扰
  bool _isRestoring = false;
  bool get isRestoring => _isRestoring;

  // 简化的配置参数
  static const int defaultPageSize = 30; // 每页消息数量

  ChatCubit({
    required ChatRepository chatRepository,
    required ChatsRepository chatsRepository,
    required String conversationId,
    ChatStateSnapshot? initialSnapshot,
    ContactsRepository? contactsRepository,
  })  : _chatRepository = chatRepository,
        _chatsRepository = chatsRepository,
        _conversationId = conversationId,
        _initialSnapshot = initialSnapshot,
        super(_createInitialState(conversationId, initialSnapshot)) {
    _init();
  }

  /// 创建初始状态
  /// 如果有快照，直接使用快照数据初始化；否则使用默认初始状态
  static ChatState _createInitialState(
      String conversationId, ChatStateSnapshot? snapshot) {
    if (snapshot != null && snapshot.isValid) {
      // 使用快照数据创建初始状态
      return ChatState.initial().copyWith(
        messages: snapshot.messages,
        lastReadMessageId: snapshot.lastReadMessageId,
        unreadCount: snapshot.unreadCount,
        currentScrollPosition: snapshot.currentScrollPosition,
        isLoadingMessages: false,
        hasMoreHistory: snapshot.hasMoreHistory,
        hasMoreRecent: snapshot.hasMoreRecent,
      );
    } else {
      // 使用默认初始状态
      return ChatState.initial();
    }
  }

  /// 初始化 💢💢💢💢💢💢💢💢💢💢💢💢💢💢
  Future<void> _init() async {
    try {
      _logger.i('ChatCubit初始化开始', extra: {'conversationId': _conversationId});

      // 如果构造函数中已传入快照，直接使用，无需再次获取
      if (_initialSnapshot != null && _initialSnapshot!.isValid) {
        _logger.i('使用构造函数传入的快照初始化', extra: {
          'conversationId': _conversationId,
          'messageCount': _initialSnapshot!.messages.length,
          'currentScrollPosition': _initialSnapshot!.currentScrollPosition,
        });

        // 设置恢复状态标记
        _isRestoring = true;

        // 先加入会话房间
        await joinConversation();

        // 然后设置事件监听
        _setupSubscriptions();

        // 清除恢复状态标记
        _isRestoring = false;

        _logger.i('ChatCubit从传入快照初始化完成');
        return;
      }

      // 如果没有传入快照，尝试从ChatsRepository获取快照
      final snapshot = await _chatsRepository.getStateSnapshot(_conversationId);
      if (snapshot != null) {
        _logger.i('从ChatsRepository获取快照恢复会话', extra: {
          'conversationId': _conversationId,
          'messageCount': snapshot.messages.length,
          'currentScrollPosition': snapshot.currentScrollPosition,
        });

        // 设置恢复状态标记
        _isRestoring = true;

        // 从快照恢复状态
        emit(state.copyWith(
          messages: snapshot.messages,
          lastReadMessageId: snapshot.lastReadMessageId,
          unreadCount: snapshot.unreadCount,
          currentScrollPosition: snapshot.currentScrollPosition,
          isLoadingMessages: false,
          hasMoreHistory: snapshot.hasMoreHistory,
          hasMoreRecent: snapshot.hasMoreRecent,
        ));

        // 先加入会话房间
        await joinConversation();

        // 然后设置事件监听
        _setupSubscriptions();

        // 清除恢复状态标记
        _isRestoring = false;

        _logger.i('ChatCubit从ChatsRepository快照恢复完成');
        return;
      } else {
        _logger.i('没有状态快照，执行正常初始化流程');
      }

      // 没有快照，执行正常初始化流程
      _setupSubscriptions();

      final conversation =
          await _chatsRepository.getConversationById(_conversationId);
      emit(state.copyWith(
          lastReadMessageId: conversation?.lastReadMessageId,
          unreadCount: conversation?.unreadCount ?? 0));

      // 加载消息
      await _loadInitialMessages();

      // 加入会话房间
      await joinConversation();

      _logger.i('ChatCubit初始化完成');
    } catch (error) {
      // 确保出错时也清除恢复状态
      _isRestoring = false;
      _logger.e('初始化ChatCubit失败', error: error);
      emit(state.copyWith(errorMessage: '初始化失败: ${error.toString()}'));
    }
  }

  /// 加载初始消息
  Future<void> _loadInitialMessages() async {
    try {
      // 检查Cubit是否已关闭
      if (isClosed) {
        _logger.w('Cubit已关闭，取消加载初始消息');
        return;
      }

      emit(state.copyWith(isLoadingMessages: true));

      // 从数据库加载消息
      await loadMoreMessages();
    } catch (error) {
      _logger.e('加载初始消息失败', error: error);

      // 检查Cubit是否已关闭
      if (!isClosed) {
        emit(state.copyWith(
          isLoadingMessages: false,
          errorMessage: '加载消息失败: ${error.toString()}',
        ));
      }
    }
  }

  /// 💢💢💢💢💢💢💢💢💢💢💢💢💢💢   设置事件订阅   💢💢💢💢💢💢💢💢💢💢💢💢💢💢
  void _setupSubscriptions() {
    try {
      _logger.i('设置事件监听', extra: {'conversationId': _conversationId});
      _subscriptions['messageStatus'] = _chatRepository
          .getMessageStatusStream()
          .where((event) => event['type'] == 'loadMore')
          .listen(
        _handleLoadMoreMessageStatusUpdate,
        onError: (error) {
          _logger.e('消息状态流监听出错', error: error);
        },
      );

      _logger.d('事件监听设置完成');
    } catch (error) {
      _logger.e('设置事件监听失败', error: error);
    }
  }

  /// 💢💢💢 处理加载更多消息状态更新事件
  void _handleLoadMoreMessageStatusUpdate(Map<String, dynamic> event) {
    _logger.d('处理加载更多消息状态更新',
        extra: {
          'messageCount': event['messages'].length,
          'hasMoreHistory': event['hasMoreHistory'],
        },
        stackTrace: StackTrace.current);

    final conversationId = event['conversationId'] as String?;
    final messages = event['messages'] as List<Message>?;

    if (conversationId != _conversationId || messages == null) {
      return;
    }

    if (messages.isEmpty) {
      if (!isClosed) {
        emit(state.copyWith(
            isLoadingMoreMessages: false, hasMoreHistory: false));
      }
      return;
    }

    // 按时间顺序
    final sortedMessages = List<Message>.from(messages)
      ..sort((a, b) => b.createdAt.compareTo(b.createdAt));
    final newMessages = [...state.messages, ...sortedMessages];

    if (!isClosed) {
      emit(state.copyWith(
        messages: newMessages,
        isLoadingMoreMessages: false,
        hasMoreHistory: event['hasMoreHistory'] ?? true,
      ));
    }
  }

  /// 💢💢💢💢💢💢💢💢💢💢💢💢💢💢                💢💢💢💢💢💢💢💢💢💢💢💢💢💢

  /// 加载会话消息
  Future<void> loadMessages() async {
    try {
      _logger.d('开始加载消息',
          extra: {'conversationId': _conversationId},
          stackTrace: StackTrace.current);

      // 检查Cubit是否已关闭
      if (isClosed) {
        _logger.w('Cubit已关闭，取消加载消息');
        return;
      }

      emit(state.copyWith(isLoadingMessages: true));
      await loadMoreMessages();
    } catch (error) {
      _logger.e('加载消息失败', error: error);

      // 检查Cubit是否已关闭
      if (!isClosed) {
        emit(state.copyWith(
          isLoadingMessages: false,
          errorMessage: '加载消息失败: ${error.toString()}',
        ));
      }
    }
  }

  /// 💢💢💢 加载更多消息
  /// 用于滚动到顶部时加载更早的消息，同时保持用户当前查看位置
  Future<void> loadMoreMessages() async {
    _logger.i('加载更多消息', extra: {
      'conversationId': _conversationId,
      'hasMoreHistory': state.hasMoreHistory,
    });
    try {
      // 检查Cubit是否已关闭
      if (isClosed) {
        _logger.w('Cubit已关闭，取消加载更多消息');
        return;
      }

      if (state.isLoadingMoreMessages || !state.hasMoreHistory) {
        _logger.d('跳过加载更多消息', extra: {
          'isLoading': state.isLoadingMoreMessages,
          'hasMoreHistory': state.hasMoreHistory,
        });
        return;
      }

      emit(state.copyWith(isLoadingMoreMessages: true));

      // 获取最早的消息时间作为before参数
      DateTime? before;
      if (state.messages.isNotEmpty) {
        before = state.messages.last.createdAt;
      }

      await _chatRepository.getConversationMessages(
        _conversationId,
        limit: defaultPageSize,
        before: before,
      );

      emit(state.copyWith(isLoadingMoreMessages: false));
    } catch (error) {
      _logger.e('加载更多消息失败', error: error);

      // 检查Cubit是否已关闭
      if (!isClosed) {
        emit(state.copyWith(
          isLoadingMoreMessages: false,
          errorMessage: '加载更多消息失败: ${error.toString()}',
        ));
      }
    }
  }

  /// 发送文本消息
  Future<void> sendTextMessage(String text) async {
    _logger.d('发送文本消息',
        extra: {
          'conversationId': _conversationId,
          'textLength': text.length,
        },
        stackTrace: StackTrace.current);

    Message? tempMessage;

    try {
      // 检查Cubit是否已关闭
      if (!isClosed) {
        emit(state.copyWith(isSending: true));
      }

      // 1. 创建带临时ID的消息
      tempMessage = await _chatRepository.createTempMessage(
        _conversationId,
        text,
        'text',
      );

      // 2. 立即添加到UI显示（状态为sending）
      final updatedMessages = [
        ...[tempMessage],
        ...state.messages
      ];

      // 再次检查Cubit是否已关闭
      if (!isClosed) {
        emit(state.copyWith(
          messages: updatedMessages,
          isSending: false,
        ));
      }

      // 3. 发送消息（不等待响应）
      await _chatRepository.sendMessageWithTimeout(
        tempMessage,
        timeout: const Duration(seconds: 3),
      );

      _logger.i('文本消息发送请求已发出', extra: {
        'tempMessageId': tempMessage.messageId,
      });
    } catch (error) {
      _logger.e('发送文本消息失败', error: error);
    }
  }

  /// 标记消息为失败状态
  Future<void> _markMessageAsFailed(
      String? messageId, String errorReason) async {
    if (messageId == null || isClosed) return;

    try {
      await _chatRepository.markMessageAsFailed(messageId, errorReason);

      // 重新加载消息以更新UI
      if (!isClosed) {
        await loadMoreMessages();
      }

      _logger.w('消息标记为失败', extra: {
        'messageId': messageId,
        'reason': errorReason,
      });
    } catch (error) {
      _logger.e('标记消息失败状态时出错', error: error);
    }
  }

  /// 用户进入会话
  Future<void> joinConversation() async {
    try {
      _logger.i('用户进入会话', extra: {'conversationId': _conversationId});
      await _chatRepository.joinConversationRoom(_conversationId);
    } catch (error) {
      _logger.e('进入会话失败', error: error);
      emit(state.copyWith(errorMessage: '进入会话失败: ${error.toString()}'));
    }
  }

  /// 离开会话 💢💢💢💢💢💢💢💢💢💢💢💢💢💢
  Future<void> leaveConversation() async {
    try {
      _logger.i('用户离开会话', extra: {'conversationId': _conversationId});

      // 离开会话时保存状态快照
      if (state.messages.isNotEmpty) {
        await _chatsRepository.saveStateSnapshot(
          conversationId: _conversationId,
          messages: state.messages,
          lastReadMessageId: state.lastReadMessageId,
          currentScrollPosition: state.currentScrollPosition,
          unreadCount: state.unreadCount,
          hasMoreHistory: state.hasMoreHistory,
          hasMoreRecent: state.hasMoreRecent,
        );

        _logger.d('离开会话时保存状态快照', extra: {
          'conversationId': _conversationId,
          'messageCount': state.messages.length,
        });
      }

      // 通知服务器用户离开会话房间
      await _chatRepository.leaveConversationRoom(_conversationId);
    } catch (error) {
      _logger.e('离开会话失败', error: error);
    }
  }

  /// 更新当前滚动位置 💢💢💢💢💢💢💢💢💢💢💢💢💢💢
  /// 用于保存用户当前的查看位置
  void updateCurrentScrollPosition(Iterable<ItemPosition> positions) {
    if (!isClosed) {
      if (positions.isEmpty || state.messages.isEmpty) {
        return;
      }

      // 获取所有可见位置并按索引排序
      final sortedPositions = positions.toList()
        ..sort((a, b) => b.index.compareTo(a.index));

      // 选择屏幕中央的消息作为锚点
      final centerPosition = sortedPositions.firstWhere(
        (pos) => pos.itemLeadingEdge <= 0.5 && pos.itemTrailingEdge >= 0.5,
        orElse: () => positions.first,
      );

      if (centerPosition.index < state.messages.length) {
        final message = state.messages[centerPosition.index];
        final currentScrollPosition = CurrentScrollPosition.fromAnchor(
          messageId: message.messageId,
          messageIndex: centerPosition.index,
          relativePosition: centerPosition.itemLeadingEdge,
        );
        _logger.i('更新当前滚动位置',
            extra: {
              'messageId': message.messageId,
              'messageIndex': centerPosition.index,
              'relativePosition': centerPosition.itemLeadingEdge,
            },
            stackTrace: StackTrace.current);
        if (!isClosed) {
          emit(state.copyWith(currentScrollPosition: currentScrollPosition));
        }
      }

      // 最后一条可见消息（索引最大）
      final lastPosition = sortedPositions.last;
      final lastMessage = lastPosition.index < state.messages.length
          ? state.messages[lastPosition.index]
          : null;

      if (lastMessage != null &&
          state.lastReadMessageId != lastMessage.messageId &&
          lastMessage.status != 'read') {
        _chatRepository.markMessagesAsReadBySelf(
          _conversationId,
          lastMessage.messageId,
        );

        // 标记消息为已读
        final newMessages = state.messages.map((message) {
          if ((message.createdAt.isBefore(lastMessage.createdAt) &&
                  message.status != 'read') ||
              message.messageId == lastMessage.messageId) {
            message.status = 'read';
            return message;
          }
          return message;
        }).toList();

        _logger.d('标记 lastMessageId', extra: {
          'lastMessageId': lastMessage.messageId,
        });

        emit(state.copyWith(
            messages: newMessages, lastReadMessageId: lastMessage.messageId));
      }
    }
  }

  /// 清除当前滚动位置
  void clearCurrentScrollPosition() {
    if (!isClosed) {
      emit(state.copyWith(
        currentScrollPosition: const CurrentScrollPosition.empty(),
      ));
      _logger.d('清除当前滚动位置');
    }
  }

  /// 从状态中获取有效的滚动位置
  CurrentScrollPosition? getValidScrollPosition() {
    final position = state.currentScrollPosition;
    return position.isValid ? position : null;
  }

  @override
  Future<void> close() async {
    _logger.i('关闭ChatCubit', extra: {'conversationId': _conversationId});

    // 取消所有订阅
    for (final subscription in _subscriptions.values) {
      await subscription.cancel();
    }
    _subscriptions.clear();

    // 离开会话
    await leaveConversation();

    return super.close();
  }
}
