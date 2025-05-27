import 'package:isar/isar.dart';
import 'user.dart';
import 'message.dart';
import 'package:cc/core/proto/generated/conversation.pb.dart' as proto;
import 'package:fixnum/fixnum.dart';

part 'conversation.g.dart';

/// 会话类型枚举
enum ConversationType { private, group, channel }

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

  // 最后一条消息的发送者名称，用于群聊或频道显示
  String? lastMessageName;

  // 会话是否静音
  bool isMuted = false;

  // 会话是否置顶
  bool isPinned = false;

  // 最后阅读时间，用于客户端计算会话未读状态
  DateTime? lastReadAt;

  // 最后阅读的消息ID，用于记录阅读位置
  String? lastReadMessageId;

  // 未读消息数量
  int unreadCount = 0;

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
    return type == ConversationType.private
        ? 'U'
        : (type == ConversationType.group ? 'G' : 'C');
  }

  /// 判断会话是否有未读消息
  bool get hasUnread {
    // 基本版本：如果最后消息时间晚于最后阅读时间，则会话有未读消息
    if (lastMessageTime != null && lastReadAt != null) {
      return lastMessageTime!.isAfter(lastReadAt!);
    }

    // 如果没有最后阅读时间但有未读计数，也认为有未读消息
    if (lastReadAt == null && unreadCount > 0) {
      return true;
    }

    // 增强版本：结合未读消息计数判断
    return unreadCount > 0;
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
    ConversationType convType;

    switch (protoType.value) {
      case 0:
        convType = ConversationType.private;
        break;
      case 1:
        convType = ConversationType.group;
        break;
      case 2:
        convType = ConversationType.channel;
        break;
      default:
        convType = ConversationType.private;
    }

    final conversation = Conversation()
      ..conversationId = proto.conversationId
      ..type = convType
      ..name = proto.hasName() ? proto.name : null
      ..avatar = proto.hasAvatar() ? proto.avatar : null
      ..lastMessagePreview =
          proto.hasLastMessagePreview() ? proto.lastMessagePreview : null
      ..lastMessageTime = proto.hasLastMessageTime()
          ? DateTime.fromMillisecondsSinceEpoch(proto.lastMessageTime.toInt())
          : null
      ..createdAt = proto.hasCreatedAt()
          ? DateTime.fromMillisecondsSinceEpoch(proto.createdAt.toInt())
          : DateTime.now()
      ..unreadCount = proto.hasUnreadCount() ? proto.unreadCount : 0
      ..contactUserId = proto.hasContactUserId() ? proto.contactUserId : null
      ..lastMessageId = proto.hasLastReadMessageId() ? proto.lastReadMessageId : null
      ..isMuted = proto.hasMuted() ? proto.muted : false
      ..lastMessageName = proto.hasLastMessageName() ? proto.lastMessageName : null
      ..isPinned = proto.hasPinned() ? proto.pinned : false
      ..lastReadAt = proto.hasLastReadAt()
          ? DateTime.fromMillisecondsSinceEpoch(proto.lastReadAt.toInt())
          : null
      ..lastReadMessageId =
          proto.hasLastReadMessageId() ? proto.lastReadMessageId : null;
          
    // 注意：这里不直接设置 participants，因为它是 IsarLinks 类型
    // 需要在仓库层处理，通过查询用户并建立关联
    // 例如：
    // for (final participantProto in proto.participants) {
    //   // 查询用户并添加到 participants
    //   final user = await userRepository.getUserById(participantProto.userId);
    //   if (user != null) {
    //     conversation.participants.add(user);
    //   }
    // }
    // await conversation.participants.save();
    
    return conversation;
  }

  /// 将数据库对象转换为Protocol Buffer对象
  ///
  /// 用于将Conversation对象转换为可序列化的Proto对象
  /// 便于网络传输和存储
  ///
  /// 返回：转换后的Protocol Buffer对象
  proto.ConversationProto toProto() {
    proto.ConversationType protoType;

    switch (type) {
      case ConversationType.private:
        protoType = proto.ConversationType.private;
        break;
      case ConversationType.group:
        protoType = proto.ConversationType.group;
        break;
      case ConversationType.channel:
        protoType = proto.ConversationType.channel;
        break;
    }

    // 将参与者转换为ParticipantProto对象列表
    final participantProtos = <proto.ParticipantProto>[];
    for (final user in participants) {
      participantProtos.add(proto.ParticipantProto(
        userId: user.userId,
        name: user.name,
        avatar: user.avatar,
        // 注意：这里只添加了基本字段，如果需要更多字段，请根据实际情况添加
        // 例如：role、joinedAt、lastReadAt等
      ));
    }

    return proto.ConversationProto(
      conversationId: conversationId,
      type: protoType,
      name: name,
      avatar: avatar,
      lastMessagePreview: lastMessagePreview,
      lastMessageTime: lastMessageTime != null
          ? Int64(lastMessageTime!.millisecondsSinceEpoch)
          : null,
      createdAt: Int64(createdAt.millisecondsSinceEpoch),
      unreadCount: unreadCount,
      contactUserId: contactUserId,
      lastMessageName: lastMessageName,
      participants: participantProtos,
      muted: isMuted,
      pinned: isPinned,
      lastReadAt:
          lastReadAt != null ? Int64(lastReadAt!.millisecondsSinceEpoch) : null,
      lastReadMessageId: lastReadMessageId,
    );
  }
}
