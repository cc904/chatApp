import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cc/core/services/log_service.dart';

import 'chat_state.dart';
import 'package:cc/core/database/models/user.dart';
import 'package:cc/core/database/models/conversation.dart';
import 'package:cc/core/database/models/message.dart';
import 'package:cc/features/chat/domain/repositories/chat_repository.dart';
import 'package:cc/features/contacts/domain/repositories/contacts_repository.dart';
import 'package:cc/core/database/database_initializer.dart';

/// 聊天Cubit
/// 负责管理聊天相关的状态和业务逻辑
class ChatCubit extends Cubit<ChatState> {
  final ChatRepository _repository;
  final ContactsRepository? _contactsRepository;
  late final LogService _logger;

  // 订阅管理
  StreamSubscription? _conversationsSubscription;
  StreamSubscription? _contactsSubscription;
  final Map<String, StreamSubscription> _messagesSubscriptions = {};

  // 实时通信相关的订阅
  StreamSubscription? _typingStatusSubscription;
  StreamSubscription? _onlineStatusSubscription;
  StreamSubscription? _messageStatusSubscription;
  StreamSubscription? _syncStatusSubscription;

  // 打字状态管理
  final Map<String, Map<String, dynamic>> _typingUsers = {}; // conversationId -> {userId: {isTyping, timestamp}}
  Timer? _typingStatusTimer;
  bool _isUserTyping = false;
  String? _lastTypingConversationId;

  // 标记是否正在加载,避免重复加载
  bool _isLoadingConversations = false;
  // ignore: prefer_final_fields
  Map<String, bool> _isLoadingMessages = {};

  // 标记数据变更的来源
  bool _isSourceOfChange = false;

  // 标记是否已初始化
  bool _isInitialized = false;

  ChatCubit({required ChatRepository repository, ContactsRepository? contactsRepository})
      : _repository = repository,
        _contactsRepository = contactsRepository,
        super(ChatState.initial()) {
    _logger = LogService.instance;
    // 不在构造函数中设置订阅,而是等待initializeSubscriptions调用

    // 设置实时通信相关的订阅
    _setupRealTimeSubscriptions();
  }

  /// 初始化数据库相关订阅
  /// 在确保数据库已初始化后调用此方法
  Future<void> initializeSubscriptions() async {
    if (_isInitialized) return;
    _logger.i('初始化数据库订阅');

    try {
      // 检查数据库是否已初始化
      if (!DatabaseInitializer.isInitialized) {
        _logger.w('数据库尚未初始化,无法设置订阅');
        return;
      }

      // 设置数据库订阅
      _setupSubscriptions();

      // 标记为已初始化
      _isInitialized = true;

      // 初始化后立即加载数据
      await loadConversations();
      await loadContacts();
    } catch (error) {
      _logger.e('初始化订阅失败', error: error, stackTrace: StackTrace.current);
    }
  }

  /// 设置数据变化订阅
  void _setupSubscriptions() {
    _logger.i('设置数据变化订阅');
    // 监听会话列表变化
    _conversationsSubscription?.cancel();
    _conversationsSubscription = _repository.watchConversations().listen((_) {
      // 只有当数据变更不是由自身引起的才重新加载
      if (!_isLoadingConversations && !_isSourceOfChange) {
        loadConversations();
      }
    });

    // 监听联系人变化
    _contactsSubscription?.cancel();
    _contactsSubscription = _repository.watchContacts().listen((_) {
      // 只有当数据变更不是由自身引起的才重新加载
      if (!_isSourceOfChange) {
        loadContacts();
      }
    });
  }

