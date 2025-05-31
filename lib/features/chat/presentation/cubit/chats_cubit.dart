import 'dart:async';

// ignore: depend_on_referenced_packages
import 'package:bloc/bloc.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/features/chat/domain/repositories/chats_repository.dart';
import 'package:cc/features/chat/presentation/cubit/chats_state.dart';
import 'package:cc/core/database/models/conversation.dart';
import 'package:cc/features/chat/domain/entities/conversation_event.dart';
import 'package:cc/features/contacts/domain/repositories/contacts_repository.dart';

/// 聊天模块的业务逻辑Cubit
class ChatsCubit extends Cubit<ChatsState> {
  final ChatsRepository _chatsRepository;
  final ContactsRepository? contactsRepository;
  final LogService _logger = LogService.instance;

  // 保存订阅，以便在dispose时取消
  final Map<String, StreamSubscription> _subscriptions = {};

  ChatsCubit({
    required ChatsRepository chatsRepository,
    this.contactsRepository,
  })  : _chatsRepository = chatsRepository,
        super(ChatsState.initial()) {
    _init();
  }

  /// 初始化
  Future<void> _init() async {
    _logger.i('初始化聊天模块');

    // 设置stream事件订阅
    await _setupSubscriptions();
  }

  /// 设置stream事件订阅
  Future<void> _setupSubscriptions() async {
    _logger.i('设置聊天事件订阅');

    // 监听会话更新
    _subscriptions['conversationUpdate'] =
        _chatsRepository.conversationUpdateStream.listen((event) {
      _handleConversationUpdate(event);
    });

    // 监听新消息
    _subscriptions['newMessage'] =
        _chatsRepository.conversationUpdateStream.listen((event) {
      if (event.type == ConversationUpdateType.updated &&
          event.lastMessagePreview != null) {
        _handleNewMessageFromEvent(event);
      }
    });

    // 监听会话同步
    _subscriptions['conversationSync'] =
        _chatsRepository.conversationSyncStream.listen((event) {
      _handleConversationSync(event);
    });
  }

  /// 统一的会话排序方法
  /// 按最后消息时间倒序排列，没有消息的会话按创建时间排序
  /// [conversations] - 要排序的会话列表
  void _sortConversations(List<Conversation> conversations) {
    // _logger.d('开始对会话进行排序',
    //     extra: {'会话数量': conversations.length}, stackTrace: StackTrace.current);

    conversations.sort((a, b) {
      // 如果两个会话都没有最后消息时间，按创建时间倒序排序
      if (a.lastMessageTime == null && b.lastMessageTime == null) {
        return b.createdAt.compareTo(a.createdAt);
      }
      // 如果 a 没有最后消息时间，排在后面
      if (a.lastMessageTime == null) {
        return 1;
      }
      // 如果 b 没有最后消息时间，排在后面
      if (b.lastMessageTime == null) {
        return -1;
      }
      // 都有最后消息时间，按时间倒序排序（最新的在前）
      return b.lastMessageTime!.compareTo(a.lastMessageTime!);
    });

    // _logger.d('会话排序完成');
  }

  /// 统一的会话列表更新方法
  /// 更新会话列表并应用当前的过滤器
  /// [conversations] - 新的会话列表
  /// [additionalUpdates] - 额外的状态更新
  void _updateConversationsWithFilter(
    List<Conversation> conversations, {
    ChatsState Function(ChatsState)? additionalUpdates,
  }) {
    // 直接应用当前的过滤器（过滤器中会进行排序）
    final filteredConversations = _filterConversations(
        conversations, state.searchQuery, state.selectedTabIndex);

    // 创建基础状态更新
    ChatsState newState = state.copyWith(
      conversations: conversations,
      filteredConversations: filteredConversations,
    );

    // 应用额外的状态更新
    if (additionalUpdates != null) {
      newState = additionalUpdates(newState);
    }

    emit(newState);
  }

