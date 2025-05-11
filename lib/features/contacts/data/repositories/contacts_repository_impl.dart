import 'package:cc/core/database/database_initializer.dart';
import 'package:cc/core/database/models/user.dart';
import 'package:cc/core/database/models/friend_request.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/services/communication_service.dart';
import 'package:cc/core/services/my_user_service.dart';
import 'package:cc/features/contacts/domain/repositories/contacts_repository.dart';
import 'package:isar/isar.dart';
import 'dart:async';
import 'package:cc/core/proto/generated/contacts.pb.dart' as proto;
import 'package:cc/core/proto/generated/contacts.pbenum.dart' as proto_enum;
import 'package:cc/core/proto/generated/user.pb.dart' as user_proto;

/// ContactsRepository的实现类
/// 负责管理联系人数据、实现联系人相关的业务逻辑
class ContactsRepositoryImpl implements ContactsRepository {
  final LogService _logger = LogService.instance;
  final CommunicationService _communicationService = CommunicationService();

  // 获取数据库实例
  Isar get _isar => DatabaseInitializer.isar;

  // 获取用户集合
  IsarCollection<User> get _users => _isar.collection<User>();

  // 获取好友请求集合
  IsarCollection<FriendRequest> get _friendRequests => _isar.collection<FriendRequest>();

  // 事件订阅管理
  final List<StreamSubscription> _subscriptions = [];

  // 构造函数
  ContactsRepositoryImpl() {
    _initializeSubscriptions();
  }

  /// 初始化订阅
  /// 订阅通信服务提供的事件流
  void _initializeSubscriptions() {
    if (!_communicationService.isInitialized) return;

    // 订阅用户在线状态事件
    _subscriptions.add(_communicationService.onProto<user_proto.UserStatusUpdate>('user_online').listen((data) {
      if (data.hasUserId()) {
        _updateUserOnlineStatus(data.userId, true);
      }
    }));

    _subscriptions.add(_communicationService.onProto<user_proto.UserStatusUpdate>('user_offline').listen((data) {
      if (data.hasUserId()) {
        _updateUserOnlineStatus(data.userId, false);
      }
    }));

    // 订阅联系人同步事件
    _subscriptions.add(_communicationService.onProto<user_proto.UserCollection>('contacts_synced').listen(_handleContactsSyncedEvent));

    // 可以添加其他联系人相关事件的订阅
  }

