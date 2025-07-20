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
  // 💢💢💢 已移除：int unreadCount = 0; // 现在使用动态计算 conversation.unreadCount(userId)
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
    // 💢💢💢 已移除：this.unreadCount = 0, // 现在使用动态计算
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
    // 💢💢💢 已移除：int? unreadCount, // 现在使用动态计算
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
      // 💢💢💢 已移除：unreadCount: unreadCount ?? this.unreadCount,
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

/// 会话数据模型
///
/// 这个模型表示一个聊天会话，包含了会话的基本信息、参与者信息以及消息统计
/// 支持一对一聊天和群组聊天两种类型
///
/// 💢💢💢 新功能：未读消息相关API
///
/// 使用示例：
/// ```dart
/// // 1. 获取第一条未读消息ID（推荐方法）
/// final messageId = await conversation.getUnreadMessage(currentUserId, chatsRepository);
/// if (messageId != null) {
///   print('第一条未读消息ID: $messageId');
///   // 可以用于定位到具体消息位置
///   await chatCubit.scrollToMessage(messageId);
/// }
///
/// // 2. 获取第一条未读消息的索引（同步方法）
/// final firstUnreadIndex = conversation.getUnreadMessageIndex(currentUserId);
/// if (firstUnreadIndex != null) {
///   print('第一条未读消息索引: $firstUnreadIndex');
/// }
///
/// // 3. 获取未读消息数量
/// final unreadCount = conversation.getUnreadMessageCount(currentUserId);
/// print('未读消息数量: $unreadCount');
///
/// // 4. 检查是否有未读消息
/// final hasUnread = conversation.hasUnread(currentUserId);
/// if (hasUnread) {
///   print('有未读消息');
/// }
///
/// // 5. 获取详细的未读消息信息
/// final info = conversation.getFirstUnreadMessageIdInfo(currentUserId);
/// if (info['canQuery']) {
///   print('可以查询第一条未读消息');
///   print('索引范围: ${info['searchRange']['startIndex']} - ${info['searchRange']['endIndex']}');
///   print('未读数量: ${info['unreadCount']}');
/// }
///
/// // 6. 直接通过Repository调用
/// final messageId2 = await chatsRepository.getFirstUnreadMessageId(
///   conversation.conversationId,
///   currentUserId
/// );
///
/// // 7. 传统方法（别名）
/// final unreadCount2 = conversation.unreadCount(currentUserId);
/// final newMessageCount = conversation.hasNewMessageCount(currentUserId);
/// ```
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

  // 群组或频道的描述信息
  String? description;

  DateTime createdAt = DateTime.now();

  // 💢💢💢 会话边界信息，用于精确判断分页状态
  /// 会话中第一条消息的索引 (对应 first_message_index)
  int firstMessageIndex = 0;

  /// 会话中最后一条消息的索引 (对应 last_message_index)
  int lastMessageIndex = 0;

  DateTime? lastMessageTime;
  String? lastMessagePreview;

  // 最后一条消息的发送者名称，用于群聊或频道显示 (对应 last_message_name)
  String? lastMessageName;

  // 私聊会话对应的联系人ID(仅私聊有效) (对应 contact_user_id)
  String? contactUserId;

  // 会话创建者ID (对应 created_by)
  String? createdBy;

  // 💢💢💢 新增：参与者详细信息，包含所有参与者的完整信息 (对应 participants)
  // Isar数据库要求使用List，但提供Map接口方法以匹配proto定义
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

  /// 💢💢💢 新增：获取当前用户的未读消息数量（别名方法）
  /// [currentUserId] - 当前用户ID
  /// 💢💢💢 重构：获取第一条未读消息ID
  /// 此方法返回第一条未读消息的ID，需要配合Repository使用
  /// [currentUserId] - 当前用户ID
  /// [repository] - 用于查询消息的Repository（可选）
  ///
  /// 如果提供了repository，返回实际的消息ID
  /// 如果没有提供repository，返回null（因为无法查询数据库）
  /// 如果没有未读消息，返回null
  Future<String?> getUnreadMessage(String? currentUserId,
      [dynamic repository]) async {
    if (currentUserId == null) return null;

    // 检查是否有未读消息
    if (!hasUnread(currentUserId)) return null;

    // 如果提供了repository，查询实际的消息ID
    if (repository != null) {
      return await repository.getFirstUnreadMessageId(
          conversationId, currentUserId);
    }

    // 如果没有提供repository，无法查询数据库，返回null
    return null;
  }

  /// 💢💢💢 新增：获取未读消息数量（明确的方法名）
  /// [currentUserId] - 当前用户ID
  /// 返回未读消息的数量
  int getUnreadMessageCount(String? currentUserId) {
    return unreadCount(currentUserId);
  }

  /// 💢💢💢 新增：同步获取第一条未读消息索引
  /// [currentUserId] - 当前用户ID
  /// 返回第一条未读消息的索引，如果没有未读消息则返回null
  int? getUnreadMessageIndex(String? currentUserId) {
    return getFirstUnreadMessageIndex(currentUserId);
  }

  /// 💢💢💢 新增：同步方法 - 检查是否有未读消息（返回布尔值）
  /// [currentUserId] - 当前用户ID
  /// 这个方法名更准确，避免与异步的getUnreadMessage混淆
  bool hasUnreadMessage(String? currentUserId) {
    return hasUnread(currentUserId);
  }

  /// 💢💢💢 新增：获取详细的未读消息信息
  /// [currentUserId] - 当前用户ID
  /// 返回包含未读数量和相关信息的Map
  Map<String, dynamic> getUnreadMessageInfo(String? currentUserId) {
    if (currentUserId == null) {
      return {
        'unreadCount': 0,
        'hasUnread': false,
        'lastReadIndex': -1,
        'lastMessageIndex': lastMessageIndex,
        'participantFound': false,
      };
    }

    final participant = getParticipant(currentUserId);
    if (participant == null) {
      return {
        'unreadCount': 0,
        'hasUnread': false,
        'lastReadIndex': -1,
        'lastMessageIndex': lastMessageIndex,
        'participantFound': false,
      };
    }

    final unreadCount = this.unreadCount(currentUserId);

    return {
      'unreadCount': unreadCount,
      'hasUnread': unreadCount > 0,
      'lastReadIndex': participant.readMessageIndex,
      'lastMessageIndex': lastMessageIndex,
      'participantFound': true,
      'participant': participant,
    };
  }

  /// 💢💢💢 新增：获取第一条未读消息的索引
  /// [currentUserId] - 当前用户ID
  /// 返回第一条未读消息的索引，如果没有未读消息则返回null
  int? getFirstUnreadMessageIndex(String? currentUserId) {
    if (currentUserId == null) return null;

    final participant = getParticipant(currentUserId);
    if (participant == null) return null;

    // 如果没有未读消息，返回null
    if (!hasUnread(currentUserId)) return null;

    // 第一条未读消息的索引 = 最后已读消息索引 + 1
    final firstUnreadIndex = participant.readMessageIndex + 1;

    // 确保索引在有效范围内
    if (firstUnreadIndex > lastMessageIndex) return null;

    return firstUnreadIndex;
  }

  /// 💢💢💢 新增：获取最新未读消息的索引（即会话中的最后一条消息）
  /// [currentUserId] - 当前用户ID
  /// 返回最新未读消息的索引，如果没有未读消息则返回null
  /// 最新未读消息就是会话中的最后一条消息（如果有未读消息的话）
  int? getLastUnreadMessageIndex(String? currentUserId) {
    if (currentUserId == null) return null;

    // 如果没有未读消息，返回null
    if (!hasUnread(currentUserId)) return null;

    // 最新未读消息就是会话的最后一条消息
    return lastMessageIndex > 0 ? lastMessageIndex : null;
  }

  /// 💢💢💢 新增：获取用户的新消息数量
  /// [userId] - 用户ID
  /// 返回lastMessageIndex和用户lastReadMessageIndex的差值
  int hasNewMessageCount(String userId) {
    final participant = getParticipant(userId);
    if (participant == null) return 0;

    // 如果没有消息或索引信息不完整，返回0
    if (lastMessageIndex <= 0 || participant.readMessageIndex < 0) {
      return 0;
    }

    // 计算新消息数量：会话最后消息索引 - 用户最后已读消息索引
    final newMessageCount = lastMessageIndex - participant.readMessageIndex;

    // 确保新消息数量不为负数
    return newMessageCount > 0 ? newMessageCount : 0;
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
  /// 适用于多端登录和重新安装的情况
  bool hasNewMessagesSinceLastRead(String? currentUserId) {
    if (currentUserId == null) return false;

    // 如果没有最后消息时间，返回false
    if (lastMessageTime == null) return false;

    // 如果用户从未阅读过会话，需要同时检查是否确实有未读消息
    // 这样处理多端登录和重新安装的情况
    if (lastReadTime == null) {
      // 必须确保确实有未读消息才认为有新消息
      return hasUnread(currentUserId);
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
      // 创建新的可变列表来更新参与者
      final newParticipants = List<Participant>.from(participants);
      newParticipants[index] = updatedParticipant;
      participants = newParticipants;
    } else {
      // 创建新的可变列表来添加参与者
      participants = [...participants, updatedParticipant];
    }
  }

  /// 💢💢💢 新增：移除参与者
  void removeParticipant(String userId) {
    // 创建新的可变列表以避免固定长度列表错误
    participants = participants.where((p) => p.userId != userId).toList();
  }

  /// 💢💢💢 新增：添加参与者
  void addParticipant(Participant participant) {
    final index =
        participants.indexWhere((p) => p.userId == participant.userId);
    if (index == -1) {
      // 创建新的可变列表来添加参与者
      participants = [...participants, participant];
    } else {
      // 创建新的可变列表来更新参与者
      final newParticipants = List<Participant>.from(participants);
      newParticipants[index] = participant;
      participants = newParticipants;
    }
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
    String? description,
    DateTime? createdAt,
    int? firstMessageIndex,
    int? lastMessageIndex,
    DateTime? lastMessageTime,
    String? lastMessagePreview,
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
      ..description = description ?? this.description
      ..createdAt = createdAt ?? this.createdAt
      ..firstMessageIndex = firstMessageIndex ?? this.firstMessageIndex
      ..lastMessageIndex = lastMessageIndex ?? this.lastMessageIndex
      ..lastMessageTime = lastMessageTime ?? this.lastMessageTime
      ..lastMessagePreview = lastMessagePreview ?? this.lastMessagePreview
      ..lastMessageName = lastMessageName ?? this.lastMessageName
      ..contactUserId = contactUserId ?? this.contactUserId
      ..createdBy = createdBy ?? this.createdBy
      ..lastReadTime = lastReadTime ?? this.lastReadTime
      ..participants = participants != null
          ? List<Participant>.from(participants)
          : List<Participant>.from(this.participants);

    return conversation;
  }

  /// 获取会话显示名称
  ///
  /// 私聊：返回对方参与者的名称，忽略 conversation.name
  /// 群聊/频道：返回 conversation.name，若为空则使用默认占位
  String displayName(String currentUserId) {
    if (type == ConversationType.private) {
      try {
        final other = participants.firstWhere((p) => p.userId != currentUserId);
        if (other.name.isNotEmpty) return other.name;
      } catch (_) {
        // ignore
      }
      return '未知联系人';
    }

    if (type == ConversationType.group) {
      return name ?? '群聊';
    } else if (type == ConversationType.channel) {
      return name ?? '频道';
    }
    return name ?? '未知联系人';
  }

  /// 💢💢💢 新增：频道相关方法
  
  /// 检查是否为频道
  bool get isChannel => type == ConversationType.channel;
  
  /// 检查当前用户是否已加入频道
  /// [currentUserId] - 当前用户ID
  bool isJoined(String? currentUserId) {
    if (currentUserId == null || !isChannel) return true;
    return getParticipant(currentUserId) != null;
  }
  
  /// 检查当前用户是否可以发送消息
  /// 频道：只有非普通成员才能发送消息
  /// 私聊/群聊：所有成员都可以发送消息
  /// [currentUserId] - 当前用户ID
  bool canSendMessage(String? currentUserId) {
    if (currentUserId == null) return false;
    
    if (!isChannel) {
      // 私聊和群聊：所有成员都可以发送消息
      return isJoined(currentUserId);
    }
    
    // 频道：只有非普通成员才能发送消息
    final participant = getParticipant(currentUserId);
    if (participant == null) return false;
    
    return participant.role == MemberRole.admin || participant.role == MemberRole.owner;
  }
  
  /// 检查当前用户是否为频道的普通成员
  /// [currentUserId] - 当前用户ID
  bool isRegularMember(String? currentUserId) {
    if (currentUserId == null || !isChannel) return false;
    
    final participant = getParticipant(currentUserId);
    if (participant == null) return false;
    
    return participant.role == MemberRole.member;
  }
  
  /// 获取当前用户在频道中的角色
  /// [currentUserId] - 当前用户ID
  MemberRole? getUserRole(String? currentUserId) {
    if (currentUserId == null) return null;
    
    final participant = getParticipant(currentUserId);
    return participant?.role;
  }
  
  /// 检查当前用户是否为频道管理员或所有者
  /// [currentUserId] - 当前用户ID
  bool isChannelAdminOrOwner(String? currentUserId) {
    if (currentUserId == null || !isChannel) return false;
    
    final participant = getParticipant(currentUserId);
    if (participant == null) return false;
    
    return participant.role == MemberRole.admin || participant.role == MemberRole.owner;
  }
}
