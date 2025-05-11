import 'package:protobuf/protobuf.dart';
import '../proto/generated/message.pb.dart';
import '../proto/generated/conversation.pb.dart';
import '../proto/generated/user.pb.dart';

/// 事件到Protobuf消息类型的映射
/// 定义了服务器和客户端之间通信的事件和对应的Protobuf消息类型
class ProtoEvents {
  /// 消息事件映射表
  static final Map<String, GeneratedMessage Function()> _eventTypeMap = {
    // 消息相关事件
    'new_message': () => MessageProto(),
    'message_delivered': () => MessageProto(),
    'message_read': () => MessageProto(),

    // 会话相关事件
    'conversation_update': () => ConversationProto(),
    'conversation_created': () => ConversationProto(),
    'conversation_deleted': () => ConversationProto(),
    'sync_conversations': () => ConversationCollection(),

    // 用户相关事件
    'user_online': () => UserStatusUpdate(),
    'user_offline': () => UserStatusUpdate(),
    'user_typing': () => UserTypingUpdate(),
    'user_updated': () => UserProto(),

    // 系统相关事件
    'system_message': () => SystemMessage(),
  };

  /// 获取事件的Protobuf消息创建函数
  /// [eventName] - 事件名称
  /// 返回创建对应Protobuf消息的函数，如果事件不存在则返回null
  static GeneratedMessage Function()? getEventCreator(String eventName) {
    return _eventTypeMap[eventName];
  }

  /// 检查事件是否已注册
  /// [eventName] - 事件名称
  static bool isEventRegistered(String eventName) {
    return _eventTypeMap.containsKey(eventName);
  }

  /// 注册自定义事件和对应的Protobuf消息类型
  /// [eventName] - 事件名称
  /// [creator] - 创建对应Protobuf消息的函数
  static void registerEvent(String eventName, GeneratedMessage Function() creator) {
    _eventTypeMap[eventName] = creator;
  }

  /// 获取所有已注册的事件名称
  static Set<String> get allEvents => _eventTypeMap.keys.toSet();
}
