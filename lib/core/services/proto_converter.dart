import 'dart:typed_data';
import 'package:fixnum/fixnum.dart' as $fixnum;

import '../proto/generated/message.pb.dart';
import '../proto/generated/user.pb.dart';
import '../proto/generated/conversation.pb.dart';
import '../proto/generated/auth.pb.dart';
import 'log_service.dart';

/// Protobuf 转换工具类
/// 负责通信中的 Protobuf 数据序列化和反序列化
class ProtoConverter {
  final LogService _logger = LogService('proto_converter.dart');

  // 单例模式
  static final ProtoConverter _instance = ProtoConverter._internal();
  factory ProtoConverter() => _instance;
  ProtoConverter._internal();

  // ==== Message 转换 ====

  /// 将 MessageProto 转换为二进制数据
  Uint8List messageToBytes(MessageProto message) {
    return message.writeToBuffer();
  }

  /// 将二进制数据转换为 MessageProto
  MessageProto bytesToMessage(Uint8List bytes) {
    try {
      return MessageProto.fromBuffer(bytes);
    } catch (e) {
      _logger.e('二进制转MessageProto失败', error: e);
      throw FormatException('无效的消息格式: $e');
    }
  }

  // ==== Generic 转换 ====

  /// 将事件数据编码为二进制格式
  /// [data] - 事件数据（Map格式）
  /// [eventType] - 事件类型
  /// 返回 - 编码后的二进制数据
  Uint8List encodeData(Map<String, dynamic> data, String eventType) {
    _logger.d('编码事件数据', extra: {'eventType': eventType});

    // 根据事件类型选择适当的Protobuf消息
    switch (eventType) {
      case 'new_message':
      case 'message_delivered':
      case 'message_read':
        final message = MessageProto(
          messageId: data['id'] ?? '',
          senderId: data['senderId'] ?? '',
          conversationId: data['conversationId'] ?? '',
          text: data['content'] ?? '',
          createdAt: data['timestamp'] != null ? $fixnum.Int64(data['timestamp'] is int ? data['timestamp'] : int.parse(data['timestamp'].toString())) : $fixnum.Int64(0),
          type: MessageType.text, // 默认文本消息类型
        );
        return messageToBytes(message);

      case 'auth_request':
        // AuthRequest不是真正的protobuf类,无法序列化
        _logger.w('AuthRequest未实现为protobuf,无法序列化');
        throw UnimplementedError('AuthRequest暂不支持二进制序列化');

      case 'user_online':
      case 'user_offline':
        // UserStatus类未定义
        _logger.w('UserStatus未定义,无法序列化');
        throw UnimplementedError('UserStatus暂不支持二进制序列化');

      case 'conversation_update':
        final conversation = ConversationProto(
          conversationId: data['id'] ?? '',
          lastMessageId: data['lastMessageId'] ?? '',
          lastMessageTime: data['lastMessageSent'] != null
              ? $fixnum.Int64(data['lastMessageSent'] is int ? data['lastMessageSent'] : int.parse(data['lastMessageSent'].toString()))
              : $fixnum.Int64(0),
          unreadCount: data['unreadCount'] ?? 0,
        );
        if (data['participantIds'] != null) {
          conversation.participantIds.addAll((data['participantIds'] as List<dynamic>).map((e) => e.toString()).toList());
        }
        return conversation.writeToBuffer();

      default:
        _logger.w('未知事件类型,无法编码为Protobuf', extra: {'eventType': eventType});
        throw UnsupportedError('不支持的事件类型: $eventType');
    }
  }

  /// 将二进制数据解码为Map
  /// [data] - 二进制数据
  /// [eventType] - 事件类型
  /// 返回 - 解码后的`Map<String, dynamic>`
  Map<String, dynamic> decodeData(Uint8List data, String eventType) {
    try {
      _logger.d('解码事件数据', extra: {'eventType': eventType});

      // 根据事件类型选择适当的Protobuf解码方式
      switch (eventType) {
        case 'new_message':
        case 'message_delivered':
        case 'message_read':
          final message = bytesToMessage(data);
          return {
            'id': message.messageId,
            'senderId': message.senderId,
            'conversationId': message.conversationId,
            'content': message.text,
            'timestamp': message.createdAt.toInt(),
            'type': message.type.value,
          };

        case 'auth_response':
          // AuthResponse不是真正的protobuf类,无法反序列化
          _logger.w('AuthResponse未实现为protobuf,无法反序列化');
          throw UnimplementedError('AuthResponse暂不支持二进制反序列化');

        case 'user_online':
        case 'user_offline':
          // UserStatus类未定义
          _logger.w('UserStatus未定义,无法反序列化');
          throw UnimplementedError('UserStatus暂不支持二进制反序列化');

        case 'conversation_update':
          final conversation = ConversationProto.fromBuffer(data);
          return {
            'id': conversation.conversationId,
            'participantIds': conversation.participantIds,
            'lastMessageId': conversation.lastMessageId,
            'lastMessageSent': conversation.lastMessageTime.toInt(),
            'unreadCount': conversation.unreadCount,
          };

        default:
          _logger.w('未知事件类型,无法解码', extra: {'eventType': eventType});
          throw UnsupportedError('不支持的事件类型: $eventType');
      }
    } catch (e) {
      _logger.e('解码数据失败', error: e, extra: {'eventType': eventType});
      throw FormatException('解码失败: $e');
    }
  }

  // ==== User 转换 ====

  /// 将 UserSession 转换为二进制数据
  /// 注意：这个方法实际未实现,因为UserSession不是真正的protobuf类
  Uint8List userSessionToBytes(UserSession user) {
    _logger.w('UserSession未实现为protobuf,无法序列化');
    throw UnimplementedError('UserSession暂不支持二进制序列化');
  }

  /// 将二进制数据转换为 UserSession
  /// 注意：这个方法实际未实现,因为UserSession不是真正的protobuf类
  UserSession bytesToUserSession(Uint8List bytes) {
    _logger.w('UserSession未实现为protobuf,无法反序列化');
    throw UnimplementedError('UserSession暂不支持二进制反序列化');
  }

  // ==== Conversation 转换 ====

  /// 将 ConversationProto 转换为二进制数据
  Uint8List conversationToBytes(ConversationProto conversation) {
    return conversation.writeToBuffer();
  }

  /// 将二进制数据转换为 ConversationProto
  ConversationProto bytesToConversation(Uint8List bytes) {
    return ConversationProto.fromBuffer(bytes);
  }

  // ==== Auth 转换 ====

  /// 将 AuthRequest 转换为二进制数据
  /// 注意：这个方法实际未实现,因为AuthRequest不是真正的protobuf类
  Uint8List authRequestToBytes(AuthRequest request) {
    _logger.w('AuthRequest未实现为protobuf,无法序列化');
    throw UnimplementedError('AuthRequest暂不支持二进制序列化');
  }

  /// 将二进制数据转换为 AuthResponse
  /// 注意：这个方法实际未实现,因为AuthResponse不是真正的protobuf类
  AuthResponse bytesToAuthResponse(Uint8List bytes) {
    _logger.w('AuthResponse未实现为protobuf,无法反序列化');
    throw UnimplementedError('AuthResponse暂不支持二进制反序列化');
  }
}
