import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/services/secure_storage_service.dart';

/// 认证调试工具
/// 提供简单的方法来检查当前用户的认证状态
class AuthDebugUtils {
  static final _logger = LogService.instance;
  static final _secureStorage = SecureStorageService.instance;

  /// 检查当前用户认证信息
  static Future<void> checkCurrentAuth() async {
    _logger.i('=== 🔍 开始检查用户认证状态 ===');

    try {
      // 1. 检查安全存储中的基本信息
      final userId = await _secureStorage.getUserId();
      final token = await _secureStorage.getToken();
      final isTokenValid = await _secureStorage.isTokenValid();
      final tokenExpireTime = await _secureStorage.getTokenExpireTime();

      _logger.i('📱 安全存储信息:', extra: {
        'userId': userId ?? '❌ 无',
        'hasToken': token != null,
        'tokenLength': token?.length ?? 0,
        'tokenPreview': token != null ? '${token.substring(0, 20)}...' : '❌ 无',
        'isTokenValid': isTokenValid,
        'tokenExpireTime': tokenExpireTime?.toIso8601String() ?? '❌ 无',
      });

      // 2. 检查完整用户信息
      final fullUserInfo = await _secureStorage.getFullUserInfo();
      if (fullUserInfo != null) {
        _logger.i('👤 用户详细信息:', extra: {
          'name': fullUserInfo.name.isNotEmpty ? fullUserInfo.name : '❌ 无',
          'phone': fullUserInfo.phone ?? '❌ 无',
          'email': fullUserInfo.email ?? '❌ 无',
          'avatar': fullUserInfo.avatar ?? '❌ 无',
          'status': fullUserInfo.status ?? '❌ 无',
          'lastLoginTime':
              fullUserInfo.lastLoginTime?.toIso8601String() ?? '❌ 无',
        });
      } else {
        _logger.w('❌ 未找到完整用户信息');
      }

      // 3. 分析问题
      await _analyzeAuthProblem(userId, token, isTokenValid, tokenExpireTime);
    } catch (error) {
      _logger.e('检查认证状态失败', error: error, stackTrace: StackTrace.current);
    }

    _logger.i('=== 🔍 认证状态检查完成 ===');
  }

  /// 分析认证问题
  static Future<void> _analyzeAuthProblem(
    String? userId,
    String? token,
    bool isTokenValid,
    DateTime? tokenExpireTime,
  ) async {
    final issues = <String>[];
    final solutions = <String>[];

    // 检查基本认证信息
    if (userId == null || userId.isEmpty) {
      issues.add('❌ 用户ID缺失');
      solutions.add('💡 需要重新登录');
    }

    if (token == null || token.isEmpty) {
      issues.add('❌ 认证Token缺失');
      solutions.add('💡 需要重新登录获取Token');
    } else {
      // Token存在，检查有效性
      if (!isTokenValid) {
        issues.add('❌ Token无效或已过期');
        solutions.add('💡 需要刷新Token或重新登录');
      }

      if (tokenExpireTime != null) {
        final now = DateTime.now();
        final isExpired = tokenExpireTime.isBefore(now);
        final timeRemaining = tokenExpireTime.difference(now);

        if (isExpired) {
          issues.add('❌ Token已过期');
          solutions.add('💡 Token已过期，需要重新登录');
        } else if (timeRemaining.inMinutes < 30) {
          issues.add('⚠️ Token即将过期 (${timeRemaining.inMinutes}分钟)');
          solutions.add('💡 建议提前刷新Token');
        }
      }
    }

    // 针对401错误的特殊分析
    if (token != null && isTokenValid) {
      issues.add('🤔 Token看起来正常，但仍然收到401错误');
      solutions.add('💡 检查文件上传服务是否正确设置了Token');
      solutions.add('💡 确认服务器端Token验证逻辑');
      solutions.add('💡 检查API请求头格式是否正确');
    }

    // 输出分析结果
    if (issues.isNotEmpty) {
      _logger.w('🩺 发现的问题:', extra: {'issues': issues});
      _logger.i('🔧 建议的解决方案:', extra: {'solutions': solutions});
    } else {
      _logger.i('✅ 认证状态看起来正常');
    }
  }

  /// 检查文件上传Token设置
  static Future<void> checkFileUploadTokenSetup() async {
    _logger.i('=== 🔍 检查文件上传Token设置 ===');

    try {
      final token = await _secureStorage.getToken();
      final isValid = await _secureStorage.isTokenValid();

      if (token == null || !isValid) {
        _logger.w('❌ 文件上传Token未准备好:', extra: {
          'hasToken': token != null,
          'isValid': isValid,
          'suggestion': '需要在上传文件前调用 fileUploadService.setAuthToken(token)',
        });
      } else {
        _logger.i('✅ Token准备就绪，可以进行文件上传:', extra: {
          'tokenLength': token.length,
          'isValid': isValid,
          'tokenPreview': '${token.substring(0, 20)}...',
          'nextStep': '确保在FileUploadService中调用setAuthToken()',
        });

        // 提供完整的代码示例
        _logger.i('🔧 正确设置文件上传认证的代码:', extra: {
          'step1':
              'import "package:cc/core/services/file_upload_service.dart";',
          'step2': 'final fileUploadService = FileUploadService();',
          'step3':
              'final token = await SecureStorageService.instance.getToken();',
          'step4': 'fileUploadService.setAuthToken(token!);',
          'step5': '// 然后再进行文件上传',
          'note': '⚠️ 每次应用重启都需要重新设置Token',
        });
      }
    } catch (error) {
      _logger.e('检查文件上传Token设置失败', error: error);
    }
  }

  /// 提供修复建议
  static Future<void> suggestFixes() async {
    _logger.i('=== 🔧 认证问题修复建议 ===');

    final token = await _secureStorage.getToken();
    final isValid = await _secureStorage.isTokenValid();

    if (token == null || !isValid) {
      _logger.i('📱 需要重新登录:', extra: {
        'step1': '在AuthCubit中调用登录方法',
        'step2': 'await authCubit.loginWithPassword(phone, password)',
        'step3': '或 await authCubit.loginWithCode(phone, code)',
      });
    } else {
      _logger.i('🔐 设置文件上传认证:', extra: {
        'step1': '获取当前Token',
        'step2': 'final token = await SecureStorageService.instance.getToken()',
        'step3': 'fileUploadService.setAuthToken(token)',
        'note': '确保在每次文件上传前都设置Token',
      });
    }

    _logger.i('🧪 调试步骤:', extra: {
      'check1': '在网络请求中验证Authorization头是否正确',
      'check2': '确认服务器端接收到正确的Bearer token',
      'check3': '验证API端点URL是否正确',
      'check4': '检查服务器端Token验证逻辑',
    });
  }

  /// 简单的Token格式检查
  static Future<void> validateTokenFormat() async {
    try {
      final token = await _secureStorage.getToken();

      if (token == null) {
        _logger.w('❌ Token不存在');
        return;
      }

      // 简单的JWT格式检查
      final parts = token.split('.');

      _logger.i('🔍 Token格式检查:', extra: {
        'tokenLength': token.length,
        'jwtParts': parts.length,
        'isValidJWTFormat': parts.length == 3,
        'headerPreview': parts.isNotEmpty ? parts[0].substring(0, 10) : '无',
        'recommendation': parts.length != 3 ? 'Token格式不是标准JWT' : 'Token格式正确',
      });
    } catch (error) {
      _logger.e('Token格式检查失败', error: error);
    }
  }
}
