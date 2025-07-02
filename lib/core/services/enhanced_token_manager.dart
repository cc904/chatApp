import 'dart:async';
import 'package:dio/dio.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/services/secure_storage_service.dart';
import 'package:cc/core/services/communication_service.dart';
import 'package:cc/core/services/device_manager.dart';
import 'package:cc/core/constants/app_config.dart';

/// 增强的Token管理服务
///
/// 支持多设备登录的Token管理，包括：
/// - Access Token (30分钟有效期)
/// - Refresh Token (30天有效期)
/// - Socket Token (7天有效期)
/// - 自动刷新机制
/// - 设备登录冲突处理
class EnhancedTokenManager {
  static final EnhancedTokenManager _instance =
      EnhancedTokenManager._internal();
  static EnhancedTokenManager get instance => _instance;

  final _logger = LogService.instance;
  final _secureStorage = SecureStorageService();
  final _communicationService = CommunicationService();

  // 用于Token刷新的独立Dio实例，避免循环依赖
  late final Dio _dio;

  // Token更新回调函数
  Function()? _tokenUpdateCallback;

  Timer? _refreshTimer;
  bool _isRefreshing = false;

  // Token刷新配置
  static const Duration _accessTokenRefreshAdvance =
      Duration(minutes: 5); // 提前5分钟刷新
  static const Duration _checkInterval = Duration(minutes: 3); // 每3分钟检查一次

  EnhancedTokenManager._internal() {
    _dio = Dio();
    _setupDioSync();
  }

  /// 同步设置Dio基础配置
  void _setupDioSync() {
    // 获取服务器URL
    final appConfig = AppConfig();
    final baseUrl = appConfig.serverUrl;

    // 基础配置，不添加认证拦截器避免循环依赖
    _dio.options.baseUrl = baseUrl;
    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);

    _logger.i('🔧 EnhancedTokenManager Dio基础配置完成', extra: {'baseUrl': baseUrl});

