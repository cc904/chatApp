import 'package:isar/isar.dart';
import 'user.dart';
import 'message.dart';

part 'conversation.g.dart';

/// 会话类型枚举
enum ConversationType { private, group, channel }

/// 成员角色枚举，匹配proto中的MemberRole
enum MemberRole { member, admin, owner }

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
  int? lastMessageIndex;
  String? lastMessagePreview;
  String? lastMessageId;

  // 最后一条消息的发送者名称，用于群聊或频道显示
  String? lastMessageName;

  // 会话是否静音
  bool isMuted = false;

  // 会话是否置顶
  bool isPinned = false;

  // 最后阅读的消息索引，用于客户端计算会话未读状态
  int? lastReadAtIndex;

  // 未读消息数量
  int unreadCount = 0;

  // 私聊会话对应的联系人ID(仅私聊有效)
  String? contactUserId;

  // 会话创建者ID
  String? createdBy;

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
    return type == ConversationType.private
        ? 'U'
        : (type == ConversationType.group ? 'G' : 'C');
  }

  /// 判断会话是否有未读消息
  bool get hasUnread {
    // 基于消息索引判断：如果最后消息索引大于最后阅读索引，则有未读消息
    if (lastMessageIndex != null && lastReadAtIndex != null) {
      return lastMessageIndex! > lastReadAtIndex!;
    }

    // 如果没有最后阅读索引但有未读计数，也认为有未读消息
    if (lastReadAtIndex == null && unreadCount > 0) {
      return true;
    }

    // 基于未读消息计数判断
    return unreadCount > 0;
  }

  /// 创建一个新的 Conversation 对象，复制当前对象的所有属性，并允许覆盖指定的属性
  Conversation copyWith({
    String? conversationId,
    ConversationType? type,
    String? name,
    String? avatar,
    DateTime? createdAt,
    DateTime? lastMessageTime,
    int? lastMessageIndex,
    String? lastMessagePreview,
    String? lastMessageId,
    String? lastMessageName,
    bool? muted,
    bool? pinned,
    int? lastReadAtIndex,
    int? unreadCount,
    String? contactUserId,
    String? createdBy,
  }) {
    final conversation = Conversation()
      ..id = id
      ..conversationId = conversationId ?? this.conversationId
      ..type = type ?? this.type
      ..name = name ?? this.name
      ..avatar = avatar ?? this.avatar
      ..createdAt = createdAt ?? this.createdAt
      ..lastMessageTime = lastMessageTime ?? this.lastMessageTime
      ..lastMessageIndex = lastMessageIndex ?? this.lastMessageIndex
      ..lastMessagePreview = lastMessagePreview ?? this.lastMessagePreview
      ..lastMessageId = lastMessageId ?? this.lastMessageId
      ..lastMessageName = lastMessageName ?? this.lastMessageName
      ..isMuted = muted ?? isMuted
      ..isPinned = pinned ?? isPinned
      ..lastReadAtIndex = lastReadAtIndex ?? this.lastReadAtIndex
      ..unreadCount = unreadCount ?? this.unreadCount
      ..contactUserId = contactUserId ?? this.contactUserId
      ..createdBy = createdBy ?? this.createdBy;

    // 复制关联关系
    conversation.participants.addAll(participants);

    return conversation;
  }
}
