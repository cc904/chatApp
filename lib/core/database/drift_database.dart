import 'package:drift/drift.dart';
import 'package:cc/core/services/log_service.dart';

// 条件导入：根据平台选择不同的数据库实现
import 'drift_database_stub.dart'
    if (dart.library.io) 'drift_database_io.dart'
    if (dart.library.html) 'drift_database_web.dart';

// 导入表定义
part 'drift_database.g.dart';

/// 用户表 - 基于 UserProto
class Users extends Table {
  TextColumn get userId => text()();              // user_id
  TextColumn get nickName => text()();            // nick_name
  TextColumn get avatar => text().nullable()();   // avatar
  TextColumn get phone => text().nullable()();    // phone
  TextColumn get email => text().nullable()();    // email
  TextColumn get pinyin => text().nullable()();   // pinyin
  DateTimeColumn get lastActiveTime => dateTime().nullable()(); // last_active_time (DateTime)
  TextColumn get status => text().nullable()();   // status
  
  // 本地扩展字段
  BoolColumn get online => boolean().withDefault(const Constant(false))();
  BoolColumn get isFriend => boolean().withDefault(const Constant(false))();
  TextColumn get customNickname => text().nullable()(); // custom_nickname 自定义联系人昵称
  
  @override
  Set<Column> get primaryKey => {userId};
}

/// 当前用户表 - 基于 CurrentUserProto
class CurrentUsers extends Table {
  TextColumn get userId => text()();              // user_id
  TextColumn get name => text()();                // name
  TextColumn get avatar => text().nullable()();   // avatar
  TextColumn get phone => text().nullable()();    // phone
  TextColumn get email => text().nullable()();    // email
  DateTimeColumn get lastLoginTime => dateTime().nullable()(); // last_login_time (DateTime)
  TextColumn get status => text().nullable()();   // status
  BoolColumn get hasSetPassword => boolean().withDefault(const Constant(false))(); // has_set_password
  
  @override
  Set<Column> get primaryKey => {userId};
}

/// 会话表 - 基于 ConversationProto
class Conversations extends Table {
  TextColumn get conversationId => text()();      // conversation_id
  TextColumn get type => text()();                // type (PRIVATE, GROUP, CHANNEL)
  TextColumn get name => text().nullable()();     // name
  TextColumn get avatar => text().nullable()();   // avatar
  DateTimeColumn get createdAt => dateTime()();   // created_at (DateTime)
  TextColumn get createdBy => text().nullable()(); // created_by
  
  // 消息索引边界
  IntColumn get firstMessageIndex => integer().withDefault(const Constant(0))(); // first_message_index
  IntColumn get lastMessageIndex => integer().withDefault(const Constant(0))();  // last_message_index
  
  // 最后消息信息
  DateTimeColumn get lastMessageTime => dateTime().nullable()(); // last_message_time (DateTime)
  TextColumn get lastMessagePreview => text().nullable()(); // last_message_preview
  TextColumn get lastMessageName => text().nullable()();   // last_message_name
  
  // 参与者信息 (JSON 格式存储 ParticipantProto 列表)
  TextColumn get participants => text()();        // participants
  
  // 会话扩展信息
  TextColumn get description => text().nullable()(); // description
  BoolColumn get requiresApproval => boolean().withDefault(const Constant(false))(); // requires_approval
  
  // 当前用户的参与者设置 (用于快速访问，避免解析JSON)
  BoolColumn get muted => boolean().withDefault(const Constant(false))(); // 当前用户是否静音此会话
  BoolColumn get pinned => boolean().withDefault(const Constant(false))(); // 当前用户是否置顶此会话
  IntColumn get readMessageIndex => integer().withDefault(const Constant(0))(); // 当前用户已读消息索引
  IntColumn get unreadCount => integer().withDefault(const Constant(0))(); // 当前用户未读消息数量
  DateTimeColumn get lastReadTime => dateTime().nullable()(); // 当前用户最后阅读时间
  
  @override
  Set<Column> get primaryKey => {conversationId};
}

