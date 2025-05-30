import 'dart:async';

// ignore: depend_on_referenced_packages
import 'package:bloc/bloc.dart';
import 'package:cc/core/database/models/message.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/features/chat/domain/repositories/chat_repository.dart';
import 'package:cc/features/chat/presentation/cubit/chat_state.dart';
import 'package:cc/features/contacts/domain/repositories/contacts_repository.dart';

/// 单个聊天会话的业务逻辑Cubit
class ChatCubit extends Cubit<ChatState> {
  final ChatRepository _chatRepository;
  final LogService _logger = LogService.instance;

  // 保存订阅，以便在dispose时取消
  final Map<String, StreamSubscription> _subscriptions = {};

  ChatCubit({
    required ChatRepository chatRepository,
    required String conversationId,
    ContactsRepository? contactsRepository,
  })  : _chatRepository = chatRepository,
        super(ChatState.initial(conversationId)) {
    _setupSubscriptions();
    _init();
  }

  /// 初始化
  Future<void> _init() async {
    try {
      // 初始化会话
      await _initializeConversation();

      // 加入会话房间
      await joinConversation();

      // 设置事件监听
      _setupSubscriptions();

      _logger.i('ChatCubit初始化完成');
    } catch (error) {
      _logger.e('初始化ChatCubit失败', error: error);
      emit(state.copyWith(errorMessage: '初始化失败: ${error.toString()}'));
    }
  }

  /// 初始化会话
  /// 加载会话信息和联系人信息
  Future<void> _initializeConversation() async {
    try {
      _logger.i('初始化会话', extra: {'conversationId': state.conversationId});

      // 会话信息和联系人信息应该由外部传入或通过其他方式获取
      // 这里只初始化消息相关的功能

      // 加载消息
      await loadMessages();
    } catch (error) {
      _logger.e('初始化会话失败', error: error);
      emit(state.copyWith(
        errorMessage: '初始化会话失败: ${error.toString()}',
      ));
    }
  }

  /// 设置stream事件订阅
  void _setupSubscriptions() {
    _logger.i('设置聊天事件订阅');

    // 监听打字状态
    _subscriptions['typingStatus'] =
        _chatRepository.getTypingStatusStream().listen((data) {
      if (data['conversationId'] == state.conversationId) {
        _handleTypingStatus(data);
      }
    });

    // 监听消息状态
    _subscriptions['messageStatus'] =
        _chatRepository.getMessageStatusStream().listen((data) {
      // 查找消息是否属于当前会话
      for (final message in state.messages) {
        if (message.messageId == data['messageId']) {
          _handleMessageStatus(data);
          break;
        }
      }
    });
  }

  /// 处理打字状态事件
  void _handleTypingStatus(Map<String, dynamic> data) {
    final String userId = data['userId'] as String;
    final bool isTyping = data['isTyping'] as bool;

    // 更新打字状态
    final updatedTypingUsers = List<String>.from(state.typingUsers);

    if (isTyping) {
      // 添加正在输入的用户
      if (!updatedTypingUsers.contains(userId)) {
        updatedTypingUsers.add(userId);
      }
    } else {
      // 移除不再输入的用户
      updatedTypingUsers.removeWhere((id) => id == userId);
    }

    emit(state.copyWith(typingUsers: updatedTypingUsers));
  }

