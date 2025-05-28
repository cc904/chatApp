import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/features/home/domain/repositories/home_repository.dart';
import 'package:cc/features/home/data/repositories/home_repository_impl.dart';
import 'package:cc/core/database/models/user.dart';
import 'package:cc/core/database/models/message.dart';
import 'package:cc/core/database/models/conversation.dart';
import 'package:cc/features/chat/domain/entities/conversation_update_event.dart';
import 'package:cc/core/proto/generated/user.pb.dart';
import 'package:cc/features/contacts/domain/repositories/contacts_repository.dart';
import 'package:cc/features/contacts/data/repositories/contacts_repository_impl.dart';
import 'package:cc/features/chat/domain/repositories/chat_repository.dart';
import 'package:cc/features/chat/data/repositories/chat_repository_impl.dart';

import 'home_state.dart';

/// HomePage的业务逻辑控制器
/// 负责管理主页相关的状态和业务逻辑
/// 直接管理三个核心仓库：HomeRepository、ChatRepository和ContactsRepository
class HomeCubit extends Cubit<HomeState> {
  final HomeRepository _homeRepository;
  final ChatRepository _chatRepository;
  final ContactsRepository _contactsRepository;
  final LogService _logger = LogService.instance;
  final CurrentUserProto _currentUser;

  // 保存订阅，以便在dispose时取消
  final Map<String, StreamSubscription> _subscriptions = {};

  // 网络连接实例
  final Connectivity _connectivity = Connectivity();

  HomeCubit({required CurrentUserProto currentUserProto})
      : _currentUser = currentUserProto,
        _homeRepository =
            HomeRepositoryImpl(currentUserProto: currentUserProto),
        _chatRepository =
            ChatRepositoryImpl(currentUserProto: currentUserProto),
        _contactsRepository =
            ContactsRepositoryImpl(currentUserProto: currentUserProto),
        super(HomeState.initial());

  /// 初始化用户会话
  ///
  /// 初始化数据库和通信
  Future<void> initUserSession() async {
    try {
      _logger.i('开始初始化用户会话');
      emit(state.toInitializingState());

      // 初始化网络状态监听
      await _initNetworkMonitoring();

      // 初始化各个 Repository
      final homeRepositoryInitialized = await _homeRepository.initUserSession();
      if (!homeRepositoryInitialized) {
        _logger.e('HomeRepository初始化失败');
        emit(state.toErrorState('HomeRepository初始化失败'));
        return;
      } else {
        // 注册事件处理器
        await _chatRepository.registerEventHandlers();
        await _contactsRepository.registerEventHandlers();
      }

      // 设置数据库变化监听
      _setupSubscriptions();

      // 加载初始数据
      await _loadInitialData();

      // 更新状态为已初始化
      emit(state.toInitializedState(currentUserProto: _currentUser));
      _logger.i('用户会话初始化完成');

      // 同步联系人
      syncContacts();
      // 同步会话列表
      syncConversations();
    } catch (error) {
      _logger.e('初始化用户会话失败', error: error, stackTrace: StackTrace.current);
      emit(state.toErrorState(error.toString()));
    }
  }

  /// 设置数据变化订阅
  void _setupSubscriptions() {
    _logger.i('设置数据变化订阅');

    // 取消已有订阅
    for (var subscription in _subscriptions.values) {
      subscription.cancel();
    }
    _subscriptions.clear();

    // 监听会话更新事件
    _subscriptions['conversationUpdates'] =
        _chatRepository.conversationUpdateStream.listen((event) {
      _handleConversationUpdateEvent(event);
    });

    // 初始化时加载所有会话
    _loadConversations();

    // 监听联系人变化
    _subscriptions['contacts'] =
        _contactsRepository.watchContacts().listen((_) {
      _loadContacts();
    });

    // 监听联系人同步状态
    _subscriptions['contactsSyncStatus'] =
        _contactsRepository.syncStatusStream.listen((status) {
      _handleContactsSyncStatus(status);
    });

    // 监听打字状态
    _subscriptions['typingStatus'] =
        _chatRepository.getTypingStatusStream().listen((data) {
      _handleTypingStatus(data);
    });

    // 监听在线状态
    _subscriptions['onlineStatus'] =
        _chatRepository.getOnlineStatusStream().listen((data) {
      _handleOnlineStatus(data);
    });
  }

  /// 处理联系人同步状态
  void _handleContactsSyncStatus(ContactsSyncStatus status) {
    _logger.i('处理联系人同步状态', extra: {'status': status.toString()});

    switch (status) {
      case ContactsSyncStatus.syncing:
        emit(state.copyWith(
          contactsSyncStatus: status,
          contactsErrorMessage: null,
        ));
        break;
      case ContactsSyncStatus.success:
        emit(state.copyWith(
          contactsSyncStatus: status,
          lastContactsSyncTime: DateTime.now(),
          contactsErrorMessage: null,
        ));
        break;
      case ContactsSyncStatus.error:
        emit(state.copyWith(
          contactsSyncStatus: status,
          contactsErrorMessage: '同步联系人失败',
        ));
        break;
      default:
        emit(state.copyWith(contactsSyncStatus: status));
        break;
    }
  }

