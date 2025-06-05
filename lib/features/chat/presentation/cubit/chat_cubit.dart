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
          firstMessage.status != 'read') {
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
      ));
      _logger.i('退出搜索模式');
    }
  }

  /// 执行搜索
  Future<void> performSearch(String query) async {
    if (isClosed) return;

    _logger.i('执行搜索', extra: {'query': query});

    try {
      emit(state.copyWith(
        searchQuery: query,
        isSearching: true,
      ));

      if (query.trim().isEmpty) {
        emit(state.copyWith(
          searchResults: [],
          isSearching: false,
        ));
        return;
      }

      // 在本地消息中搜索
      final searchResults = _searchInMessages(query, state.messages);

      emit(state.copyWith(
        searchResults: searchResults,
        isSearching: false,
      ));

      _logger.i('搜索完成', extra: {'resultCount': searchResults.length});
    } catch (error) {
      _logger.e('搜索失败', error: error);
      if (!isClosed) {
        emit(state.copyWith(
          isSearching: false,
          errorMessage: '搜索失败: ${error.toString()}',
        ));
      }
    }
  }

  /// 获取当前显示的消息列表（搜索模式下返回搜索结果，正常模式返回所有消息）
  List<Message> getCurrentDisplayMessages() {
    if (state.isSearchMode && state.searchQuery.trim().isNotEmpty) {
      return _searchInMessages(state.searchQuery, state.messages);
    }
    return state.messages;
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

  /// 在消息列表中搜索
  List<Message> _searchInMessages(String query, List<Message> messages) {
    final searchQuery = query.toLowerCase().trim();
    final dateFilter = state.searchDateFilter;

    return messages.where((message) {
      // 日期过滤
      if (dateFilter != null) {
        final messageDate = DateTime(
          message.createdAt.year,
          message.createdAt.month,
          message.createdAt.day,
        );
        final filterDate = DateTime(
          dateFilter.year,
          dateFilter.month,
          dateFilter.day,
        );
        if (!messageDate.isAtSameMomentAs(filterDate)) {
          return false;
        }
      }

      // 内容搜索
      final content = message.text?.toLowerCase() ?? '';
      return content.contains(searchQuery);
    }).toList();
  }

  /// 💢💢💢💢💢💢💢💢💢💢💢💢💢💢   会话设置管理   💢💢💢💢��💢💢💢💢💢💢💢💢💢

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
