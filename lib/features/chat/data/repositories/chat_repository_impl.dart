import 'dart:async';
import 'dart:io';
import 'package:cc/core/database/models/current_user.dart';
import 'package:isar/isar.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/database/database_initializer.dart';
import 'package:cc/core/database/models/message.dart';
import 'package:cc/core/database/models/conversation.dart' as db;
import 'package:cc/core/adapters/message_adapter.dart';
import 'package:cc/core/adapters/conversation_adapter.dart';
import 'package:cc/core/services/communication_service.dart';
import 'package:cc/features/chat/domain/repositories/chat_repository.dart';
import 'package:cc/features/chat/domain/entities/message_update_event.dart';
import 'package:cc/features/chat/domain/entities/conversation_update_event.dart';
import 'package:fixnum/fixnum.dart';
import 'package:cc/core/utils/timezone_utils.dart';

import 'package:cc/core/proto/generated/message.pb.dart' as message_proto;
import 'package:cc/core/proto/generated/conversation.pb.dart'
    as conversation_proto;
import 'package:uuid/uuid.dart';

/// 🔥 临时兼容类已全部移除 - Index方案完全替代了复杂的游标系统

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
  IsarCollection<db.Conversation> get _conversations => _isar.conversations;

  // 输入事件流控制器
  final _typingStatusController =
      StreamController<Map<String, dynamic>>.broadcast();

  // 💢💢💢 新Stream架构：消息更新事件流控制器
  final Map<String, StreamController<MessagesEvent>>
      _messageUpdateControllers = {};
  // 💢💢💢 新Stream架构：会话级加载状态流控制器
  final Map<String, StreamController<LoadingStateUpdate>>
      _conversationLoadingControllers = {};
  // 💢💢💢 新增：会话更新事件流控制器
  final Map<String, StreamController<ConversationUpdateEvent>>
      _conversationUpdateControllers = {};

  // 事件订阅列表
  final List<StreamSubscription> _subscriptions = [];

  static const Uuid _uuid = Uuid();

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

  /// 💢💢💢💢💢💢💢💢💢💢💢💢💢💢 新Stream架构：获取消息更新事件流
  @override
  Stream<MessagesEvent> getMessageUpdateStream(String conversationId) {
    _messageUpdateControllers[conversationId] ??=
        StreamController<MessagesEvent>.broadcast();
    return _messageUpdateControllers[conversationId]!.stream;
  }

  /// 💢💢💢💢💢💢💢💢💢💢��💢💢💢 新Stream架构：获取会话级加载状态流
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
            .listen(_handleNewMessage))
        ..add(_communicationService
            .onProto<message_proto.MessageEditResponse>('message:edit:response')
            .listen(_handleMessageEditResponse))
        ..add(_communicationService
            .onProto<message_proto.MessageRevokeResponse>(
                'message:revoke:response')
            .listen(_handleMessageRevokeResponse))
        ..add(_communicationService
            .onProto<message_proto.MessageDeleteResponse>(
                'message:delete:response')
            .listen(_handleMessageDeleteResponse))
        ..add(_communicationService
            .onProto<conversation_proto.ConversationMemberChangeResponse>(
                'conversation:member:changed')
            .listen(_handleMemberChangeNotification));

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
      // 💢💢💢 修复：响应处理器不应该发送开始状态，只处理数据和发送完成状态
      _logger.d('开始处理服务器消息响应', extra: {
        'conversationId': conversationId,
        'jumpIndex': response.hasJumpIndex() ? response.jumpIndex : null,
        'messageCount': response.messages.length,
      });

      if (response.messages.isEmpty) {
        _logger.d('收到空的消息响应');
        // 💢💢💢 通知网络请求完成
        _notifyConversationLoadingState(LoadingStateUpdate.complete(
          conversationId: conversationId,
          loadingStateType:
              LoadingStateType.isFetching, // 🆕 _handleMessagesFetchResponse 专用
        ));
        return;
      }

      _logger.d('处理消息获取响应', extra: {
        'messageCount': response.messages.length,
      });

      // 转换消息
      final messages = <Message>[];
      for (final protoMessage in response.messages) {
        final message = MessageAdapter.fromProto(protoMessage);
        messages.add(message);
      }

      // 使用批量事务操作，提高性能和数据一致性
      await _isar.writeTxn(() async {
        // 批量插入/更新消息（自动处理重复，replace: true）
        await _messages.putAll(messages);
      });

      // 💢💢💢 关键：推送精确的消息更新事件
      // 提取跳转索引（proto3中，使用hasJumpIndex检查是否设置）
      final jumpIndex = response.hasJumpIndex() ? response.jumpIndex : null;

      _notifyMessagesEvent(MessageAddedEvent( 
        conversationId: conversationId,
        newMessages: messages,
        addedEventType: AddedEventType.load, // 🆕 服务器获取的消息
        anchorMessageIndex: jumpIndex, // 🆕 使用jumpIndex作为锚点
      ));

      // 💢💢💢 通知网络请求完成
      _notifyConversationLoadingState(LoadingStateUpdate.complete(
        conversationId: conversationId,
        loadingStateType:
            LoadingStateType.isFetching, // 🆕 _handleMessagesFetchResponse 专用
        metadata: {'messageCount': messages.length},
      ));

      _logger.i('消息批量写入数据库完成', extra: {
        'insertedCount': response.messages.length,
        'jumpIndex': jumpIndex,
      });
    } catch (error) {
      _logger.e('将收到的信息写入数据库失败', error: error, stackTrace: StackTrace.current);

      // 💢💢💢 处理失败时通知错误
      _notifyConversationLoadingState(LoadingStateUpdate.error(
        conversationId: conversationId,
        loadingStateType:
            LoadingStateType.isFetching, // 🆕 _handleMessagesFetchResponse 专用
        error: error.toString(),
      ));
    }
  }

  /// 处理消息发送响应
  void _handleMessageSendResponse(
      message_proto.MessageSendResponse response) async {
    try {
      // 💢💢💢 新增：验证conversationId不能为空
      if (response.conversationId.isEmpty) {
        _logger.e('⚠️ 消息发送响应被拒绝：conversationId为空', extra: {
          'messageId': response.messageId,
          'success': response.success,
          'hasConversationId': response.hasConversationId(),
        });
        return; // 直接返回，不处理空的conversationId
      }

      _logger.i('💌 收到消息发送响应', extra: {
        'success': response.success,
        'messageId': response.messageId,
        'messageIndex': response.messageIndex.toInt(),
        'conversationId': response.conversationId,
        'msg': response.msg,
      });

      if (response.messageId.isEmpty) {
        _logger.w('💌 消息发送响应缺少消息ID，无法匹配本地消息', extra: {
          'conversationId': response.conversationId,
        });
        return;
      }

      // 💢💢💢 直接按messageId查找消息
      final message = await _messages
          .filter()
          .messageIdEqualTo(response.messageId)
          .findFirst();
      if (message == null) {
        _logger.w('💌 找不到对应的消息', extra: {
          'messageId': response.messageId,
        });
        return;
      }

      if (response.success) {
        // 💢💢💢 发送成功，更新消息索引、状态和服务器时间戳
        await _isar.writeTxn(() async {
          message.messageIndex = response.messageIndex.toInt();
          message.status = MessageStatus.sent;
          message.updatedAt = TimezoneUtils.nowUtc(); // 🌍 使用UTC时间

          // 🆕 使用服务器时间戳替换本地乐观更新时的时间戳
          if (response.hasCreatedAt()) {
            message.createdAt =
                TimezoneUtils.fromServerTimestamp(response.createdAt.toInt());
          }

          await _messages.put(message);
        });

        // 💢💢💢 推送消息更新事件
        _notifyMessagesEvent(MessageUpdatedEvent(
          conversationId: message.conversationId,
          messageId: message.messageId,
          timestamp: TimezoneUtils.nowUtc(),
          updatedFields: {
            'messageIndex': response.messageIndex.toInt(),
            'status': MessageStatus.sent.name,
            'updatedAt': TimezoneUtils.nowUtc().toIso8601String(),
            'createdAt': response.hasCreatedAt()
                ? TimezoneUtils.fromServerTimestamp(response.createdAt.toInt())
                    .toIso8601String()
                : null,
          }..removeWhere((key, value) => value == null),
        ));

        _logger.i('💌 服务器确认消息发送成功，已更新本地消息和UI状态', extra: {
          'messageId': response.messageId,
          'messageIndex': response.messageIndex.toInt(),
          'type': message.type.name,
          'hasServerTimestamp': response.hasCreatedAt(),
          'serverTimestamp': response.hasCreatedAt()
              ? TimezoneUtils.fromServerTimestamp(response.createdAt.toInt())
                  .toIso8601String()
              : null,
          'originalLocalTimestamp': message.createdAt.toIso8601String(),
        });
      } else {
        // 发送失败，更新状态为失败
        await _isar.writeTxn(() async {
          message.status = MessageStatus.failed;
          message.updatedAt = TimezoneUtils.nowUtc(); // 🌍 使用UTC时间
          await _messages.put(message);
        });

        // 通知UI消息发送失败
        _notifyMessagesEvent(MessageUpdatedEvent(
          conversationId: message.conversationId,
          messageId: message.messageId,
          timestamp: TimezoneUtils.nowUtc(),
          updatedFields: {
            'status': MessageStatus.failed.name,
            'updatedAt': TimezoneUtils.nowUtc().toIso8601String(),
          },
        ));

        _logger.w('💌 消息发送失败，服务器返回错误', extra: {
          'messageId': response.messageId,
          'errorMsg': response.msg,
          'type': message.type.name,
        });
      }
    } catch (error) {
      _logger.e('💌 处理消息发送响应失败', error: error, stackTrace: StackTrace.current);
    }
  }

  /// 💢💢💢💢💢💢💢💢💢💢💢💢💢💢    Request    💢💢💢💢💢💢💢💢💢💢💢💢💢💢

  @override
  Future<bool> requestMessages(
      String conversationId, int indexA, int indexB, jumpIndex) async {
    _logger.i('请求服务器获取指定范围的消息', extra: {
      'conversationId': conversationId,
      'indexA': indexA,
      'indexB': indexB,
      'jumpIndex': jumpIndex,
      'rangeSize': indexA > indexB ? indexA - indexB + 1 : indexB - indexA + 1,
    });

    try {
      // 更新状态
      _notifyConversationLoadingState(LoadingStateUpdate.start(
        conversationId: conversationId,
        loadingStateType:
            LoadingStateType.isFetching, // 🆕 _handleMessagesFetchResponse 专用
      ));

      // 🆕 创建请求对象 - 直接使用新的索引范围字段
      final request = message_proto.MessagesFetchRequest()
        ..conversationId = conversationId
        ..indexA = indexA
        ..indexB = indexB
        ..jumpIndex = jumpIndex;

      // 发送请求到服务器
      await _communicationService.emitProto('messages:fetch', request);
      return true;
    } catch (error) {
      _logger.e('请求服务器获取指定范围的消息失败',
          error: error, stackTrace: StackTrace.current);
      return false;
    }
  }

  /// 💢💢💢💢💢💢💢💢💢💢💢💢💢💢  Get4Database  💢💢💢💢💢💢💢💢💢💢💢💢💢💢

  /// 🆕 加载指定范围的消息
  /// [conversationId] - 会话ID
  /// [indexA] - 开始索引（包含）
  /// [indexB] - 结束索引（包含）
  /// [jumpIndex] - 跳转目标索引（用于滚动定位，0表示无跳转）
  @override
  Future<bool> loadMessages(
      String conversationId, int indexA, int indexB, int jumpIndex) async {
    try {
      _logger.d('🆕 加载指定范围的消息 - 开始', extra: {
        'conversationId': conversationId,
        'indexA': indexA,
        'indexB': indexB,
        'jumpIndex': jumpIndex,
      });

      // 🆕 loadMessages 自有的状态管理 - 发送开始状态
      _notifyConversationLoadingState(LoadingStateUpdate.start(
        conversationId: conversationId,
        loadingStateType:
            LoadingStateType.isLoading, // 🆕 loadMessages 使用 isLoading
      ));

      // 🆕 直接基于索引范围加载：加载 [indexA, indexB] 范围内的消息
      final messages = await _messages
          .filter()
          .conversationIdEqualTo(conversationId)
          .and()
          .messageIndexBetween(indexA, indexB)
          .sortByCreatedAtDesc()
          .findAll();

      // 计算期望的消息数量
      final expectedCount =
          indexA > indexB ? indexA - indexB + 1 : indexB - indexA + 1;

      // 检查是否需要请求服务器：如果数据库中的消息数量少于预期
      if (messages.length < expectedCount) {
        _logger.i('数据库消息不足，请求服务器', extra: {
          'localCount': messages.length,
          'expectedCount': expectedCount,
          'needFromServer': expectedCount - messages.length,
        });

        // 请求服务器获取缺失的消息
        await requestMessages(conversationId, indexA, indexB, jumpIndex);

        // 🆕 loadMessages 状态管理 - 发送完成状态（本地部分完成）
        _notifyConversationLoadingState(LoadingStateUpdate.complete(
          conversationId: conversationId,
          loadingStateType: LoadingStateType.isLoading, // 🆕 loadMessages 专用类型
        ));

        return true;
      }

      // 🆕 数据库中有足够的消息，直接推送并完成
      _logger.d('数据库消息充足，直接推送', extra: {
        'messageCount': messages.length,
      });

      // 推送消息更新事件
      _messageUpdateControllers[conversationId]!.add(MessageAddedEvent(
        conversationId: conversationId,
        newMessages: messages,
        addedEventType: AddedEventType.load, // 🆕 本地数据库加载的消息
        anchorMessageIndex:
            jumpIndex != 0 ? jumpIndex : null, // 🆕 使用jumpIndex作为锚点
      ));

      // 🆕 loadMessages 状态管理 - 发送完成状态
      _notifyConversationLoadingState(LoadingStateUpdate.complete(
        conversationId: conversationId,
        loadingStateType: LoadingStateType.isLoading, // 🆕 loadMessages 专用类型
      ));

      return true;
    } catch (error) {
      _logger.e('加载指定范围的消息失败',
          error: error,
          stackTrace: StackTrace.current,
          extra: {
            'conversationId': conversationId,
            'indexA': indexA,
            'indexB': indexB,
            'jumpIndex': jumpIndex,
          });

      // 🆕 loadMessages 状态管理 - 发送错误状态
      _notifyConversationLoadingState(LoadingStateUpdate.error(
        conversationId: conversationId,
        loadingStateType: LoadingStateType.isLoading, // 🆕 loadMessages 专用类型
        error: error.toString(),
      ));

      return false;
    }
  }

  /// 获取会话中的消息数量
  @override
  Future<int> getConversationMessageCount(String conversationId) async {
    try {
      final allMessages = await _messages
          .filter()
          .conversationIdEqualTo(conversationId)
          .findAll();

      return allMessages.length;
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

  /// 编辑消息 message:edit
  /// 编辑指定消息的文本内容
  /// [messageId] - 消息ID
  /// [conversationId] - 会话ID
  /// [newText] - 新的文本内容
  @override
  Future<bool> editMessage(
      String messageId, String conversationId, String newText) async {
    try {
      _logger.i('发送消息编辑请求', extra: {
        'messageId': messageId,
        'conversationId': conversationId,
        'newTextLength': newText.length,
      });

      if (!_communicationService.isInitialized) {
        _logger.w('通信服务未初始化，无法编辑消息');
        return false;
      }

      // 创建编辑请求
      final request = message_proto.MessageEditRequest()
        ..messageId = messageId
        ..conversationId = conversationId
        ..newText = newText;

      // 发送编辑请求
      final success =
          await _communicationService.emitProto('message:edit', request);

      if (success) {
        _logger.i('消息编辑请求已发送', extra: {
          'messageId': messageId,
          'conversationId': conversationId,
        });
      } else {
        _logger.w('消息编辑请求发送失败', extra: {
          'messageId': messageId,
          'conversationId': conversationId,
        });
      }

      return success;
    } catch (error) {
      _logger.e('发送消息编辑请求失败', error: error, stackTrace: StackTrace.current);
      return false;
    }
  }

  /// 撤回消息 message:revoke
  /// 撤回指定的消息
  /// [messageId] - 消息ID
  /// [conversationId] - 会话ID
  @override
  Future<bool> revokeMessage(String messageId, String conversationId) async {
    try {
      _logger.i('发送消息撤回请求', extra: {
        'messageId': messageId,
        'conversationId': conversationId,
      });

      if (!_communicationService.isInitialized) {
        _logger.w('通信服务未初始化，无法撤回消息');
        return false;
      }

      // 创建撤回请求
      final request = message_proto.MessageRevokeRequest()
        ..messageId = messageId
        ..conversationId = conversationId;

      // 发送撤回请求
      final success =
          await _communicationService.emitProto('message:revoke', request);

      if (success) {
        _logger.i('消息撤回请求已发送', extra: {
          'messageId': messageId,
          'conversationId': conversationId,
        });
      } else {
        _logger.w('消息撤回请求发送失败', extra: {
          'messageId': messageId,
          'conversationId': conversationId,
        });
      }

      return success;
    } catch (error) {
      _logger.e('发送消息撤回请求失败', error: error, stackTrace: StackTrace.current);
      return false;
    }
  }

  /// 删除消息 message:delete
  /// 删除指定的消息
  /// [messageId] - 消息ID
  /// [conversationId] - 会话ID
  @override
  Future<bool> deleteMessage(String messageId, String conversationId) async {
    try {
      _logger.i('发送消息删除请求', extra: {
        'messageId': messageId,
        'conversationId': conversationId,
      });

      if (!_communicationService.isInitialized) {
        _logger.w('通信服务未初始化，无法删除消息');
        return false;
      }

      // 创建删除请求
      final request = message_proto.MessageDeleteRequest()
        ..messageId = messageId
        ..conversationId = conversationId;

      // 发送删除请求
      final success =
          await _communicationService.emitProto('message:delete', request);

      if (success) {
        _logger.i('消息删除请求已发送', extra: {
          'messageId': messageId,
          'conversationId': conversationId,
        });

        // 💢💢💢 本地也标记为删除状态
        await _markMessageAsDeletedLocally(messageId);
      } else {
        _logger.w('消息删除请求发送失败', extra: {
          'messageId': messageId,
          'conversationId': conversationId,
        });
      }

      return success;
    } catch (error) {
      _logger.e('发送消息删除请求失败', error: error, stackTrace: StackTrace.current);
      return false;
    }
  }

  /// 💢💢💢 本地标记消息为已删除状态
  Future<void> _markMessageAsDeletedLocally(String messageId) async {
    try {
      // 💢💢💢 直接按messageId查找消息
      final message =
          await _messages.filter().messageIdEqualTo(messageId).findFirst();

      if (message == null) {
        _logger.w('要删除的消息未找到', extra: {
          'messageId': messageId,
        });
        return;
      }

      // 更新消息状态为已删除
      await _isar.writeTxn(() async {
        message.status = MessageStatus.deleted;
        message.updatedAt = DateTime.now();
        await _messages.put(message);
      });

      // 通知UI更新
      _notifyMessagesEvent(MessageUpdatedEvent(
        conversationId: message.conversationId,
        messageId: message.messageId,
        timestamp: TimezoneUtils.nowUtc(),
        updatedFields: {
          'status': MessageStatus.deleted.name,
          'updatedAt': DateTime.now().toIso8601String(),
        },
      ));

      _logger.i('消息已标记为删除', extra: {
        'messageId': messageId,
        'conversationId': message.conversationId,
      });
    } catch (error) {
      _logger.e('标记消息删除失败', error: error, stackTrace: StackTrace.current);
    }
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
      loadingStateType:
          LoadingStateType.isLoading, // 🆕 loadMessages 使用 isLoading
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
      final rawMessages = await _messages
          .filter()
          .conversationIdEqualTo(conversationId)
          .createdAtBetween(safeStartDate, safeEndDate)
          .sortByCreatedAtDesc() // 按服务器时间戳降序排序
          .limit(limit)
          .findAll();

      // 💢💢💢 应用删除消息过滤规则
      final messages = rawMessages;

      _logger.d('按日期范围查询结果', extra: {'找到消息数': messages.length});

      // 💢💢💢 通知加载完成
      _notifyConversationLoadingState(LoadingStateUpdate.complete(
        conversationId: conversationId,
        loadingStateType:
            LoadingStateType.isLoading, // 🆕 loadMessages 使用 isLoading
      ));
      return messages;
    } catch (error) {
      _logger.e('根据日期范围获取消息失败', error: error, stackTrace: StackTrace.current);

      // 💢💢💢 出错时通知停止加载
      _notifyConversationLoadingState(LoadingStateUpdate.error(
        conversationId: conversationId,
        loadingStateType:
            LoadingStateType.isLoading, // 🆕 loadMessages 使用 isLoading
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
      loadingStateType:
          LoadingStateType.isLoading, // 🆕 loadMessages 使用 isLoading
    ));

    try {
      // 确保使用日期的开始时间
      final dayStart =
          DateTime(startDate.year, startDate.month, startDate.day, 0, 0, 0);

      // 查询从指定日期开始的消息
      final rawMessages = await _messages
          .filter()
          .conversationIdEqualTo(conversationId)
          .createdAtGreaterThan(
              dayStart.subtract(const Duration(seconds: 1))) // 大于等于指定日期
          .sortByCreatedAtDesc() // 按服务器时间戳降序排序
          .limit(limit)
          .findAll();

      // 💢💢💢 应用删除消息过滤规则
      final messages = rawMessages;

      _logger.d('从日期获取消息结果', extra: {'找到消息数': messages.length});

      // 💢💢💢 通知加载完成
      _notifyConversationLoadingState(LoadingStateUpdate.complete(
        conversationId: conversationId,
        loadingStateType:
            LoadingStateType.isLoading, // 🆕 loadMessages 使用 isLoading
      ));
      return messages;
    } catch (error) {
      _logger.e('从指定日期获取消息失败', error: error, stackTrace: StackTrace.current);

      // 💢💢💢 出错时通知停止加载
      _notifyConversationLoadingState(LoadingStateUpdate.error(
        conversationId: conversationId,
        loadingStateType:
            LoadingStateType.isLoading, // 🆕 loadMessages 使用 isLoading
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
          _logger.i('加入会话房间请求已发送', extra: {
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
          matchedMessageIndexes: [],
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
      final rawMessages = await queryBuilder.sortByCreatedAtDesc().findAll();

      // 💢💢💢 应用删除消息过滤规则
      final allMessages = rawMessages;

      _logger.d('获取基础消息列表', extra: {
        'totalMessages': allMessages.length,
        'keywords': keywords,
      });

      // 💢💢💢 在内存中进行关键词匹配，确保每条消息只被计算一次
      final matchedMessages = <Message>[];
      final matchedMessageIndexes = <int>{};
      int textMessageCount = 0;
      int nonTextMessageCount = 0;

      for (final message in allMessages) {
        // 确保不重复处理同一条消息
        if (matchedMessageIndexes.contains(message.messageIndex)) {
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
          matchedMessageIndexes.add(message.messageIndex);
        }
      }

      // 提取消息ID列表（从新到旧排序）
      final matchedMessageIndexesList = matchedMessageIndexes.toList();

      final result = SearchResult(
        matchedMessageIndexes: matchedMessageIndexesList,
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
        matchedMessageIndexes: [],
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
      loadingStateType:
          LoadingStateType.isLoading, // 🆕 loadMessages 使用 isLoading
    ));

    try {
      if (searchResultIds.isEmpty) {
        // 💢💢💢 通知加载完成
        _notifyConversationLoadingState(LoadingStateUpdate.complete(
          conversationId: conversationId,
          loadingStateType:
              LoadingStateType.isLoading, // 🆕 loadMessages 使用 isLoading
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
          loadingStateType:
              LoadingStateType.isLoading, // 🆕 loadMessages 使用 isLoading
        ));
        return [];
      }

      // 获取时间范围内的所有消息
      final startTime = firstMessage.createdAt;
      final endTime =
          lastMessage.createdAt.add(const Duration(seconds: 1)); // 包含最后一条消息

      final rawMessages = await _messages
          .filter()
          .conversationIdEqualTo(conversationId)
          .and()
          .createdAtBetween(startTime, endTime)
          .sortByCreatedAtDesc() // 按服务器时间戳降序排列（最新到最老，符合聊天界面显示）
          .findAll();

      // 💢💢💢 应用删除消息过滤规则
      final allMessages = rawMessages;

      _logger.i('获取搜索范围消息完成', extra: {
        'totalMessages': allMessages.length,
        'timeRange':
            '${startTime.toIso8601String()} - ${endTime.toIso8601String()}',
      });

      // 💢💢💢 通知加载完成
      _notifyConversationLoadingState(LoadingStateUpdate.complete(
        conversationId: conversationId,
        loadingStateType:
            LoadingStateType.isLoading, // 🆕 loadMessages 使用 isLoading
      ));
      return allMessages;
    } catch (error) {
      _logger.e('获取搜索范围消息失败', error: error, stackTrace: StackTrace.current);

      // 💢💢💢 出错时通知停止加载
      _notifyConversationLoadingState(LoadingStateUpdate.error(
        conversationId: conversationId,
        loadingStateType:
            LoadingStateType.isLoading, // 🆕 loadMessages 使用 isLoading
        error: error.toString(),
      ));
      return [];
    }
  }

  /// 💢💢💢 新增：加载指定搜索结果附近的消息
  @override
  Future<List<Message>> getMessagesAroundSearchResult({
    required String conversationId,
    required int targetMessageIndex,
    int contextSize = 25,
  }) async {
    try {
      _logger.i('加载搜索结果附近的消息', extra: {
        'conversationId': conversationId,
        'targetMessageIndex': targetMessageIndex,
        'contextSize': contextSize,
      });

      // 💢💢💢 使用新Stream架构通知开始加载
      _notifyConversationLoadingState(LoadingStateUpdate.start(
        conversationId: conversationId,
        loadingStateType:
            LoadingStateType.isLoading, // 🆕 loadMessages 使用 isLoading
      ));

      // 💢💢💢 直接根据targetMessageIndex计算前后范围
      final startIndex =
          (targetMessageIndex - contextSize).clamp(1, targetMessageIndex);
      final endIndex = targetMessageIndex + contextSize;

      _logger.d('计算索引范围', extra: {
        'targetMessageIndex': targetMessageIndex,
        'startIndex': startIndex,
        'endIndex': endIndex,
        'contextSize': contextSize,
      });

      // 直接根据messageIndex范围获取消息
      final allMessages = await _messages
          .filter()
          .conversationIdEqualTo(conversationId)
          .and()
          .messageIndexBetween(startIndex, endIndex)
          .sortByCreatedAt() // 按服务器时间戳升序
          .findAll();

      // 💢💢💢 按创建时间排序（降序，最新消息在前）
      allMessages.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // 💢💢💢 通知加载完成
      _notifyConversationLoadingState(LoadingStateUpdate.complete(
        conversationId: conversationId,
        loadingStateType:
            LoadingStateType.isLoading, // 🆕 loadMessages 使用 isLoading
      ));

      _logger.i('加载搜索结果附近消息完成', extra: {
        'totalMessages': allMessages.length,
        'targetMessageIndex': targetMessageIndex,
        'indexRange': '$startIndex-$endIndex',
      });

      return allMessages;
    } catch (error) {
      _logger.e('加载搜索结果附近消息失败', error: error, stackTrace: StackTrace.current);

      // 💢💢💢 出错时通知停止加载
      _notifyConversationLoadingState(LoadingStateUpdate.error(
        conversationId: conversationId,
        loadingStateType:
            LoadingStateType.isLoading, // 🆕 loadMessages 使用 isLoading
        error: error.toString(),
      ));

      return <Message>[];
    }
  }

  /// 💢💢💢💢💢💢💢💢💢💢💢💢💢💢 新增：处理新消息事件（服务器广播）

  /// 处理新消息事件
  /// 当服务器广播新消息时触发，需要防止重复处理
  /// [newMessage] - 新消息的Proto格式
  void _handleNewMessage(message_proto.MessageProto newMessage) async {
    try {
      _logger.d('收到新消息事件', extra: {'newMessage': newMessage});

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
      _notifyMessagesEvent(MessageAddedEvent(
        conversationId: message.conversationId,
        newMessages: [message],
        addedEventType: AddedEventType.newMessage, // 🆕 新消息（实时接收）
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

  /// 处理消息编辑响应
  /// 当服务器返回消息编辑结果时触发
  /// [response] - 编辑响应
  void _handleMessageEditResponse(
      message_proto.MessageEditResponse response) async {
    try {
      _logger.i('收到消息编辑响应', extra: {
        'success': response.success,
        'messageId': response.messageId,
        'newText': response.newText,
        'msg': response.msg,
      });

      if (response.success) {
        // 编辑成功，更新本地消息内容
        // 💢💢💢 直接按messageId查找消息
        final message = await _messages
            .filter()
            .messageIdEqualTo(response.messageId)
            .findFirst();

        if (message != null) {
          await _isar.writeTxn(() async {
            message.text = response.newText;
            message.updatedAt =
                TimezoneUtils.fromServerTimestamp(response.editedAt.toInt());
            await _messages.put(message);
          });

          // 通知UI消息已编辑
          _notifyMessagesEvent(MessageUpdatedEvent(
            conversationId: message.conversationId,
            messageId: message.messageId,
            updatedFields: {
              'text': response.newText,
              'editedAt': message.updatedAt?.toIso8601String(),
            },
          ));

          _logger.i('服务器确认消息编辑成功，已更新本地数据', extra: {
            'messageId': response.messageId,
            'newText': response.newText,
          });
        } else {
          _logger.w('找不到要编辑的消息', extra: {'messageId': response.messageId});
        }
      } else {
        _logger.w('消息编辑失败', extra: {
          'messageId': response.messageId,
          'error': response.msg,
        });
      }
    } catch (error) {
      _logger.e('处理消息编辑响应失败', error: error, stackTrace: StackTrace.current);
    }
  }

  /// 处理消息撤回响应
  /// 当服务器返回消息撤回结果时触发
  /// [response] - 撤回响应
  void _handleMessageRevokeResponse(
      message_proto.MessageRevokeResponse response) async {
    try {
      // 💢💢💢 新增：验证conversationId不能为空
      if (response.conversationId.isEmpty) {
        _logger.e('⚠️ 消息撤回响应被拒绝：conversationId为空', extra: {
          'messageId': response.messageId,
          'success': response.success,
          'hasConversationId': response.hasConversationId(),
        });
        return; // 直接返回，不处理空的conversationId
      }

      _logger.i('收到消息撤回响应', extra: {
        'success': response.success,
        'messageId': response.messageId,
        'conversationId': response.conversationId,
        'msg': response.msg,
      });

      if (response.success) {
        // 撤回成功，更新本地消息状态
        // 💢💢💢 直接按messageId查找消息
        final message = await _messages
            .filter()
            .messageIdEqualTo(response.messageId)
            .findFirst();

        if (message != null) {
          await _isar.writeTxn(() async {
            message.status = MessageStatus.revoked;
            message.text = null; // 清空文本内容
            message.mediaUrl = null; // 清空媒体URL
            message.thumbnailUrl = null; // 清空缩略图URL
            message.updatedAt =
                TimezoneUtils.fromServerTimestamp(response.revokedAt.toInt());
            await _messages.put(message);
          });

          // 通知UI消息已撤回
          _notifyMessagesEvent(MessageUpdatedEvent(
            conversationId: message.conversationId,
            messageId: message.messageId,
            updatedFields: {
              'status': 'revoked',
              'revokedAt': message.updatedAt?.toIso8601String(),
            },
          ));

          _logger.i('服务器确认消息撤回成功，已更新本地数据', extra: {
            'messageId': response.messageId,
          });
        } else {
          _logger.w('找不到要撤回的消息', extra: {'messageId': response.messageId});
        }
      } else {
        _logger.w('消息撤回失败', extra: {
          'messageId': response.messageId,
          'error': response.msg,
        });
      }
    } catch (error) {
      _logger.e('处理消息撤回响应失败', error: error, stackTrace: StackTrace.current);
    }
  }

  /// 处理消息删除响应
  void _handleMessageDeleteResponse(
      message_proto.MessageDeleteResponse response) async {
    try {
      _logger.i('💌 收到消息删除响应', extra: {
        'success': response.success,
        'messageId': response.messageId,
        'msg': response.msg,
      });

      if (response.success) {
        // 从数据库中查找对应消息并更新状态
        final message = await _messages
            .filter()
            .messageIdEqualTo(response.messageId)
            .findFirst();

        if (message != null) {
          // 更新消息状态为已删除
          await _isar.writeTxn(() async {
            message.status = MessageStatus.deleted;
            message.updatedAt = DateTime.now();
            await _messages.put(message);
          });

          // 💢💢💢 触发消息更新事件通知UI
          _notifyMessagesEvent(MessageUpdatedEvent(
            conversationId: message.conversationId,
            messageId: message.messageId,
            updatedFields: {
              'status': 'deleted',
              'deletedAt': message.updatedAt?.toIso8601String(),
            },
          ));

          _logger.i('服务器确认消息删除成功，已更新本地数据', extra: {
            'messageId': response.messageId,
          });
        } else {
          _logger.w('找不到要删除的消息', extra: {'messageId': response.messageId});
        }
      } else {
        _logger.w('消息删除失败', extra: {
          'messageId': response.messageId,
          'error': response.msg,
        });
      }
    } catch (error) {
      _logger.e('处理消息删除响应失败', error: error, stackTrace: StackTrace.current);
    }
  }

  /// 处理会话成员变更通知 (conversation:member:changed)
  void _handleMemberChangeNotification(
      conversation_proto.ConversationMemberChangeResponse notification) async {
    try {
      _logger.i('💥 收到会话成员变更通知 (conversation:member:changed)', extra: {
        'conversationId': notification.conversationId,
        'userId': notification.member.userId,
        'memberName': notification.member.name,
        'action': notification.action,
        'actionBy': notification.actionBy,
        'timestamp': notification.timestamp,
      });

      await _isar.writeTxn(() async {
        // 1. 更新本地会话数据中的参与者信息
        final conversation = await _conversations
            .filter()
            .conversationIdEqualTo(notification.conversationId)
            .findFirst();

        if (conversation == null) {
          _logger.w('本地找不到对应的会话，跳过处理', extra: {
            'conversationId': notification.conversationId,
          });
          return;
        }

        // 转换ParticipantProto为Participant
        final updatedParticipant =
            ConversationAdapter.participantFromProto(notification.member);

        // 根据action类型更新参与者信息
        switch (notification.action) {
          case 'added':
            // 新成员加入：添加到参与者列表
            conversation.addParticipant(updatedParticipant);
            _logger.i('成员加入会话', extra: {
              'memberName': notification.member.name,
              'conversationId': notification.conversationId,
            });
            break;

          case 'removed':
            // 成员被移除：从参与者列表删除
            conversation.removeParticipant(notification.member.userId);
            _logger.i('成员离开会话', extra: {
              'memberName': notification.member.name,
              'conversationId': notification.conversationId,
            });
            break;

          case 'promoted':
            // 成员权限提升：更新角色信息
            conversation.updateParticipant(updatedParticipant);
            _logger.i('成员权限提升', extra: {
              'memberName': notification.member.name,
              'newRole': notification.member.role.toString(),
              'conversationId': notification.conversationId,
            });
            break;

          case 'demoted':
            // 成员权限降级：更新角色信息
            conversation.updateParticipant(updatedParticipant);
            _logger.i('成员权限降级', extra: {
              'memberName': notification.member.name,
              'newRole': notification.member.role.toString(),
              'conversationId': notification.conversationId,
            });
            break;

          case 'blocked':
            // 成员被屏蔽：标记为非活跃状态
            updatedParticipant.isActive = false;
            conversation.updateParticipant(updatedParticipant);
            _logger.i('成员被屏蔽', extra: {
              'memberName': notification.member.name,
              'conversationId': notification.conversationId,
            });
            break;

          default:
            _logger.w('未知的成员变更操作', extra: {
              'action': notification.action,
              'conversationId': notification.conversationId,
            });
            return; // 未知操作，跳过后续处理
        }

        // 保存更新后的会话
        await _conversations.put(conversation);

        // 2. 发送会话更新事件通知UI更新参与者列表
        final notifyController =
            _conversationUpdateControllers[notification.conversationId];
        if (notifyController != null && !notifyController.isClosed) {
          notifyController.add(ConversationUpdatedEvent(
            updatedConversation: conversation,
            updatedFields: ['participants'],
            timestamp: DateTime.now(),
          ));
        }

        // 3. 创建系统消息显示成员变更信息
        await _createMemberChangeSystemMessage(
          conversationId: notification.conversationId,
          member: notification.member,
          action: notification.action,
          actionBy: notification.actionBy,
          timestamp: notification.timestamp,
          conversation: conversation,
        );
      });
    } catch (error, stackTrace) {
      _logger.e('处理会话成员变更通知失败', error: error, stackTrace: stackTrace);
    }
  }

  /// 💢💢💢 新Stream架构：通知消息更新事件
  void _notifyMessagesEvent(MessagesEvent event) {
    try {
      final controller = _messageUpdateControllers[event.conversationId];
      if (controller != null && !controller.isClosed) {
        controller.add(event);

        // _logger.d('通知消息更新事件', extra: {
        //   'conversationId': event.conversationId,
        //   'eventType': event.runtimeType.toString(),
        //   'timestamp': event.timestamp.toIso8601String(),
        // });
      }
    } catch (error) {
      _logger.e('通知消息更新事件失败', error: error);
    }
  }

  /// 💢💢💢 新增：外部通知消息更新事件（公共接口）
  /// 允许其他Repository组件（如ChatRepositorySend）通知消息变化
  @override
  void notifyMessageUpdate(MessagesEvent event) {
    _notifyMessagesEvent(event);  
  }

  /// 💢💢💢 新Stream架构：通知会话级加载状态变化
  void _notifyConversationLoadingState(LoadingStateUpdate update) {
    try {
      // 💢💢💢 新增：验证conversationId不能为空
      if (update.conversationId.isEmpty) {
        _logger.e('⚠️ 加载状态更新被拒绝：conversationId为空', extra: {
          'loadingStateType': update.loadingStateType.toString(),
          'isLoading': update.isLoading,
          'error': update.error,
          'stackTrace':
              StackTrace.current.toString().split('\n').take(5).join('\n'),
        });
        return; // 直接返回，不处理空的conversationId
      }

      final controller = _conversationLoadingControllers[update.conversationId];

      if (controller != null && !controller.isClosed) {
        controller.add(update);

        _logger.d('通知会话级加载状态变化', extra: {
          'conversationId': update.conversationId,
          'loadingStateType': update.loadingStateType.toString(),
          'isLoading': update.isLoading,
          'error': update.error,
        });
      } else {
        _logger.w('无法发送加载状态更新：控制器无效', extra: {
          'conversationId': update.conversationId,
          'hasController': controller != null,
          'controllerClosed': controller?.isClosed ?? true,
          'loadingStateType': update.loadingStateType.toString(),
          'isLoading': update.isLoading,
        });
      }
    } catch (error) {
      _logger.e('通知会话级加载状态失败', error: error, extra: {
        'conversationId': update.conversationId,
        'loadingStateType': update.loadingStateType.toString(),
        'isLoading': update.isLoading,
      });
    }
  }

  /// 💢💢💢💢💢💢💢💢💢💢💢💢💢💢  会话成员管理  💢💢💢💢💢💢💢💢💢💢💢💢💢💢

  @override
  Future<bool> updateMemberRole(
      String conversationId, String userId, String action) async {
    try {
      if (!_communicationService.isInitialized) {
        _logger.w('通信服务未初始化，无法更新成员角色');
        return false;
      }

      final memberRequest = conversation_proto.ConversationMemberChangeRequest()
        ..conversationId = conversationId
        ..userId = userId
        ..action = action;

      final success = await _communicationService.emitProto(
        'conversation:member:change',
        memberRequest,
      );

      if (success) {
        _logger.i('成员角色更新请求已发送', extra: {
          'conversationId': conversationId,
          'userId': userId,
          'action': action,
        });
      } else {
        _logger.w('发送成员角色更新请求失败');
      }

      return success;
    } catch (error) {
      _logger.e('更新成员角色失败', error: error);
      return false;
    }
  }

  @override
  Future<bool> removeMemberFromConversation(
      String conversationId, String userId) async {
    try {
      if (!_communicationService.isInitialized) {
        _logger.w('通信服务未初始化，无法移除会话成员');
        return false;
      }

      final memberRequest = conversation_proto.ConversationMemberChangeRequest()
        ..conversationId = conversationId
        ..userId = userId
        ..action = 'remove';

      final success = await _communicationService.emitProto(
        'conversation:member:change',
        memberRequest,
      );

      if (success) {
        _logger.i('成员移除请求已发送', extra: {
          'conversationId': conversationId,
          'userId': userId,
        });
      } else {
        _logger.w('发送成员移除请求失败');
      }

      return success;
    } catch (error) {
      _logger.e('移除会话成员失败', error: error);
      return false;
    }
  }

  @override
  Future<bool> blockMemberInConversation(
      String conversationId, String userId) async {
    try {
      if (!_communicationService.isInitialized) {
        _logger.w('通信服务未初始化，无法屏蔽会话成员');
        return false;
      }

      final memberRequest = conversation_proto.ConversationMemberChangeRequest()
        ..conversationId = conversationId
        ..userId = userId
        ..action = 'block';

      final success = await _communicationService.emitProto(
        'conversation:member:change',
        memberRequest,
      );

      if (success) {
        _logger.i('成员屏蔽请求已发送', extra: {
          'conversationId': conversationId,
          'userId': userId,
        });
      } else {
        _logger.w('发送成员屏蔽请求失败');
      }

      return success;
    } catch (error) {
      _logger.e('屏蔽会话成员失败', error: error);
      return false;
    }
  }

  /// 创建成员变更系统消息
  /// 根据成员变更类型创建相应的系统消息提示用户
  Future<void> _createMemberChangeSystemMessage({
    required String conversationId,
    required conversation_proto.ParticipantProto member,
    required String action,
    required String actionBy,
    required Int64 timestamp,
    required db.Conversation conversation,
  }) async {
    try {
      // 确定系统事件类型
      message_proto.SystemEventType eventType;
      String messageText;

      // 获取操作者名称
      final actionByParticipant = conversation.getParticipant(actionBy);
      final actionByName = actionByParticipant?.name ?? '系统';

      switch (action) {
        case 'added':
          eventType = message_proto.SystemEventType.MEMBER_JOINED;
          if (member.userId == actionBy) {
            messageText = '${member.name} 加入了群聊';
          } else {
            messageText = '$actionByName 邀请 ${member.name} 加入了群聊';
          }
          break;

        case 'removed':
          eventType = message_proto.SystemEventType.MEMBER_REMOVED;
          if (member.userId == actionBy) {
            messageText = '${member.name} 离开了群聊';
          } else {
            messageText = '$actionByName 将 ${member.name} 移出了群聊';
          }
          break;

        case 'promoted':
          eventType = message_proto.SystemEventType.MEMBER_PROMOTED;
          final roleText = _getMemberRoleText(member.role);
          messageText = '$actionByName 将 ${member.name} 设为$roleText';
          break;

        case 'demoted':
          eventType = message_proto.SystemEventType.MEMBER_DEMOTED;
          messageText = '$actionByName 取消了 ${member.name} 的管理员权限';
          break;

        case 'blocked':
          // 屏蔽操作通常不显示系统消息，直接返回
          return;

        default:
          _logger.w('未知的成员变更操作，跳过创建系统消息', extra: {'action': action});
          return;
      }

      // 创建系统消息
      final systemMessage = Message()
        ..messageId = _uuid.v4() // 💢💢💢 使用UUID作为messageId
        ..conversationId = conversationId
        ..senderId = 'system'
        ..senderName = '系统'
        ..type = MessageType.membership
        ..text = messageText
        ..createdAt = TimezoneUtils.fromServerTimestamp(timestamp.toInt())
        ..status = MessageStatus.sent
        ..membershipEventType = eventType.name
        ..actorUserId = actionBy
        ..eventTimestamp = TimezoneUtils.fromServerTimestamp(timestamp.toInt())
        ..affectedUserIdsList = [member.userId]
        ..membershipActorMap = {
          'userId': actionBy,
          'userName': actionByName,
          'userAvatar': actionByParticipant?.avatar ?? '',
          'role': actionByParticipant?.role.index ?? 0,
        }
        ..membershipAffectedMembersList = [
          {
            'userId': member.userId,
            'userName': member.name,
            'userAvatar': member.avatar,
            'role': member.role.value,
            'joinedAt': member.hasJoinedAt() ? member.joinedAt.toInt() : null,
          }
        ];

      // 保存系统消息到数据库
      await _messages.put(systemMessage);

      // 链接消息到会话
      systemMessage.conversation.value = conversation;
      await systemMessage.conversation.save();

      _logger.d('创建成员变更系统消息成功', extra: {
        'conversationId': conversationId,
        'action': action,
        'memberName': member.name,
        'messageText': messageText,
      });

      // 通知UI有新消息
      final messageController = _messageUpdateControllers[conversationId];
      if (messageController != null && !messageController.isClosed) {
        messageController.add(MessageAddedEvent(
          conversationId: conversationId,
          newMessages: [systemMessage],
          addedEventType: AddedEventType.newMessage,
          timestamp: TimezoneUtils.nowUtc(),
        ));
      }
    } catch (error, stackTrace) {
      _logger.e('创建成员变更系统消息失败', error: error, stackTrace: stackTrace);
    }
  }

  /// 获取成员角色的中文文本
  String _getMemberRoleText(conversation_proto.MemberRole role) {
    switch (role) {
      case conversation_proto.MemberRole.OWNER:
        return '群主';
      case conversation_proto.MemberRole.ADMIN:
        return '管理员';
      case conversation_proto.MemberRole.MEMBER:
        return '成员';
      default:
        return '成员';
    }
  }

  /// 💢💢💢 本地标记消息为已撤回状态
  Future<void> _markMessageAsRevokedLocally(String messageId) async {
    try {
      // 💢💢💢 直接按messageId查找消息
      final message =
          await _messages.filter().messageIdEqualTo(messageId).findFirst();

      if (message == null) {
        _logger.w('要撤回的消息未找到', extra: {
          'messageId': messageId,
        });
        return;
      }

      // 更新消息状态为已撤回
      await _isar.writeTxn(() async {
        message.status = MessageStatus.revoked;
        message.updatedAt = DateTime.now();
        await _messages.put(message);
      });

      // 通知UI更新
      _notifyMessagesEvent(MessageUpdatedEvent(
        conversationId: message.conversationId,
        messageId: message.messageId,
        updatedFields: {
          'status': MessageStatus.revoked.name,
          'updatedAt': DateTime.now().toIso8601String(),
        },
      ));

      _logger.i('消息已标记为撤回', extra: {
        'messageId': messageId,
        'conversationId': message.conversationId,
      });
    } catch (error) {
      _logger.e('标记消息撤回失败', error: error, stackTrace: StackTrace.current);
    }
  }
}