  /// 加载初始数据
  Future<void> _loadInitialData() async {
    _logger.i('加载初始数据');

    try {
      // 加载会话
      await _loadConversations();

      // 加载联系人
      await _loadContacts();

      // 加载通话记录
      // 通话相关功能已移除
    } catch (error) {
      _logger.e('加载初始数据失败', error: error);
    }
  }

  /// 重试初始化
  Future<void> retryInitialization() async {
    _logger.i('重试初始化');
    if (!state.homePageIsInitializing) {
      await initUserSession();
    }
  }

  // 💢💢💢💢💢💢💢💢💢💢💢💢💢💢 聊天相关 💢💢💢💢💢💢💢💢💢💢💢💢💢💢

  /// 加载所有会话
  Future<void> loadConversations() async {
    await _loadConversations();
  }

  /// 同步会话列表
  /// 从服务器同步最新的会话数据
  Future<void> syncConversations() async {
    _logger.i('同步会话列表');
    try {
      await _chatRepository.syncConversations();
    } catch (error) {
      _logger.e('同步会话失败', error: error);
      emit(state.copyWith(
        errorMessage: '同步会话失败: ${error.toString()}',
      ));
    }
  }

  /// 处理会话更新事件
  /// 根据事件类型直接更新状态，而不需要重新从数据库加载所有会话
  void _handleConversationUpdateEvent(ConversationUpdateEvent event) {
    _logger.d('处理会话更新事件', extra: {
      'conversationId': event.conversationId,
      'type': event.type.toString(),
    });

    // 创建更新和删除的会话ID集合
    final updatedIds = <String>{};
    final removedIds = <String>{};

    switch (event.type) {
      case ConversationUpdateType.added:
      case ConversationUpdateType.updated:
        if (event.conversation != null) {
          // 更新会话列表
          final conversations = List<Conversation>.from(state.conversations);

          // 查找会话索引
          final index = conversations
              .indexWhere((c) => c.conversationId == event.conversationId);

          if (index >= 0) {
            // 如果已存在，则更新
            conversations[index] = event.conversation!;
          } else {
            // 如果不存在，则添加
            conversations.add(event.conversation!);
          }

          // 添加到更新的ID集合
          updatedIds.add(event.conversationId);

          // 更新状态
          emit(state.copyWith(
            conversations: conversations,
            updatedConversationIds: updatedIds,
          ));
        }
        break;

      case ConversationUpdateType.removed:
        // 删除会话
        final conversations = state.conversations
            .where((c) => c.conversationId != event.conversationId)
            .toList();

        // 添加到删除的ID集合
        removedIds.add(event.conversationId);

        // 更新状态
        emit(state.copyWith(
          conversations: conversations,
          removedConversationIds: removedIds,
        ));
        break;
    }
  }

  /// 内部加载会话实现
  Future<void> _loadConversations() async {
    _logger.d('加载所有会话', stackTrace: StackTrace.current);
    try {
      // 只在首次加载时设置 isInitializing
      final isFirstLoad = state.conversations.isEmpty;
      if (isFirstLoad) {
        emit(state.copyWith(homePageIsInitializing: true));
      }

      final conversations = await _chatRepository.getAllConversations();

      // 检查会话列表是否真正变化了
      if (!_areConversationsEqual(state.conversations, conversations)) {
        // 计算更新和删除的会话ID
        final updatedIds = <String>{};
        final removedIds = <String>{};

        // 找出新增和更新的会话
        for (final conversation in conversations) {
          final oldIndex = state.conversations.indexWhere(
              (c) => c.conversationId == conversation.conversationId);

          if (oldIndex >= 0) {
            // 如果已存在，检查是否有变化
            final oldConversation = state.conversations[oldIndex];
            if (oldConversation != conversation) {
              updatedIds.add(conversation.conversationId);
            }
          } else {
            // 新增的会话
            updatedIds.add(conversation.conversationId);
          }
        }

        // 找出删除的会话
        for (final oldConversation in state.conversations) {
          final exists = conversations
              .any((c) => c.conversationId == oldConversation.conversationId);

          if (!exists) {
            removedIds.add(oldConversation.conversationId);
          }
        }

        emit(state.copyWith(
          conversations: conversations,
          homePageIsInitializing:
              isFirstLoad ? false : state.homePageIsInitializing,
          updatedConversationIds: updatedIds,
          removedConversationIds: removedIds,
        ));

        // 初始化过滤后的会话列表
        initFilteredConversations();

        _logger.i(
            '加载会话成功，共 ${conversations.length} 个会话，更新 ${updatedIds.length} 个，删除 ${removedIds.length} 个');
      } else {
        _logger.i('会话数据未变化，跳过更新');
        // 如果是首次加载，但数据没变化，仍然需要更新 isInitializing
        if (isFirstLoad) {
          emit(state.copyWith(homePageIsInitializing: false));
          
          // 初始化过滤后的会话列表
          initFilteredConversations();
        }
      }
    } catch (error) {
      _logger.e('加载会话失败', error: error);
      emit(state.copyWith(
        homePageIsInitializing: false,
        errorMessage: '加载会话失败: ${error.toString()}',
      ));
    }
  }

