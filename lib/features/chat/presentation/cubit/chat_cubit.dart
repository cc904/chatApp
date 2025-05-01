import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

import 'chat_state.dart';
import 'package:cc/core/database/models/user.dart';
import 'package:cc/core/database/models/conversation.dart';
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

  ChatCubit({required ChatRepository repository})
      : _repository = repository,
        super(ChatState.initial()) {
    // 初始化时加载数据
    _initializeData();
  }

  /// 初始化数据
  Future<void> _initializeData() async {
    // 加载会话列表
    await loadConversations();

    // 加载联系人列表
    await loadContacts();

    // 设置订阅
    _setupSubscriptions();
  }

  /// 设置数据变化订阅
  void _setupSubscriptions() {
    // 监听会话列表变化
    _conversationsSubscription?.cancel();
    _conversationsSubscription = _repository.watchConversations().listen((_) {
      loadConversations();
    });

    // 监听联系人变化
    _contactsSubscription?.cancel();
    _contactsSubscription = _repository.watchContacts().listen((_) {
      loadContacts();
    });
  }

  /// 加载会话列表
  Future<void> loadConversations() async {
    try {
      emit(state.copyWithLoading());
      final conversations = await _repository.getAllConversations();
      emit(state.copyWith(
        conversations: conversations,
        isLoading: false,
      ));

      // 为每个会话设置消息监听
      _setupMessageSubscriptions(conversations);

      // 加载每个会话的最近消息
      for (final conversation in conversations) {
        loadMessagesForConversation(conversation.id.toString());
      }
    } catch (e) {
      _logger.e('加载会话列表失败', error: e);
      emit(state.copyWithError('加载会话列表失败: $e'));
    }
  }

  /// 为会话设置消息变化监听
  void _setupMessageSubscriptions(List<Conversation> conversations) {
    // 清理不需要的订阅
    final validIds = conversations.map((c) => c.id.toString()).toSet();
    _messagesSubscriptions.keys.where((id) => !validIds.contains(id)).toList().forEach((id) {
      _messagesSubscriptions[id]?.cancel();
      _messagesSubscriptions.remove(id);
    });

    // 添加新的订阅
    for (final conversation in conversations) {
      final id = conversation.id.toString();
      if (!_messagesSubscriptions.containsKey(id)) {
        _messagesSubscriptions[id] = _repository.watchConversationMessages(id).listen((_) {
          loadMessagesForConversation(id);
        });
      }
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
    try {
      final messages = await _repository.getConversationMessages(
        conversationId,
        limit: limit,
        before: before,
      );

      // 更新状态
      emit(state.copyWithMessagesForConversation(conversationId, messages));

      // 如果是当前会话，标记为已读
      if (state.currentConversationId == conversationId) {
        markConversationAsRead(conversationId);
      }
    } catch (e) {
      _logger.e('加载会话消息失败', error: e);
      // 不影响主UI，仅记录错误
    }
  }

  /// 切换当前会话
  Future<void> setCurrentConversation(String conversationId) async {
    try {
      emit(state.copyWith(currentConversationId: conversationId));

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
      await _repository.markConversationAsRead(conversationId);

      // 通过监听会自动更新UI
    } catch (e) {
      _logger.e('标记会话已读失败', error: e);
      // 不影响主UI，仅记录错误
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
      await _repository.sendTextMessage(conversationId, text);
      // 消息会通过监听自动更新UI
    } catch (e) {
      _logger.e('发送文本消息失败', error: e);
      emit(state.copyWithError('发送消息失败: $e'));
    }
  }

  /// 发送图片消息
  Future<void> sendImageMessage(String conversationId, String localPath, {String? mediaUrl}) async {
    try {
      await _repository.sendImageMessage(conversationId, localPath, mediaUrl: mediaUrl);
      // 消息会通过监听自动更新UI
    } catch (e) {
      _logger.e('发送图片消息失败', error: e);
      emit(state.copyWithError('发送图片失败: $e'));
    }
  }

  /// 发送语音消息
  Future<void> sendVoiceMessage(String conversationId, String localPath, int duration, {String? mediaUrl}) async {
    try {
      await _repository.sendVoiceMessage(conversationId, localPath, duration, mediaUrl: mediaUrl);
      // 消息会通过监听自动更新UI
    } catch (e) {
      _logger.e('发送语音消息失败', error: e);
      emit(state.copyWithError('发送语音失败: $e'));
    }
  }

  /// 获取或创建私聊会话
  Future<Conversation> getOrCreatePrivateConversation(String contactUserId) async {
    try {
      return await _repository.getOrCreatePrivateConversation(contactUserId);
    } catch (e) {
      _logger.e('获取或创建私聊会话失败', error: e);
      rethrow;
    }
  }

  /// 创建群聊
  Future<Conversation> createGroupConversation(String name, List<String> memberIds, {String? avatar}) async {
    try {
      return await _repository.createGroupConversation(name, memberIds, avatar: avatar);
    } catch (e) {
      _logger.e('创建群聊失败', error: e);
      rethrow;
    }
  }

  /// 删除消息
  Future<void> deleteMessage(String messageId) async {
    try {
      await _repository.deleteMessage(messageId);
      // 消息会通过监听自动更新UI
    } catch (e) {
      _logger.e('删除消息失败', error: e);
      emit(state.copyWithError('删除消息失败: $e'));
    }
  }

  /// 删除会话
  Future<void> deleteConversation(String conversationId) async {
    try {
      await _repository.deleteConversation(conversationId);
      // 会话会通过监听自动更新UI

      // 如果删除的是当前会话，清空当前会话ID
      if (state.currentConversationId == conversationId) {
        emit(state.copyWith(currentConversationId: null));
      }
    } catch (e) {
      _logger.e('删除会话失败', error: e);
      emit(state.copyWithError('删除会话失败: $e'));
    }
  }

  /// 添加联系人
  Future<void> addContact(User user) async {
    try {
      await _repository.addContact(user);
      // 联系人会通过监听自动更新UI
    } catch (e) {
      _logger.e('添加联系人失败', error: e);
      emit(state.copyWithError('添加联系人失败: $e'));
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
