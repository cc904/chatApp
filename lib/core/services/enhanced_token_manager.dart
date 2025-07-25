import 'dart:async';
import 'package:dio/dio.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/services/secure_storage_service.dart';
import 'package:cc/core/services/communication_service.dart';
import 'package:cc/core/services/proto_socket_service.dart';
import 'package:cc/core/services/device_manager.dart';
import 'package:cc/core/constants/app_config.dart';
import 'package:cc/core/services/version_info_service.dart';

/// 增强的Token管理服务
///
/// 支持多设备登录的Token管理，包括：
/// - Refresh Token (30天有效期，负责API认证)
/// - Socket Token (7天有效期，专门用于Socket.IO实时通信)
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
  static const Duration _socketTokenRefreshAdvance =
      Duration(hours: 12); // 提前12小时刷新Socket Token
  static const Duration _checkInterval = Duration(hours: 1); // 每1小时检查一次

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

  /// 更新基础URL
  /// 当服务器切换时调用此方法更新Token管理器的baseUrl
  void updateBaseUrl(String baseUrl) {
    _dio.options.baseUrl = baseUrl;
    _logger.i('🔗 更新TokenManager基础URL', extra: {'baseUrl': baseUrl});
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
      // 获取设备信息用于验证请求
      final deviceInfo = await DeviceManager.getDeviceInfo();
      
      // 获取版本信息
      final versionInfo = VersionInfoService.instance;
      
      // 构建客户端信息
      final clientInfo = {
        'version': versionInfo.currentVersion,
        'buildNumber': versionInfo.buildNumber,
        'platform': versionInfo.platformName,
        'deviceInfo': {
          'deviceId': deviceInfo.deviceId,
          'deviceName': deviceInfo.deviceModel,
          'systemVersion': deviceInfo.osVersion,
          'deviceModel': deviceInfo.deviceModel,
        }
      };

      // 使用新的验证接口进行Token检查
      final success = await checkAndAutoRefreshToken(clientInfo: clientInfo);
      
      if (!success) {
        _logger.w('Token检查失败，可能需要重新登录');
      }
    } catch (error) {
      _logger.e('检查Token状态失败', error: error, stackTrace: StackTrace.current);
    }
  }


  /// 执行Socket Token刷新
  Future<bool> _performTokenRefresh() async {
    if (_isRefreshing) return false;

    _isRefreshing = true;
    _logger.i('🔄 开始刷新Socket Token...');

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

      // 使用Socket.io接口刷新Socket Token
      final refreshSuccess = await _refreshSocketTokenViaSocket(refreshToken);
      
      if (refreshSuccess) {
        // 通知Token更新（避免循环依赖）
        _tokenUpdateCallback?.call();

        // 如果Socket连接存在，触发重连使用新Token
        if (_communicationService.isConnected) {
          _logger.i('🔄 Socket Token已更新，触发Socket重连');
          await _communicationService.reconnect();
        }

        _logger.i('✅ Socket Token刷新成功');
        return true;
      }

      _logger.w('Socket Token刷新失败：服务器响应异常');
      return false;
    } catch (error) {
      _logger.e('Socket Token刷新失败', error: error, stackTrace: StackTrace.current);

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
  /// 处理来自服务器的登录响应，保存 Refresh Token 和 Socket Token
  Future<void> saveLoginTokens(Map<String, dynamic> loginResponse) async {
    try {
      // 支持新的tokens结构
      if (loginResponse['tokens'] != null) {
        final tokens = loginResponse['tokens'];
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
        _logger.i('✅ 保存新版Token结构 (Refresh Token + Socket Token)');

        // 启动Token管理
        startTokenManagement();

        return;
      }

      _logger.w('⚠️ 登录响应中未找到有效的tokens结构');
    } catch (error) {
      _logger.e('保存登录Token失败', error: error, stackTrace: StackTrace.current);
      rethrow;
    }
  }

  /// 获取Socket连接用的Token
  ///
  /// 返回用于Socket连接的Token，自动处理过期刷新
  Future<String?> getSocketToken() async {
    try {
      _logger.d('🔍 检查Socket Token状态...');

      // 🔧 修复：检查Socket Token是否存在且有效，避免重复调用
      final socketToken = await _secureStorage.getSocketToken();
      if (socketToken != null) {
        // 直接检查过期时间，避免调用isSocketTokenValid()造成重复getSocketToken调用
        final expireTime = await _secureStorage.getSocketTokenExpireTime();
        if (expireTime != null && DateTime.now().isBefore(expireTime)) {
          _logger.d('✅ Socket Token有效，直接使用');
          return socketToken;
        } else {
          _logger.d('⏰ Socket Token已过期，尝试刷新');
          
          // 尝试刷新Socket Token
          final refreshSuccess = await _performTokenRefresh();
          if (refreshSuccess) {
            final newSocketToken = await _secureStorage.getSocketToken();
            if (newSocketToken != null) {
              _logger.i('✅ Socket Token刷新成功');
              return newSocketToken;
            }
          }
        }
      }

      _logger.w('❌ 没有可用的Socket Token');
      return null;
    } catch (error) {
      _logger.e('获取Socket Token失败', error: error);
      return null;
    }
  }

  /// 获取API请求用的Token
  ///
  /// 返回用于API请求的Refresh Token
  /// 每次调用时自动检查Token状态，如果过期则需要重新登录
  Future<String?> getApiToken() async {
    try {
      _logger.d('检查API Token状态');

      // 检查Refresh Token是否存在
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken == null) {
        _logger.w('Refresh Token不存在');
        return null;
      }

      // 检查Refresh Token是否有效（未过期）- 避免重复获取token
      final expireTime = await _secureStorage.getRefreshTokenExpireTime();
      if (expireTime != null && DateTime.now().isBefore(expireTime)) {
        _logger.d('Refresh Token有效，直接使用');
        return refreshToken;
      }

      // Refresh Token已过期，需要重新登录
      _logger.w('Refresh Token已过期，需要重新登录');
      await _handleTokenExpired();
      return null;
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

  /// 通过Socket.io接口刷新Socket Token
  Future<bool> _refreshSocketTokenViaSocket(String refreshToken) async {
    try {
      _logger.i('🔌 通过Socket.io接口刷新Socket Token');

      // 创建一个Completer来等待Socket响应
      final completer = Completer<bool>();
      bool responseReceived = false;

      // 获取ProtoSocketService实例来处理原始事件
      final protoSocketService = ProtoSocketService();
      
      // 监听刷新响应
      protoSocketService.on('refreshSocketTokenResponse', (response) {
        if (responseReceived) return;
        responseReceived = true;

        try {
          // 解析响应并保存新Token
          _handleSocketTokenRefreshResponse(response, completer);
        } catch (error) {
          _logger.e('处理Socket Token刷新响应失败', error: error);
          if (!completer.isCompleted) {
            completer.complete(false);
          }
        }
      });

      // 发送刷新请求
      final requestData = {
        'refreshToken': refreshToken,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      
      protoSocketService.emit('refreshSocketToken', requestData);
      _logger.i('📤 已发送Socket Token刷新请求');

      // 等待响应，设置超时
      final result = await completer.future.timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          _logger.w('Socket Token刷新请求超时');
          return false;
        },
      );

      return result;
    } catch (error) {
      _logger.e('通过Socket.io刷新Token失败', error: error);
      return false;
    }
  }

  /// 处理Socket Token刷新响应
  Future<void> _handleSocketTokenRefreshResponse(
    dynamic response,
    Completer<bool> completer,
  ) async {
    try {
      // 这里需要根据实际的protobuf响应结构来解析
      // 假设响应包含success字段和tokens字段
      final success = _extractBoolFromResponse(response, 'success');
      
      if (success) {
        final tokens = _extractTokensFromResponse(response);
        
        // 保存新的Token
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

        _logger.i('✅ Socket Token通过Socket.io刷新成功');
        if (!completer.isCompleted) {
          completer.complete(true);
        }
      } else {
        _logger.w('❌ Socket Token刷新失败：服务器返回失败');
        if (!completer.isCompleted) {
          completer.complete(false);
        }
      }
    } catch (error) {
      _logger.e('解析Socket Token刷新响应失败', error: error);
      if (!completer.isCompleted) {
        completer.complete(false);
      }
    }
  }


  /// 从响应中提取布尔值
  bool _extractBoolFromResponse(dynamic response, String field) {
    // 暂时处理JSON响应，等protobuf生成后再替换
    if (response is Map) {
      return response[field] == true;
    }
    return false;
  }

  /// 从响应中提取Token信息
  Map<String, dynamic> _extractTokensFromResponse(dynamic response) {
    // 暂时处理JSON响应，等protobuf生成后再替换
    if (response is Map && response['tokens'] is Map) {
      return Map<String, dynamic>.from(response['tokens']);
    }
    return {};
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

  /// 验证Token并自动刷新
  ///
  /// 调用新的 /api/v1/auth/verifyToken 接口，支持自动刷新功能
  Future<Map<String, dynamic>?> verifyTokenWithAutoRefresh({
    required Map<String, dynamic> clientInfo,
    bool autoRefresh = true,
  }) async {
    try {
      _logger.i('🔍 验证Token并自动刷新');

      // 获取当前的refresh token
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken == null) {
        _logger.w('没有可用的refresh token');
        return null;
      }

      // 构建请求数据
      final requestData = {
        'token': refreshToken,
        'autoRefresh': autoRefresh,
        'clientInfo': clientInfo,
      };

      // 调用验证接口
      final response = await _dio.post(
        '/api/v1/auth/verifyToken',
        data: requestData,
      );

      final data = response.data;
      if (data['success'] != true) {
        _logger.w('Token验证失败: ${data['message']}');
        return null;
      }

      // 检查是否有新的token返回（自动刷新的结果）
      if (data['tokens'] != null) {
        _logger.i('🔄 服务器返回了新的Token，更新本地存储');
        await saveLoginTokens(data);
      }

      _logger.i('✅ Token验证成功');
      return data;
    } catch (error) {
      _logger.e('Token验证失败', error: error);
      
      // 如果是401错误，表示Token无效
      if (error.toString().contains('401')) {
        await _handleTokenExpired();
      }
      
      return null;
    }
  }

  /// 检查Token是否即将过期并自动刷新
  ///
  /// 使用新的验证接口进行Token检查和自动刷新
  Future<bool> checkAndAutoRefreshToken({
    required Map<String, dynamic> clientInfo,
  }) async {
    try {
      _logger.d('🔍 检查Token状态并自动刷新');

      // 检查refresh token是否存在
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken == null) {
        _logger.w('没有可用的refresh token');
        return false;
      }

      // 检查refresh token是否即将过期（提前1天检查）
      final refreshTokenExpiry = await _secureStorage.getRefreshTokenExpireTime();
      if (refreshTokenExpiry != null) {
        final timeUntilExpiry = refreshTokenExpiry.difference(DateTime.now());
        if (timeUntilExpiry.inDays <= 1) {
          _logger.i('🔄 Refresh token即将过期，尝试自动刷新');
          
          // 使用验证接口进行自动刷新
          final result = await verifyTokenWithAutoRefresh(
            clientInfo: clientInfo,
            autoRefresh: true,
          );
          
          return result != null;
        }
      }

      // 检查socket token是否需要刷新
      final socketTokenExpiry = await _secureStorage.getSocketTokenExpireTime();
      if (socketTokenExpiry != null) {
        final timeUntilExpiry = socketTokenExpiry.difference(DateTime.now());
        if (timeUntilExpiry <= _socketTokenRefreshAdvance) {
          _logger.i('🔄 Socket token即将过期，尝试自动刷新');
          
          // 使用验证接口进行自动刷新
          final result = await verifyTokenWithAutoRefresh(
            clientInfo: clientInfo,
            autoRefresh: true,
          );
          
          return result != null;
        }
      }

      _logger.d('✅ Token状态正常，无需刷新');
      return true;
    } catch (error) {
      _logger.e('检查Token状态失败', error: error);
      return false;
    }
  }
}
