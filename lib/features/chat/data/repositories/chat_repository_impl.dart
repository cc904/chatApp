import 'dart:async';
import 'dart:io';
import 'dart:collection';
import 'package:cc/core/database/models/current_user.dart';
import 'package:isar/isar.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/database/database_initializer.dart';
import 'package:cc/core/database/models/message.dart';
import 'package:cc/core/database/models/conversation.dart';
import 'package:cc/features/chat/domain/entities/message_cursor.dart';
import 'package:cc/core/services/communication_service.dart';
import 'package:cc/core/services/file_upload_service.dart';
import 'package:cc/features/chat/domain/repositories/chat_repository.dart';
import 'package:fixnum/fixnum.dart' as $fixnum;

import 'package:cc/core/proto/generated/message.pb.dart' as message_proto;
import 'package:cc/core/proto/generated/conversation.pb.dart'
    as conversation_proto;

/// 信号量类，用于控制并发数量
class Semaphore {
  final int maxCount;
  int _currentCount;
  final Queue<Completer<void>> _waitQueue = Queue<Completer<void>>();

  Semaphore(this.maxCount) : _currentCount = maxCount;

  Future<void> acquire() async {
    if (_currentCount > 0) {
      _currentCount--;
      return;
    }

    final completer = Completer<void>();
    _waitQueue.add(completer);
    return completer.future;
  }

  void release() {
    if (_waitQueue.isNotEmpty) {
      final completer = _waitQueue.removeFirst();
      completer.complete();
    } else {
      _currentCount++;
    }
  }
}

/// 消息异常
class MessageException implements Exception {
  final String message;
  MessageException(this.message);

  @override
  String toString() => message;
}

/// ChatRepository的实现类
/// 负责单个聊天会话相关的数据处理、消息收发等功能
class ChatRepositoryImpl implements ChatRepository {
  final LogService _logger = LogService.instance;
  final CommunicationService _communicationService = CommunicationService();
  final FileUploadService _fileUploadService = FileUploadService();
  final CurrentUser _currentUser;

  // 获取当前数据库实例，使用DatabaseInitializer
  Isar get _isar => DatabaseInitializer.isar;
  IsarCollection<Message> get _messages => _isar.messages;
  IsarCollection<Conversation> get _conversations => _isar.conversations;

  // 事件流控制器
  final _typingStatusController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _messageStatusController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _scrollPositionController =
      StreamController<ScrollPositionInfo>.broadcast();

  // 事件订阅列表
  final List<StreamSubscription> _subscriptions = [];

  // 跟踪用户当前活跃的会话
  final Set<String> _activeConversations = <String>{};

  // 构造函数
  ChatRepositoryImpl({required CurrentUser currentUser})
      : _currentUser = currentUser {
    _logger.x('ChatRepositoryImpl 初始化');
    _registerEventHandlers();
  }

  // 💢💢💢💢💢💢💢💢💢💢💢💢💢💢     Handler    💢💢💢💢💢💢💢💢💢💢💢💢💢💢

  /// 设置事件处理器
  Future<void> _registerEventHandlers() async {
    if (_communicationService.isInitialized) {
      _logger.i('ChatRepository Proto事件流 订阅');
      _subscriptions
        ..add(_communicationService
            .onProto<message_proto.MessageReadProto>('message:read')
            .listen(_handleMessageRead))
        ..add(_communicationService
            .onProto<message_proto.TypingProto>('user:typing')
            .listen(_handleTypingStatus))
        ..add(_communicationService
            .onProto<message_proto.TypingProto>('user:typing:stop')
            .listen(_handleTypingStop))
        ..add(_communicationService
            .onProto<message_proto.MessageSyncResponse>(
                'messages:sync:response')
            .listen(_handleMessageSyncResponse))
        ..add(_communicationService
            .onProto<message_proto.HistoryMessagesResponse>(
                'messages:history:response')
            .listen(_handleHistoryMessagesResponse))
        ..add(_communicationService
            .onProto<message_proto.MessageResponse>('message:send:response')
            .listen(_handleMessageSendResponse));

      // 添加通用监听器用于调试
      _logger.i('已注册历史消息事件监听器: messages:history:response');
    } else {
      _logger.i('通信服务未初始化，无法注册事件处理器');
    }
  }

  /// 处理消息已读事件
  void _handleMessageRead(message_proto.MessageReadProto data) {
    try {
      _messageStatusController.add({
        'messageId': data.messageId,
        'conversationId': data.conversationId,
        'status': 'read',
      });
    } catch (error) {
      _logger.e('处理消息已读事件失败', error: error, stackTrace: StackTrace.current);
    }
  }

  /// 处理打字状态事件
  void _handleTypingStatus(message_proto.TypingProto data) {
    try {
      _typingStatusController.add({
        'conversationId': data.conversationId,
        'isTyping': data.isTyping,
      });
    } catch (error) {
      _logger.e('处理打字状态事件失败', error: error, stackTrace: StackTrace.current);
    }
  }

  /// 处理停止打字事件
  void _handleTypingStop(message_proto.TypingProto data) {
    try {
      _typingStatusController.add({
        'conversationId': data.conversationId,
        'isTyping': data.isTyping,
      });
    } catch (error) {
      _logger.e('处理停止打字事件失败', error: error, stackTrace: StackTrace.current);
    }
  }

  /// 处理历史消息响应
  void _handleHistoryMessagesResponse(
      message_proto.HistoryMessagesResponse response) {
    try {
      _logger.i('收到历史消息响应', extra: {
        'conversationId': response.conversationId,
        'messageCount': response.hasMessagesCollection()
            ? response.messagesCollection.messages.length
            : 0,
        'hasMoreHistory': response.hasMoreHistory,
      });

      if (!response.success) {
        _logger.e('历史消息获取失败: ${response.message}');
        return;
      }

      if (!response.hasMessagesCollection()) {
        _logger.w('历史消息响应中没有消息集合');
        return;
      }

      // 将消息保存到本地数据库
      _saveMessagesToLocal(response.messagesCollection.messages);

      // 将消息集合转换为List<Message>
      final messages = response.messagesCollection.messages
          .map((e) => Message.fromProto(e))
          .toList();

      // 将消息通过Stream发送出去
      _messageStatusController.add({
        'type': 'loadMore',
        'conversationId': response.conversationId,
        'messages': messages,
        'hasMoreHistory': response.hasMoreHistory,
      });
    } catch (error) {
      _logger.e('处理历史消息响应失败', error: error, stackTrace: StackTrace.current);
    }
  }

  /// 处理消息同步响应
  void _handleMessageSyncResponse(message_proto.MessageSyncResponse response) {
    try {
      _logger.i('收到消息同步响应', extra: {
        'conversationId': response.conversationId,
        'success': response.success,
        'messageCount': response.messages.messages.length,
      });

      if (!response.success) {
        _logger.e('消息同步失败');
        return;
      }

      // 将消息保存到本地数据库
      _saveMessagesToLocal(response.messages.messages);
    } catch (error) {
      _logger.e('处理消息同步响应失败', error: error, stackTrace: StackTrace.current);
    }
  }

  /// 处理消息发送响应
  void _handleMessageSendResponse(
      message_proto.MessageResponse response) async {
    try {
      _logger.d('收到消息发送响应', extra: {
        'success': response.success,
        'tempId': response.tempId,
        'serverMessageId': response.messageId,
        'message': response.message,
      });

      if (response.tempId.isEmpty) {
        _logger.w('消息发送响应缺少临时ID，无法匹配本地消息');
        return;
      }

      // 查找对应的临时消息
      final tempMessage = await getMessageById(response.tempId);
      if (tempMessage == null) {
        _logger.w('找不到对应的临时消息', extra: {'tempId': response.tempId});
        return;
      }

      if (response.success) {
        // 发送成功，更新消息ID和状态
        await _isar.writeTxn(() async {
          tempMessage.messageId = response.messageId;
          tempMessage.status = 'sent';
          tempMessage.errorMessage = null;
          await _messages.put(tempMessage);
        });

        // 💢💢💢 新增：通知UI层消息发送成功
        _messageStatusController.add({
          'type': 'messageStatusUpdate',
          'messageId': response.tempId, // 使用临时ID，因为UI层还在使用临时ID
          'newMessageId': response.messageId, // 新的服务器ID
          'conversationId': tempMessage.conversationId,
          'status': 'sent',
          'errorMessage': null,
        });

        _logger.i('消息发送成功，已更新本地消息和UI状态', extra: {
          'tempId': response.tempId,
          'serverMessageId': response.messageId,
        });
      } else {
        // 发送失败，标记为失败状态
        final errorMessage =
            response.message.isNotEmpty ? response.message : '服务器处理失败';
        await markMessageAsFailed(response.tempId, errorMessage);

        // 💢💢💢 新增：通知UI层消息发送失败
        _messageStatusController.add({
          'type': 'messageStatusUpdate',
          'messageId': response.tempId,
          'conversationId': tempMessage.conversationId,
          'status': 'failed',
          'errorMessage': errorMessage,
        });

        _logger.w('消息发送失败，已更新本地消息和UI状态', extra: {
          'tempId': response.tempId,
          'errorMessage': errorMessage,
        });
      }
    } catch (error) {
      _logger.e('处理消息发送响应失败', error: error);
    }
  }

