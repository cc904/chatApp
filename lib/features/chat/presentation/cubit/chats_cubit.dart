import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cc/core/database/drift_database.dart';
import 'package:cc/core/adapters/conversation_adapter.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/services/communication_service.dart';
import 'package:cc/core/services/proto_socket_service.dart';
import 'package:cc/features/chat/domain/repositories/chats_repository.dart';
import 'package:cc/features/chat/presentation/cubit/chats_state.dart';
import 'package:cc/features/chat/domain/entities/conversation_update_event.dart';
import 'package:cc/features/chat/domain/entities/conversation_merger.dart';
import 'package:cc/features/contacts/domain/repositories/contacts_repository.dart';

/// 聊天模块的业务逻辑Cubit
class ChatsCubit extends Cubit<ChatsState> {
  final ChatsRepository _chatsRepository;
  final ContactsRepository? contactsRepository;
  final LogService _logger = LogService.instance;

  // 保存订阅，以便在dispose时取消
  final Map<String, StreamSubscription> _subscriptions = {};

  /// 是否允许网络重连时自动同步
  bool _allowNetworkReconnectSync = true;

  ChatsCubit({
    required ChatsRepository chatsRepository,
    required CurrentUser currentUser,
    this.contactsRepository,
  })  : _chatsRepository = chatsRepository,
        super(ChatsState.initial(currentUser)) {
    _init();
  }

  /// 初始化
  Future<void> _init() async {
    _logger.i('初始化聊天模块');

    // 设置stream事件订阅
    await _setupSubscriptions();

    // 初始化重连监听
    _initReconnectListener();
  }

  /// 设置stream事件订阅
  Future<void> _setupSubscriptions() async {
    _logger.i('设置聊天事件订阅');

    // 新架构：监听会话更新事件
    _subscriptions['conversationUpdates'] =
        _chatsRepository.getConversationUpdateStream().listen(
      _handleConversationUpdate,
      onError: (error) {
        _logger.e('会话更新事件监听出错', error: error);
      },
    );
  }

  /// 新架构：处理会话更新事件
  void _handleConversationUpdate(ConversationUpdateEvent event) {
    if (isClosed) return;

    _logger.d('🔔 ChatsPage收到会话更新事件', extra: {
      'eventType': event.runtimeType.toString(),
      'conversationId': event.conversationId,
      'timestamp': event.timestamp.toIso8601String(),
    });

    // 使用ConversationMerger处理会话更新
    final updatedConversations = ConversationMerger.handleConversationUpdate(
      state.conversations,
      event,
    );

    // 更新状态并应用过滤器
    _updateConversationsWithFilter(updatedConversations);
  }

  /// 统一的会话列表更新方法
  /// 更新会话列表并应用当前的过滤器
  /// [conversations] - 新的会话列表
  /// [additionalUpdates] - 额外的状态更新
  void _updateConversationsWithFilter(
    List<Conversation> conversations, {
    ChatsState Function(ChatsState)? additionalUpdates,
  }) {
    // 💢💢💢 新增：记录更新前后的未读数量变化
    final currentUserId = state.currentUser?.userId;
    if (currentUserId != null) {
      _logger.d('🔄 ChatsPage即将更新会话列表', extra: {
        'oldConversationsCount': state.conversations.length,
        'newConversationsCount': conversations.length,
      });
    }

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

    // 💢💢💢 新增：确认状态已更新
    _logger.d('✅ ChatsPage状态已更新', extra: {
      'conversationsCount': newState.conversations.length,
      'filteredConversationsCount': newState.filteredConversations.length,
    });
  }