  /// 比较两个会话列表是否相等
  bool _areConversationsEqual(
      List<Conversation> list1, List<Conversation> list2) {
    if (list1.length != list2.length) return false;

    // 创建会话 ID 到会话的映射，便于快速查找
    final map1 = {for (var conv in list1) conv.conversationId: conv};

    // 检查每个会话的关键字段是否变化
    for (final conv2 in list2) {
      final conv1 = map1[conv2.conversationId];
      if (conv1 == null) return false;

      // 比较关键字段
      if (conv1.lastMessageTime != conv2.lastMessageTime ||
          conv1.unreadCount != conv2.unreadCount ||
          conv1.lastMessagePreview != conv2.lastMessagePreview ||
          conv1.isPinned != conv2.isPinned ||
          conv1.isMuted != conv2.isMuted ||
          conv1.lastReadAt != conv2.lastReadAt) {
        return false;
      }
    }
    return true;
  }

  /// 加载会话消息
  Future<void> loadMessagesForConversation(String conversationId) async {
    _logger.d('加载会话消息',
        extra: {'conversationId': conversationId},
        stackTrace: StackTrace.current);
    try {
      emit(state.copyWith(
          isLoadingMessages: true, currentConversationId: conversationId));

      final messages =
          await _chatRepository.getConversationMessages(conversationId);

      // 创建新的消息映射，保留原有消息，添加新加载的消息
      final updatedMessages =
          Map<String, List<Message>>.from(state.messagesByConversation);
      updatedMessages[conversationId] = messages;

      emit(state.copyWith(
        messagesByConversation: updatedMessages,
        isLoadingMessages: false,
      ));

      // 如果本地没有消息，从服务器获取历史消息
      if (messages.isEmpty) {
        _logger.i('本地没有消息，尝试从服务器获取历史消息');
        await loadHistoryMessagesFromServer(conversationId);
      } else {
        _logger.i('加载会话消息成功，会话 $conversationId，共 ${messages.length} 条消息');
      }
    } catch (error) {
      _logger.e('加载会话消息失败', error: error);
      emit(state.copyWith(
        isLoadingMessages: false,
        errorMessage: '加载消息失败: ${error.toString()}',
      ));
    }
  }

  /// 从服务器加载历史消息
  Future<void> loadHistoryMessagesFromServer(String conversationId,
      {DateTime? before, int limit = 20}) async {
    _logger.d('从服务器加载历史消息', extra: {
      'conversationId': conversationId,
      'before': before?.toIso8601String(),
      'limit': limit
    });
    try {
      emit(state.copyWith(isLoadingMessages: true));

      // 从服务器获取历史消息
      final messages = await _chatRepository
          .fetchHistoryMessages(conversationId, before: before, limit: limit);

      if (messages.isNotEmpty) {
        // 创建新的消息映射，保留原有消息，添加新加载的消息
        final updatedMessages =
            Map<String, List<Message>>.from(state.messagesByConversation);
        final existingMessages = updatedMessages[conversationId] ?? [];

        // 合并消息并按时间排序
        final mergedMessages = [...existingMessages, ...messages];
        mergedMessages.sort(
            (a, b) => b.createdAt.compareTo(a.createdAt)); // 按时间降序排序，最新的在前

        // 去除重复消息
        final uniqueMessages = <Message>[];
        final messageIds = <String>{};
        for (final message in mergedMessages) {
          if (!messageIds.contains(message.messageId)) {
            uniqueMessages.add(message);
            messageIds.add(message.messageId);
          }
        }

        updatedMessages[conversationId] = uniqueMessages;

        emit(state.copyWith(
          messagesByConversation: updatedMessages,
          isLoadingMessages: false,
        ));

        _logger.i('从服务器加载历史消息成功，会话 $conversationId，新加载 ${messages.length} 条消息');
      } else {
        emit(state.copyWith(isLoadingMessages: false));
        _logger.i('服务器没有更多历史消息');
      }
    } catch (error) {
      _logger.e('从服务器加载历史消息失败', error: error);
      emit(state.copyWith(
        isLoadingMessages: false,
        errorMessage: '加载历史消息失败: ${error.toString()}',
      ));
    }
  }

