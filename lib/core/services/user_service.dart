import 'package:cc/core/database/database_initializer.dart';
import 'package:cc/core/database/models/user.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:isar/isar.dart';

/// 用户服务
/// 负责处理联系人信息的存储和查询
class UserService {
  static final _logger = LogService.instance;
  static final _isar = DatabaseInitializer.isar;

  /// 创建联系人
  static Future<User?> createContact({
    required String name,
    String? avatar,
    String? phone,
    String? email,
    String? status,
  }) async {
    try {
      _logger.i('创建联系人', extra: {'name': name});

      // 创建新联系人
      final user = User()
        ..name = name
        ..avatar = avatar
        ..phone = phone
        ..email = email
        ..status = status ?? 'offline';

      // 保存联系人
      await _isar.writeTxn(() async {
        user.id = await _isar.users.put(user);
        user.userId = user.id.toString();
        await _isar.users.put(user);
      });

      _logger.i('联系人创建成功', extra: {'userId': user.userId});
      return user;
    } catch (error) {
      _logger.e('创建联系人失败', error: error, stackTrace: StackTrace.current);
      return null;
    }
  }

  /// 获取联系人列表
  static Future<List<User>> getContacts({int limit = 20, int offset = 0}) async {
    try {
      _logger.i('获取联系人列表', extra: {
        'limit': limit,
        'offset': offset,
      });

      final contacts = await _isar.users.where().sortByName().offset(offset).limit(limit).findAll();

      _logger.i('获取联系人列表成功', extra: {'count': contacts.length});
      return contacts;
    } catch (error) {
      _logger.e('获取联系人列表失败', error: error, stackTrace: StackTrace.current);
      return [];
    }
  }

  /// 获取联系人详情
  static Future<User?> getContact(String userId) async {
    try {
      _logger.i('获取联系人详情', extra: {'userId': userId});

      final id = int.tryParse(userId);
      if (id == null) return null;

      final user = await _isar.users.get(id);
      if (user == null) {
        _logger.w('联系人不存在', extra: {'userId': userId});
        return null;
      }

      _logger.i('获取联系人详情成功');
      return user;
    } catch (error) {
      _logger.e('获取联系人详情失败', error: error, stackTrace: StackTrace.current);
      return null;
    }
  }

  /// 更新联系人信息
  static Future<bool> updateContact(
    String userId, {
    String? name,
    String? avatar,
    String? phone,
    String? email,
    String? status,
  }) async {
    try {
      _logger.i('更新联系人信息', extra: {
        'userId': userId,
        'name': name,
        'avatar': avatar,
        'phone': phone,
        'email': email,
        'status': status,
      });

      final id = int.tryParse(userId);
      if (id == null) return false;

      final success = await _isar.writeTxn(() async {
        final user = await _isar.users.get(id);
        if (user == null) return false;

        if (name != null) user.name = name;
        if (avatar != null) user.avatar = avatar;
        if (phone != null) user.phone = phone;
        if (email != null) user.email = email;
        if (status != null) user.status = status;

        await _isar.users.put(user);
        return true;
      });

      _logger.i('更新联系人信息成功');
      return success;
    } catch (error) {
      _logger.e('更新联系人信息失败', error: error, stackTrace: StackTrace.current);
      return false;
    }
  }

  /// 删除联系人
  static Future<bool> deleteContact(String userId) async {
    try {
      _logger.i('删除联系人', extra: {'userId': userId});

      final id = int.tryParse(userId);
      if (id == null) return false;

      final success = await _isar.writeTxn(() async {
        final user = await _isar.users.get(id);
        if (user == null) return false;

        await _isar.users.delete(id);
        return true;
      });

      _logger.i('删除联系人成功');
      return success;
    } catch (error) {
      _logger.e('删除联系人失败', error: error, stackTrace: StackTrace.current);
      return false;
    }
  }
}
