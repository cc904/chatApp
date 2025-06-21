// ignore_for_file: unused_element

import 'dart:async';
import 'dart:collection';

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
import 'package:cc/features/chat/domain/entities/message_update_event.dart';
import 'package:cc/core/proto/generated/message.pb.dart' show LoadingType;

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

      // 🔄 第1步：设置Repository Stream监听（必须在加入房间前设置）
      _setupRepositoryListeners();

      // 🔄 第2步：加入会话房间开始接收实时消息
      await joinConversation();

      // 🔄 第3步：执行消息同步（此时新消息会被暂存）
      initMessages();
    } catch (error) {
      _logger.e('初始同步失败', error: error);
      emit(state.copyWith(
        errorMessage: '同步失败: ${error.toString()}',
      ));
    }
  }

  /// 初始化消息列表（统一加载最新100条消息）
  Future<void> initMessages() async {
    if (isClosed) return;
    try {
      _logger.i('初始化消息列表 - 加载最新100条消息', extra: {
        'conversationId': _conversationId,
        'hasSnapshot': state.messages.isNotEmpty,
        'currentMessageCount': state.messages.length,
      });

      final hasUnread = state.conversation.hasUnread(_currentUser.userId);
      if (hasUnread) {
        final readMessageIndex = state.conversation
            .getParticipant(_currentUser.userId)!
            .readMessageIndex;

        await _chatRepository.loadMoreMessages(
          _conversationId,
          LoadingType.INITIAL,
          readMessageIndex == 0 ? 1 : readMessageIndex,
          state.conversation.firstMessageIndex,
          state.conversation.lastMessageIndex,
          limit: 100, // 明确指定加载100条消息
        );
      } else {
        if (state.messages.isEmpty) {
          // 有消息，定位到最新消息
          await _chatRepository.loadMoreMessages(
            _conversationId,
            LoadingType.INITIAL,
            -1, // -1 代表从最新消息开始加载
            state.conversation.firstMessageIndex,
            state.conversation.lastMessageIndex,
            limit: 100, // 明确指定加载100条消息
          );
        }
      }
    } catch (error) {
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

  /// 发送语音消息
  Future<void> sendVoiceMessage(String localPath, int duration,
      {String? mediaUrl}) async {
    _logger.d('发送语音消息',
        extra: {
          'conversationId': _conversationId,
          'duration': duration,
          'localPath': localPath,
        },
        stackTrace: StackTrace.current);

    if (isClosed) return;

    // 验证输入
    if (localPath.trim().isEmpty || duration <= 0) {
      _logger.w('尝试发送无效语音消息');
      return;
    }

    try {
      // 1. 设置发送状态
      if (!isClosed) {
        emit(state.copyWith(isSending: true));
      }

      // 2. 直接通过ChatRepositorySend发送语音消息
      final message = await _chatRepositorySend.sendVoiceMessage(
        _conversationId,
        localPath.trim(),
        duration,
        mediaUrl: mediaUrl,
      );

      _logger.i('语音消息发送请求已提交', extra: {
        'messageId': message.messageId,
        'conversationId': _conversationId,
        'duration': duration,
      });

      // 💢💢💢 关键：不需要手动更新UI，数据库监听会自动处理
    } catch (error) {
      _logger.e('发送语音消息失败', error: error);

      // 设置错误状态
      if (!isClosed) {
        emit(state.copyWith(errorMessage: '语音消息发送失败: ${error.toString()}'));
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

    _mergeMessages([message], LoadingType.ADD);

    _logger.d('消息已添加到UI', extra: {
      'messageId': message.messageId,
      'totalMessages': state.messages.length,
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
          pendingMessages: [], // 清空暂存消息
        ));
      }

      // 离开会话时保存状态快照（只保存滚动位置附近的消息）
      if (state.messages.isNotEmpty) {
        final nearbyMessages = _getMessagesAroundScrollPosition();
        final snapshot = ChatStateSnapshot(
          messages: nearbyMessages,
          currentScrollPosition: state.currentScrollPosition,
        );

        await _chatsRepository.saveStateSnapshot(snapshot, _conversationId);

        _logger.d('离开会话时保存状态快照', extra: {
          'conversationId': _conversationId,
          'totalMessageCount': state.messages.length,
          'savedMessageCount': nearbyMessages.length,
          'scrollPosition':
              state.currentScrollPosition.getListIndex(state.messages),
        });
      }

      // 通知服务器用户离开会话房间
      await _chatRepository.leaveConversationRoom(_conversationId);

      _logger.i('会话离开完成，同步状态已重置');
    } catch (error) {
      _logger.e('离开会话失败', error: error);
      // 即使出错也要重置同步状态
      if (!isClosed) {
        emit(state.copyWith(pendingMessages: []));
      }
    }
  }

  /// 💢💢💢 新增：获取滚动位置附近的消息（前后各25条，共50条）
  List<Message> _getMessagesAroundScrollPosition() {
    const contextSize = 25; // 前后各25条消息

    if (state.messages.isEmpty) {
      return [];
    }

    // 如果没有滚动位置信息，返回最新的50条消息
    if (state.currentScrollPosition.messageId == null) {
      return state.messages.take(50).toList();
    }

    // 查找当前滚动位置对应的消息索引
    final scrollMessageIndex = state.messages.indexWhere(
      (message) => message.messageId == state.currentScrollPosition.messageId,
    );

    // 如果找不到滚动位置消息，返回最新的50条
    if (scrollMessageIndex == -1) {
      return state.messages.take(50).toList();
    }

    // 计算要保存的消息范围
    final startIndex =
        (scrollMessageIndex - contextSize).clamp(0, state.messages.length);
    final endIndex =
        (scrollMessageIndex + contextSize + 1).clamp(0, state.messages.length);

    final nearbyMessages = state.messages.sublist(startIndex, endIndex);

    _logger.d('获取滚动位置附近的消息', extra: {
      'scrollMessageIndex': scrollMessageIndex,
      'startIndex': startIndex,
      'endIndex': endIndex,
      'nearbyMessageCount': nearbyMessages.length,
      'totalMessageCount': state.messages.length,
    });

    return nearbyMessages;
  }

  /// 更新当前滚动位置 💢💢💢💢
  /// 用于保存用户当前的查看位置
  void updateCurrentScrollPosition(Iterable<ItemPosition> positions) {
    if (isClosed || positions.isEmpty || state.messages.isEmpty) {
      return;
    }

    // 💢💢💢 修复：过滤掉日期分隔符的位置，只保留消息位置
    // 由于processedItems包含日期分隔符，我们需要找到真正的消息索引
    final validMessagePositions = positions.where((pos) {
      // 检查当前索引对应的是否为消息项（而非日期分隔符）
      // 这需要根据MessageListProcessor的逻辑来判断
      return _isMessagePosition(pos.index);
    }).toList();

    if (validMessagePositions.isEmpty) {
      return;
    }

    // 获取所有有效位置并按索引排序
    final sortedPositions = validMessagePositions
      ..sort((a, b) => b.index.compareTo(a.index));

    // 选择屏幕中央的消息作为锚点
    final centerPosition = sortedPositions.firstWhere(
      (pos) => pos.itemLeadingEdge <= 0.5 && pos.itemTrailingEdge >= 0.5,
      orElse: () => validMessagePositions.first,
    );

    int isDown = 0;

    // 💢💢💢 将processedItems索引转换为messages索引
    final listIndex =
        _convertProcessedIndexToMessageIndex(centerPosition.index);

    // 💢💢💢 双重检查索引有效性
    if (listIndex >= 0 && listIndex < state.messages.length) {
      final message = state.messages[listIndex];
      final currentScrollPosition = CurrentScrollPosition.fromAnchor(
        messageId: message.messageId,
        relativePosition: centerPosition.itemLeadingEdge,
      );

      // 💢💢💢 计算滚动方向
      final prevIndex =
          state.currentScrollPosition.getListIndex(state.messages);
      if (prevIndex >= 0) {
        isDown = prevIndex - listIndex; // 使用UI列表索引比较
      }

      if (!isClosed) {
        _logger.i('更新当前滚动位置', extra: {
          'currentScrollPosition': currentScrollPosition,
          'currentScrollPositionMessageID': currentScrollPosition.messageId,
        });
        emit(state.copyWith(
          currentScrollPosition: currentScrollPosition,
        ));
      }
    }

    if (!state.isSearchMode &&
        !state.isCleaningMessages &&
        !state.isLoadingMessages &&
        !state.isLoadingMoreMessages &&
        !state.isLoadingMoreMessagesBefore &&
        !state.isLoadingMoreMessagesAfter &&
        !state.isFetching &&
        state.messages.isNotEmpty) {
      // 搜索模式、清理消息、同步中或正在加载时不触发
      _checkAndLoadMoreMessages(sortedPositions, isDown);
    }

    _updateReadStatus(sortedPositions);
  }

  /// 💢💢💢 检查位置是否对应消息项（而非日期分隔符）
  bool _isMessagePosition(int processedIndex) {
    // 根据MessageListProcessor的逻辑，我们需要计算有多少个日期分隔符在此索引之前
    // 一个简单的方法是检查processedItems，但这里我们使用更直接的方法

    // 如果没有消息，则肯定不是消息位置
    if (state.messages.isEmpty) return false;

    // 根据MessageListProcessor的逻辑：
    // - 消息和日期分隔符交替出现
    // - 对于每个日期组，消息在前，日期分隔符在后
    // 所以我们可以通过计算消息数量来判断

    final messageCount = state.messages.length;
    // 根据MessageListProcessor的实现，每个日期组都会有一个分隔符
    // 但这个计算比较复杂，我们采用更直接的方法

    // 先估算：如果索引超过了消息数量的两倍，肯定有问题
    if (processedIndex >= messageCount * 2) return false;

    // 将processedIndex转换为messageIndex，看是否有效
    final messageIndex = _convertProcessedIndexToMessageIndex(processedIndex);
    return messageIndex >= 0 && messageIndex < messageCount;
  }

  /// 💢💢💢 将processedItems索引转换为messages索引
  int _convertProcessedIndexToMessageIndex(int processedIndex) {
    if (state.messages.isEmpty) return -1;

    // 💢💢💢 新策略：根据MessageListProcessor的逻辑重新计算
    // 我们知道processedItems包含消息和日期分隔符
    // 直接模拟MessageListProcessor.processMessages的逻辑

    int currentProcessedIndex = 0;

    for (int messageIndex = 0;
        messageIndex < state.messages.length;
        messageIndex++) {
      // 当前消息对应的processed index
      if (currentProcessedIndex == processedIndex) {
        return messageIndex;
      }

      currentProcessedIndex++; // 消息本身占用一个位置

      // 检查是否需要插入日期分隔符（复制MessageListProcessor的逻辑）
      final message = state.messages[messageIndex];
      final currentMessageDate = DateTime(
        message.createdAt.year,
        message.createdAt.month,
        message.createdAt.day,
      );

      // 查看下一条消息的日期
      if (messageIndex + 1 < state.messages.length) {
        final nextMessage = state.messages[messageIndex + 1];
        final nextMessageDate = DateTime(
          nextMessage.createdAt.year,
          nextMessage.createdAt.month,
          nextMessage.createdAt.day,
        );

        // 如果下一条消息的日期不同，则在当前消息后插入日期分隔符
        if (currentMessageDate != nextMessageDate) {
          currentProcessedIndex++; // 日期分隔符占用一个位置
        }
      } else {
        // 这是最后一条消息（最旧的消息），总是添加日期分隔符
        currentProcessedIndex++; // 日期分隔符占用一个位置
      }
    }

    return -1; // 无效索引
  }

  /// 💢💢💢 新增：检查并加载更多消息
  void _checkAndLoadMoreMessages(
      List<ItemPosition> sortedPositions, int isDown) {
    // 💢💢💢 修复：转换索引后再访问messages
    final firstMessageIndex =
        _convertProcessedIndexToMessageIndex(sortedPositions.first.index);
    final lastMessageIndex =
        _convertProcessedIndexToMessageIndex(sortedPositions.last.index);

    if (firstMessageIndex < 0 ||
        lastMessageIndex < 0 ||
        firstMessageIndex >= state.messages.length ||
        lastMessageIndex >= state.messages.length) {
      return; // 索引无效，直接返回
    }

    final firstVisibleMessageIndex =
        state.messages[firstMessageIndex].messageIndex;
    final lastVisibleMessageIndex =
        state.messages[lastMessageIndex].messageIndex;

    // 会话的消息索引范围 messages.first 最新消息 messages.last 最晚消息
    final messagesUpIndex = state.messages.last.messageIndex;
    final messagesDownIndex = state.messages.first.messageIndex;

    _logger.i('检查并加载更多消息', extra: {'isDown': isDown});
    if (isDown > 0) {
      if (firstVisibleMessageIndex - 10 < messagesUpIndex &&
          messagesUpIndex > state.conversation.firstMessageIndex) {
        _logger.w('加载历史消息', extra: {"messageIndex": firstVisibleMessageIndex});
        _chatRepository.loadMoreMessages(
          _conversationId,
          LoadingType.LOAD_MORE_BEFORE, // 向上加载历史消息
          messagesUpIndex,
          state.conversation.firstMessageIndex,
          state.conversation.lastMessageIndex,
        );
      }
    } else {
      if (lastVisibleMessageIndex + 10 > messagesDownIndex &&
          messagesDownIndex < state.conversation.lastMessageIndex) {
        _logger.w('加载新消息', extra: {"messageIndex": lastVisibleMessageIndex});
        _chatRepository.loadMoreMessages(
          _conversationId,
          LoadingType.LOAD_MORE_AFTER, // 向下加载新消息
          messagesDownIndex,
          state.conversation.firstMessageIndex,
          state.conversation.lastMessageIndex,
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

      _logger.i('增量加载并跳转完成', extra: {
        'targetIndex': targetIndex + 1,
        'originalMessageCount': state.messages.length,
        'newMessageCount': result.messages.length,
        'mergedMessageCount': mergedMessages.length,
        'loadedRange':
            '${result.timeRange.start.toIso8601String()} - ${result.timeRange.end.toIso8601String()}',
      });
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

  ///💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢 设置Stream监听 💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢

  void _setupRepositoryListeners() {
    try {
      _logger.i('设置Repository Stream监听',
          extra: {'conversationId': _conversationId});

      // 💢💢💢 核心：监听消息更新事件（替代数据库监听）
      _subscriptions['messageUpdates'] =
          _chatRepository.getMessageUpdateStream(_conversationId).listen(
        _handleMessageUpdate,
        onError: (error) {
          _logger.e('消息更新事件监听出错', error: error);
        },
      );

      // 💢💢💢 监听会话级加载状态变化
      _subscriptions['conversationLoadingUpdates'] = _chatRepository
          .getConversationLoadingStateStream(_conversationId)
          .listen(
        _handleConversationLoadingState,
        onError: (error) {
          _logger.e('会话级加载状态监听出错', error: error);
        },
      );

      // 🔥 新增：监听当前会话的元数据变化（会话名称、头像等）
      // 这样ChatPage就能同步获取ChatsPage中会话的更新
      _subscriptions['conversationMetadata'] =
          _chatsRepository.watchConversation(_conversationId).listen(
        _handleConversationMetadataUpdate,
        onError: (error) {
          _logger.e('会话元数据监听出错', error: error);
        },
      );

      // 保留必要的网络事件监听（如输入状态）
      _subscriptions['typingStatus'] =
          _chatRepository.getTypingStatusStream().listen(
        _handleTypingStatus,
        onError: (error) {
          _logger.e('输入状态监听出错', error: error);
        },
      );

      _logger.i('Repository Stream监听设置完成');
    } catch (error) {
      _logger.e('设置Repository Stream监听失败', error: error);
    }
  }

  /// 核心：处理消息更新事件（新Stream架构）
  void _handleMessageUpdate(MessageUpdateEvent event) {
    if (isClosed) return;

    _logger.d('处理消息更新事件', extra: {
      'conversationId': event.conversationId,
      'eventType': event.runtimeType.toString(),
      'timestamp': event.timestamp.toIso8601String(),
    });

    switch (event) {
      case MessageAddedEvent(:final newMessages, :final loadingType):
        _mergeMessages(newMessages, loadingType);
        break;

      case MessageUpdatedEvent(:final messageId, :final updatedFields):
        _updateMessageFields(messageId, updatedFields);
        break;

      case UpdateSendEvent(
          :final tempId,
          :final messageId,
          :final messageIndex
        ):
        _handleMessageSendUpdate(tempId, messageId, messageIndex);
        break;
    }
  }

  /// 💢💢💢 新增：基于messageId和字段映射更新消息
  void _updateMessageFields(
      String messageId, Map<String, dynamic> updatedFields) {
    final currentMessages = List<Message>.from(state.messages);
    final messageIndex =
        currentMessages.indexWhere((msg) => msg.messageId == messageId);

    if (messageIndex == -1) {
      _logger.w('要更新的消息未找到', extra: {'messageId': messageId});
      return;
    }

    final message = currentMessages[messageIndex];

    // 应用字段更新
    for (final entry in updatedFields.entries) {
      switch (entry.key) {
        case 'status':
          if (entry.value is String) {
            // 将字符串转换为MessageStatus枚举
            try {
              message.status = MessageStatus.values.firstWhere(
                (status) => status.name == entry.value,
                orElse: () => message.status,
              );
            } catch (e) {
              _logger.w('无效的消息状态值', extra: {'status': entry.value});
            }
          }
          break;
        case 'updatedAt':
          if (entry.value is String) {
            try {
              message.updatedAt = DateTime.parse(entry.value);
            } catch (e) {
              _logger.w('无效的更新时间格式', extra: {'updatedAt': entry.value});
            }
          }
          break;
        // 可以根据需要添加更多字段的处理
      }
    }

    // 更新状态
    emit(state.copyWith(
      messages: currentMessages,
      messageUpdateTrigger: state.messageUpdateTrigger + 1,
    ));

    _logger.d('消息字段更新完成', extra: {
      'messageId': messageId,
      'updatedFields': updatedFields.keys.toList(),
    });
  }

  /// 💢💢💢 新增：处理消息发送更新事件
  void _handleMessageSendUpdate(
      String tempId, String newMessageId, int messageIndex) {
    final currentMessages = List<Message>.from(state.messages);
    final messageIndexInList =
        currentMessages.indexWhere((msg) => msg.messageId == tempId);

    if (messageIndexInList == -1) {
      _logger.w('要更新的临时消息未找到', extra: {'tempId': tempId});
      return;
    }

    final message = currentMessages[messageIndexInList];

    // 更新消息ID、索引和状态
    message.messageId = newMessageId;
    message.messageIndex = messageIndex;
    message.status = MessageStatus.sent;
    message.updatedAt = DateTime.now();

    // 更新状态
    emit(state.copyWith(
      messages: currentMessages,
      messageUpdateTrigger: state.messageUpdateTrigger + 1,
    ));

    _logger.d('消息发送更新完成', extra: {
      'tempId': tempId,
      'newMessageId': newMessageId,
      'messageIndex': messageIndex,
    });
  }

  /// 💢💢💢 统一的消息合并方法：排序 + 去重 + 定位
  void _mergeMessages(List<Message> newMessages, LoadingType loadingType) {
    if (newMessages.isEmpty) return;

    final currentMessages = state.messages;

    // 1. 合并消息：当前消息 + 新消息
    final allMessages = [...currentMessages, ...newMessages];

    // 2. 去重：基于messageId去重，保留最新的消息
    final messageMap = <String, Message>{};
    for (final message in allMessages) {
      final existing = messageMap[message.messageId];
      if (existing == null ||
          (message.updatedAt != null &&
              existing.updatedAt != null &&
              message.updatedAt!.isAfter(existing.updatedAt!))) {
        messageMap[message.messageId] = message;
      }
    }

    // 3. 排序：按messageIndex降序（最新消息在前）
    final mergedMessages = messageMap.values.toList()
      ..sort((a, b) => b.messageIndex.compareTo(a.messageIndex));

    _logger.d('消息合并完成', extra: {
      'originalCount': currentMessages.length,
      'newCount': newMessages.length,
      'mergedCount': mergedMessages.length,
      'loadingType': loadingType.toString(),
    });

    // 4. 根据loadingType决定是否需要定位
    final targetMessageId =
        _getTargetMessageIdForLoadingType(loadingType, newMessages);

    // 5. 更新状态（包含可选的滚动定位）
    emit(state.copyWith(
      messages: mergedMessages,
      messageUpdateTrigger: state.messageUpdateTrigger + 1,
      currentScrollPosition: targetMessageId != null
          ? CurrentScrollPosition.fromAnchor(messageId: targetMessageId)
          : state.currentScrollPosition,
    ));
  }

  /// 💢💢💢 根据LoadingType确定目标定位消息ID
  String? _getTargetMessageIdForLoadingType(
      LoadingType loadingType, List<Message> newMessages) {
    if (newMessages.isEmpty) return null;

    switch (loadingType) {
      case LoadingType.INITIAL:
        // 初始加载：智能定位策略
        // 1. 如果有未读消息，定位到第一条未读消息
        final hasUnread = state.conversation.hasUnread(_currentUser.userId);
        if (hasUnread) {
          var readMessageIndex = state.conversation
              .getParticipant(_currentUser.userId)!
              .readMessageIndex;
          readMessageIndex = readMessageIndex == 0 ? 1 : readMessageIndex;
          final lastReadMessageID = newMessages
              .where((msg) => msg.messageIndex == readMessageIndex)
              .firstOrNull
              ?.messageId;

          if (lastReadMessageID != null) {
            return lastReadMessageID;
          }
        }

        // 2. 没有未读消息或找不到未读消息，定位到最新消息
        return newMessages
            .reduce((a, b) => a.messageIndex > b.messageIndex ? a : b)
            .messageId;

      case LoadingType.ADD:
        // 添加单个消息：智能定位策略
        if (newMessages.length == 1) {
          final newMessage = newMessages.first;
          // 如果是最新消息（索引最大），并且用户可能在底部，则定位到新消息
          final isNewestMessage = newMessages
              .every((msg) => newMessage.messageIndex >= msg.messageIndex);
          if (isNewestMessage) {
            return newMessage.messageId;
          }
        }
        return null; // 不是单条最新消息，保持当前位置

      case LoadingType.SEARCH:
        // 搜索消息：定位到第一个搜索结果
        return newMessages.isNotEmpty ? newMessages.first.messageId : null;

      case LoadingType.LOAD_MORE_BEFORE:
      case LoadingType.LOAD_MORE_AFTER:
        // 加载更多、更新、刷新：保持当前位置，不主动定位
        return null;
    }
    return null;
  }

  /// 💢💢💢 处理会话级加载状态更新（新Stream架构）
  void _handleConversationLoadingState(LoadingStateUpdate update) {
    if (isClosed) return;

    _logger.d('处理会话级加载状态更新', extra: {
      'conversationId': update.conversationId,
      'loadingType': update.loadingType.toString(),
      'isLoading': update.isLoading,
      'error': update.error,
    });

    switch (update.loadingType) {
      case LoadingType.INITIAL:
        emit(state.copyWith(isLoadingMessages: update.isLoading));
        break;
      case LoadingType.LOAD_MORE_BEFORE:
      case LoadingType.LOAD_MORE_AFTER:
        emit(state.copyWith(isLoadingMoreMessages: update.isLoading));
        break;
      case LoadingType.SEARCH:
        emit(state.copyWith(isSearching: update.isLoading));
        break;
      case LoadingType.ADD:
        emit(state.copyWith(isSending: update.isLoading));
        break;
      case LoadingType.UPDATE:
      case LoadingType.UPDATE_SEND:
        emit(state.copyWith(isFetching: update.isLoading));
        break;
    }

    if (update.error != null) {
      emit(state.copyWith(errorMessage: update.error));
    }
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

  /// 💢💢💢 新增：更新已读状态（独立方法）
  void _updateReadStatus(List<ItemPosition> sortedPositions) {
    if (sortedPositions.isEmpty) return;

    // 💢💢💢 修复：转换索引后再访问messages
    final lastPosition = sortedPositions.last;
    final lastMessageIndex =
        _convertProcessedIndexToMessageIndex(lastPosition.index);

    if (lastMessageIndex < 0 || lastMessageIndex >= state.messages.length) {
      return; // 索引无效，直接返回
    }

    final lastShowMessage = state.messages[lastMessageIndex];

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

    if (lastShowMessage.messageIndex > lastReadMessageIndex) {
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

  /// 🔥 新增：处理会话元数据更新
  /// 当ChatsPage中的会话信息更新时，同步更新ChatPage中的会话状态
  void _handleConversationMetadataUpdate(Conversation? updatedConversation) {
    if (isClosed || updatedConversation == null) return;

    _logger.d('会话元数据更新', extra: {
      'conversationId': updatedConversation.conversationId,
      'name': updatedConversation.name,
      'avatar': updatedConversation.avatar,
      'lastMessagePreview': updatedConversation.lastMessagePreview,
    });

    // 更新ChatPage中的会话状态，确保与ChatsPage同步
    emit(state.copyWith(conversation: updatedConversation));
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
