import 'dart:async';
import 'package:cc/core/database/drift_database.dart';
import 'package:drift/drift.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/services/communication_service.dart';
import 'package:cc/core/services/app_lifecycle_service.dart';
import 'package:cc/core/proto/generated/user.pb.dart';
import 'package:cc/core/proto/generated/contacts.pb.dart';
import 'package:cc/core/adapters/user_adapter.dart';

import 'package:cc/features/contacts/domain/repositories/contacts_repository.dart';

/// ContactsRepository的实现类
/// 负责管理联系人数据、实现联系人相关的业务逻辑
class ContactsRepositoryImpl implements ContactsRepository {
  final LogService _logger = LogService.instance;
  final CommunicationService _communicationService = CommunicationService();
  final CurrentUser _currentUser;

  // 获取数据库实例
  AppDatabase get _db => AppDatabase.instance;

  // 事件订阅管理
  final List<StreamSubscription> _subscriptions = [];

  // 同步状态流
  final _syncContactsStatusController = StreamController<ContactsSyncStatus>.broadcast();
  @override
  Stream<ContactsSyncStatus> get syncStatusStream => _syncContactsStatusController.stream;

  // 构造函数
  ContactsRepositoryImpl({required CurrentUser currentUser}) : _currentUser = currentUser {
    _logger.x('ContactsRepositoryImpl 初始化');
    _initializeEventHandlers();
  }

  /// 初始化事件处理器
  void _initializeEventHandlers() {
    _logger.i('初始化好友请求事件处理器');

    // 监听发送好友请求响应
    _subscriptions.add(
      _communicationService.onProto<FriendRequestProto>('friend:request:send:response').listen(_handleFriendRequestSendResponse),
    );

    // 监听处理好友请求响应
    _subscriptions.add(
      _communicationService.onProto<FriendRequestProto>('friend:request:process:response').listen(_handleFriendRequestProcessResponse),
    );

    // 监听收到好友请求通知
    _subscriptions.add(
      _communicationService.onProto<FriendRequestProto>('friend:request:received').listen(_handleFriendRequestReceived),
    );

    // 监听好友请求处理结果通知
    _subscriptions.add(
      _communicationService.onProto<FriendRequestProto>('friend:request:processed').listen(_handleFriendRequestProcessed),
    );
  }

  /// 获取通信服务实例
  CommunicationService get communicationService => _communicationService;

  /// 更新用户在线状态
  void updateUserOnlineStatus(String userId, bool isOnline) {
    _updateUserOnlineStatus(userId, isOnline);
  }

  /// 处理联系人同步事件
  void handleContactsSyncedEvent(UserCollection data) {
    _handleContactsSyncedEvent(data);
  }

  /// 处理联系人同步结果
  void handleContactsSyncResultProto(SyncContactsResponse response) {
    _handleContactsSyncResultProto(response);
  }

  /// 处理联系人同步完成事件
  void _handleContactsSyncedEvent(UserCollection data) async {
    try {
      _logger.i('收到联系人同步事件', extra: {'count': data.users.length});

      // 将 UserProto 转换为 User 对象并保存到数据库
      for (final userProto in data.users) {
        _logger.i('🔥🔥🔥 联系人同步事件处理', extra: {
          'userName': userProto.name,
          'userId': userProto.userId,
          'roleId': 0, // Proto中没有roleId字段
          'hasRoleId': false, // Proto中没有roleId字段
        });

        await _db.into(_db.users).insertOnConflictUpdate(UsersCompanion.insert(
              userId: userProto.userId,
              name: userProto.name,
              avatar: Value(userProto.avatar.isEmpty ? null : userProto.avatar),
              phone: Value(userProto.phone.isEmpty ? null : userProto.phone),
              email: Value(userProto.email.isEmpty ? null : userProto.email),
              pinyin: Value(userProto.pinyin.isEmpty ? null : userProto.pinyin),
              lastActiveTime: Value(userProto.hasLastActiveTime() ? DateTime.fromMillisecondsSinceEpoch(userProto.lastActiveTime.toInt()) : null),
              status: Value(userProto.status.isEmpty ? null : userProto.status),
              roleId: const Value(0), // Proto中没有roleId字段
              isFriend: const Value(true),
            ));
      }

      // 通知同步成功
      _syncContactsStatusController.add(ContactsSyncStatus.success);

      _logger.i('联系人同步数据处理完成', extra: {'count': data.users.length});
    } catch (error) {
      _logger.e('处理联系人同步事件失败', error: error, stackTrace: StackTrace.current);
      _syncContactsStatusController.add(ContactsSyncStatus.error);
    }
  }

