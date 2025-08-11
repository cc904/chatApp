import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/features/chat/domain/entities/participant.dart';
import 'package:cc/core/adapters/conversation_adapter.dart';

// 条件导入：根据平台选择不同的数据库实现
import 'drift_database_stub.dart'
    if (dart.library.io) 'drift_database_io.dart'
    if (dart.library.html) 'drift_database_web.dart';

// 导入表定义
part 'drift_database.g.dart';

/// 用户表 - 基于 UserProto
class Users extends Table {
  TextColumn get userId => text()();              // user_id
  TextColumn get name => text()();                // name (用户真实昵称)
  TextColumn get avatar => text().nullable()();   // avatar
  TextColumn get phone => text().nullable()();    // phone
  TextColumn get email => text().nullable()();    // email
  TextColumn get pinyin => text().nullable()();   // pinyin
  DateTimeColumn get lastActiveTime => dateTime().nullable()(); // last_active_time (DateTime)
  IntColumn get status => integer().nullable()();   // status (0=OFFLINE,1=ONLINE,2=AWAY)
  IntColumn get roleId => integer().withDefault(const Constant(2))(); // role_id 用户角色ID，默认为普通用户
  
  // 本地扩展字段
  BoolColumn get online => boolean().withDefault(const Constant(false))();
  BoolColumn get isFriend => boolean().withDefault(const Constant(false))();
  TextColumn get nickname => text().nullable()(); // nickname 自定义联系人昵称
  TextColumn get remark => text().nullable()(); // remark 联系人备注
  
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
  IntColumn get status => integer().nullable()();   // status (0=OFFLINE,1=ONLINE,2=AWAY)
  BoolColumn get hasSetPassword => boolean().withDefault(const Constant(false))(); // has_set_password
  IntColumn get roleId => integer().withDefault(const Constant(2))(); // role_id 用户角色ID，默认为普通用户
  
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
  
  // 参与者信息（底层仍为 JSON 存储，但通过 TypeConverter 暴露为 List<Participant>）
  TextColumn get participants =>
      text().map(const ParticipantListConverter()).withDefault(const Constant('[]'))();
  
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

/// Drift TypeConverter：List<Participant> <-> JSON String
class ParticipantListConverter extends TypeConverter<List<Participant>, String> {
  const ParticipantListConverter();

  @override
  List<Participant> fromSql(String fromDb) {
    try {
      if (fromDb.isEmpty) return const [];
      final dynamic decoded = _decodeJson(fromDb);
      if (decoded is List) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .map((m) => Participant.fromMap(m))
            .toList();
      }
      return const [];
    } catch (_) {
      return const [];
    }
  }

  @override
  String toSql(List<Participant> value) {
    final list = value.map((e) => e.toMap()).toList();
    return _encodeJson(list);
  }

  dynamic _decodeJson(String s) {
    try {
      return const JsonDecoder().convert(s);
    } catch (_) {
      return [];
    }
  }