  /// 💢💢💢💢💢💢💢💢💢💢💢💢💢💢    Request    💢💢💢💢💢💢💢💢💢💢💢💢💢💢

  Future<void> _requestMoreMessages(
      String conversationId, int limit, DateTime? before) async {
    _logger.i('请求服务器获取更多历史消息', extra: {
      'conversationId': conversationId,
      'limit': limit,
      'before': before?.toIso8601String(),
      'beforeTimestamp': before?.millisecondsSinceEpoch,
    });

    // 创建请求对象
    final request = message_proto.HistoryMessagesRequest()
      ..conversationId = conversationId
      ..limit = limit
      ..beforeTimestamp = $fixnum.Int64(before?.millisecondsSinceEpoch ?? 0)
      ..beforeMessageId = '';

    _logger.d('发送历史消息请求', extra: {
      'event': 'messages:history',
      'conversationId': request.conversationId,
      'limit': request.limit,
      'beforeTimestamp': request.beforeTimestamp.toString(),
    });

    // 发送请求到服务器
    await _communicationService.emitProto('messages:history', request);

    _logger.d('历史消息请求已发送');
  }

  /// 💢💢💢💢💢💢💢💢💢💢💢💢💢💢  Get4Database  💢💢💢💢💢💢💢💢💢💢💢💢💢💢

  /// 获取会话消息
  /// 获取指定会话的消息列表,支持分页
  /// [conversationId] - 会话ID
  /// [limit] - 获取消息的最大数量
  /// [before] - 可选的时间点,获取此时间之前的消息
  /// 返回消息列表
  @override
  Future<void> getConversationMessages(String conversationId,
      {int limit = 50, DateTime? before}) async {
    try {
      _logger.i('获取会话消息', extra: {
        'conversationId': conversationId,
        'limit': limit,
        'before': before?.toIso8601String(),
      });

      // 🔥 优化：利用复合索引 (conversationId + createdAt) 进行高效查询
      final query = _messages
          .filter()
          .conversationIdEqualTo(conversationId)
          .optional(before != null, (q) => q.createdAtLessThan(before!))
          .sortByCreatedAt(); // 最新消息在后

      final messages = await query.limit(limit).findAll();
      messages.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      final hasMoreHistory = messages.length == limit;

      // _logger.d('从数据库获取会话消息完成', extra: {
      //   'conversationId': conversationId,
      //   'foundMessages': messages.length,
      // });

      if (messages.length < limit) {
        if (messages.isNotEmpty) {
          before = messages.last.createdAt;
        }
        _logger.w('从数据库获取会话消息不足', extra: {
          'conversationId': conversationId,
          'foundMessages': messages.length,
          'limit': limit,
        });
        _requestMoreMessages(conversationId, limit, before);
      }

      // 将获取的messages 通过Stream 发送出去
      _messageStatusController.add({
        'type': 'loadMore',
        'conversationId': conversationId,
        'messages': messages,
        'hasMoreHistory': hasMoreHistory,
      });
    } catch (error) {
      _logger.e('获取会话消息失败', error: error, stackTrace: StackTrace.current);
    }
  }

  /// 💢💢💢💢💢💢💢💢💢💢💢💢💢💢  ---  💢💢💢💢💢💢💢💢💢💢💢💢💢💢

  /// 创建消息通用方法
  /// 创建基本的消息对象,设置共同属性
  /// [conversationId] - 会话ID
  /// [text] - 消息文本
  /// [type] - 消息类型
  /// 返回创建的消息对象
  Future<Message> _createMessage(
      String conversationId, String text, String type) async {
    try {
      // 检查当前用户是否已初始化
      if (_currentUser.userId.isEmpty) {
        throw Exception('当前用户未初始化');
      }

      final message = Message();

      // 生成临时messageId
      message.messageId =
          'temp_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';

      message.conversationId = conversationId;
      // 获取当前用户ID
      message.senderId = _currentUser.userId;
      message.senderName = _currentUser.name;
      message.type = type;
      message.text = text.isEmpty ? null : text;
      message.status = 'pending'; // 初始状态为待发送
      message.createdAt = DateTime.now();

      return message;
    } catch (error) {
      _logger.e('创建消息失败', error: error, stackTrace: StackTrace.current);
      rethrow;
    }
  }

  /// 发送文本消息
  /// 创建并发送文本类型的消息
  /// [conversationId] - 会话ID
  /// [text] - 消息文本内容
  /// 返回创建的消息对象
  @override
  Future<Message> sendTextMessage(String conversationId, String text) async {
    final message = await _createMessage(conversationId, text, 'text');
    await sendMessage(message);
    return message;
  }

  /// 发送图片消息
  /// 创建并发送图片类型的消息,可选上传图片
  /// [conversationId] - 会话ID
  /// [localPath] - 图片本地路径
  /// [mediaUrl] - 可选的媒体URL,如已上传则直接使用
  /// 返回创建的消息对象
  @override
  Future<Message> sendImageMessage(String conversationId, String localPath,
      {String? mediaUrl}) async {
    final message = await _createMessage(conversationId, '', 'image');

    if (mediaUrl != null) {
      message.mediaUrl = mediaUrl;
    } else {
      final imageFile = File(localPath);
      // 上传图片
      final uploadResult = await _fileUploadService.uploadImage(imageFile);
      if (uploadResult != null) {
        message.mediaUrl = uploadResult.remoteUrl;
      }
    }
    message.localPath = localPath;

    await sendMessage(message);
    return message;
  }

  /// 发送语音消息
  /// 创建并发送语音类型的消息,可选上传语音文件
  /// [conversationId] - 会话ID
  /// [localPath] - 语音文件本地路径
  /// [duration] - 语音时长（秒）
  /// [mediaUrl] - 可选的媒体URL,如已上传则直接使用
  /// 返回创建的消息对象
  @override
  Future<Message> sendVoiceMessage(
      String conversationId, String localPath, int duration,
      {String? mediaUrl}) async {
    final message = await _createMessage(conversationId, '', 'voice');

    if (mediaUrl != null) {
      message.mediaUrl = mediaUrl;
      message.duration = duration;
    } else {
      final voiceFile = File(localPath);
      // 上传语音
      final uploadResult =
          await _fileUploadService.uploadVoice(voiceFile, duration);
      if (uploadResult != null) {
        message.mediaUrl = uploadResult.remoteUrl;
        if (uploadResult.duration != null) {
          message.duration = uploadResult.duration;
        } else {
          message.duration = duration;
        }
      } else {
        message.duration = duration;
      }
    }
    message.localPath = localPath;

    await sendMessage(message);
    return message;
  }

  /// 发送文件消息
  /// 创建并发送文件类型的消息,可选上传文件
  /// [conversationId] - 会话ID
  /// [localPath] - 文件本地路径
  /// [fileName] - 文件名
  /// [fileSize] - 文件大小
  /// [mediaUrl] - 可选的媒体URL,如已上传则直接使用
  /// 返回创建的消息对象
  @override
  Future<Message> sendFileMessage(
      String conversationId, String localPath, String fileName, double fileSize,
      {String? mediaUrl}) async {
    final message = await _createMessage(conversationId, '', 'file');

    if (mediaUrl != null) {
      message.mediaUrl = mediaUrl;
    } else {
      final file = File(localPath);
      // 上传文件
      final uploadResult = await _fileUploadService.uploadFile(file);
      if (uploadResult != null) {
        message.mediaUrl = uploadResult.remoteUrl;
      }
    }
    message.localPath = localPath;
    message.fileName = fileName;
    message.fileSize = fileSize;

    await sendMessage(message);
    return message;
  }

  /// 发送视频消息
  /// 创建并发送视频类型的消息,可选上传视频文件
  /// [conversationId] - 会话ID
  /// [localPath] - 视频文件本地路径
  /// [duration] - 视频时长（秒）
  /// [thumbnailUrl] - 可选的缩略图URL
  /// [mediaUrl] - 可选的媒体URL,如已上传则直接使用
  /// [isServerProcessed] - 是否由服务器处理缩略图
  /// 返回创建的消息对象
  @override
  Future<Message> sendVideoMessage(
      String conversationId, String localPath, int duration,
      {String? thumbnailUrl,
      String? mediaUrl,
      bool isServerProcessed = false}) async {
    try {
      final message = await _createMessage(conversationId, '', 'video');

      message.localPath = localPath;
      message.mediaUrl = mediaUrl;
      message.thumbnailUrl = thumbnailUrl;
      message.duration = duration;

      // 如果缩略图由服务器处理,且尚未生成,设置状态为处理中
      if (isServerProcessed && thumbnailUrl == null) {
        message.status = 'processing'; // 服务器处理中
      } else {
        message.status = 'pending'; // 正常发送状态
      }

      await _isar.writeTxn(() async {
        message.id = await _messages.put(message);
      });

      // 如果是服务器处理模式且没有缩略图,模拟服务器异步处理
      if (isServerProcessed && thumbnailUrl == null) {
        _simulateServerProcessing(message);
      }

      await sendMessage(message);
      return message;
    } catch (error) {
      _logger.e('发送视频消息失败', error: error, stackTrace: StackTrace.current);
      rethrow;
    }
  }

