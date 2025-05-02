import 'package:cc/core/database/database_initializer.dart';
import 'package:cc/core/database/models/user.dart';
import 'package:cc/features/contacts/domain/repositories/contacts_repository.dart';
import 'package:isar/isar.dart';
import 'package:logger/logger.dart';

/// ContactsRepository的实现类
class ContactsRepositoryImpl implements ContactsRepository {
  final Logger _logger = Logger();

  // 获取当前数据库实例
  Isar get _isar => DatabaseInitializer.isar;

  // 获取用户集合
  IsarCollection<User> get _users => _isar.collection<User>();

  @override
  Future<List<User>> getAllContacts() async {
    try {
      // 查询所有标记为朋友的用户
      return await _users.where().filter().isFriendEqualTo(true).sortByName().findAll();
    } catch (e) {
      _logger.e('获取联系人失败', error: e);
      return [];
    }
  }

  @override
  Future<List<User>> searchContacts(String keyword) async {
    if (keyword.isEmpty) {
      return getAllContacts();
    }

    try {
      // 搜索姓名、电话或邮箱包含关键词的联系人
      final query = _users
          .where()
          .filter()
          .isFriendEqualTo(true)
          .and()
          .group((q) => q.nameContains(keyword, caseSensitive: false).or().phoneContains(keyword).or().emailContains(keyword, caseSensitive: false));

      return await query.sortByName().findAll();
    } catch (e) {
      _logger.e('搜索联系人失败', error: e);
      return [];
    }
  }

  @override
  Future<User?> getContactById(String userId) async {
    try {
      final id = int.tryParse(userId);
      if (id == null) return null;

      final user = await _users.get(id);
      if (user == null || !user.isFriend) return null;

      return user;
    } catch (e) {
      _logger.e('获取联系人失败', error: e);
      return null;
    }
  }

  @override
  Future<void> addContact(User user) async {
    try {
      // 确保用户标记为朋友
      user.isFriend = true;

      await _isar.writeTxn(() async {
        user.id = await _users.put(user);
        DatabaseInitializer.syncIds(user);
        await _users.put(user);
      });
    } catch (e) {
      _logger.e('添加联系人失败', error: e);
      rethrow;
    }
  }

  @override
  Future<void> deleteContact(String userId) async {
    try {
      final id = int.tryParse(userId);
      if (id == null) return;

      final user = await _users.get(id);
      if (user == null) return;

      // 将用户的isFriend设为false，而不是真正删除
      user.isFriend = false;

      await _isar.writeTxn(() async {
        await _users.put(user);
      });
    } catch (e) {
      _logger.e('删除联系人失败', error: e);
      rethrow;
    }
  }

  @override
  Future<void> updateContact(User user) async {
    try {
      // 确保用户存在
      if (user.id <= 0) {
        throw Exception('无效的用户ID');
      }

      await _isar.writeTxn(() async {
        DatabaseInitializer.syncIds(user);
        await _users.put(user);
      });
    } catch (e) {
      _logger.e('更新联系人失败', error: e);
      rethrow;
    }
  }

  @override
  Stream<void> watchContacts() {
    return _users.where().filter().isFriendEqualTo(true).watchLazy();
  }
}