  /// 加载更多历史消息
  Future<void> loadMoreMessagesForConversation(
      String conversationId, DateTime before) async {
    _logger.d('加载更多历史消息', extra: {
      'conversationId': conversationId,
      'before': before.toIso8601String()
    });

    // 先尝试从本地数据库加载
    try {
      emit(state.copyWith(isLoadingMoreMessages: true));

      final messages = await _chatRepository
          .getConversationMessages(conversationId, before: before, limit: 20);

      if (messages.isNotEmpty) {
        // 如果本地有更多消息，则合并到现有消息中
        final updatedMessages =
            Map<String, List<Message>>.from(state.messagesByConversation);
        final existingMessages = updatedMessages[conversationId] ?? [];

        // 合并消息并按时间排序
        final mergedMessages = [...existingMessages, ...messages];
        mergedMessages
            .sort((a, b) => b.createdAt.compareTo(a.createdAt)); // 按时间降序排序

        // 去除重复消息
        final uniqueMessages = <Message>[];
        final messageIds = <String>{};
        for (final message in mergedMessages) {
          if (!messageIds.contains(message.messageId)) {
            uniqueMessages.add(message);
            messageIds.add(message.messageId);
          }
        }

        updatedMessages[conversationId] = uniqueMessages;

        emit(state.copyWith(
          messagesByConversation: updatedMessages,
          isLoadingMoreMessages: false,
        ));

        _logger
            .i('从本地加载更多历史消息成功，会话 $conversationId，新加载 ${messages.length} 条消息');
        return;
      }

      // 如果本地没有更多消息，则从服务器获取
      await loadHistoryMessagesFromServer(conversationId, before: before);
    } catch (error) {
      _logger.e('加载更多历史消息失败', error: error);
      emit(state.copyWith(
        isLoadingMoreMessages: false,
        errorMessage: '加载更多历史消息失败: ${error.toString()}',
      ));
    }
  }

  /// 发送消息
  Future<void> sendMessage(Message message) async {
    _logger.i('发送消息', extra: {'conversationId': message.conversationId});
    try {
      Message sentMessage;

      // 根据消息类型调用不同的发送方法
      switch (message.type) {
        case 'text':
          sentMessage = await _chatRepository.sendTextMessage(
            message.conversationId,
            message.text ?? '',
          );
          break;
        case 'image':
          sentMessage = await _chatRepository.sendImageMessage(
            message.conversationId,
            message.mediaUrl ?? '',
          );
          break;
        case 'voice':
          sentMessage = await _chatRepository.sendVoiceMessage(
            message.conversationId,
            message.mediaUrl ?? '',
            message.duration ?? 0,
          );
          break;
        case 'file':
          sentMessage = await _chatRepository.sendFileMessage(
            message.conversationId,
            message.mediaUrl ?? '',
            message.fileName ?? 'file',
            message.fileSize ?? 0.0,
          );
          break;
        case 'video':
          sentMessage = await _chatRepository.sendVideoMessage(
            message.conversationId,
            message.mediaUrl ?? '',
            message.duration ?? 0,
          );
          break;
        default:
          throw '不支持的消息类型: ${message.type}';
      }

      _logger.i('发送消息成功: ${sentMessage.messageId}');
    } catch (error) {
      _logger.e('发送消息异常', error: error);
      emit(state.copyWith(errorMessage: '发送消息失败: ${error.toString()}'));
    }
  }

  /// 处理打字状态
  void _handleTypingStatus(Map<String, dynamic> data) {
    _logger.i('处理打字状态', extra: data);
    try {
      final conversationId = data['conversationId'] as String?;
      final userId = data['userId'] as String?;
      final isTyping = data['isTyping'] as bool? ?? false;

      if (conversationId == null || userId == null) return;

      // 更新打字状态
      final updatedTypingUsers =
          Map<String, List<String>>.from(state.typingUsers);
      final currentTyping = updatedTypingUsers[conversationId] ?? [];

      if (isTyping && !currentTyping.contains(userId)) {
        updatedTypingUsers[conversationId] = [...currentTyping, userId];
      } else if (!isTyping && currentTyping.contains(userId)) {
        updatedTypingUsers[conversationId] =
            currentTyping.where((id) => id != userId).toList();
      }

      emit(state.copyWith(typingUsers: updatedTypingUsers));
    } catch (error) {
      _logger.e('处理打字状态失败', error: error);
    }
  }

