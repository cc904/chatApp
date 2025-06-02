import 'dart:async';

// ignore: depend_on_referenced_packages
import 'package:bloc/bloc.dart';
import 'package:cc/core/database/models/message.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/features/chat/domain/repositories/chat_repository.dart';
import 'package:cc/features/chat/presentation/cubit/chat_state.dart';
import 'package:cc/features/contacts/domain/repositories/contacts_repository.dart';

/// 单个聊天会话的业务逻辑Cubit
/// 使用简化的消息列表缓存系统，提供高性能的消息管理
class ChatCubit extends Cubit<ChatState> {
  final ChatRepository _chatRepository;
  final LogService _logger = LogService.instance;

  // 保存订阅，以便在dispose时取消
  final Map<String, StreamSubscription> _subscriptions = {};

  // 简化的配置参数
  static const int defaultPageSize = 30; // 每页消息数量
  static const int visibleMessagesCount = 50; // 可见消息数量

  ChatCubit({
    required ChatRepository chatRepository,
    required String conversationId,
    ContactsRepository? contactsRepository,
  })  : _chatRepository = chatRepository,
        super(ChatState.initial(conversationId)) {
    _init();
  }

  /// 初始化
  Future<void> _init() async {
    try {
      _logger
          .i('ChatCubit初始化开始', extra: {'conversationId': state.conversationId});

      // 设置事件监听
      _setupSubscriptions();

      // 简化初始化：直接加载消息
      await _loadInitialMessages();

      // 加入会话房间
      await joinConversation();

      _logger.i('ChatCubit初始化完成');
    } catch (error) {
      _logger.e('初始化ChatCubit失败', error: error);
      emit(state.copyWith(errorMessage: '初始化失败: ${error.toString()}'));
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

      emit(state.copyWith(isLoadingMessages: true));

      // 检查是否有缓存的消息
      final cachedMessages =
          _chatRepository.getCachedMessages(state.conversationId);

      if (cachedMessages != null && cachedMessages.isNotEmpty) {
        _logger.i('从消息缓存加载消息', extra: {
          'conversationId': state.conversationId,
          'messageCount': cachedMessages.length,
        });

        // 按时间升序排序（最新的在下方）
        final sortedMessages = List<Message>.from(cachedMessages)
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

        // 计算未读消息数量
        final unreadCount =
            sortedMessages.where((msg) => msg.status != 'read').length;
        final firstUnreadMessage = sortedMessages.firstWhere(
          (msg) => msg.status != 'read',
          orElse: () => Message(),
        );

        // 再次检查Cubit是否已关闭
        if (!isClosed) {
          emit(state.copyWith(
            messages: sortedMessages,
            hasMoreHistory: sortedMessages.length >= visibleMessagesCount,
            hasMoreRecent: false,
            unreadCount: unreadCount,
            firstUnreadMessageId: firstUnreadMessage.messageId.isNotEmpty
                ? firstUnreadMessage.messageId
                : null,
            isLoadingMessages: false,
          ));
        }
      } else {
        // 没有缓存，从数据库加载
        await _loadMessagesFromDatabase();
      }
    } catch (error) {
      _logger.e('加载初始消息失败', error: error);

      // 检查Cubit是否已关闭
      if (!isClosed) {
        emit(state.copyWith(
          isLoadingMessages: false,
          errorMessage: '加载消息失败: ${error.toString()}',
        ));
      }
    }
  }