  /// 加载会话列表
  Future<void> loadConversations() async {
    _logger.i('加载会话列表');
    try {
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
    _logger.i('请求同步会话列表');
    try {
      emit(state.copyWith(
          conversationSyncStatus: ConversationSyncStatus.syncing));

      // 调用仓库层的同步方法，数据库更新后会自动触发UI更新
      await _chatsRepository.requestSyncConversations();

      // 同步请求发送成功，状态会在数据库更新时自动变为completed
      emit(state.copyWith(
          conversationSyncStatus: ConversationSyncStatus.completed));
    } catch (error) {
      _logger.e('同步会话失败', error: error);
      emit(state.copyWith(
        conversationSyncStatus: ConversationSyncStatus.error,
        errorMessage: '同步会话失败: ${error.toString()}',
      ));
    }
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
      await _chatsRepository.updateParticipantSettings(
        conversationId,
        muted: isMuted,
      );

      // 更新本地状态
      final currentConversations = List<Conversation>.from(state.conversations);
      final conversationIndex = currentConversations
          .indexWhere((c) => c.conversationId == conversationId);

      if (conversationIndex != -1) {
        // 找到会话，更新静音状态
        final conversation = currentConversations[conversationIndex];
        final currentUserId = state.currentUser?.userId;
        if (currentUserId != null) {
          // 使用扩展方法更新静音状态
          conversation.updateCurrentUserSettings(
            currentUserId: currentUserId,
            muted: isMuted,
          );
          _updateConversationsWithFilter(currentConversations);
        }
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

      if (conversation.type == 'PRIVATE' &&
          conversation.contactUserId != null) {
        // 获取联系人信息
        await contactsRepository!.getContactById(conversation.contactUserId!);
      }
    } catch (error) {
      _logger.e('加载会话联系人失败', error: error);
    }
  }

  /// 重构：移除重连逻辑，改为监听重连成功事件
  /// ChatsCubit 不再负责重连，而是监听重连成功后进行数据同步
  void _initReconnectListener() {
    _logger.i('ChatsCubit: 初始化重连成功监听');

    // 监听重连成功事件
    _subscriptions['reconnectSuccess'] =
        CommunicationService().reconnectSuccessStream.listen((_) {
      _logger.i('ChatsCubit: 收到重连成功通知，检查是否允许自动同步', extra: {
        'allowSync': _allowNetworkReconnectSync,
      });
      
      if (_allowNetworkReconnectSync) {
        _logger.i('网络重连，执行会话同步');
        _syncAfterReconnect();
      } else {
        _logger.d('网络重连自动同步已禁用，跳过会话同步');
      }
    });

    // 监听连接状态变化
    _subscriptions['connectionState'] = CommunicationService()
        .connectionStateStream
        .listen(_handleConnectionStateChange);
  }

  /// 处理连接状态变化
  void _handleConnectionStateChange(SocketConnectionStatus status) {
    _logger.d('ChatsCubit: 连接状态变化', extra: {'status': status.toString()});

    switch (status) {
      case SocketConnectionStatus.connected:
        emit(state.copyWith(
          networkStatus: ChatsState.kNetworkStatusConnected,
          isConnected: true,
          lastConnectionTime: DateTime.now(),
          connectionErrorMessage: null,
        ));
        break;
      case SocketConnectionStatus.connecting:
        emit(state.copyWith(
          networkStatus: ChatsState.kNetworkStatusConnecting,
          isConnected: false,
        ));
        break;
      case SocketConnectionStatus.reconnecting:
        emit(state.copyWith(
          networkStatus: ChatsState.kNetworkStatusConnecting,
          isConnected: false,
        ));
        break;
      case SocketConnectionStatus.disconnected:
      case SocketConnectionStatus.error:
        emit(state.copyWith(
          networkStatus: ChatsState.kNetworkStatusError,
          isConnected: false,
          connectionErrorMessage: '连接已断开',
        ));
        break;
    }
  }

  /// 重连成功后的数据同步
  Future<void> _syncAfterReconnect() async {
    try {
      _logger.i('ChatsCubit: 开始重连后数据同步');

      // 重新同步会话列表
      await requestSyncConversations();

      _logger.i('ChatsCubit: 重连后数据同步完成');
    } catch (error) {
      _logger.e('ChatsCubit: 重连后数据同步失败', error: error);
      emit(state.copyWith(
        connectionErrorMessage: '数据同步失败: ${error.toString()}',
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
        final currentUserId = state.currentUser?.userId;
        if (currentUserId != null) {
          // 过滤掉未加入的频道
          tabFilteredConversations = conversations
              .where((c) => c.type != 'CHANNEL' || ConversationAdapter.isUserInConversation(c.participants, currentUserId))
              .toList();
        } else {
          tabFilteredConversations = conversations;
        }
        break;
      case 1: // 私聊
        tabFilteredConversations = conversations
            .where((c) => c.type == 'PRIVATE')
            .toList();
        break;
      case 2: // 群组
        tabFilteredConversations = conversations
            .where((c) => c.type == 'GROUP')
            .toList();
        break;
      case 3: // 频道
        final currentUserId = state.currentUser?.userId;
        if (currentUserId != null) {
          tabFilteredConversations = conversations
              .where((c) => c.type == 'CHANNEL' && ConversationAdapter.isUserInConversation(c.participants, currentUserId))
              .toList();
        } else {
          tabFilteredConversations = [];
        }
        break;
      case 4: // 未读
        final currentUserId = state.currentUser?.userId;
        if (currentUserId != null) {
          tabFilteredConversations = conversations
              .where((c) => c.unreadCount > 0 && 
                           (c.type != 'CHANNEL'))
              .toList();
        } else {
          tabFilteredConversations = [];
        }
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

    // 使用ConversationMerger进行统一排序
    ConversationMerger.sortConversations(finalFilteredConversations);

    return finalFilteredConversations;
  }

  /// 设置是否允许网络重连时自动同步
  void setNetworkReconnectSyncEnabled(bool enabled) {
    _allowNetworkReconnectSync = enabled;
    _logger.d('ChatsCubit 网络重连自动同步设置', extra: {
      'enabled': enabled,
    });
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
