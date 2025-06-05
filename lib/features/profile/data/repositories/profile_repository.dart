import 'dart:io';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/constants/app_config.dart';
import 'package:cc/core/database/models/current_user.dart';
import 'package:cc/core/database/database_initializer.dart';

/// 个人资料仓库
///
/// 负责管理用户配置文件数据的持久化存储和检索
/// 使用DatabaseInitializer中的Isar数据库实现本地存储，并处理CurrentUser模型和CurrentUserProto之间的转换
class ProfileRepository {
  final _logger = LogService.instance;

  /// 初始化方法
  ///
  /// 检查DatabaseInitializer是否已初始化
  /// 如果未初始化，则抛出异常，需要先初始化DatabaseInitializer
  Future<void> init() async {
    try {
      if (!DatabaseInitializer.isInitialized) {
        throw Exception('DatabaseInitializer未初始化，请先初始化DatabaseInitializer');
      }
      _logger.i('ProfileRepository 已准备就绪');
    } catch (e) {
      _logger.e('ProfileRepository 初始化失败', error: e);
      rethrow;
    }
  }

  /// 获取当前登录用户信息
  ///
  /// 从DatabaseInitializer的Isar实例中读取CurrentUser记录
  /// 如果没有用户记录，返回null
  ///
  /// 返回值:
  ///   - CurrentUser?: 当前登录用户信息，如果未登录则为null
  Future<CurrentUser?> getCurrentUser() async {
    try {
      if (!DatabaseInitializer.isInitialized) {
        _logger.w('数据库未初始化，无法获取用户信息');
        return null;
      }

      final users =
          await DatabaseInitializer.isar.currentUsers.where().findAll();
      if (users.isEmpty) {
        return null;
      }

      // 直接返回 CurrentUser
      final user = users.first;
      return user;
    } catch (e) {
      _logger.e('获取用户信息失败', error: e);
      return null;
    }
  }

  /// 保存用户信息
  ///
  /// 直接保存CurrentUser对象到数据库
  /// 在保存前会清除所有现有用户数据
  ///
  /// 参数:
  ///   - user: 需要保存的用户信息(CurrentUser类型)
  Future<void> saveUser(CurrentUser user) async {
    try {
      if (!DatabaseInitializer.isInitialized) {
        throw Exception('数据库未初始化，无法保存用户信息');
      }

      await DatabaseInitializer.isar.writeTxn(() async {
        await DatabaseInitializer.isar.currentUsers.clear(); // 清除旧数据
        await DatabaseInitializer.isar.currentUsers.put(user); // 保存新数据
      });
      _logger.i('用户信息保存成功', extra: {'userId': user.userId});
    } catch (e) {
      _logger.e('保存用户信息失败', error: e);
      rethrow;
    }
  }

  /// 更新用户信息
  ///
  /// 允许选择性地更新用户的昵称、头像和状态
  /// 不会更改其他用户属性
  ///
  /// 参数:
  ///   - nickname: 可选，新昵称
  ///   - avatar: 可选，新头像URL
  ///   - status: 可选，新状态信息
  ///
  /// 异常:
  ///   - 如果用户未登录，抛出异常
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

      // 创建更新后的用户对象
      final updatedUser = CurrentUser()
        ..userId = currentUser.userId
        ..token = currentUser.token
        ..name = nickname ?? currentUser.name
        ..avatar = avatar ?? currentUser.avatar
        ..phone = currentUser.phone
        ..email = currentUser.email
        ..tokenExpireTime = currentUser.tokenExpireTime
        ..lastLoginTime = currentUser.lastLoginTime
        ..status = status ?? currentUser.status;

      await saveUser(updatedUser);
      _logger.i('用户信息更新成功', extra: {'userId': currentUser.userId});
    } catch (e) {
      _logger.e('更新用户信息失败', error: e);
      rethrow;
    }
  }

  /// 获取服务器URL
  ///
  /// 从应用程序配置中获取当前的服务器URL
  ///
  /// 返回值:
  ///   - String: 当前配置的服务器URL
  String getServerUrl() {
    return AppConfig().serverUrl;
  }

  /// 更新服务器URL
  ///
  /// 更新应用程序配置中的服务器URL
  ///
  /// 参数:
  ///   - url: 新的服务器URL地址
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
  ///
  /// 完全清除应用程序数据:
  /// 1. 关闭现有数据库连接
  /// 2. 删除所有Isar数据库文件
  /// 3. 删除媒体文件夹及其内容
  ///
  /// 通常用于用户退出登录或应用重置功能
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
      _logger.i('数据库文件目录: ${appDocDir.path}');
      final isarFiles = await appDocDir
          .list()
          .where((entity) =>
              entity.path.endsWith('.isar') ||
              entity.path.endsWith('.isar.lock'))
          .toList();

      for (final file in isarFiles) {
        await file.delete();
        _logger.i('删除数据库文件: ${file.path}');
      }

      // 删除媒体文件夹
      final mediaDir = Directory('${appDocDir.path}/media');
      if (await mediaDir.exists()) {
        await mediaDir.delete(recursive: true);
        _logger.i('删除媒体文件夹: ${mediaDir.path}');
      }

      _logger.i('数据重置完成');
    } catch (e) {
      _logger.e('重置数据失败', error: e);
      rethrow;
    }
  }

  /// 关闭数据库
  ///
  /// 安全地关闭数据库连接
  Future<void> close() async {
    try {
      // 不直接关闭数据库，由DatabaseInitializer负责
      _logger.i('ProfileRepository 已释放资源');
    } catch (e) {
      _logger.e('关闭数据库失败', error: e);
      rethrow;
    }
  }
}
