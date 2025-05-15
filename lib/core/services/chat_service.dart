import 'dart:async';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/services/communication_service.dart';
import 'package:cc/core/proto/generated/message.pb.dart';
import 'package:cc/core/proto/generated/conversation.pb.dart';
import 'package:fixnum/fixnum.dart' as $fixnum;

/// 聊天服务
/// 提供聊天相关功能，使用类型安全的Protobuf通信
class ChatService {
  final LogService _logger = LogService.instance;
  final CommunicationService _communicationService = CommunicationService();

  // 消息流控制器
  final StreamController<MessageProto> _messageController = StreamController<MessageProto>.broadcast();
  Stream<MessageProto> get messageStream => _messageController.stream;

  // 会话更新流控制器
  final StreamController<ConversationProto> _conversationController = StreamController<ConversationProto>.broadcast();
  Stream<ConversationProto> get conversationStream => _conversationController.stream;

  // 单例模式
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  /// 初始化服务
  Future<void> init() async {
    _logger.i('初始化聊天服务');

    // 监听新消息
    _communicationService.onProto<MessageProto>('message:new').listen((message) {
      _logger.i('收到新消息', extra: {'messageId': message.messageId, 'senderId': message.senderId});
      _messageController.add(message);
    });

    // 监听消息已送达
    _communicationService.onProto<MessageProto>('message:delivered').listen((message) {
      _logger.i('消息已送达', extra: {'messageId': message.messageId});
      // 更新消息状态为已送达
    });

    // 监听消息已读
    _communicationService.onProto<MessageProto>('message:read').listen((message) {
      _logger.i('消息已读', extra: {'messageId': message.messageId});
      // 更新消息状态为已读
    });

    // 监听会话更新
    _communicationService.onProto<ConversationProto>('conversation:update').listen((conversation) {
      _logger.i('会话更新', extra: {'conversationId': conversation.conversationId});
      _conversationController.add(conversation);
    });

    _logger.i('聊天服务初始化完成');
  }

  /// 发送消息
  /// [conversationId] - 会话ID
  /// [text] - 消息文本
  /// [senderId] - 发送者ID
  Future<void> sendMessage({required String conversationId, required String text, required String senderId}) async {
    _logger.i('发送消息', extra: {'conversationId': conversationId, 'senderId': senderId});

    // 创建一个新的MessageProto对象
    final message = MessageProto(
      messageId: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      conversationId: conversationId,
      senderId: senderId,
      text: text,
      createdAt: $fixnum.Int64(DateTime.now().millisecondsSinceEpoch),
      type: MessageType.text,
      isRead: false,
      status: 'sending',
    );

    try {
      // 使用类型安全的方式发送消息
      await _communicationService.emitProto('message:new', message);
      _logger.i('消息发送成功', extra: {'messageId': message.messageId});
    } catch (error) {
      _logger.e('消息发送失败', error: error, stackTrace: StackTrace.current);
    }
  }

  /// 标记消息为已读
  /// [messageId] - 消息ID
  /// [conversationId] - 会话ID
  Future<void> markMessageAsRead(String messageId, String conversationId) async {
    _logger.i('标记消息为已读', extra: {'messageId': messageId, 'conversationId': conversationId});

    // 创建一个简化的MessageProto对象，只包含必要的字段
    final message = MessageProto(
      messageId: messageId,
      conversationId: conversationId,
      isRead: true,
      status: 'read',
    );

    try {
      // 发送消息已读事件
      await _communicationService.emitProto('message:read', message);
      _logger.i('消息已读状态已发送');
    } catch (error) {
      _logger.e('标记消息已读失败', error: error, stackTrace: StackTrace.current);
    }
  }

  /// 获取会话消息
  /// [conversationId] - 会话ID
  /// [limit] - 消息数量限制
  /// [beforeTimestamp] - 获取此时间戳之前的消息
  Future<void> fetchMessages({
    required String conversationId,
    int limit = 20,
    int? beforeTimestamp,
  }) async {
    _logger.i('获取会话消息', extra: {
      'conversationId': conversationId,
      'limit': limit,
      'beforeTimestamp': beforeTimestamp,
    });

    // 使用MessageCollection来批量请求消息
    // 注意: 这个请求结构应该在Proto文件中定义
    final request = MessageProto(
      conversationId: conversationId,
      // 将额外参数作为自定义字段传递
      text: 'fetch', // 用作临时标记
    );

    if (beforeTimestamp != null) {
      request.createdAt = $fixnum.Int64(beforeTimestamp);
    }

    try {
      // 发送获取消息请求
      await _communicationService.emitProto('messages:fetch', request);
      _logger.i('获取消息请求已发送');
      // 响应将通过messageStream流获取
    } catch (error) {
      _logger.e('获取消息失败', error: error, stackTrace: StackTrace.current);
    }
  }

  /// 释放资源
  void dispose() {
    _logger.i('释放聊天服务资源');
    _messageController.close();
    _conversationController.close();
  }
}
