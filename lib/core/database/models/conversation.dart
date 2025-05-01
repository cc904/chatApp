import 'package:isar/isar.dart';
import 'user.dart';
import 'message.dart';

part 'conversation.g.dart';

/// 会话类型枚举
enum ConversationType { private, group }

@collection
class Conversation {
  // Isar ID
  Id id = Isar.autoIncrement;
  
  // 兼容性字段，与id值保持一致
  String conversationId = '';
  
  @Enumerated(EnumType.name)
  late ConversationType type;

  String? name;
  String? avatar;
  DateTime createdAt = DateTime.now();
  DateTime? lastMessageTime;
  String? lastMessagePreview;

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

  // 为UI生成会话头像文本(取名字首字母或群名首字母)
  String get avatarText {
    if (name?.isNotEmpty == true) {
      return name!.substring(0, 1).toUpperCase();
    }
    return type == ConversationType.private ? 'U' : 'G';
  }
}
