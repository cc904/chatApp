import 'package:cc/core/utils/auth_debug_utils.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/services/auth_token_sync_service.dart';
import 'package:cc/core/services/secure_storage_service.dart';

/// 调试命令集合
/// 提供各种调试功能的快捷命令
class DebugCommands {
  static final _logger = LogService.instance;

  /// 完整的认证状态诊断
  /// 建议在遇到401错误时调用此方法
  static Future<void> diagnoseAuthIssue() async {
    _logger.i('🚨 开始诊断认证问题...');

    // 1. 检查基本认证信息
    await AuthDebugUtils.checkCurrentAuth();

    // 2. 检查文件上传Token设置
    await AuthDebugUtils.checkFileUploadTokenSetup();

    // 3. 验证Token格式
    await AuthDebugUtils.validateTokenFormat();

    // 4. 提供修复建议
    await AuthDebugUtils.suggestFixes();

    _logger.i('🚨 认证问题诊断完成');
  }

  /// 快速检查当前用户信息
  static Future<void> whoAmI() async {
    await AuthDebugUtils.checkCurrentAuth();
  }

  /// 检查文件上传准备状态
  static Future<void> checkUploadReady() async {
    await AuthDebugUtils.checkFileUploadTokenSetup();
  }

  /// 🚨 快速认证检查和修复
  static Future<void> quickAuthCheck() async {
    _logger.i('🚀 === 快速认证检查 === 🚀');

    try {
      await AuthDebugUtils.checkCurrentAuth();

      _logger.i('🔧 如果看到401错误，请立即执行以下代码:', extra: {
        'import': 'import "package:cc/core/services/file_upload_service.dart";',
        'import2':
            'import "package:cc/core/services/secure_storage_service.dart";',
        'code1': 'final fileUploadService = FileUploadService();',
        'code2':
            'final token = await SecureStorageService.instance.getToken();',
        'code3': 'if (token != null) {',
        'code4': '  fileUploadService.setAuthToken(token);',
        'code5': '  print("✅ Token已设置到上传服务");',
        'code6': '} else {',
        'code7': '  print("❌ 无法获取Token，请先登录");',
        'code8': '}',
        'note': '⚠️ 在调用任何文件上传方法前执行此代码！',
      });
    } catch (error) {
      _logger.e('快速认证检查失败', error: error);
    }
  }

  /// 🔧 立即修复Token同步问题
  /// 自动获取Token并设置到所有服务
  static Future<void> fixTokenSync() async {
    _logger.i('🔧 === 立即修复Token同步 === 🔧');

    try {
      final token = await SecureStorageService.instance.getToken();

      if (token == null) {
        _logger.e('❌ 无法获取Token，请先登录');
        return;
      }

      final isValid = await SecureStorageService.instance.isTokenValid();
      if (!isValid) {
        _logger.e('❌ Token已过期，请重新登录');
        return;
      }

      // 立即同步Token到所有服务
      AuthTokenSyncService.instance.syncTokenToAllServices(token);

      _logger.i('✅ Token同步修复完成！现在可以进行文件上传了。');
    } catch (error) {
      _logger.e('Token同步修复失败', error: error);
    }
  }
}

/// 在需要调试时，可以在代码中任何地方调用：
/// 
/// ```dart
/// // 完整诊断（推荐在遇到401错误时使用）
/// await DebugCommands.diagnoseAuthIssue();
/// 
/// // 🔧 立即修复401错误 - 推荐！
/// await DebugCommands.fixTokenSync();
/// 
/// // 快速检查用户信息
/// await DebugCommands.whoAmI();
/// 
/// // 检查文件上传准备状态
/// await DebugCommands.checkUploadReady();
/// ``` 