  /// 处理消息状态事件
  void _handleMessageStatus(Map<String, dynamic> data) {
    final String messageId = data['messageId'] as String;
    final String status = data['status'] as String;

    // 查找并更新消息状态
    final messages = List<Message>.from(state.messages);
    final messageIndex = messages.indexWhere((m) => m.messageId == messageId);

    if (messageIndex != -1) {
      // 找到消息，更新状态
      final message = messages[messageIndex];
      Message updatedMessage;

      if (status == 'delivered') {
        // 更新已送达状态
        updatedMessage = Message()
          ..id = message.id
          ..messageId = message.messageId
          ..conversationId = message.conversationId
          ..senderId = message.senderId
          ..senderName = message.senderName
          ..senderAvatar = message.senderAvatar
          ..createdAt = message.createdAt
          ..status = 'delivered'
          ..isRead = message.isRead
          ..type = message.type
          ..text = message.text
          ..mediaUrl = message.mediaUrl
          ..localPath = message.localPath
          ..duration = message.duration
          ..fileSize = message.fileSize
          ..fileName = message.fileName
          ..thumbnailUrl = message.thumbnailUrl
          ..latitude = message.latitude
          ..longitude = message.longitude
          ..locationAddress = message.locationAddress
          ..quotedMessageId = message.quotedMessageId;
      } else if (status == 'read') {
        // 更新已读状态
        updatedMessage = Message()
          ..id = message.id
          ..messageId = message.messageId
          ..conversationId = message.conversationId
          ..senderId = message.senderId
          ..senderName = message.senderName
          ..senderAvatar = message.senderAvatar
          ..createdAt = message.createdAt
          ..status = message.status
          ..isRead = true
          ..type = message.type
          ..text = message.text
          ..mediaUrl = message.mediaUrl
          ..localPath = message.localPath
          ..duration = message.duration
          ..fileSize = message.fileSize
          ..fileName = message.fileName
          ..thumbnailUrl = message.thumbnailUrl
          ..latitude = message.latitude
          ..longitude = message.longitude
          ..locationAddress = message.locationAddress
          ..quotedMessageId = message.quotedMessageId;
      } else {
        // 其他状态，直接更新状态字段
        updatedMessage = Message()
          ..id = message.id
          ..messageId = message.messageId
          ..conversationId = message.conversationId
          ..senderId = message.senderId
          ..senderName = message.senderName
          ..senderAvatar = message.senderAvatar
          ..createdAt = message.createdAt
          ..status = status
          ..isRead = message.isRead
          ..type = message.type
          ..text = message.text
          ..mediaUrl = message.mediaUrl
          ..localPath = message.localPath
          ..duration = message.duration
          ..fileSize = message.fileSize
          ..fileName = message.fileName
          ..thumbnailUrl = message.thumbnailUrl
          ..latitude = message.latitude
          ..longitude = message.longitude
          ..locationAddress = message.locationAddress
          ..quotedMessageId = message.quotedMessageId;
      }

      // 替换消息
      messages[messageIndex] = updatedMessage;
      emit(state.copyWith(messages: messages));
    }
  }

  /// 加载会话消息
  Future<void> loadMessages() async {
    _logger.i('加载会话消息', extra: {'conversationId': state.conversationId});
    try {
      emit(state.copyWith(isLoadingMessages: true));

      // 获取消息
      final messages =
          await _chatRepository.getConversationMessages(state.conversationId);

      emit(state.copyWith(
        messages: messages,
        isLoadingMessages: false,
      ));

      _logger.i('加载消息成功', extra: {'count': messages.length});
    } catch (error) {
      _logger.e('加载消息失败', error: error);
      emit(state.copyWith(
        isLoadingMessages: false,
        errorMessage: '加载消息失败: ${error.toString()}',
      ));
    }
  }

  /// 从服务器加载历史消息
  Future<void> loadHistoryMessagesFromServer() async {
    _logger.i('从服务器加载历史消息', extra: {'conversationId': state.conversationId});
    try {
      emit(state.copyWith(isLoadingMessages: true));

      // 从服务器获取历史消息
      final messages =
          await _chatRepository.fetchHistoryMessages(state.conversationId);

      emit(state.copyWith(
        messages: messages,
        isLoadingMessages: false,
      ));

      _logger.i('加载历史消息成功', extra: {'count': messages.length});
    } catch (error) {
      _logger.e('加载历史消息失败', error: error);
      emit(state.copyWith(
        isLoadingMessages: false,
        errorMessage: '加载历史消息失败: ${error.toString()}',
      ));
    }
  }

  /// 加载更多消息
  /// 用于滚动到顶部时加载更早的消息
  /// [before] - 加载此时间之前的消息
  Future<void> loadMoreMessages(DateTime before) async {
    _logger.i('加载更多消息', extra: {'conversationId': state.conversationId});
    try {
      // 避免重复加载
      if (state.isLoadingMoreMessages) {
        return;
      }

      emit(state.copyWith(isLoadingMoreMessages: true));

      // 获取更早的消息
      final olderMessages = await _chatRepository.getConversationMessages(
        state.conversationId,
        before: before,
      );

      _logger.i('加载更多消息成功', extra: {'count': olderMessages.length});

      // 如果没有更多消息，直接返回
      if (olderMessages.isEmpty) {
        emit(state.copyWith(isLoadingMoreMessages: false));
        return;
      }

      // 合并消息列表
      final currentMessages = state.messages;

      // 确保不重复添加消息
      final existingIds = currentMessages.map((m) => m.messageId).toSet();
      final newMessages = olderMessages
          .where((m) => !existingIds.contains(m.messageId))
          .toList();

      final mergedMessages = [...newMessages, ...currentMessages];

      emit(state.copyWith(
        messages: mergedMessages,
        isLoadingMoreMessages: false,
      ));
    } catch (error) {
      _logger.e('加载更多消息失败', error: error);
      emit(state.copyWith(
        isLoadingMoreMessages: false,
        errorMessage: '加载更多消息失败: ${error.toString()}',
      ));
    }
  }