  /// 处理联系人同步结果事件 - 使用 Protocol Buffer 类型
  void _handleContactsSyncResultProto(SyncContactsResponse response) async {
    try {
      _logger.i('收到联系人同步结果事件', extra: {'contactsCount': response.contacts.length});

      if (response.contacts.isEmpty) {
        _logger.i('联系人列表为空，这可能是新用户或同步过程中的正常状态');
        // 通知同步成功（即使列表为空）
        _syncContactsStatusController.add(ContactsSyncStatus.success);
        return;
      }

      // 将 UserProto 转换为 User 对象并保存到数据库
      for (final userProto in response.contacts) {
        _logger.i('🚀🚀🚀 联系人同步结果处理', extra: {
          'userName': userProto.name,
          'userId': userProto.userId,
          'roleId': 0, // Proto中没有roleId字段
          'hasRoleId': false, // Proto中没有roleId字段
        });

        // 检查是否已存在相同userId的联系人
        final existingUser = await (_db.select(_db.users)..where((tbl) => tbl.userId.equals(userProto.userId))).getSingleOrNull();

        // 使用专门的联系人转换方法，统一处理所有字段
        final user = UserAdapter.fromUserProtoForContact(
          userProto,
          existingNickname: existingUser?.nickname,
        );

        if (existingUser != null) {
          // 更新现有联系人信息 - 使用统一的本地模型
          await (_db.update(_db.users)..where((tbl) => tbl.userId.equals(userProto.userId))).write(UserAdapter.toUsersCompanion(user));
        } else {
          // 添加新联系人 - 使用统一的本地模型
          await _db.into(_db.users).insert(UserAdapter.toUsersCompanion(user));
        }
      }

      // 通知同步成功
      _syncContactsStatusController.add(ContactsSyncStatus.success);

      _logger.i('联系人同步数据处理完成', extra: {'count': response.contacts.length});
    } catch (e, stack) {
      _logger.e('处理联系人同步结果事件失败', error: e, stackTrace: stack);
      _syncContactsStatusController.add(ContactsSyncStatus.error);
    }
  }

  /// 更新用户在线状态
  /// 将用户状态更新为在线或离线,并记录最后活跃时间
  /// [userId] - 要更新状态的用户ID
  /// [isOnline] - 是否在线
  Future<void> _updateUserOnlineStatus(String userId, bool isOnline) async {
    try {
      final user = await (_db.select(_db.users)..where((tbl) => tbl.userId.equals(userId))).getSingleOrNull();
      if (user != null) {
        await (_db.update(_db.users)..where((tbl) => tbl.userId.equals(userId))).write(UsersCompanion(
          status: Value(isOnline ? 'online' : 'offline'),
          lastActiveTime: Value(DateTime.now()),
        ));

        _logger.i('已更新用户在线状态', extra: {'userId': userId, 'isOnline': isOnline});
      }
    } catch (error) {
      _logger.e('更新用户在线状态失败', error: error, stackTrace: StackTrace.current);
    }
  }

  /// 获取所有联系人
  /// 返回数据库中的所有联系人列表
  @override
  Future<List<User>> getAllContacts() async {
    _logger.w('获取所有联系人', stackTrace: StackTrace.current);
    try {
      // 返回本地数据库中的联系人列表
      final users = await (_db.select(_db.users)..where((tbl) => tbl.isFriend.equals(true))).get();

      // 🔥🔥🔥 详细的数据库查询结果日志
      for (final user in users) {
        _logger.i('🗃️🗃️🗃️ 数据库中的联系人', extra: {
          'userName': user.name,
          'userId': user.userId,
          'roleId': user.roleId,
          'isFriend': user.isFriend,
          'avatar': user.avatar,
        });
      }

      _logger.i('从本地数据库中获取 - ${users.length} 个联系人');
      return users;
    } catch (error) {
      _logger.e('从本地数据库中获取联系人列表失败', error: error, stackTrace: StackTrace.current);
      return [];
    }
  }