  /// 处理联系人同步完成事件
  void _handleContactsSyncedEvent(user_proto.UserCollection data) {
    try {
      _logger.i('收到联系人同步事件', extra: {'count': data.users.length});

      // 解析联系人数据并保存到数据库
      final List<User> contacts = data.users.map((contact) {
        return User()
          ..userId = contact.userId
          ..name = contact.name
          ..avatar = contact.avatar
          ..phone = contact.phone
          ..email = contact.email
          ..pinyin = contact.pinyin;
      }).toList();

      // 保存到数据库
      _isar.writeTxn(() async {
        for (final contact in contacts) {
          await _users.put(contact);
        }
      });

      _logger.i('联系人同步数据处理完成', extra: {'count': contacts.length});
    } catch (error) {
      _logger.e('处理联系人同步事件失败', error: error, stackTrace: StackTrace.current);
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
  Future<List<User>> getAllContacts() async {
    try {
      // 先从服务器获取最新数据
      final currentUser = await MyUserService.getCurrentUser();
      if (currentUser != null && _communicationService.isInitialized) {
        final syncRequest = proto.SyncContactsRequest()
          ..userId = currentUser.userId
          ..token = currentUser.token;
        await _communicationService.emitProto('sync_contacts', syncRequest);
      }

      // 返回本地数据库中的联系人列表
      final users = await _users.where().findAll();
      _logger.i('获取联系人列表成功 - ${users.length} 个联系人');
      return users;
    } catch (error) {
      _logger.e('获取联系人列表失败', error: error, stackTrace: StackTrace.current);
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
      final users = await _users.filter().nameContains(query, caseSensitive: false).or().pinyinContains(query, caseSensitive: false).findAll();
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
      final id = int.tryParse(userId);
      if (id == null) return null;

      final user = await _users.get(id);
      return user;
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
  Future<bool> updateContact(User contact) async {
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
      final id = int.tryParse(userId);
      if (id == null) return false;

      await _isar.writeTxn(() async {
        await _users.delete(id);
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
  @override
  Future<List<User>> syncContacts() async {
    try {
      _logger.i('开始同步联系人列表');

      // 获取当前用户
      final currentUser = await MyUserService.getCurrentUser();
      if (currentUser == null) {
        throw '未找到当前用户信息';
      }

      // 使用通信服务发送同步请求
      if (_communicationService.isInitialized) {
        final request = proto.SyncContactsRequest()
          ..userId = currentUser.userId
          ..token = currentUser.token;

        _communicationService.emitProto('sync_contacts', request);
      } else {
        _logger.w('通信服务未初始化,无法同步联系人');
      }

      List<User> serverContacts = [];

      _logger.i('使用真实网络同步联系人');
      // 实际情况下,通过上面发送的事件触发服务器返回联系人数据
      // 等待联系人同步结果通过通信服务的事件返回
      // 这里设置一个超时,避免永久等待
      final completer = Completer<List<User>>();
      final timeout = Timer(Duration(seconds: 10), () {
        if (!completer.isCompleted) {
          _logger.w('同步联系人超时');
          completer.complete([]);
        }
      });

      // 获取同步前的联系人数量
      final beforeCount = await _users.count();

      // 等待一段时间后检查联系人是否有增加
      Future.delayed(Duration(seconds: 5), () async {
        final afterCount = await _users.count();
        if (!completer.isCompleted && afterCount > beforeCount) {
          final contacts = await getAllContacts();
          completer.complete(contacts);
          timeout.cancel();
        }
      });

      // 等待服务器返回的联系人数据
      serverContacts = await completer.future;

      return serverContacts;
    } catch (error) {
      _logger.e('同步联系人失败', error: error, stackTrace: StackTrace.current);
      rethrow;
    }
  }

  /// 获取好友请求列表
  /// 获取当前用户收到的所有好友请求
  @override
  Future<List<FriendRequest>> getFriendRequests() async {
    try {
      // 获取当前用户
      final currentUser = await MyUserService.getCurrentUser();
      if (currentUser == null) {
        throw '未找到当前用户信息';
      }

      // 查询好友请求
      final requests = await _friendRequests.filter().receiverIdEqualTo(currentUser.userId).sortByCreatedAtDesc().findAll();

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
      _logger.i('发送好友请求', extra: {'targetUserId': targetUserId, 'message': message});

      // 获取当前用户
      final currentUser = await MyUserService.getCurrentUser();
      if (currentUser == null) {
        throw '未找到当前用户信息';
      }

      // 获取目标用户
      final targetUser = await getContactById(targetUserId);
      if (targetUser == null) {
        throw '未找到目标用户';
      }

      // 检查是否已发送请求
      final existingRequest =
          await _friendRequests.filter().senderIdEqualTo(currentUser.userId).and().receiverIdEqualTo(targetUserId).and().statusEqualTo(FriendRequestStatus.pending).findFirst();

      if (existingRequest != null) {
        throw '已向该用户发送过好友请求';
      }

      // 创建好友请求
      final request = FriendRequest()
        ..requestId = 'req_${DateTime.now().millisecondsSinceEpoch}'
        ..senderId = currentUser.userId
        ..senderName = currentUser.name
        ..senderAvatar = currentUser.avatar
        ..receiverId = targetUserId
        ..message = message
        ..status = FriendRequestStatus.pending
        ..createdAt = DateTime.now();

      // 保存到数据库
      await _isar.writeTxn(() async {
        await _friendRequests.put(request);
      });

      // 发送请求到服务器
      if (_communicationService.isInitialized) {
        final protoRequest = proto.SendFriendRequestProto()
          ..senderId = currentUser.userId
          ..receiverId = targetUserId
          ..message = message;

        _communicationService.emitProto('friend_request', protoRequest);
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
      final request = await _friendRequests.filter().requestIdEqualTo(requestId).findFirst();

      if (request == null) {
        throw '未找到好友请求';
      }

      if (request.status != FriendRequestStatus.pending) {
        throw '该请求已处理';
      }

      // 更新请求状态
      request.status = FriendRequestStatus.accepted;
      request.processedAt = DateTime.now();

      // 查询发送者信息
      User? sender = await _users.filter().userIdEqualTo(request.senderId).findFirst();

      // 如果发送者不在联系人列表中,则创建
      sender ??= User()
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
        final protoRequest = proto.ProcessFriendRequestProto()
          ..requestId = requestId
          ..status = proto_enum.FriendRequestStatus.accepted;

        _communicationService.emitProto('accept_friend_request', protoRequest);
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
      final request = await _friendRequests.filter().requestIdEqualTo(requestId).findFirst();

      if (request == null) {
        throw '未找到好友请求';
      }

      if (request.status != FriendRequestStatus.pending) {
        throw '该请求已处理';
      }

      // 更新请求状态
      request.status = FriendRequestStatus.rejected;
      request.processedAt = DateTime.now();

      // 保存更改
      await _isar.writeTxn(() async {
        await _friendRequests.put(request);
      });

      // 向服务器发送拒绝请求
      if (_communicationService.isInitialized) {
        final protoRequest = proto.ProcessFriendRequestProto()
          ..requestId = requestId
          ..status = proto_enum.FriendRequestStatus.rejected;

        _communicationService.emitProto('reject_friend_request', protoRequest);
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
  Future<List<FriendRequest>> getAllFriendRequests() async {
    try {
      // 获取当前用户
      final currentUser = await MyUserService.getCurrentUser();
      if (currentUser == null) {
        throw '未找到当前用户信息';
      }

      // 查询好友请求
      final requests = await _friendRequests.filter().receiverIdEqualTo(currentUser.userId).or().senderIdEqualTo(currentUser.userId).findAll();

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
  }
}
