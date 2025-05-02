import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

import 'chat_state.dart';
import 'package:cc/core/database/models/user.dart';
import 'package:cc/core/database/models/conversation.dart';
import 'package:cc/core/database/models/message.dart';
import 'package:cc/features/chat/domain/repositories/chat_repository.dart';

/// 聊天Cubit
/// 负责管理聊天相关的状态和业务逻辑
class ChatCubit extends Cubit<ChatState> {
  final ChatRepository _repository;
  final Logger _logger = Logger();

  // 订阅管理
  StreamSubscription? _conversationsSubscription;
  StreamSubscription? _contactsSubscription;
  final Map<String, StreamSubscription> _messagesSubscriptions = {};

  // 标记是否正在加载，避免重复加载
  bool _isLoadingConversations = false;
  // ignore: prefer_final_fields
  Map<String, bool> _isLoadingMessages = {};

  // 标记数据变更的来源
  bool _isSourceOfChange = false;

  ChatCubit({required ChatRepository repository})
      : _repository = repository,
        super(ChatState.initial()) {
    // 初始化时设置订阅，但不主动加载数据
    _setupSubscriptions();
  }

  /// 设置数据变化订阅
  void _setupSubscriptions() {
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

  /// 加载会话列表
  Future<void> loadConversations() async {
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
    } catch (e) {
      _logger.e('加载会话列表失败', error: e);
      emit(state.copyWithError('加载会话列表失败: $e'));
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

    // 只为当前会话添加监听，减少不必要的刷新
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
    try {
      emit(state.copyWithLoading());
      final contacts = await _repository.getAllContacts();
      emit(state.copyWith(
        contacts: contacts,
        isLoading: false,
      ));
    } catch (e) {
      _logger.e('加载联系人列表失败', error: e);
      emit(state.copyWithError('加载联系人列表失败: $e'));
    }
  }

  /// 加载指定会话的消息
  Future<void> loadMessagesForConversation(String conversationId, {int limit = 20, DateTime? before}) async {
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
        // 加载更多历史消息，合并到现有消息列表
        emit(state.copyWithAdditionalMessagesForConversation(conversationId, messages));
      } else {
        // 初始加载消息，替换现有消息列表
        emit(state.copyWithMessagesForConversation(conversationId, messages));
      }

      // 如果是当前会话，标记为已读
      if (state.currentConversationId == conversationId) {
        markConversationAsRead(conversationId);
      }
    } catch (e) {
      _logger.e('加载会话消息失败', error: e);
      // 不影响主UI，仅记录错误
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
    } catch (e) {
      _logger.e('切换会话失败', error: e);
      emit(state.copyWithError('切换会话失败: $e'));
    }
  }

  /// 标记会话为已读
  Future<void> markConversationAsRead(String conversationId) async {
    try {
      _isSourceOfChange = true;
      await _repository.markConversationAsRead(conversationId);
      _isSourceOfChange = false;
    } catch (e) {
      _logger.e('标记会话已读失败', error: e);
      _isSourceOfChange = false;
    }
  }

  /// 搜索联系人
  Future<void> searchContacts(String keyword) async {
    try {
      emit(state.copyWithLoading());

      final results = await _repository.searchContacts(keyword);

      emit(state.copyWith(
        searchQuery: keyword,
        searchResults: results,
        isLoading: false,
      ));
    } catch (e) {
      _logger.e('搜索联系人失败', error: e);
      emit(state.copyWithError('搜索联系人失败: $e'));
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
    } catch (e) {
      _logger.e('搜索会话失败', error: e);
      emit(state.copyWithError('搜索会话失败: $e'));
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
    } catch (e) {
      _logger.e('搜索消息失败', error: e);
      emit(state.copyWithError('搜索消息失败: $e'));
    }
  }

  /// 发送文本消息
  Future<void> sendTextMessage(String conversationId, String text) async {
    if (text.trim().isEmpty) return;

    try {
      _isSourceOfChange = true;
      // 发送消息并获取返回的消息对象
      final message = await _repository.sendTextMessage(conversationId, text);

      // 立即更新当前状态中的消息列表，而不是等待数据库通知
      final currentMessages = state.messagesByConversation[conversationId] ?? [];
      final newMessages = [message, ...currentMessages];

      // 直接更新状态
      emit(state.copyWithMessagesForConversation(conversationId, newMessages));

      // 再次加载完整消息列表以确保同步
      await loadMessagesForConversation(conversationId);

      _isSourceOfChange = false;
    } catch (e) {
      _logger.e('发送文本消息失败', error: e);
      emit(state.copyWithError('发送消息失败: $e'));
      _isSourceOfChange = false;
    }
  }

  /// 发送图片消息
  Future<void> sendImageMessage(String conversationId, String localPath, {String? mediaUrl}) async {
    try {
      _isSourceOfChange = true;
      // 发送消息并获取返回的消息对象
      final message = await _repository.sendImageMessage(conversationId, localPath, mediaUrl: mediaUrl);

      // 立即更新当前状态中的消息列表，而不是等待数据库通知
      final currentMessages = state.messagesByConversation[conversationId] ?? [];
      final newMessages = [message, ...currentMessages];

      // 直接更新状态
      emit(state.copyWithMessagesForConversation(conversationId, newMessages));

      // 再次加载完整消息列表以确保同步
      await loadMessagesForConversation(conversationId);

      _isSourceOfChange = false;
    } catch (e) {
      _logger.e('发送图片消息失败', error: e);
      emit(state.copyWithError('发送图片失败: $e'));
      _isSourceOfChange = false;
    }
  }

  /// 发送语音消息
  Future<void> sendVoiceMessage(String conversationId, String localPath, int duration, {String? mediaUrl}) async {
    try {
      _isSourceOfChange = true;
      // 发送消息并获取返回的消息对象
      final message = await _repository.sendVoiceMessage(conversationId, localPath, duration, mediaUrl: mediaUrl);

      // 立即更新当前状态中的消息列表，而不是等待数据库通知
      final currentMessages = state.messagesByConversation[conversationId] ?? [];
      final newMessages = [message, ...currentMessages];

      // 直接更新状态
      emit(state.copyWithMessagesForConversation(conversationId, newMessages));

      // 再次加载完整消息列表以确保同步
      await loadMessagesForConversation(conversationId);

      _isSourceOfChange = false;
    } catch (e) {
      _logger.e('发送语音消息失败', error: e);
      emit(state.copyWithError('发送语音失败: $e'));
      _isSourceOfChange = false;
    }
  }

  /// 发送文件消息
  Future<void> sendFileMessage(String conversationId, String localPath, String fileName, double fileSize, {String? mediaUrl}) async {
    try {
      _isSourceOfChange = true;
      // 发送消息并获取返回的消息对象
      final message = await _repository.sendFileMessage(conversationId, localPath, fileName, fileSize, mediaUrl: mediaUrl);

      // 立即更新当前状态中的消息列表，而不是等待数据库通知
      final currentMessages = state.messagesByConversation[conversationId] ?? [];
      final newMessages = [message, ...currentMessages];

      // 直接更新状态
      emit(state.copyWithMessagesForConversation(conversationId, newMessages));

      // 再次加载完整消息列表以确保同步
      await loadMessagesForConversation(conversationId);

      _isSourceOfChange = false;
    } catch (e) {
      _logger.e('发送文件消息失败', error: e);
      emit(state.copyWithError('发送文件失败: $e'));
      _isSourceOfChange = false;
    }
  }

  /// 发送视频消息
  Future<void> sendVideoMessage(String conversationId, String localPath, int duration, {String? thumbnailUrl, String? mediaUrl, bool isServerProcessed = false}) async {
    try {
      _isSourceOfChange = true;
      // 发送消息并获取返回的消息对象
      final message = await _repository.sendVideoMessage(conversationId, localPath, duration, thumbnailUrl: thumbnailUrl, mediaUrl: mediaUrl, isServerProcessed: isServerProcessed);

      // 立即更新当前状态中的消息列表，而不是等待数据库通知
      final currentMessages = state.messagesByConversation[conversationId] ?? [];
      final newMessages = [message, ...currentMessages];

      // 直接更新状态
      emit(state.copyWithMessagesForConversation(conversationId, newMessages));

      // 再次加载完整消息列表以确保同步
      await loadMessagesForConversation(conversationId);

      _isSourceOfChange = false;
    } catch (e) {
      _logger.e('发送视频消息失败', error: e);
      emit(state.copyWithError('发送视频失败: $e'));
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
    } catch (e) {
      _logger.e('获取或创建私聊会话失败', error: e);
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
    } catch (e) {
      _logger.e('创建群聊失败', error: e);
      _isSourceOfChange = false;
      rethrow;
    }
  }

  /// 删除消息
  Future<void> deleteMessage(String messageId) async {
    try {
      _isSourceOfChange = true;

      // 首先获取要删除的消息，以确定它属于哪个会话
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

      // 如果找到了消息和对应的会话，立即更新UI状态
      if (messageToDelete != null && conversationId != null) {
        // 从消息列表中移除该消息
        final currentMessages = state.messagesByConversation[conversationId] ?? [];
        final newMessages = currentMessages.where((m) => m.messageId != messageId).toList();

        // 更新状态
        emit(state.copyWithMessagesForConversation(conversationId, newMessages));

        // 再次加载会话列表，因为最后一条消息可能已更改
        await loadConversations();
      }

      _isSourceOfChange = false;
    } catch (e) {
      _logger.e('删除消息失败', error: e);
      emit(state.copyWithError('删除消息失败: $e'));
      _isSourceOfChange = false;
    }
  }

  /// 删除会话
  Future<void> deleteConversation(String conversationId) async {
    try {
      _isSourceOfChange = true;
      await _repository.deleteConversation(conversationId);
      _isSourceOfChange = false;

      // 如果删除的是当前会话，清空当前会话ID
      if (state.currentConversationId == conversationId) {
        emit(state.copyWith(currentConversationId: null));
      }
    } catch (e) {
      _logger.e('删除会话失败', error: e);
      emit(state.copyWithError('删除会话失败: $e'));
      _isSourceOfChange = false;
    }
  }

  /// 清空会话消息
  Future<void> clearConversationMessages(String conversationId) async {
    try {
      _isSourceOfChange = true;
      await _repository.clearConversationMessages(conversationId);

      // 清空当前状态中的会话消息
      emit(state.copyWithMessagesForConversation(conversationId, []));

      // 重新加载会话列表，因为最后一条消息已被清空
      await loadConversations();

      _isSourceOfChange = false;
    } catch (e) {
      _logger.e('清空会话消息失败', error: e);
      emit(state.copyWithError('清空会话消息失败: $e'));
      _isSourceOfChange = false;
    }
  }

  /// 添加联系人
  Future<void> addContact(User user) async {
    try {
      _isSourceOfChange = true;
      await _repository.addContact(user);
      _isSourceOfChange = false;
    } catch (e) {
      _logger.e('添加联系人失败', error: e);
      emit(state.copyWithError('添加联系人失败: $e'));
      _isSourceOfChange = false;
    }
  }

  @override
  Future<void> close() {
    // 取消所有订阅
    _conversationsSubscription?.cancel();
    _contactsSubscription?.cancel();
    for (var subscription in _messagesSubscriptions.values) {
      subscription.cancel();
    }
    _messagesSubscriptions.clear();

    return super.close();
  }
}
