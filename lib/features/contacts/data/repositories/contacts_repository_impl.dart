import 'package:cc/core/database/database_initializer.dart';
import 'package:cc/core/database/models/user.dart';
import 'package:cc/features/contacts/domain/repositories/contacts_repository.dart';
import 'package:isar/isar.dart';
import 'package:cc/core/services/log_service.dart';

/// ContactsRepository的实现类
class ContactsRepositoryImpl implements ContactsRepository {
  final _logger = LogService('contacts_repository_impl.dart');

  // 获取当前数据库实例
  Isar get _isar => DatabaseInitializer.isar;

  // 获取用户集合
  IsarCollection<User> get _users => _isar.collection<User>();

  @override
  Future<List<User>> getAllContacts() async {
    try {
      // 查询所有联系人
      return await _users.where().sortByName().findAll();
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
      final query = _users.where().filter().nameContains(keyword, caseSensitive: false).or().phoneContains(keyword).or().emailContains(keyword, caseSensitive: false);

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
      if (user == null) return null;

      return user;
    } catch (e) {
      _logger.e('获取联系人失败', error: e);
      return null;
    }
  }

  @override
  Future<void> addContact(User contact) async {
    try {
      await _isar.writeTxn(() async {
        contact.id = await _users.put(contact);
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

      await _isar.writeTxn(() async {
        await _users.delete(id);
      });
    } catch (e) {
      _logger.e('删除联系人失败', error: e);
      rethrow;
    }
  }

  @override
  Future<void> updateContact(User contact) async {
    try {
      await _isar.writeTxn(() async {
        await _users.put(contact);
      });
    } catch (e) {
      _logger.e('更新联系人失败', error: e);
      rethrow;
    }
  }

  @override
  Stream<void> watchContacts() {
    return _users.where().watchLazy();
  }
}
