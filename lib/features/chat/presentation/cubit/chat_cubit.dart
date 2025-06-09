import 'dart:async';

import 'package:cc/core/database/models/conversation.dart';
import 'package:cc/core/database/models/current_user.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cc/core/database/models/message.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/features/chat/domain/repositories/chat_repository.dart';
import 'package:cc/features/chat/domain/repositories/chats_repository.dart';
import 'package:cc/features/chat/presentation/cubit/chat_state.dart';
import 'package:cc/features/chat/domain/entities/chat_state_snapshot.dart';
import 'package:cc/features/contacts/domain/repositories/contacts_repository.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:cc/features/chat/presentation/utils/message_list_processor.dart';
import 'package:cc/features/chat/domain/entities/conversation_event.dart';

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
  final String _conversationId;

  final LogService _logger = LogService.instance;
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
    required Conversation initialConversation,
    required CurrentUser currentUser,
    ChatStateSnapshot? initialSnapshot,
    ContactsRepository? contactsRepository,
  })  : _chatRepository = chatRepository,
        _chatsRepository = chatsRepository,
        _initialSnapshot = initialSnapshot,
        _conversationId = initialConversation.conversationId,
        super(_createInitialState(
            currentUser, initialSnapshot, initialConversation)) {
    _init();
  }

  /// 创建初始状态
  /// 如果有快照，直接使用快照数据初始化；否则使用默认初始状态
  static ChatState _createInitialState(CurrentUser currentUser,
      ChatStateSnapshot? snapshot, Conversation? conversation) {
    if (snapshot != null && snapshot.isValid) {
      // 使用快照数据创建初始状态
      return ChatState.initial(currentUser).copyWith(
        messages: snapshot.messages,
        unreadCount: snapshot.unreadCount,
        currentScrollPosition: snapshot.currentScrollPosition,
        isLoadingMessages: false,
        hasMoreHistory: snapshot.hasMoreHistory,
        hasMoreRecent: snapshot.hasMoreRecent,
        conversation: conversation,
      );
    } else {
      // 使用传入的 conversation 对象创建初始状态
      return ChatState.initial(currentUser)
          .copyWith(conversation: conversation);
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
        _setupEventListeners();

        // 清除恢复状态标记
        _isRestoring = false;

        _logger.i('ChatCubit从传入快照初始化完成');
        return;
      } else {
        _logger.i('没有状态快照，执行正常初始化流程');
      }

      // 没有快照，执行正常初始化流程
      _setupEventListeners();

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

  /// 设置事件监听
  void _setupEventListeners() {
    try {
      _logger.i('设置事件监听', extra: {'conversationId': _conversationId});

      // 监听消息状态更新（包括加载更多和消息状态变化）
      _subscriptions['messageStatus'] =
          _chatRepository.getMessageStatusStream().listen(
        _handleMessageStatusUpdate,
        onError: (error) {
          _logger.e('消息状态流监听出错', error: error);
        },
      );

      // 💢💢💢 新增：监听单个会话的变化
      _subscriptions['conversationWatch'] =
          _chatsRepository.watchConversation(_conversationId).listen(
        _handleConversationDataUpdate,
        onError: (error) {
          _logger.e('会话数据流监听出错', error: error);
        },
      );

      // 监听会话更新事件（从 ChatsRepository）
      _subscriptions['conversationUpdate'] = _chatsRepository
          .conversationUpdateStream
          .where((event) => event.conversationId == _conversationId)
          .listen(
        _handleConversationUpdate,
        onError: (error) {
          _logger.e('会话更新流监听出错', error: error);
        },
      );

      _logger.d('事件监听设置完成');
    } catch (error) {
      _logger.e('设置事件监听失败', error: error);
    }
  }

  /// 💢💢💢 统一处理消息状态更新事件
  void _handleMessageStatusUpdate(Map<String, dynamic> event) {
    final eventType = event['type'] as String?;

    switch (eventType) {
      case 'loadMore':
        _handleLoadMoreMessageStatusUpdate(event);
        break;
      case 'messageStatusUpdate':
        _handleSingleMessageStatusUpdate(event);
        break;
      default:
        _logger.w('未知的消息状态更新事件类型', extra: {'type': eventType});
    }
  }

  /// 💢💢💢 处理单个消息状态更新事件
  void _handleSingleMessageStatusUpdate(Map<String, dynamic> event) {
    if (isClosed) return;

    final messageId = event['messageId'] as String?;
    final newMessageId = event['newMessageId'] as String?;
    final conversationId = event['conversationId'] as String?;
    final status = event['status'] as String?;
    final errorMessage = event['errorMessage'] as String?;

    if (conversationId != _conversationId ||
        messageId == null ||
        status == null) {
      return;
    }

    _logger.d('处理单个消息状态更新', extra: {
      'messageId': messageId,
      'newMessageId': newMessageId,
      'status': status,
      'errorMessage': errorMessage,
    });

    // 💢💢💢 优化：直接修改原有Message对象，通过触发器触发UI刷新
    bool messageFound = false;
    for (final message in state.messages) {
      if (message.messageId == messageId) {
        // 直接更新消息状态
        message.status = status;
        message.errorMessage = errorMessage;

        // 如果有新的服务器messageId，更新它
        if (newMessageId != null && newMessageId.isNotEmpty) {
          message.messageId = newMessageId;
        }

        messageFound = true;
        _logger.d('已更新消息状态', extra: {
          'oldMessageId': messageId,
          'newMessageId': message.messageId,
          'status': status,
        });
        break;
      }
    }

    if (messageFound) {
      // 💢💢💢 通过触发器触发UI刷新，而不需要创建新对象
      _updateMessagesInStateWithTrigger(state.messages);
    } else {
      _logger.w('未找到要更新的消息', extra: {'messageId': messageId});
    }
  }

  /// 💢💢💢 新增：带触发器的消息状态更新方法
  void _updateMessagesInStateWithTrigger(List<Message> newMessages,
      {bool hasMoreHistory = true, bool hasMoreRecent = false}) {
    if (isClosed) return;

    _logger.d('更新状态中的消息列表（带触发器）', extra: {
      'newMessageCount': newMessages.length,
      'hasMoreHistory': hasMoreHistory,
      'hasMoreRecent': hasMoreRecent,
      'currentTrigger': state.messageUpdateTrigger,
      'newTrigger': state.messageUpdateTrigger + 1,
    });

    // 获取当前用户ID
    final currentUserId = state.currentUser?.userId ?? '';

    // 使用MessageListProcessor计算未读消息相关数据
    final unreadCount = MessageListProcessor.calculateUnreadCount(
      messages: newMessages,
      currentUserId: currentUserId,
      lastReadMessageId: state.lastReadMessageId,
    );

    // 💢💢💢 创建新状态时增加触发器值
    final newState = state.copyWith(
      messages: newMessages,
      isLoadingMessages: false,
      isLoadingMoreMessages: false,
      hasMoreHistory: hasMoreHistory,
      hasMoreRecent: hasMoreRecent,
      unreadCount: unreadCount,
      messageUpdateTrigger: state.messageUpdateTrigger + 1, // 💢 关键：增加触发器值
    );

    _logger.d('准备发射新状态（带触发器）', extra: {
      'oldStateHash': state.hashCode,
      'newStateHash': newState.hashCode,
      'oldTrigger': state.messageUpdateTrigger,
      'newTrigger': newState.messageUpdateTrigger,
    });

    emit(newState);

    _logger.d('消息状态更新完成（带触发器）', extra: {
      'totalMessages': newMessages.length,
      'unreadCount': unreadCount,
      'triggerValue': newState.messageUpdateTrigger,
    });
  }

  /// 更新状态中的消息列表（原有方法，保持不变）
  void _updateMessagesInState(List<Message> newMessages,
      {bool hasMoreHistory = true, bool hasMoreRecent = false}) {
    if (isClosed) return;

    _logger.d('更新状态中的消息列表', extra: {
      'newMessageCount': newMessages.length,
      'hasMoreHistory': hasMoreHistory,
      'hasMoreRecent': hasMoreRecent,
    });

    // 获取当前用户ID
    final currentUserId = state.currentUser?.userId ?? '';

    // 使用MessageListProcessor计算未读消息相关数据
    final unreadCount = MessageListProcessor.calculateUnreadCount(
      messages: newMessages,
      currentUserId: currentUserId,
      lastReadMessageId: state.lastReadMessageId,
    );

    emit(state.copyWith(
      messages: newMessages,
      isLoadingMessages: false,
      isLoadingMoreMessages: false,
      hasMoreHistory: hasMoreHistory,
      hasMoreRecent: hasMoreRecent,
      unreadCount: unreadCount,
    ));

    _logger.d('消息状态更新完成', extra: {
      'totalMessages': newMessages.length,
      'unreadCount': unreadCount,
      'hasMoreHistory': hasMoreHistory,
      'hasMoreRecent': hasMoreRecent,
    });
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
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final newMessages = [...state.messages, ...sortedMessages];

    if (!isClosed) {
      _updateMessagesInState(
        newMessages,
        hasMoreHistory: event['hasMoreHistory'] ?? true,
      );
    }
  }

  /// 💢💢💢 新增：处理会话数据更新（来自数据库监听）
  void _handleConversationDataUpdate(Conversation? conversation) {
    if (isClosed) return;

    if (conversation != null) {
      _logger.d('收到会话数据更新', extra: {
        'conversationId': conversation.conversationId,
        'name': conversation.name,
        'isMuted': conversation.isMuted,
        'isPinned': conversation.isPinned,
        'unreadCount': conversation.unreadCount,
      });

      // 更新 ChatState 中的会话信息
      emit(state.copyWith(conversation: conversation));
    } else {
      _logger.w('会话数据为空，可能已被删除', extra: {
        'conversationId': _conversationId,
      });
    }
  }

  /// 💢💢💢 处理会话更新事件
  /// 监听 ChatsCubit 中的会话状态变化，保持 ChatPage 中会话信息的同步
  void _handleConversationUpdate(ConversationUpdateEvent event) {
    _logger.d('处理会话更新事件', extra: {
      'conversationId': event.conversationId,
      'updateType': event.type.toString(),
    });

    if (isClosed) return;

    // 根据更新类型处理不同的事件
    switch (event.type) {
      case ConversationUpdateType.updated:
        // 会话信息更新（如静音状态、置顶状态等）
        _logger.i('会话信息已更新', extra: {
          'conversationId': event.conversationId,
          'isMuted': event.isMuted,
          'isPinned': event.isPinned,
        });
        // 这里可以更新 ChatPage 中显示的会话状态
        // 例如 AppBar 中的会话名称、头像等
        break;
      case ConversationUpdateType.readStatusUpdated:
        // 阅读状态更新
        emit(state.copyWith(
          unreadCount: event.unreadCount ?? state.unreadCount,
        ));
        break;
      case ConversationUpdateType.added:
      case ConversationUpdateType.removed:
        // 这些事件通常不会影响当前打开的聊天页面
        break;
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

    if (isClosed) return;

    // 验证输入
    if (text.trim().isEmpty) {
      _logger.w('尝试发送空消息');
      return;
    }

    Message? tempMessage;
    try {
      // 1. 设置发送状态
      _setLoadingState(true);

      // 2. 创建临时消息
      tempMessage = await _createTempMessage(text.trim());

      // 3. 立即更新UI显示（乐观更新）
      await _addMessageToUI(tempMessage);

      // 4. 异步发送消息到服务器
      _sendMessageToServerAsync(tempMessage);

      _logger.i('文本消息已添加到UI，正在后台发送', extra: {
        'tempMessageId': tempMessage.messageId,
      });
    } catch (error) {
      _logger.e('发送文本消息失败', error: error);

      // 处理发送失败
      await _handleSendFailure(tempMessage?.messageId, error.toString());

      // 重新抛出异常，让UI层处理
      rethrow;
    } finally {
      // 重置发送状态
      _setLoadingState(false);
    }
  }

  /// 设置加载状态
  void _setLoadingState(bool isLoading) {
    if (!isClosed) {
      emit(state.copyWith(isSending: isLoading));
    }
  }

  /// 创建临时消息
  Future<Message> _createTempMessage(String text) async {
    return await _chatRepository.createTempMessage(
      _conversationId,
      text,
      'text',
    );
  }

  /// 添加消息到UI（乐观更新）
  Future<void> _addMessageToUI(Message message) async {
    if (isClosed) return;

    final updatedMessages = [message, ...state.messages];
    _updateMessagesInState(updatedMessages);

    _logger.d('消息已添加到UI', extra: {
      'messageId': message.messageId,
      'totalMessages': updatedMessages.length,
    });
  }

  /// 异步发送消息到服务器（不阻塞UI）
  void _sendMessageToServerAsync(Message message) {
    // 使用异步方式发送，不阻塞UI
    _sendMessageToServer(message).catchError((error) {
      _logger.e('后台发送消息失败', error: error);
      // 异步处理发送失败
      _handleSendFailure(message.messageId, error.toString());
    });
  }

  /// 发送消息到服务器
  Future<void> _sendMessageToServer(Message message) async {
    await _chatRepository.sendMessageWithTimeout(
      message,
      timeout: const Duration(seconds: 5), // 增加超时时间到5秒
    );
  }

  /// 处理发送失败
  Future<void> _handleSendFailure(String? messageId, String errorReason) async {
    if (messageId == null || isClosed) return;

    try {
      // 标记消息为失败状态
      await _chatRepository.markMessageAsFailed(messageId, errorReason);

      // 重新加载消息以更新UI
      await loadMoreMessages();

      // 设置错误消息给用户
      emit(state.copyWith(errorMessage: '消息发送失败: $errorReason'));
    } catch (error) {
      _logger.e('处理发送失败时出错', error: error);
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

  /// 💢💢💢💢💢💢💢💢💢💢💢💢💢💢                💢💢💢💢💢💢💢💢💢💢💢💢💢💢

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
        final snapshot = ChatStateSnapshot(
          conversation: state.conversation,
          messages: state.messages,
          lastReadMessageId: state.lastReadMessageId,
          unreadCount: state.unreadCount,
          currentScrollPosition: state.currentScrollPosition,
          visibleMessageId: null, // 离开时不需要记录可见消息
          timestamp: DateTime.now(),
          hasMoreHistory: state.hasMoreHistory,
          hasMoreRecent: state.hasMoreRecent,
        );

        await _chatsRepository.saveStateSnapshot(snapshot);

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

      // 💢💢💢 过滤掉超出消息列表范围的位置
      final validPositions = positions
          .where((position) =>
              position.index >= 0 && position.index < state.messages.length)
          .toList();

      if (validPositions.isEmpty) {
        _logger.w('所有滚动位置都超出消息列表范围', extra: {
          'originalPositions': positions.map((e) => e.index).toList(),
          'messageCount': state.messages.length,
        });
        return;
      }

      // 获取所有有效位置并按索引排序
      final sortedPositions = validPositions.toList()
        ..sort((a, b) => b.index.compareTo(a.index));

      // 选择屏幕中央的消息作为锚点
      final centerPosition = sortedPositions.firstWhere(
        (pos) => pos.itemLeadingEdge <= 0.5 && pos.itemTrailingEdge >= 0.5,
        orElse: () => validPositions.first,
      );

      // 💢💢💢 双重检查索引有效性
      if (centerPosition.index >= 0 &&
          centerPosition.index < state.messages.length) {
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

      // 第一条可见消息（索引最小）
      final firstPosition = sortedPositions.first;
      final firstMessage = (firstPosition.index >= 0 &&
              firstPosition.index < state.messages.length)
          ? state.messages[firstPosition.index]
          : null;

      if (firstMessage != null &&
          state.lastReadMessageId != firstMessage.messageId &&
          firstMessage.status != 'read' &&
          !state.isSearchMode) {
        _chatRepository.markMessagesAsReadBySelf(
          _conversationId,
          firstMessage.messageId,
        );

        // 标记消息为已读
        final newMessages = state.messages.map((message) {
          if ((message.createdAt.isBefore(firstMessage.createdAt) &&
                  message.status != 'read') ||
              message.messageId == firstMessage.messageId) {
            message.status = 'read';
            return message;
          }
          return message;
        }).toList();

        _logger.d('标记 firstMessageId', extra: {
          'firstMessageId': firstMessage.messageId,
        });

        // 使用_updateMessagesInState来更新消息状态，同时更新未读消息相关状态
        _updateMessagesInState(
          newMessages,
          hasMoreHistory: state.hasMoreHistory,
          hasMoreRecent: state.hasMoreRecent,
        );

        // 单独更新lastReadMessageId
        emit(state.copyWith(lastReadMessageId: firstMessage.messageId));
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

  /// 💢💢💢💢💢💢��💢💢💢💢💢💢💢   搜索功能   💢💢💢💢💢💢💢💢💢💢💢💢💢💢

  /// 进入搜索模式
  void enterSearchMode() {
    if (!isClosed) {
      emit(state.copyWith(
        isSearchMode: true,
        searchQuery: '',
        searchResults: [],
        isSearching: false,
        searchDateFilter: null,
        searchResultMessageIds: [],
        currentSearchResultIndex: 0,
        isShowingSearchAsList: false,
        searchResultTotalCount: 0,
        originalMessages: state.messages, // 💢 备份当前消息列表
      ));
      _logger.i('进入搜索模式');
    }
  }

  /// 退出搜索模式
  void exitSearchMode() {
    if (!isClosed) {
      emit(state.copyWith(
        isSearchMode: false,
        searchQuery: '',
        searchResults: [],
        isSearching: false,
        searchDateFilter: null,
        searchResultMessageIds: [],
        currentSearchResultIndex: 0,
        isShowingSearchAsList: false,
        searchResultTotalCount: 0,
        messages: state.originalMessages ?? state.messages, // 💢 恢复原始消息列表
        originalMessages: null, // 清空备份
      ));
      _logger.i('退出搜索模式');
    }
  }

  /// 💢💢💢 重构：执行数据库搜索
  Future<void> performSearch(String query) async {
    if (isClosed) return;

    _logger.i('执行数据库搜索', extra: {'query': query});

    try {
      emit(state.copyWith(
        searchQuery: query,
        isSearching: true,
      ));

      if (query.trim().isEmpty) {
        emit(state.copyWith(
          searchResults: [],
          isSearching: false,
          searchResultMessageIds: [],
          currentSearchResultIndex: 0,
          searchResultTotalCount: 0,
        ));
        return;
      }

      // 🔥 使用新的数据库搜索方法（结果按从新到旧排序）
      final searchResult = await _chatRepository.searchMessagesInDatabase(
        query: query.trim(),
        conversationId: _conversationId,
        dateFilter: state.searchDateFilter,
      );

      if (searchResult.hasResults) {
        // 💢💢💢 新逻辑：加载最新搜索结果附近的消息（替换式加载）
        final firstResultId = searchResult.matchedMessageIds.first; // 最新的搜索结果
        final result = await _chatRepository.getMessagesAroundSearchResult(
          conversationId: _conversationId,
          targetMessageId: firstResultId,
          contextSize: 25, // 前后各25条消息
        );

        emit(state.copyWith(
          messages: result.messages, // 💢 替换整个消息列表
          searchResultMessageIds: searchResult.matchedMessageIds,
          currentSearchResultIndex: 0, // 从第一个（最新）搜索结果开始
          searchResultTotalCount: searchResult.totalCount,
          isSearching: false,
        ));

        _logger.i('数据库搜索完成（替换式加载）', extra: {
          'query': query,
          'resultCount': searchResult.totalCount,
          'loadedMessageCount': result.messages.length,
          'loadedRange':
              '${result.timeRange.start.toIso8601String()} - ${result.timeRange.end.toIso8601String()}',
        });
      } else {
        emit(state.copyWith(
          searchResultMessageIds: [],
          currentSearchResultIndex: 0,
          searchResultTotalCount: 0,
          isSearching: false,
        ));
      }
    } catch (error) {
      _logger.e('数据库搜索失败', error: error);
      if (!isClosed) {
        emit(state.copyWith(
          isSearching: false,
          errorMessage: '搜索失败: ${error.toString()}',
        ));
      }
    }
  }

  /// 💢💢💢 重构：跳转到下一个搜索结果（线性导航，无循环）
  Future<void> goToNextSearchResult() async {
    if (!isClosed && state.searchResultMessageIds.isNotEmpty) {
      // 💢💢💢 线性导航：检查是否已经是最后一个
      if (state.currentSearchResultIndex >= state.searchResultTotalCount - 1) {
        _logger.i('已经是最后一个搜索结果，无法继续下一个');
        return;
      }

      final nextIndex = state.currentSearchResultIndex + 1;
      final targetMessageId = state.searchResultMessageIds[nextIndex];

      await _loadAndJumpToSearchResultIncremental(nextIndex, targetMessageId);
    }
  }

  /// 💢💢💢 重构：跳转到上一个搜索结果（线性导航，无循环）
  Future<void> goToPrevSearchResult() async {
    if (!isClosed && state.searchResultMessageIds.isNotEmpty) {
      // 💢💢💢 线性导航：检查是否已经是第一个
      if (state.currentSearchResultIndex <= 0) {
        _logger.i('已经是第一个搜索结果，无法继续上一个');
        return;
      }

      final prevIndex = state.currentSearchResultIndex - 1;
      final targetMessageId = state.searchResultMessageIds[prevIndex];

      await _loadAndJumpToSearchResultIncremental(prevIndex, targetMessageId);
    }
  }

  /// 💢💢💢 新增：切换搜索结果列表视图
  void toggleSearchListView() {
    if (!isClosed) {
      emit(state.copyWith(
        isShowingSearchAsList: !state.isShowingSearchAsList,
      ));

      _logger.i('切换搜索结果视图', extra: {
        'isListView': !state.isShowingSearchAsList,
      });
    }
  }

  /// 💢💢💢 新增：获取当前显示的消息列表（搜索模式下返回搜索结果，正常模式返回所有消息）
  List<Message> getCurrentDisplayMessages() {
    if (state.isSearchMode && state.searchQuery.trim().isNotEmpty) {
      // 搜索模式下，直接返回当前的消息列表（已经是搜索范围内的消息）
      return state.messages;
    }
    return state.messages;
  }

  /// 💢💢💢 新增：获取当前搜索结果信息
  Map<String, dynamic> getCurrentSearchInfo() {
    if (!state.isSearchMode || state.searchResultTotalCount == 0) {
      return {};
    }

    return {
      'currentIndex': state.currentSearchResultIndex + 1,
      'totalCount': state.searchResultTotalCount,
      'query': state.searchQuery,
      'hasDateFilter': state.searchDateFilter != null,
      'currentMessageId': state.searchResultMessageIds.isNotEmpty
          ? state.searchResultMessageIds[state.currentSearchResultIndex]
          : null,
    };
  }

  /// 💢💢💢 新增：检查指定消息是否是当前高亮的搜索结果
  bool isCurrentSearchResult(String messageId) {
    if (!state.isSearchMode || state.searchResultMessageIds.isEmpty) {
      return false;
    }

    final currentResultId =
        state.searchResultMessageIds[state.currentSearchResultIndex];
    return messageId == currentResultId;
  }

  /// 💢💢💢 新增：检查指定消息是否是搜索结果之一
  bool isSearchResult(String messageId) {
    return state.searchResultMessageIds.contains(messageId);
  }

  /// 💢💢💢💢💢💢💢💢💢💢💢💢💢💢   会话设置管理   💢💢💢💢💢💢💢💢💢💢💢💢💢💢

  /// 更新会话静音状态
  Future<void> updateConversationMuteStatus(bool isMuted) async {
    try {
      _logger.i('更新会话静音状态', extra: {
        'conversationId': _conversationId,
        'isMuted': isMuted,
      });

      // 💢💢💢 统一通过 ChatsRepository 更新会话状态
      // 不再需要通过 ChatRepository 更新，避免重复操作
      await _chatsRepository.updateConversationMuteStatus(
          _conversationId, isMuted);

      // 💢💢💢 移除本地状态更新，由数据库监听自动处理
      // 当数据库更新后，watchConversation 会自动触发 _handleConversationDataUpdate
      // 从而更新 ChatCubit 的状态，实现自动同步

      _logger.i('会话静音状态更新请求已发送，等待数据库监听器自动同步状态');
    } catch (error) {
      _logger.e('更新会话静音状态失败', error: error);
      if (!isClosed) {
        emit(state.copyWith(errorMessage: '更新静音状态失败: ${error.toString()}'));
      }
    }
  }

  /// 更新会话置顶状态
  Future<void> updateConversationPinStatus(bool isPinned) async {
    try {
      _logger.i('更新会话置顶状态', extra: {
        'conversationId': _conversationId,
        'isPinned': isPinned,
      });

      // 💢💢💢 统一通过 ChatsRepository 更新置顶状态
      await _chatsRepository.updateConversationPinStatus(
          _conversationId, isPinned);

      // 💢💢💢 由数据库监听自动处理状态同步
      _logger.i('会话置顶状态更新请求已发送，等待数据库监听器自动同步状态');
    } catch (error) {
      _logger.e('更新会话置顶状态失败', error: error);
      if (!isClosed) {
        emit(state.copyWith(errorMessage: '更新置顶状态失败: ${error.toString()}'));
      }
    }
  }

  /// 获取当前会话信息
  Future<Conversation?> getCurrentConversation() async {
    try {
      return await _chatsRepository.getConversationById(_conversationId);
    } catch (error) {
      _logger.e('获取会话信息失败', error: error);
      return null;
    }
  }

  /// 获取有消息的日期列表
  Set<DateTime> getAvailableDates() {
    final availableDates = <DateTime>{};

    for (final message in state.messages) {
      final messageDate = DateTime(
        message.createdAt.year,
        message.createdAt.month,
        message.createdAt.day,
      );
      availableDates.add(messageDate);
    }

    return availableDates;
  }

  /// 检查指定日期是否有消息
  bool hasMessagesOnDate(DateTime date) {
    final targetDate = DateTime(date.year, date.month, date.day);

    return state.messages.any((message) {
      final messageDate = DateTime(
        message.createdAt.year,
        message.createdAt.month,
        message.createdAt.day,
      );
      return messageDate.isAtSameMomentAs(targetDate);
    });
  }

  /// 💢💢💢 新增：查找指定日期的第一条消息（时间最早的消息）
  /// 注意：由于UI是反向显示的，该日期的第一条消息在UI中会显示在该日期所有消息的最下方
  Future<Message?> findFirstMessageOfDate(DateTime date) async {
    try {
      final targetDate = DateTime(date.year, date.month, date.day);

      _logger.i('查找指定日期的第一条消息（最早时间）', extra: {
        'targetDate': targetDate.toIso8601String(),
      });

      // 首先在当前消息列表中查找
      Message? firstMessage;
      DateTime? earliestTime;

      for (final message in state.messages) {
        final messageDate = DateTime(
          message.createdAt.year,
          message.createdAt.month,
          message.createdAt.day,
        );

        if (messageDate.isAtSameMomentAs(targetDate)) {
          if (earliestTime == null ||
              message.createdAt.isBefore(earliestTime)) {
            earliestTime = message.createdAt;
            firstMessage = message;
          }
        }
      }

      // 如果在当前消息列表中找到了，直接返回
      if (firstMessage != null) {
        _logger.i('在当前消息列表中找到第一条消息', extra: {
          'messageId': firstMessage.messageId,
          'createdAt': firstMessage.createdAt.toIso8601String(),
        });
        return firstMessage;
      }

      // 如果当前消息列表中没有，从数据库中查找
      _logger.i('当前消息列表中未找到，从数据库查找');

      // 💢💢💢 修改数据库查询：获取该日期的所有消息，然后找到最早的
      final messagesFromDb = await _chatRepository.getMessagesByDateRange(
        _conversationId,
        targetDate,
        targetDate,
        limit: 100, // 获取该日期的更多消息以确保找到最早的
      );

      if (messagesFromDb.isNotEmpty) {
        // 💢💢💢 按时间升序排序，获取最早的消息（第一条）
        messagesFromDb.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        final firstMessageFromDb = messagesFromDb.first;

        _logger.i('从数据库找到第一条消息', extra: {
          'messageId': firstMessageFromDb.messageId,
          'createdAt': firstMessageFromDb.createdAt.toIso8601String(),
          'totalMessagesOnDate': messagesFromDb.length,
        });

        return firstMessageFromDb;
      }

      _logger.w('指定日期没有找到任何消息', extra: {
        'targetDate': targetDate.toIso8601String(),
      });

      return null;
    } catch (error) {
      _logger.e('查找指定日期的第一条消息失败', error: error);
      return null;
    }
  }

  /// 设置搜索日期过滤器
  void setSearchDateFilter(DateTime? dateFilter) {
    if (!isClosed) {
      // 💢💢💢 使用新的 clearSearchDateFilter 参数来正确处理 null 值
      emit(state.copyWith(
        searchDateFilter: dateFilter,
        clearSearchDateFilter: dateFilter == null,
      ));

      // 💢💢💢 新逻辑：根据不同情况处理
      if (state.searchQuery.isNotEmpty) {
        // 如果有搜索关键词，重新执行搜索
        performSearch(state.searchQuery);
      } else if (dateFilter != null) {
        // 💢💢💢 如果没有搜索关键词但有日期过滤器，展示当天所有消息
        _performDateOnlyFilter(dateFilter);
      } else {
        // 💢💢💢 如果清除了日期过滤器且没有搜索词，恢复正常消息列表
        _restoreNormalMessageList();
      }

      _logger.i('设置搜索日期过滤器', extra: {
        'dateFilter': dateFilter,
        'hasSearchQuery': state.searchQuery.isNotEmpty,
      });
    }
  }

  /// 💢💢💢 新增：执行纯日期过滤，展示指定日期的所有消息
  Future<void> _performDateOnlyFilter(DateTime dateFilter) async {
    try {
      _logger.i('执行纯日期过滤', extra: {
        'dateFilter': dateFilter.toIso8601String(),
      });

      emit(state.copyWith(isSearching: true));

      // 获取指定日期的所有消息
      final messages = await _chatRepository.getMessagesByDateRange(
        _conversationId,
        dateFilter,
        dateFilter,
        limit: 200, // 一天最多200条消息
      );

      emit(state.copyWith(
        messages: messages,
        isSearching: false,
        // 💢💢💢 清空搜索结果相关状态，因为这不是文本搜索
        searchResultMessageIds: [],
        currentSearchResultIndex: 0,
        searchResultTotalCount: 0,
      ));

      _logger.i('纯日期过滤完成', extra: {
        'dateFilter': dateFilter.toIso8601String(),
        'messageCount': messages.length,
      });
    } catch (error) {
      _logger.e('纯日期过滤失败', error: error);
      if (!isClosed) {
        emit(state.copyWith(
          isSearching: false,
          errorMessage: '日期过滤失败: ${error.toString()}',
        ));
      }
    }
  }

  /// 💢💢💢 新增：恢复正常消息列表
  Future<void> _restoreNormalMessageList() async {
    try {
      _logger.i('恢复正常消息列表');

      emit(state.copyWith(isSearching: true));

      // 💢💢💢 如果有原始消息备份，直接恢复；否则重新加载
      if (state.originalMessages != null &&
          state.originalMessages!.isNotEmpty) {
        // 直接恢复原始消息列表
        emit(state.copyWith(
          messages: state.originalMessages!,
          isSearching: false,
          // 💢💢💢 清空搜索相关状态
          searchResultMessageIds: [],
          currentSearchResultIndex: 0,
          searchResultTotalCount: 0,
          originalMessages: null, // 清空备份
        ));
        _logger.i('从备份恢复正常消息列表完成');
      } else {
        // 重新加载最近的消息
        await _loadInitialMessages();

        // 💢💢💢 确保重置搜索状态
        if (!isClosed) {
          emit(state.copyWith(
            isSearching: false,
            searchResultMessageIds: [],
            currentSearchResultIndex: 0,
            searchResultTotalCount: 0,
          ));
        }
        _logger.i('重新加载恢复正常消息列表完成');
      }
    } catch (error) {
      _logger.e('恢复正常消息列表失败', error: error);
      if (!isClosed) {
        emit(state.copyWith(
          isSearching: false,
          errorMessage: '恢复消息列表失败: ${error.toString()}',
        ));
      }
    }
  }

  /// 💢💢💢💢💢💢💢💢💢💢💢💢💢💢   会话设置管理   💢💢💢💢💢💢💢��💢💢💢💢💢💢

  /// 💢💢💢 新增：加载并跳转到指定的搜索结果
  Future<void> _loadAndJumpToSearchResult(
      int targetIndex, String targetMessageId) async {
    try {
      _logger.i('加载并跳转到搜索结果', extra: {
        'targetIndex': targetIndex + 1,
        'targetMessageId': targetMessageId,
      });

      // 显示加载状态
      emit(state.copyWith(isSearching: true));

      // 🔥 加载目标搜索结果附近的消息（替换式加载）
      final result = await _chatRepository.getMessagesAroundSearchResult(
        conversationId: _conversationId,
        targetMessageId: targetMessageId,
        contextSize: 25,
      );

      // 更新状态
      emit(state.copyWith(
        messages: result.messages, // 💢 替换整个消息列表
        currentSearchResultIndex: targetIndex,
        isSearching: false,
      ));

      // 滚动到目标消息
      // _scrollToSearchResult(targetMessageId);

      _logger.i('加载并跳转完成', extra: {
        'targetIndex': targetIndex + 1,
        'loadedMessageCount': result.messages.length,
        'loadedRange':
            '${result.timeRange.start.toIso8601String()} - ${result.timeRange.end.toIso8601String()}',
      });
    } catch (error) {
      _logger.e('加载并跳转到搜索结果失败', error: error);
      if (!isClosed) {
        emit(state.copyWith(
          isSearching: false,
          errorMessage: '跳转失败: ${error.toString()}',
        ));
      }
    }
  }

  /// 💢💢💢 新增：增量加载 废弃->并跳转到指定的搜索结果
  Future<void> _loadAndJumpToSearchResultIncremental(
      int targetIndex, String targetMessageId) async {
    try {
      _logger.i('增量加载并跳转到搜索结果', extra: {
        'targetIndex': targetIndex + 1,
        'targetMessageId': targetMessageId,
      });

      // 显示加载状态
      emit(state.copyWith(isSearching: true));

      // 🔥 加载目标搜索结果附近的消息
      final result = await _chatRepository.getMessagesAroundSearchResult(
        conversationId: _conversationId,
        targetMessageId: targetMessageId,
        contextSize: 25,
      );

      // 💢💢💢 增量合并消息列表
      final mergedMessages =
          _mergeMessagesIncremental(state.messages, result.messages);

      // 更新状态
      emit(state.copyWith(
        messages: mergedMessages, // 💢 增量合并后的消息列表
        currentSearchResultIndex: targetIndex,
        isSearching: false,
      ));

      // 滚动到目标消息(废弃)
      // _scrollToSearchResult(targetMessageId);

      _logger.i('增量加载并跳转完成', extra: {
        'targetIndex': targetIndex + 1,
        'originalMessageCount': state.messages.length,
        'newMessageCount': result.messages.length,
        'mergedMessageCount': mergedMessages.length,
        'loadedRange':
            '${result.timeRange.start.toIso8601String()} - ${result.timeRange.end.toIso8601String()}',
      });

      // 💢💢💢 延迟清理多余的消息（在跳转完成后）
      // Future.delayed(const Duration(milliseconds: 500), () {
      //   _cleanupExcessMessages(targetMessageId);
      // });
    } catch (error) {
      _logger.e('增量加载并跳转到搜索结果失败', error: error);
      if (!isClosed) {
        emit(state.copyWith(
          isSearching: false,
          errorMessage: '跳转失败: ${error.toString()}',
        ));
      }
    }
  }

  /// 💢💢💢 新增：增量合并消息列表并去重排序
  List<Message> _mergeMessagesIncremental(
      List<Message> existingMessages, List<Message> newMessages) {
    // 使用Map来去重，messageId作为key
    final messageMap = <String, Message>{};

    // 先添加现有消息
    for (final message in existingMessages) {
      messageMap[message.messageId] = message;
    }

    // 再添加新消息（会覆盖重复的）
    for (final message in newMessages) {
      messageMap[message.messageId] = message;
    }

    // 转换为列表并按时间排序（最新到最老）
    final mergedList = messageMap.values.toList();
    mergedList.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return mergedList;
  }

  /// 💢💢💢 新增：加载指定消息周围的消息
  Future<bool> loadMessagesAroundMessage(String messageId,
      {int contextSize = 25}) async {
    try {
      _logger.i('加载指定消息周围的消息', extra: {
        'messageId': messageId,
        'contextSize': contextSize,
      });

      // 显示加载状态
      emit(state.copyWith(isLoadingMessages: true));

      // 使用现有的getMessagesAroundSearchResult方法
      final result = await _chatRepository.getMessagesAroundSearchResult(
        conversationId: _conversationId,
        targetMessageId: messageId,
        contextSize: contextSize,
      );

      if (result.messages.isNotEmpty) {
        // 更新消息列表
        emit(state.copyWith(
          messages: result.messages,
          isLoadingMessages: false,
        ));

        _logger.i('加载指定消息周围的消息成功', extra: {
          'messageId': messageId,
          'loadedCount': result.messages.length,
        });

        return true;
      } else {
        _logger.w('未找到指定消息或其周围的消息', extra: {
          'messageId': messageId,
        });

        emit(state.copyWith(isLoadingMessages: false));
        return false;
      }
    } catch (error) {
      _logger.e('加载指定消息周围的消息失败', error: error, extra: {
        'messageId': messageId,
      });

      if (!isClosed) {
        emit(state.copyWith(
          isLoadingMessages: false,
          errorMessage: '加载消息失败: ${error.toString()}',
        ));
      }

      return false;
    }
  }

  /// 💢💢💢 新增：清理多余的消息，保持内存效率
  void _cleanupExcessMessages(String targetMessageId) {
    if (isClosed) return;

    try {
      final currentMessages = state.messages;
      const maxMessagesInMemory = 200; // 内存中最多保留200条消息

      // 如果消息数量超过限制，需要清理
      if (currentMessages.length <= maxMessagesInMemory) {
        return; // 无需清理
      }

      _logger.i('开始清理多余消息', extra: {
        'currentCount': currentMessages.length,
        'maxAllowed': maxMessagesInMemory,
        'targetMessageId': targetMessageId,
      });

      // 找到目标消息的索引
      final targetIndex = currentMessages.indexWhere(
        (message) => message.messageId == targetMessageId,
      );

      if (targetIndex == -1) {
        _logger.w('清理时未找到目标消息，跳过清理');
        return;
      }

      // 计算保留范围：目标消息前后各保留一定数量
      const keepBeforeTarget = 80;
      const keepAfterTarget = 80;

      final startIndex =
          (targetIndex - keepBeforeTarget).clamp(0, currentMessages.length);
      final endIndex =
          (targetIndex + keepAfterTarget + 1).clamp(0, currentMessages.length);

      final cleanedMessages = currentMessages.sublist(startIndex, endIndex);

      // 💢💢💢 清理后，需要暂时禁用滚动位置监听，避免误触发加载更多
      emit(state.copyWith(
        messages: cleanedMessages,
        isCleaningMessages: true, // 💢💢💢 添加清理标志
      ));

      _logger.i('清理多余消息完成', extra: {
        'originalCount': currentMessages.length,
        'cleanedCount': cleanedMessages.length,
        'removedCount': currentMessages.length - cleanedMessages.length,
        'targetStillExists':
            cleanedMessages.any((m) => m.messageId == targetMessageId),
      });

      // 💢💢💢 延迟重置清理标志，给UI时间调整
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (!isClosed) {
          emit(state.copyWith(isCleaningMessages: false));
          _logger.d('清理标志已重置');
        }
      });
    } catch (error) {
      _logger.e('清理多余消息失败', error: error);
    }
  }

  /// 重发失败的消息
  Future<void> resendMessage(String messageId) async {
    _logger.d('重发消息', extra: {'messageId': messageId});

    if (isClosed) return;

    try {
      // 1. 获取失败的消息
      final message = await _chatRepository.getMessageById(messageId);
      if (message == null) {
        _logger.w('重发消息失败：消息不存在', extra: {'messageId': messageId});
        return;
      }

      if (message.status != 'failed') {
        _logger.w('重发消息失败：消息状态不是失败', extra: {
          'messageId': messageId,
          'currentStatus': message.status,
        });
        return;
      }

      // 2. 设置发送状态
      _setLoadingState(true);

      // 3. 重置消息状态为发送中
      await _chatRepository.updateMessageStatus(messageId, 'sending');

      // 4. 更新UI中的消息状态
      _updateMessageStatusInUI(messageId, 'sending');

      // 5. 重新发送消息
      await _sendMessageToServer(message);

      _logger.i('消息重发成功', extra: {'messageId': messageId});
    } catch (error) {
      _logger.e('重发消息失败', error: error);

      // 重新标记为失败
      await _handleSendFailure(messageId, '重发失败: ${error.toString()}');
    } finally {
      // 重置发送状态
      _setLoadingState(false);
    }
  }

  /// 更新UI中消息的状态
  void _updateMessageStatusInUI(String messageId, String status) {
    if (isClosed) return;

    final updatedMessages = state.messages.map((message) {
      if (message.messageId == messageId) {
        message.status = status;
        if (status != 'failed') {
          message.errorMessage = null;
        }
      }
      return message;
    }).toList();

    _updateMessagesInState(updatedMessages);

    _logger.d('UI中消息状态已更新', extra: {
      'messageId': messageId,
      'status': status,
    });
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
