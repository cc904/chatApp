import 'dart:async';
import 'dart:io';
import 'package:isar/isar.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/database/database_initializer.dart';
import 'package:cc/core/database/models/message.dart';
import 'package:cc/core/database/models/current_user.dart';
import 'package:cc/core/services/communication_service.dart';
import 'package:cc/core/services/file_upload_service.dart';
import 'package:cc/features/chat/domain/repositories/chat_repository.dart';
import 'package:fixnum/fixnum.dart' as $fixnum;

import 'package:cc/core/proto/generated/message.pb.dart' as message_proto;
import 'package:cc/core/proto/generated/conversation.pb.dart'
    as conversation_proto;

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

  // 事件流控制器
  final _typingStatusController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _messageStatusController =
      StreamController<Map<String, dynamic>>.broadcast();

  // 事件订阅列表
  final List<StreamSubscription> _subscriptions = [];

  // 构造函数
  ChatRepositoryImpl() {
    _logger.x('ChatRepositoryImpl 初始化');
    _setupEventHandlers();
  }

  /// 设置事件处理器
  void _setupEventHandlers() {
    if (!_communicationService.isInitialized) {
      _logger.i('通信服务未初始化，无法注册事件处理器');
      return;
    }

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
          .listen(_handleTypingStop));
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

  /// 💢💢💢💢💢💢💢💢💢💢💢💢💢💢   Isar   💢💢💢💢💢💢💢💢💢💢💢💢💢💢

  // 获取当前数据库实例，使用DatabaseInitializer
  Isar get _isar => DatabaseInitializer.isar;

  // 获取用户集合

  // 获取会话集合

  // 获取消息集合
  IsarCollection<Message> get _messages => _isar.messages;

  /// 获取当前用户ID
  /// 直接从数据库获取当前登录用户的ID
  /// 返回用户ID,如未找到则抛出异常
  Future<String> _getCurrentUserId() async {
    try {
      if (!DatabaseInitializer.isInitialized) {
        throw Exception('数据库未初始化，请确保已登录');
      }

      final currentUsers =
          await DatabaseInitializer.isar.currentUsers.where().findAll();

      if (currentUsers.isEmpty) {
        throw Exception('找不到当前用户信息，请确保已登录');
      }

      // 返回第一个用户的ID（通常只会有一个用户记录）
      return currentUsers.first.userId;
    } catch (e) {
      throw Exception('获取当前用户ID失败: ${e.toString()}');
    }
  }

  /// 💢💢💢💢💢💢💢💢💢💢💢💢💢💢   消息相关   💢💢💢💢💢💢💢💢💢💢💢💢💢💢

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
      final query = _messages
          .filter()
          .conversationIdEqualTo(conversationId)
          .optional(before != null, (q) => q.createdAtLessThan(before!))
          .sortByCreatedAtDesc();

      final messages = await query.limit(limit).findAll();
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
      final message = Message();
      message.conversationId = conversationId;
      // 获取当前用户ID
      final currentUserId = await _getCurrentUserId();
      message.senderId = currentUserId;
      message.senderName = '我';
      message.type = type;
      message.text = text.isEmpty ? null : text;
      message.isRead = true; // 自己发送的消息默认已读
      message.status = 'sending';
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
        final messages = await _messages
            .filter()
            .conversationIdEqualTo(conversationId)
            .and()
            .isReadEqualTo(false)
            .findAll();
        for (final message in messages) {
          message.isRead = true;
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
      final message = Message();
      message.conversationId = conversationId;
      // 获取当前用户ID
      final currentUserId = await _getCurrentUserId();
      message.senderId = currentUserId;
      message.senderName = '我';
      message.type = 'video';
      message.localPath = localPath;
      message.mediaUrl = mediaUrl;
      message.thumbnailUrl = thumbnailUrl;
      message.duration = duration;
      message.isRead = true; // 自己发送的消息默认已读

      // 如果缩略图由服务器处理,且尚未生成,设置状态为处理中
      if (isServerProcessed && thumbnailUrl == null) {
        message.status = 'processing'; // 服务器处理中
      } else {
        message.status = 'sent'; // 正常发送状态
      }

      await _isar.writeTxn(() async {
        message.id = await _messages.put(message);
        await _messages.put(message);
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
    try {
      // 保存消息到数据库
      await _isar.writeTxn(() async {
        message.id = await _isar.messages.put(message);
      });

      // 创建Proto对象用于发送
      final protoMsg = message.toProto();

      // 通过通信服务发送消息
      _communicationService.emitProto('message:new', protoMsg);

      return message.messageId;
    } catch (error) {
      _logger.e('发送消息失败', extra: {'error': error.toString()});
      throw MessageException('发送消息失败: ${error.toString()}');
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

  /// 🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥 获取输入状态流  🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥

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

  /// 💢💢💢💢💢💢💢💢💢💢💢💢💢💢    其他功能     💢💢💢💢💢💢💢💢💢💢💢💢💢💢

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

      _logger.i('会话已标记为已读', extra: {'conversationId': conversationId});
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

  /// 💢💢💢💢💢💢💢💢💢💢💢💢💢💢      TODo     💢💢💢💢💢💢💢💢💢💢💢💢💢💢

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
  }
}