/// 消息表 - 基于 MessageProto
class Messages extends Table {
  TextColumn get messageId => text()();           // message_id
  TextColumn get conversationId => text()();      // conversation_id
  TextColumn get senderId => text()();            // sender_id
  TextColumn get senderName => text().nullable()(); // sender_name
  TextColumn get senderAvatar => text().nullable()(); // sender_avatar
  DateTimeColumn get createdAt => dateTime()();   // created_at (DateTime)
  DateTimeColumn get updatedAt => dateTime().nullable()(); // updated_at (DateTime)
  
  // 消息索引和状态
  IntColumn get messageIndex => integer()();      // index
  TextColumn get messageType => text()();         // type (TEXT, IMAGE, VOICE, FILE, VIDEO, SYSTEM)
  TextColumn get messageStatus => text()();       // status (SENDING, SENT, DELIVERED, READ, FAILED, DELETED, REVOKED)
  
  // 引用和回复
  TextColumn get quotedMessageId => text().nullable()(); // quoted_message_id
  TextColumn get repliedToMessageId => text().nullable()(); // replied_to_message_id
  TextColumn get forwardedFromConversationId => text().nullable()(); // forwarded_from_conversation_id
  TextColumn get forwardedFromMessageId => text().nullable()(); // forwarded_from_message_id
  
  // 编辑信息
  BoolColumn get isEdited => boolean().withDefault(const Constant(false))(); // is_edited
  DateTimeColumn get editedAt => dateTime().nullable()(); // edited_at (timestamp)
  
  // 消息功能
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))(); // is_pinned
  TextColumn get reactions => text().nullable()(); // reactions (JSON map<string, int32>)
  TextColumn get tags => text().nullable()();      // tags (JSON repeated string)
  
  // 消息内容 (基于 oneof content，存储为 JSON)
  TextColumn get content => text().nullable()();   // content (JSON of TextMessage/MediaMessage/SystemMessage etc.)
  
  @override
  Set<Column> get primaryKey => {messageId};
}

/// 好友请求表 - 基于 FriendRequestProto
class FriendRequests extends Table {
  TextColumn get requestId => text()();           // request_id
  TextColumn get senderId => text()();            // sender_id
  TextColumn get receiverId => text()();          // receiver_id
  TextColumn get status => text()();              // status (PENDING, ACCEPTED, REJECTED)
  TextColumn get message => text().nullable()();  // message
  DateTimeColumn get sentAt => dateTime()();      // sent_at (DateTime)
  DateTimeColumn get processedAt => dateTime().nullable()(); // processed_at (DateTime)
  
  @override
  Set<Column> get primaryKey => {requestId};
}

/// 快捷回复表 - 基于 QuickReply
class QuickReplies extends Table {
  IntColumn get id => integer().autoIncrement()(); // id
  TextColumn get content => text()();             // content
  TextColumn get category => text().nullable()(); // category
  IntColumn get orderIndex => integer().withDefault(const Constant(0))(); // order_index
  BoolColumn get isEnabled => boolean().withDefault(const Constant(true))(); // is_enabled
  DateTimeColumn get createdAt => dateTime()();   // 本地创建时间 (DateTime)
  DateTimeColumn get updatedAt => dateTime().nullable()(); // 本地更新时间 (DateTime)
}