  /// 处理在线状态
  void _handleOnlineStatus(Map<String, dynamic> data) {
    _logger.i('处理在线状态', extra: data);
    try {
      final userId = data['userId'] as String?;
      final isOnline = data['isOnline'] as bool? ?? false;

      if (userId == null) return;

      // 更新在线状态
      final updatedOnlineUsers = Set<String>.from(state.onlineUsers);

      if (isOnline) {
        updatedOnlineUsers.add(userId);
      } else {
        updatedOnlineUsers.remove(userId);
      }

      emit(state.copyWith(onlineUsers: updatedOnlineUsers));
    } catch (error) {
      _logger.e('处理在线状态失败', error: error);
    }
  }

  // 💢💢💢💢💢💢💢💢💢💢💢💢💢💢 联系人相关 💢💢💢💢💢💢💢💢💢💢💢💢💢💢

  /// 加载所有联系人
  Future<void> loadContacts() async {
    await _loadContacts();
  }

  /// 内部加载联系人实现
  Future<void> _loadContacts() async {
    _logger.i('加载所有联系人');
    try {
      emit(state.copyWith(isLoadingContacts: true));
      final contacts = await _contactsRepository.getAllContacts();
      emit(state.copyWith(
        contacts: contacts,
        isLoadingContacts: false,
      ));
      _logger.i('加载联系人成功，共 ${contacts.length} 个联系人');
    } catch (error) {
      _logger.e('加载联系人失败', error: error);
      emit(state.copyWith(
        isLoadingContacts: false,
        contactsErrorMessage: '加载联系人失败: ${error.toString()}',
      ));
    }
  }

  /// 同步联系人
  Future<void> syncContacts() async {
    _logger.i('同步联系人');
    try {
      // 状态更新将由 _handleContactsSyncStatus 处理
      await _contactsRepository.syncContacts();
    } catch (error) {
      _logger.e('同步联系人失败', error: error);
      emit(state.copyWith(
        contactsSyncStatus: ContactsSyncStatus.error,
        contactsErrorMessage: '同步联系人失败: ${error.toString()}',
      ));
    }
  }

  /// 搜索联系人
  Future<List<User>> searchContacts(String query) async {
    _logger.i('搜索联系人', extra: {'query': query});
    try {
      return await _contactsRepository.searchContacts(query);
    } catch (error) {
      _logger.e('搜索联系人失败', error: error);
      return [];
    }
  }

  /// 获取联系人详情
  Future<User?> getContactById(String userId) async {
    _logger.i('获取联系人详情', extra: {'userId': userId});
    try {
      return await _contactsRepository.getContactById(userId);
    } catch (error) {
      _logger.e('获取联系人详情失败', error: error);
      return null;
    }
  }

  /// 添加联系人
  Future<bool> addContact(User contact) async {
    _logger.i('添加联系人', extra: {'contact': contact.name});
    try {
      return await _contactsRepository.addContact(contact);
    } catch (error) {
      _logger.e('添加联系人失败', error: error);
      return false;
    }
  }

  /// 发送好友请求
  Future<bool> sendFriendRequest(String targetUserId, String message) async {
    _logger
        .x('发送好友请求', extra: {'targetUserId': targetUserId, 'message': message});
    try {
      return await _contactsRepository.sendFriendRequest(targetUserId, message);
    } catch (error) {
      _logger.e('发送好友请求失败', error: error);
      return false;
    }
  }

  // 通话相关功能已移除

  // 💢💢💢💢💢💢💢💢💢💢💢💢💢💢 网络状态相关 💢💢💢💢💢💢💢💢💢💢💢💢💢💢

  /// 初始化网络状态监听
  Future<void> _initNetworkMonitoring() async {
    _logger.i('初始化网络状态监听');

    // 检查当前网络状态
    final connectivityResult = await _connectivity.checkConnectivity();
    _updateNetworkStatus(connectivityResult.first);

    // 监听网络状态变化
    _subscriptions['connectivity'] = _connectivity.onConnectivityChanged
        .listen((result) => _handleNetworkChange(result.first));
  }

  /// 处理网络状态变化
  void _handleNetworkChange(ConnectivityResult result) {
    _logger.i('网络状态变化', extra: {'result': result.toString()});
    _updateNetworkStatus(result);
  }

  /// 更新网络状态
  void _updateNetworkStatus(ConnectivityResult result) {
    NetworkStatus networkStatus;
    bool isConnected = false;
    String? errorMessage;

    switch (result) {
      case ConnectivityResult.wifi:
      case ConnectivityResult.mobile:
      case ConnectivityResult.ethernet:
        networkStatus = NetworkStatus.connected;
        isConnected = true;
        errorMessage = null;
        break;
      case ConnectivityResult.none:
        networkStatus = NetworkStatus.disconnected;
        isConnected = false;
        errorMessage = '无网络连接';
        break;
      default:
        networkStatus = NetworkStatus.error;
        isConnected = false;
        errorMessage = '网络连接异常';
    }

    emit(state.copyWith(
      isConnected: isConnected,
      networkStatus: networkStatus,
      lastConnectionTime:
          isConnected ? DateTime.now() : state.lastConnectionTime,
      connectionErrorMessage: errorMessage,
    ));
  }

