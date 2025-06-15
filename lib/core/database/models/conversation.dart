import 'package:isar/isar.dart';
import 'message.dart';

part 'conversation.g.dart';

/// 会话类型枚举
enum ConversationType { private, group, channel }

/// 成员角色枚举，匹配proto中的MemberRole
enum MemberRole { member, admin, owner }

/// 💢💢💢 新增：参与者模型，匹配Proto中的ParticipantProto
@embedded
class Participant {
  String userId = ''; // 对应 user_id
  String name = ''; // 用户名称
  String avatar = ''; // 用户头像
  int unreadCount = 0; // 对应 unread_count
  bool muted = false; // 对应 muted
  bool pinned = false; // 对应 pinned
  DateTime? joinedAt; // 对应 joined_at
  int deliveredMessageIndex = 0; // 💢💢💢 新增：送达消息索引 - 最后送达的消息索引
  int readMessageIndex = 0; // 💢💢💢 新增：已读消息索引 - 最后已读的消息索引

  @Enumerated(EnumType.name)
  MemberRole role = MemberRole.member; // 对应 role

  String? addedBy; // 对应 added_by
  bool online = false; // 是否在线
  bool isActive = true; // 是否活跃

  /// 💢💢💢 新增：获取最后已读消息索引（兼容性方法）
  int get lastReadMessageIndex => readMessageIndex;

  /// 💢💢💢 新增：设置最后已读消息索引（兼容性方法）
  set lastReadMessageIndex(int index) => readMessageIndex = index;

  /// 💢💢💢 新增：获取最后送达消息索引
  int get lastDeliveredMessageIndex => deliveredMessageIndex;

  /// 💢💢💢 新增：设置最后送达消息索引
  set lastDeliveredMessageIndex(int index) => deliveredMessageIndex = index;

  Participant();

  /// 创建参与者的便捷构造函数
  Participant.create({
    required this.userId,
    required this.name,
    this.avatar = '',
    this.unreadCount = 0,
    this.muted = false,
    this.pinned = false,
    this.joinedAt,
    this.deliveredMessageIndex = 0,
    this.readMessageIndex = 0,
    this.role = MemberRole.member,
    this.addedBy,
    this.online = false,
    this.isActive = true,
  });

