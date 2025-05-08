import 'package:cc/core/database/database_initializer.dart';
import 'package:cc/core/database/models/user.dart';
import 'package:cc/core/database/models/friend_request.dart';
import 'package:cc/core/database/test_data_manager.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/network/index.dart';
import 'package:cc/core/services/my_user_service.dart';
import 'package:cc/features/contacts/domain/repositories/contacts_repository.dart';
import 'package:isar/isar.dart';
import 'dart:math' as math;

/// ContactsRepository的实现类
class ContactsRepositoryImpl implements ContactsRepository {
  final LogService _logger = LogService('contacts_repository_impl.dart');
  final SocketService _socketService = SocketService.getInstance();

  // 模拟延迟的随机数生成器
  final math.Random _random = math.Random();

  // 获取数据库实例
  Isar get _isar => DatabaseInitializer.isar;

  // 获取用户集合
  IsarCollection<User> get _users => _isar.collection<User>();

  // 获取好友请求集合
  IsarCollection<FriendRequest> get _friendRequests => _isar.collection<FriendRequest>();

  @override
  Future<List<User>> getAllContacts() async {
    try {
      final users = await _users.where().findAll();
      _logger.i('获取联系人列表成功 - ${users.length} 个联系人');
      return users;
    } catch (e) {
      _logger.e('获取联系人列表失败', error: e);
      // 使用TestDataManager获取测试联系人
      return await TestDataManager.getAllTestContacts();
    }
  }

  @override
  Future<List<User>> searchContacts(String query) async {
    if (query.isEmpty) return [];

    try {
      final users = await _users.filter().nameContains(query, caseSensitive: false).or().pinyinContains(query, caseSensitive: false).findAll();
      return users;
    } catch (e) {
      _logger.e('搜索联系人失败', error: e);
      // 使用TestDataManager搜索测试联系人
      return await TestDataManager.searchTestContacts(query);
    }
  }

  @override
  Future<User?> getContactById(String userId) async {
    try {
      final id = int.tryParse(userId);
      if (id == null) return null;

      final user = await _users.get(id);
      return user;
    } catch (e) {
      _logger.e('获取联系人详情失败', error: e);
      // 使用TestDataManager获取测试联系人
      return await TestDataManager.getTestContactById(userId);
    }
  }

  @override
  Future<bool> addContact(User contact) async {
    try {
      await _isar.writeTxn(() async {
        await _users.put(contact);
      });
      return true;
    } catch (e) {
      _logger.e('添加联系人失败', error: e);
      return false;
    }
  }

  @override
  Future<bool> updateContact(User contact) async {
    try {
      await _isar.writeTxn(() async {
        await _users.put(contact);
      });
      return true;
    } catch (e) {
      _logger.e('更新联系人失败', error: e);
      return false;
    }
  }

  @override
  Future<bool> deleteContact(String userId) async {
    try {
      final id = int.tryParse(userId);
      if (id == null) return false;

      await _isar.writeTxn(() async {
        await _users.delete(id);
      });
      return true;
    } catch (e) {
      _logger.e('删除联系人失败', error: e);
      return false;
    }
  }

  @override
  Stream<void> watchContacts() {
    return _users.where().watchLazy();
  }