  /// 搜索联系人
  /// 根据查询词搜索联系人,可匹配名称、拼音等字段
  /// [query] - 搜索关键词
  @override
  Future<List<User>> searchContacts(String query) async {
    if (query.isEmpty) return [];

    try {
      final users = await (_db.select(_db.users)..where((tbl) => tbl.isFriend.equals(true) & (tbl.name.contains(query) | tbl.pinyin.contains(query)))).get();
      return users;
    } catch (error) {
      _logger.e('搜索联系人失败', error: error, stackTrace: StackTrace.current);
      return [];
    }
  }

  /// 获取单个联系人
  /// 根据用户ID查询联系人详情
  /// [userId] - 联系人的用户ID
  @override
  Future<User?> getContactById(String userId) async {
    try {
      // 使用userId字段查询
      return await (_db.select(_db.users)..where((tbl) => tbl.userId.equals(userId))).getSingleOrNull();
    } catch (error) {
      _logger.e('获取联系人详情失败', error: error, stackTrace: StackTrace.current);
      return null;
    }
  }

  /// 添加联系人
  /// 将联系人保存到数据库
  /// [contact] - 要添加的联系人对象
  @override
  Future<bool> addContact(User contact) async {
    try {
      await _db.into(_db.users).insertOnConflictUpdate(UsersCompanion.insert(
            userId: contact.userId,
            name: contact.name,
            avatar: Value(contact.avatar),
            phone: Value(contact.phone),
            email: Value(contact.email),
            pinyin: Value(contact.pinyin),
            lastActiveTime: Value(contact.lastActiveTime),
            status: Value(contact.status),
            roleId: Value(contact.roleId),
            isFriend: const Value(true),
          ));
      return true;
    } catch (error) {
      _logger.e('添加联系人失败', error: error, stackTrace: StackTrace.current);
      return false;
    }
  }

  /// 更新联系人
  /// 更新已有联系人的信息
  /// [contact] - 包含更新信息的联系人对象
  @override
  Future<bool> updateContact(User contact) async {
    try {
      await (_db.update(_db.users)..where((tbl) => tbl.userId.equals(contact.userId))).write(UsersCompanion(
        name: Value(contact.name),
        avatar: Value(contact.avatar),
        phone: Value(contact.phone),
        email: Value(contact.email),
        pinyin: Value(contact.pinyin),
        lastActiveTime: Value(contact.lastActiveTime),
        status: Value(contact.status),
        roleId: Value(contact.roleId),
      ));
      return true;
    } catch (error) {
      _logger.e('更新联系人失败', error: error, stackTrace: StackTrace.current);
      return false;
    }
  }

  /// 删除联系人
  /// 从数据库中删除指定联系人
  /// [userId] - 要删除的联系人ID
  @override
  Future<bool> deleteContact(String userId) async {
    try {
      final rowsAffected = await (_db.delete(_db.users)..where((tbl) => tbl.userId.equals(userId))).go();
      return rowsAffected > 0;
    } catch (error) {
      _logger.e('删除联系人失败', error: error, stackTrace: StackTrace.current);
      return false;
    }
  }

  /// 监听联系人变化
  /// 返回联系人列表变化的流
  @override
  Stream<void> watchContacts() {
    return _db.select(_db.users).watch().map((_) {});
  }