  /// 发送消息
  Future<String> sendMessage(Message message) async {
    final tempMessageId = message.messageId;

    try {
      // 1. 先保存消息到数据库（状态为pending）
      await _isar.writeTxn(() async {
        message.status = 'sending';
        message.id = await _isar.messages.put(message);
      });

      _logger.d('开始发送消息', extra: {
        'tempMessageId': tempMessageId,
        'conversationId': message.conversationId,
        'type': message.type,
      });

      // 2. 创建Proto对象用于发送
      final protoMsg = message.toProto();

      // 3. 发送消息到服务器并等待响应
      final serverResponse =
          await _sendMessageWithRetry(protoMsg, tempMessageId);

      if (serverResponse != null) {
        // 4. 检查服务器响应是否成功
        if (serverResponse.success) {
          // 发送成功，更新消息状态和服务器返回的messageId
          await _updateMessageAfterSend(message, serverResponse);

          _logger.i('消息发送成功', extra: {
            'tempMessageId': tempMessageId,
            'serverMessageId': serverResponse.messageId,
          });

          return serverResponse.messageId;
        } else {
          // 服务器返回失败
          final errorMessage =
              serverResponse.hasMessage() ? serverResponse.message : '服务器处理失败';
          await _markMessageAsFailed(message, errorMessage);
          throw MessageException('发送消息失败: $errorMessage');
        }
      } else {
        // 5. 发送失败，更新状态
        await _markMessageAsFailed(message, '服务器无响应');
        throw MessageException('发送消息失败: 服务器无响应');
      }
    } catch (error) {
      _logger.e('发送消息失败',
          extra: {'tempMessageId': tempMessageId, 'error': error.toString()});

      // 更新消息状态为失败
      await _markMessageAsFailed(message, error.toString());

      if (error is MessageException) {
        rethrow;
      } else {
        throw MessageException('发送消息失败: ${error.toString()}');
      }
    }
  }

  /// 带重试机制的消息发送
  Future<message_proto.MessageResponse?> _sendMessageWithRetry(
    message_proto.MessageProto protoMsg,
    String tempMessageId, {
    int maxRetries = 3,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        _logger.d('发送消息尝试', extra: {
          'attempt': attempt,
          'maxRetries': maxRetries,
          'tempMessageId': tempMessageId,
        });

        // 在发送的消息中包含临时ID，方便服务器匹配响应
        final messageToSend = message_proto.MessageProto()
          ..mergeFromMessage(protoMsg)
          ..messageId = tempMessageId; // 使用临时ID

        // 发送消息
        _communicationService.emitProto('message:send', messageToSend);

        // 等待服务器响应 - 使用MessageResponse格式
        final response = await _communicationService
            .onProto<message_proto.MessageResponse>('message:send:response')
            .where((response) =>
                // 可以通过时间戳或其他方式匹配响应
                response.hasTimestamp() &&
                response.timestamp.toInt() >=
                    (DateTime.now().millisecondsSinceEpoch - 30000)) // 30秒内的响应
            .timeout(timeout)
            .first;

        _logger.d('收到服务器响应', extra: {
          'tempMessageId': tempMessageId,
          'success': response.success,
          'serverMessageId': response.messageId,
          'attempt': attempt,
        });

        return response;
      } catch (error) {
        _logger.w('发送消息失败，尝试 $attempt/$maxRetries', extra: {
          'tempMessageId': tempMessageId,
          'error': error.toString(),
        });

        if (attempt == maxRetries) {
          // 最后一次尝试失败
          rethrow;
        }

        // 等待一段时间后重试
        await Future.delayed(Duration(seconds: attempt * 2));
      }
    }

