import 'dart:async';
import 'dart:io';
import 'dart:collection';
import 'package:cc/core/database/models/current_user.dart';
import 'package:isar/isar.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/database/database_initializer.dart';
import 'package:cc/core/database/models/message.dart';
import 'package:cc/core/adapters/message_adapter.dart';
import 'package:cc/core/services/communication_service.dart';
import 'package:cc/features/chat/domain/repositories/chat_repository.dart';
import 'package:cc/features/chat/domain/entities/message_update_event.dart';

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:cc/core/proto/generated/message.pb.dart' as message_proto;
import 'package:cc/core/proto/generated/conversation.pb.dart'
    as conversation_proto;
import 'package:cc/core/proto/generated/message.pb.dart' show LoadingType;

/// 🔥 临时兼容类已全部移除 - Index方案完全替代了复杂的游标系统

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

class LoadType {}

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

  final CurrentUser _currentUser;

  // 获取当前数据库实例，使用DatabaseInitializer
  Isar get _isar => DatabaseInitializer.isar;
  IsarCollection<Message> get _messages => _isar.messages;

  // 输入事件流控制器
  final _typingStatusController =
      StreamController<Map<String, dynamic>>.broadcast();

  // 💢💢💢 新Stream架构：消息更新事件流控制器
  final Map<String, StreamController<MessageUpdateEvent>>
      _messageUpdateControllers = {};
  // 💢💢💢 新Stream架构：会话级加载状态流控制器
  final Map<String, StreamController<LoadingStateUpdate>>
      _conversationLoadingControllers = {};

  // 事件订阅列表
  final List<StreamSubscription> _subscriptions = [];

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

  /// 💢💢💢 新Stream架构：获取消息更新事件流
  @override
  Stream<MessageUpdateEvent> getMessageUpdateStream(String conversationId) {
    _messageUpdateControllers[conversationId] ??=
        StreamController<MessageUpdateEvent>.broadcast();
    return _messageUpdateControllers[conversationId]!.stream;
  }

  /// 💢💢💢 新Stream架构：获取会话级加载状态流
  @override
  Stream<LoadingStateUpdate> getConversationLoadingStateStream(
      String conversationId) {
    _conversationLoadingControllers[conversationId] ??=
        StreamController<LoadingStateUpdate>.broadcast();
    return _conversationLoadingControllers[conversationId]!.stream;
  }

  // 构造函数
  ChatRepositoryImpl({required CurrentUser currentUser})
      : _currentUser = currentUser {
    _logger.x('ChatRepositoryImpl 初始化');
    _registerEventHandlers();
  }

  // 💢💢💢💢💢💢💢💢💢💢💢💢💢💢     Handler    💢💢💢💢💢💢💢💢💢💢💢💢💢💢

  /// 设置事件处理器
  Future<void> _registerEventHandlers() async {
    _logger.i('开始注册事件处理器', extra: {
      'isInitialized': _communicationService.isInitialized,
      'isConnected': _communicationService.isConnected,
    });

    if (_communicationService.isInitialized) {
      _logger.i('ChatRepository Proto事件流 订阅');
      _subscriptions
        // ..add(_communicationService
        //     .onProto<message_proto.MessageReadProto>('message:read')
        //     .listen(_handleMessageRead))
        ..add(_communicationService
            .onProto<message_proto.TypingProto>('user:typing')
            .listen(_handleTypingStatus))
        ..add(_communicationService
            .onProto<message_proto.TypingProto>('user:typing:stop')
            .listen(_handleTypingStop))
        ..add(_communicationService
            .onProto<message_proto.MessagesFetchResponse>(
                'messages:fetch:response')
            .listen(_handleMessagesFetchResponse))
        ..add(_communicationService
            .onProto<message_proto.MessageSendResponse>('message:send:response')
            .listen(_handleMessageSendResponse))
        ..add(_communicationService
            .onProto<message_proto.MessageProto>('message:new')
            .listen(_handleNewMessage));

      _logger.i('所有事件处理器已注册', extra: {
        'subscriptionCount': _subscriptions.length,
      });
    } else {
      _logger.w('通信服务未初始化，无法注册事件处理器');
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

  /// 将收到的信息写入数据库,有重复的需要覆盖
  void _handleMessagesFetchResponse(
      message_proto.MessagesFetchResponse response) async {
    final conversationId = response.conversationId;
    try {
      // 💢💢💢 通知开始处理网络响应
      _notifyConversationLoadingState(LoadingStateUpdate.start(
        conversationId: conversationId,
        loadingType: LoadingType.LOAD_MORE_BEFORE,
      ));

      if (response.messages.isEmpty) {
        _logger.d('收到空的消息响应');
        // 💢💢💢 通知网络请求完成
        _notifyConversationLoadingState(LoadingStateUpdate.complete(
          conversationId: conversationId,
          loadingType: LoadingType.LOAD_MORE_BEFORE,
        ));
        return;
      }

      _logger.d('处理消息获取响应', extra: {
        'messageCount': response.messages.length,
      });

      // 转换消息
      final messageModels = <Message>[];
      for (final protoMessage in response.messages) {
        final messageModel = MessageAdapter.fromProto(protoMessage);
        messageModels.add(messageModel);
      }

      // 使用批量事务操作，提高性能和数据一致性
      await _isar.writeTxn(() async {
        // 批量插入/更新消息（自动处理重复，replace: true）
        await _messages.putAll(messageModels);
      });

      // 💢💢💢 关键：推送精确的消息更新事件，而不是模糊的"数据库变了"信号
      _notifyMessageUpdate(MessageAddedEvent(
        conversationId: conversationId,
        newMessages: messageModels,
        loadingType: response.loadingType, // 使用LoadingContext
      ));

      // 💢💢💢 通知网络请求完成
      _notifyConversationLoadingState(LoadingStateUpdate.complete(
        conversationId: conversationId,
        loadingType: response.loadingType,
        metadata: {'messageCount': messageModels.length},
      ));

      _logger.i('消息批量写入数据库完成', extra: {
        'insertedCount': response.messages.length,
      });
    } catch (error) {
      _logger.e('将收到的信息写入数据库失败', error: error, stackTrace: StackTrace.current);

      // 💢💢💢 处理失败时通知错误
      _notifyConversationLoadingState(LoadingStateUpdate.error(
        conversationId: conversationId,
        loadingType: response.loadingType,
        error: error.toString(),
      ));
    }
  }

  /// 处理消息发送响应
  void _handleMessageSendResponse(
      message_proto.MessageSendResponse response) async {
    try {
      _logger.d('收到消息发送响应', extra: {
        'success': response.success,
        'messageIndex': response.messageIndex.toInt(),
      });

      if (response.tempId.isEmpty) {
        _logger.w('消息发送响应缺少临时ID，无法匹配本地消息');
        return;
      }

      // 查找对应的临时消息
      final tempMessage = await _messages
          .filter()
          .messageIdEqualTo(response.tempId)
          .findFirst();
      if (tempMessage == null) {
        _logger.w('找不到对应的临时消息', extra: {'tempId': response.tempId});
        return;
      }

      if (response.success) {
        // 发送成功，更新消息ID和状态
        await _isar.writeTxn(() async {
          tempMessage.messageId = response.messageId;
          tempMessage.messageIndex = response.messageIndex.toInt();
          tempMessage.status = MessageStatus.sent;
          await _messages.put(tempMessage);
        });

        // 💢💢💢 使用新的UpdateSendEvent推送消息发送更新事件
        _notifyMessageUpdate(UpdateSendEvent(
          conversationId: tempMessage.conversationId,
          tempId: response.tempId,
          messageId: response.messageId,
          messageIndex: response.messageIndex.toInt(),
        ));

        _logger.i('消息发送成功，已更新本地消息和UI状态', extra: {
          'tempId': response.tempId,
          'serverMessageId': response.messageId,
        });
      } // 失败了不需要修改状态,因为超时会更新为失败状态
    } catch (error) {
      _logger.e('处理消息发送响应失败', error: error);
    }
  }

  /// 💢💢💢💢💢💢💢💢💢💢💢💢💢💢    Request    💢💢💢💢💢💢💢💢💢💢💢💢💢💢

  @override
  Future<bool> requestMoreMessages(
      String conversationId, LoadingType loadingType, int messageIndex,
      {int limit = 50}) async {
    _logger.i('请求服务器获取更多历史消息', extra: {
      'conversationId': conversationId,
      'messageIndex': messageIndex,
      'loadingType': loadingType,
      'limit': limit,
    });

    try {
      // 💢💢💢 使用新Stream架构通知网络请求开始
      _notifyConversationLoadingState(LoadingStateUpdate.start(
        conversationId: conversationId,
        loadingType: loadingType,
      ));

      // 创建请求对象 - 使用新的index字段
      final request = message_proto.MessagesFetchRequest()
        ..conversationId = conversationId
        ..limit = limit
        ..messageIndex = $fixnum.Int64(messageIndex)
        ..loadingType = loadingType;

      // 发送请求到服务器
      await _communicationService.emitProto('messages:fetch', request);

      return true;
    } catch (error) {
      // 💢💢💢 请求失败时通知停止网络请求
      _notifyConversationLoadingState(LoadingStateUpdate.error(
        conversationId: conversationId,
        loadingType: loadingType,
        error: error.toString(),
      ));
      return false;
    }
  }

  /// 💢💢💢💢💢💢💢💢💢💢💢💢💢💢  Get4Database  💢💢💢💢💢💢💢💢💢💢💢💢💢💢

  /// 加载本地最新的消息
  /// [conversationId] - 会话ID
  /// [loadingContext] - 加载上下文
  /// [anchorMessageIndex] - 锚点消息Index
  /// [firstMessageIndex] - 第一条消息Index
  /// [lastMessageIndex] - 最后一条消息Index
  /// [limit] - 消息数量限制
  @override
  Future<bool> loadMoreMessages(String conversationId, LoadingType loadingType,
      int anchorMessageIndex, int firstMessageIndex, int lastMessageIndex,
      {int? limit}) async {
    _logger.d('加载本地最新的消息', extra: {
      'conversationId': conversationId,
      'anchorMessageIndex': anchorMessageIndex,
      'loadingContext': loadingType,
    });
    _notifyConversationLoadingState(LoadingStateUpdate.start(
      conversationId: conversationId,
      loadingType: loadingType,
    ));

    List<Message> messages = [];

    switch (loadingType) {
      case LoadingType.INITIAL:
        // 无新消息,读取最新100条
        if (anchorMessageIndex == -1) {
          messages = await _messages
              .filter()
              .conversationIdEqualTo(conversationId)
              .sortByMessageIndexDesc()
              .limit(limit ?? 100)
              .findAll();

          if (messages.isEmpty) {
            await requestMoreMessages(conversationId, loadingType, -1);
          } else if (messages.length < 50 &&
              messages.last.messageIndex > firstMessageIndex) {
            await requestMoreMessages(
                conversationId, loadingType, messages.last.messageIndex);
          }
        }
        // 有新消息,锚点为新消息位置,获取范围内的消息
        else {
          final rangeSize = limit ?? 50;
          final startIndex = anchorMessageIndex - rangeSize;
          final endIndex = anchorMessageIndex + rangeSize;

          messages = await _messages
              .filter()
              .conversationIdEqualTo(conversationId)
              .and()
              .messageIndexBetween(startIndex, endIndex)
              .sortByMessageIndexDesc()
              .findAll();

          if (messages.isEmpty) {
            await requestMoreMessages(conversationId, loadingType, -1);
          } else if (messages.length < 50 &&
              messages.last.messageIndex > firstMessageIndex &&
              messages.first.messageIndex < lastMessageIndex) {
            await requestMoreMessages(
                conversationId, loadingType, anchorMessageIndex);
          }
        }
        break;
      case LoadingType.LOAD_MORE_BEFORE:
        messages = await _messages
            .filter()
            .conversationIdEqualTo(conversationId)
            .and()
            .messageIndexLessThan(anchorMessageIndex)
            .sortByMessageIndexDesc()
            .limit(limit ?? 50)
            .findAll();

        if (messages.isEmpty) {
          await requestMoreMessages(conversationId, loadingType, -1);
        } else if (messages.length < 50 &&
            messages.last.messageIndex > firstMessageIndex) {
          await requestMoreMessages(
              conversationId, loadingType, messages.last.messageIndex);
        }
        break;
      case LoadingType.LOAD_MORE_AFTER:
        messages = await _messages
            .filter()
            .conversationIdEqualTo(conversationId)
            .and()
            .messageIndexGreaterThan(anchorMessageIndex)
            .sortByMessageIndex()
            .limit(limit ?? 50)
            .findAll();

        if (messages.isEmpty) {
          await requestMoreMessages(conversationId, loadingType, -1);
        } else if (messages.length < 50 &&
            messages.first.messageIndex < lastMessageIndex) {
          await requestMoreMessages(
              conversationId, loadingType, messages.first.messageIndex);
        }
        break;
      case LoadingType.SEARCH:
      case LoadingType.ADD:
      case LoadingType.UPDATE:
      case LoadingType.UPDATE_SEND:
        break;
    }

    _messageUpdateControllers[conversationId]!.add(MessageAddedEvent(
      conversationId: conversationId,
      newMessages: messages,
      loadingType: loadingType, // 使用LoadingContext
    ));

    _notifyConversationLoadingState(LoadingStateUpdate.complete(
      conversationId: conversationId,
      loadingType: loadingType,
    ));
    return true;
  }

  /// 获取会话中的消息数量
  @override
  Future<int> getConversationMessageCount(String conversationId) async {
    try {
      final count = await _messages
          .filter()
          .conversationIdEqualTo(conversationId)
          .count();
      return count;
    } catch (error) {
      _logger.e('获取会话中的消息数量失败', error: error, stackTrace: StackTrace.current);
      return 0;
    }
  }

  /// 💢💢💢💢💢💢💢💢💢💢💢💢💢💢  ---  💢💢💢💢💢💢💢💢💢💢💢💢💢💢

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
          .typeEqualTo(MessageType.text) // 💢💢💢 只搜索文本类型的消息
          .and()
          .optional(keyword.isNotEmpty,
              (q) => q.textContains(keyword, caseSensitive: false));

      final messages = await query.sortByMessageIndexDesc().findAll();

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

  /// 删除消息（标记为删除状态，不物理删除）
  /// 将消息状态标记为已删除，清空内容但保留消息索引连续性
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

      // 💢💢💢 在数据库事务中标记消息为删除状态
      await _isar.writeTxn(() async {
        // 标记为删除状态，清空内容字段
        message.status = MessageStatus.deleted;
        message.text = null;
        message.mediaUrl = null;
        message.thumbnailUrl = null;
        message.localPath = null;
        message.fileName = null;
        message.fileSize = null;
        message.duration = null;
        message.metadata = null;
        message.updatedAt = DateTime.now();

        // 更新消息到数据库，保留messageIndex等关键字段
        await _messages.put(message);
      });

      // 删除关联的媒体文件（物理文件可以删除）
      await _deleteMediaFiles(filesToDelete);

      // 💢💢💢 推送消息更新事件，通知UI更新
      _notifyMessageUpdate(MessageUpdatedEvent(
        conversationId: message.conversationId,
        messageId: message.messageId,
        updatedFields: {
          'status': 'deleted',
          'updatedAt': message.updatedAt?.toIso8601String(),
        },
      ));

      _logger.i('消息已标记为删除状态', extra: {
        'messageId': messageId,
        'conversationId': message.conversationId,
        'messageIndex': message.messageIndex,
        'action': '标记删除而非物理删除',
      });
    } catch (error) {
      _logger.e('标记消息删除失败', error: error, stackTrace: StackTrace.current);
      rethrow;
    }
  }

  /// 收集消息中的媒体文件路径
  /// 分析消息对象,收集需要删除的媒体文件路径
  /// [message] - 消息对象
  /// 返回文件路径列表
  List<String> _collectMediaFilePaths(Message message) {
    final filesToDelete = <String>[];

    if (message.type == MessageType.image ||
        message.type == MessageType.video ||
        message.type == MessageType.voice ||
        message.type == MessageType.file) {
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
    // 💢💢💢 使用新Stream架构通知开始加载
    _notifyConversationLoadingState(LoadingStateUpdate.start(
      conversationId: conversationId,
      loadingType: LoadingType.SEARCH,
    ));

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
          .sortByMessageIndexDesc() // 按messageIndex降序排序
          .limit(limit)
          .findAll();

      _logger.d('按日期范围查询结果', extra: {'找到消息数': messages.length});

      // 💢💢💢 通知加载完成
      _notifyConversationLoadingState(LoadingStateUpdate.complete(
        conversationId: conversationId,
        loadingType: LoadingType.SEARCH,
      ));
      return messages;
    } catch (error) {
      _logger.e('根据日期范围获取消息失败', error: error, stackTrace: StackTrace.current);

      // 💢💢💢 出错时通知停止加载
      _notifyConversationLoadingState(LoadingStateUpdate.error(
        conversationId: conversationId,
        loadingType: LoadingType.SEARCH,
        error: error.toString(),
      ));
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
    int limit = 50,
  }) async {
    // 💢💢💢 使用新Stream架构通知开始加载
    _notifyConversationLoadingState(LoadingStateUpdate.start(
      conversationId: conversationId,
      loadingType: LoadingType.SEARCH,
    ));

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
          .sortByMessageIndexDesc() // 按messageIndex降序排序
          .limit(limit)
          .findAll();

      _logger.d('从日期获取消息结果', extra: {'找到消息数': messages.length});

      // 💢💢💢 通知加载完成
      _notifyConversationLoadingState(LoadingStateUpdate.complete(
        conversationId: conversationId,
        loadingType: LoadingType.SEARCH,
      ));
      return messages;
    } catch (error) {
      _logger.e('从指定日期获取消息失败', error: error, stackTrace: StackTrace.current);

      // 💢💢💢 出错时通知停止加载
      _notifyConversationLoadingState(LoadingStateUpdate.error(
        conversationId: conversationId,
        loadingType: LoadingType.SEARCH,
        error: error.toString(),
      ));
      return [];
    }
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
  /// 将用户加入对应的Socket.io会话房间
  /// [conversationId] - 会话ID
  @override
  Future<void> joinConversationRoom(String conversationId) async {
    try {
      // 通知服务器用户加入会话房间
      if (_communicationService.isInitialized) {
        final joinRoomRequest =
            conversation_proto.ConversationJoinLeaveRequest()
              ..conversationId = conversationId;

        _logger.d('发送加入会话房间请求', extra: {
          'conversationId': conversationId,
        });

        final success = await _communicationService.emitProto(
            'conversation:join', joinRoomRequest);

        if (success) {
          _logger.i('发送加入会话房间请求成功', extra: {
            'conversationId': conversationId,
          });
        } else {
          _logger.w('发送加入会话房间请求失败', extra: {
            'conversationId': conversationId,
          });

          // 💢 新增：记录失败但不抛出异常，让调用者知道状态
          throw Exception('发送加入会话房间请求失败');
        }
      } else {
        _logger.w('通信服务未初始化，无法发送加入会话房间请求');
        throw Exception('通信服务未初始化');
      }
    } catch (error) {
      _logger.e('发送加入会话房间请求失败',
          error: error,
          stackTrace: StackTrace.current,
          extra: {
            'conversationId': conversationId,
          });

      rethrow;
    }
  }

  /// 用户离开会话页面
  /// 将用户从对应的Socket.io会话房间中移除，并同步阅读状态到服务器
  /// [conversationId] - 会话ID
  @override
  Future<void> leaveConversationRoom(String conversationId) async {
    try {
      _logger.i('用户离开会话页面', extra: {'conversationId': conversationId});

      // 🔥 退出会话时，同步最后阅读时间到服务器
      // TODO 需要通过ChatsRepository来更新
      _logger.d('用户离开会话页面，需要同步阅读状态到服务器');

      // 通知服务器用户离开会话房间
      if (_communicationService.isInitialized) {
        final leaveRoomRequest =
            conversation_proto.ConversationJoinLeaveRequest()
              ..conversationId = conversationId;

        final success = await _communicationService.emitProto(
            'conversation:leave', leaveRoomRequest);
        if (success) {
          _logger.d('已发送离开会话房间请求');
        } else {
          _logger.w('发送离开会话房间请求失败');
        }
      }
    } catch (error) {
      _logger.e('离开会话房间失败', error: error, stackTrace: StackTrace.current);
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

    // 💢💢💢 关闭新Stream架构的控制器
    for (var controller in _messageUpdateControllers.values) {
      if (!controller.isClosed) {
        controller.close();
      }
    }
    _messageUpdateControllers.clear();

    for (var controller in _conversationLoadingControllers.values) {
      if (!controller.isClosed) {
        controller.close();
      }
    }
    _conversationLoadingControllers.clear();
  }

  /// 💢💢💢💢💢💢💢💢💢💢💢💢💢💢   私有辅助方法   💢💢💢💢💢💢💢💢💢💢💢💢💢💢

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
      final allMessages = await queryBuilder.sortByMessageIndexDesc().findAll();

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
        if (message.type != MessageType.text) {
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
        // if (message.locationAddress != null &&
        //     message.locationAddress!.isNotEmpty) {
        //   searchableTexts.add(message.locationAddress!.toLowerCase());
        // }

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

      // 按messageIndex降序排列（最新到最老）
      matchedMessages.sort((a, b) => b.messageIndex.compareTo(a.messageIndex));

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
        'searchFields': ['text', 'fileName', 'senderName'],
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
    // 💢💢💢 使用新Stream架构通知开始加载
    _notifyConversationLoadingState(LoadingStateUpdate.start(
      conversationId: conversationId,
      loadingType: LoadingType.SEARCH,
    ));

    try {
      if (searchResultIds.isEmpty) {
        // 💢💢💢 通知加载完成
        _notifyConversationLoadingState(LoadingStateUpdate.complete(
          conversationId: conversationId,
          loadingType: LoadingType.SEARCH,
        ));
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

        // 💢💢💢 通知加载完成
        _notifyConversationLoadingState(LoadingStateUpdate.complete(
          conversationId: conversationId,
          loadingType: LoadingType.SEARCH,
        ));
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
          .sortByMessageIndexDesc() // 按messageIndex降序排列（最新到最老，符合聊天界面显示）
          .findAll();

      _logger.i('获取搜索范围消息完成', extra: {
        'totalMessages': allMessages.length,
        'timeRange':
            '${startTime.toIso8601String()} - ${endTime.toIso8601String()}',
      });

      // 💢💢💢 通知加载完成
      _notifyConversationLoadingState(LoadingStateUpdate.complete(
        conversationId: conversationId,
        loadingType: LoadingType.SEARCH,
      ));
      return allMessages;
    } catch (error) {
      _logger.e('获取搜索范围消息失败', error: error, stackTrace: StackTrace.current);

      // 💢💢💢 出错时通知停止加载
      _notifyConversationLoadingState(LoadingStateUpdate.error(
        conversationId: conversationId,
        loadingType: LoadingType.SEARCH,
        error: error.toString(),
      ));
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

      // 💢💢💢 使用新Stream架构通知开始加载
      _notifyConversationLoadingState(LoadingStateUpdate.start(
        conversationId: conversationId,
        loadingType: LoadingType.SEARCH,
      ));

      // 获取目标消息
      final targetMessage = await _messages
          .filter()
          .conversationIdEqualTo(conversationId)
          .and()
          .messageIdEqualTo(targetMessageId)
          .findFirst();

      if (targetMessage == null) {
        _logger.w('找不到目标搜索结果消息', extra: {'messageId': targetMessageId});

        // 💢💢💢 通知加载完成
        _notifyConversationLoadingState(LoadingStateUpdate.complete(
          conversationId: conversationId,
          loadingType: LoadingType.SEARCH,
        ));

        return (
          messages: <Message>[],
          timeRange: DateTimeRange(start: DateTime.now(), end: DateTime.now())
        );
      }

      // 获取目标消息之前的消息（按messageIndex升序，取最后contextSize条）
      final beforeMessages = await _messages
          .filter()
          .conversationIdEqualTo(conversationId)
          .and()
          .messageIndexLessThan(targetMessage.messageIndex)
          .sortByMessageIndex() // 按messageIndex升序
          .findAll();

      final contextBefore = beforeMessages.length > contextSize
          ? beforeMessages.sublist(beforeMessages.length - contextSize)
          : beforeMessages;

      // 获取目标消息之后的消息（按messageIndex升序，取前contextSize条）
      final afterMessages = await _messages
          .filter()
          .conversationIdEqualTo(conversationId)
          .and()
          .messageIndexGreaterThan(targetMessage.messageIndex)
          .sortByMessageIndex() // 按messageIndex升序
          .limit(contextSize)
          .findAll();

      // 合并所有消息：之前的 + 目标消息 + 之后的
      final allMessages = <Message>[
        ...contextBefore,
        targetMessage,
        ...afterMessages,
      ];

      // 按messageIndex降序排列（符合聊天界面显示）
      allMessages.sort((a, b) => b.messageIndex.compareTo(a.messageIndex));

      // 计算时间范围
      final startTime =
          allMessages.isEmpty ? DateTime.now() : allMessages.last.createdAt;
      final endTime =
          allMessages.isEmpty ? DateTime.now() : allMessages.first.createdAt;

      final timeRange = DateTimeRange(start: startTime, end: endTime);

      // 💢💢💢 通知加载完成
      _notifyConversationLoadingState(LoadingStateUpdate.complete(
        conversationId: conversationId,
        loadingType: LoadingType.SEARCH,
      ));

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

      // 💢💢💢 出错时通知停止加载
      _notifyConversationLoadingState(LoadingStateUpdate.error(
        conversationId: conversationId,
        loadingType: LoadingType.SEARCH,
        error: error.toString(),
      ));

      return (
        messages: <Message>[],
        timeRange: DateTimeRange(start: DateTime.now(), end: DateTime.now())
      );
    }
  }

  /// 💢💢💢💢💢💢💢💢💢💢💢💢💢💢 新增：处理新消息事件（服务器广播）

  /// 处理新消息事件
  /// 当服务器广播新消息时触发，需要防止重复处理
  /// [newMessage] - 新消息的Proto格式
  void _handleNewMessage(message_proto.MessageProto newMessage) async {
    try {
      _logger.d('收到新消息事件', extra: {
        'messageId': newMessage.messageId,
        'conversationId': newMessage.conversationId,
        'senderId': newMessage.senderId,
        'type': newMessage.type.toString(),
      });

      // 💢💢💢 防重复检查：如果是当前用户发送的消息，忽略
      if (newMessage.senderId == _currentUser.userId) {
        _logger.d('忽略自己发送的消息广播', extra: {
          'messageId': newMessage.messageId,
          'senderId': newMessage.senderId,
        });
        return;
      }

      // 💢💢💢 防重复检查：检查消息是否已存在于数据库
      final existingMessage = await _messages
          .filter()
          .messageIdEqualTo(newMessage.messageId)
          .findFirst();

      if (existingMessage != null) {
        _logger.d('消息已存在，忽略重复', extra: {
          'messageId': newMessage.messageId,
        });
        return;
      }

      // 💢💢💢 保存新消息到数据库
      final message = MessageAdapter.fromProto(newMessage);
      await _isar.writeTxn(() async {
        await _messages.put(message);
      });

      // 💢💢💢 关键：推送新消息事件，而不是依赖数据库监听
      _notifyMessageUpdate(MessageAddedEvent(
        conversationId: message.conversationId,
        newMessages: [message],
        loadingType: LoadingType.ADD, // 新消息来自网络
      ));

      _logger.d('新消息已保存到数据库并推送更新事件', extra: {
        'messageId': message.messageId,
        'conversationId': message.conversationId,
      });
    } catch (error) {
      _logger.e('处理新消息事件失败',
          error: error,
          stackTrace: StackTrace.current,
          extra: {'messageId': newMessage.messageId});
    }
  }

  /// 💢💢💢 新Stream架构：通知消息更新事件
  void _notifyMessageUpdate(MessageUpdateEvent event) {
    try {
      final controller = _messageUpdateControllers[event.conversationId];
      if (controller != null && !controller.isClosed) {
        controller.add(event);

        _logger.d('通知消息更新事件', extra: {
          'conversationId': event.conversationId,
          'eventType': event.runtimeType.toString(),
          'timestamp': event.timestamp.toIso8601String(),
        });
      }
    } catch (error) {
      _logger.e('通知消息更新事件失败', error: error);
    }
  }

  /// 💢💢💢 新增：外部通知消息更新事件（公共接口）
  /// 允许其他Repository组件（如ChatRepositorySend）通知消息变化
  @override
  void notifyMessageUpdate(MessageUpdateEvent event) {
    _notifyMessageUpdate(event);
  }

  /// 💢💢💢 新Stream架构：通知会话级加载状态变化
  void _notifyConversationLoadingState(LoadingStateUpdate update) {
    try {
      final controller = _conversationLoadingControllers[update.conversationId];
      if (controller != null && !controller.isClosed) {
        controller.add(update);

        _logger.d('通知会话级加载状态变化', extra: {
          'conversationId': update.conversationId,
          'loadingType': update.loadingType.toString(),
          'isLoading': update.isLoading,
          'error': update.error,
        });
      }
    } catch (error) {
      _logger.e('通知会话级加载状态失败', error: error);
    }
  }
}
