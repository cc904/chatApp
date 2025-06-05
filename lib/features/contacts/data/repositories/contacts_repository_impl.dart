import 'dart:async';
import 'package:isar/isar.dart';
import 'package:cc/core/database/database_initializer.dart';
import 'package:cc/core/database/models/current_user.dart';
import 'package:cc/core/database/models/user.dart' as db_user;
import 'package:cc/core/database/models/friend_request.dart'
    as db_friend_request;
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/services/communication_service.dart';
import 'package:cc/core/proto/generated/user.pb.dart';
import 'package:cc/core/proto/generated/contacts.pb.dart';

import 'package:cc/features/contacts/domain/repositories/contacts_repository.dart';

/// ContactsRepository的实现类
/// 负责管理联系人数据、实现联系人相关的业务逻辑
class ContactsRepositoryImpl implements ContactsRepository {
  final LogService _logger = LogService.instance;
  final CommunicationService _communicationService = CommunicationService();
  final CurrentUser _currentUser;

  // 获取数据库实例
  Isar get _isar => DatabaseInitializer.isar;

  // 获取用户集合
  IsarCollection<db_user.User> get _users => _isar.collection<db_user.User>();

  // 获取好友请求集合
  IsarCollection<db_friend_request.FriendRequest> get _friendRequests =>
      _isar.collection<db_friend_request.FriendRequest>();

  // 事件订阅管理
  final List<StreamSubscription> _subscriptions = [];

  // 同步状态流
  final _syncContactsStatusController =
      StreamController<ContactsSyncStatus>.broadcast();
  @override
  Stream<ContactsSyncStatus> get syncStatusStream =>
      _syncContactsStatusController.stream;