  String _encodeJson(Object o) {
    try {
      return const JsonEncoder().convert(o);
    } catch (_) {
      return '[]';
    }
  }
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
  int get schemaVersion => 5;
  
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) {
      return m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from == 1 && to == 2) {
        // 添加role_id字段到current_users表
        await m.addColumn(currentUsers, currentUsers.roleId);
        _logger.i('数据库迁移完成: 添加role_id字段到current_users表');
      }
      if (from == 2 && to == 3) {
        // 添加role_id字段到users表
        await m.addColumn(users, users.roleId);
        _logger.i('数据库迁移完成: 添加role_id字段到users表');
      }
      if (from == 3 && to == 4) {
        // 原本添加senderRoleId字段，现已移除该字段
        _logger.i('数据库迁移跳过: sender_role_id字段已移除');
      }
      if (from == 1 && to == 3) {
        // 从版本1直接升级到版本3
        await m.addColumn(currentUsers, currentUsers.roleId);
        await m.addColumn(users, users.roleId);
        _logger.i('数据库迁移完成: 添加role_id字段到current_users和users表');
      }
      if (from == 1 && to == 4) {
        // 从版本1直接升级到版本4
        await m.addColumn(currentUsers, currentUsers.roleId);
        await m.addColumn(users, users.roleId);
        // sender_role_id字段已移除
        _logger.i('数据库迁移完成: 添加role_id字段，跳过sender_role_id');
      }
      if (from == 2 && to == 4) {
        // 从版本2直接升级到版本4
        await m.addColumn(users, users.roleId);
        // sender_role_id字段已移除
        _logger.i('数据库迁移完成: 添加role_id字段到users表，跳过sender_role_id');
      }
      if (from < 5 && to >= 5) {
        // 将 Users.status / CurrentUsers.status 从 TEXT 迁移为 INTEGER
        // 简化处理：重建两张表并拷贝字段（服务未上线，允许重建）
        _logger.i('数据库迁移到 v5：重建 users / current_users 以切换 status 为 INT');
        // 先清理可能遗留的备份表，避免重名冲突
        await customStatement('DROP TABLE IF EXISTS users_backup_v4');
        await customStatement('DROP TABLE IF EXISTS current_users_backup_v4');

        // 备份旧表数据
        await customStatement('ALTER TABLE users RENAME TO users_backup_v4');
        await customStatement('ALTER TABLE current_users RENAME TO current_users_backup_v4');

        // 重建新表结构
        await m.createTable(users);
        await m.createTable(currentUsers);

        // 从备份表拷贝数据，status 尝试 CAST 为 INTEGER
        // 兼容旧列名（如 users.nick_name/custom_nickname 等）
        try {
          final usersInfo = await customSelect('PRAGMA table_info(users_backup_v4)').get();
          final cuInfo = await customSelect('PRAGMA table_info(current_users_backup_v4)').get();

          bool _has(List<QueryRow> info, String col) =>
              info.any((r) => (r.data['name'] as String?) == col);

          final usersNameExpr = _has(usersInfo, 'name')
              ? 'name'
              : (_has(usersInfo, 'nick_name') ? 'nick_name' : "''");
          final usersNicknameExpr = _has(usersInfo, 'nickname')
              ? 'nickname'
              : (_has(usersInfo, 'custom_nickname') ? 'custom_nickname' : 'NULL');
          final usersRoleIdExpr = _has(usersInfo, 'role_id') ? 'role_id' : '2';

          await customStatement('''
            INSERT OR IGNORE INTO users (user_id, name, avatar, phone, email, pinyin, last_active_time, status, role_id, online, is_friend, nickname, remark)
            SELECT user_id, $usersNameExpr, avatar, phone, email, pinyin, last_active_time,
                   CASE
                     WHEN status IS NULL THEN NULL
                     WHEN status IN ('', 'offline','OFFLINE','0') THEN 0
                     WHEN status IN ('online','ONLINE','1') THEN 1
                     WHEN status IN ('away','AWAY','2') THEN 2
                     WHEN CAST(status AS INTEGER) IN (0,1,2) THEN CAST(status AS INTEGER)
                     ELSE NULL
                   END as status,
                   $usersRoleIdExpr, online, is_friend, $usersNicknameExpr, NULL
            FROM users_backup_v4;
          ''');

          final cuRoleIdExpr = _has(cuInfo, 'role_id') ? 'role_id' : '2';
          await customStatement('''
            INSERT OR IGNORE INTO current_users (user_id, name, avatar, phone, email, last_login_time, status, has_set_password, role_id)
            SELECT user_id, name, avatar, phone, email, last_login_time,
                   CASE
                     WHEN status IS NULL THEN NULL
                     WHEN status IN ('', 'offline','OFFLINE','0') THEN 0
                     WHEN status IN ('online','ONLINE','1') THEN 1
                     WHEN status IN ('away','AWAY','2') THEN 2
                     WHEN CAST(status AS INTEGER) IN (0,1,2) THEN CAST(status AS INTEGER)
                     ELSE NULL
                   END as status,
                   has_set_password, $cuRoleIdExpr
            FROM current_users_backup_v4;
          ''');
        } catch (e) {
          _logger.e('v5 数据迁移（兼容旧列名）失败，降级为空表迁移：$e');
          // 如果复制失败，保持新表为空，继续执行清理，避免应用不可用
        }

        // 删除备份表
        await customStatement('DROP TABLE IF EXISTS users_backup_v4');
        await customStatement('DROP TABLE IF EXISTS current_users_backup_v4');
        _logger.i('v5 迁移完成：status 字段切换为 INT');
      }
    },
  );
  
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
      final userStatus = currentUser.status ?? 0; // 0=OFFLINE
      
      // 使用时间戳（已经是毫秒格式）
      final lastLoginTimeMs = currentUser.lastLoginTime;
      
      // 保存用户信息（增加重试，规避偶发的底层打开失败/锁竞争）
      const int maxRetries = 3;
      Duration backoff(int attempt) => Duration(milliseconds: 200 * attempt);
      int attempt = 0;
      while (true) {
        attempt++;
        try {
          await into(currentUsers).insertOnConflictUpdate(CurrentUsersCompanion.insert(
            userId: currentUser.userId,
            name: userName,
            phone: Value(userPhone.isEmpty ? null : userPhone),
            email: Value(userEmail.isEmpty ? null : userEmail),
            avatar: Value(userAvatar.isEmpty ? null : userAvatar),
            status: Value(userStatus),
            lastLoginTime: Value(lastLoginTimeMs),
            hasSetPassword: Value(currentUser.hasSetPassword),
            roleId: Value(currentUser.roleId), // 添加roleId字段
          ));
          break;
        } catch (e) {
          _logger.w('保存当前用户重试中', extra: {
            'attempt': attempt,
            'maxRetries': maxRetries,
            'error': e.toString(),
          });
          if (attempt >= maxRetries) {
            rethrow;
          }
          await Future.delayed(backoff(attempt));
        }
      }
      
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
    
    // 对于群组和频道，解析强类型 participants
    final list = ConversationAdapter.parseParticipants(participants);
    return list.any((p) => p.userId == userId);
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
    
    final list = ConversationAdapter.parseParticipants(participants);
    if (list.length == 2) {
      return list.first.userId;
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