  /// 加载会话列表
  Future<void> loadConversations() async {
    _logger.i('加载会话列表');

    try {
      // 从本地数据库加载会话
      final conversations = await _chatsRepository.getAllConversations();
      _updateConversationsWithFilter(conversations);
    } catch (error) {
      _logger.e('加载会话列表失败', error: error);
      emit(state.copyWith(errorMessage: '加载会话列表失败: ${error.toString()}'));
    }
  }

  /// 同步会话列表
  /// 从服务器同步最新的会话数据
  Future<void> requestSyncConversations() async {
    _logger.i('同步会话列表');
    try {
      emit(state.copyWith(
          conversationSyncStatus: ConversationSyncStatus.syncing));

      // 调用仓库层的同步方法
      await _chatsRepository.requestSyncConversations();
    } catch (error) {
      _logger.e('同步会话失败', error: error);
      emit(state.copyWith(
        conversationSyncStatus: ConversationSyncStatus.error,
        errorMessage: '同步会话失败: ${error.toString()}',
      ));
    }
  }

  /// 处理会话同步事件
  void _handleConversationSync(ConversationSyncEvent event) {
    _logger.i('处理会话同步事件', extra: {
      'type': event.type.toString(),
    });

    switch (event.type) {
      case ConversationSyncType.syncStarted:
        emit(state.copyWith(
            conversationSyncStatus: ConversationSyncStatus.syncing,
            errorMessage: null));
        break;
      case ConversationSyncType.syncCompleted:
        final conversations = event.conversations ?? [];
        _updateConversationsWithFilter(conversations,
            additionalUpdates: (state) => state.copyWith(
                conversationSyncStatus: ConversationSyncStatus.completed,
                errorMessage: null));
        break;
      case ConversationSyncType.syncError:
        emit(state.copyWith(
            conversationSyncStatus: ConversationSyncStatus.error,
            errorMessage: '同步会话失败'));
        break;
    }
  }

  /// 处理会话更新事件
  void _handleConversationUpdate(ConversationUpdateEvent event) {
    // _logger.i('处理会话更新事件', extra: {
    //   'conversationId': event.conversationId,
    //   'type': event.type.toString(),
    // });

    switch (event.type) {
      case ConversationUpdateType.added:
        _handleConversationAdded(event);
        break;
      case ConversationUpdateType.updated:
        _handleConversationUpdated(event);
        break;
      case ConversationUpdateType.removed:
        _handleConversationRemoved(event);
        break;
    }
  }

  /// 处理新增会话事件
  void _handleConversationAdded(ConversationUpdateEvent event) {
    if (event.conversation == null) {
      _logger.w('新增会话事件缺少会话对象');
      return;
    }

    // 获取当前会话列表
    final currentConversations = List<Conversation>.from(state.conversations);

    // 检查会话是否已存在
    final existingIndex = currentConversations
        .indexWhere((c) => c.conversationId == event.conversationId);

    if (existingIndex != -1) {
      _logger.w('会话已存在，忽略添加操作');
      return;
    }

    // 添加新会话
    currentConversations.add(event.conversation!);

    _updateConversationsWithFilter(currentConversations);
  }

  /// 处理会话更新事件
  void _handleConversationUpdated(ConversationUpdateEvent event) {
    // 获取当前会话列表
    final currentConversations = List<Conversation>.from(state.conversations);

    // 查找要更新的会话
    final conversationIndex = currentConversations
        .indexWhere((c) => c.conversationId == event.conversationId);

    if (conversationIndex == -1) {
      _logger.w('未找到要更新的会话', extra: {'conversationId': event.conversationId});
      return;
    }

    // 更新会话
    Conversation updatedConversation;

    if (event.conversation != null) {
      // 如果事件中包含完整的会话对象，直接使用
      updatedConversation = event.conversation!;
    } else {
      // 否则，使用现有会话并更新相关字段
      updatedConversation = currentConversations[conversationIndex].copyWith(
        lastMessagePreview: event.lastMessagePreview,
        lastMessageTime: event.lastMessageTime,
        unreadCount: event.unreadCount,
        lastMessageName: event.senderName,
        muted: event.isMuted,
        pinned: event.isPinned,
      );
    }

    // 替换会话
    currentConversations[conversationIndex] = updatedConversation;

    _updateConversationsWithFilter(currentConversations);
  }