  // 构造函数
  ContactsRepositoryImpl({required CurrentUser currentUser})
      : _currentUser = currentUser {
    _logger.x('ContactsRepositoryImpl 初始化');
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
  void _handleContactsSyncedEvent(UserCollection data) {
    try {
      _logger.i('收到联系人同步事件', extra: {'count': data.users.length});

      // 使用 fromProto 方法将 UserProto 转换为 User 对象
      final List<db_user.User> contacts = data.users.map((contact) {
        final user = db_user.User.fromProto(contact);
        return user;
      }).toList();

      // 保存到数据库
      _isar.writeTxn(() async {
        for (final contact in contacts) {
          await _users.put(contact);
        }
      });

      // 通知同步成功
      _syncContactsStatusController.add(ContactsSyncStatus.success);

      _logger.i('联系人同步数据处理完成', extra: {'count': contacts.length});
    } catch (error) {
      _logger.e('处理联系人同步事件失败', error: error, stackTrace: StackTrace.current);
      _syncContactsStatusController.add(ContactsSyncStatus.error);
    }
  }

  /// 处理联系人同步结果事件 - 使用 Protocol Buffer 类型
  void _handleContactsSyncResultProto(SyncContactsResponse response) {
    try {
      _logger
          .i('收到联系人同步结果事件', extra: {'contactsCount': response.contacts.length});

      if (response.contacts.isEmpty) {
        _logger.i('联系人列表为空，这可能是新用户或同步过程中的正常状态');
        // 通知同步成功（即使列表为空）
        _syncContactsStatusController.add(ContactsSyncStatus.success);
        return;
      }

      // 使用 fromProto 方法将 UserProto 转换为 User 对象
      final List<db_user.User> contacts = response.contacts.map((contact) {
        final user = db_user.User.fromProto(contact);
        return user;
      }).toList();

      // 保存到数据库
      _isar.writeTxn(() async {
        for (final contact in contacts) {
          // 检查是否已存在相同userId的联系人
          final existingUser =
              await _users.filter().userIdEqualTo(contact.userId).findFirst();
          if (existingUser != null) {
            // 更新现有联系人信息
            existingUser
              ..name = contact.name
              ..avatar = contact.avatar
              ..phone = contact.phone
              ..email = contact.email
              ..pinyin = contact.pinyin; // 使用contact中的拼音
            await _users.put(existingUser);
          } else {
            // 添加新联系人
            await _users.put(contact);
          }
        }
      });

      // 通知同步成功
      _syncContactsStatusController.add(ContactsSyncStatus.success);

      _logger.i('联系人同步数据处理完成', extra: {'count': contacts.length});
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
      final user = await _users.filter().userIdEqualTo(userId).findFirst();
      if (user != null) {
        await _isar.writeTxn(() async {
          user.status = isOnline ? 'online' : 'offline';
          user.lastActiveTime = DateTime.now();
          await _users.put(user);
        });

        _logger.i('已更新用户在线状态', extra: {'userId': userId, 'isOnline': isOnline});
      }
    } catch (error) {
      _logger.e('更新用户在线状态失败', error: error, stackTrace: StackTrace.current);
    }
  }

  /// 获取所有联系人
  /// 返回数据库中的所有联系人列表
  @override
  Future<List<db_user.User>> getAllContacts() async {
    try {
      // 返回本地数据库中的联系人列表
      final users = await _users.where().findAll();
      _logger.i('从本地数据库中获取 - ${users.length} 个联系人');
      return users;
    } catch (error) {
      _logger.e('从本地数据库中获取联系人列表失败',
          error: error, stackTrace: StackTrace.current);
      return [];
    }
  }

  /// 搜索联系人
  /// 根据查询词搜索联系人,可匹配名称、拼音等字段
  /// [query] - 搜索关键词
  @override
  Future<List<db_user.User>> searchContacts(String query) async {
    if (query.isEmpty) return [];

    try {
      final users = await _users
          .filter()
          .nameContains(query, caseSensitive: false)
          .or()
          .pinyinContains(query, caseSensitive: false)
          .findAll();
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
  Future<db_user.User?> getContactById(String userId) async {
    try {
      // 使用userId字段查询，而不是尝试转换为整数ID
      return await _users.filter().userIdEqualTo(userId).findFirst();
    } catch (error) {
      _logger.e('获取联系人详情失败', error: error, stackTrace: StackTrace.current);
      return null;
    }
  }

  /// 添加联系人
  /// 将联系人保存到数据库
  /// [contact] - 要添加的联系人对象
  @override
  Future<bool> addContact(db_user.User contact) async {
    try {
      await _isar.writeTxn(() async {
        await _users.put(contact);
      });
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
  Future<bool> updateContact(db_user.User contact) async {
    try {
      await _isar.writeTxn(() async {
        await _users.put(contact);
      });
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
      // 使用userId字段查询，而不是尝试转换为整数ID
      final contact = await _users.filter().userIdEqualTo(userId).findFirst();
      if (contact == null) return false;

      await _isar.writeTxn(() async {
        // 使用联系人的Isar ID删除
        await _users.delete(contact.id);
      });
      return true;
    } catch (error) {
      _logger.e('删除联系人失败', error: error, stackTrace: StackTrace.current);
      return false;
    }
  }

  /// 监听联系人变化
  /// 返回联系人列表变化的流
  @override
  Stream<void> watchContacts() {
    return _users.where().watchLazy();
  }

  /// 同步联系人
  /// 从服务器同步最新的联系人数据
  /// 该方法只发送同步请求，不返回联系人列表
  /// 联系人数据将通过事件通知并由状态管理系统更新UI
  @override
  Future<void> syncContacts() async {
    try {
      // 通知开始同步
      _syncContactsStatusController.add(ContactsSyncStatus.syncing);
      _logger.i('开始联系人同步流程');

      // 验证当前用户信息
      if (_currentUser.userId.isEmpty || _currentUser.token.isEmpty) {
        _logger.e('当前用户信息不完整，无法同步联系人', extra: {
          'userId': _currentUser.userId,
          'hasToken': _currentUser.token.isNotEmpty
        });
        _syncContactsStatusController.add(ContactsSyncStatus.error);
        return;
      }

      if (_communicationService.isInitialized) {
        // 发送请求
        _communicationService.emitProto('contact:sync', SyncContactsRequest());
        _logger.i('联系人同步请求已发送');

        // 创建一个变量来跟踪同步状态
        bool isSyncComplete = false;

        // 添加一个临时监听器来检测同步状态变化
        final syncSubscription =
            _syncContactsStatusController.stream.listen((status) {
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
  Future<List<db_friend_request.FriendRequest>> getFriendRequests() async {
    try {
      // 查询好友请求
      final requests = await _friendRequests
          .filter()
          .receiverIdEqualTo(_currentUser.userId)
          .sortByCreatedAtDesc()
          .findAll();

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
      _logger.i('发送好友请求',
          extra: {'targetUserId': targetUserId, 'message': message});

      // 获取当前用户

      // 获取目标用户
      final targetUser = await getContactById(targetUserId);
      if (targetUser == null) {
        throw '未找到目标用户';
      }

      // 检查是否已发送请求
      final existingRequest = await _friendRequests
          .filter()
          .senderIdEqualTo(_currentUser.userId)
          .and()
          .receiverIdEqualTo(targetUserId)
          .and()
          .statusEqualTo(db_friend_request.FriendRequestStatus.pending)
          .findFirst();

      if (existingRequest != null) {
        throw '已向该用户发送过好友请求';
      }

      // 创建好友请求
      final request = db_friend_request.FriendRequest()
        ..requestId = 'req_${DateTime.now().millisecondsSinceEpoch}'
        ..senderId = _currentUser.userId
        ..senderName = _currentUser.name
        ..senderAvatar = _currentUser.avatar
        ..receiverId = targetUserId
        ..message = message
        ..status = db_friend_request.FriendRequestStatus.pending
        ..createdAt = DateTime.now();

      // 保存到数据库
      await _isar.writeTxn(() async {
        await _friendRequests.put(request);
      });

      // 发送请求到服务器
      if (_communicationService.isInitialized) {
        final protoRequest = SendFriendRequestProto()
          ..senderId = _currentUser.userId
          ..receiverId = targetUserId
          ..message = message;

        await _communicationService.emitProto('friend:request', protoRequest);
      }

      _logger.i('发送好友请求成功');
      return true;
    } catch (error) {
      _logger.e('发送好友请求失败', error: error, stackTrace: StackTrace.current);
      return false;
    }
  }

  /// 接受好友请求
  /// 接受来自指定用户的好友申请
  /// [requestId] - 好友请求ID
  @override
  Future<bool> acceptFriendRequest(String requestId) async {
    try {
      _logger.i('接受好友请求', extra: {'requestId': requestId});

      // 查询请求
      final request = await _friendRequests
          .filter()
          .requestIdEqualTo(requestId)
          .findFirst();

      if (request == null) {
        throw '未找到好友请求';
      }

      if (request.status != db_friend_request.FriendRequestStatus.pending) {
        throw '该请求已处理';
      }

      // 更新请求状态
      request.status = db_friend_request.FriendRequestStatus.accepted;
      request.processedAt = DateTime.now();

      // 查询发送者信息
      db_user.User? sender =
          await _users.filter().userIdEqualTo(request.senderId).findFirst();

      // 如果发送者不在联系人列表中,则创建
      sender ??= db_user.User()
        ..userId = request.senderId
        ..name = request.senderName
        ..avatar = request.senderAvatar
        ..pinyin = request.senderName;

      // 保存更改
      await _isar.writeTxn(() async {
        await _friendRequests.put(request);
        // 确保sender不为空
        if (sender != null) {
          sender.id = await _users.put(sender);
        }
      });

      // 向服务器发送接受请求
      if (_communicationService.isInitialized) {
        final protoRequest = ProcessFriendRequestProto()
          ..requestId = requestId
          ..status = FriendRequestStatus.ACCEPTED;

        await _communicationService.emitProto(
            'friend:request:accept', protoRequest);
      }

      _logger.i('接受好友请求成功');
      return true;
    } catch (error) {
      _logger.e('接受好友请求失败', error: error, stackTrace: StackTrace.current);
      return false;
    }
  }

  /// 拒绝好友请求
  /// 拒绝来自指定用户的好友申请
  /// [requestId] - 好友请求ID
  @override
  Future<bool> rejectFriendRequest(String requestId) async {
    try {
      _logger.i('拒绝好友请求', extra: {'requestId': requestId});

      // 查询请求
      final request = await _friendRequests
          .filter()
          .requestIdEqualTo(requestId)
          .findFirst();

      if (request == null) {
        throw '未找到好友请求';
      }

      if (request.status != db_friend_request.FriendRequestStatus.pending) {
        throw '该请求已处理';
      }

      // 更新请求状态
      request.status = db_friend_request.FriendRequestStatus.rejected;
      request.processedAt = DateTime.now();

      // 保存更改
      await _isar.writeTxn(() async {
        await _friendRequests.put(request);
      });

      // 向服务器发送拒绝请求
      if (_communicationService.isInitialized) {
        final protoRequest = ProcessFriendRequestProto()
          ..requestId = requestId
          ..status = FriendRequestStatus.REJECTED;

        _communicationService.emitProto('friend:request:reject', protoRequest);
      }

      _logger.i('拒绝好友请求成功');
      return true;
    } catch (error) {
      _logger.e('拒绝好友请求失败', error: error, stackTrace: StackTrace.current);
      return false;
    }
  }

  /// 获取所有好友请求
  /// 返回发送和接收的所有好友请求
  Future<List<db_friend_request.FriendRequest>> getAllFriendRequests() async {
    try {
      // 查询好友请求
      final requests = await _friendRequests
          .filter()
          .receiverIdEqualTo(_currentUser.userId)
          .or()
          .senderIdEqualTo(_currentUser.userId)
          .findAll();

      _logger.i('获取所有好友请求成功 - ${requests.length} 个请求');
      return requests;
    } catch (error) {
      _logger.e('获取所有好友请求失败', error: error, stackTrace: StackTrace.current);
      return [];
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
