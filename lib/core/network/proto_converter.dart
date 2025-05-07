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

  /// 将 UserProto 转换为 Base64 字符串
  String userToBase64(UserProto user) {
    final bytes = user.writeToBuffer();
    return base64Encode(bytes);
  }

  /// 将 Base64 字符串转换为 UserProto
  UserProto base64ToUser(String base64Str) {
    final bytes = base64Decode(base64Str);
    return UserProto.fromBuffer(bytes);
  }

  /// 将 UserProto 转换为 Map
  Map<String, dynamic> userToMap(UserProto user) {
    return jsonDecode(jsonEncode(user.toProto3Json())) as Map<String, dynamic>;
  }

  /// 将 Map 转换为 UserProto
  UserProto mapToUser(Map<String, dynamic> map) {
    return UserProto.create()..mergeFromProto3Json(map);
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

  /// AuthRequest Proto对象转Map
  Map<String, dynamic> authRequestToMap(AuthRequest request) {
    final jsonString = request.writeToJson();
    final map = json.decode(jsonString) as Map<String, dynamic>;
    return map;
  }

  /// Map转AuthRequest Proto对象
  AuthRequest mapToAuthRequest(Map<String, dynamic> map) {
    final jsonString = json.encode(map);
    final request = AuthRequest.fromJson(jsonString);
    return request;
  }

  /// AuthResponse Proto对象转Map
  Map<String, dynamic> authResponseToMap(AuthResponse response) {
    final jsonString = response.writeToJson();
    final map = json.decode(jsonString) as Map<String, dynamic>;
    return map;
  }

  /// Map转AuthResponse Proto对象
  AuthResponse mapToAuthResponse(Map<String, dynamic> map) {
    final jsonString = json.encode(map);
    final response = AuthResponse.fromJson(jsonString);
    return response;
  }

  /// AuthRequest Proto对象转Base64字符串
  String authRequestToBase64(AuthRequest request) {
    final bytes = request.writeToBuffer();
    return base64Encode(bytes);
  }

  /// Base64字符串转AuthRequest Proto对象
  AuthRequest base64ToAuthRequest(String base64String) {
    final bytes = base64Decode(base64String);
    return AuthRequest.fromBuffer(bytes);
  }

  /// AuthResponse Proto对象转Base64字符串
  String authResponseToBase64(AuthResponse response) {
    final bytes = response.writeToBuffer();
    return base64Encode(bytes);
  }

  /// Base64字符串转AuthResponse Proto对象
  AuthResponse base64ToAuthResponse(String base64String) {
    final bytes = base64Decode(base64String);
    return AuthResponse.fromBuffer(bytes);
  }
}