/// Drift数据库类
@DriftDatabase(tables: [
  Users,
  CurrentUsers, 
  Conversations,
  Messages,
  FriendRequests,
  QuickReplies,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase._internal(String userId) : super(_openConnection(userId));
  
  static AppDatabase? _instance;
  static String? _currentUserId;
  static final _logger = LogService.instance;
  
  /// 获取数据库单例实例
  static AppDatabase get instance {
    if (_instance == null) {
      throw Exception('数据库未初始化，请先调用 AppDatabase.init()');
    }
    return _instance!;
  }
  
  @override
  int get schemaVersion => 1;
  
  /// 初始化数据库（为特定用户）
  static Future<void> init({required CurrentUser currentUser}) async {
    try {
      _logger.i('初始化 Drift 数据库，用户ID: ${currentUser.userId}');
      
      // 如果当前用户ID相同且实例存在，直接返回
      if (_currentUserId == currentUser.userId && _instance != null) {
        _logger.i('数据库已为当前用户初始化，跳过重复初始化');
        return;
      }
      
      // 如果是不同用户，先关闭现有数据库
      if (_instance != null && _currentUserId != currentUser.userId) {
        _logger.i('切换用户，关闭现有数据库实例。旧用户: $_currentUserId, 新用户: ${currentUser.userId}');
        await closeDatabase();
      }
      
      // 创建新的数据库实例
      _currentUserId = currentUser.userId;
      _instance = AppDatabase._internal(currentUser.userId);
      
      // 创建数据库表和索引
      await _instance!._createIndexes();
      
      // 保存当前用户信息
      await _instance!._saveCurrentUserToDatabase(currentUser);
      
      _logger.i('Drift 数据库初始化完成，用户ID: ${currentUser.userId}');
    } catch (error) {
      _logger.e('Drift 数据库初始化失败', error: error, stackTrace: StackTrace.current);
      // 确保在失败时清理状态
      _instance = null;
      _currentUserId = null;
      rethrow;
    }
  }
  
  /// 创建数据库索引
  Future<void> _createIndexes() async {
    try {
      _logger.i('创建 Drift 数据库索引');
      
      // Drift 会自动为主键创建索引
      // 可以在这里创建额外的复合索引来优化查询性能
      
      _logger.i('Drift 数据库索引创建完成');
    } catch (error) {
      _logger.e('创建 Drift 数据库索引失败', error: error);
    }
  }
  
  /// 保存当前用户信息到数据库
  Future<void> _saveCurrentUserToDatabase(CurrentUser currentUser) async {
    try {
      _logger.i('保存当前用户信息到 Drift 数据库', extra: {
        'userId': currentUser.userId,
        'name': currentUser.name,
        'phone': currentUser.phone,
        'email': currentUser.email,
        'avatar': currentUser.avatar,
        'status': currentUser.status,
      });
      
      // 验证必需字段
      if (currentUser.userId.isEmpty) {
        throw ArgumentError('用户ID不能为空');
      }
      
      // 设置默认值
      final userName = currentUser.name.isEmpty ? '用户${currentUser.userId.substring(0, 6)}' : currentUser.name;
      final userPhone = currentUser.phone ?? '';
      final userEmail = currentUser.email ?? '';
      final userAvatar = currentUser.avatar ?? '';
      final userStatus = currentUser.status ?? 'offline';
      
      // 使用时间戳（已经是毫秒格式）
      final lastLoginTimeMs = currentUser.lastLoginTime;
      
      // 保存用户信息
      await into(currentUsers).insertOnConflictUpdate(CurrentUsersCompanion.insert(
        userId: currentUser.userId,
        name: userName,
        phone: Value(userPhone.isEmpty ? null : userPhone),
        email: Value(userEmail.isEmpty ? null : userEmail),
        avatar: Value(userAvatar.isEmpty ? null : userAvatar),
        status: Value(userStatus.isEmpty ? null : userStatus),
        lastLoginTime: Value(lastLoginTimeMs),
        hasSetPassword: Value(currentUser.hasSetPassword),
      ));
      
      _logger.i('当前用户信息已保存到 Drift 数据库');
    } catch (error) {
      _logger.e('保存当前用户信息到 Drift 数据库失败', error: error, stackTrace: StackTrace.current);
    }
  }
  
  /// 关闭数据库
  static Future<void> closeDatabase() async {
    try {
      if (_instance != null) {
        _logger.i('关闭 Drift 数据库，用户ID: $_currentUserId');
        await _instance!.close();
        _instance = null;
        _currentUserId = null;
        _logger.i('Drift 数据库关闭完成');
      }
    } catch (error) {
      _logger.e('关闭 Drift 数据库失败', error: error, stackTrace: StackTrace.current);
      // 即使关闭失败也要清理状态
      _instance = null;
      _currentUserId = null;
    }
  }
}

/// 打开数据库连接
DatabaseConnection _openConnection(String userId) {
  // 在 Web 平台上直接使用连接，避免 LazyDatabase 在 release 模式下的时序问题
  return DatabaseConnection.delayed(openDatabaseConnection(userId));
}

/// Conversation类的扩展方法
/// 为Drift生成的Conversation类添加业务逻辑方法
extension ConversationExtension on Conversation {
  /// 检查用户是否已加入会话
  /// 对于私聊会话总是返回true
  /// 对于群组和频道，检查参与者列表
  bool isJoined(String userId) {
    // 私聊会话总是已加入
    if (type == 'PRIVATE') {
      return true;
    }
    
    // 对于群组和频道，需要解析participants字段（JSON格式）
    try {
      final participantsList = participants.split(',');
      return participantsList.contains(userId);
    } catch (e) {
      // 如果解析失败，默认返回false
      return false;
    }
  }
  
  /// 获取用户在会话中的未读消息数
  /// 通过比较lastMessageIndex和用户的lastReadMessageIndex计算
  int unreadCount(String userId) {
    // 这里需要查询用户的已读位置，暂时返回0
    // 实际实现需要通过数据库查询用户的lastReadMessageIndex
    // 然后计算 lastMessageIndex - lastReadMessageIndex
    
    // TODO: 实现实际的未读计数逻辑
    // 需要查询用户设置表或参与者表来获取lastReadMessageIndex
    return 0;
  }
  
  /// 获取私聊会话的联系人用户ID
  /// 从participants字段中解析出对方的用户ID
  String? get contactUserId {
    if (type != 'PRIVATE') {
      return null;
    }
    
    try {
      // 对于私聊，participants包含两个用户ID
      final participantsList = participants.split(',');
      if (participantsList.length == 2) {
        // 假设当前用户ID可以通过某种方式获取
        // 这里需要传入当前用户ID来确定对方ID
        // 暂时返回第一个参与者ID
        return participantsList.first;
      }
    } catch (e) {
      // 解析失败
    }
    
    return null;
  }
  
  /// 更新当前用户在会话中的设置
  /// 这个方法应该调用数据库更新操作
  void updateCurrentUserSettings({
    required String currentUserId,
    bool? muted,
    int? lastReadMessageIndex,
  }) {
    // 这个方法应该通过数据库操作来更新用户在会话中的设置
    // 在Drift架构中，这通常需要更新一个单独的用户设置表
    // 或者更新participants字段中的相关信息
    
    // TODO: 实现实际的数据库更新操作
    // 例如：
    // await AppDatabase.instance.updateUserConversationSettings(
    //   conversationId: conversationId,
    //   userId: currentUserId,
    //   muted: muted,
    //   lastReadMessageIndex: lastReadMessageIndex,
    // );
  }
  
  /// 获取会话的第一个未读消息索引
  /// 基于用户的已读位置计算
  int? getFirstUnreadMessageIndex(String userId) {
    // TODO: 实现实际逻辑
    // 需要查询用户的lastReadMessageIndex，然后返回下一个消息的索引
    return null;
  }
}

/// QuickReply类的扩展方法
/// 为Drift生成的QuickReply类添加业务逻辑方法
extension QuickReplyExtension on QuickReply {
  /// 从服务器JSON创建QuickReply对象
  static QuickReply fromServerJson(Map<String, dynamic> json) {
    return QuickReply(
      id: json['id'] ?? 0,
      content: json['content'] ?? '',
      category: json['category'],
      orderIndex: json['order'] ?? 0,
      isEnabled: json['is_enabled'] ?? true,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }
  
  /// 转换为JSON格式
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'category': category,
      'order': orderIndex,
      'is_enabled': isEnabled,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
  
  /// 兼容性属性：获取order（映射到orderIndex）
  int get order => orderIndex;
}