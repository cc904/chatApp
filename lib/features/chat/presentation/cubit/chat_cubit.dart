// ignore_for_file: unused_element

import 'dart:async';

import 'package:cc/core/database/models/conversation.dart';
import 'package:cc/core/database/models/current_user.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cc/core/database/models/message.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/features/chat/domain/repositories/chat_repository.dart';
import 'package:cc/features/chat/domain/repositories/chat_repository_send.dart';
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
  final ChatRepositorySend _chatRepositorySend;
  final ChatsRepository _chatsRepository;
  final String _conversationId;
  final CurrentUser _currentUser;

  final LogService _logger = LogService.instance;

  // 保存订阅，以便在dispose时取消
  final Map<String, StreamSubscription> _subscriptions = {};

  // 简化的配置参数
  static const int defaultPageSize = 50; // 每页消息数量

  ChatCubit({
    required ChatRepository chatRepository,
    required ChatRepositorySend chatRepositorySend,
    required ChatsRepository chatsRepository,
    required Conversation initialConversation,
    required CurrentUser currentUser,
    ChatStateSnapshot? initialSnapshot,
    ContactsRepository? contactsRepository,
  })  : _chatRepository = chatRepository,
        _chatRepositorySend = chatRepositorySend,
        _chatsRepository = chatsRepository,
        _conversationId = initialConversation.conversationId,
        _currentUser = currentUser,
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
        currentScrollPosition: snapshot.currentScrollPosition,
        isLoadingMessages: false,
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
      _logger.i('开始初始同步流程', extra: {'conversationId': _conversationId});

      // 🔄 第二步：设置数据库监听（必须在加入房间前设置）
      _setupDatabaseListeners();

      // 🔄 第三步：加入会话房间开始接收实时消息
      await joinConversation();

      // 🔄 第四步：执行消息同步（此时新消息会被暂存）
      initMessages();
    } catch (error) {
      _logger.e('初始同步失败', error: error);
      emit(state.copyWith(
        isSyncing: false,
        errorMessage: '同步失败: ${error.toString()}',
      ));
    }
  }

  /// 初始化消息列表（纯数据库监听架构版本）
  Future<void> initMessages() async {
    if (isClosed) return;

    // 🔄 第一步：设置同步状态（Index方案无需时间戳）
    emit(state.copyWith(
      isSyncing: true,
    ));

    try {
      final messages = await _chatRepository.getMessagesByAnchorMessageIndex(
          _conversationId,
          null,
          state.conversation.firstMessageIndex,
          state.conversation.lastMessageIndex);

      _logger.i('初始化消息列表',
          extra: {
            'conversationId': _conversationId,
            'messageCount': messages.length,
          },
          stackTrace: StackTrace.current);

      emit(state.copyWith(messages: messages, isSyncing: false));
    } catch (error) {
      emit(state.copyWith(isSyncing: false));
      _logger.e('初始化消息列表失败', error: error);
    }
  }

  /// 发送文本消息（纯数据库监听架构版本）
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

    try {
      // 1. 设置发送状态
      if (!isClosed) {
        emit(state.copyWith(isSending: true));
      }

      // 2. 直接通过ChatRepositorySend发送消息
      // Repository会创建消息、保存到数据库、发送到服务器
      // 数据库监听会自动更新UI，无需手动更新
      final message = await _chatRepositorySend.sendTextMessage(
          _conversationId, text.trim());

      _logger.i('文本消息发送请求已提交', extra: {
        'messageId': message.messageId,
        'conversationId': _conversationId,
      });

      // 💢💢💢 关键：不需要手动更新UI，数据库监听会自动处理
    } catch (error) {
      _logger.e('发送文本消息失败', error: error);

      // 设置错误状态
      if (!isClosed) {
        emit(state.copyWith(errorMessage: '消息发送失败: ${error.toString()}'));
      }

      rethrow;
    } finally {
      // 重置发送状态
      if (!isClosed) {
        emit(state.copyWith(isSending: false));
      }
    }
  }

  /// 创建临时消息
  Future<Message> _createTempMessage(String text) async {
    return await _chatRepositorySend.createTempMessage(
      _conversationId,
      text,
      MessageType.text,
    );
  }

  /// 添加消息到UI（乐观更新）
  Future<void> _addMessageToUI(Message message) async {
    if (isClosed) return;

    final updatedMessages = [message, ...state.messages];

    emit(state.copyWith(messages: updatedMessages));

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
    await _chatRepositorySend.sendMessageWithTimeout(
      message,
      timeout: const Duration(seconds: 5), // 增加超时时间到5秒
    );
  }

  /// 处理发送失败
  Future<void> _handleSendFailure(String? messageId, String errorReason) async {
    if (messageId == null || isClosed) return;

    try {
      // 标记消息为失败状态
      await _chatRepositorySend.markMessageAsFailed(messageId, errorReason);

      // 设置错误消息给用户
      emit(state.copyWith(errorMessage: '消息发送失败: $errorReason'));
    } catch (error) {
      _logger.e('处理发送失败时出错', error: error);
    }
  }

  /// 💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢

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

      // 🔧 修复：离开会话时重置同步状态
      if (!isClosed) {
        emit(state.copyWith(
          isSyncing: false,
          pendingMessages: [], // 清空暂存消息
        ));
      }

      // 离开会话时保存状态快照
      if (state.messages.isNotEmpty) {
        final snapshot = ChatStateSnapshot(
          messages: state.messages,
          currentScrollPosition: state.currentScrollPosition,
        );

        await _chatsRepository.saveStateSnapshot(snapshot, _conversationId);

        _logger.d('离开会话时保存状态快照', extra: {
          'conversationId': _conversationId,
          'messageCount': state.messages.length,
        });
      }

      // 通知服务器用户离开会话房间
      await _chatRepository.leaveConversationRoom(_conversationId);

      _logger.i('会话离开完成，同步状态已重置');
    } catch (error) {
      _logger.e('离开会话失败', error: error);
      // 即使出错也要重置同步状态
      if (!isClosed) {
        emit(state.copyWith(isSyncing: false, pendingMessages: []));
      }
    }
  }

  /// 更新当前滚动位置 💢💢💢💢
  /// 用于保存用户当前的查看位置
  void updateCurrentScrollPosition(Iterable<ItemPosition> positions) {
    if (isClosed || positions.isEmpty || state.messages.isEmpty) {
      return;
    }

    // 获取所有有效位置并按索引排序
    final sortedPositions = positions.toList()
      ..sort((a, b) => b.index.compareTo(a.index));

    // 选择屏幕中央的消息作为锚点
    final centerPosition = sortedPositions.firstWhere(
      (pos) => pos.itemLeadingEdge <= 0.5 && pos.itemTrailingEdge >= 0.5,
      orElse: () => positions.first,
    );

    int isDown = 0;

    // 💢💢💢 双重检查索引有效性
    if (centerPosition.index >= 0 &&
        centerPosition.index < state.messages.length) {
      final message = state.messages[centerPosition.index];
      final currentScrollPosition = CurrentScrollPosition.fromAnchor(
        messageId: message.messageId,
        messageIndex: message.messageIndex,
        relativePosition: centerPosition.itemLeadingEdge,
      );

      // 💢💢💢 计算滚动方向
      if (state.currentScrollPosition.messageIndex != null) {
        isDown =
            state.currentScrollPosition.messageIndex! - message.messageIndex;
      }

      if (!isClosed) {
        emit(state.copyWith(
          currentScrollPosition: currentScrollPosition,
        ));
      }
    }

    if (!state.isSearchMode &&
        !state.isCleaningMessages &&
        !state.isSyncing &&
        !state.isLoadingMessages &&
        !state.isLoadingMoreMessages &&
        state.messages.length > 50 &&
        state.messages.isNotEmpty) {
      // 搜索模式、清理消息、同步中或正在加载时不触发
      // 💢💢💢 传递滚动方向给检查方法
      _checkAndLoadMoreMessages(sortedPositions, isDown);
    }

    // 💢💢💢 已读状态更新
    _updateReadStatus(sortedPositions);
  }

  /// 💢💢💢 新增：检查并加载更多消息
  void _checkAndLoadMoreMessages(
      List<ItemPosition> sortedPositions, int isDown) {
    final firstVisibleMessageIndex =
        state.messages[sortedPositions.first.index].messageIndex;
    final lastVisibleMessageIndex =
        state.messages[sortedPositions.last.index].messageIndex;

    // 会话的消息索引范围 messages.first 最新消息 messages.last 最晚消息
    final messagesUpIndex = state.messages.last.messageIndex;
    final messagesDownIndex = state.messages.first.messageIndex;

    _logger.i('检查并加载更多消息', extra: {'isDown': isDown});
    if (isDown > 0) {
      if (firstVisibleMessageIndex - 10 < messagesUpIndex &&
          messagesUpIndex > state.conversation.firstMessageIndex) {
        _logger.w('加载消息up', extra: {"messageIndex": firstVisibleMessageIndex});
        _chatRepository.requestMoreMessages(
          _conversationId,
          messageIndex: messagesUpIndex,
          isBefore: true, // 获取历史消息
        );
      }
    } else {
      if (lastVisibleMessageIndex + 10 > messagesDownIndex &&
          messagesDownIndex < state.conversation.lastMessageIndex) {
        _logger.w('加载消息down', extra: {"messageIndex": lastVisibleMessageIndex});
        _chatRepository.requestMoreMessages(
          _conversationId,
          messageIndex: messagesDownIndex,
          isBefore: false, // 获取更新的消息
        );
      }
    }
  }

  /// 💢💢💢💢💢💢💢💢💢💢💢💢💢   搜索功能   💢💢💢💢💢💢💢💢💢💢💢💢💢💢

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
          contextSize: 50, // 前后各50条消息
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

  /// 💢💢💢 新增：增量加载并跳转到指定的搜索结果
  Future<void> _loadAndJumpToSearchResultIncremental(
      int targetIndex, String targetMessageId) async {
    try {
      _logger.i('增量加载并跳转到搜索结果', extra: {
        'targetIndex': targetIndex + 1,
        'targetMessageId': targetMessageId,
      });

      // 💢💢💢 使用搜索状态而不是加载状态
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

      // 滚动功能暂时禁用
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
    mergedList.sort((a, b) => b.messageIndex.compareTo(a.messageIndex));

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

      // 💢💢💢 移除手动设置加载状态，由 ChatRepository 通知
      // emit(state.copyWith(isLoadingMessages: true));

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
          // isLoadingMessages: false, // 💢💢💢 由 ChatRepository 通知
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

        // emit(state.copyWith(isLoadingMessages: false)); // 💢💢💢 由 ChatRepository 通知
        return false;
      }
    } catch (error) {
      _logger.e('加载指定消息周围的消息失败', error: error, extra: {
        'messageId': messageId,
      });

      if (!isClosed) {
        emit(state.copyWith(
          // isLoadingMessages: false, // 💢💢💢 由 ChatRepository 通知
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
      await _chatsRepository.updateParticipantSettings(
        _conversationId,
        muted: isMuted,
      );

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
      await _chatsRepository.updateParticipantSettings(
        _conversationId,
        pinned: isPinned,
      );

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

  /// 新增：查找指定日期的第一条消息（时间最早的消息）💢💢💢💢
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
        messagesFromDb.sort((a, b) => b.messageIndex.compareTo(a.messageIndex));
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

  /// 💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢 消息相关 💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢

  /// 重发失败的消息
  Future<void> resendMessage(String messageId) async {
    _logger.d('重发消息', extra: {'messageId': messageId});

    if (isClosed) return;

    try {
      // 1. 获取失败的消息
      final message = await _chatRepositorySend.getMessageById(messageId);
      if (message == null) {
        _logger.w('重发消息失败：消息不存在', extra: {'messageId': messageId});
        return;
      }

      if (message.status != MessageStatus.failed) {
        _logger.w('重发消息失败：消息状态不是失败', extra: {
          'messageId': messageId,
          'currentStatus': message.status,
        });
        return;
      }

      // 2. 设置发送状态
      if (!isClosed) {
        emit(state.copyWith(isSending: true));
      }

      // 3. 重置消息状态为发送中
      await _chatRepositorySend.updateMessageStatus(
          messageId, MessageStatus.sending);

      // 5. 重新发送消息
      await _sendMessageToServer(message);

      _logger.i('消息重发成功', extra: {'messageId': messageId});
    } catch (error) {
      _logger.e('重发消息失败', error: error);

      // 重新标记为失败
      await _handleSendFailure(messageId, '重发失败: ${error.toString()}');
    } finally {
      // 重置发送状态
      if (!isClosed) {
        emit(state.copyWith(isSending: false));
      }
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

      // emit(state.copyWith(isLoadingMessages: true)); // 💢💢💢 由 ChatRepository 通知

      // 从数据库加载消息
      // await requestSyncMessages();
    } catch (error) {
      _logger.e('加载初始消息失败', error: error);

      // 检查Cubit是否已关闭
      if (!isClosed) {
        emit(state.copyWith(
          // isLoadingMessages: false, // 💢💢💢 由 ChatRepository 通知
          errorMessage: '加载消息失败: ${error.toString()}',
        ));
      }
    }
  }

  ///💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢 设置数据库监听 💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢

  void _setupDatabaseListeners() {
    try {
      _logger.i('设置数据库监听', extra: {'conversationId': _conversationId});

      // 💢💢💢 核心：监听数据库消息变化触发信号
      _subscriptions['messagesWatch'] =
          _chatRepository.watchMessages(_conversationId).listen(
        (_) => _handleDatabaseMessagesChanged(),
        onError: (error) {
          _logger.e('数据库消息监听出错', error: error);
        },
      );

      // 💢💢💢 监听会话数据变化
      _subscriptions['conversationWatch'] =
          _chatsRepository.watchConversation(_conversationId).listen(
        _handleDatabaseConversationChanged,
        onError: (error) {
          _logger.e('数据库会话监听出错', error: error);
        },
      );

      // 💢💢💢 保留必要的网络事件监听（如输入状态）
      _subscriptions['typingStatus'] =
          _chatRepository.getTypingStatusStream().listen(
        _handleTypingStatus,
        onError: (error) {
          _logger.e('输入状态监听出错', error: error);
        },
      );

      // 💢💢💢 新增：监听加载状态变化
      _subscriptions['loadingStatus'] =
          _chatRepository.getLoadingStatusStream().listen(
        _handleLoadingStatus,
        onError: (error) {
          _logger.e('加载状态监听出错', error: error);
        },
      );

      _logger.i('数据库监听设置完成');
    } catch (error) {
      _logger.e('设置数据库监听失败', error: error);
    }
  }

  /// 💢💢💢 处理数据库消息变化触发信号（优化性能版本）
  void _handleDatabaseMessagesChanged() async {
    if (isClosed) return;

    // 获取锚点消息Index
    final anchorMessageIndex = state.currentScrollPosition.messageIndex;

    try {
      // 主动从数据库获取最新消息数据
      final messages = await _chatRepository.getMessagesByAnchorMessageIndex(
          _conversationId,
          anchorMessageIndex,
          state.conversation.firstMessageIndex,
          state.conversation.lastMessageIndex);

      // 获取消息数量
      final messageCount = messages.length;

      // 更新消息列表
      emit(state.copyWith(
        messages: messages,
        // isLoadingMessages: false, // 💢💢💢 由 ChatRepository 通知
      ));

      _logger.d('数据库消息变化处理完成', extra: {
        'messageCount': messageCount,
      });
    } catch (error) {
      _logger.e('处理数据库消息变化触发信号失败', error: error);
    }
  }

  /// 💢💢💢 处理数据库会话变化
  void _handleDatabaseConversationChanged(Conversation? conversation) {
    if (isClosed || conversation == null) return;

    _logger.d('数据库会话变化处理', extra: {
      'conversationId': conversation.conversationId,
      'name': conversation.name,
    });

    // 直接更新会话状态
    emit(state.copyWith(conversation: conversation));
  }

  /// 💢💢💢 处理输入状态变化
  void _handleTypingStatus(Map<String, dynamic> event) {
    if (isClosed) return;

    final conversationId = event['conversationId'] as String?;
    final isTyping = event['isTyping'] as bool? ?? false;

    if (conversationId == _conversationId) {
      _logger.d('输入状态变化', extra: {
        'conversationId': conversationId,
        'isTyping': isTyping,
      });

      // 更新输入状态（这里可以根据需要扩展状态）
      // emit(state.copyWith(isOtherUserTyping: isTyping));
    }
  }

  /// 💢💢💢 新增：处理加载状态变化
  void _handleLoadingStatus(Map<String, dynamic> event) {
    if (isClosed) return;

    final conversationId = event['conversationId'] as String?;
    final isLoading = event['isLoading'] as bool? ?? false;
    final loadingType = event['loadingType'] as String? ?? 'messages';

    if (conversationId == _conversationId) {
      _logger.d('加载状态变化', extra: {
        'isLoading': isLoading,
        'loadingType': loadingType,
      });

      // 根据加载类型更新对应的状态
      switch (loadingType) {
        case 'fetchMessages':
          // 网络请求获取消息
          emit(state.copyWith(isFetching: isLoading));
          break;
        case 'initialMessages':
          // 初始消息加载
          emit(state.copyWith(isLoadingMessages: isLoading));
          break;
        case 'loadMoreBefore':
          // 加载历史消息（向上滚动）
          emit(state.copyWith(isLoadingMoreMessages: isLoading));
          break;
        case 'loadMoreAfter':
          // 加载更新消息（向下滚动）
          emit(state.copyWith(isLoadingMoreMessages: isLoading));
          break;
        case 'dateRange':
          // 按日期范围加载消息
          if (state.isSearchMode) {
            emit(state.copyWith(isSearching: isLoading));
          } else {
            emit(state.copyWith(isLoadingMessages: isLoading));
          }
          break;
        case 'fromDate':
          // 从指定日期加载消息
          if (state.isSearchMode) {
            emit(state.copyWith(isSearching: isLoading));
          } else {
            emit(state.copyWith(isLoadingMessages: isLoading));
          }
          break;
        case 'searchContext':
          // 搜索上下文加载（可以使用搜索状态或单独的状态）
          if (state.isSearchMode) {
            emit(state.copyWith(isSearching: isLoading));
          } else {
            emit(state.copyWith(isLoadingMessages: isLoading));
          }
          break;
        case 'searchRange':
          // 搜索范围加载
          if (state.isSearchMode) {
            emit(state.copyWith(isSearching: isLoading));
          } else {
            emit(state.copyWith(isLoadingMessages: isLoading));
          }
          break;
        case 'messages':
        default:
          // 默认消息加载
          emit(state.copyWith(isLoadingMessages: isLoading));
      }
    }
  }

  /// 💢💢💢 新增：更新已读状态（独立方法）
  void _updateReadStatus(List<ItemPosition> sortedPositions) {
    // 最新可见消息（索引最大）
    final lastPosition = sortedPositions.last;
    final lastShowMessage =
        (lastPosition.index >= 0 && lastPosition.index < state.messages.length)
            ? state.messages[lastPosition.index]
            : null;

    // 💢💢💢 修复：通过currentUser获取participant，添加空值检查
    final currentUserId = _currentUser.userId;

    final participant = state.conversation.getParticipant(currentUserId);
    if (participant == null) {
      _logger.w('找不到当前用户的参与者信息', extra: {
        'currentUserId': currentUserId,
        'conversationId': _conversationId,
      });
      return;
    }

    final lastReadMessageIndex = participant.lastReadMessageIndex;

    if (lastShowMessage != null &&
        lastShowMessage.messageIndex > lastReadMessageIndex) {
      _chatsRepository.updateParticipantSettings(
        _conversationId,
        readMessageIndex: lastShowMessage.messageIndex,
      );
      _logger.i('已读状态更新', extra: {
        'messageIndex': lastShowMessage.messageIndex,
        'lastReadMessageIndex': participant.lastReadMessageIndex,
      });
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
