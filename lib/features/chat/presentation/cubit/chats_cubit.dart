import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cc/core/database/models/conversation.dart';
import 'package:cc/core/database/models/message.dart';
import 'package:cc/core/database/models/user.dart';
import 'package:cc/core/proto/generated/user.pb.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:cc/features/chat/domain/repositories/chat_repository.dart';
import 'package:cc/features/chat/presentation/cubit/chats_state.dart';
import 'package:cc/features/contacts/domain/repositories/contacts_repository.dart';

/// 聊天相关的业务逻辑Cubit
class ChatsCubit extends Cubit<ChatsState> {
  late ChatRepository _chatRepository;
  // final ContactsRepository _contactsRepository;
  final LogService _logger = LogService.instance;

  // 订阅列表
  final Map<String, StreamSubscription> _subscriptions = {};

  ChatsCubit()
      : super(ChatsState.initial()) {
    _chatRepository = ChatRepositoryImpl();
    _setupSubscriptions();
  }

  /// 设置事件订阅
  void _setupSubscriptions() {
    // 监听会话更新事件
    _subscriptions['conversationUpdate'] =
        _chatRepository.conversationUpdateStream.listen((event) {
      _handleConversationUpdateEvent(event);
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

    // 监听消息状态
    _subscriptions['messageStatus'] =
        _chatRepository.getMessageStatusStream().listen((data) {
      _handleMessageStatus(data);
    });

    // 监听新消息
    _subscriptions['newMessage'] =
        _chatRepository.messageStream.listen((message) {
      _handleNewMessage(message);
    });
  }

  /// 加载会话列表
  Future<void> loadConversations() async {
    _logger.i('加载会话列表');
    try {
      final conversations = await _chatRepository.getAllConversations();
      emit(state.copyWith(conversations: conversations));
    } catch (error) {
      _logger.e('加载会话失败', error: error);
      emit(state.copyWith(errorMessage: '加载会话失败: ${error.toString()}'));
    }
  }

  /// 同步会话列表
  /// 从服务器同步最新的会话数据
  Future<void> syncConversations() async {
    emit(state.copyWith(
      conversationSyncStatus: ConversationSyncStatus.syncing,
    ));
    _logger.i('同步会话列表');
    try {
      await _chatRepository.syncConversations();

      // 同步完成后加载最新数据
      final conversations = await _chatRepository.getAllConversations();
      emit(state.copyWith(
        conversations: conversations,
        conversationSyncStatus: ConversationSyncStatus.completed,
      ));
    } catch (error) {
      _logger.e('同步会话失败', error: error);
      emit(state.copyWith(
        errorMessage: '同步会话失败: ${error.toString()}',
        conversationSyncStatus: ConversationSyncStatus.error,
      ));
    }
  }

  /// 加载会话消息
  /// 加载指定会话的消息列表
  Future<void> loadMessages(String conversationId) async {
    _logger.i('加载会话消息', extra: {'conversationId': conversationId});

    emit(state.copyWith(
      currentConversationId: conversationId,
      isLoadingMessages: true,
    ));

    try {
      final messages = await _chatRepository.getMessages(conversationId);

      // 更新消息映射
      final updatedMessagesByConversation =
          Map<String, List<Message>>.from(state.messagesByConversation);
      updatedMessagesByConversation[conversationId] = messages;

      emit(state.copyWith(
        messagesByConversation: updatedMessagesByConversation,
        isLoadingMessages: false,
      ));
    } catch (error) {
      _logger.e('加载消息失败', error: error);
      emit(state.copyWith(
        errorMessage: '加载消息失败: ${error.toString()}',
        isLoadingMessages: false,
      ));
    }
  }

  /// 加载更多消息
  /// 加载指定会话的更多历史消息
  Future<void> loadMoreMessages(String conversationId) async {
    if (state.isLoadingMoreMessages) return;

    _logger.i('加载更多历史消息', extra: {'conversationId': conversationId});

    emit(state.copyWith(isLoadingMoreMessages: true));

    try {
      // 获取当前消息列表
      final currentMessages =
          state.messagesByConversation[conversationId] ?? [];
      if (currentMessages.isEmpty) {
        emit(state.copyWith(isLoadingMoreMessages: false));
        return;
      }

      // 获取最早消息的时间作为加载更多的起点
      final oldestMessage = currentMessages
          .reduce((a, b) => a.createdAt.isBefore(b.createdAt) ? a : b);

      // 加载更多历史消息
      final olderMessages = await _chatRepository.getMessagesBefore(
        conversationId,
        oldestMessage.createdAt,
      );

      if (olderMessages.isEmpty) {
        emit(state.copyWith(isLoadingMoreMessages: false));
        return;
      }

      // 合并消息列表
      final updatedMessages = [...olderMessages, ...currentMessages];

      // 更新消息映射
      final updatedMessagesByConversation =
          Map<String, List<Message>>.from(state.messagesByConversation);
      updatedMessagesByConversation[conversationId] = updatedMessages;

      emit(state.copyWith(
        messagesByConversation: updatedMessagesByConversation,
        isLoadingMoreMessages: false,
      ));
    } catch (error) {
      _logger.e('加载更多消息失败', error: error);
      emit(state.copyWith(
        errorMessage: '加载更多消息失败: ${error.toString()}',
        isLoadingMoreMessages: false,
      ));
    }
  }

  /// 发送消息
  Future<void> sendMessage(String conversationId, String content,
      {String? replyToMessageId}) async {
    _logger.i('发送消息',
        extra: {'conversationId': conversationId, 'content': content});

    try {
      final message = await _chatRepository.sendMessage(
        conversationId: conversationId,
        content: content,
        replyToMessageId: replyToMessageId,
      );

      // 更新消息列表
      final currentMessages =
          state.messagesByConversation[conversationId] ?? [];
      final updatedMessages = [...currentMessages, message];

      // 更新消息映射
      final updatedMessagesByConversation =
          Map<String, List<Message>>.from(state.messagesByConversation);
      updatedMessagesByConversation[conversationId] = updatedMessages;

      emit(state.copyWith(
        messagesByConversation: updatedMessagesByConversation,
      ));
    } catch (error) {
      _logger.e('发送消息失败', error: error);
      emit(state.copyWith(
        errorMessage: '发送消息失败: ${error.toString()}',
      ));
    }
  }

  /// 处理会话更新事件
  void _handleConversationUpdateEvent(ConversationUpdateEvent event) {
    _logger.i('处理会话更新事件', extra: {
      'type': event.type.toString(),
      'conversationId': event.conversationId,
    });

    switch (event.type) {
      case ConversationUpdateType.added:
        _handleConversationAdded(event.conversation!);
        break;
      case ConversationUpdateType.updated:
        _handleConversationUpdated(event.conversation!);
        break;
      case ConversationUpdateType.deleted:
        _handleConversationDeleted(event.conversationId);
        break;
    }
  }

  /// 处理会话添加事件
  void _handleConversationAdded(Conversation conversation) {
    final updatedConversations = [...state.conversations, conversation];

    // 按最后消息时间排序
    updatedConversations.sort((a, b) {
      final aTime = a.lastMessageTime ?? DateTime(1970);
      final bTime = b.lastMessageTime ?? DateTime(1970);
      return bTime.compareTo(aTime);
    });

    // 更新已更新会话ID集合
    final updatedIds = {
      ...state.updatedConversationIds,
      conversation.conversationId
    };

    emit(state.copyWith(
      conversations: updatedConversations,
      updatedConversationIds: updatedIds,
    ));
  }

  /// 处理会话更新事件
  void _handleConversationUpdated(Conversation updatedConversation) {
    final updatedConversations = state.conversations.map((conversation) {
      if (conversation.conversationId == updatedConversation.conversationId) {
        return updatedConversation;
      }
      return conversation;
    }).toList();

    // 按最后消息时间排序
    updatedConversations.sort((a, b) {
      final aTime = a.lastMessageTime ?? DateTime(1970);
      final bTime = b.lastMessageTime ?? DateTime(1970);
      return bTime.compareTo(aTime);
    });

    // 更新已更新会话ID集合
    final updatedIds = {
      ...state.updatedConversationIds,
      updatedConversation.conversationId
    };

    emit(state.copyWith(
      conversations: updatedConversations,
      updatedConversationIds: updatedIds,
    ));
  }

  /// 处理会话删除事件
  void _handleConversationDeleted(String conversationId) {
    final updatedConversations = state.conversations
        .where((conversation) => conversation.conversationId != conversationId)
        .toList();

    // 更新已删除会话ID集合
    final removedIds = {...state.removedConversationIds, conversationId};

    emit(state.copyWith(
      conversations: updatedConversations,
      removedConversationIds: removedIds,
    ));
  }

  /// 处理新消息
  void _handleNewMessage(Message message) {
    final conversationId = message.conversationId;

    // 更新消息列表
    final currentMessages = state.messagesByConversation[conversationId] ?? [];
    final updatedMessages = [...currentMessages, message];

    // 更新消息映射
    final updatedMessagesByConversation =
        Map<String, List<Message>>.from(state.messagesByConversation);
    updatedMessagesByConversation[conversationId] = updatedMessages;

    emit(state.copyWith(
      messagesByConversation: updatedMessagesByConversation,
    ));
  }

  /// 处理打字状态
  void _handleTypingStatus(Map<String, dynamic> data) {
    final conversationId = data['conversationId'] as String;
    final userId = data['userId'] as String;
    final isTyping = data['isTyping'] as bool;

    final updatedTypingUsers =
        Map<String, List<String>>.from(state.typingUsers);

    if (isTyping) {
      // 添加到正在输入的用户列表
      final typingUsersInConversation =
          updatedTypingUsers[conversationId] ?? [];
      if (!typingUsersInConversation.contains(userId)) {
        updatedTypingUsers[conversationId] = [
          ...typingUsersInConversation,
          userId
        ];
      }
    } else {
      // 从正在输入的用户列表中移除
      final typingUsersInConversation =
          updatedTypingUsers[conversationId] ?? [];
      updatedTypingUsers[conversationId] =
          typingUsersInConversation.where((id) => id != userId).toList();
    }

    emit(state.copyWith(typingUsers: updatedTypingUsers));
  }

  /// 处理在线状态
  void _handleOnlineStatus(Map<String, dynamic> data) {
    final userId = data['userId'] as String;
    final isOnline = data['isOnline'] as bool;

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
    final messageId = data['messageId'] as String;
    final status = data['status'] as String;
    final conversationId = data['conversationId'] as String;

    // 更新消息状态
    final currentMessages = state.messagesByConversation[conversationId] ?? [];
    final updatedMessages = currentMessages.map((message) {
      if (message.messageId == messageId) {
        return message.copyWith(status: status);
      }
      return message;
    }).toList();

    // 更新消息映射
    final updatedMessagesByConversation =
        Map<String, List<Message>>.from(state.messagesByConversation);
    updatedMessagesByConversation[conversationId] = updatedMessages;

    emit(state.copyWith(
      messagesByConversation: updatedMessagesByConversation,
    ));
  }

  /// 搜索会话
  void searchConversations(String query) {
    if (query.isEmpty) {
      emit(state.copyWith(
        searchQuery: "",
        filteredConversations: [],
      ));
      return;
    }

    _logger.i('搜索会话', extra: {'query': query});

    emit(state.copyWith(searchQuery: query));

    // 在 Cubit 层实现搜索逻辑
    final lowercaseQuery = query.toLowerCase();

    // 过滤会话
    final filteredList = state.conversations.where((conversation) {
      // 先检查会话名称
      final name = conversation.name;
      if (name != null &&
          name.isNotEmpty &&
          name.toLowerCase().contains(lowercaseQuery)) {
        return true;
      }

      // 检查最后一条消息预览
      if (conversation.lastMessagePreview != null &&
          conversation.lastMessagePreview!
              .toLowerCase()
              .contains(lowercaseQuery)) {
        return true;
      }

      // 如果是私聊，检查联系人信息
      if (conversation.type == ConversationType.private &&
          conversation.contactUserId != null) {
        // 查找对应的联系人
        final contacts = _contactsRepository.getCachedContacts();
        final contact = contacts.firstWhere(
          (contact) => contact.userId == conversation.contactUserId,
          orElse: () => User()..name = '',
        );

        // 检查联系人名称和拼音
        if (contact.name.toLowerCase().contains(lowercaseQuery)) {
          return true;
        }

        if (contact.pinyin != null &&
            contact.pinyin!.toLowerCase().contains(lowercaseQuery)) {
          return true;
        }
      }

      return false;
    }).toList();

    emit(state.copyWith(filteredConversations: filteredList));
  }

  /// 清除搜索
  void clearSearch() {
    emit(state.copyWith(
      searchQuery: "",
      filteredConversations: [],
    ));
  }

  /// 设置当前选中的标签索引
  void setSelectedTabIndex(int index) {
    emit(state.copyWith(selectedTabIndex: index));
  }

  @override
  Future<void> close() {
    // 取消所有订阅
    for (final subscription in _subscriptions.values) {
      subscription.cancel();
    }
    _subscriptions.clear();

    return super.close();
  }
}
