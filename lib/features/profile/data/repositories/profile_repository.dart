import 'dart:io';
import 'package:isar/isar.dart';
import 'package:fixnum/fixnum.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/constants/app_config.dart';
import 'package:cc/core/database/models/my_user.dart';
import 'package:cc/core/proto/generated/user.pb.dart';
import 'package:cc/core/database/database_initializer.dart';

class ProfileRepository {
  final _logger = LogService.instance;
  late final Isar _db;

  /// 初始化数据库
  Future<void> init() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      _db = await Isar.open(
        [MyUserSchema],
        directory: dir.path,
      );
      _logger.i('ProfileRepository 数据库初始化成功');
    } catch (e) {
      _logger.e('ProfileRepository 数据库初始化失败', error: e);
      rethrow;
    }
  }

  /// 获取当前用户信息
  Future<MyUserProto?> getCurrentUser() async {
    try {
      final users = await _db.myUsers.where().findAll();
      if (users.isEmpty) {
        return null;
      }
      
      // 转换为 MyUserProto
      final user = users.first;
      return MyUserProto(
        userId: user.userId,
        token: user.token,
        name: user.name,
        avatar: user.avatar,
        phone: user.phone,
        email: user.email,
        tokenExpireTime: user.tokenExpireTime != null ? Int64(user.tokenExpireTime!.millisecondsSinceEpoch) : null,
        lastLoginTime: user.lastLoginTime != null ? Int64(user.lastLoginTime!.millisecondsSinceEpoch) : null,
        status: user.status,
      );
    } catch (e) {
      _logger.e('获取用户信息失败', error: e);
      rethrow;
    }
  }

  /// 保存用户信息
  Future<void> saveUser(MyUserProto user) async {
    try {
      await _db.writeTxn(() async {
        await _db.myUsers.clear(); // 清除旧数据
        
        // 创建 MyUser 对象并保存
        final myUser = MyUser()
          ..userId = user.userId
          ..token = user.token
          ..name = user.name
          ..avatar = user.avatar
          ..phone = user.phone
          ..email = user.email
          ..tokenExpireTime = user.hasTokenExpireTime() ? 
              DateTime.fromMillisecondsSinceEpoch(user.tokenExpireTime.toInt()) : null
          ..lastLoginTime = user.hasLastLoginTime() ? 
              DateTime.fromMillisecondsSinceEpoch(user.lastLoginTime.toInt()) : null
          ..status = user.status;
        
        await _db.myUsers.put(myUser); // 保存新数据
      });
      _logger.i('用户信息保存成功', extra: {'userId': user.userId});
    } catch (e) {
      _logger.e('保存用户信息失败', error: e);
      rethrow;
    }
  }

  /// 更新用户信息
  Future<void> updateUserInfo({
    String? nickname,
    String? avatar,
    String? status,
  }) async {
    try {
      final currentUser = await getCurrentUser();
      if (currentUser == null) {
        throw Exception('用户未登录');
      }

      final updatedUser = MyUserProto(
        userId: currentUser.userId,
        token: currentUser.token,
        name: nickname ?? currentUser.name,
        avatar: avatar ?? currentUser.avatar,
        phone: currentUser.phone,
        email: currentUser.email,
        tokenExpireTime: currentUser.tokenExpireTime,
        lastLoginTime: currentUser.lastLoginTime,
        status: status ?? currentUser.status,
      );

      await saveUser(updatedUser);
      _logger.i('用户信息更新成功', extra: {'userId': currentUser.userId});
    } catch (e) {
      _logger.e('更新用户信息失败', error: e);
      rethrow;
    }
  }

  /// 获取服务器配置
  String getServerUrl() {
    return AppConfig().serverUrl;
  }

  /// 更新服务器配置
  Future<void> updateServerUrl(String url) async {
    try {
      AppConfig().serverUrl = url;
      _logger.i('服务器URL已更新', extra: {'serverUrl': url});
    } catch (e) {
      _logger.e('更新服务器URL失败', error: e);
      rethrow;
    }
  }

  /// 重置所有数据
  Future<void> resetAllData() async {
    try {
      _logger.i('开始重置数据');

      // 关闭数据库
      if (DatabaseInitializer.isInitialized) {
        await DatabaseInitializer.close();
      }

      // 获取应用文档目录
      final appDocDir = await getApplicationDocumentsDirectory();

      // 删除数据库文件
      _logger.i('数据库文件目录: $appDocDir');
      final isarFiles = await appDocDir.list().where((entity) => entity.path.endsWith('.isar') || entity.path.endsWith('.isar.lock')).toList();

      for (final file in isarFiles) {
        await file.delete();
        _logger.i('删除数据库文件: ${file.path}');
      }

      // 删除媒体文件
      final mediaDir = Directory('${appDocDir.path}/media');
      if (await mediaDir.exists()) {
        await mediaDir.delete(recursive: true);
        _logger.i('媒体文件已删除');
      }

      _logger.i('数据重置完成');
    } catch (e) {
      _logger.e('重置数据失败', error: e);
      rethrow;
    }
  }

  /// 关闭数据库
  Future<void> close() async {
    try {
      await _db.close();
      _logger.i('ProfileRepository 数据库已关闭');
    } catch (e) {
      _logger.e('关闭数据库失败', error: e);
      rethrow;
    }
  }
}