  /// 设置实时通信相关的订阅
  void _setupRealTimeSubscriptions() {
    _logger.i('设置实时通信订阅');

    // 监听打字状态
    _typingStatusSubscription?.cancel();
    _typingStatusSubscription = _repository.getTypingStatusStream().listen((data) {
      _handleTypingStatus(data);
    });

    // 监听在线状态
    _onlineStatusSubscription?.cancel();
    _onlineStatusSubscription = _repository.getOnlineStatusStream().listen((data) {
      _handleOnlineStatus(data);
    });

    // 监听消息状态
    _messageStatusSubscription?.cancel();
    _messageStatusSubscription = _repository.getMessageStatusStream().listen((data) {
      _handleMessageStatus(data);
    });

    // 监听同步状态
    _syncStatusSubscription?.cancel();
    _syncStatusSubscription = _repository.getSyncStatusStream().listen((status) {
      _handleSyncStatus(status);
    });

    // 设置打字状态清理定时器
    _typingStatusTimer?.cancel();
    _typingStatusTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _cleanupTypingStatus();
    });
  }

  /// 处理打字状态
  void _handleTypingStatus(Map<String, dynamic> data) {
    _logger.i('处理打字状态', extra: {'data': data});

    final conversationId = data['conversationId'] as String?;
    final userId = data['userId'] as String?;
    final isTyping = data['isTyping'] as bool? ?? false;
    final timestamp = data['timestamp'] as int? ?? DateTime.now().millisecondsSinceEpoch;

    if (conversationId == null || userId == null) return;

    // 更新打字状态缓存
    if (!_typingUsers.containsKey(conversationId)) {
      _typingUsers[conversationId] = {};
    }

    _typingUsers[conversationId]![userId] = {
      'isTyping': isTyping,
      'timestamp': timestamp,
    };

    // 更新UI状态
    final typingUserIds = _getTypingUserIds(conversationId);
    emit(state.copyWith(
      typingUsers: Map<String, List<String>>.from(state.typingUsers)..update(conversationId, (_) => typingUserIds, ifAbsent: () => typingUserIds),
    ));
  }

  /// 获取当前正在输入的用户ID列表
  List<String> _getTypingUserIds(String conversationId) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final typingTimeout = 10000; // 10秒超时

    return _typingUsers[conversationId]
            ?.entries
            .where((entry) => entry.value['isTyping'] == true && (now - (entry.value['timestamp'] as int)) < typingTimeout)
            .map((entry) => entry.key)
            .toList() ??
        [];
  }

  /// 清理过期的打字状态
  void _cleanupTypingStatus() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final typingTimeout = 10000; // 10秒超时
    bool needsUpdate = false;

    // 检查所有会话
    for (final conversationId in _typingUsers.keys) {
      final userEntries = _typingUsers[conversationId]!;

      // 移除过期的状态
      for (final userId in userEntries.keys.toList()) {
        final data = userEntries[userId]!;
        if (data['isTyping'] == true && (now - (data['timestamp'] as int)) >= typingTimeout) {
          userEntries[userId] = {
            'isTyping': false,
            'timestamp': now,
          };
          needsUpdate = true;
        }
      }
    }

    // 如果有状态变更,更新UI
    if (needsUpdate) {
      final updatedTypingUsers = <String, List<String>>{};

      for (final conversationId in _typingUsers.keys) {
        updatedTypingUsers[conversationId] = _getTypingUserIds(conversationId);
      }

      emit(state.copyWith(typingUsers: updatedTypingUsers));
    }
  }

  /// 处理在线状态
  void _handleOnlineStatus(Map<String, dynamic> data) {
    _logger.i('处理在线状态', extra: {'data': data});

    final userId = data['userId'] as String?;
    final isOnline = data['isOnline'] as bool? ?? false;

    if (userId == null) return;

    // 更新UI状态
    final updatedOnlineUsers = Set<String>.from(state.onlineUsers);
    if (isOnline) {
      updatedOnlineUsers.add(userId);
    } else {
      updatedOnlineUsers.remove(userId);
    }

    emit(state.copyWith(onlineUsers: updatedOnlineUsers));
  }

  /// 处理消息状态
  void _handleMessageStatus(Map<String, dynamic> data) {
    _logger.i('处理消息状态', extra: {'data': data});

    final messageId = data['messageId'] as String?;
    final status = data['status'] as int?;
    final conversationId = data['conversationId'] as String?;

    if (messageId == null || status == null || conversationId == null) return;

    // 获取当前会话的消息
    final messages = state.messagesByConversation[conversationId] ?? [];
    final messageIndex = messages.indexWhere((m) => m.messageId == messageId);

    if (messageIndex >= 0) {
      // 更新消息状态
      final updatedMessages = List<Message>.from(messages);
      final message = updatedMessages[messageIndex];

      // 目前在数据模型中使用字符串表示状态,这里需要转换
      String newStatus;
      switch (status) {
        case 0:
          newStatus = 'sending';
          break;
        case 1:
          newStatus = 'sent';
          break;
        case 2:
          newStatus = 'delivered';
          break;
        case 3:
          newStatus = 'read';
          break;
        case 4:
          newStatus = 'failed';
          break;
        default:
          newStatus = message.status;
      }

      if (message.status != newStatus) {
        message.status = newStatus;

        // 更新UI状态
        emit(state.copyWithMessagesForConversation(conversationId, updatedMessages));
      }
    }
  }

  /// 处理同步状态
  void _handleSyncStatus(SyncStatus status) {
    _logger.i('处理同步状态', extra: {'status': status.toString()});

    // 同步状态变更会通知所有订阅了ChatCubit的Widget
    // 主要在ChatDetailPage和ConversationListPage中使用
    // 用于显示同步进度指示器和错误提示
    emit(state.copyWith(syncStatus: status));
    // 用于在UI上显示同步进度指示器和错误提示
    emit(state.copyWith(syncStatus: status));
  }

  /// 发送正在输入状态
  Future<void> sendTypingStatus(String conversationId, bool isTyping) async {
    // 避免重复发送相同状态
    if (_isUserTyping == isTyping && _lastTypingConversationId == conversationId) {
      return;
    }

    _isUserTyping = isTyping;
    _lastTypingConversationId = conversationId;

    try {
      await _repository.sendTypingStatus(conversationId, isTyping);
    } catch (error) {
      _logger.e('发送输入状态失败', error: error, stackTrace: StackTrace.current);
    }
  }

  /// 加载会话列表
  Future<void> loadConversations() async {
    _logger.i('开始加载会话列表');
    if (_isLoadingConversations) return; // 防止重复加载

    try {
      _isLoadingConversations = true;
      emit(state.copyWithLoading());
      final conversations = await _repository.getAllConversations();
      emit(state.copyWith(
        conversations: conversations,
        isLoading: false,
      ));

      // 为每个会话设置消息监听
      _setupMessageSubscriptions(conversations);

      // 加载每个会话的最近消息 (限制只加载当前选中的会话消息以减少刷新)
      if (state.currentConversationId != null) {
        loadMessagesForConversation(state.currentConversationId!);
      }
    } catch (error) {
      _logger.e('加载会话列表失败', error: error, stackTrace: StackTrace.current);
      // 确保在错误情况下仍然提供空列表，而不是保持加载状态
      emit(state.copyWith(
          conversations: [], // 提供空列表
          isLoading: false,
          error: '加载会话列表失败，请稍后重试'));
    } finally {
      _isLoadingConversations = false;
    }
  }

  /// 为会话设置消息变化监听
  void _setupMessageSubscriptions(List<Conversation> conversations) {
    // 清理不需要的订阅
    final validIds = conversations.map((c) => c.id.toString()).toSet();
    _messagesSubscriptions.keys.where((id) => !validIds.contains(id)).toList().forEach((id) {
      _messagesSubscriptions[id]?.cancel();
      _messagesSubscriptions.remove(id);
      _isLoadingMessages.remove(id); // 清理加载状态标记
    });

    // 只为当前会话添加监听,减少不必要的刷新
    if (state.currentConversationId != null && !_messagesSubscriptions.containsKey(state.currentConversationId)) {
      _messagesSubscriptions[state.currentConversationId!] = _repository.watchConversationMessages(state.currentConversationId!).listen((_) {
        if (!(_isLoadingMessages[state.currentConversationId!] ?? false) && !_isSourceOfChange) {
          loadMessagesForConversation(state.currentConversationId!);
        }
      });
    }
  }

  /// 加载联系人列表
  Future<void> loadContacts() async {
    _logger.i('开始加载联系人列表');
    try {
      emit(state.copyWithLoading());

      List<User> contacts = [];

      // 优先使用ContactsRepository加载联系人
      if (_contactsRepository != null) {
        try {
          contacts = await _contactsRepository.getAllContacts();
        } catch (error) {
          _logger.e('使用ContactsRepository加载联系人失败', error: error, stackTrace: StackTrace.current);
        }
      }

      // 如果ContactsRepository不可用或加载失败,使用ChatRepository
      if (contacts.isEmpty) {
        _logger.w('联系人列表为空');
        contacts = [];
      }

      emit(state.copyWith(
        contacts: contacts,
        isLoading: false,
      ));
    } catch (error) {
      _logger.e('加载联系人列表失败', error: error, stackTrace: StackTrace.current);
      emit(state.copyWithError('加载联系人列表失败: $error'));
    }
  }

  /// 加载指定会话的消息
  Future<void> loadMessagesForConversation(String conversationId, {int limit = 20, DateTime? before}) async {
    _logger.i('开始加载会话消息', extra: {'conversationId': conversationId, 'limit': limit});
    // 防止同一会话的消息并发加载
    if (_isLoadingMessages[conversationId] ?? false) return;

    try {
      _isLoadingMessages[conversationId] = true;

      final messages = await _repository.getConversationMessages(
        conversationId,
        limit: limit,
        before: before,
      );

      // 更新状态 - 处理新加载的消息
      if (before != null) {
        // 加载更多历史消息,合并到现有消息列表
        emit(state.copyWithAdditionalMessagesForConversation(conversationId, messages));
      } else {
        // 初始加载消息,替换现有消息列表
        emit(state.copyWithMessagesForConversation(conversationId, messages));
      }

      // 如果是当前会话,标记为已读
      if (state.currentConversationId == conversationId) {
        markConversationAsRead(conversationId);
      }
    } catch (error) {
      _logger.e('加载会话消息失败', error: error, stackTrace: StackTrace.current);
      // 不影响主UI,仅记录错误
    } finally {
      _isLoadingMessages[conversationId] = false;
    }
  }

  /// 切换当前会话
  Future<void> setCurrentConversation(String conversationId) async {
    try {
      emit(state.copyWith(currentConversationId: conversationId));

      // 添加对当前会话的消息监听
      if (!_messagesSubscriptions.containsKey(conversationId)) {
        _messagesSubscriptions[conversationId] = _repository.watchConversationMessages(conversationId).listen((_) {
          if (!(_isLoadingMessages[conversationId] ?? false) && !_isSourceOfChange) {
            loadMessagesForConversation(conversationId);
          }
        });
      }

      // 加载消息
      await loadMessagesForConversation(conversationId);

      // 标记为已读
      await markConversationAsRead(conversationId);
    } catch (error) {
      _logger.e('切换会话失败', error: error, stackTrace: StackTrace.current);
      emit(state.copyWithError('切换会话失败: $error'));
    }
  }

  /// 标记会话为已读
  Future<void> markConversationAsRead(String conversationId) async {
    try {
      _isSourceOfChange = true;
      await _repository.markConversationAsRead(conversationId);
      _isSourceOfChange = false;
    } catch (error) {
      _logger.e('标记会话已读失败', error: error, stackTrace: StackTrace.current);
      _isSourceOfChange = false;
    }
  }

  /// 搜索联系人
  Future<void> searchContacts(String keyword) async {
    try {
      emit(state.copyWithLoading());

      List<User> results = [];
      // 优先使用ContactsRepository搜索联系人
      if (_contactsRepository != null) {
        try {
          results = await _contactsRepository.searchContacts(keyword);
        } catch (error) {
          _logger.e('使用ContactsRepository搜索联系人失败', error: error, stackTrace: StackTrace.current);
        }
      }

      emit(state.copyWith(
        searchQuery: keyword,
        searchResults: results,
        isLoading: false,
      ));
    } catch (error) {
      _logger.e('搜索联系人失败', error: error, stackTrace: StackTrace.current);
      emit(state.copyWithError('搜索联系人失败: $error'));
    }
  }

  /// 搜索会话
  Future<void> searchConversations(String keyword) async {
    try {
      emit(state.copyWithLoading());

      final results = await _repository.getAllConversations();
      final filteredResults = results
          .where((conversation) =>
              conversation.name?.toLowerCase().contains(keyword.toLowerCase()) == true || conversation.lastMessagePreview?.toLowerCase().contains(keyword.toLowerCase()) == true)
          .toList();

      emit(state.copyWith(
        searchQuery: keyword,
        searchResults: filteredResults,
        isLoading: false,
      ));
    } catch (error) {
      _logger.e('搜索会话失败', error: error, stackTrace: StackTrace.current);
      emit(state.copyWithError('搜索会话失败: $error'));
    }
  }

  /// 搜索消息
  Future<void> searchMessages(String keyword, {String? conversationId}) async {
    try {
      emit(state.copyWithLoading());

      final results = await _repository.searchMessages(keyword, conversationId: conversationId);

      emit(state.copyWith(
        searchQuery: keyword,
        searchResults: results,
        isLoading: false,
      ));
    } catch (error) {
      _logger.e('搜索消息失败', error: error, stackTrace: StackTrace.current);
      emit(state.copyWithError('搜索消息失败: $error'));
    }
  }

  /// 发送文本消息
  Future<void> sendTextMessage(String conversationId, String text) async {
    _logger.i('发送文本消息', extra: {'conversationId': conversationId, 'text': text});
    if (text.trim().isEmpty) return;

    try {
      _isSourceOfChange = true;
      // 发送消息并获取返回的消息对象
      final message = await _repository.sendTextMessage(conversationId, text);

      // 立即更新当前状态中的消息列表,而不是等待数据库通知
      final currentMessages = state.messagesByConversation[conversationId] ?? [];
      final newMessages = [message, ...currentMessages];

      // 直接更新状态
      emit(state.copyWithMessagesForConversation(conversationId, newMessages));

      // 再次加载完整消息列表以确保同步
      await loadMessagesForConversation(conversationId);

      _isSourceOfChange = false;
    } catch (error) {
      _logger.e('发送文本消息失败', error: error, stackTrace: StackTrace.current);
      emit(state.copyWithError('发送消息失败: $error'));
      _isSourceOfChange = false;
    }
  }

  /// 发送图片消息
  Future<void> sendImageMessage(String conversationId, String localPath, {String? mediaUrl}) async {
    _logger.i('发送图片消息', extra: {'conversationId': conversationId, 'imagePath': localPath});
    try {
      _isSourceOfChange = true;
      // 发送消息并获取返回的消息对象
      final message = await _repository.sendImageMessage(conversationId, localPath, mediaUrl: mediaUrl);

      // 立即更新当前状态中的消息列表,而不是等待数据库通知
      final currentMessages = state.messagesByConversation[conversationId] ?? [];
      final newMessages = [message, ...currentMessages];

      // 直接更新状态
      emit(state.copyWithMessagesForConversation(conversationId, newMessages));

      // 再次加载完整消息列表以确保同步
      await loadMessagesForConversation(conversationId);

      _isSourceOfChange = false;
    } catch (error) {
      _logger.e('发送图片消息失败', error: error, stackTrace: StackTrace.current);
      emit(state.copyWithError('发送图片失败: $error'));
      _isSourceOfChange = false;
    }
  }

  /// 发送语音消息
  Future<void> sendVoiceMessage(String conversationId, String localPath, int duration, {String? mediaUrl}) async {
    _logger.i('发送语音消息', extra: {'conversationId': conversationId, 'voicePath': localPath, 'duration': duration});
    try {
      _isSourceOfChange = true;
      // 发送消息并获取返回的消息对象
      final message = await _repository.sendVoiceMessage(conversationId, localPath, duration, mediaUrl: mediaUrl);

      // 立即更新当前状态中的消息列表,而不是等待数据库通知
      final currentMessages = state.messagesByConversation[conversationId] ?? [];
      final newMessages = [message, ...currentMessages];

      // 直接更新状态
      emit(state.copyWithMessagesForConversation(conversationId, newMessages));

      // 再次加载完整消息列表以确保同步
      await loadMessagesForConversation(conversationId);

      _isSourceOfChange = false;
    } catch (error) {
      _logger.e('发送语音消息失败', error: error, stackTrace: StackTrace.current);
      emit(state.copyWithError('发送语音失败: $error'));
      _isSourceOfChange = false;
    }
  }

  /// 发送文件消息
  Future<void> sendFileMessage(String conversationId, String localPath, String fileName, double fileSize, {String? mediaUrl}) async {
    _logger.i('发送文件消息', extra: {'conversationId': conversationId, 'filePath': localPath});
    try {
      _isSourceOfChange = true;
      // 发送消息并获取返回的消息对象
      final message = await _repository.sendFileMessage(conversationId, localPath, fileName, fileSize, mediaUrl: mediaUrl);

      // 立即更新当前状态中的消息列表,而不是等待数据库通知
      final currentMessages = state.messagesByConversation[conversationId] ?? [];
      final newMessages = [message, ...currentMessages];

      // 直接更新状态
      emit(state.copyWithMessagesForConversation(conversationId, newMessages));

      // 再次加载完整消息列表以确保同步
      await loadMessagesForConversation(conversationId);

      _isSourceOfChange = false;
    } catch (error) {
      _logger.e('发送文件消息失败', error: error, stackTrace: StackTrace.current);
      emit(state.copyWithError('发送文件失败: $error'));
      _isSourceOfChange = false;
    }
  }

  /// 发送视频消息
  Future<void> sendVideoMessage(String conversationId, String localPath, int duration, {String? thumbnailUrl, String? mediaUrl, bool isServerProcessed = false}) async {
    _logger.i('发送视频消息', extra: {'conversationId': conversationId, 'videoPath': localPath});
    try {
      _isSourceOfChange = true;
      // 发送消息并获取返回的消息对象
      final message = await _repository.sendVideoMessage(conversationId, localPath, duration, thumbnailUrl: thumbnailUrl, mediaUrl: mediaUrl, isServerProcessed: isServerProcessed);

      // 立即更新当前状态中的消息列表,而不是等待数据库通知
      final currentMessages = state.messagesByConversation[conversationId] ?? [];
      final newMessages = [message, ...currentMessages];

      // 直接更新状态
      emit(state.copyWithMessagesForConversation(conversationId, newMessages));

      // 再次加载完整消息列表以确保同步
      await loadMessagesForConversation(conversationId);

      _isSourceOfChange = false;
    } catch (error) {
      _logger.e('发送视频消息失败', error: error, stackTrace: StackTrace.current);
      emit(state.copyWithError('发送视频失败: $error'));
      _isSourceOfChange = false;
    }
  }

  /// 获取或创建私聊会话
  Future<Conversation> getOrCreatePrivateConversation(String contactUserId) async {
    try {
      _isSourceOfChange = true;
      final result = await _repository.getOrCreatePrivateConversation(contactUserId);
      _isSourceOfChange = false;
      return result;
    } catch (error) {
      _logger.e('获取或创建私聊会话失败', error: error, stackTrace: StackTrace.current);
      _isSourceOfChange = false;
      rethrow;
    }
  }

  /// 创建群聊
  Future<Conversation> createGroupConversation(String name, List<String> memberIds, {String? avatar}) async {
    try {
      _isSourceOfChange = true;
      final result = await _repository.createGroupConversation(name, memberIds, avatar: avatar);
      _isSourceOfChange = false;
      return result;
    } catch (error) {
      _logger.e('创建群聊失败', error: error, stackTrace: StackTrace.current);
      _isSourceOfChange = false;
      rethrow;
    }
  }

  /// 删除消息
  Future<void> deleteMessage(String messageId) async {
    _logger.i('删除消息', extra: {'messageId': messageId});
    try {
      _isSourceOfChange = true;

      // 首先获取要删除的消息,以确定它属于哪个会话
      Message? messageToDelete;
      String? conversationId;

      // 遍历所有会话的消息列表查找该消息
      for (final entry in state.messagesByConversation.entries) {
        final messages = entry.value;
        final message = messages.firstWhere(
          (m) => m.messageId == messageId,
          orElse: () => Message()..messageId = '-1',
        );

        if (message.messageId != '-1') {
          messageToDelete = message;
          conversationId = entry.key;
          break;
        }
      }

      // 调用repository删除消息
      await _repository.deleteMessage(messageId);

      // 如果找到了消息和对应的会话,立即更新UI状态
      if (messageToDelete != null && conversationId != null) {
        // 从消息列表中移除该消息
        final currentMessages = state.messagesByConversation[conversationId] ?? [];
        final newMessages = currentMessages.where((m) => m.messageId != messageId).toList();

        // 更新状态
        emit(state.copyWithMessagesForConversation(conversationId, newMessages));

        // 再次加载会话列表,因为最后一条消息可能已更改
        await loadConversations();
      }

      _isSourceOfChange = false;
    } catch (error) {
      _logger.e('删除消息失败', error: error, stackTrace: StackTrace.current);
      emit(state.copyWithError('删除消息失败: $error'));
      _isSourceOfChange = false;
    }
  }

  /// 删除会话
  Future<void> deleteConversation(String conversationId) async {
    try {
      _isSourceOfChange = true;
      await _repository.deleteConversation(conversationId);
      _isSourceOfChange = false;

      // 如果删除的是当前会话,清空当前会话ID
      if (state.currentConversationId == conversationId) {
        emit(state.copyWith(currentConversationId: null));
      }
    } catch (error) {
      _logger.e('删除会话失败', error: error, stackTrace: StackTrace.current);
      emit(state.copyWithError('删除会话失败: $error'));
      _isSourceOfChange = false;
    }
  }

  /// 清空会话消息
  Future<void> clearConversationMessages(String conversationId) async {
    _logger.i('清除会话消息', extra: {'conversationId': conversationId});
    try {
      _isSourceOfChange = true;
      await _repository.clearConversationMessages(conversationId);

      // 清空当前状态中的会话消息
      emit(state.copyWithMessagesForConversation(conversationId, []));

      // 重新加载会话列表,因为最后一条消息已被清空
      await loadConversations();

      _isSourceOfChange = false;
    } catch (error) {
      _logger.e('清空会话消息失败', error: error, stackTrace: StackTrace.current);
      emit(state.copyWithError('清空会话消息失败: $error'));
      _isSourceOfChange = false;
    }
  }

  /// 添加联系人
  Future<void> addContact(User user) async {
    try {
      // 优先使用ContactsRepository添加联系人
      if (_contactsRepository != null) {
        await _contactsRepository.addContact(user);
      } else {
        _logger.e('无法添加联系人：ContactsRepository未注入');
        throw '无法添加联系人：系统未初始化';
      }
    } catch (error) {
      _logger.e('添加联系人失败', error: error, stackTrace: StackTrace.current);
      emit(state.copyWithError('添加联系人失败: $error'));
    }
  }

  // 添加通过ID获取消息的方法
  Future<Message?> getMessageById(String messageId) async {
    try {
      // 遍历所有会话的消息,查找匹配ID的消息
      for (final entry in state.messagesByConversation.entries) {
        final messages = entry.value;
        for (final message in messages) {
          if (message.messageId == messageId) {
            return message;
          }
        }
      }

      // 如果未找到,返回null
      return null;
    } catch (error) {
      _logger.e('通过ID获取消息失败', error: error, stackTrace: StackTrace.current);
      return null;
    }
  }

  // 加载指定日期前后的消息
  Future<void> loadMessagesAroundDate(String conversationId, DateTime targetDate) async {
    try {
      emit(state.copyWith(isLoading: true));

      // 计算时间范围 - 目标日期当天到目标日期后10天的消息
      final startOfDay = DateTime(targetDate.year, targetDate.month, targetDate.day);
      final endRange = startOfDay.add(const Duration(days: 10));

      // 从数据库加载该日期范围的消息
      final messages = await _repository.getMessagesByDateRange(conversationId, startOfDay, endRange, limit: 50 // 设置合理的限制,避免加载过多消息
          );

      // 如果找不到当天消息,尝试加载一个更大的范围
      if (!messages.any((m) => m.createdAt.year == targetDate.year && m.createdAt.month == targetDate.month && m.createdAt.day == targetDate.day)) {
        // 也加载目标日期前10天的消息
        final extendedStartRange = startOfDay.subtract(const Duration(days: 10));
        final earlierMessages = await _repository.getMessagesByDateRange(conversationId, extendedStartRange, startOfDay, limit: 30);

        // 合并两个范围的消息
        messages.addAll(earlierMessages);
      }

      // 更新状态
      final currentMessages = state.messagesByConversation[conversationId] ?? [];

      // 合并新旧消息,避免重复
      final Map<String, Message> uniqueMessages = {};
      for (var msg in [...currentMessages, ...messages]) {
        uniqueMessages[msg.messageId] = msg;
      }

      final updatedMessages = uniqueMessages.values.toList();

      // 按时间排序
      updatedMessages.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // 更新状态
      final updatedMessagesByConversation = Map<String, List<Message>>.from(state.messagesByConversation);
      updatedMessagesByConversation[conversationId] = updatedMessages;

      emit(state.copyWith(isLoading: false, messagesByConversation: updatedMessagesByConversation));
    } catch (error) {
      _logger.e('加载日期附近消息失败', error: error, stackTrace: StackTrace.current);
      emit(state.copyWith(isLoading: false, error: '加载消息失败: $error'));
    }
  }

  /// 根据日期加载会话消息,从指定日期开始获取消息
  Future<void> loadMessagesForConversationByDate(String conversationId, {required DateTime targetDate, int limit = 30}) async {
    try {
      emit(state.copyWith(isLoading: true));

      // 从指定日期开始获取消息（包括该日期的消息）
      // 注意：这里不使用日期范围查询,而是从该日期开始获取消息
      final messages = await _repository.getConversationMessagesFromDate(conversationId, targetDate, limit: limit);

      if (messages.isEmpty) {
        _logger.i('未找到从日期开始的消息', extra: {'targetDate': targetDate});
      } else {
        _logger.i('已加载消息', extra: {'count': messages.length, 'targetDate': targetDate});
      }

      // 替换现有的消息列表,确保当天消息显示在顶部
      final updatedMessagesByConversation = Map<String, List<Message>>.from(state.messagesByConversation);
      updatedMessagesByConversation[conversationId] = messages;

      emit(state.copyWith(isLoading: false, messagesByConversation: updatedMessagesByConversation));
    } catch (error) {
      _logger.e('从指定日期加载消息失败', error: error, stackTrace: StackTrace.current);
      emit(state.copyWith(isLoading: false, error: '加载消息失败: $error'));
    }
  }

  /// 设置页面间交互数据,用于在不同页面之间传递信息
  void setNavigationData(Map<String, dynamic> data) {
    emit(state.copyWith(navigationData: data));
  }

  /// 清除页面间交互数据
  void clearNavigationData() {
    emit(state.copyWithClearedNavigationData());
  }

  /// 处理跳转到指定日期的消息
  Future<void> jumpToDate(String conversationId, DateTime targetDate) async {
    try {
      // 计算所选日期的开始
      // final startOfDay = DateTime(targetDate.year, targetDate.month, targetDate.day);

      // 从数据库加载该日期为起点的消息
      // await loadMessagesForConversationByDate(conversationId, targetDate: startOfDay, limit: 30);

      // 更新导航数据,包含跳转信息
      _logger.i('更新导航数据,包含跳转信息', extra: {'jumpToDate': targetDate});
      setNavigationData({'jumpToDate': targetDate});
    } catch (error) {
      _logger.e('跳转到指定日期失败', error: error, stackTrace: StackTrace.current);
      emit(state.copyWithError('跳转到指定日期失败: $error'));
    }
  }

  /// 跳转到指定消息
  void jumpToMessage(String messageId) {
    setNavigationData({'targetMessageId': messageId});
  }

  /// 开始与用户的对话
  Future<void> startConversationWithUser({
    required String userId,
    required String name,
    String? avatar,
  }) async {
    try {
      _logger.i('开始与用户的对话', extra: {'userId': userId, 'name': name});

      // 创建或获取现有会话
      final conversationId = await _repository.createOrGetConversation(userId);

      if (conversationId != null) {
        // 跳转到聊天详情页
        setNavigationData({
          'route': '/chat',
          'conversation': {
            'id': conversationId,
            'name': name,
            'avatar': avatar,
          },
        });
      } else {
        _logger.e('创建会话失败');
      }
    } catch (error) {
      _logger.e('开始对话失败', error: error, stackTrace: StackTrace.current);
    }
  }

  /// 关闭ChatCubit
  @override
  Future<void> close() {
    _logger.i('关闭ChatCubit');
    // 取消所有订阅
    _conversationsSubscription?.cancel();
    _contactsSubscription?.cancel();
    for (var subscription in _messagesSubscriptions.values) {
      subscription.cancel();
    }
    _messagesSubscriptions.clear();

    // 取消实时通信相关的订阅
    _typingStatusSubscription?.cancel();
    _onlineStatusSubscription?.cancel();
    _messageStatusSubscription?.cancel();
    _syncStatusSubscription?.cancel();
    _typingStatusTimer?.cancel();

    return super.close();
  }
}