  /// 同步联系人
  /// 从服务器同步最新的联系人数据
  /// 该方法只发送同步请求，不返回联系人列表
  /// 联系人数据将通过事件通知并由状态管理系统更新UI
  @override
  Future<void> syncContacts() async {
    try {
      // 🔄 检查应用状态，如果在后台则跳过同步
      final appLifecycleService = AppLifecycleService.instance;
      if (appLifecycleService.isAppInBackground) {
        _logger.w('应用在后台状态，跳过联系人同步', extra: {
          'currentState': appLifecycleService.currentState.toString(),
        });
        // 不设置错误状态，保持当前状态
        return;
      }

      // 通知开始同步
      _syncContactsStatusController.add(ContactsSyncStatus.syncing);
      _logger.i('开始联系人同步流程');

      // 检查用户信息
      if (_currentUser.userId.isEmpty) {
        _logger.e('当前用户信息不完整或Token无效，无法同步联系人', extra: {
          'userId': _currentUser.userId,
          'hasUserId': _currentUser.userId.isNotEmpty,
          'appState': appLifecycleService.currentState.toString(),
        });

        // 🔄 只在应用活跃时才设置错误状态
        if (appLifecycleService.isAppActive) {
          _syncContactsStatusController.add(ContactsSyncStatus.error);
        }
        return;
      }

      if (_communicationService.isInitialized) {
        // 发送请求
        _communicationService.emitProto('contact:sync', SyncContactsRequest());
        _logger.i('联系人同步请求已发送');

        // 创建一个变量来跟踪同步状态
        bool isSyncComplete = false;

        // 添加一个临时监听器来检测同步状态变化
        final syncSubscription = _syncContactsStatusController.stream.listen((status) {
          if (status != ContactsSyncStatus.syncing) {
            isSyncComplete = true;
          }
        });

        // 启动超时检查，如果15秒内没有收到响应，则标记为失败
        Future.delayed(const Duration(seconds: 15), () {
          syncSubscription.cancel(); // 取消监听器
          if (!isSyncComplete) {
            _logger.w('联系人同步请求超时');
            _syncContactsStatusController.add(ContactsSyncStatus.error);
          }
        });
      } else {
        _logger.e('通信服务未初始化，无法同步联系人');
        _syncContactsStatusController.add(ContactsSyncStatus.error);
      }
    } catch (error, stack) {
      _logger.e('同步联系人失败', error: error, stackTrace: stack);
      _syncContactsStatusController.add(ContactsSyncStatus.error);
      rethrow;
    }
  }

  /// 获取好友请求列表
  /// 获取当前用户收到的所有好友请求
  @override
  Future<List<FriendRequest>> getFriendRequests() async {
    try {
      // 查询好友请求
      final requests = await (_db.select(_db.friendRequests)
            ..where((tbl) => tbl.receiverId.equals(_currentUser.userId))
            ..orderBy([(tbl) => OrderingTerm.desc(tbl.sentAt)]))
          .get();

      _logger.i('获取好友请求列表成功 - ${requests.length} 个请求');
      return requests;
    } catch (error) {
      _logger.e('获取好友请求列表失败', error: error, stackTrace: StackTrace.current);
      return [];
    }
  }

  /// 发送好友请求
  /// 向指定用户发送好友申请
  /// [targetUserId] - 目标用户ID
  /// [message] - 申请附带消息
  @override
  Future<bool> sendFriendRequest(String targetUserId, String message) async {
    try {
      _logger.i('发送好友请求', extra: {'event': 'friend:request:send', 'targetUserId': targetUserId, 'message': message});

      // 检查目标用户是否已经是好友
      final existingContact = await getContactById(targetUserId);
      if (existingContact != null) {
        throw '该用户已经是您的好友';
      }

      // 注意：是否已发送请求的判断交由服务器处理
      // 本地不再检查重复请求，避免客户端和服务器状态不一致的问题

      // 创建好友请求
      final requestId = 'req_${DateTime.now().millisecondsSinceEpoch}';

      // 保存到数据库
      await _db.into(_db.friendRequests).insert(FriendRequestsCompanion.insert(
            requestId: requestId,
            senderId: _currentUser.userId,
            receiverId: targetUserId,
            message: Value(message.isEmpty ? null : message),
            status: 'PENDING',
            sentAt: DateTime.now(),
          ));

      // 发送请求到服务器
      if (_communicationService.isInitialized) {
        final protoRequest = SendFriendRequestProto()
          ..senderId = _currentUser.userId
          ..receiverId = targetUserId
          ..message = message;

        await _communicationService.emitProto('friend:request:send', protoRequest);
      }

      _logger.i('发送好友请求成功', extra: {
        'event': 'friend:request:send',
        'targetUserId': targetUserId,
      });
      return true;
    } catch (error) {
      _logger.e('发送好友请求失败',
          error: error,
          extra: {
            'event': 'friend:request:send',
            'targetUserId': targetUserId,
          },
          stackTrace: StackTrace.current);
      rethrow;
    }
  }

