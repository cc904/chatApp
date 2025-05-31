import 'dart:async';

// ignore: depend_on_referenced_packages
import 'package:bloc/bloc.dart';
import 'package:cc/core/database/models/message.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/features/chat/domain/repositories/chat_repository.dart';
import 'package:cc/features/chat/domain/entities/message_timeline.dart';
import 'package:cc/features/chat/presentation/cubit/chat_state.dart';
import 'package:cc/features/contacts/domain/repositories/contacts_repository.dart';

/// 单个聊天会话的业务逻辑Cubit
/// 集成MessageTimeline缓存系统，提供高性能的消息管理
class ChatCubit extends Cubit<ChatState> {
  final ChatRepository _chatRepository;
  final LogService _logger = LogService.instance;

  // 保存订阅，以便在dispose时取消
  final Map<String, StreamSubscription> _subscriptions = {};

  // Timeline缓存相关
static const int visibleMessagesCount = 50; // 可见消息数量
static const int preloadBuffer = 20;       // 预加载缓冲区

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
      _logger
          .i('ChatCubit初始化开始', extra: {'conversationId': state.conversationId});

      // 设置事件监听
      _setupSubscriptions();

      // 检查是否已有缓存的Timeline
      await _initializeTimeline();

      // 加入会话房间
      await joinConversation();