  /// 处理会话删除事件
  void _handleConversationRemoved(ConversationUpdateEvent event) {
    // 获取当前会话列表
    final currentConversations = List<Conversation>.from(state.conversations);

    // 移除会话
    currentConversations
        .removeWhere((c) => c.conversationId == event.conversationId);

    _updateConversationsWithFilter(currentConversations);
  }

  /// 处理从事件中获取的新消息
  void _handleNewMessageFromEvent(ConversationUpdateEvent event) {
    // 检查是否有必要的数据
    if (event.lastMessagePreview == null || event.lastMessageTime == null) {
      return;
    }

    // 消息加载由ChatCubit处理
  }

  /// 更新会话静音状态
  ///
  /// [conversationId] - 会话ID
  /// [isMuted] - 是否静音
  Future<void> updateConversationMuteStatus(
      String conversationId, bool isMuted) async {
    _logger.i('更新会话静音状态',
        extra: {'conversationId': conversationId, 'isMuted': isMuted});

    try {
      // 调用仓库层更新静音状态
      await _chatsRepository.updateConversationMuteStatus(
          conversationId, isMuted);

      // 更新本地状态
      final currentConversations = List<Conversation>.from(state.conversations);
      final conversationIndex = currentConversations
          .indexWhere((c) => c.conversationId == conversationId);

      if (conversationIndex != -1) {
        // 找到会话，更新静音状态
        final conversation = currentConversations[conversationIndex];
        final updatedConversation = conversation.copyWith(muted: isMuted);
        currentConversations[conversationIndex] = updatedConversation;

        _updateConversationsWithFilter(currentConversations);
      }
    } catch (error) {
      _logger.e('更新会话静音状态失败', error: error);
      emit(state.copyWith(errorMessage: '更新会话静音状态失败: ${error.toString()}'));
    }
  }

  /// 获取会话中的联系人信息
  Future<void> loadContactsForConversation(String conversationId) async {
    try {
      if (contactsRepository == null) {
        _logger.w('联系人仓库未初始化');
        return;
      }

      final conversation = state.conversations.firstWhere(
        (c) => c.conversationId == conversationId,
        orElse: () => throw Exception('会话不存在'),
      );

      if (conversation.type == ConversationType.private &&
          conversation.contactUserId != null) {
        // 获取联系人信息
        await contactsRepository!.getContactById(conversation.contactUserId!);
      }
    } catch (error) {
      _logger.e('加载会话联系人失败', error: error);
    }
  }

  /// 重新连接
  ///
  /// 当网络断开后重新连接
  Future<void> reconnect() async {
    _logger.i('尝试重新连接');

    try {
      // 更新网络状态为连接中
      emit(state.copyWith(
        networkStatus: ChatsState.kNetworkStatusConnecting,
        isConnected: false,
      ));

      // TODO: 实现实际的重连逻辑，可能需要调用repository中的方法

      // 连接成功后更新状态
      emit(state.copyWith(
        networkStatus: ChatsState.kNetworkStatusConnected,
        isConnected: true,
        lastConnectionTime: DateTime.now(),
        connectionErrorMessage: null,
      ));

      // 重新加载会话列表
      await loadConversations();
    } catch (error) {
      _logger.e('重新连接失败', error: error);
      emit(state.copyWith(
        networkStatus: ChatsState.kNetworkStatusError,
        isConnected: false,
        connectionErrorMessage: '连接失败: ${error.toString()}',
      ));
    }
  }

  /// 搜索会话
  ///
  /// 根据关键词搜索会话
  /// [query] - 搜索关键词
  void searchConversations(String query) {
    _logger.i('搜索会话', extra: {'query': query});

    // 应用搜索过滤器
    final filteredConversations = _filterConversations(
        state.conversations, query, state.selectedTabIndex);

    emit(state.copyWith(
      searchQuery: query,
      filteredConversations: filteredConversations,
    ));
  }