  /// 接受好友请求
  /// 接受来自指定用户的好友申请
  /// [requestId] - 好友请求ID
  @override
  Future<bool> acceptFriendRequest(String requestId) async {
    try {
      _logger.i('接受好友请求', extra: {
        'event': 'friend:request:process',
        'requestId': requestId,
      });

      // 查询请求
      final request = await (_db.select(_db.friendRequests)..where((tbl) => tbl.requestId.equals(requestId))).getSingleOrNull();

      if (request == null) {
        throw '未找到好友请求';
      }

      if (request.status != 'PENDING') {
        throw '该请求已处理';
      }

      // 更新请求状态
      await (_db.update(_db.friendRequests)..where((tbl) => tbl.requestId.equals(requestId))).write(FriendRequestsCompanion(
        status: const Value('ACCEPTED'),
        processedAt: Value(DateTime.now()),
      ));

      // 查询发送者信息
      User? sender = await (_db.select(_db.users)..where((tbl) => tbl.userId.equals(request.senderId))).getSingleOrNull();

      // 如果发送者不在联系人列表中,则创建
      if (sender == null) {
        await _db.into(_db.users).insert(UsersCompanion.insert(
              userId: request.senderId,
              name: request.senderId, // 使用userId作为默认名称
              roleId: const Value(0), // 默认角色ID
              isFriend: const Value(true),
            ));
      } else {
        // 更新为朋友状态
        await (_db.update(_db.users)..where((tbl) => tbl.userId.equals(request.senderId))).write(const UsersCompanion(
          isFriend: Value(true),
        ));
      }

      // 向服务器发送接受请求
      if (_communicationService.isInitialized) {
        final protoRequest = ProcessFriendRequestProto()
          ..requestId = requestId
          ..status = FriendRequestStatus.ACCEPTED;

        await _communicationService.emitProto('friend:request:process', protoRequest);
      }

      _logger.i('接受好友请求成功', extra: {
        'event': 'friend:request:process',
        'requestId': requestId,
      });
      return true;
    } catch (error) {
      _logger.e('接受好友请求失败',
          error: error,
          extra: {
            'event': 'friend:request:process',
            'requestId': requestId,
          },
          stackTrace: StackTrace.current);
      return false;
    }
  }

  /// 拒绝好友请求
  /// 拒绝来自指定用户的好友申请
  /// [requestId] - 好友请求ID
  @override
  Future<bool> rejectFriendRequest(String requestId) async {
    try {
      _logger.i('拒绝好友请求', extra: {
        'event': 'friend:request:process',
        'requestId': requestId,
      });

      // 查询请求
      final request = await (_db.select(_db.friendRequests)..where((tbl) => tbl.requestId.equals(requestId))).getSingleOrNull();

      if (request == null) {
        throw '未找到好友请求';
      }

      if (request.status != 'PENDING') {
        throw '该请求已处理';
      }

      // 更新请求状态
      await (_db.update(_db.friendRequests)..where((tbl) => tbl.requestId.equals(requestId))).write(FriendRequestsCompanion(
        status: const Value('REJECTED'),
        processedAt: Value(DateTime.now()),
      ));

      // 向服务器发送拒绝请求
      if (_communicationService.isInitialized) {
        final protoRequest = ProcessFriendRequestProto()
          ..requestId = requestId
          ..status = FriendRequestStatus.REJECTED;

        _communicationService.emitProto('friend:request:process', protoRequest);
      }

      _logger.i('拒绝好友请求成功', extra: {
        'event': 'friend:request:process',
        'requestId': requestId,
      });
      return true;
    } catch (error) {
      _logger.e('拒绝好友请求失败',
          error: error,
          extra: {
            'event': 'friend:request:process',
            'requestId': requestId,
          },
          stackTrace: StackTrace.current);
      return false;
    }
  }

  /// 获取所有好友请求
  /// 返回发送和接收的所有好友请求
  Future<List<FriendRequest>> getAllFriendRequests() async {
    try {
      // 查询好友请求
      final requests = await (_db.select(_db.friendRequests)..where((tbl) => tbl.receiverId.equals(_currentUser.userId) | tbl.senderId.equals(_currentUser.userId))).get();

      _logger.i('获取所有好友请求成功 - ${requests.length} 个请求');
      return requests;
    } catch (error) {
      _logger.e('获取所有好友请求失败', error: error, stackTrace: StackTrace.current);
      return [];
    }
  }

  /// 处理发送好友请求响应
  void _handleFriendRequestSendResponse(FriendRequestProto response) {
    _logger.i('收到发送好友请求响应', extra: {
      'requestId': response.requestId,
      'status': response.status.toString(),
    });

    // 更新本地请求状态
    _updateLocalFriendRequest(response);
  }