  /// 从数据库加载消息
  Future<void> _loadMessagesFromDatabase() async {
    try {
      // 检查Cubit是否已关闭
      if (isClosed) {
        _logger.w('Cubit已关闭，取消加载消息');
        return;
      }

      final messages = await _chatRepository.getConversationMessages(
        state.conversationId,
        limit: visibleMessagesCount,
      );

      // 按时间升序排序（最新的在下方）
      final sortedMessages = List<Message>.from(messages)
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

      // 缓存消息
      if (messages.isNotEmpty) {
        _chatRepository.cacheMessages(state.conversationId, sortedMessages);
      }

      // 计算未读消息数量
      final unreadCount =
          sortedMessages.where((msg) => msg.status != 'read').length;
      final firstUnreadMessage = sortedMessages.firstWhere(
        (msg) => msg.status != 'read',
        orElse: () => Message(),
      );

      // 再次检查Cubit是否已关闭
      if (!isClosed) {
        emit(state.copyWith(
          messages: sortedMessages,
          hasMoreHistory: messages.length == visibleMessagesCount,
          unreadCount: unreadCount,
          firstUnreadMessageId: firstUnreadMessage.messageId.isNotEmpty
              ? firstUnreadMessage.messageId
              : null,
          isLoadingMessages: false,
        ));
      }

      _logger.i('从数据库加载消息成功', extra: {'count': sortedMessages.length});
    } catch (error) {
      _logger.e('从数据库加载消息失败', error: error);
      rethrow;
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
    // 检查Cubit是否已关闭
    if (isClosed) {
      _logger.w('Cubit已关闭，忽略消息状态更新');
      return;
    }

    final String messageId = data['messageId'] as String;
    final String status = data['status'] as String;
    final String? errorMessage = data['errorMessage'] as String?;

    _logger.d('收到消息状态更新', extra: {
      'messageId': messageId,
      'status': status,
      'errorMessage': errorMessage,
    });

    // 查找并更新消息状态
    final messages = List<Message>.from(state.messages);
    final messageIndex = messages.indexWhere((m) => m.messageId == messageId);

    if (messageIndex != -1) {
      // 找到消息，直接更新状态
      final message = messages[messageIndex];
      message.status = status;

      // 如果有错误信息，也更新错误信息
      if (errorMessage != null) {
        message.errorMessage = errorMessage;
      }

      // 替换消息
      messages[messageIndex] = message;

      // 同时更新消息缓存
      _chatRepository.cacheMessages(state.conversationId, messages);

      // 再次检查Cubit是否已关闭
      if (!isClosed) {
        emit(state.copyWith(messages: messages));
      }

      _logger.d('消息状态已更新', extra: {
        'messageId': messageId,
        'newStatus': status,
      });
    } else {
      _logger.w('未找到要更新状态的消息', extra: {'messageId': messageId});
    }
  }

  /// 加载会话消息
  Future<void> loadMessages() async {
    try {
      _logger.i('开始加载消息', extra: {'conversationId': state.conversationId});

      // 检查Cubit是否已关闭
      if (isClosed) {
        _logger.w('Cubit已关闭，取消加载消息');
        return;
      }

      emit(state.copyWith(isLoadingMessages: true));

      // 从数据库加载消息
      final messages = await _chatRepository.getConversationMessages(
        state.conversationId,
        limit: visibleMessagesCount,
      );

      // 按时间升序排序（最新的在下方）
      final sortedMessages = List<Message>.from(messages)
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

      // 更新缓存
      if (messages.isNotEmpty) {
        _chatRepository.cacheMessages(state.conversationId, sortedMessages);
      }

      // 计算未读消息数量
      final unreadCount =
          sortedMessages.where((msg) => msg.status != 'read').length;
      final firstUnreadMessage = sortedMessages.firstWhere(
        (msg) => msg.status != 'read',
        orElse: () => Message(),
      );

      // 再次检查Cubit是否已关闭
      if (!isClosed) {
        emit(state.copyWith(
          messages: sortedMessages,
          hasMoreHistory: messages.length == visibleMessagesCount,
          unreadCount: unreadCount,
          firstUnreadMessageId: firstUnreadMessage.messageId.isNotEmpty
              ? firstUnreadMessage.messageId
              : null,
          isLoadingMessages: false,
        ));
      }

      _logger.i('消息加载完成', extra: {'count': sortedMessages.length});
    } catch (error) {
      _logger.e('加载消息失败', error: error);

      // 检查Cubit是否已关闭
      if (!isClosed) {
        emit(state.copyWith(
          isLoadingMessages: false,
          errorMessage: '加载消息失败: ${error.toString()}',
        ));
      }
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

      // 按时间升序排序（最新的在下方）
      final sortedMessages = List<Message>.from(messages)
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

      // 更新消息缓存
      _chatRepository.cacheMessages(state.conversationId, sortedMessages);

      emit(state.copyWith(
        messages: sortedMessages,
        isLoadingMessages: false,
        hasMoreHistory: messages.isNotEmpty,
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

  /// 加载更多消息（简化版本）
  /// 用于滚动到顶部时加载更早的消息
  Future<void> loadMoreMessages() async {
    try {
      // 检查Cubit是否已关闭
      if (isClosed) {
        _logger.w('Cubit已关闭，取消加载更多消息');
        return;
      }

      if (state.isLoadingMoreMessages || !state.hasMoreHistory) {
        _logger.d('跳过加载更多消息', extra: {
          'isLoading': state.isLoadingMoreMessages,
          'hasMore': state.hasMoreHistory,
        });
        return;
      }

      emit(state.copyWith(isLoadingMoreMessages: true));

      // 获取最早的消息时间作为before参数
      DateTime? before;
      if (state.messages.isNotEmpty) {
        before = state.messages.first.createdAt;
      }

      final moreMessages = await _chatRepository.getConversationMessages(
        state.conversationId,
        limit: defaultPageSize,
        before: before,
      );

      if (moreMessages.isNotEmpty) {
        // 合并消息（新消息在前）
        final allMessages = [...moreMessages, ...state.messages];

        // 按时间升序排序
        allMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

        // 更新缓存
        _chatRepository.cacheMessages(state.conversationId, allMessages);

        // 再次检查Cubit是否已关闭
        if (!isClosed) {
          emit(state.copyWith(
            messages: allMessages,
            hasMoreHistory: moreMessages.length == defaultPageSize,
            isLoadingMoreMessages: false,
          ));
        }

        _logger.i('加载更多消息成功', extra: {'newCount': moreMessages.length});
      } else {
        // 没有更多消息
        if (!isClosed) {
          emit(state.copyWith(
            hasMoreHistory: false,
            isLoadingMoreMessages: false,
          ));
        }

        _logger.i('没有更多历史消息');
      }
    } catch (error) {
      _logger.e('加载更多消息失败', error: error);

      // 检查Cubit是否已关闭
      if (!isClosed) {
        emit(state.copyWith(
          isLoadingMoreMessages: false,
          errorMessage: '加载更多消息失败: ${error.toString()}',
        ));
      }
    }
  }

  /// 发送文本消息
  Future<void> sendTextMessage(String text) async {
    _logger.i('发送文本消息', extra: {
      'conversationId': state.conversationId,
      'textLength': text.length,
    });

    Message? tempMessage;

    try {
      // 检查Cubit是否已关闭
      if (isClosed) {
        _logger.w('Cubit已关闭，取消发送消息');
        return;
      }

      emit(state.copyWith(isSending: true));

      // 1. 创建带临时ID的消息
      tempMessage = await _chatRepository.createTempMessage(
        state.conversationId,
        text,
        'text',
      );

      // 2. 立即添加到UI显示（状态为sending）
      final updatedMessages = [...state.messages, tempMessage];

      // 再次检查Cubit是否已关闭
      if (isClosed) {
        _logger.w('Cubit已关闭，取消状态更新');
        return;
      }

      emit(state.copyWith(
        messages: updatedMessages,
        isSending: false,
      ));

      // 3. 发送消息（不等待响应）
      await _chatRepository.sendMessageWithTimeout(
        tempMessage,
        timeout: const Duration(seconds: 3),
      );

      _logger.i('文本消息发送请求已发出', extra: {
        'tempMessageId': tempMessage.messageId,
      });
    } catch (error) {
      _logger.e('发送文本消息失败', error: error);

      // 如果是超时错误，标记消息为失败状态
      if (error.toString().contains('timeout') ||
          error.toString().contains('超时')) {
        await _markMessageAsFailed(tempMessage?.messageId, '发送超时');
      } else {
        // 检查Cubit是否已关闭再发射状态
        if (!isClosed) {
          emit(state.copyWith(
            errorMessage: '发送消息失败: ${error.toString()}',
            isSending: false,
          ));
        }
      }
    }
  }

  /// 标记消息为失败状态
  Future<void> _markMessageAsFailed(
      String? messageId, String errorReason) async {
    if (messageId == null || isClosed) return;

    try {
      await _chatRepository.markMessageAsFailed(messageId, errorReason);

      // 重新加载消息以更新UI
      if (!isClosed) {
        await _loadMessagesFromDatabase();
      }

      _logger.w('消息标记为失败', extra: {
        'messageId': messageId,
        'reason': errorReason,
      });
    } catch (error) {
      _logger.e('标记消息失败状态时出错', error: error);
    }
  }

  /// 重新发送失败的消息
  Future<void> resendMessage(String messageId) async {
    _logger.i('重新发送消息', extra: {
      'messageId': messageId,
      'conversationId': state.conversationId,
    });

    try {
      emit(state.copyWith(isSending: true));

      // 1. 获取失败的消息
      final failedMessage = await _chatRepository.getMessageById(messageId);
      if (failedMessage == null) {
        throw Exception('找不到要重发的消息');
      }

      // 2. 重置消息状态为sending
      await _chatRepository.updateMessageStatus(messageId, 'sending');
      await _loadMessagesFromDatabase(); // 更新UI

      // 3. 重新发送（不等待响应）
      await _chatRepository.sendMessageWithTimeout(
        failedMessage,
        timeout: const Duration(seconds: 3),
      );

      emit(state.copyWith(isSending: false));

      _logger.i('消息重发请求已发出', extra: {
        'messageId': messageId,
      });
    } catch (error) {
      _logger.e('重发消息失败', error: error);

      // 如果是超时错误，重新标记为失败
      if (error.toString().contains('timeout') ||
          error.toString().contains('超时')) {
        await _markMessageAsFailed(messageId, '重发超时');
      } else {
        emit(state.copyWith(
          errorMessage: '重发消息失败: ${error.toString()}',
          isSending: false,
        ));
      }
    }
  }

  /// 发送图片消息
  Future<void> sendImageMessage(String localPath, {String? mediaUrl}) async {
    _logger.i('发送图片消息', extra: {
      'conversationId': state.conversationId,
      'localPath': localPath,
      'hasMediaUrl': mediaUrl != null,
    });

    try {
      emit(state.copyWith(isSending: true));

      final message = await _chatRepository.sendImageMessage(
        state.conversationId,
        localPath,
        mediaUrl: mediaUrl,
      );

      // 将新消息添加到列表末尾（因为是升序排列，新消息在底部）
      final updatedMessages = [...state.messages, message];

      // 再次检查Cubit是否已关闭
      if (isClosed) {
        _logger.w('Cubit已关闭，取消状态更新');
        return;
      }

      emit(state.copyWith(
        messages: updatedMessages,
        isSending: false,
      ));

      _logger.i('图片消息发送成功');
    } catch (error) {
      _logger.e('发送图片消息失败', error: error);
      emit(state.copyWith(
        errorMessage: '发送图片失败: ${error.toString()}',
        isSending: false,
      ));
    }
  }

  /// 发送语音消息
  Future<void> sendVoiceMessage(String localPath, int duration,
      {String? mediaUrl}) async {
    _logger.i('发送语音消息', extra: {
      'conversationId': state.conversationId,
      'localPath': localPath,
      'duration': duration,
      'hasMediaUrl': mediaUrl != null,
    });

    try {
      emit(state.copyWith(isSending: true));

      final message = await _chatRepository.sendVoiceMessage(
        state.conversationId,
        localPath,
        duration,
        mediaUrl: mediaUrl,
      );

      // 将新消息添加到列表末尾（因为是升序排列，新消息在底部）
      final updatedMessages = [...state.messages, message];

      // 再次检查Cubit是否已关闭
      if (isClosed) {
        _logger.w('Cubit已关闭，取消状态更新');
        return;
      }

      emit(state.copyWith(
        messages: updatedMessages,
        isSending: false,
      ));

      _logger.i('语音消息发送成功');
    } catch (error) {
      _logger.e('发送语音消息失败', error: error);
      emit(state.copyWith(
        errorMessage: '发送语音失败: ${error.toString()}',
        isSending: false,
      ));
    }
  }

  /// 发送视频消息
  Future<void> sendVideoMessage(
    String localPath,
    int duration, {
    String? thumbnailUrl,
    String? mediaUrl,
    bool isServerProcessed = false,
  }) async {
    _logger.i('发送视频消息', extra: {
      'conversationId': state.conversationId,
      'localPath': localPath,
      'duration': duration,
      'hasMediaUrl': mediaUrl != null,
      'hasThumbnailUrl': thumbnailUrl != null,
      'isServerProcessed': isServerProcessed,
    });

    try {
      emit(state.copyWith(isSending: true));

      final message = await _chatRepository.sendVideoMessage(
        state.conversationId,
        localPath,
        duration,
        thumbnailUrl: thumbnailUrl,
        mediaUrl: mediaUrl,
        isServerProcessed: isServerProcessed,
      );

      // 将新消息添加到列表末尾（因为是升序排列，新消息在底部）
      final updatedMessages = [...state.messages, message];

      // 再次检查Cubit是否已关闭
      if (isClosed) {
        _logger.w('Cubit已关闭，取消状态更新');
        return;
      }

      emit(state.copyWith(
        messages: updatedMessages,
        isSending: false,
      ));

      _logger.i('视频消息发送成功');
    } catch (error) {
      _logger.e('发送视频消息失败', error: error);
      emit(state.copyWith(
        errorMessage: '发送视频失败: ${error.toString()}',
        isSending: false,
      ));
    }
  }

  /// 发送文件消息
  Future<void> sendFileMessage(
    String localPath,
    String fileName,
    double fileSize, {
    String? mediaUrl,
  }) async {
    _logger.i('发送文件消息', extra: {
      'conversationId': state.conversationId,
      'localPath': localPath,
      'fileName': fileName,
      'fileSize': fileSize,
      'hasMediaUrl': mediaUrl != null,
    });

    try {
      emit(state.copyWith(isSending: true));

      final message = await _chatRepository.sendFileMessage(
        state.conversationId,
        localPath,
        fileName,
        fileSize,
        mediaUrl: mediaUrl,
      );

      // 将新消息添加到列表末尾（因为是升序排列，新消息在底部）
      final updatedMessages = [...state.messages, message];

      // 再次检查Cubit是否已关闭
      if (isClosed) {
        _logger.w('Cubit已关闭，取消状态更新');
        return;
      }

      emit(state.copyWith(
        messages: updatedMessages,
        isSending: false,
      ));

      _logger.i('文件消息发送成功');
    } catch (error) {
      _logger.e('发送文件消息失败', error: error);
      emit(state.copyWith(
        errorMessage: '发送文件失败: ${error.toString()}',
        isSending: false,
      ));
    }
  }

  /// 发送消息（通用方法）
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
          if (message.localPath != null) {
            await sendImageMessage(
              message.localPath!,
              mediaUrl: message.mediaUrl,
            );
          }
          break;
        case 'voice':
          if (message.localPath != null && message.duration != null) {
            await sendVoiceMessage(
              message.localPath!,
              message.duration!,
              mediaUrl: message.mediaUrl,
            );
          }
          break;
        case 'video':
          if (message.localPath != null && message.duration != null) {
            await sendVideoMessage(
              message.localPath!,
              message.duration!,
              thumbnailUrl: message.thumbnailUrl,
              mediaUrl: message.mediaUrl,
            );
          }
          break;
        case 'file':
          if (message.localPath != null &&
              message.fileName != null &&
              message.fileSize != null) {
            await sendFileMessage(
              message.localPath!,
              message.fileName!,
              message.fileSize!,
              mediaUrl: message.mediaUrl,
            );
          }
          break;
        default:
          _logger.w('不支持的消息类型: ${message.type}');
          throw Exception('不支持的消息类型: ${message.type}');
      }
    } catch (error) {
      _logger.e('发送消息失败', error: error);
      emit(state.copyWith(errorMessage: '发送消息失败: ${error.toString()}'));
    }
  }

  /// 更新最后阅读的消息ID（简化版本）
  void updateLastReadMessageId(String messageId) {
    _logger.d('更新最后阅读的消息ID', extra: {'messageId': messageId});

    emit(state.copyWith(lastReadMessageId: messageId));

    // 异步更新到Repository
    _chatRepository
        .updateLastReadMessageId(state.conversationId, messageId)
        .catchError((error) {
      _logger.e('更新最后阅读消息ID到Repository失败', error: error);
    });
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
      await _chatRepository.joinConversationRoom(state.conversationId);
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

    // 传统方式：查找消息在列表中的位置
    final messageIndex =
        state.messages.indexWhere((m) => m.messageId == messageId);
    if (messageIndex != -1) {
      emit(state.copyWith(lastReadMessageId: messageId));
    }
  }

  /// 更新滚动位置（简化版本）
  /// [scrollPosition] - 新的滚动位置
  void updateScrollPosition(int scrollPosition) {
    _logger.d('更新滚动位置', extra: {'scrollPosition': scrollPosition});

    // 保存用户查看状态
    _saveUserViewState(scrollPosition);
  }

  /// 保存用户查看状态
  void _saveUserViewState(int scrollPosition) {
    // 简化版本：只记录日志，不保存状态
    _logger.d('用户查看状态', extra: {
      'scrollPosition': scrollPosition,
      'conversationId': state.conversationId,
      'lastViewTime': DateTime.now().toIso8601String(),
    });
  }

  /// 标记消息为已读
  /// [messageIds] - 消息ID列表
  void markMessagesAsRead(List<String> messageIds) {
    // 在消息列表中标记已读
    final updatedMessages = List<Message>.from(state.messages);
    int unreadCount = 0;
    String? firstUnreadMessageId;

    for (final message in updatedMessages) {
      if (messageIds.contains(message.messageId)) {
        message.status = 'read';
      }
      if (message.status != 'read') {
        unreadCount++;
        firstUnreadMessageId ??= message.messageId;
      }
    }

    // 更新缓存
    _chatRepository.cacheMessages(state.conversationId, updatedMessages);

    // 更新状态
    emit(state.copyWith(
      messages: updatedMessages,
      unreadCount: unreadCount,
      firstUnreadMessageId: firstUnreadMessageId,
    ));

    _logger.i('消息已标记为已读', extra: {
      'messageIds': messageIds,
      'remainingUnread': unreadCount,
    });
  }

  /// 跳转到第一条未读消息
  void scrollToFirstUnreadMessage() {
    if (state.firstUnreadMessageId != null) {
      scrollToMessage(state.firstUnreadMessageId!);
    } else {
      _logger.i('没有未读消息');
    }
  }

  /// 清空消息缓存
  void clearMessageCache() {
    _logger.i('清空消息缓存');

    _chatRepository.removeCachedMessages(state.conversationId);

    emit(state.copyWith(
      messages: [],
      unreadCount: 0,
      firstUnreadMessageId: null,
    ));
  }

  /// 强制刷新消息
  Future<void> forceRefresh() async {
    _logger.i('强制刷新消息');

    // 清空缓存
    clearMessageCache();

    // 重新加载消息
    await loadMessages();
  }

  /// 获取缓存统计信息
  Map<String, dynamic> getCacheStats() {
    final repoStats = _chatRepository.getCacheStats();
    final messageStats = state.getMessageStats();

    return {
      'repository': repoStats,
      'currentState': messageStats,
      'conversationId': state.conversationId,
    };
  }

  /// 发送输入状态
  Future<void> sendTypingStatus(bool isTyping) async {
    await _chatRepository.sendTypingStatus(state.conversationId, isTyping);
  }

  /// 清理重复消息数据
  /// 用于修复数据库中的重复消息问题
  Future<void> cleanupDuplicateMessages() async {
    try {
      _logger.i('开始清理重复消息', extra: {
        'conversationId': state.conversationId,
      });

      // 清理数据库中的重复消息
      final removedCount = await _chatRepository.cleanupDuplicateMessages(
        state.conversationId,
      );

      if (removedCount > 0) {
        _logger.i('清理重复消息完成', extra: {
          'conversationId': state.conversationId,
          'removedCount': removedCount,
        });

        // 重新加载消息以反映清理结果
        await _loadInitialMessages();
      } else {
        _logger.i('没有发现重复消息');
      }
    } catch (error) {
      _logger.e('清理重复消息失败', error: error);
    }
  }

  /// 验证消息数据一致性
  /// 检查消息数据的完整性和一致性
  Future<Map<String, dynamic>> validateMessageConsistency() async {
    try {
      _logger.i('验证消息数据一致性', extra: {
        'conversationId': state.conversationId,
      });

      final stats = await _chatRepository.validateMessageConsistency(
        state.conversationId,
      );

      _logger.i('消息数据一致性验证完成', extra: stats);

      return stats;
    } catch (error) {
      _logger.e('验证消息数据一致性失败', error: error);
      return {'error': error.toString()};
    }
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