  /// 发送消息
  ///
  /// 通用的发送消息方法，支持发送不同类型的消息
  /// [message] - 消息对象
  Future<void> sendMessage(Message message) async {
    _logger.i('发送消息', extra: {
      'conversationId': state.conversationId,
      'messageType': message.type,
    });

    try {
      // 根据消息类型调用不同的发送方法
      switch (message.type) {
        case 'text':
          if (message.text != null) {
            await sendTextMessage(message.text!);
          }
          break;
        case 'image':
          // TODO: 实现发送图片消息
          _logger.w('发送图片消息功能尚未实现');
          break;
        case 'file':
          // TODO: 实现发送文件消息
          _logger.w('发送文件消息功能尚未实现');
          break;
        default:
          _logger.w('不支持的消息类型: ${message.type}');
          break;
      }
    } catch (error) {
      _logger.e('发送消息失败', error: error);
      emit(state.copyWith(errorMessage: '发送消息失败: ${error.toString()}'));
    }
  }

  /// 发送文本消息
  Future<void> sendTextMessage(String text) async {
    _logger.i('发送文本消息',
        extra: {'conversationId': state.conversationId, 'text': text});
    try {
      // 调用仓库层发送消息
      final message =
          await _chatRepository.sendTextMessage(state.conversationId, text);

      // 更新消息列表
      final currentMessages = state.messages;
      final updatedMessages = [...currentMessages, message];

      emit(state.copyWith(messages: updatedMessages));
    } catch (error) {
      _logger.e('发送消息失败', error: error);
      emit(state.copyWith(errorMessage: '发送消息失败: ${error.toString()}'));
    }
  }

  /// 更新最后阅读的消息ID
  ///
  /// [messageId] - 消息ID
  Future<void> updateLastReadMessageId(String messageId) async {
    _logger.i('更新最后阅读的消息ID', extra: {
      'conversationId': state.conversationId,
      'messageId': messageId
    });

    try {
      await _chatRepository.updateLastReadMessageId(
          state.conversationId, messageId);

      emit(state.copyWith(lastReadMessageId: messageId));
    } catch (error) {
      _logger.e('更新最后阅读的消息ID失败', error: error);
      emit(state.copyWith(errorMessage: '更新最后阅读的消息ID失败: ${error.toString()}'));
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
        networkStatus: ChatState.kNetworkStatusConnecting,
      ));

      // TODO: 实现实际的重连逻辑，可能需要调用repository中的方法

      // 连接成功后更新状态
      emit(state.copyWith(
        networkStatus: ChatState.kNetworkStatusConnected,
      ));

      // 重新加载消息
      await loadMessages();
    } catch (error) {
      _logger.e('重新连接失败', error: error);
      emit(state.copyWith(
        networkStatus: ChatState.kNetworkStatusError,
        errorMessage: '连接失败: ${error.toString()}',
      ));
    }
  }

  /// 用户进入会话
  Future<void> joinConversation() async {
    try {
      _logger.i('用户进入会话', extra: {'conversationId': state.conversationId});

      // 通知服务器用户加入会话房间
      await _chatRepository.joinConversationRoom(state.conversationId);

      // 标记会话为已读
      await _chatRepository.markConversationAsRead(state.conversationId);
    } catch (error) {
      _logger.e('进入会话失败', error: error);
      emit(state.copyWith(errorMessage: '进入会话失败: ${error.toString()}'));
    }
  }

  /// 用户离开会话
  Future<void> leaveConversation() async {
    try {
      _logger.i('用户离开会话', extra: {'conversationId': state.conversationId});

      // 通知服务器用户离开会话房间
      await _chatRepository.leaveConversationRoom(state.conversationId);
    } catch (error) {
      _logger.e('离开会话失败', error: error);
    }
  }

  /// 滚动到特定消息
  /// [messageId] - 消息ID
  void scrollToMessage(String messageId) {
    _logger.i('滚动到消息', extra: {'messageId': messageId});

    // 查找消息在列表中的位置
    final messageIndex =
        state.messages.indexWhere((m) => m.messageId == messageId);
    if (messageIndex != -1) {
      // 这里只是记录目标消息ID，实际滚动操作由UI层处理
      emit(state.copyWith(lastReadMessageId: messageId));
    }
  }

  /// 发送输入状态
  Future<void> sendTypingStatus(bool isTyping) async {
    await _chatRepository.sendTypingStatus(state.conversationId, isTyping);
  }

  /// 清理资源
  @override
  Future<void> close() async {
    _logger.i('关闭 ChatCubit');

    // 离开会话
    await leaveConversation();

    // 取消订阅
    for (final subscription in _subscriptions.values) {
      subscription.cancel();
    }

    return super.close();
  }
}