  /// 处理好友请求处理响应
  void _handleFriendRequestProcessResponse(FriendRequestProto response) {
    _logger.i('收到好友请求处理响应', extra: {
      'requestId': response.requestId,
      'status': response.status.toString(),
    });

    // 更新本地请求状态
    _updateLocalFriendRequest(response);
  }

  /// 处理收到好友请求通知
  void _handleFriendRequestReceived(FriendRequestProto request) {
    _logger.i('收到好友请求通知', extra: {
      'requestId': request.requestId,
      'senderId': request.senderId,
      'message': request.hasMessage() ? request.message : '',
    });

    // 保存到本地数据库
    _saveIncomingFriendRequest(request);
  }

  /// 处理好友请求处理结果通知
  void _handleFriendRequestProcessed(FriendRequestProto response) {
    _logger.i('收到好友请求处理结果通知', extra: {
      'requestId': response.requestId,
      'status': response.status.toString(),
    });

    // 更新本地请求状态
    _updateLocalFriendRequest(response);

    // 如果请求被接受，添加联系人
    if (response.status == FriendRequestStatus.ACCEPTED) {
      _addContactFromAcceptedRequest(response);
    }
  }

  /// 更新本地好友请求状态
  Future<void> _updateLocalFriendRequest(FriendRequestProto response) async {
    try {
      final request = await (_db.select(_db.friendRequests)..where((tbl) => tbl.requestId.equals(response.requestId))).getSingleOrNull();

      if (request != null) {
        await (_db.update(_db.friendRequests)..where((tbl) => tbl.requestId.equals(response.requestId))).write(FriendRequestsCompanion(
          status: Value(_convertProtoStatus(response.status)),
          processedAt: Value(DateTime.fromMillisecondsSinceEpoch(
            response.hasProcessedAt() ? response.processedAt.toInt() : DateTime.now().millisecondsSinceEpoch,
          )),
        ));
        _logger.d('本地好友请求状态已更新', extra: {'requestId': response.requestId});
      }
    } catch (error) {
      _logger.e('更新本地好友请求状态失败', error: error);
    }
  }

  /// 保存收到的好友请求
  Future<void> _saveIncomingFriendRequest(FriendRequestProto request) async {
    try {
      await _db.into(_db.friendRequests).insertOnConflictUpdate(FriendRequestsCompanion.insert(
            requestId: request.requestId,
            senderId: request.senderId,
            receiverId: _currentUser.userId,
            message: Value(request.hasMessage() ? request.message : null),
            status: _convertProtoStatus(request.status),
            sentAt: DateTime.fromMillisecondsSinceEpoch(
              request.hasSentAt() ? request.sentAt.toInt() : DateTime.now().millisecondsSinceEpoch,
            ),
            processedAt: Value(request.hasProcessedAt() && request.processedAt.toInt() > 0 ? DateTime.fromMillisecondsSinceEpoch(request.processedAt.toInt()) : null),
          ));

      _logger.i('收到的好友请求已保存', extra: {'requestId': request.requestId});
    } catch (error) {
      _logger.e('保存收到的好友请求失败', error: error);
    }
  }

  /// 从被接受的请求中添加联系人
  Future<void> _addContactFromAcceptedRequest(FriendRequestProto response) async {
    try {
      // 这里需要根据response中的信息添加联系人
      // 由于FriendRequestProto可能不包含完整的用户信息，
      // 我们可能需要额外的用户信息查询
      _logger.i('好友请求被接受，准备添加联系人', extra: {'requestId': response.requestId});

      // TODO: 实现根据接受的好友请求添加联系人的逻辑
      // 这可能需要向服务器请求完整的用户信息
    } catch (error) {
      _logger.e('从被接受的请求中添加联系人失败', error: error);
    }
  }

  /// 转换Proto状态到本地状态
  String _convertProtoStatus(FriendRequestStatus protoStatus) {
    switch (protoStatus) {
      case FriendRequestStatus.PENDING:
        return 'PENDING';
      case FriendRequestStatus.ACCEPTED:
        return 'ACCEPTED';
      case FriendRequestStatus.REJECTED:
        return 'REJECTED';
      default:
        return 'PENDING';
    }
  }

  /// 释放资源
  /// 取消订阅,释放所占用的资源
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    _syncContactsStatusController.close();
  }
}