  /// 开始搜索模式
  /// 将状态更新为搜索状态
  void startSearch() {
    _logger.i('开始搜索模式');
    emit(state.copyWith(isSearching: true));
  }

  /// 结束搜索模式
  /// 清除搜索关键词并重置搜索状态
  void endSearch() {
    _logger.i('结束搜索模式');

    final filteredConversations =
        _filterConversations(state.conversations, '', state.selectedTabIndex);

    emit(state.copyWith(
        isSearching: false,
        searchQuery: '',
        filteredConversations: filteredConversations));
  }

  /// 设置选中的标签索引
  ///
  /// 切换会话标签页
  /// [index] - 标签索引
  Future<void> setSelectedTabIndex(int index) async {
    _logger.i('设置选中的标签索引', extra: {'index': index});

    try {
      // 如果标签没有变化，则不做任何操作
      if (state.selectedTabIndex == index) {
        return;
      }

      // 应用新的标签过滤器和当前的搜索过滤器
      final filteredConversations =
          _filterConversations(state.conversations, state.searchQuery, index);

      emit(state.copyWith(
        selectedTabIndex: index,
        filteredConversations: filteredConversations,
      ));
    } catch (error) {
      _logger.e('设置选中的标签索引失败', error: error);
      emit(state.copyWith(errorMessage: '设置选中的标签索引失败: ${error.toString()}'));
    }
  }

  /// 过滤会话
  ///
  /// 根据搜索关键词和标签过滤会话
  /// [conversations] - 要过滤的会话列表
  /// [query] - 搜索关键词
  /// [tabIndex] - 标签索引
  List<Conversation> _filterConversations(
      List<Conversation> conversations, String query, int tabIndex) {
    // 首先按标签过滤会话
    List<Conversation> tabFilteredConversations;
    switch (tabIndex) {
      case 0: // 全部会话
        tabFilteredConversations = conversations;
        break;
      case 1: // 私聊
        tabFilteredConversations = conversations
            .where((c) => c.type == ConversationType.private)
            .toList();
        break;
      case 2: // 群组
        tabFilteredConversations = conversations
            .where((c) => c.type == ConversationType.group)
            .toList();
        break;
      case 3: // 频道
        tabFilteredConversations = conversations
            .where((c) => c.type == ConversationType.channel)
            .toList();
        break;
      case 4: // 未读
        tabFilteredConversations =
            conversations.where((c) => c.unreadCount > 0).toList();
        break;
      default:
        tabFilteredConversations = conversations;
        break;
    }

    List<Conversation> finalFilteredConversations;

    // 如果搜索关键词为空，则直接使用按标签过滤后的会话
    if (query.isEmpty) {
      finalFilteredConversations = tabFilteredConversations;
    } else {
      // 将搜索关键词转换为小写以进行大小写不敏感的搜索
      final String lowerCaseQuery = query.toLowerCase();

      // 在标签过滤的基础上，按搜索关键词过滤
      finalFilteredConversations =
          tabFilteredConversations.where((conversation) {
        // 搜索会话名称
        final bool matchesName =
            conversation.name?.toLowerCase().contains(lowerCaseQuery) ?? false;

        // 搜索最后一条消息预览
        final bool matchesLastMessage = conversation.lastMessagePreview
                ?.toLowerCase()
                .contains(lowerCaseQuery) ??
            false;

        // 返回匹配结果
        return matchesName || matchesLastMessage;
      }).toList();
    }

    // 统一在最后对过滤后的会话进行排序（避免重复排序）
    _sortConversations(finalFilteredConversations);

    return finalFilteredConversations;
  }

  /// 清理资源
  @override
  Future<void> close() async {
    _logger.i('关闭 ChatsCubit');
    for (final subscription in _subscriptions.values) {
      subscription.cancel();
    }
    return super.close();
  }
}