  /// 检查网络连接
  Future<void> checkNetworkConnection() async {
    _logger.i('检查网络连接');

    try {
      // 先更新为连接中状态
      emit(state.copyWith(
        networkStatus: NetworkStatus.connecting,
      ));

      // 检查当前网络状态
      final connectivityResult = await _connectivity.checkConnectivity();
      _updateNetworkStatus(connectivityResult.first);

      // 如果连接上了，尝试加载数据
      if (state.isConnected) {
        await _loadConversations();
      }
    } catch (error) {
      _logger.e('检查网络连接失败', error: error);
      emit(state.copyWith(
        networkStatus: NetworkStatus.error,
        isConnected: false,
        connectionErrorMessage: '检查网络连接失败: ${error.toString()}',
      ));
    }
  }

  /// 尝试重新连接
  Future<void> reconnect() async {
    _logger.i('尝试重新连接');
    await checkNetworkConnection();
  }

  // 💢💢💢💢💢💢💢💢💢💢💢💢💢💢 个人资料相关 💢💢💢💢💢💢💢💢💢💢💢💢💢💢

  /// 加载用户资料
  // Future<void> loadUserProfile() async {
  //   _logger.i('加载用户资料');
  //   try {
  //     final profile = await _homeRepository.getCurrentUserProfile();
  //     if (profile != null) {
  //       _logger.i('加载用户资料成功: ${profile.name}');
  //     }
  //   } catch (error) {
  //     _logger.e('加载用户资料失败', error: error);
  //   }
  // }

  /// 更新用户状态
  // Future<bool> updateUserStatus(String status) async {
  //   _logger.i('更新用户状态', extra: {'status': status});
  //   try {
  //     return await _homeRepository.updateUserStatus(status);
  //   } catch (error) {
  //     _logger.e('更新用户状态失败', error: error);
  //     return false;
  //   }
  // }

  /// 搜索功能
  void search(String query) {
    _logger.i('执行搜索', extra: {'query': query});
    emit(state.copyWith(
      searchQuery: query,
      isSearching: query.isNotEmpty,
    ));

    if (query.isEmpty) {
      emit(state.copyWith(searchResults: []));
      return;
    }

    try {
      // 简单实现：从当前会话和联系人中搜索
      final results = <dynamic>[];

      // 搜索联系人
      results.addAll(state.contacts.where((contact) =>
          contact.name.toLowerCase().contains(query.toLowerCase())));

      // 搜索会话
      results.addAll(state.conversations.where((conversation) =>
          conversation.lastMessagePreview
              ?.toLowerCase()
              .contains(query.toLowerCase()) ??
          false));

      emit(state.copyWith(searchResults: results));
      _logger.i('搜索结果: ${results.length} 项');
    } catch (error) {
      _logger.e('搜索失败', error: error);
    }
  }

  /// 获取或创建私聊会话
  Future<String?> getOrCreatePrivateConversation(String contactUserId) async {
    _logger.i('获取或创建私聊会话', extra: {'contactUserId': contactUserId});
    try {
      // 使用ChatRepository创建会话
      final conversation =
          await _chatRepository.getOrCreatePrivateConversation(contactUserId);

      // 如果该会话不在当前状态中，添加到状态
      final exists = state.conversations
          .any((c) => c.conversationId == conversation.conversationId);
      if (!exists) {
        final updatedConversations =
            List<Conversation>.from(state.conversations)..add(conversation);
        emit(state.copyWith(conversations: updatedConversations));
      }

      return conversation.conversationId;
    } catch (error) {
      _logger.e('获取或创建会话失败', error: error);
      emit(state.copyWith(errorMessage: '创建会话失败: ${error.toString()}'));
      return null;
    }
  }

  /// 更新会话的静音状态
  Future<void> updateConversationMuteStatus(
      String conversationId, bool isMuted) async {
    _logger.i('更新会话静音状态',
        extra: {'conversationId': conversationId, 'isMuted': isMuted});
    try {
      await _chatRepository.updateConversationMuteStatus(
          conversationId, isMuted);
      // 通过监听数据库变化会自动更新状态，无需在此处手动更新
    } catch (error) {
      _logger.e('更新会话静音状态失败', error: error);
      emit(state.copyWith(
        errorMessage: '更新会话静音状态失败: ${error.toString()}',
      ));
    }
  }