  /// 复制参与者信息
  Participant copyWith({
    String? userId,
    String? name,
    String? avatar,
    int? unreadCount,
    bool? muted,
    bool? pinned,
    DateTime? joinedAt,
    int? deliveredMessageIndex,
    int? readMessageIndex,
    MemberRole? role,
    String? addedBy,
    bool? online,
    bool? isActive,
  }) {
    return Participant.create(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      unreadCount: unreadCount ?? this.unreadCount,
      muted: muted ?? this.muted,
      pinned: pinned ?? this.pinned,
      joinedAt: joinedAt ?? this.joinedAt,
      deliveredMessageIndex:
          deliveredMessageIndex ?? this.deliveredMessageIndex,
      readMessageIndex: readMessageIndex ?? this.readMessageIndex,
      role: role ?? this.role,
      addedBy: addedBy ?? this.addedBy,
      online: online ?? this.online,
      isActive: isActive ?? this.isActive,
    );
  }
}

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

  // 💢💢💢 会话边界信息，用于精确判断分页状态
  /// 会话中第一条消息的索引 (对应 first_message_index)
  int firstMessageIndex = 0;

  /// 会话中最后一条消息的索引 (对应 last_message_index)
  int lastMessageIndex = 0;

  DateTime? lastMessageTime;
  String? lastMessagePreview;
  String? lastMessageId;

  // 最后一条消息的发送者名称，用于群聊或频道显示 (对应 last_message_name)
  String? lastMessageName;

  // 私聊会话对应的联系人ID(仅私聊有效) (对应 contact_user_id)
  String? contactUserId;

  // 会话创建者ID (对应 created_by)
  String? createdBy;

  // 💢💢💢 新增：参与者详细信息，包含所有参与者的完整信息 (对应 participants)
  List<Participant> participants = [];

  // 💢💢💢 新增：当前用户的最后阅读时间 - 记录用户最后一次离开会话的时间
  DateTime? lastReadTime;

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

  /// 💢💢💢 新增：动态获取当前用户的静音状态
  /// [currentUserId] - 当前用户ID
  bool isMuted(String? currentUserId) {
    if (currentUserId == null) return false;
    final participant = getParticipant(currentUserId);
    return participant?.muted ?? false;
  }

  /// 💢💢💢 新增：动态获取当前用户的置顶状态
  /// [currentUserId] - 当前用户ID
  bool isPinned(String? currentUserId) {
    if (currentUserId == null) return false;
    final participant = getParticipant(currentUserId);
    return participant?.pinned ?? false;
  }

  /// 💢💢💢 新增：动态获取当前用户的未读消息数量
  /// [currentUserId] - 当前用户ID
  /// 通过计算 lastMessageIndex - readMessageIndex 来得到未读消息数量
  int unreadCount(String? currentUserId) {
    if (currentUserId == null) return 0;

    final participant = getParticipant(currentUserId);
    if (participant == null) return 0;

    // 如果没有消息或索引信息不完整，返回0
    if (lastMessageIndex <= 0 || participant.readMessageIndex < 0) {
      return 0;
    }

    // 计算未读消息数量：最后消息索引 - 已读消息索引
    final unread = lastMessageIndex - participant.readMessageIndex;

    // 确保未读数量不为负数
    return unread > 0 ? unread : 0;
  }

  /// 💢💢💢 新增：动态获取当前用户的最后已读消息索引
  /// [currentUserId] - 当前用户ID
  int? lastReadAtIndex(String? currentUserId) {
    if (currentUserId == null) return null;
    final participant = getParticipant(currentUserId);
    return participant?.readMessageIndex;
  }

  /// 💢💢💢 新增：判断会话是否有未读消息（需要当前用户ID）
  /// [currentUserId] - 当前用户ID
  bool hasUnread(String? currentUserId) {
    if (currentUserId == null) return false;

    final participant = getParticipant(currentUserId);
    if (participant == null) return false;

    // 基于消息索引判断：如果最后消息索引大于最后阅读索引，则有未读消息
    if (lastMessageIndex > 0 && participant.readMessageIndex >= 0) {
      return lastMessageIndex > participant.readMessageIndex;
    }

    // 如果索引信息不完整，返回false
    return false;
  }

  /// 💢💢💢 新增：基于时间判断是否有新消息
  /// [currentUserId] - 当前用户ID
  /// 通过比较 lastMessageTime 和用户的 lastReadTime 来判断是否有新消息
  bool hasNewMessagesSinceLastRead(String? currentUserId) {
    if (currentUserId == null) return false;

    // 如果没有最后消息时间，返回false
    if (lastMessageTime == null) return false;

    // 如果用户从未阅读过会话，且有消息，则认为有新消息
    if (lastReadTime == null) {
      return true;
    }

    // 比较最后消息时间和最后阅读时间
    return lastMessageTime!.isAfter(lastReadTime!);
  }

  /// 💢💢💢 新增：更新用户的最后阅读时间
  /// [currentUserId] - 当前用户ID
  /// [readTime] - 阅读时间，默认为当前时间
  void updateLastReadTime(String currentUserId, {DateTime? readTime}) {
    lastReadTime = readTime ?? DateTime.now();
  }

  /// 💢💢💢 新增：获取用户的最后阅读时间
  /// [currentUserId] - 当前用户ID
  DateTime? getLastReadTime(String? currentUserId) {
    if (currentUserId == null) return null;
    return lastReadTime;
  }

  /// 💢💢💢 新增：更新当前用户的个人设置
  /// [currentUserId] - 当前用户ID
  /// [muted] - 静音状态
  /// [pinned] - 置顶状态
  /// [readMessageIndex] - 已读消息索引
  void updateCurrentUserSettings({
    required String currentUserId,
    bool? muted,
    bool? pinned,
    int? readMessageIndex,
  }) {
    final participant = getParticipant(currentUserId);
    if (participant != null) {
      final updatedParticipant = participant.copyWith(
        muted: muted,
        pinned: pinned,
        readMessageIndex: readMessageIndex,
      );
      updateParticipant(updatedParticipant);
    }
  }

  /// 💢💢💢 新增：根据用户ID获取参与者信息
  Participant? getParticipant(String userId) {
    try {
      return participants.firstWhere((p) => p.userId == userId);
    } catch (e) {
      return null;
    }
  }

  /// 💢💢💢 新增：获取当前用户的参与者信息
  Participant? getCurrentUserParticipant(String currentUserId) {
    return getParticipant(currentUserId);
  }

  /// 💢💢💢 新增：更新参与者信息
  void updateParticipant(Participant updatedParticipant) {
    final index =
        participants.indexWhere((p) => p.userId == updatedParticipant.userId);
    if (index != -1) {
      participants[index] = updatedParticipant;
    } else {
      participants.add(updatedParticipant);
    }
  }

  /// 💢💢💢 新增：移除参与者
  void removeParticipant(String userId) {
    participants.removeWhere((p) => p.userId == userId);
  }

  /// 💢💢💢 新增：添加参与者
  void addParticipant(Participant participant) {
    // 如果已存在，则更新；否则添加
    updateParticipant(participant);
  }

  /// 💢💢💢 新增：获取在线参与者数量
  int get onlineParticipantCount {
    return participants.where((p) => p.online).length;
  }

  /// 💢💢💢 新增：获取活跃参与者数量
  int get activeParticipantCount {
    return participants.where((p) => p.isActive).length;
  }

  /// 💢💢💢 新增：判断是否还有更多历史消息
  /// 基于会话边界信息进行精确判断
  bool hasMoreMessagesBefore(int? currentOldestIndex) {
    if (currentOldestIndex == null || firstMessageIndex <= 0) {
      return false; // 没有当前索引或没有消息边界信息
    }
    return currentOldestIndex > firstMessageIndex;
  }

  /// 💢💢💢 新增：判断是否还有更多新消息
  /// 基于会话边界信息进行精确判断
  bool hasMoreMessagesAfter(int? currentNewestIndex) {
    if (currentNewestIndex == null || lastMessageIndex <= 0) {
      return false; // 没有当前索引或没有消息边界信息
    }
    return currentNewestIndex < lastMessageIndex;
  }

  /// 💢💢💢 新增：获取消息加载进度
  /// 返回值范围 0.0 - 1.0
  double getMessageLoadProgress(int localMessageCount) {
    final totalCount = getTotalMessageCount();
    if (totalCount <= 0) return 1.0;
    return (localMessageCount / totalCount).clamp(0.0, 1.0);
  }

  /// 💢💢💢 新增：获取会话消息总数
  int getTotalMessageCount() {
    if (firstMessageIndex <= 0 || lastMessageIndex <= 0) {
      return 0;
    }
    return lastMessageIndex - firstMessageIndex + 1;
  }

  /// 创建一个新的 Conversation 对象，复制当前对象的所有属性，并允许覆盖指定的属性
  Conversation copyWith({
    String? conversationId,
    ConversationType? type,
    String? name,
    String? avatar,
    DateTime? createdAt,
    int? firstMessageIndex,
    int? lastMessageIndex,
    DateTime? lastMessageTime,
    String? lastMessagePreview,
    String? lastMessageId,
    String? lastMessageName,
    String? contactUserId,
    String? createdBy,
    List<Participant>? participants,
    DateTime? lastReadTime,
  }) {
    final conversation = Conversation()
      ..id = id
      ..conversationId = conversationId ?? this.conversationId
      ..type = type ?? this.type
      ..name = name ?? this.name
      ..avatar = avatar ?? this.avatar
      ..createdAt = createdAt ?? this.createdAt
      ..firstMessageIndex = firstMessageIndex ?? this.firstMessageIndex
      ..lastMessageIndex = lastMessageIndex ?? this.lastMessageIndex
      ..lastMessageTime = lastMessageTime ?? this.lastMessageTime
      ..lastMessagePreview = lastMessagePreview ?? this.lastMessagePreview
      ..lastMessageId = lastMessageId ?? this.lastMessageId
      ..lastMessageName = lastMessageName ?? this.lastMessageName
      ..contactUserId = contactUserId ?? this.contactUserId
      ..createdBy = createdBy ?? this.createdBy
      ..lastReadTime = lastReadTime ?? this.lastReadTime
      ..participants = participants != null
          ? List<Participant>.from(participants)
          : List<Participant>.from(this.participants);

    return conversation;
  }
}
