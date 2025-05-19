import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/database/database_initializer.dart';
import 'package:cc/core/database/models/user.dart';
import 'package:cc/core/constants/app_config.dart';

class ProfileRepository {
  final _logger = LogService.instance;

  /// 获取当前用户信息
  Future<User?> getCurrentUser() async {
    try {
      // TODO: 从数据库获取当前用户信息
      return null;
    } catch (e) {
      _logger.e('获取用户信息失败', error: e);
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
      // TODO: 更新用户信息到数据库
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

      // TODO: 删除数据库文件和媒体文件

      _logger.i('数据重置完成');
    } catch (e) {
      _logger.e('重置数据失败', error: e);
      rethrow;
    }
  }
}