    return null;
  }

  /// 搜索消息
  /// 根据关键词搜索消息
  /// [keyword] - 搜索关键词
  /// [conversationId] - 可选的会话ID,限定搜索范围
  /// 返回匹配的消息列表
  @override
  Future<List<Message>> searchMessages(String keyword,
      {String? conversationId}) async {
    try {
      if (keyword.isEmpty) {
        return [];
      }

      final query = _messages
          .filter()
          .optional(conversationId != null,
              (q) => q.conversationIdEqualTo(conversationId!))
          .and()
          .typeEqualTo('text') // 💢💢💢 只搜索文本类型的消息
          .and()
          .optional(keyword.isNotEmpty,
              (q) => q.textContains(keyword, caseSensitive: false));

      final messages = await query.sortByCreatedAtDesc().findAll();

      _logger.d('搜索消息完成', extra: {
        'keyword': keyword,
        'conversationId': conversationId,
        'resultCount': messages.length,
      });

      return messages;
    } catch (error) {
      _logger.e('搜索消息失败', error: error, stackTrace: StackTrace.current);
      return [];
    }
  }

  /// 💢💢💢 根据消息ID标记该消息及之前的非自己的消息为已读
  /// [conversationId] - 会话ID
  /// [messageId] - 消息ID
  /// 返回void
  @override
  Future<void> markMessagesAsReadBySelf(
      String conversationId, String messageId) async {
    try {
      final List<String> updatedMessageIds = [];

      await _isar.writeTxn(() async {
        // 首先获取指定消息的时间戳
        final targetMessage = await _messages
            .filter()
            .conversationIdEqualTo(conversationId)
            .and()
            .messageIdEqualTo(messageId)
            .findFirst();

        if (targetMessage == null) {
          _logger.w('目标消息不存在', extra: {'messageId': messageId});
          return;
        }

        // 标记该消息及之前的所有非自己的未读消息为已读
        final unreadMessages = await _messages
            .filter()
            .conversationIdEqualTo(conversationId)
            .and()
            .createdAtLessThan(
                targetMessage.createdAt.add(const Duration(seconds: 1)))
            .and()
            .not()
            .senderIdEqualTo(_currentUser.userId) // 排除当前用户发送的消息
            .and()
            .group(
                (q) => q.statusEqualTo('sent').or().statusEqualTo('delivered'))
            .findAll();

        for (final message in unreadMessages) {
          message.status = 'read';
          await _messages.put(message);
          updatedMessageIds.add(message.messageId);
        }

        _logger.d('标记非自己的消息为已读',
            extra: {
              'conversationId': conversationId,
              'targetMessageId': messageId,
              'currentUserId': _currentUser.userId,
              'updatedCount': updatedMessageIds.length,
            },
            stackTrace: StackTrace.current);
      });
    } catch (error) {
      _logger.e('标记消息为已读失败', error: error, stackTrace: StackTrace.current);
    }
  }

  /// 💢💢💢 根据消息ID标记该消息及之前的消息为其他用户已读
  /// [conversationId] - 会话ID
  /// [messageId] - 消息ID
  /// 返回void
  @override
  Future<void> markMessagesAsReadByOther(
      String conversationId, String messageId) async {
    try {
      final List<String> updatedMessageIds = [];

      await _isar.writeTxn(() async {
        // 首先获取指定消息的时间戳
        final targetMessage = await _messages
            .filter()
            .conversationIdEqualTo(conversationId)
            .and()
            .messageIdEqualTo(messageId)
            .findFirst();

        if (targetMessage == null) {
          _logger.w('目标消息不存在', extra: {'messageId': messageId});
          return;
        }

        // 标记该消息及之前的当前用户发送的消息为已读（表示其他用户已读）
        final messagesToUpdate = await _messages
            .filter()
            .conversationIdEqualTo(conversationId)
            .and()
            .createdAtLessThan(
                targetMessage.createdAt.add(const Duration(seconds: 1)))
            .and()
            .senderIdEqualTo(_currentUser.userId) // 只处理当前用户发送的消息
            .and()
            .group(
                (q) => q.statusEqualTo('sent').or().statusEqualTo('delivered'))
            .findAll();

        for (final message in messagesToUpdate) {
          message.status = 'read';
          await _messages.put(message);
          updatedMessageIds.add(message.messageId);
        }

        _logger.i('标记自己的消息为其他用户已读', extra: {
          'conversationId': conversationId,
          'targetMessageId': messageId,
          'currentUserId': _currentUser.userId,
          'updatedCount': updatedMessageIds.length,
        });
      });
    } catch (error) {
      _logger.e('标记消息为其他用户已读失败', error: error, stackTrace: StackTrace.current);
    }
  }

  /// 标记消息发送失败
  Future<void> _markMessageAsFailed(Message message, String errorReason) async {
    try {
      await _isar.writeTxn(() async {
        message.status = 'failed';
        message.errorMessage = errorReason;
        await _isar.messages.put(message);
      });

      // 💢💢💢 新增：通知UI层消息发送失败
      _messageStatusController.add({
        'type': 'messageStatusUpdate',
        'messageId': message.messageId,
        'conversationId': message.conversationId,
        'status': 'failed',
        'errorMessage': errorReason,
      });

      _logger.w('消息标记为失败，已更新本地消息和UI状态', extra: {
        'messageId': message.messageId,
        'errorMessage': errorReason,
      });
    } catch (error) {
      _logger.e('标记消息失败状态时出错', error: error);
    }
  }

  /// 删除消息
  /// 删除指定的消息及其相关的媒体文件
  /// [messageId] - 消息ID
  @override
  Future<void> deleteMessage(String messageId) async {
    try {
      // 使用messageId字段查询，而不是尝试转换为整数ID
      final message =
          await _messages.filter().messageIdEqualTo(messageId).findFirst();
      if (message == null) {
        throw Exception('找不到要删除的消息');
      }

      // 用于存储要删除的文件路径
      final filesToDelete = _collectMediaFilePaths(message);

      // 在数据库事务中删除消息
      await _isar.writeTxn(() async {
        // 使用消息的Isar ID删除
        final success = await _messages.delete(message.id);
        if (!success) {
          throw Exception('删除消息失败');
        }
      });

      // 删除关联的媒体文件
      await _deleteMediaFiles(filesToDelete);
    } catch (error) {
      _logger.e('删除消息失败', error: error, stackTrace: StackTrace.current);
      rethrow;
    }
  }

  /// 收集消息中的媒体文件路径
  /// 分析消息对象,收集需要删除的媒体文件路径
  /// [message] - 消息对象
  /// 返回文件路径列表
  List<String> _collectMediaFilePaths(Message message) {
    final filesToDelete = <String>[];

    if (message.type == 'image' ||
        message.type == 'video' ||
        message.type == 'voice' ||
        message.type == 'file') {
      // 检查本地文件路径
      if (message.localPath != null && message.localPath!.isNotEmpty) {
        filesToDelete.add(message.localPath!);
      }

      // 检查媒体URL（如果是本地file://）
      if (message.mediaUrl != null && message.mediaUrl!.startsWith('file://')) {
        filesToDelete.add(message.mediaUrl!.substring(7)); // 移除file://前缀
      }

      // 检查缩略图URL（如果是本地file://）
      if (message.thumbnailUrl != null &&
          message.thumbnailUrl!.startsWith('file://')) {
        filesToDelete.add(message.thumbnailUrl!.substring(7)); // 移除file://前缀
      }
    }

    return filesToDelete;
  }

  /// 删除媒体文件
  /// 删除指定路径列表中的所有文件
  /// [filePaths] - 文件路径列表
  Future<void> _deleteMediaFiles(List<String> filePaths) async {
    for (final filePath in filePaths) {
      try {
        final file = File(filePath);
        if (await file.exists()) {
          await file.delete();
          _logger.d('已删除媒体文件', extra: {'path': filePath});
        }
      } catch (fileError) {
        // 文件删除失败,但不要中断整个删除过程
        _logger.w('删除媒体文件失败',
            extra: {'path': filePath, 'error': fileError.toString()});
      }
    }
  }

  /// 按日期范围获取消息
  /// 获取指定会话中特定日期范围内的消息
  /// [conversationId] - 会话ID
  /// [startDate] - 开始日期
  /// [endDate] - 结束日期
  /// [limit] - 消息数量限制
  /// 返回符合条件的消息列表
  @override
  Future<List<Message>> getMessagesByDateRange(
    String conversationId,
    DateTime startDate,
    DateTime endDate, {
    int limit = 50,
  }) async {
    try {
      // 确保转换为有效的DateTime对象,避免日期比较问题
      final safeStartDate = DateTime.utc(
        startDate.year,
        startDate.month,
        startDate.day,
      );
      final safeEndDate = DateTime.utc(
        endDate.year,
        endDate.month,
        endDate.day,
        23,
        59,
        59,
      );

      _logger.d('按日期范围查询消息', extra: {
        '会话ID': conversationId,
        '开始日期': safeStartDate.toString(),
        '结束日期': safeEndDate.toString(),
        '限制': limit
      });

      // 查询指定日期范围内的消息
      final messages = await _messages
          .filter()
          .conversationIdEqualTo(conversationId)
          .createdAtBetween(safeStartDate, safeEndDate)
          .sortByCreatedAtDesc() // 按时间降序排序
          .limit(limit)
          .findAll();

      _logger.d('按日期范围查询结果', extra: {'找到消息数': messages.length});
      return messages;
    } catch (error) {
      _logger.e('根据日期范围获取消息失败', error: error, stackTrace: StackTrace.current);
      return [];
    }
  }

  /// 从指定日期获取会话消息
  /// 获取从指定日期开始的会话消息
  /// [conversationId] - 会话ID
  /// [startDate] - 开始日期
  /// [limit] - 消息数量限制
  /// 返回符合条件的消息列表
  @override
  Future<List<Message>> getConversationMessagesFromDate(
    String conversationId,
    DateTime startDate, {
    int limit = 30,
  }) async {
    try {
      // 确保使用日期的开始时间
      final dayStart =
          DateTime(startDate.year, startDate.month, startDate.day, 0, 0, 0);

      // 查询从指定日期开始的消息
      final messages = await _messages
          .filter()
          .conversationIdEqualTo(conversationId)
          .createdAtGreaterThan(
              dayStart.subtract(const Duration(seconds: 1))) // 大于等于指定日期
          .sortByCreatedAtDesc() // 按时间降序排序,确保最旧的消息在前
          .limit(limit)
          .findAll();

      _logger.d('从日期获取消息结果', extra: {'找到消息数': messages.length});
      return messages;
    } catch (error) {
      _logger.e('从指定日期获取消息失败', error: error, stackTrace: StackTrace.current);
      return [];
    }
  }

  /// 💢 从服务器获取历史消息
  /// 当本地数据库没有消息或需要加载更多历史消息时使用
  /// [conversationId] - 会话 ID
  /// [before] - 可选，获取此时间之前的消息
  /// [limit] - 可选，每次获取的消息数量限制，默认 20 条
  @override
  Future<List<Message>> fetchHistoryMessages(String conversationId,
      {DateTime? before, int limit = 20}) async {
    try {
      _logger.i('从服务器获取历史消息', extra: {
        'conversationId': conversationId,
        'before': before?.toIso8601String(),
        'limit': limit
      });

      // 创建请求对象
      final request = message_proto.MessageProto()
        ..conversationId = conversationId;

      // 发送请求到服务器
      await _communicationService.emitProto('messages:fetch', request);

      // 等待响应
      final response = await _communicationService
          .onProto<message_proto.MessageCollection>('messages:fetch:response')
          .first;

      // 检查响应消息列表是否为空
      if (response.messages.isEmpty) {
        _logger.i('服务器返回空消息列表');
        return [];
      }

      // 转换服务器响应为消息列表
      final messages = response.messages.map((msg) {
        final message = Message()
          ..messageId = msg.messageId
          ..conversationId = msg.conversationId
          ..senderId = msg.senderId
          ..createdAt =
              DateTime.fromMillisecondsSinceEpoch(msg.createdAt.toInt())
          ..text = msg.text
          ..type = msg.type.toString()
          ..status = 'received';

        // 处理媒体消息的特殊字段
        if (msg.hasMediaUrl()) {
          message.mediaUrl = msg.mediaUrl;
        }

        if (msg.hasDuration()) {
          message.duration = msg.duration.toInt();
        }

        if (msg.hasFileName()) {
          message.fileName = msg.fileName;
        }

        if (msg.hasFileSize()) {
          message.fileSize = msg.fileSize;
        }

        if (msg.hasThumbnailUrl()) {
          message.thumbnailUrl = msg.thumbnailUrl;
        }

        // 保存消息到本地数据库
        _isar.writeTxn(() async {
          message.id = await _messages.put(message);
        });

        return message;
      }).toList();

      _logger.i('从服务器获取历史消息成功', extra: {'count': messages.length});
      return messages;
    } catch (error) {
      _logger.e('从服务器获取历史消息失败', error: error, stackTrace: StackTrace.current);
      return [];
    }
  }

  /// 从服务器获取消息
  /// 获取指定会话的消息列表,支持分页
  /// [conversationId] - 会话ID
  /// [limit] - 获取消息的最大数量
  /// [before] - 可选的时间点,获取此时间之前的消息
  /// 返回消息列表
  @override
  Future<List<Message>> fetchMessagesFromServer(String conversationId,
      {int limit = 20, DateTime? before}) async {
    try {
      _logger.i('从服务器获取消息',
          extra: {'conversationId': conversationId, 'limit': limit});

      // 创建请求参数
      final request = message_proto.MessageProto()
        ..conversationId = conversationId
        ..text = 'fetch'; // 用作临时标记

      if (before != null) {
        request.createdAt = $fixnum.Int64(before.millisecondsSinceEpoch);
      }

      // 发送请求到服务器
      await _communicationService.emitProto('messages:fetch', request);

      // 等待响应
      final response = await _communicationService
          .onProto<message_proto.MessageCollection>('messages:fetch:response')
          .first;

      // 转换服务器响应为消息列表
      final messages = response.messages.map((msg) {
        final message = Message()
          ..messageId = msg.messageId
          ..conversationId = msg.conversationId
          ..senderId = msg.senderId
          ..createdAt =
              DateTime.fromMillisecondsSinceEpoch(msg.createdAt.toInt())
          ..text = msg.text
          ..type = msg.type.toString()
          ..status = 'received';

        // 保存消息到本地数据库
        _isar.writeTxn(() async {
          message.id = await _messages.put(message);
        });

        return message;
      }).toList();

      _logger.i('从服务器获取消息成功', extra: {'count': messages.length});
      return messages;
    } catch (error) {
      _logger.e('从服务器获取消息失败', error: error, stackTrace: StackTrace.current);
      return [];
    }
  }

  /// 💢💢💢💢💢💢💢💢💢💢💢💢💢💢  获取输入状态流  💢💢💢💢💢💢💢💢💢💢💢💢💢💢

  /// 发送正在输入状态
  /// 通知其他用户当前用户的输入状态
  /// [conversationId] - 会话ID
  /// [isTyping] - 是否正在输入
  @override
  Future<void> sendTypingStatus(String conversationId, bool isTyping) async {
    if (_communicationService.isInitialized) {
      try {
        final typingProto = message_proto.TypingProto()
          ..conversationId = conversationId
          ..isTyping = isTyping;

        _communicationService.emitProto(
            isTyping ? 'user:typing' : 'user:typing:stop', typingProto);
        return;
      } catch (error) {
        _logger.e('发送打字状态失败', error: error, stackTrace: StackTrace.current);
      }
    }

    _logger.w('通信服务未初始化,无法发送输入状态');
  }

  /// 获取输入状态流
  /// 返回用户输入状态变化的流
  @override
  Stream<Map<String, dynamic>> getTypingStatusStream() {
    return _typingStatusController.stream;
  }

  /// 获取消息状态流
  /// 返回消息状态变化的流
  @override
  Stream<Map<String, dynamic>> getMessageStatusStream() {
    return _messageStatusController.stream;
  }

  /// 💢💢💢💢💢💢💢💢💢💢💢💢💢💢    其他功能    💢💢💢💢💢💢💢💢💢💢💢💢💢💢

  /// 清空会话消息
  @override
  Future<void> clearConversationMessages(String conversationId) async {
    try {
      _logger.i('清空会话消息', extra: {'conversationId': conversationId});

      await _isar.writeTxn(() async {
        // 删除该会话的所有消息
        await _messages
            .filter()
            .conversationIdEqualTo(conversationId)
            .deleteAll();
      });

      _logger.i('会话消息清空成功', extra: {'conversationId': conversationId});
    } catch (error) {
      _logger.e('清空会话消息失败', error: error);
      rethrow;
    }
  }

  /// 用户进入会话页面
  /// 将用户加入对应的Socket.io会话房间，并自动标记会话为已读
  /// [conversationId] - 会话ID
  @override
  Future<void> joinConversationRoom(String conversationId) async {
    try {
      _logger.i('用户进入会话页面', extra: {'conversationId': conversationId});

      // 🔥 将会话加入活跃会话集合
      _activeConversations.add(conversationId);

      // 🔥 进入会话时自动更新最后阅读时间（不同步到服务器，仅更新本地）
      // TODO 需要通过ChatsRepository来更新
      _logger.d('用户进入会话页面，需要更新最后阅读时间');

      // 通知服务器用户加入会话房间
      if (_communicationService.isInitialized) {
        final joinRoomRequest =
            conversation_proto.ConversationJoinLeaveRequest()
              ..conversationId = conversationId;

        _communicationService.emitProto('conversation:join', joinRoomRequest);
        _logger.d('已发送加入会话房间请求');
      } else {
        _logger.w('通信服务未初始化，无法发送加入会话房间请求');
      }
    } catch (error) {
      _logger.e('加入会话房间失败', error: error, stackTrace: StackTrace.current);
    }
  }

  /// 用户离开会话页面
  /// 将用户从对应的Socket.io会话房间中移除，并同步阅读状态到服务器
  /// [conversationId] - 会话ID
  @override
  Future<void> leaveConversationRoom(String conversationId) async {
    try {
      _logger.i('用户离开会话页面', extra: {'conversationId': conversationId});

      // 🔥 将会话从活跃会话集合中移除
      _activeConversations.remove(conversationId);

      // 🔥 退出会话时，同步最后阅读时间到服务器
      // TODO 需要通过ChatsRepository来更新
      _logger.d('用户离开会话页面，需要同步阅读状态到服务器');

      // 通知服务器用户离开会话房间
      if (_communicationService.isInitialized) {
        final leaveRoomRequest =
            conversation_proto.ConversationJoinLeaveRequest()
              ..conversationId = conversationId;

        _communicationService.emitProto('conversation:leave', leaveRoomRequest);
        _logger.d('已发送离开会话房间请求');
      }
    } catch (error) {
      _logger.e('离开会话房间失败', error: error, stackTrace: StackTrace.current);
    }
  }

  /// 💢💢💢💢💢💢💢💢💢💢💢💢💢💢      ToDo      💢💢💢💢💢💢💢💢💢💢💢💢💢💢

  /// 模拟服务器处理视频缩略图
  /// 这是一个临时方法，实际应该由服务器完成
  /// [message] - 需要处理缩略图的消息
  void _simulateServerProcessing(Message message) {
    // 空实现，实际项目中应该由服务器处理
    _logger.d('模拟服务器处理视频缩略图', extra: {'messageId': message.messageId});
  }

  /// 释放资源
  /// 取消所有订阅并关闭流控制器
  void dispose() {
    _logger.i('销毁ChatRepository');
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    _typingStatusController.close();
    _messageStatusController.close();
    _scrollPositionController.close();
  }

  /// 💢💢💢💢💢💢💢💢💢💢💢💢💢💢   消息同步方法   💢💢💢💢💢💢💢💢💢💢💢💢💢💢

  /// 检查消息是否存在于本地
  @override
  Future<bool> isMessageExistsLocally(
      String conversationId, String messageId) async {
    try {
      final message = await _messages
          .filter()
          .conversationIdEqualTo(conversationId)
          .and()
          .messageIdEqualTo(messageId)
          .findFirst();

      return message != null;
    } catch (error) {
      _logger.e('检查消息是否存在失败', error: error);
      return false;
    }
  }

  /// 检查会话是否有本地消息
  @override
  Future<bool> hasLocalMessages(String conversationId) async {
    try {
      final count = await _messages
          .filter()
          .conversationIdEqualTo(conversationId)
          .count();

      return count > 0;
    } catch (error) {
      _logger.e('检查会话是否有本地消息失败', error: error);
      return false;
    }
  }

  /// 💢💢💢💢💢💢💢💢💢💢💢💢💢💢   私有辅助方法   💢💢💢💢💢💢💢💢💢💢💢💢💢💢

  /// 保存消息到本地数据库
  Future<int> _saveMessagesToLocal(
      List<message_proto.MessageProto> protoMessages) async {
    if (protoMessages.isEmpty) return 0;

    try {
      int savedCount = 0;

      await _isar.writeTxn(() async {
        for (final protoMsg in protoMessages) {
          // 检查消息是否已存在
          final existing = await _messages
              .filter()
              .messageIdEqualTo(protoMsg.messageId)
              .findFirst();

          if (existing == null) {
            // 消息不存在，转换并保存
            final message = Message.fromProto(protoMsg);
            await _messages.put(message);
            savedCount++;
          }
          // 如果消息已存在，覆盖保存
          else {
            final message = Message.fromProto(protoMsg);
            message.id = existing.id;
            await _messages.put(message);
            savedCount++;
          }
        }
      });

      // _logger.d('保存消息到本地数据库', extra: {
      //   'totalReceived': protoMessages.length,
      //   'savedCount': savedCount,
      //   'skippedCount': protoMessages.length - savedCount,
      // });

      return savedCount;
    } catch (error) {
      _logger.e('保存消息到本地数据库失败', error: error);
      return 0;
    }
  }

  /// 批量同步多个会话的消息
  @override
  Future<List<bool>> batchSyncMessages(
    List<ConversationSyncTask> syncTasks, {
    int maxConcurrent = 3,
  }) async {
    _logger.i('批量同步消息（游标模式）', extra: {
      'taskCount': syncTasks.length,
      'maxConcurrent': maxConcurrent,
    });

    final results = <bool>[];
    final semaphore = Semaphore(maxConcurrent);

    // 并发执行同步任务
    final futures = syncTasks.map((task) async {
      await semaphore.acquire();
      try {
        final result = await _executeCursorSyncTask(task);
        return result.success;
      } finally {
        semaphore.release();
      }
    });

    results.addAll(await Future.wait(futures));
    return results;
  }

  /// 执行游标同步任务
  Future<CursorSyncResult> _executeCursorSyncTask(
      ConversationSyncTask task) async {
    final conversationId = task.conversationId;
    final syncType = task.type;
    final limit = task.limit ?? 20;

    _logger.d('执行游标同步任务', extra: {
      'conversationId': conversationId,
      'syncType': syncType.name,
      'limit': limit,
    });

    switch (syncType) {
      case message_proto.MessageSyncType.INITIAL_LOAD:
        return await syncMessagesInitial(conversationId, limit: limit);

      case message_proto.MessageSyncType.CURSOR_FORWARD:
        // 获取同步游标作为起点
        final syncCursor = await getSyncCursor(conversationId);
        return await syncMessagesForward(
          conversationId,
          cursor: syncCursor.isEmpty ? null : syncCursor,
          limit: limit,
        );

      case message_proto.MessageSyncType.CURSOR_BACKWARD:
        // 获取本地游标作为起点
        final localCursor = await getLocalCursor(conversationId);
        return await syncMessagesBackward(
          conversationId,
          cursor: localCursor.isEmpty ? null : localCursor,
          limit: limit,
        );

      case message_proto.MessageSyncType.CURSOR_AROUND:
        // 双向同步需要明确的游标位置
        if (task.cursor != null && task.cursor!.isValid) {
          return await syncMessagesAround(
            conversationId,
            cursor: task.cursor!,
            beforeCount: 10, // 使用默认值
            afterCount: 10, // 使用默认值
            includeCursor: true, // 使用默认值
          );
        } else {
          _logger.w('双向同步缺少有效游标，降级为初始加载', extra: {
            'conversationId': conversationId,
          });
          return await syncMessagesInitial(conversationId, limit: limit);
        }

      case message_proto.MessageSyncType.RECENT:
      case message_proto.MessageSyncType.UNREAD:
        // 旧的同步类型，转换为游标模式
        _logger.w('使用已废弃的同步类型，转换为游标模式', extra: {
          'conversationId': conversationId,
          'oldSyncType': syncType.name,
        });

        // 检查是否有本地消息来决定使用哪种策略
        final hasLocal = await hasLocalMessages(conversationId);
        if (hasLocal) {
          final syncCursor = await getSyncCursor(conversationId);
          return await syncMessagesForward(
            conversationId,
            cursor: syncCursor.isEmpty ? null : syncCursor,
            limit: limit,
          );
        } else {
          return await syncMessagesInitial(conversationId, limit: limit);
        }

      default:
        _logger.e('未知的同步类型', extra: {
          'conversationId': conversationId,
          'syncType': syncType.name,
        });
        return CursorSyncResult.failure(
          conversationId: conversationId,
          errorMessage: '未知的同步类型: ${syncType.name}',
        );
    }
  }

  /// 发送成功后更新消息
  Future<void> _updateMessageAfterSend(
      Message message, message_proto.MessageResponse serverResponse) async {
    try {
      await _isar.writeTxn(() async {
        // 更新消息ID和状态
        message.messageId = serverResponse.messageId;
        message.status = 'sent';

        // 如果服务器返回了时间戳，使用服务器时间
        if (serverResponse.hasTimestamp()) {
          message.createdAt = DateTime.fromMillisecondsSinceEpoch(
              serverResponse.timestamp.toInt());
        }

        await _isar.messages.put(message);
      });
    } catch (error) {
      _logger.e('更新消息状态失败', error: error);
    }
  }

  /// 重新发送失败的消息
  @override
  Future<String> resendMessage(String messageId) async {
    try {
      // 获取失败的消息
      final message = await getMessageById(messageId);
      if (message == null) {
        throw Exception('找不到要重发的消息');
      }

      // 重置消息状态
      await updateMessageStatus(messageId, 'sending');

      // 重新发送
      await sendMessageWithTimeout(message);

      return messageId;
    } catch (error) {
      _logger.e('重发消息失败', error: error);
      rethrow;
    }
  }

  /// 创建临时消息（用于发送前显示）
  @override
  Future<Message> createTempMessage(
      String conversationId, String content, String type) async {
    final message = await _createMessage(conversationId, content, type);

    // 检查数据库是否已初始化
    if (_isar.isOpen) {
      // 保存到数据库，状态为sending
      await _isar.writeTxn(() async {
        message.status = 'sending';
        message.id = await _messages.put(message);
      });
    } else {
      // 数据库未初始化，只设置状态
      message.status = 'sending';
    }

    _logger.d('创建临时消息', extra: {
      'tempMessageId': message.messageId,
      'conversationId': conversationId,
      'type': type,
      'dbInitialized': _isar.isOpen,
    });

    return message;
  }

  /// 发送消息（带超时机制，不等待响应）
  @override
  Future<void> sendMessageWithTimeout(Message message,
      {Duration timeout = const Duration(seconds: 5)}) async {
    final tempMessageId = message.messageId;

    try {
      _logger.d('发送消息（超时机制）', extra: {
        'tempMessageId': tempMessageId,
        'conversationId': message.conversationId,
        'type': message.type,
        'timeout': timeout.inSeconds,
      });

      // 1. 更新消息状态为发送中
      await _updateMessageStatus(message, 'sending');

      // 2. 创建Proto对象用于发送
      final protoMsg = message.toProto();

      // 3. 发送消息到服务器（不等待响应）
      _communicationService.emitProto('message:send', protoMsg);

      // 4. 启动超时计时器
      Timer(timeout, () async {
        try {
          // 检查消息是否仍然是sending状态
          final currentMessage = await getMessageById(tempMessageId);
          if (currentMessage != null && currentMessage.status == 'sending') {
            // 超时，标记为失败
            await markMessageAsFailed(tempMessageId, '发送超时，请检查网络连接');

            // 💢💢💢 新增：通知UI层消息发送超时
            _messageStatusController.add({
              'type': 'messageStatusUpdate',
              'messageId': tempMessageId,
              'conversationId': currentMessage.conversationId,
              'status': 'failed',
              'errorMessage': '发送超时，请检查网络连接',
            });

            _logger.w('消息发送超时，已更新本地消息和UI状态', extra: {
              'tempMessageId': tempMessageId,
              'timeout': timeout.inSeconds,
            });
          }
        } catch (error) {
          _logger.e('处理消息超时时出错', error: error);
        }
      });

      _logger.d('消息发送请求已发出', extra: {
        'tempMessageId': tempMessageId,
        'willTimeoutIn': timeout.inSeconds,
      });
    } catch (error) {
      _logger.e('发送消息失败', error: error, extra: {
        'tempMessageId': tempMessageId,
      });

      // 标记消息为失败状态
      await markMessageAsFailed(tempMessageId, '发送失败: ${error.toString()}');

      // 💢💢💢 新增：通知UI层消息发送失败
      final currentMessage = await getMessageById(tempMessageId);
      if (currentMessage != null) {
        _messageStatusController.add({
          'type': 'messageStatusUpdate',
          'messageId': tempMessageId,
          'conversationId': currentMessage.conversationId,
          'status': 'failed',
          'errorMessage': '发送失败: ${error.toString()}',
        });
      }

      rethrow;
    }
  }

  /// 更新消息状态（内部方法）
  Future<void> _updateMessageStatus(Message message, String status) async {
    try {
      await _isar.writeTxn(() async {
        message.status = status;
        if (status != 'failed') {
          message.errorMessage = null; // 清除错误信息
        }
        await _messages.put(message);
      });

      _logger.d('消息状态已更新', extra: {
        'messageId': message.messageId,
        'status': status,
      });
    } catch (error) {
      _logger.e('更新消息状态失败', error: error);
    }
  }

  /// 标记消息为失败状态
  @override
  Future<void> markMessageAsFailed(String messageId, String errorReason) async {
    try {
      final message = await getMessageById(messageId);
      if (message == null) {
        _logger.w('标记失败：找不到消息', extra: {'messageId': messageId});
        return;
      }

      await _isar.writeTxn(() async {
        message.status = 'failed';
        message.errorMessage = errorReason;
        await _messages.put(message);
      });

      _logger.d('消息已标记为失败', extra: {
        'messageId': messageId,
        'errorReason': errorReason,
      });
    } catch (error) {
      _logger.e('标记消息失败状态时出错', error: error);
    }
  }

  /// 根据消息ID获取消息
  @override
  Future<Message?> getMessageById(String messageId) async {
    try {
      return await _messages.filter().messageIdEqualTo(messageId).findFirst();
    } catch (error) {
      _logger.e('获取消息失败', error: error);
      return null;
    }
  }

  /// 更新消息状态
  @override
  Future<void> updateMessageStatus(String messageId, String status) async {
    try {
      final message = await getMessageById(messageId);
      if (message == null) {
        _logger.w('更新状态：找不到消息', extra: {'messageId': messageId});
        return;
      }

      await _isar.writeTxn(() async {
        message.status = status;
        message.errorMessage = null; // 清除错误信息
        await _messages.put(message);
      });

      _logger.d('消息状态已更新', extra: {
        'messageId': messageId,
        'status': status,
      });
    } catch (error) {
      _logger.e('更新消息状态失败', error: error);
    }
  }

  /// 清理重复消息数据
  @override
  Future<int> cleanupDuplicateMessages(String conversationId) async {
    try {
      _logger.i('开始清理重复消息', extra: {'conversationId': conversationId});

      // 获取所有消息，按messageId分组
      final allMessages = await _messages
          .filter()
          .conversationIdEqualTo(conversationId)
          .sortByCreatedAt()
          .findAll();

      final messageGroups = <String, List<Message>>{};

      // 按messageId分组
      for (final message in allMessages) {
        if (message.messageId.isNotEmpty) {
          messageGroups.putIfAbsent(message.messageId, () => []).add(message);
        }
      }

      int removedCount = 0;

      await _isar.writeTxn(() async {
        for (final group in messageGroups.values) {
          if (group.length > 1) {
            // 保留最新的消息，删除其他重复的
            group.sort((a, b) => b.createdAt.compareTo(a.createdAt));

            for (int i = 1; i < group.length; i++) {
              await _messages.delete(group[i].id);
              removedCount++;
            }
          }
        }
      });

      _logger.i('清理重复消息完成', extra: {
        'conversationId': conversationId,
        'removedCount': removedCount,
      });

      return removedCount;
    } catch (error) {
      _logger.e('清理重复消息失败', error: error);
      return 0;
    }
  }

  /// 验证消息数据一致性
  @override
  Future<Map<String, dynamic>> validateMessageConsistency(
      String conversationId) async {
    try {
      _logger.i('验证消息数据一致性', extra: {'conversationId': conversationId});

      final allMessages = await _messages
          .filter()
          .conversationIdEqualTo(conversationId)
          .findAll();

      int totalMessages = allMessages.length;
      int duplicateMessages = 0;
      int invalidMessages = 0;
      int orphanedMessages = 0;

      final messageIds = <String>{};

      for (final message in allMessages) {
        // 检查重复messageId
        if (message.messageId.isNotEmpty) {
          if (messageIds.contains(message.messageId)) {
            duplicateMessages++;
          } else {
            messageIds.add(message.messageId);
          }
        }

        // 检查无效消息
        if (message.messageId.isEmpty ||
            message.conversationId.isEmpty ||
            message.senderId.isEmpty) {
          invalidMessages++;
        }

        // 检查孤立消息（conversationId不匹配）
        if (message.conversationId != conversationId) {
          orphanedMessages++;
        }
      }

      final stats = {
        'conversationId': conversationId,
        'totalMessages': totalMessages,
        'uniqueMessageIds': messageIds.length,
        'duplicateMessages': duplicateMessages,
        'invalidMessages': invalidMessages,
        'orphanedMessages': orphanedMessages,
        'consistencyScore': totalMessages > 0
            ? ((totalMessages -
                        duplicateMessages -
                        invalidMessages -
                        orphanedMessages) /
                    totalMessages *
                    100)
                .toStringAsFixed(1)
            : '100.0',
        'validationTime': DateTime.now().toIso8601String(),
      };

      _logger.i('消息数据一致性验证完成', extra: stats);

      return stats;
    } catch (error) {
      _logger.e('验证消息数据一致性失败', error: error);
      return {
        'error': error.toString(),
        'conversationId': conversationId,
        'validationTime': DateTime.now().toIso8601String(),
      };
    }
  }

  /// 💢💢💢 新增：在数据库中搜索消息并返回结果信息
  /// TODO: 优化搜索逻辑，只搜索文本类型的消息，排除图片、语音、视频、文件等其他类型
  @override
  Future<SearchResult> searchMessagesInDatabase({
    required String query,
    required String conversationId,
    DateTime? dateFilter,
  }) async {
    try {
      _logger.i('在数据库中搜索消息', extra: {
        'query': query,
        'conversationId': conversationId,
        'hasDateFilter': dateFilter != null,
      });

      if (query.trim().isEmpty) {
        return const SearchResult(
          matchedMessageIds: [],
          totalCount: 0,
        );
      }

      // 💢💢💢 新方法：先获取所有消息，然后在内存中进行匹配
      final trimmedQuery = query.trim().toLowerCase();

      // 分割关键词（支持空格分隔的多关键词搜索）
      final keywords = trimmedQuery
          .split(RegExp(r'\s+'))
          .where((keyword) => keyword.isNotEmpty)
          .toList();

      // 构建基础查询（只过滤会话ID和日期）
      var queryBuilder =
          _messages.filter().conversationIdEqualTo(conversationId);

      // 添加日期过滤条件
      if (dateFilter != null) {
        final startOfDay =
            DateTime(dateFilter.year, dateFilter.month, dateFilter.day);
        final endOfDay = startOfDay.add(const Duration(days: 1));

        queryBuilder =
            queryBuilder.and().createdAtBetween(startOfDay, endOfDay);
      }

      // 💢💢💢 先获取所有符合基础条件的消息
      final allMessages = await queryBuilder.sortByCreatedAtDesc().findAll();

      _logger.d('获取基础消息列表', extra: {
        'totalMessages': allMessages.length,
        'keywords': keywords,
      });

      // 💢💢💢 在内存中进行关键词匹配，确保每条消息只被计算一次
      final matchedMessages = <Message>[];
      final processedMessageIds = <String>{};
      int textMessageCount = 0;
      int nonTextMessageCount = 0;

      for (final message in allMessages) {
        // 确保不重复处理同一条消息
        if (processedMessageIds.contains(message.messageId)) {
          continue;
        }

        // 💢💢💢 只搜索文本类型的消息，排除图片、表情符、语音等其他类型
        if (message.type != 'text') {
          nonTextMessageCount++;
          continue;
        }

        textMessageCount++;

        // 💢💢💢 检查消息的多个文本字段是否包含任意一个关键词
        bool isMatch = false;

        // 收集所有可搜索的文本字段
        final searchableTexts = <String>[];

        // 主要文本内容
        if (message.text != null && message.text!.isNotEmpty) {
          searchableTexts.add(message.text!.toLowerCase());
        }

        // 文件名（对于文件类型消息，虽然我们已经过滤了非文本消息，但保留此逻辑以备将来扩展）
        if (message.fileName != null && message.fileName!.isNotEmpty) {
          searchableTexts.add(message.fileName!.toLowerCase());
        }

        // 位置地址（对于位置类型消息）
        if (message.locationAddress != null &&
            message.locationAddress!.isNotEmpty) {
          searchableTexts.add(message.locationAddress!.toLowerCase());
        }

        // 发送者名称
        if (message.senderName != null && message.senderName!.isNotEmpty) {
          searchableTexts.add(message.senderName!.toLowerCase());
        }

        // 在所有可搜索文本中查找关键词
        for (final searchText in searchableTexts) {
          for (final keyword in keywords) {
            if (searchText.contains(keyword)) {
              isMatch = true;
              break;
            }
          }
          if (isMatch) break; // 找到匹配就退出
        }

        if (isMatch) {
          matchedMessages.add(message);
          processedMessageIds.add(message.messageId);
        }
      }

      // 按时间降序排列（最新到最老）
      matchedMessages.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // 提取消息ID列表（从新到旧排序）
      final matchedMessageIds =
          matchedMessages.map((msg) => msg.messageId).toList();

      final result = SearchResult(
        matchedMessageIds: matchedMessageIds,
        totalCount: matchedMessages.length,
      );

      _logger.i('数据库搜索完成（内存匹配）', extra: {
        'query': query,
        'keywords': keywords,
        'searchFields': ['text', 'fileName', 'locationAddress', 'senderName'],
        'candidateMessages': allMessages.length,
        'textMessages': textMessageCount,
        'nonTextMessages': nonTextMessageCount,
        'matchedMessages': result.totalCount,
      });

      return result;
    } catch (error) {
      _logger.e('数据库搜索失败', error: error, stackTrace: StackTrace.current);

      return const SearchResult(
        matchedMessageIds: [],
        totalCount: 0,
      );
    }
  }

  /// 💢💢💢 新增：根据搜索结果获取完整的消息范围
  @override
  Future<List<Message>> getMessagesRangeForSearch({
    required String conversationId,
    required List<String> searchResultIds,
  }) async {
    try {
      if (searchResultIds.isEmpty) {
        return [];
      }

      _logger.i('获取搜索结果的完整消息范围', extra: {
        'conversationId': conversationId,
        'searchResultCount': searchResultIds.length,
      });

      // 获取搜索结果中最老和最新的消息
      final firstMessage = await _messages
          .filter()
          .messageIdEqualTo(searchResultIds.first)
          .findFirst();

      final lastMessage = await _messages
          .filter()
          .messageIdEqualTo(searchResultIds.last)
          .findFirst();

      if (firstMessage == null || lastMessage == null) {
        _logger.w('找不到搜索结果的边界消息');
        return [];
      }

      // 获取时间范围内的所有消息
      final startTime = firstMessage.createdAt;
      final endTime =
          lastMessage.createdAt.add(const Duration(seconds: 1)); // 包含最后一条消息

      final allMessages = await _messages
          .filter()
          .conversationIdEqualTo(conversationId)
          .and()
          .createdAtBetween(startTime, endTime)
          .sortByCreatedAtDesc() // 按时间降序排列（最新到最老，符合聊天界面显示）
          .findAll();

      _logger.i('获取搜索范围消息完成', extra: {
        'totalMessages': allMessages.length,
        'timeRange':
            '${startTime.toIso8601String()} - ${endTime.toIso8601String()}',
      });

      return allMessages;
    } catch (error) {
      _logger.e('获取搜索范围消息失败', error: error, stackTrace: StackTrace.current);
      return [];
    }
  }

  /// 💢💢💢 新增：加载指定搜索结果附近的消息
  @override
  Future<({List<Message> messages, DateTimeRange timeRange})>
      getMessagesAroundSearchResult({
    required String conversationId,
    required String targetMessageId,
    int contextSize = 25,
  }) async {
    try {
      _logger.i('加载搜索结果附近的消息', extra: {
        'conversationId': conversationId,
        'targetMessageId': targetMessageId,
        'contextSize': contextSize,
      });

      // 获取目标消息
      final targetMessage = await _messages
          .filter()
          .conversationIdEqualTo(conversationId)
          .and()
          .messageIdEqualTo(targetMessageId)
          .findFirst();

      if (targetMessage == null) {
        _logger.w('找不到目标搜索结果消息', extra: {'messageId': targetMessageId});
        return (
          messages: <Message>[],
          timeRange: DateTimeRange(start: DateTime.now(), end: DateTime.now())
        );
      }

      final targetTime = targetMessage.createdAt;

      // 获取目标消息之前的消息（按时间升序，取最后contextSize条）
      final beforeMessages = await _messages
          .filter()
          .conversationIdEqualTo(conversationId)
          .and()
          .createdAtLessThan(targetTime)
          .sortByCreatedAt() // 按时间升序
          .findAll();

      final contextBefore = beforeMessages.length > contextSize
          ? beforeMessages.sublist(beforeMessages.length - contextSize)
          : beforeMessages;

      // 获取目标消息之后的消息（按时间升序，取前contextSize条）
      final afterMessages = await _messages
          .filter()
          .conversationIdEqualTo(conversationId)
          .and()
          .createdAtGreaterThan(targetTime)
          .sortByCreatedAt() // 按时间升序
          .limit(contextSize)
          .findAll();

      // 合并所有消息：之前的 + 目标消息 + 之后的
      final allMessages = <Message>[
        ...contextBefore,
        targetMessage,
        ...afterMessages,
      ];

      // 按时间降序排列（符合聊天界面显示）
      allMessages.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // 计算时间范围
      final startTime =
          allMessages.isEmpty ? DateTime.now() : allMessages.last.createdAt;
      final endTime =
          allMessages.isEmpty ? DateTime.now() : allMessages.first.createdAt;

      final timeRange = DateTimeRange(start: startTime, end: endTime);

      _logger.i('加载搜索结果附近消息完成', extra: {
        'totalMessages': allMessages.length,
        'beforeCount': contextBefore.length,
        'afterCount': afterMessages.length,
        'timeRange':
            '${startTime.toIso8601String()} - ${endTime.toIso8601String()}',
      });

      return (messages: allMessages, timeRange: timeRange);
    } catch (error) {
      _logger.e('加载搜索结果附近消息失败', error: error, stackTrace: StackTrace.current);
      return (
        messages: <Message>[],
        timeRange: DateTimeRange(start: DateTime.now(), end: DateTime.now())
      );
    }
  }

  /// 💢💢💢💢💢💢💢💢💢💢💢💢💢💢 新的游标同步方法实现 💢💢💢💢💢💢💢💢💢💢💢💢💢💢

  /// 向前游标同步（获取新消息）
  @override
  Future<CursorSyncResult> syncMessagesForward(
    String conversationId, {
    MessageCursor? cursor,
    int limit = 20,
  }) async {
    try {
      _logger.i('向前游标同步', extra: {
        'conversationId': conversationId,
        'cursor': cursor?.toString(),
        'limit': limit,
      });

      final request = message_proto.MessageSyncRequest()
        ..syncType = message_proto.MessageSyncType.CURSOR_FORWARD
        ..conversationId = conversationId
        ..limit = limit;

      if (cursor != null && cursor.isValid) {
        request.cursorMessageId = cursor.messageId!;
        request.cursorTimestamp =
            $fixnum.Int64(cursor.timestamp!.millisecondsSinceEpoch);
      }

      _communicationService.emitProto('messages:sync', request);

      // 等待响应（简化实现，实际项目中应该通过事件处理）
      return CursorSyncResult.success(
        conversationId: conversationId,
        returnedCount: 0, // 实际数量将在响应处理中更新
      );
    } catch (error) {
      _logger.e('向前游标同步失败', error: error);
      return CursorSyncResult.failure(
        conversationId: conversationId,
        errorMessage: error.toString(),
      );
    }
  }

  /// 向后游标同步（获取历史消息）
  @override
  Future<CursorSyncResult> syncMessagesBackward(
    String conversationId, {
    MessageCursor? cursor,
    int limit = 20,
  }) async {
    try {
      _logger.i('向后游标同步', extra: {
        'conversationId': conversationId,
        'cursor': cursor?.toString(),
        'limit': limit,
      });

      final request = message_proto.MessageSyncRequest()
        ..syncType = message_proto.MessageSyncType.CURSOR_BACKWARD
        ..conversationId = conversationId
        ..limit = limit;

      if (cursor != null && cursor.isValid) {
        request.cursorMessageId = cursor.messageId!;
        request.cursorTimestamp =
            $fixnum.Int64(cursor.timestamp!.millisecondsSinceEpoch);
      }

      _communicationService.emitProto('messages:sync', request);

      return CursorSyncResult.success(
        conversationId: conversationId,
        returnedCount: 0,
      );
    } catch (error) {
      _logger.e('向后游标同步失败', error: error);
      return CursorSyncResult.failure(
        conversationId: conversationId,
        errorMessage: error.toString(),
      );
    }
  }

  /// 双向游标同步（获取上下文消息）
  @override
  Future<CursorSyncResult> syncMessagesAround(
    String conversationId, {
    required MessageCursor cursor,
    int beforeCount = 10,
    int afterCount = 10,
    bool includeCursor = true,
  }) async {
    try {
      _logger.i('双向游标同步', extra: {
        'conversationId': conversationId,
        'cursor': cursor.toString(),
        'beforeCount': beforeCount,
        'afterCount': afterCount,
        'includeCursor': includeCursor,
      });

      final request = message_proto.MessageSyncRequest()
        ..syncType = message_proto.MessageSyncType.CURSOR_AROUND
        ..conversationId = conversationId
        ..cursorMessageId = cursor.messageId!
        ..cursorTimestamp =
            $fixnum.Int64(cursor.timestamp!.millisecondsSinceEpoch)
        ..beforeCount = beforeCount
        ..afterCount = afterCount
        ..includeCursor = includeCursor;

      _communicationService.emitProto('messages:sync', request);

      return CursorSyncResult.success(
        conversationId: conversationId,
        returnedCount: 0,
      );
    } catch (error) {
      _logger.e('双向游标同步失败', error: error);
      return CursorSyncResult.failure(
        conversationId: conversationId,
        errorMessage: error.toString(),
      );
    }
  }

  /// 初始加载消息
  @override
  Future<CursorSyncResult> syncMessagesInitial(
    String conversationId, {
    int limit = 20,
  }) async {
    try {
      _logger.i('初始加载消息', extra: {
        'conversationId': conversationId,
        'limit': limit,
      });

      final request = message_proto.MessageSyncRequest()
        ..syncType = message_proto.MessageSyncType.INITIAL_LOAD
        ..conversationId = conversationId
        ..limit = limit;

      _communicationService.emitProto('messages:sync', request);

      return CursorSyncResult.success(
        conversationId: conversationId,
        returnedCount: 0,
      );
    } catch (error) {
      _logger.e('初始加载消息失败', error: error);
      return CursorSyncResult.failure(
        conversationId: conversationId,
        errorMessage: error.toString(),
      );
    }
  }

  /// 💢💢💢💢💢💢💢💢💢💢💢💢💢💢 游标管理方法实现 💢💢💢💢💢💢💢💢💢💢💢💢💢💢

  /// 获取本地游标
  @override
  Future<MessageCursor> getLocalCursor(String conversationId) async {
    try {
      final conversation = await _conversations
          .filter()
          .conversationIdEqualTo(conversationId)
          .findFirst();

      if (conversation?.localCursorMessageId != null &&
          conversation?.localCursorTimestamp != null) {
        return MessageCursor.fromMessageData(
          conversation!.localCursorMessageId!,
          conversation.localCursorTimestamp!,
        );
      }

      return MessageCursor.empty;
    } catch (error) {
      _logger.e('获取本地游标失败', error: error);
      return MessageCursor.empty;
    }
  }

  /// 更新本地游标
  @override
  Future<void> updateLocalCursor(
      String conversationId, MessageCursor cursor) async {
    try {
      await _isar.writeTxn(() async {
        final conversation = await _conversations
            .filter()
            .conversationIdEqualTo(conversationId)
            .findFirst();

        if (conversation != null) {
          conversation.localCursorMessageId = cursor.messageId;
          conversation.localCursorTimestamp = cursor.timestamp;
          await _conversations.put(conversation);
        }
      });
    } catch (error) {
      _logger.e('更新本地游标失败', error: error);
    }
  }

  /// 获取同步游标
  @override
  Future<MessageCursor> getSyncCursor(String conversationId) async {
    try {
      final conversation = await _conversations
          .filter()
          .conversationIdEqualTo(conversationId)
          .findFirst();

      if (conversation?.syncCursorMessageId != null &&
          conversation?.syncCursorTimestamp != null) {
        return MessageCursor.fromMessageData(
          conversation!.syncCursorMessageId!,
          conversation.syncCursorTimestamp!,
        );
      }

      return MessageCursor.empty;
    } catch (error) {
      _logger.e('获取同步游标失败', error: error);
      return MessageCursor.empty;
    }
  }

  /// 更新同步游标
  @override
  Future<void> updateSyncCursor(
      String conversationId, MessageCursor cursor) async {
    try {
      await _isar.writeTxn(() async {
        final conversation = await _conversations
            .filter()
            .conversationIdEqualTo(conversationId)
            .findFirst();

        if (conversation != null) {
          conversation.syncCursorMessageId = cursor.messageId;
          conversation.syncCursorTimestamp = cursor.timestamp;
          await _conversations.put(conversation);
        }
      });
    } catch (error) {
      _logger.e('更新同步游标失败', error: error);
    }
  }
}
