import 'package:cc/core/services/enhanced_token_manager.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/services/secure_storage_service.dart';

/// 认证调试工具
/// 提供简单的方法来检查当前用户的认证状态（基于新的多Token系统）
class AuthDebugUtils {
  static final _logger = LogService.instance;
  static final _secureStorage = SecureStorageService();

  /// 检查当前用户认证信息
  static Future<void> checkCurrentAuth() async {
    _logger.i('=== 🔍 开始检查用户认证状态 ===');

    try {
      // 1. 检查安全存储中的基本信息
      final userId = await _secureStorage.read('user_id');

      // 使用新的Token系统检查状态
      final tokenStatus = {
        'accessToken': await _secureStorage.isAccessTokenValid(),
        'refreshToken': await _secureStorage.isRefreshTokenValid(),
        'socketToken': await _secureStorage.isSocketTokenValid(),
      };

      _logger.i('📱 安全存储信息:', extra: {
        'userId': userId ?? '❌ 无',
        'tokenStatus': tokenStatus,
      });

      // 2. 检查完整用户信息
      final fullUserInfo = await _secureStorage.readUserCredentials();
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
      await _analyzeAuthProblem(userId, tokenStatus);
    } catch (error) {
      _logger.e('检查认证状态失败', error: error, stackTrace: StackTrace.current);
    }

    _logger.i('=== 🔍 认证状态检查完成 ===');
  }

  /// 分析认证问题
  static Future<void> _analyzeAuthProblem(
    String? userId,
    Map<String, dynamic> tokenStatus,
  ) async {
    final issues = <String>[];
    final solutions = <String>[];

    // 检查基本认证信息
    if (userId == null || userId.isEmpty) {
      issues.add('❌ 用户ID缺失');
      solutions.add('💡 需要重新登录');
    }

    // 检查多Token状态
    final accessToken = tokenStatus['accessToken'] as Map<String, dynamic>?;
    final refreshToken = tokenStatus['refreshToken'] as Map<String, dynamic>?;
    // socketToken检查已集成到tokenStatus中，不需要单独获取

    if (accessToken?['exists'] != true) {
      issues.add('❌ Access Token缺失');
      solutions.add('💡 需要重新登录获取Access Token');
    } else if (accessToken?['valid'] != true) {
      issues.add('❌ Access Token无效或已过期');
      solutions.add('💡 需要使用Refresh Token刷新');
    }

    if (refreshToken?['exists'] != true) {
      issues.add('❌ Refresh Token缺失');
      solutions.add('💡 需要重新登录获取Refresh Token');
    } else if (refreshToken?['valid'] != true) {
      issues.add('❌ Refresh Token无效或已过期');
      solutions.add('💡 需要重新登录');
    }

    // 输出分析结果
    if (issues.isNotEmpty) {
      _logger.w('🩺 发现的问题:', extra: {'issues': issues});
      _logger.i('🔧 建议的解决方案:', extra: {'solutions': solutions});
    } else {
      _logger.i('✅ 认证状态看起来正常');
    }
  }

  /// 检查Token可用性
  static Future<void> checkTokenAvailability() async {
    _logger.i('=== 🔍 检查Token可用性 ===');

    try {
      // 检查存储的Token
      final storedToken = await _secureStorage.getAccessToken();

      // 检查带自动刷新的Token
      final tokenManager = EnhancedTokenManager.instance;
      final refreshedToken = await tokenManager.getApiToken();

      _logger.i('🔑 Token状态对比:', extra: {
        'storedTokenExists': storedToken != null,
        'storedTokenLength': storedToken?.length ?? 0,
        'refreshedTokenExists': refreshedToken != null,
        'refreshedTokenLength': refreshedToken?.length ?? 0,
        'autoRefreshWorking': refreshedToken != null,
      });

      if (refreshedToken != null) {
        _logger.i('✅ Token自动刷新机制正常工作');
      } else if (storedToken != null) {
        _logger.w('⚠️ 存储中有Token但自动刷新失败');
      } else {
        _logger.w('❌ 没有可用的Token');
      }

      // 详细状态
      final tokenStatus = {
        'accessToken': {
          'exists': await _secureStorage.getAccessToken() != null,
          'valid': await _secureStorage.isAccessTokenValid(),
        },
        'refreshToken': {
          'exists': await _secureStorage.getRefreshToken() != null,
          'valid': await _secureStorage.isRefreshTokenValid(),
        },
        'socketToken': {
          'exists': await _secureStorage.getSocketToken() != null,
          'valid': await _secureStorage.isSocketTokenValid(),
        },
      };
      _logger.i('📊 详细Token状态:', extra: tokenStatus);
    } catch (error) {
      _logger.e('检查Token可用性失败', error: error);
    }
  }

  /// 提供修复建议
  static Future<void> suggestFixes() async {
    _logger.i('=== 🔧 认证问题修复建议 ===');

    // 使用带自动刷新的Token检查
    final tokenManager = EnhancedTokenManager.instance;
    final bestToken = await tokenManager.getApiToken();

    if (bestToken == null) {
      _logger.i('📱 需要重新登录:', extra: {
        'step1': '在AuthCubit中调用登录方法',
        'step2': 'await authCubit.loginWithPassword(phone, password)',
        'step3': '或 await authCubit.loginWithCode(phone, code)',
        'note': '系统已尝试自动刷新Token但失败',
      });
    } else {
      _logger.i('🔐 Token自动刷新成功，检查API调用:', extra: {
        'step1': '确认API请求使用正确的端点',
        'step2': '检查服务器端Token验证逻辑',
        'step3': '验证请求头格式是否正确',
        'note': 'Token自动刷新机制正常工作',
      });
    }

    _logger.i('🧪 调试步骤:', extra: {
      'check1': '在网络请求中验证Authorization头是否正确',
      'check2': '确认服务器端接收到正确的Bearer token',
      'check3': '验证API端点URL是否正确',
      'check4': '系统会自动处理Token过期和刷新',
    });
  }

  /// 检查Token格式（多Token系统）
  static Future<void> validateTokenFormats() async {
    try {
      final tokenStatus = {
        'accessToken': {
          'exists': await _secureStorage.getAccessToken() != null,
          'valid': await _secureStorage.isAccessTokenValid(),
        },
        'refreshToken': {
          'exists': await _secureStorage.getRefreshToken() != null,
          'valid': await _secureStorage.isRefreshTokenValid(),
        },
        'socketToken': {
          'exists': await _secureStorage.getSocketToken() != null,
          'valid': await _secureStorage.isSocketTokenValid(),
        },
      };

      _logger.i('🔍 多Token格式检查:', extra: {
        'accessTokenExists': tokenStatus['accessToken']?['exists'] ?? false,
        'refreshTokenExists': tokenStatus['refreshToken']?['exists'] ?? false,
        'socketTokenExists': tokenStatus['socketToken']?['exists'] ?? false,
        'recommendation': '使用新的多Token认证系统，无需JWT格式检查',
      });
    } catch (error) {
      _logger.e('Token格式检查失败', error: error);
    }
  }
}
