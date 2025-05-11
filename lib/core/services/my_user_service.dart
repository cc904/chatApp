import 'package:cc/core/database/database_initializer.dart';
import 'package:cc/core/database/models/my_user.dart';
import 'package:cc/core/proto/generated/auth.pb.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:isar/isar.dart';

/// 当前用户服务
/// 负责处理当前登录用户信息的存储和查询
class MyUserService {
  static final _logger = LogService.instance;

  /// 保存当前用户信息
  static Future<MyUser?> saveCurrentUser({
    required String userId,
    required String token,
    required String name,
    String? avatar,
    String? phone,
    String? email,
    DateTime? tokenExpireTime,
  }) async {
    try {
      _logger.i('保存当前用户信息', extra: {'userId': userId, 'name': name});

      final isar = DatabaseInitializer.isar;

      // 查询现有的当前用户信息
      final existingUser = await isar.myUsers.where().findFirst();

      // 创建或更新用户信息
      final myUser = existingUser ?? MyUser();
      myUser.userId = userId;
      myUser.token = token;
      myUser.name = name;
      myUser.avatar = avatar;
      myUser.phone = phone;
      myUser.email = email;
      myUser.tokenExpireTime = tokenExpireTime;
      myUser.lastLoginTime = DateTime.now();
      myUser.status = 'online';

      // 保存到数据库
      await isar.writeTxn(() async {
        await isar.myUsers.put(myUser);
      });

      _logger.i('当前用户信息保存成功', extra: {'id': myUser.id});
      return myUser;
    } catch (e) {
      _logger.e('保存当前用户信息失败', error: e);
      return null;
    }
  }

  /// 从UserSession创建MyUser对象
  static Future<MyUser?> saveFromUserSession(UserSession session, {String? name}) async {
    try {
      return await saveCurrentUser(
        userId: session.userId,
        token: session.token,
        name: name ?? '我', // 默认昵称
        phone: session.phoneNumber,
        tokenExpireTime: session.expireTime.toInt() > 0 ? DateTime.fromMillisecondsSinceEpoch(session.expireTime.toInt()) : null,
      );
    } catch (e) {
      _logger.e('从UserSession创建MyUser失败', error: e);
      return null;
    }
  }

  /// 获取当前用户信息
  static Future<MyUser?> getCurrentUser() async {
    try {
      final isar = DatabaseInitializer.isar;
      return await isar.myUsers.where().findFirst();
    } catch (e) {
      _logger.e('获取当前用户信息失败', error: e);
      return null;
    }
  }

  /// 检查用户是否登录
  static Future<bool> isLoggedIn() async {
    final currentUser = await getCurrentUser();
    return currentUser != null;
  }

  /// 检查令牌是否有效
  static Future<bool> isTokenValid() async {
    final currentUser = await getCurrentUser();
    if (currentUser == null || currentUser.token.isEmpty) {
      return false;
    }

    // 检查令牌是否过期
    if (currentUser.tokenExpireTime != null) {
      return currentUser.tokenExpireTime!.isAfter(DateTime.now());
    }

    return true; // 如果没有过期时间,则默认为有效
  }

  /// 更新当前用户状态
  static Future<bool> updateStatus(String status) async {
    try {
      final currentUser = await getCurrentUser();
      if (currentUser == null) {
        return false;
      }

      currentUser.status = status;

      await DatabaseInitializer.isar.writeTxn(() async {
        await DatabaseInitializer.isar.myUsers.put(currentUser);
      });

      return true;
    } catch (e) {
      _logger.e('更新用户状态失败', error: e);
      return false;
    }
  }

  /// 更新令牌
  static Future<bool> updateToken(String token, {DateTime? expireTime}) async {
    try {
      final currentUser = await getCurrentUser();
      if (currentUser == null) {
        return false;
      }

      currentUser.token = token;
      if (expireTime != null) {
        currentUser.tokenExpireTime = expireTime;
      }

      await DatabaseInitializer.isar.writeTxn(() async {
        await DatabaseInitializer.isar.myUsers.put(currentUser);
      });

      return true;
    } catch (e) {
      _logger.e('更新令牌失败', error: e);
      return false;
    }
  }

  /// 清除当前用户信息（退出登录）
  static Future<bool> clearCurrentUser() async {
    try {
      await DatabaseInitializer.isar.writeTxn(() async {
        await DatabaseInitializer.isar.myUsers.clear();
      });

      _logger.i('当前用户信息已清除');
      return true;
    } catch (e) {
      _logger.e('清除当前用户信息失败', error: e);
      return false;
    }
  }
}