  @override
  Future<List<User>> syncContacts() async {
    try {
      _logger.i('开始同步联系人列表');

      // 获取当前用户
      final currentUser = await MyUserService.getCurrentUser();
      if (currentUser == null) {
        throw '未找到当前用户信息';
      }

      // 发送同步请求
      if (_socketService.isConnected) {
        _socketService.emit('sync_contacts', {
          'userId': currentUser.userId,
          'token': currentUser.token,
        });
      }

      // 模拟网络延迟
      await Future.delayed(Duration(milliseconds: 500 + _random.nextInt(1000)));

      // 使用TestDataManager获取测试联系人
      final serverContacts = await TestDataManager.getAllTestContacts();

      // 保存到数据库
      await _isar.writeTxn(() async {
        for (final contact in serverContacts) {
          await _users.put(contact);
        }
      });

      _logger.i('联系人同步完成 - ${serverContacts.length} 个联系人');
      return serverContacts;
    } catch (e) {
      _logger.e('同步联系人失败', error: e);
      rethrow;
    }
  }

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
    } catch (e) {
      _logger.e('获取好友请求列表失败', error: e);
      return [];
    }
  }

  @override
  Future<bool> sendFriendRequest(String userId, String message) async {
    try {
      _logger.i('发送好友请求', extra: {'targetUserId': userId, 'message': message});

      // 获取当前用户
      final currentUser = await MyUserService.getCurrentUser();
      if (currentUser == null) {
        throw '未找到当前用户信息';
      }

      // 获取目标用户
      final targetUser = await getContactById(userId);
      if (targetUser == null) {
        throw '未找到目标用户';
      }

      // 检查是否已发送请求
      final existingRequest =
          await _friendRequests.filter().senderIdEqualTo(currentUser.userId).and().receiverIdEqualTo(userId).and().statusEqualTo(FriendRequestStatus.pending).findFirst();

      if (existingRequest != null) {
        throw '已向该用户发送过好友请求';
      }

      // 创建好友请求
      final request = FriendRequest()
        ..requestId = 'req_${DateTime.now().millisecondsSinceEpoch}'
        ..senderId = currentUser.userId
        ..senderName = currentUser.name
        ..senderAvatar = currentUser.avatar
        ..receiverId = userId
        ..message = message
        ..status = FriendRequestStatus.pending
        ..createdAt = DateTime.now();

      // 保存到数据库
      await _isar.writeTxn(() async {
        await _friendRequests.put(request);
      });

      // 模拟发送请求到服务器
      if (_socketService.isConnected) {
        _socketService.emit('friend_request', {
          'senderId': currentUser.userId,
          'receiverId': userId,
          'message': message,
        });
      }

      // 模拟网络延迟
      await Future.delayed(Duration(milliseconds: 300 + _random.nextInt(700)));

      _logger.i('发送好友请求成功');
      return true;
    } catch (e) {
      _logger.e('发送好友请求失败', error: e);
      return false;
    }
  }

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

      // 如果发送者不在联系人列表中，则创建
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
      if (_socketService.isConnected) {
        _socketService.emit('accept_friend_request', {
          'requestId': requestId,
        });
      }

      // 模拟网络延迟
      await Future.delayed(Duration(milliseconds: 300 + _random.nextInt(700)));

      _logger.i('接受好友请求成功');
      return true;
    } catch (e) {
      _logger.e('接受好友请求失败', error: e);
      return false;
    }
  }

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
      if (_socketService.isConnected) {
        _socketService.emit('reject_friend_request', {
          'requestId': requestId,
        });
      }

      // 模拟网络延迟
      await Future.delayed(Duration(milliseconds: 300 + _random.nextInt(700)));

      _logger.i('拒绝好友请求成功');
      return true;
    } catch (e) {
      _logger.e('拒绝好友请求失败', error: e);
      return false;
    }
  }

  // 生成模拟联系人数据
  List<User> _generateMockContacts() {
    final contacts = <User>[];
    final names = ['张三', '李四', '王五', '赵六', '钱七', '孙八', '周九', '吴十', '郑一', '王二', '陈三', '李想', '张明', '刘洋', '王芳', '李娜', '赵丽', '钱江', '孙红', '周伟', '吴刚', '郑强', '王勇', '陈磊'];

    // 生成20-30个随机联系人
    final count = 20 + _random.nextInt(11);

    for (int i = 0; i < count; i++) {
      final id = 1000 + i;
      final name = names[_random.nextInt(names.length)];

      final user = User()
        ..id = id
        ..userId = id.toString()
        ..name = name
        ..pinyin = name // 在实际应用中应该计算拼音
        ..phone = '138${(10000000 + i).toString().padLeft(8, '0')}'
        ..email = 'user$i@example.com'
        ..status = _random.nextBool() ? 'online' : 'offline';

      contacts.add(user);
    }

    return contacts;
  }
}
