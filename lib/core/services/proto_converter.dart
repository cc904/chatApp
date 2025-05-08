import 'dart:convert';
import 'dart:typed_data';

import '../proto/generated/message.pb.dart';
import '../proto/generated/user.pb.dart';
import '../proto/generated/conversation.pb.dart';
import '../proto/generated/auth.pb.dart';

/// Protobuf 转换工具类
/// 负责在 Socket.IO 通信中进行 Protobuf 和 JSON 之间的转换
class ProtoConverter {
  // 单例模式
  static final ProtoConverter _instance = ProtoConverter._internal();

  factory ProtoConverter() {
    return _instance;
  }

  ProtoConverter._internal();

  // ==== Message 转换 ====

  /// 将 MessageProto 转换为 Base64 字符串
  String messageToBase64(MessageProto message) {
    final bytes = message.writeToBuffer();
    return base64Encode(bytes);
  }

  /// 将 Base64 字符串转换为 MessageProto
  MessageProto base64ToMessage(String base64Str) {
    final bytes = base64Decode(base64Str);
    return MessageProto.fromBuffer(bytes);
  }

  /// 将 MessageProto 转换为 Map
  Map<String, dynamic> messageToMap(MessageProto message) {
    return jsonDecode(jsonEncode(message.toProto3Json())) as Map<String, dynamic>;
  }

  /// 将 Map 转换为 MessageProto
  MessageProto mapToMessage(Map<String, dynamic> map) {
    return MessageProto.create()..mergeFromProto3Json(map);
  }

  /// 将二进制数据转换为 MessageProto
  MessageProto bytesToMessage(Uint8List bytes) {
    return MessageProto.fromBuffer(bytes);
  }

  /// 将 MessageProto 转换为二进制数据
  Uint8List messageToBytes(MessageProto message) {
    return message.writeToBuffer();
  }

  // ==== User 转换 ====

  /// 将 UserSession 转换为 Base64 字符串
  String userSessionToBase64(UserSession user) {
    final map = {
      'userId': user.userId,
      'token': user.token,
      'phoneNumber': user.phoneNumber,
      'expireTime': user.expireTime,
    };
    final jsonStr = json.encode(map);
    final bytes = utf8.encode(jsonStr);
    return base64Encode(bytes);
  }

  /// 将 Base64 字符串转换为 UserSession
  UserSession base64ToUserSession(String base64Str) {
    final bytes = base64Decode(base64Str);
    final jsonStr = utf8.decode(bytes);
    final map = json.decode(jsonStr) as Map<String, dynamic>;

    final user = UserSession();
    user.userId = map['userId'] as String? ?? '';
    user.token = map['token'] as String? ?? '';
    user.phoneNumber = map['phoneNumber'] as String? ?? '';
    user.expireTime = map['expireTime'] as int? ?? 0;
    return user;
  }

  /// 将 UserSession 转换为 Map
  Map<String, dynamic> userSessionToMap(UserSession user) {
    return {
      'userId': user.userId,
      'token': user.token,
      'phoneNumber': user.phoneNumber,
      'expireTime': user.expireTime,
    };
  }

  /// 将 Map 转换为 UserSession
  UserSession mapToUserSession(Map<String, dynamic> map) {
    final user = UserSession();
    user.userId = map['userId'] as String? ?? '';
    user.token = map['token'] as String? ?? '';
    user.phoneNumber = map['phoneNumber'] as String? ?? '';
    user.expireTime = map['expireTime'] as int? ?? 0;
    return user;
  }

  // ==== Conversation 转换 ====

  /// 将 ConversationProto 转换为 Base64 字符串
  String conversationToBase64(ConversationProto conversation) {
    final bytes = conversation.writeToBuffer();
    return base64Encode(bytes);
  }

  /// 将 Base64 字符串转换为 ConversationProto
  ConversationProto base64ToConversation(String base64Str) {
    final bytes = base64Decode(base64Str);
    return ConversationProto.fromBuffer(bytes);
  }

  /// 将 ConversationProto 转换为 Map
  Map<String, dynamic> conversationToMap(ConversationProto conversation) {
    return jsonDecode(jsonEncode(conversation.toProto3Json())) as Map<String, dynamic>;
  }

  /// 将 Map 转换为 ConversationProto
  ConversationProto mapToConversation(Map<String, dynamic> map) {
    return ConversationProto.create()..mergeFromProto3Json(map);
  }

  // ==== Auth 转换 ====

  /// AuthRequest 转 Map (简化版)
  Map<String, dynamic> authRequestToMap(AuthRequest request) {
    return {
      'operationType': request.operationType.index,
      'phoneNumber': request.phoneNumber,
      'password': request.password,
      'verificationCode': request.verificationCode,
      'nickname': request.nickname,
      'purpose': request.purpose,
      'isQuickLogin': request.isQuickLogin,
    };
  }

  /// Map 转 AuthResponse (简化版)
  AuthResponse mapToAuthResponse(Map<String, dynamic> map) {
    final response = AuthResponse();
    response.success = map['success'] as bool? ?? false;
    response.message = map['message'] as String? ?? '';
    response.userId = map['userId'] as String? ?? '';
    response.token = map['token'] as String? ?? '';
    response.timestamp = map['timestamp'] as int? ?? 0;
    return response;
  }

  /// Base64 转 AuthResponse (简化版)
  AuthResponse base64ToAuthResponse(String base64String) {
    try {
      final jsonStr = utf8.decode(base64Decode(base64String));
      final map = json.decode(jsonStr) as Map<String, dynamic>;
      return mapToAuthResponse(map);
    } catch (e) {
      // 出错时返回一个默认响应
      final response = AuthResponse();
      response.success = false;
      response.message = '数据解析错误: $e';
      return response;
    }
  }

  /// AuthRequest 转 Base64 (简化版)
  String base64FromAuthRequest(AuthRequest request) {
    final map = authRequestToMap(request);
    final jsonStr = json.encode(map);
    final bytes = utf8.encode(jsonStr);
    return base64Encode(bytes);
  }
}