  /// 更新会话的置顶状态
  Future<void> updateConversationPinStatus(
      String conversationId, bool isPinned) async {
    _logger.i('更新会话置顶状态',
        extra: {'conversationId': conversationId, 'isPinned': isPinned});
    try {
      await _chatRepository.updateConversationPinStatus(
          conversationId, isPinned);
      // 通过监听数据库变化会自动更新状态，无需在此处手动更新
    } catch (error) {
      _logger.e('更新会话置顶状态失败', error: error);
      emit(state.copyWith(
        errorMessage: '更新会话置顶状态失败: ${error.toString()}',
      ));
    }
  }

  /// 更新会话的最后阅读时间
  Future<void> updateLastReadAt(String conversationId,
      [DateTime? timestamp]) async {
    final now = timestamp ?? DateTime.now();
    _logger.i('更新会话最后阅读时间',
        extra: {'conversationId': conversationId, 'timestamp': now.toString()});
    try {
      await _chatRepository.updateLastReadAt(conversationId, now);
      // 通过监听数据库变化会自动更新状态，无需在此处手动更新
    } catch (error) {
      _logger.e('更新会话最后阅读时间失败', error: error);
      emit(state.copyWith(
        errorMessage: '更新会话最后阅读时间失败: ${error.toString()}',
      ));
    }
  }

  /// 用户进入会话页面
  Future<void> enterConversation(String conversationId) async {
    _logger.i('用户进入会话页面', extra: {'conversationId': conversationId});
    try {
      // 加入Socket.io会话房间
      await _chatRepository.joinConversationRoom(conversationId);

      // 注册会话事件处理器
      _chatRepository.registerConversationEventHandlers(conversationId);

      // 设置当前会话ID
      emit(state.copyWith(currentConversationId: conversationId));

      // 加载会话消息
      await loadMessagesForConversation(conversationId);

      _logger.i('已进入会话: $conversationId');
    } catch (error) {
      _logger.e('进入会话失败', error: error);
      emit(state.copyWith(
        errorMessage: '进入会话失败: ${error.toString()}',
      ));
    }
  }

  /// 用户离开会话页面
  Future<void> leaveConversation(String conversationId) async {
    _logger.i('用户离开会话页面', extra: {'conversationId': conversationId});
    try {
      // 离开Socket.io会话房间
      await _chatRepository.leaveConversationRoom(conversationId);

      // 移除会话事件处理器
      _chatRepository.unregisterConversationEventHandlers(conversationId);

      // 清除当前会话ID
      if (state.currentConversationId == conversationId) {
        emit(state.copyWith(currentConversationId: null));
      }

      _logger.i('已离开会话: $conversationId');
    } catch (error) {
      _logger.e('离开会话失败', error: error);
      emit(state.copyWith(
        errorMessage: '离开会话失败: ${error.toString()}',
      ));
    }
  }

  /// 标记会话为已读
  Future<void> markConversationAsRead(String conversationId) async {
    _logger.i('标记会话为已读', extra: {'conversationId': conversationId});
    try {
      await _chatRepository.markConversationAsRead(conversationId);

      // 重新加载会话列表以更新未读计数
      await _loadConversations();

      _logger.i('会话已标记为已读: $conversationId');
    } catch (error) {
      _logger.e('标记会话为已读失败', error: error);
      emit(state.copyWith(
        errorMessage: '标记会话为已读失败: ${error.toString()}',
      ));
    }
  }

  /// 更新最后阅读的消息ID
  Future<void> updateLastReadMessageId(
      String conversationId, String messageId) async {
    _logger.i('更新最后阅读的消息ID',
        extra: {'conversationId': conversationId, 'messageId': messageId});
    try {
      // 调用仓库方法更新最后阅读的消息ID
      await _chatRepository.updateLastReadMessageId(conversationId, messageId);

      // 重新加载会话列表以更新状态
      await _loadConversations();

      _logger.i('最后阅读的消息ID已更新: $messageId');
    } catch (error) {
      _logger.e('更新最后阅读的消息ID失败', error: error);
      emit(state.copyWith(
        errorMessage: '更新最后阅读的消息ID失败: ${error.toString()}',
      ));
    }
  }

  /// 搜索会话
  ///
  /// 根据搜索关键词过滤会话列表
  /// 如果搜索关键词为空，则显示所有会话
  void searchConversations(String query) {
    _logger.d('搜索会话: $query');
    
    try {
      // 更新搜索关键词
      emit(state.copyWith(searchQuery: query));
      
      if (query.isEmpty) {
        // 如果搜索关键词为空，则根据当前选中的标签过滤会话
        _filterConversationsByTab(state.selectedTabIndex);
        return;
      }
      
      // 搜索会话和联系人数据
      final lowercaseQuery = query.toLowerCase();
      
      // 根据联系人名称或会话内容搜索
      final filteredList = state.conversations.where((conversation) {
        // 查找会话对应的联系人
        final contact = state.contacts.firstWhere(
          (c) => c.userId == conversation.contactUserId,
          orElse: () => User()..name = '',
        );
        
        // 检查联系人名称、拼音和会话最后消息是否包含搜索关键词
        return contact.name.toLowerCase().contains(lowercaseQuery) ||
            (contact.pinyin?.toLowerCase().contains(lowercaseQuery) ?? false) ||
            (conversation.lastMessagePreview
                    ?.toLowerCase()
                    .contains(lowercaseQuery) ??
                false);
      }).toList();
      
      // 更新过滤后的会话列表
      emit(state.copyWith(filteredConversations: filteredList));
      
      _logger.i('搜索结果: ${filteredList.length} 个会话');
    } catch (e) {
      _logger.e('搜索会话出错', error: e);
      // 出错时显示所有会话
      _filterConversationsByTab(state.selectedTabIndex);
    }
  }
  
