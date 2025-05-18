import 'package:cc/core/database/models/user.dart';
import 'package:isar/isar.dart';

class ContactService {
  final Isar _db;

  ContactService(this._db);

  /// 获取所有联系人
  Future<List<User>> getContacts() async {
    try {
      final contacts = await _db.users.where().findAll();
      return contacts;
    } catch (e) {
      throw Exception('获取联系人失败: $e');
    }
  }

  /// 根据ID获取联系人
  Future<User?> getContactById(String userId) async {
    try {
      return await _db.users.filter().userIdEqualTo(userId).findFirst();
    } catch (e) {
      throw Exception('获取联系人失败: $e');
    }
  }

  /// 保存联系人
  Future<void> saveContact(User user) async {
    try {
      await _db.writeTxn(() async {
        await _db.users.put(user);
      });
    } catch (e) {
      throw Exception('保存联系人失败: $e');
    }
  }

  /// 删除联系人
  Future<void> deleteContact(String userId) async {
    try {
      await _db.writeTxn(() async {
        await _db.users.filter().userIdEqualTo(userId).deleteAll();
      });
    } catch (e) {
      throw Exception('删除联系人失败: $e');
    }
  }

  /// 搜索联系人
  Future<List<User>> searchContacts(String query) async {
    try {
      final contacts = await _db.users.filter().nameContains(query, caseSensitive: false).or().phoneContains(query, caseSensitive: false).findAll();
      return contacts;
    } catch (e) {
      throw Exception('搜索联系人失败: $e');
    }
  }

  /// 清除所有联系人
  Future<void> clearContacts() async {
    try {
      await _db.writeTxn(() async {
        await _db.users.clear();
      });
    } catch (e) {
      throw Exception('清除联系人失败: $e');
    }
  }
}
