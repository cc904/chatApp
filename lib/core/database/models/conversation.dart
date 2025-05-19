import 'package:isar/isar.dart';
import 'user.dart';
import 'message.dart';
import 'package:cc/core/proto/generated/conversation.pb.dart' as proto;
import 'package:fixnum/fixnum.dart';

part 'conversation.g.dart';

/// 会话类型枚举
enum ConversationType { private, group }

@collection
class Conversation {
  // Isar ID
  Id id = Isar.autoIncrement;

  // 兼容性字段,与id值保持一致
  String conversationId = '';

  @Enumerated(EnumType.name)
  late ConversationType type;

  String? name;
  String? avatar;
  DateTime createdAt = DateTime.now();
  DateTime? lastMessageTime;
  String? lastMessagePreview;
  String? lastMessageId;

  // 未读消息数量
  int unreadCount = 0;

  // 安全的未读消息数量（非负值）
  int safeUnreadCount = 0;

  // 私聊会话对应的联系人ID(仅私聊有效)
  String? contactUserId;

  // 会话参与者
  final participants = IsarLinks<User>();

  // 反向关系 - 会话中的所有消息
  @Backlink(to: 'conversation')
  final messages = IsarLinks<Message>();

  // 为了满足Isar的要求，提供默认无参构造函数
  Conversation();
  
  // 为UI生成会话头像文本(取名字首字母或群名首字母)
  String get avatarText {
    if (name?.isNotEmpty == true) {
      return name!.substring(0, 1).toUpperCase();
    }
    return type == ConversationType.private ? 'U' : 'G';
  }
  
  /// 从Protocol Buffer对象创建数据库对象
  /// 
  /// 直接从ConversationProto对象创建Conversation实例
  /// 简化了在仓库中的数据转换逻辑
  /// 
  /// [proto] - 原始的Protocol Buffer对象
  /// 返回：转换后的数据库对象
  factory Conversation.fromProto(proto.ConversationProto proto) {
    // 确定会话类型
    final protoType = proto.type;
    final isPrivate = protoType.value == 0; // 0 对应 private, 1 对应 group
    
    return Conversation()
      ..conversationId = proto.conversationId
      ..type = isPrivate ? ConversationType.private : ConversationType.group
      ..name = proto.hasName() ? proto.name : null
      ..avatar = proto.hasAvatar() ? proto.avatar : null
      ..lastMessagePreview = proto.hasLastMessagePreview() ? proto.lastMessagePreview : null
      ..lastMessageTime = proto.hasLastMessageTime() 
          ? DateTime.fromMillisecondsSinceEpoch(proto.lastMessageTime.toInt()) 
          : null
      ..createdAt = proto.hasCreatedAt()
          ? DateTime.fromMillisecondsSinceEpoch(proto.createdAt.toInt())
          : DateTime.now()
      ..unreadCount = proto.hasUnreadCount() ? proto.unreadCount : 0
      ..contactUserId = proto.hasContactUserId() ? proto.contactUserId : null
      ..lastMessageId = proto.hasLastMessageId() ? proto.lastMessageId : null;
  }
  
  /// 将数据库对象转换为Protocol Buffer对象
  /// 
  /// 用于将Conversation对象转换为可序列化的Proto对象
  /// 便于网络传输和存储
  /// 
  /// 返回：转换后的Protocol Buffer对象
  proto.ConversationProto toProto() {
    return proto.ConversationProto(
      conversationId: conversationId,
      type: type == ConversationType.private 
          ? proto.ConversationType.private 
          : proto.ConversationType.group,
      name: name,
      avatar: avatar,
      lastMessagePreview: lastMessagePreview,
      lastMessageTime: lastMessageTime != null 
          ? Int64(lastMessageTime!.millisecondsSinceEpoch) 
          : null,
      createdAt: Int64(createdAt.millisecondsSinceEpoch),
      unreadCount: unreadCount,
      contactUserId: contactUserId,
      lastMessageId: lastMessageId,
    );
  }
}