  /// 切换标签
  ///
  /// 切换标签并过滤会话列表
  void switchTab(int tabIndex) {
    _logger.d('切换标签: $tabIndex');
    
    // 更新选中的标签索引
    emit(state.copyWith(selectedTabIndex: tabIndex));
    
    // 根据标签过滤会话
    _filterConversationsByTab(tabIndex);
  }
  
  /// 根据标签过滤会话
  ///
  /// 根据选中的标签类型过滤会话列表
  void _filterConversationsByTab(int tabIndex) {
    _logger.d('根据标签过滤会话: $tabIndex');
    
    // 根据标签类型过滤会话
    List<Conversation> filteredList;
    
    switch (tabIndex) {
      case 0: // All Chats
        filteredList = state.conversations;
      case 1: // 私密
        filteredList = state.conversations
            .where((c) => c.type == ConversationType.private)
            .toList();
      case 2: // 群组
        filteredList = state.conversations
            .where((c) => c.type == ConversationType.group)
            .toList();
      case 3: // 频道
        filteredList = state.conversations
            .where((c) => c.type == ConversationType.channel)
            .toList();
      case 4: // 未读
        filteredList = state.conversations.where((c) => c.unreadCount > 0).toList();
      default:
        filteredList = state.conversations;
    }
    
    // 分离置顶和非置顶会话
    final pinnedConversations = filteredList.where((c) => c.isPinned).toList();
    final unpinnedConversations = filteredList.where((c) => !c.isPinned).toList();
    
    // 按最后消息时间排序
    _sortConversationsByTime(pinnedConversations);
    _sortConversationsByTime(unpinnedConversations);
    
    // 重新组合会话列表，置顶会话在前面
    filteredList = [...pinnedConversations, ...unpinnedConversations];
    
    // 更新过滤后的会话列表
    emit(state.copyWith(filteredConversations: filteredList));
  }
  
  /// 按最后消息时间排序会话列表
  void _sortConversationsByTime(List<Conversation> conversations) {
    conversations.sort((a, b) {
      if (a.lastMessageTime == null && b.lastMessageTime == null) {
        return b.createdAt.compareTo(a.createdAt); // 都没有lastMessageTime，按创建时间排序
      } else if (a.lastMessageTime == null) {
        return 1; // a没有lastMessageTime，排在后面
      } else if (b.lastMessageTime == null) {
        return -1; // b没有lastMessageTime，a排在前面
      }
      return b.lastMessageTime!
          .compareTo(a.lastMessageTime!); // 都有lastMessageTime，按时间降序
    });
  }
  
  /// 初始化过滤的会话列表
  ///
  /// 在加载会话列表后调用，初始化过滤后的会话列表
  void initFilteredConversations() {
    _logger.d('初始化过滤的会话列表');
    
    // 如果有搜索关键词，则执行搜索
    if (state.searchQuery.isNotEmpty) {
      searchConversations(state.searchQuery);
    } else {
      // 否则根据当前选中的标签过滤会话
      _filterConversationsByTab(state.selectedTabIndex);
    }
  }
  
  @override
  Future<void> close() {
    _logger.i('关闭HomeCubit');
    // 取消所有订阅
    for (final subscription in _subscriptions.values) {
      subscription.cancel();
    }
    // 取消网络状态监听
    _subscriptions['connectivity']?.cancel();
    _subscriptions.clear();

    // 关闭各个 Repository
    if (_contactsRepository is ContactsRepositoryImpl) {
      (_contactsRepository as ContactsRepositoryImpl).dispose();
    }

    // 如果 ChatRepository 也有 dispose 方法，也在这里调用
    if (_chatRepository is ChatRepositoryImpl) {
      (_chatRepository as ChatRepositoryImpl).dispose();
    }

    // 如果 HomeRepository 也有 dispose 方法，也在这里调用
    if (_homeRepository is HomeRepositoryImpl) {
      (_homeRepository as HomeRepositoryImpl).dispose();
    }

    return super.close();
  }
}
