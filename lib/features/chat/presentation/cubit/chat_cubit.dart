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
  final LogService _logger = LogService.instance;
  final String _conversationId;
  // final User _currentUser;
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
    required Conversation conversation,
    required CurrentUser currentUser,
    ChatStateSnapshot? initialSnapshot,
    ContactsRepository? contactsRepository,
  })  : _chatRepository = chatRepository,
        _chatsRepository = chatsRepository,
        _conversationId = conversation.conversationId,
        _initialSnapshot = initialSnapshot,
        // _currentUser = currentUser,
        super(_createInitialState(conversation, currentUser, initialSnapshot)) {
    _init();
  }

  /// 创建初始状态
  /// 如果有快照，直接使用快照数据初始化；否则使用默认初始状态
  static ChatState _createInitialState(Conversation conversation,
      CurrentUser currentUser, ChatStateSnapshot? snapshot) {
    if (snapshot != null && snapshot.isValid) {
      // 使用快照数据创建初始状态
      return ChatState.initial(currentUser).copyWith(
        messages: snapshot.messages,
        lastReadMessageId: snapshot.lastReadMessageId,
        unreadCount: snapshot.unreadCount,
        currentScrollPosition: snapshot.currentScrollPosition,
        isLoadingMessages: false,
        hasMoreHistory: snapshot.hasMoreHistory,
        hasMoreRecent: snapshot.hasMoreRecent,
        conversation: conversation,
      );
    } else {
      // 使用传入的 conversation 对象创建初始状态
      return ChatState.initial(currentUser).copyWith(
        conversation: conversation,
      );
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

      // 监听消息状态更新
      _subscriptions['messageStatus'] = _chatRepository
          .getMessageStatusStream()
          .where((event) => event['type'] == 'loadMore')
          .listen(
        _handleLoadMoreMessageStatusUpdate,
        onError: (error) {
          _logger.e('消息状态流监听出错', error: error);
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

    Message? tempMessage;
    try {
      // 1. 设置发送状态
      _setLoadingState(true);

      // 2. 创建临时消息
      tempMessage = await _createTempMessage(text);

      // 3. 更新UI显示
      await _addMessageToUI(tempMessage);

      // 4. 发送消息到服务器
      await _sendMessageToServer(tempMessage);

      _logger.i('文本消息发送请求已发出', extra: {
        'tempMessageId': tempMessage.messageId,
      });
    } catch (error) {
      _logger.e('发送文本消息失败', error: error);

      // 处理发送失败
      await _handleSendFailure(tempMessage?.messageId, error.toString());
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

  /// 添加消息到UI
  Future<void> _addMessageToUI(Message message) async {
    if (isClosed) return;

    final updatedMessages = [message, ...state.messages];
    _updateMessagesInState(updatedMessages);
  }

  /// 发送消息到服务器
  Future<void> _sendMessageToServer(Message message) async {
    await _chatRepository.sendMessageWithTimeout(
      message,
      timeout: const Duration(seconds: 3),
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

      // 第一条可见消息（索引最小）
      final firstPosition = sortedPositions.first;
      final firstMessage = firstPosition.index < state.messages.length
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

  /// 更新状态中的消息列表
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

  /// 💢💢💢💢💢��💢💢💢💢💢💢💢💢   搜索功能   💢💢💢💢💢💢💢💢💢💢💢💢💢💢

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

  /// 💢💢💢 新增：滚动到指定的搜索结果消息(废弃)
  // void _scrollToSearchResult(String messageId) {
  //   // 这个方法会被UI层调用，用于滚动到指定消息
  //   // 具体的滚动逻辑在ChatPage中实现
  //   _logger.d('请求滚动到搜索结果', extra: {'messageId': messageId});
  // }

  /// 获取当前显示的消息列表（搜索模式下返回搜索结果，正常模式返回所有消息）
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

      // 通过 ChatsRepository 更新静音状态
      await _chatsRepository.updateConversationMuteStatus(
          _conversationId, isMuted);

      _logger.i('会话静音状态更新成功');
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

      // 通过 ChatsRepository 更新置顶状态
      await _chatsRepository.updateConversationPinStatus(
          _conversationId, isPinned);

      _logger.i('会话置顶状态更新成功');
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

  /// 设置搜索日期过滤器
  void setSearchDateFilter(DateTime? dateFilter) {
    if (!isClosed) {
      emit(state.copyWith(searchDateFilter: dateFilter));

      // 如果有搜索关键词，重新执行搜索
      if (state.searchQuery.isNotEmpty) {
        performSearch(state.searchQuery);
      }

      _logger.i('设置搜索日期过滤器', extra: {'dateFilter': dateFilter});
    }
  }

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
