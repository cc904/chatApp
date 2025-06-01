import 'dart:async';
import 'dart:io';
import 'dart:collection';
import 'package:cc/core/proto/generated/user.pb.dart';
import 'package:isar/isar.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/database/database_initializer.dart';
import 'package:cc/core/database/models/message.dart';
import 'package:cc/core/services/communication_service.dart';
import 'package:cc/core/services/file_upload_service.dart';
import 'package:cc/features/chat/domain/repositories/chat_repository.dart';
import 'package:cc/features/chat/domain/entities/message_timeline.dart';
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
  final CurrentUserProto _currentUser;

  // 获取当前数据库实例，使用DatabaseInitializer
  Isar get _isar => DatabaseInitializer.isar;
  IsarCollection<Message> get _messages => _isar.messages;

  // 事件流控制器
  final _typingStatusController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _messageStatusController =
      StreamController<Map<String, dynamic>>.broadcast();

  // 事件订阅列表
  final List<StreamSubscription> _subscriptions = [];

  // MessageTimeline 缓存相关字段
  static const int maxCachedTimelines = 60; // 最多缓存60个Timeline
  static const int maxPreloadConversations = 50; // 预加载50个会话
  static const int preloadMessagesCount = 100; // 预加载时每个会话100条

  // 时间线缓存池 - 使用LRU策略
  final Map<String, MessageTimeline> _timelineCache =
      <String, MessageTimeline>{};
  final List<String> _lruOrder = <String>[]; // LRU 顺序追踪

  // 构造函数
  ChatRepositoryImpl({required CurrentUserProto currentUserProto})
      : _currentUser = currentUserProto {
    _logger.x('ChatRepositoryImpl 初始化');
    _registerEventHandlers();
  }

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
            .onProto<message_proto.MessageSyncResponse>('message:sync:response')
            .listen(_handleMessageSyncResponse))
        ..add(_communicationService
            .onProto<message_proto.MessageResponse>('message:send:response')
            .listen(_handleMessageSendResponse));
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

  /// 处理未读消息同步响应
  void _handleUnreadMessageSyncResponse(
      message_proto.MessageSyncResponse response) {
    try {
      _logger.i('收到未读消息同步响应', extra: {
        'conversationId': response.conversationId,
        'success': response.success,
        'messageCount': response.messages.messages.length,
      });

      if (!response.success) {
        _logger.e('未读消息同步失败');
        return;
      }

      // 将消息保存到本地数据库
      _saveMessagesToLocal(response.messages.messages);
    } catch (error) {
      _logger.e('处理未读消息同步响应失败', error: error, stackTrace: StackTrace.current);
    }
  }

  /// 处理围绕最后阅读消息的同步响应
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

  /// 处理智能消息同步响应
  void _handleSmartMessageSyncResponse(
      message_proto.MessageSyncResponse response) {
    try {
      _logger.i('收到智能消息同步响应', extra: {
        'conversationId': response.conversationId,
        'success': response.success,
        'messageCount': response.messages.messages.length,
      });

      if (!response.success) {
        _logger.e('智能消息同步失败');
        return;
      }

      // 将消息保存到本地数据库
      _saveMessagesToLocal(response.messages.messages);
    } catch (error) {
      _logger.e('处理智能消息同步响应失败', error: error, stackTrace: StackTrace.current);
    }
  }

  /// 处理批量消息同步响应
  void _handleBatchMessageSyncResponse(
      message_proto.BatchMessageSyncResponse response) {
    try {
      _logger.i('收到批量消息同步响应', extra: {
        'successCount': response.successCount,
        'failureCount': response.failureCount,
        'responseCount': response.syncResponses.length,
      });

      // 处理每个会话的同步结果
      for (final syncResponse in response.syncResponses) {
        if (syncResponse.success) {
          _saveMessagesToLocal(syncResponse.messages.messages);
          _logger.d(
              '会话 ${syncResponse.conversationId} 同步成功，消息数: ${syncResponse.messages.messages.length}');
        } else {
          _logger.e('会话 ${syncResponse.conversationId} 同步失败');
        }
      }

      _logger.i('批量消息同步完成', extra: {
        '成功': response.successCount,
        '失败': response.failureCount,
      });
    } catch (error) {
      _logger.e('处理批量消息同步响应失败', error: error, stackTrace: StackTrace.current);
    }
  }

  /// 💢💢💢💢💢💢💢💢💢💢💢💢💢💢    消息相关    💢💢💢💢💢💢💢💢💢💢💢💢💢💢

  /// 获取会话消息
  /// 获取指定会话的消息列表,支持分页
  /// [conversationId] - 会话ID
  /// [limit] - 获取消息的最大数量
  /// [before] - 可选的时间点,获取此时间之前的消息
  /// 返回消息列表
  @override
  Future<List<Message>> getConversationMessages(String conversationId,
      {int limit = 20, DateTime? before}) async {
    try {
      _logger.d('获取会话消息', extra: {
        'conversationId': conversationId,
        'limit': limit,
        'before': before?.toIso8601String(),
      });

      // 🔥 优化：利用复合索引 (conversationId + createdAt) 进行高效查询
      final query = _messages
          .filter()
          .conversationIdEqualTo(conversationId)
          .optional(before != null, (q) => q.createdAtLessThan(before!))
          .sortByCreatedAtDesc(); // 最新消息在前

      final messages = await query.limit(limit).findAll();

      _logger.d('获取会话消息完成', extra: {
        'conversationId': conversationId,
        'foundMessages': messages.length,
      });

      return messages;
    } catch (error) {
      _logger.e('获取会话消息失败', error: error, stackTrace: StackTrace.current);
      return [];
    }
  }

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
          .optional(keyword.isNotEmpty,
              (q) => q.textContains(keyword, caseSensitive: false));

      final messages = await query.sortByCreatedAtDesc().findAll();
      return messages;
    } catch (error) {
      _logger.e('搜索消息失败', error: error, stackTrace: StackTrace.current);
      return [];
    }
  }

  /// 将消息标记为已读
  /// 更新指定会话中所有未读消息的状态为已读
  /// [conversationId] - 会话ID
  Future<void> markMessagesAsRead(String conversationId) async {
    try {
      await _isar.writeTxn(() async {
        final unreadMessages = await _messages
            .filter()
            .conversationIdEqualTo(conversationId)
            .and()
            .statusEqualTo('sent')
            .or()
            .statusEqualTo('delivered')
            .findAll();
        for (final message in unreadMessages) {
          message.status = 'read';
          await _messages.put(message);
        }
      });
    } catch (error) {
      _logger.e('标记消息为已读失败', error: error, stackTrace: StackTrace.current);
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

  /// 标记消息发送失败
  Future<void> _markMessageAsFailed(Message message, String errorReason) async {
    try {
      await _isar.writeTxn(() async {
        message.status = 'failed';
        message.errorMessage = errorReason;
        await _isar.messages.put(message);
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
          .sortByCreatedAt() // 按时间正序排序
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
          .sortByCreatedAt() // 按时间正序排序,确保最早的消息在前
          .limit(limit)
          .findAll();

      _logger.d('从日期获取消息结果', extra: {'找到消息数': messages.length});
      return messages;
    } catch (error) {
      _logger.e('从指定日期获取消息失败', error: error, stackTrace: StackTrace.current);
      return [];
    }
  }

  /// 从服务器获取历史消息
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
          ..isRead = false
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
          ..isRead = false
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

  /// 标记会话为已读
  /// 调用markMessagesAsRead方法实现
  /// [conversationId] - 会话ID
  @override
  Future<void> markConversationAsRead(String conversationId) async {
    try {
      // 更新最后阅读时间
      await updateLastReadAt(conversationId, DateTime.now());

      // 标记消息为已读
      await markMessagesAsRead(conversationId);

      _logger.d('会话已标记为已读',
          extra: {'conversationId': conversationId},
          stackTrace: StackTrace.current);
    } catch (error) {
      _logger.e('标记会话为已读失败', error: error, stackTrace: StackTrace.current);
    }
  }

  /// 监听会话消息变化
  /// 监听指定会话中消息的变化
  /// [conversationId] - 会话ID
  /// 返回消息变化的流
  @override
  Stream<void> watchConversationMessages(String conversationId) {
    return _messages.filter().conversationIdEqualTo(conversationId).watchLazy();
  }

  /// 清空会话消息
  /// 删除指定会话中的所有消息和相关媒体文件,但保留会话本身
  /// [conversationId] - 会话ID
  @override
  Future<void> clearConversationMessages(String conversationId) async {
    try {
      // 先获取所有相关消息,以便收集需要删除的媒体文件
      final messages = await _messages
          .filter()
          .conversationIdEqualTo(conversationId)
          .findAll();

      // 收集所有媒体文件路径
      final filesToDelete = <String>[];
      for (final message in messages) {
        filesToDelete.addAll(_collectMediaFilePaths(message));
      }

      // 在数据库事务中删除所有消息
      await _isar.writeTxn(() async {
        // 删除会话中的所有消息
        await _messages
            .filter()
            .conversationIdEqualTo(conversationId)
            .deleteAll();
      });

      // 删除关联的媒体文件
      await _deleteMediaFiles(filesToDelete);
    } catch (error) {
      _logger.e('清空会话消息失败', error: error, stackTrace: StackTrace.current);
      rethrow;
    }
  }

  @override
  Future<void> updateLastReadAt(
      String conversationId, DateTime timestamp) async {
    _logger.i('更新会话最后阅读时间', extra: {
      'conversationId': conversationId,
      'timestamp': timestamp.toString()
    });

    try {
      // 同步到服务器
      if (_communicationService.isInitialized) {
        _logger.i('开始同步会话最后阅读时间到服务器');

        // 创建会话标记已读请求
        final markReadRequest = conversation_proto.ConversationMarkReadRequest()
          ..conversationId = conversationId
          ..readAt = $fixnum.Int64(timestamp.millisecondsSinceEpoch);

        // 发送请求到服务器
        _communicationService.emitProto(
            'conversation:mark:read', markReadRequest);

        // 监听服务器响应
        _communicationService
            .onProto<conversation_proto.ConversationMarkReadResponse>(
                'conversation:mark:read:response')
            .first
            .then((response) {
          if (response.success) {
            _logger.i('服务器已更新会话最后阅读时间', extra: {
              'conversationId': response.conversationId,
              'remainingUnread': response.remainingUnread
            });
          } else {
            _logger.w('服务器更新会话最后阅读时间失败',
                extra: {'conversationId': response.conversationId});
          }
        }).catchError((error) {
          _logger.e('接收服务器最后阅读时间更新响应时出错', error: error);
        });
      } else {
        _logger.w('通信服务未初始化，无法同步会话最后阅读时间到服务器');
      }
    } catch (error) {
      _logger.e('更新会话最后阅读时间失败', error: error);
      throw Exception('更新会话最后阅读时间失败: ${error.toString()}');
    }
  }

  @override
  Future<void> updateLastReadMessageId(
      String conversationId, String messageId) async {
    _logger.i('更新会话最后阅读消息ID',
        extra: {'conversationId': conversationId, 'messageId': messageId});

    try {
      // 同步到服务器
      if (_communicationService.isInitialized) {
        _logger.i('开始同步会话最后阅读消息ID到服务器');

        // 创建会话标记已读请求
        final markReadRequest = conversation_proto.ConversationMarkReadRequest()
          ..conversationId = conversationId
          ..messageId = messageId;

        // 发送请求到服务器
        _communicationService.emitProto(
            'conversation:mark:read', markReadRequest);

        // 监听服务器响应
        _communicationService
            .onProto<conversation_proto.ConversationMarkReadResponse>(
                'conversation:mark:read:response')
            .first
            .then((response) {
          if (response.success) {
            _logger.i('服务器已更新会话最后阅读消息ID', extra: {
              'conversationId': response.conversationId,
              'remainingUnread': response.remainingUnread
            });
          } else {
            _logger.w('服务器更新会话最后阅读消息ID失败',
                extra: {'conversationId': response.conversationId});
          }
        }).catchError((error) {
          _logger.e('接收服务器最后阅读消息ID更新响应时出错', error: error);
        });
      } else {
        _logger.w('通信服务未初始化，无法同步会话最后阅读消息ID到服务器');
      }
    } catch (error) {
      _logger.e('更新会话最后阅读消息ID失败', error: error);
      throw Exception('更新会话最后阅读消息ID失败: ${error.toString()}');
    }
  }

  /// 用户进入会话页面
  /// 将用户加入对应的Socket.io会话房间，但不重置未读消息计数
  /// [conversationId] - 会话ID
  @override
  Future<void> joinConversationRoom(String conversationId) async {
    try {
      _logger.i('用户进入会话页面', extra: {'conversationId': conversationId});

      // 通知服务器用户加入会话房间
      if (_communicationService.isInitialized) {
        final joinRoomRequest =
            conversation_proto.ConversationJoinLeaveRequest()
              ..conversationId = conversationId;

        _communicationService.emitProto('conversation:join', joinRoomRequest);
        _logger.d('已发送加入会话房间请求');
      } else {
        _logger.w('通信服务未初始化，无法同步会话最后阅读消息ID到服务器');
      }
    } catch (error) {
      _logger.e('加入会话房间失败', error: error, stackTrace: StackTrace.current);
    }
  }

  /// 用户离开会话页面
  /// 将用户从对应的Socket.io会话房间中移除
  /// [conversationId] - 会话ID
  @override
  Future<void> leaveConversationRoom(String conversationId) async {
    try {
      _logger.i('用户离开会话页面', extra: {'conversationId': conversationId});

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

  // 💢💢💢💢💢💢💢💢💢💢💢💢💢💢  缓存管理私有方法  💢💢💢💢💢💢💢💢💢💢💢💢💢💢

  /// 获取缓存的MessageTimeline
  @override
  MessageTimeline? getTimeline(String conversationId) {
    final timeline = _timelineCache[conversationId];
    if (timeline != null) {
      // 更新LRU顺序
      _updateLRUOrder(conversationId);
      _logger.d('Timeline缓存命中', extra: {'conversationId': conversationId});
    } else {
      _logger.d('Timeline缓存未命中', extra: {'conversationId': conversationId});
    }
    return timeline;
  }

  /// 存储MessageTimeline到缓存
  @override
  void storeTimeline(String conversationId, MessageTimeline timeline) {
    _timelineCache[conversationId] = timeline;
    _updateLRUOrder(conversationId);
    _manageCacheSize();

    _logger.d('Timeline已缓存', extra: {
      'conversationId': conversationId,
      'messageCount': timeline.length,
      'cacheSize': _timelineCache.length,
    });
  }

  /// 移除指定会话的Timeline缓存
  @override
  void removeTimeline(String conversationId) {
    _timelineCache.remove(conversationId);
    _lruOrder.remove(conversationId);

    _logger.d('Timeline已移除', extra: {
      'conversationId': conversationId,
      'remainingCacheSize': _timelineCache.length,
    });
  }

  /// 清空所有Timeline缓存
  @override
  void clearTimelineCache() {
    final previousSize = _timelineCache.length;
    _timelineCache.clear();
    _lruOrder.clear();

    _logger.i('Timeline缓存已清空', extra: {
      'previousSize': previousSize,
    });
  }

  /// 获取缓存状态信息
  @override
  Map<String, dynamic> getCacheStats() {
    int totalMessages = 0;
    for (final timeline in _timelineCache.values) {
      totalMessages += timeline.length;
    }

    // 估算内存使用（每条消息约2KB）
    final estimatedMemoryMB = (totalMessages * 2 * 1024) / (1024 * 1024);

    return {
      'cachedConversations': _timelineCache.length,
      'totalMessages': totalMessages,
      'estimatedMemoryMB': estimatedMemoryMB.toStringAsFixed(1),
      'averageMessagesPerConversation': _timelineCache.isNotEmpty
          ? (totalMessages / _timelineCache.length).toStringAsFixed(1)
          : '0',
      'maxCacheSize': maxCachedTimelines,
      'cacheUtilization':
          '${(_timelineCache.length / maxCachedTimelines * 100).toStringAsFixed(1)}%',
    };
  }

  /// 预加载指定会话的消息到Timeline
  @override
  Future<bool> preloadTimeline(String conversationId,
      {int messageCount = 100}) async {
    try {
      // 检查是否已经缓存
      if (_timelineCache.containsKey(conversationId)) {
        _logger
            .d('Timeline已存在，跳过预加载', extra: {'conversationId': conversationId});
        return true;
      }

      _logger.d('开始预加载Timeline', extra: {
        'conversationId': conversationId,
        'messageCount': messageCount,
      });

      // 从数据库加载消息
      final messages = await getConversationMessages(
        conversationId,
        limit: messageCount,
      );

      if (messages.isNotEmpty) {
        // 创建Timeline并添加消息
        final timeline = MessageTimeline(conversationId: conversationId);

        // 消息按时间升序排列（来自数据库的是降序）
        final sortedMessages = messages.reversed.toList();
        timeline.appendNewMessages(sortedMessages);

        // 计算未读消息信息
        await _calculateUnreadInfo(timeline, conversationId);

        // 存储到缓存
        storeTimeline(conversationId, timeline);

        _logger.d('Timeline预加载完成', extra: {
          'conversationId': conversationId,
          'loadedMessages': messages.length,
          'unreadCount': timeline.unreadCount,
        });

        return true;
      } else {
        _logger
            .d('会话暂无消息，创建空Timeline', extra: {'conversationId': conversationId});

        // 创建空的Timeline
        final timeline = MessageTimeline(conversationId: conversationId);
        storeTimeline(conversationId, timeline);

        return true;
      }
    } catch (error) {
      _logger.e('Timeline预加载失败', error: error, extra: {
        'conversationId': conversationId,
      });
      return false;
    }
  }

  /// 获取用户上次查看状态
  @override
  Future<ViewState?> getUserLastViewState(String conversationId) async {
    try {
      // 这里可以从数据库或持久化存储中获取用户的查看状态
      // 目前返回null，后续可以根据需要实现持久化
      _logger.d('获取用户查看状态', extra: {'conversationId': conversationId});
      return null;
    } catch (error) {
      _logger.e('获取用户查看状态失败', error: error, extra: {
        'conversationId': conversationId,
      });
      return null;
    }
  }

  /// 保存用户查看状态
  @override
  Future<void> saveUserViewState(ViewState viewState) async {
    try {
      // 这里可以将查看状态保存到数据库或持久化存储
      // 目前只是记录日志，后续可以根据需要实现持久化
      _logger.d('保存用户查看状态', extra: {
        'conversationId': viewState.conversationId,
        'scrollPosition': viewState.scrollPosition,
        'lastViewTime': viewState.lastViewTime.toString(),
      });
    } catch (error) {
      _logger.e('保存用户查看状态失败', error: error, extra: {
        'conversationId': viewState.conversationId,
      });
    }
  }

  // 💢💢💢💢💢💢💢💢💢💢💢💢💢💢  缓存管理私有方法  💢💢💢💢💢💢💢💢💢💢💢💢💢💢

  /// 更新LRU顺序
  void _updateLRUOrder(String conversationId) {
    _lruOrder.remove(conversationId);
    _lruOrder.add(conversationId);
  }

  /// 管理缓存大小，使用LRU策略淘汰
  void _manageCacheSize() {
    if (_timelineCache.length <= maxCachedTimelines) return;

    // 计算需要淘汰的数量
    final excess = _timelineCache.length - maxCachedTimelines;

    _logger.d('缓存超出限制，准备淘汰', extra: {
      'currentSize': _timelineCache.length,
      'maxSize': maxCachedTimelines,
      'toEvict': excess,
    });

    // 淘汰最久未使用的Timeline
    for (int i = 0; i < excess && _lruOrder.isNotEmpty; i++) {
      final oldestConversationId = _lruOrder.removeAt(0);
      final evictedTimeline = _timelineCache.remove(oldestConversationId);

      if (evictedTimeline != null) {
        _logger.d('Timeline已被淘汰', extra: {
          'conversationId': oldestConversationId,
          'messageCount': evictedTimeline.length,
        });
      }
    }
  }

  /// 计算Timeline的未读消息信息
  Future<void> _calculateUnreadInfo(
      MessageTimeline timeline, String conversationId) async {
    try {
      // 获取会话的最后阅读时间
      // 这里需要从Conversation模型中获取lastReadAt
      // 暂时使用简单的逻辑：所有消息都视为已读
      final unreadMessages = timeline.getUnreadMessages();

      if (unreadMessages.isNotEmpty) {
        timeline.unreadCount = unreadMessages.length;
        timeline.firstUnreadMessageId = unreadMessages.first.messageId;
        timeline.lastUnreadMessageId = unreadMessages.last.messageId;

        _logger.d('计算未读消息信息完成', extra: {
          'conversationId': conversationId,
          'unreadCount': timeline.unreadCount,
        });
      }
    } catch (error) {
      _logger.e('计算未读消息信息失败', error: error, extra: {
        'conversationId': conversationId,
      });
    }
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

    // 清空缓存
    clearTimelineCache();
  }

  /// 💢💢💢💢💢💢💢💢💢💢💢💢💢💢   消息同步方法   💢💢💢💢💢💢💢💢💢💢💢💢💢💢

  /// 同步会话消息
  @override
  Future<bool> syncConversationMessages(
    String conversationId,
    message_proto.MessageSyncType syncType, {
    String? anchorMessageId,
  }) async {
    try {
      _logger.i('开始同步会话消息', extra: {
        'conversationId': conversationId,
        'syncType': syncType.name,
        'anchorMessageId': anchorMessageId,
      });

      switch (syncType) {
        case message_proto.MessageSyncType.RECENT:
          if (anchorMessageId == null) {
            _logger.w('RECENT同步需要anchorMessageId');
            return false;
          }
          return await syncRecentMessages(conversationId, anchorMessageId);

        case message_proto.MessageSyncType.UNREAD:
          return await syncUnreadMessages(
            conversationId,
            lastReadMessageId: anchorMessageId,
          );

        default:
          _logger.w('未知的同步类型', extra: {'syncType': syncType});
          return false;
      }
    } catch (error) {
      _logger.e('同步会话消息失败', error: error);
      return false;
    }
  }

  /// 日期同步消息
  @override
  Future<bool> syncRecentMessages(
    String conversationId,
    String anchorMessageId,
  ) async {
    try {
      _logger.i('日期同步消息', extra: {
        'conversationId': conversationId,
        'anchorMessageId': anchorMessageId,
      });

      final dailyCounts = await calculateDailyMessageCounts(
        conversationId,
        anchorMessageId,
      );

      final syncRequest = message_proto.MessageSyncRequest()
        ..syncType = message_proto.MessageSyncType.RECENT
        ..conversationId = conversationId
        ..anchorMessageId = anchorMessageId;

      for (final entry in dailyCounts.entries) {
        final dailyCount = message_proto.DailyMessageCount()
          ..date = entry.key
          ..count = entry.value;
        syncRequest.dailyCounts.add(dailyCount);
      }

      _logger.d('日期同步请求参数', extra: {
        'dailyCountsSize': dailyCounts.length,
      });

      _communicationService.emitProto('message:sync', syncRequest);

      return true;
    } catch (error) {
      _logger.e('日期同步消息失败', error: error);
      return false;
    }
  }

  /// 同步未读消息
  @override
  Future<bool> syncUnreadMessages(
    String conversationId, {
    String? lastReadMessageId,
  }) async {
    try {
      // _logger.i('同步未读消息', extra: {
      //   'conversationId': conversationId,
      //   'lastReadMessageId': lastReadMessageId,
      // });

      final syncRequest = message_proto.MessageSyncRequest()
        ..syncType = message_proto.MessageSyncType.UNREAD
        ..conversationId = conversationId
        ..anchorMessageId = lastReadMessageId ?? '';

      // 发送请求
      _communicationService.emitProto('message:sync', syncRequest);

      return true;
    } catch (error) {
      _logger.e('同步未读消息失败', error: error);
      return false;
    }
  }

  /// 计算锚点消息前后15天每天的消息数量
  @override
  Future<Map<String, int>> calculateDailyMessageCounts(
    String conversationId,
    String anchorMessageId,
  ) async {
    try {
      _logger.d('计算每日消息数量', extra: {
        'conversationId': conversationId,
        'anchorMessageId': anchorMessageId,
      });

      // 获取锚点消息的时间戳
      final anchorTime =
          await getMessageTimestamp(conversationId, anchorMessageId);
      if (anchorTime == null) {
        _logger.w('锚点消息不存在', extra: {'anchorMessageId': anchorMessageId});
        return {};
      }

      final dailyCounts = <String, int>{};

      // 计算前后15天，共31天的数据
      for (int i = -15; i <= 15; i++) {
        final targetDate = anchorTime.add(Duration(days: i));
        final dateKey = _formatDateKey(targetDate);
        final count = await getMessageCountByDate(conversationId, targetDate);
        dailyCounts[dateKey] = count;
      }

      _logger.d('每日消息统计完成', extra: {
        'totalDays': dailyCounts.length,
        'totalMessages':
            dailyCounts.values.fold(0, (sum, count) => sum + count),
      });

      return dailyCounts;
    } catch (error) {
      _logger.e('计算每日消息数量失败', error: error);
      return {};
    }
  }

  /// 获取指定日期的消息数量
  @override
  Future<int> getMessageCountByDate(
      String conversationId, DateTime date) async {
    try {
      // 计算当天的开始和结束时间
      final dayStart = DateTime(date.year, date.month, date.day, 0, 0, 0);
      final dayEnd = DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

      // 🔥 使用复合索引高效查询指定日期的消息数量
      final count = await _messages
          .filter()
          .conversationIdEqualTo(conversationId)
          .and()
          .createdAtBetween(dayStart, dayEnd)
          .count();

      return count;
    } catch (error) {
      _logger.e('获取指定日期消息数量失败', error: error);
      return 0;
    }
  }

  /// 格式化日期为字符串键
  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// 获取消息在时间线中的位置
  Future<DateTime?> getMessageTimestamp(
      String conversationId, String messageId) async {
    try {
      final message = await _messages
          .filter()
          .conversationIdEqualTo(conversationId)
          .and()
          .messageIdEqualTo(messageId)
          .findFirst();

      return message?.createdAt;
    } catch (error) {
      _logger.e('获取消息时间戳失败', error: error);
      return null;
    }
  }

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
          // 如果消息已存在，跳过保存
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
    _logger.i('批量同步消息', extra: {
      'taskCount': syncTasks.length,
      'maxConcurrent': maxConcurrent,
    });

    final results = <bool>[];
    final semaphore = Semaphore(maxConcurrent);

    // 并发执行同步任务
    final futures = syncTasks.map((task) async {
      await semaphore.acquire();
      try {
        final result = await syncConversationMessages(
          task.conversationId,
          task.type,
          anchorMessageId: task.anchorMessageId,
        );
        return result;
      } finally {
        semaphore.release();
      }
    });

    results.addAll(await Future.wait(futures));
    return results;
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
      {Duration timeout = const Duration(seconds: 3)}) async {
    final tempMessageId = message.messageId;

    try {
      _logger.d('发送消息（超时机制）', extra: {
        'tempMessageId': tempMessageId,
        'timeout': timeout.inSeconds,
      });

      // 创建Proto对象用于发送
      final protoMsg = message.toProto();

      // 发送消息到服务器（不等待响应）
      _communicationService.emitProto('message:send', protoMsg);

      // 启动超时计时器
      Timer(timeout, () async {
        // 检查消息是否仍然是sending状态
        final currentMessage = await getMessageById(tempMessageId);
        if (currentMessage != null && currentMessage.status == 'sending') {
          // 超时，标记为失败
          await markMessageAsFailed(tempMessageId, '发送超时');

          // 发送消息状态更新事件，通知UI层
          _messageStatusController.add({
            'messageId': tempMessageId,
            'conversationId': currentMessage.conversationId,
            'status': 'failed',
            'errorMessage': '发送超时',
          });

          _logger.w('消息发送超时', extra: {'tempMessageId': tempMessageId});
        }
      });

      _logger.d('消息发送请求已发出', extra: {'tempMessageId': tempMessageId});
    } catch (error) {
      _logger.e('发送消息失败', error: error);
      await markMessageAsFailed(tempMessageId, '发送失败: ${error.toString()}');

      // 发送消息状态更新事件，通知UI层
      final currentMessage = await getMessageById(tempMessageId);
      if (currentMessage != null) {
        _messageStatusController.add({
          'messageId': tempMessageId,
          'conversationId': currentMessage.conversationId,
          'status': 'failed',
          'errorMessage': '发送失败: ${error.toString()}',
        });
      }

      rethrow;
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

        _logger.i('消息发送成功，已更新本地消息', extra: {
          'tempId': response.tempId,
          'serverMessageId': response.messageId,
        });
      } else {
        // 发送失败，标记为失败状态
        final errorMessage =
            response.message.isNotEmpty ? response.message : '服务器处理失败';
        await markMessageAsFailed(response.tempId, errorMessage);

        _logger.w('消息发送失败', extra: {
          'tempId': response.tempId,
          'errorMessage': errorMessage,
        });
      }
    } catch (error) {
      _logger.e('处理消息发送响应失败', error: error);
    }
  }
}
