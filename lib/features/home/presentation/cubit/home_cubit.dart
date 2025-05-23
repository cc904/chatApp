import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/features/home/domain/repositories/home_repository.dart';
import 'package:cc/features/home/data/repositories/home_repository_impl.dart';
import 'package:cc/core/database/models/message.dart';
import 'package:cc/core/database/models/user.dart';
import 'package:cc/core/database/models/conversation.dart';
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

      // 检查是否需要同步联系人
      final lastSyncTime = await _contactsRepository.getLastSyncTime();
      if (lastSyncTime == null ||
          DateTime.now().difference(lastSyncTime).inHours >= 1) {
        syncContacts();
      }

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

    // 监听会话列表变化
    _subscriptions['conversations'] =
        _chatRepository.watchConversations().listen((_) {
      _loadConversations();
    });

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
    _logger.i('联系人同步状态变化', extra: {'status': status.toString()});

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
      // await _loadCallHistory();
    } catch (error) {
      _logger.e('加载初始数据失败', error: error);
    }
  }

  /// 重试初始化
  Future<void> retryInitialization() async {
    _logger.i('重试初始化');
    if (!state.isInitializing) {
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

  /// 内部加载会话实现
  Future<void> _loadConversations() async {
    _logger.i('加载所有会话');
    try {
      emit(state.copyWith(isInitializing: true));
      final conversations = await _chatRepository.getAllConversations();
      emit(state.copyWith(
        conversations: conversations,
        isInitializing: false,
      ));
      _logger.i('加载会话成功，共 ${conversations.length} 个会话');
    } catch (error) {
      _logger.e('加载会话失败', error: error);
      emit(state.copyWith(
        isInitializing: false,
        errorMessage: '加载会话失败: ${error.toString()}',
      ));
    }
  }

  /// 加载会话消息
  Future<void> loadMessagesForConversation(String conversationId) async {
    _logger.d('加载会话消息', extra: {'conversationId': conversationId},stackTrace: StackTrace.current);
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

      // 标记会话为已读
      await _chatRepository.markConversationAsRead(conversationId);

      _logger.i('加载会话消息成功，会话 $conversationId，共 ${messages.length} 条消息');
    } catch (error) {
      _logger.e('加载会话消息失败', error: error);
      emit(state.copyWith(
        isLoadingMessages: false,
        errorMessage: '加载消息失败: ${error.toString()}',
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

  // 💢💢💢💢💢💢💢💢💢💢💢💢💢💢 通话相关 💢💢💢💢💢💢💢💢💢💢💢💢💢💢

  /// 加载通话记录
  Future<void> loadCallHistory() async {
    _logger.i('加载通话记录');
    try {
      emit(state.copyWith(isLoadingCalls: true));

      // 如果有实际的通话记录加载逻辑，应该在这里实现
      // 目前使用模拟数据
      await Future.delayed(const Duration(milliseconds: 500)); // 模拟网络延迟

      // 模拟通话记录数据
      // final mockCalls = await _homeRepository.getCallHistory();

      // emit(state.copyWith(
      //   calls: mockCalls,
      //   isLoadingCalls: false,
      // ));

      // _logger.i('通话记录加载成功，共 ${mockCalls.length} 条记录');
    } catch (error) {
      _logger.e('加载通话记录失败', error: error);
      emit(state.copyWith(
        isLoadingCalls: false,
        errorMessage: '加载通话记录失败: ${error.toString()}',
      ));
    }
  }

  /// 发起通话
  // Future<bool> initiateCall(String contactId, bool isVideo) async {
  //   _logger.i('发起通话', extra: {'contactId': contactId, 'isVideo': isVideo});
  //   try {
  //     return await _homeRepository.initiateCall(contactId, isVideo);
  //   } catch (error) {
  //     _logger.e('发起通话失败', error: error);
  //     return false;
  //   }
  // }

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

  @override
  Future<void> close() {
    _logger.i('关闭HomeCubit');
    // 取消所有订阅
    for (var subscription in _subscriptions.values) {
      subscription.cancel();
    }
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