      _logger.i('ChatCubit初始化完成');
    } catch (error) {
      _logger.e('初始化ChatCubit失败', error: error);
      emit(state.copyWith(errorMessage: '初始化失败: ${error.toString()}'));
    }
  }

  /// 初始化Timeline缓存
  Future<void> _initializeTimeline() async {
    try {
      // 检查Repository中是否已有缓存的Timeline
      final cachedTimeline = _chatRepository.getTimeline(state.conversationId);

      if (cachedTimeline != null) {
        _logger.i('发现缓存的Timeline', extra: {
          'conversationId': state.conversationId,
          'messageCount': cachedTimeline.length,
          'unreadCount': cachedTimeline.unreadCount,
        });

        // 从缓存恢复Timeline
        await _restoreFromTimeline(cachedTimeline);
      } else {
        _logger.i('未发现缓存，开始预加载Timeline');

        // 预加载Timeline
        await _preloadTimeline();
      }
    } catch (error) {
      _logger.e('初始化Timeline失败', error: error);
      // 如果Timeline初始化失败，回退到传统方式
      await _fallbackLoadMessages();
    }
  }

  /// 从Timeline缓存恢复状态
  Future<void> _restoreFromTimeline(MessageTimeline timeline) async {
    try {
      // 获取可见消息 - 使用已有的方法
      final visibleMessages =
          _getVisibleMessagesFromTimeline(timeline, timeline.lastVisibleIndex);

      // 获取总消息数和滚动位置
      final totalMessages = timeline.length;
      final scrollPosition = timeline.lastVisibleIndex;

      emit(state.copyWith(
        messages: visibleMessages,
        timeline: timeline,
        hasMoreHistory: timeline.hasMoreHistory,
        hasMoreRecent: timeline.hasMoreRecent,
        unreadCount: timeline.unreadCount,
        firstUnreadMessageId: timeline.firstUnreadMessageId,
        currentScrollPosition: scrollPosition,
        isLoadingMessages: false,
        isPreloading: false,
      ));

      _logger.i('从Timeline缓存恢复成功', extra: {
        'visibleMessages': visibleMessages.length,
        'totalMessages': totalMessages,
        'scrollPosition': scrollPosition,
      });
    } catch (error) {
      _logger.e('从Timeline缓存恢复失败', error: error);
      rethrow;
    }
  }

  /// 预加载Timeline
  Future<void> _preloadTimeline() async {
    try {
      emit(state.copyWith(isPreloading: true));

      // 调用Repository预加载
      final success = await _chatRepository.preloadTimeline(
        state.conversationId,
        messageCount: visibleMessagesCount + preloadBuffer,
      );

      if (success) {
        // 获取预加载的Timeline
        final timeline = _chatRepository.getTimeline(state.conversationId);

        if (timeline != null) {
          await _restoreFromTimeline(timeline);
        } else {
          throw Exception('预加载成功但无法获取Timeline');
        }
      } else {
        throw Exception('Timeline预加载失败');
      }

      emit(state.copyWith(isPreloading: false));
    } catch (error) {
      _logger.e('预加载Timeline失败', error: error);
      emit(state.copyWith(isPreloading: false));

      // 回退到传统方式
      await _fallbackLoadMessages();
    }
  }

  /// 回退到传统消息加载方式
  Future<void> _fallbackLoadMessages() async {
    _logger.w('回退到传统消息加载方式');
    try {
      emit(state.copyWith(isLoadingMessages: true));

      final messages = await _chatRepository.getConversationMessages(
        state.conversationId,
        limit: visibleMessagesCount,
      );

      emit(state.copyWith(
        messages: messages,
        isLoadingMessages: false,
        hasMoreHistory: messages.length == visibleMessagesCount,
      ));

      _logger.i('传统方式加载消息成功', extra: {'count': messages.length});
    } catch (error) {
      _logger.e('传统方式加载消息失败', error: error);
      emit(state.copyWith(
        isLoadingMessages: false,
        errorMessage: '加载消息失败: ${error.toString()}',
      ));
    }
  }

  /// 从Timeline获取可见消息
  List<Message> _getVisibleMessagesFromTimeline(
      MessageTimeline timeline, int scrollPosition) {
    if (timeline.isEmpty) {
      return [];
    }

    final startIndex = scrollPosition.clamp(0, timeline.length - 1);
    final endIndex = (startIndex + visibleMessagesCount)
        .clamp(startIndex, timeline.length);

    return timeline.getRange(startIndex, endIndex);
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

    // 如果已有Timeline，直接从缓存获取
    if (state.timeline != null) {
      _logger.d('使用Timeline缓存');
      final visibleMessages =
          _getVisibleMessagesFromTimeline(state.timeline!, 0);
      emit(state.copyWith(messages: visibleMessages));
      return;
    }

    // 否则重新初始化Timeline
    await _initializeTimeline();
  }

  /// 从服务器加载历史消息
  Future<void> loadHistoryMessagesFromServer() async {
    _logger.i('从服务器加载历史消息', extra: {'conversationId': state.conversationId});
    try {
      emit(state.copyWith(isLoadingMessages: true));

      // 从服务器获取历史消息
      final messages =
          await _chatRepository.fetchHistoryMessages(state.conversationId);

      if (state.timeline != null) {
        // 将新消息添加到Timeline
        state.timeline!.insertHistoryMessages(messages);

        // 更新缓存
        _chatRepository.storeTimeline(state.conversationId, state.timeline!);

        // 更新可见消息
        final visibleMessages = _getVisibleMessagesFromTimeline(
            state.timeline!, state.currentScrollPosition ?? 0);

        emit(state.copyWith(
          messages: visibleMessages,
          isLoadingMessages: false,
          hasMoreHistory: state.timeline!.hasMoreHistory,
        ));
      } else {
        // 回退到传统方式
        emit(state.copyWith(
          messages: messages,
          isLoadingMessages: false,
        ));
      }

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

      if (state.timeline != null) {
        // 使用Timeline缓存
        await _loadMoreMessagesWithTimeline(before);
      } else {
        // 传统方式加载
        await _loadMoreMessagesTraditional(before);
      }
    } catch (error) {
      _logger.e('加载更多消息失败', error: error);
      emit(state.copyWith(
        isLoadingMoreMessages: false,
        errorMessage: '加载更多消息失败: ${error.toString()}',
      ));
    }
  }

  /// 使用Timeline缓存加载更多消息
  Future<void> _loadMoreMessagesWithTimeline(DateTime before) async {
    try {
      // 检查Timeline是否还有历史消息
      if (!state.timeline!.hasMoreHistory) {
        emit(state.copyWith(isLoadingMoreMessages: false));
        return;
      }

      // 从数据库或服务器获取更早的消息
      final olderMessages = await _chatRepository.getConversationMessages(
        state.conversationId,
        before: before,
        limit: preloadBuffer,
      );

      if (olderMessages.isNotEmpty) {
        // 添加到Timeline
        state.timeline!.insertHistoryMessages(olderMessages);

        // 更新缓存
        _chatRepository.storeTimeline(state.conversationId, state.timeline!);

        // 更新可见消息（保持当前滚动位置）
        final visibleMessages = _getVisibleMessagesFromTimeline(
            state.timeline!, state.currentScrollPosition ?? 0);

        emit(state.copyWith(
          messages: visibleMessages,
          isLoadingMoreMessages: false,
          hasMoreHistory: state.timeline!.hasMoreHistory,
        ));

        _logger.i('Timeline加载更多消息成功', extra: {
          'newMessages': olderMessages.length,
          'totalInTimeline': state.timeline!.length,
        });
      } else {
        // 没有更多历史消息
        state.timeline!.hasMoreHistory = false;
        emit(state.copyWith(
          isLoadingMoreMessages: false,
          hasMoreHistory: false,
        ));
      }
    } catch (error) {
      _logger.e('Timeline加载更多消息失败', error: error);
      rethrow;
    }
  }

  /// 传统方式加载更多消息
  Future<void> _loadMoreMessagesTraditional(DateTime before) async {
    try {
      // 获取更早的消息
      final olderMessages = await _chatRepository.getConversationMessages(
        state.conversationId,
        before: before,
      );

      _logger.i('传统方式加载更多消息成功', extra: {'count': olderMessages.length});

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
      _logger.e('传统方式加载更多消息失败', error: error);
      rethrow;
    }
  }

  /// 发送文本消息
  Future<void> sendTextMessage(String text) async {
    _logger.i('发送文本消息', extra: {
      'conversationId': state.conversationId,
      'textLength': text.length,
    });

    try {
      emit(state.copyWith(isSending: true));

      final message = await _chatRepository.sendTextMessage(
        state.conversationId,
        text,
      );

      // 将新消息添加到Timeline
      if (state.timeline != null) {
        state.timeline!.appendNewMessages([message]);
        emit(state.copyWith(
          timeline: state.timeline,
          isSending: false,
        ));
      } else {
        // 如果没有Timeline，重新加载消息
        await _fallbackLoadMessages();
      }

      _logger.i('文本消息发送成功');
    } catch (error) {
      _logger.e('发送文本消息失败', error: error);
      emit(state.copyWith(
        errorMessage: '发送消息失败: ${error.toString()}',
        isSending: false,
      ));
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

      // 将新消息添加到Timeline
      if (state.timeline != null) {
        state.timeline!.appendNewMessages([message]);
        emit(state.copyWith(
          timeline: state.timeline,
          isSending: false,
        ));
      } else {
        // 如果没有Timeline，重新加载消息
        await _fallbackLoadMessages();
      }

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

      // 将新消息添加到Timeline
      if (state.timeline != null) {
        state.timeline!.appendNewMessages([message]);
        emit(state.copyWith(
          timeline: state.timeline,
          isSending: false,
        ));
      } else {
        // 如果没有Timeline，重新加载消息
        await _fallbackLoadMessages();
      }

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

      // 将新消息添加到Timeline
      if (state.timeline != null) {
        state.timeline!.appendNewMessages([message]);
        emit(state.copyWith(
          timeline: state.timeline,
          isSending: false,
        ));
      } else {
        // 如果没有Timeline，重新加载消息
        await _fallbackLoadMessages();
      }

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

      // 将新消息添加到Timeline
      if (state.timeline != null) {
        state.timeline!.appendNewMessages([message]);
        emit(state.copyWith(
          timeline: state.timeline,
          isSending: false,
        ));
      } else {
        // 如果没有Timeline，重新加载消息
        await _fallbackLoadMessages();
      }

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

    if (state.timeline != null) {
      // 在Timeline中查找消息位置
      final messageIndex = state.timeline!.findMessageIndex(messageId);
      if (messageIndex != null) {
        // 更新滚动位置
        updateScrollPosition(messageIndex);

        // 更新最后阅读消息
        emit(state.copyWith(lastReadMessageId: messageId));

        _logger.i('找到消息位置', extra: {
          'messageId': messageId,
          'index': messageIndex,
        });
      } else {
        _logger.w('未在Timeline中找到消息', extra: {'messageId': messageId});
      }
    } else {
      // 传统方式：查找消息在列表中的位置
      final messageIndex =
          state.messages.indexWhere((m) => m.messageId == messageId);
      if (messageIndex != -1) {
        emit(state.copyWith(lastReadMessageId: messageId));
      }
    }
  }

  /// 更新滚动位置
  /// [scrollPosition] - 新的滚动位置
  void updateScrollPosition(int scrollPosition) {
    if (state.timeline == null) return;

    try {
      // 更新Timeline的最后可见位置
      state.timeline!.updateLastVisibleIndex(scrollPosition);

      // 获取新的可见消息
      final visibleMessages =
          _getVisibleMessagesFromTimeline(state.timeline!, scrollPosition);

      emit(state.copyWith(
        messages: visibleMessages,
        currentScrollPosition: scrollPosition,
      ));

      // 保存用户查看状态
      _saveUserViewState(scrollPosition);

      _logger.d('滚动位置已更新', extra: {
        'scrollPosition': scrollPosition,
        'visibleMessages': visibleMessages.length,
      });
    } catch (error) {
      _logger.e('更新滚动位置失败', error: error);
    }
  }

  /// 保存用户查看状态
  void _saveUserViewState(int scrollPosition) {
    final viewState = ViewState(
      scrollPosition: scrollPosition,
      conversationId: state.conversationId,
      lastViewTime: DateTime.now(),
    );

    // 异步保存，不阻塞UI
    _chatRepository.saveUserViewState(viewState).catchError((error) {
      _logger.e('保存用户查看状态失败', error: error);
    });
  }

  /// 标记消息为已读
  /// [messageIds] - 消息ID列表
  void markMessagesAsRead(List<String> messageIds) {
    if (state.timeline != null) {
      // 在Timeline中标记已读
      state.timeline!.markMessagesAsRead(messageIds);

      // 更新缓存
      _chatRepository.storeTimeline(state.conversationId, state.timeline!);

      // 更新状态
      emit(state.copyWith(
        unreadCount: state.timeline!.unreadCount,
        firstUnreadMessageId: state.timeline!.firstUnreadMessageId,
      ));

      _logger.i('消息已标记为已读', extra: {
        'messageIds': messageIds,
        'remainingUnread': state.timeline!.unreadCount,
      });
    }
  }

  /// 跳转到第一条未读消息
  void scrollToFirstUnreadMessage() {
    if (state.timeline?.firstUnreadMessageId != null) {
      scrollToMessage(state.timeline!.firstUnreadMessageId!);
    } else {
      _logger.i('没有未读消息');
    }
  }

  /// 清空Timeline缓存
  void clearTimelineCache() {
    _logger.i('清空Timeline缓存');

    _chatRepository.removeTimeline(state.conversationId);

    emit(state.copyWith(
      timeline: ChatState.nullTimeline,
      currentScrollPosition: ChatState.nullScrollPosition,
    ));
  }

  /// 强制刷新Timeline
  Future<void> refreshTimeline() async {
    _logger.i('强制刷新Timeline');

    try {
      // 清空当前缓存
      clearTimelineCache();

      // 重新预加载
      await _preloadTimeline();

      _logger.i('Timeline刷新完成');
    } catch (error) {
      _logger.e('刷新Timeline失败', error: error);
      emit(state.copyWith(errorMessage: '刷新失败: ${error.toString()}'));
    }
  }

  /// 获取缓存统计信息
  Map<String, dynamic> getCacheStats() {
    final repoStats = _chatRepository.getCacheStats();
    final timelineStats = state.getTimelineStats();

    return {
      'repository': repoStats,
      'currentTimeline': timelineStats,
      'conversationId': state.conversationId,
    };
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