    // 异步设置设备标识头
    _setupDeviceHeaders();
  }

  /// 异步设置设备标识头
  Future<void> _setupDeviceHeaders() async {
    try {
      final deviceId = await DeviceManager.getDeviceId();
      final userAgent = await DeviceManager.getUserAgent();
      _dio.options.headers['x-device-id'] = deviceId;
      _dio.options.headers['User-Agent'] = userAgent;
      _logger.d('设备标识头设置完成');
    } catch (e) {
      _logger.w('设置设备标识头失败', extra: {'error': e.toString()});
    }
  }

  /// 设置Token更新回调（避免循环依赖）
  void setTokenUpdateCallback(Function() callback) {
    _tokenUpdateCallback = callback;
  }

  /// 启动Token管理服务
  void startTokenManagement() {
    _logger.i('🚀 启动增强Token管理服务');

    // 取消现有定时器
    _refreshTimer?.cancel();

    // 立即检查一次
    _checkAndRefreshTokens();

    // 设置定时检查
    _refreshTimer = Timer.periodic(_checkInterval, (_) {
      _checkAndRefreshTokens();
    });
  }

  /// 停止Token管理服务
  void stopTokenManagement() {
    _logger.i('⏹️ 停止Token管理服务');
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  /// 检查并刷新Token
  Future<void> _checkAndRefreshTokens() async {
    if (_isRefreshing) return;

    try {
      // 检查Access Token是否需要刷新
      final needsRefresh = await _needsAccessTokenRefresh();
      if (needsRefresh) {
        _logger.i('🔄 Access Token即将过期，开始自动刷新');
        await _performTokenRefresh();
      }
    } catch (error) {
      _logger.e('检查Token状态失败', error: error, stackTrace: StackTrace.current);
    }
  }

  /// 检查Access Token是否需要刷新
  Future<bool> _needsAccessTokenRefresh() async {
    try {
      final expireTime = await _secureStorage.getAccessTokenExpireTime();
      if (expireTime == null) return false;

      final timeUntilExpiry = expireTime.difference(DateTime.now());
      return timeUntilExpiry <= _accessTokenRefreshAdvance;
    } catch (error) {
      _logger.e('检查Access Token刷新需求失败', error: error);
      return false;
    }
  }

  /// 执行Token刷新
  Future<bool> _performTokenRefresh() async {
    if (_isRefreshing) return false;

    _isRefreshing = true;
    _logger.i('🔄 开始刷新Access Token...');

    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        _logger.w('没有可用的Refresh Token，无法刷新');
        return false;
      }

      // 检查Refresh Token是否有效
      if (!await _secureStorage.isRefreshTokenValid()) {
        _logger.w('Refresh Token已过期，需要重新登录');
        await _handleTokenExpired();
        return false;
      }

      // 调用刷新Token API（使用独立Dio实例避免循环依赖）
      final response = await _dio.post(
        '/api/v1/auth/refreshToken',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['tokens'] != null) {
          // 保存新的Token
          final tokens = data['tokens'];
          if (tokens['accessToken'] != null &&
              tokens['accessTokenExpiresAt'] != null) {
            await _secureStorage.saveAccessToken(
              tokens['accessToken'],
              DateTime.fromMillisecondsSinceEpoch(
                  tokens['accessTokenExpiresAt']),
            );
          }
          if (tokens['refreshToken'] != null &&
              tokens['refreshTokenExpiresAt'] != null) {
            await _secureStorage.saveRefreshToken(
              tokens['refreshToken'],
              DateTime.fromMillisecondsSinceEpoch(
                  tokens['refreshTokenExpiresAt']),
            );
          }
          if (tokens['socketToken'] != null &&
              tokens['socketTokenExpiresAt'] != null) {
            await _secureStorage.saveSocketToken(
              tokens['socketToken'],
              DateTime.fromMillisecondsSinceEpoch(
                  tokens['socketTokenExpiresAt']),
            );
          }

          // 通知Token更新（避免循环依赖）
          _tokenUpdateCallback?.call();

          // 如果Socket连接存在，触发重连使用新Token
          if (_communicationService.isConnected) {
            _logger.i('🔄 Token已更新，触发Socket重连');
            await _communicationService.reconnect();
          }

          _logger.i('✅ Token刷新成功');
          return true;
        }
      }

      _logger.w('Token刷新失败：服务器响应异常');
      return false;
    } catch (error) {
      _logger.e('Token刷新失败', error: error, stackTrace: StackTrace.current);

      // 如果是401错误，表示Refresh Token无效
      if (error.toString().contains('401')) {
        await _handleTokenExpired();
      }

      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  /// 处理Token过期
  Future<void> _handleTokenExpired() async {
    _logger.w('🚨 Token已过期，清除本地认证状态');

    try {
      // 清除所有Token
      await _secureStorage.clearAllTokens();

      // 清除用户凭证
      await _secureStorage.clearUserCredentials();

      // 断开连接
      await _communicationService.disconnect();

      // 清除所有服务的Token通过回调处理
      _tokenUpdateCallback?.call();

      // 停止Token管理
      stopTokenManagement();

      _logger.i('💫 本地认证状态已清除，用户需要重新登录');

      // TODO: 触发应用重新导航到登录页面
      // 这里可以发送全局事件通知UI层
    } catch (error) {
      _logger.e('处理Token过期失败', error: error, stackTrace: StackTrace.current);
    }
  }

  /// 保存登录响应中的Token
  ///
  /// 处理来自服务器的登录响应，保存多种Token
  Future<void> saveLoginTokens(Map<String, dynamic> loginResponse) async {
    try {
      // 支持新的tokens结构
      if (loginResponse['tokens'] != null) {
        final tokens = loginResponse['tokens'];
        if (tokens['accessToken'] != null &&
            tokens['accessTokenExpiresAt'] != null) {
          await _secureStorage.saveAccessToken(
            tokens['accessToken'],
            DateTime.fromMillisecondsSinceEpoch(tokens['accessTokenExpiresAt']),
          );
        }
        if (tokens['refreshToken'] != null &&
            tokens['refreshTokenExpiresAt'] != null) {
          await _secureStorage.saveRefreshToken(
            tokens['refreshToken'],
            DateTime.fromMillisecondsSinceEpoch(
                tokens['refreshTokenExpiresAt']),
          );
        }
        if (tokens['socketToken'] != null &&
            tokens['socketTokenExpiresAt'] != null) {
          await _secureStorage.saveSocketToken(
            tokens['socketToken'],
            DateTime.fromMillisecondsSinceEpoch(tokens['socketTokenExpiresAt']),
          );
        }
        _logger.i('✅ 保存新版多Token结构');

        // 启动Token管理
        startTokenManagement();

        return;
      }

      // 兼容旧的响应结构
      if (loginResponse['currentUser'] != null) {
        final currentUser = loginResponse['currentUser'];
        final token = currentUser['token'];
        final tokenExpireTime =
            loginResponse['tokenExpiresAt'] ?? currentUser['tokenExpireTime'];

        if (token != null) {
          // 构造兼容的Token结构，同时用作Access Token和Socket Token
          final compatTokens = {
            'accessToken': token,
            'accessTokenExpiresAt': tokenExpireTime,
            'socketToken': token, // 兼容模式下，socket也使用同一个token
            'socketTokenExpiresAt': tokenExpireTime,
          };

          if (compatTokens['accessToken'] != null &&
              compatTokens['accessTokenExpiresAt'] != null) {
            await _secureStorage.saveAccessToken(
              compatTokens['accessToken'],
              DateTime.fromMillisecondsSinceEpoch(
                  compatTokens['accessTokenExpiresAt']),
            );
          }
          if (compatTokens['socketToken'] != null &&
              compatTokens['socketTokenExpiresAt'] != null) {
            await _secureStorage.saveSocketToken(
              compatTokens['socketToken'],
              DateTime.fromMillisecondsSinceEpoch(
                  compatTokens['socketTokenExpiresAt']),
            );
          }
          _logger.i('✅ 保存兼容版Token结构（Access Token和Socket Token使用同一token）');

          // 启动Token管理
          startTokenManagement();
        }
      }
    } catch (error) {
      _logger.e('保存登录Token失败', error: error, stackTrace: StackTrace.current);
      rethrow;
    }
  }

  /// 获取Socket连接用的最佳Token
  ///
  /// 按优先级返回用于Socket连接的Token，自动处理过期刷新
  Future<String?> getSocketToken() async {
    try {
      _logger.d('🔍 检查Socket Token状态...');

      // 1. 优先使用Socket Token
      final socketToken = await _secureStorage.getSocketToken();
      if (socketToken != null) {
        if (await _secureStorage.isSocketTokenValid()) {
          _logger.d('✅ Socket Token有效，直接使用');
          return socketToken;
        } else {
          _logger.d('⏰ Socket Token已过期，尝试使用Access Token');
        }
      }

      // 2. 使用Access Token作为备用（并自动刷新）
      final accessToken = await getApiToken(); // 这会自动处理过期刷新
      if (accessToken != null) {
        _logger.d('🔌 使用Access Token进行Socket连接');
        return accessToken;
      }

      _logger.w('❌ 没有可用的Token进行Socket连接');
      return null;
    } catch (error) {
      _logger.e('获取Socket Token失败', error: error);
      return null;
    }
  }

  /// 获取API请求用的Token
  ///
  /// 返回用于API请求的Access Token
  /// 每次调用时自动检查Token状态，如果过期则立即刷新
  Future<String?> getApiToken() async {
    try {
      _logger.d('🔍 检查API Token状态...');

      // 1. 首先检查Access Token是否存在
      final accessToken = await _secureStorage.getAccessToken();
      if (accessToken == null) {
        _logger.w('❌ Access Token不存在');
        return null;
      }

      // 2. 检查Access Token是否有效（未过期）
      final isValid = await _secureStorage.isAccessTokenValid();
      if (isValid) {
        _logger.d('✅ Access Token有效，直接使用');
        return accessToken;
      }

      // 3. Token已过期，尝试刷新
      _logger.i('⏰ Access Token已过期，尝试立即刷新...');

      // 检查是否有Refresh Token
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken == null) {
        _logger.w('❌ 没有Refresh Token，无法刷新，需要重新登录');
        return null;
      }

      // 检查Refresh Token是否有效
      if (!await _secureStorage.isRefreshTokenValid()) {
        _logger.w('❌ Refresh Token也已过期，需要重新登录');
        return null;
      }

      // 执行Token刷新
      _logger.i('🔄 开始刷新过期的Access Token...');
      final refreshSuccess = await _performTokenRefresh();

      if (refreshSuccess) {
        // 刷新成功，获取新的Access Token
        final newAccessToken = await _secureStorage.getAccessToken();
        if (newAccessToken != null) {
          _logger.i('✅ Token刷新成功，返回新Token');
          return newAccessToken;
        } else {
          _logger.w('⚠️ Token刷新成功但无法获取新Token');
          return null;
        }
      } else {
        _logger.w('❌ Token刷新失败');
        return null;
      }
    } catch (error) {
      _logger.e('获取API Token失败', error: error);
      return null;
    }
  }

  /// 手动刷新Token
  ///
  /// 供外部调用的公共方法
  Future<bool> manualRefreshToken() async {
    return await _performTokenRefresh();
  }

  /// 处理多设备登录冲突
  ///
  /// 当收到设备冲突错误时调用
  Future<void> handleDeviceConflict(Map<String, dynamic> conflictInfo) async {
    try {
      _logger.w('🚨 检测到多设备登录冲突', extra: conflictInfo);

      final conflictType = conflictInfo['type']; // 'exclusive', 'limited', etc.
      final message = conflictInfo['message'] ?? '设备登录冲突';

      // 根据冲突类型处理
      switch (conflictType) {
        case 'exclusive':
          // 互斥策略：当前设备被踢下线
          _logger.w('设备被踢下线（互斥策略）');
          await _handleDeviceKickedOut(message);
          break;

        case 'limited':
          // 限制策略：超过最大设备数
          _logger.w('超过最大设备数限制');
          await _handleDeviceLimitExceeded(message);
          break;

        default:
          _logger.w('未知的设备冲突类型: $conflictType');
          await _handleGenericDeviceConflict(message);
      }
    } catch (error) {
      _logger.e('处理设备冲突失败', error: error, stackTrace: StackTrace.current);
    }
  }

  /// 处理设备被踢下线
  Future<void> _handleDeviceKickedOut(String message) async {
    // 清除本地认证状态
    await _handleTokenExpired();

    // TODO: 显示通知给用户
    _logger.i('设备已被踢下线，需要重新登录');
  }

  /// 处理设备数量限制
  Future<void> _handleDeviceLimitExceeded(String message) async {
    // 可以选择显示设备管理界面，让用户选择踢掉其他设备
    _logger.i('设备数量超限，建议用户管理设备');
  }

  /// 处理通用设备冲突
  Future<void> _handleGenericDeviceConflict(String message) async {
    _logger.w('通用设备冲突: $message');
  }

  /// 获取Token状态信息
  ///
  /// 用于调试和状态检查
  Future<Map<String, dynamic>> getTokenStatus() async {
    try {
      final summary = {
        'accessToken': {
          'exists': await _secureStorage.getAccessToken() != null,
          'valid': await _secureStorage.isAccessTokenValid(),
          'expiresAt': (await _secureStorage.getAccessTokenExpireTime())
              ?.toIso8601String(),
        },
        'refreshToken': {
          'exists': await _secureStorage.getRefreshToken() != null,
          'valid': await _secureStorage.isRefreshTokenValid(),
          'expiresAt': (await _secureStorage.getRefreshTokenExpireTime())
              ?.toIso8601String(),
        },
        'socketToken': {
          'exists': await _secureStorage.getSocketToken() != null,
          'valid': await _secureStorage.isSocketTokenValid(),
          'expiresAt': (await _secureStorage.getSocketTokenExpireTime())
              ?.toIso8601String(),
        },
      };

      return {
        ...summary,
        'refreshTimer': {
          'active': _refreshTimer?.isActive ?? false,
          'isRefreshing': _isRefreshing,
        },
        'nextRefreshCheck': _refreshTimer != null
            ? DateTime.now().add(_checkInterval).toIso8601String()
            : null,
      };
    } catch (error) {
      _logger.e('获取Token状态失败', error: error);
      return {};
    }
  }

  /// 强制刷新所有Token
  ///
  /// 在检测到服务器端Token策略更新时使用
  Future<bool> forceRefreshAllTokens() async {
    _logger.i('🔄 强制刷新所有Token');

    try {
      // 停止自动刷新
      _refreshTimer?.cancel();

      // 执行刷新
      final success = await _performTokenRefresh();

      // 重新启动自动刷新
      if (success) {
        startTokenManagement();
      }

      return success;
    } catch (error) {
      _logger.e('强制刷新Token失败', error: error);
      return false;
    }
  }
}
