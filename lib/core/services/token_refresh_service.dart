import 'dart:async';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/services/secure_storage_service.dart';
import 'package:cc/core/network/auth_api_client.dart';
import 'package:cc/core/services/auth_token_sync_service.dart';
import 'package:cc/core/database/database_initializer.dart';
import 'package:cc/core/database/models/current_user.dart';
import 'package:cc/core/services/communication_service.dart';

/// Token自动刷新服务
///
/// 负责监控token过期时间，在token即将过期时自动刷新
/// 确保用户无感知的认证状态维护
class TokenRefreshService {
  static final TokenRefreshService _instance = TokenRefreshService._internal();
  static TokenRefreshService get instance => _instance;

  final _logger = LogService.instance;
  final _secureStorage = SecureStorageService.instance;
  final _authApiClient = AuthApiClient.getInstance();
  final _authTokenSync = AuthTokenSyncService.instance;
  final _communicationService = CommunicationService();

  Timer? _refreshTimer;
  bool _isRefreshing = false;

  // 提前刷新时间：token过期前30分钟开始尝试刷新
  static const Duration _refreshAdvanceTime = Duration(minutes: 30);
  // 检查间隔：每5分钟检查一次
  static const Duration _checkInterval = Duration(minutes: 5);

  TokenRefreshService._internal();

  /// 启动自动刷新服务
  void startAutoRefresh() {
    _logger.i('🔄 启动Token自动刷新服务');

    // 取消现有定时器
    _refreshTimer?.cancel();

    // 立即检查一次
    _checkAndRefreshToken();

    // 设置定时检查
    _refreshTimer = Timer.periodic(_checkInterval, (_) {
      _checkAndRefreshToken();
    });
  }

  /// 停止自动刷新服务
  void stopAutoRefresh() {
    _logger.i('⏹️ 停止Token自动刷新服务');
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  /// 检查并刷新Token
  Future<void> _checkAndRefreshToken() async {
    if (_isRefreshing) {
      _logger.d('Token刷新正在进行中，跳过本次检查');
      return;
    }

    try {
      // 获取当前token信息
      final token = await _secureStorage.getToken();
      final expireTime = await _secureStorage.getTokenExpireTime();

      if (token == null || token.isEmpty) {
        _logger.d('没有找到Token，停止自动刷新');
        stopAutoRefresh();
        return;
      }

      if (expireTime == null) {
        _logger.d('Token没有过期时间，跳过刷新检查');
        return;
      }

      final now = DateTime.now();
      final timeUntilExpiry = expireTime.difference(now);

      _logger.d('Token状态检查', extra: {
        'expireTime': expireTime.toIso8601String(),
        'timeUntilExpiry': '${timeUntilExpiry.inMinutes}分钟',
        'needsRefresh': timeUntilExpiry <= _refreshAdvanceTime,
      });

      // 如果token即将过期，尝试刷新
      if (timeUntilExpiry <= _refreshAdvanceTime) {
        await _performTokenRefresh(token);
      }
    } catch (error) {
      _logger.e('检查Token状态失败', error: error, stackTrace: StackTrace.current);
    }
  }

  /// 执行Token刷新
  Future<void> _performTokenRefresh(String currentToken) async {
    if (_isRefreshing) return;

    _isRefreshing = true;
    _logger.i('🔄 开始刷新Token...');

    try {
      // 通过验证token接口获取新token
      final verifyResponse = await _authApiClient.verifyToken(currentToken);

      if (verifyResponse.success && verifyResponse.currentUser != null) {
        final currentUser = verifyResponse.currentUser!;

        // 检查是否返回了新token
        String? newToken;
        DateTime? newExpireTime;

        // 从验证响应中提取新token（如果服务器返回了）
        if (currentUser.hasToken() && currentUser.token != currentToken) {
          newToken = currentUser.token;
          _logger.i('✅ 服务器返回了新Token');
        }

        if (currentUser.hasTokenExpireTime()) {
          newExpireTime = DateTime.fromMillisecondsSinceEpoch(
              currentUser.tokenExpireTime.toInt());
          _logger.i('✅ 更新Token过期时间: ${newExpireTime.toIso8601String()}');
        }

        // 如果有新token或新过期时间，更新存储
        if (newToken != null || newExpireTime != null) {
          await _updateTokenInfo(newToken ?? currentToken, newExpireTime);

          // 同步新token到所有服务
          _authTokenSync.syncTokenToAllServices(newToken ?? currentToken);

          // 🔑 重要：Token更新后，如果Socket已连接，需要重连以使用新token
          if (_communicationService.isConnected) {
            _logger.i('🔄 Token已更新，触发Socket重连以使用新token');
            try {
              final reconnectSuccess = await _communicationService.reconnect();
              if (reconnectSuccess) {
                _logger.i('✅ Socket重连成功，新Token已生效');
              } else {
                _logger.w('⚠️ Socket重连失败，新Token可能未生效');
              }
            } catch (error) {
              _logger.e('Socket重连异常',
                  error: error, stackTrace: StackTrace.current);
            }
          } else {
            _logger.d('Socket未连接，跳过重连步骤');
          }

          _logger.i('🎉 Token刷新成功');
        } else {
          _logger.d('服务器没有返回新Token，当前Token仍然有效');
        }
      } else {
        _logger.w('Token验证失败，可能需要重新登录',
            extra: {'message': verifyResponse.message});

        // 停止自动刷新，让用户重新登录
        stopAutoRefresh();
      }
    } catch (error) {
      _logger.e('Token刷新失败', error: error, stackTrace: StackTrace.current);
    } finally {
      _isRefreshing = false;
    }
  }

  /// 更新Token信息到存储
  Future<void> _updateTokenInfo(String token, DateTime? expireTime) async {
    try {
      // 获取当前完整用户信息
      final currentUser = await _secureStorage.getFullUserInfo();
      if (currentUser == null) {
        _logger.w('无法获取当前用户信息，跳过Token更新');
        return;
      }

      // 更新token和过期时间
      currentUser.token = token;
      if (expireTime != null) {
        currentUser.tokenExpireTime = expireTime;
      }

      // 保存到安全存储
      await _secureStorage.saveUserCredentials(currentUser);

      // 更新数据库中的用户信息
      if (DatabaseInitializer.isInitialized) {
        await DatabaseInitializer.isar.writeTxn(() async {
          await DatabaseInitializer.isar.currentUsers.clear();
          await DatabaseInitializer.isar.currentUsers.put(currentUser);
        });
      }

      _logger.i('Token信息已更新到存储');
    } catch (error) {
      _logger.e('更新Token信息失败', error: error, stackTrace: StackTrace.current);
      rethrow;
    }
  }

  /// 手动刷新Token
  /// 供外部调用的公共方法
  Future<bool> manualRefreshToken() async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null) {
        _logger.w('没有找到Token，无法手动刷新');
        return false;
      }

      await _performTokenRefresh(token);
      return true;
    } catch (error) {
      _logger.e('手动刷新Token失败', error: error, stackTrace: StackTrace.current);
      return false;
    }
  }

  /// 检查Token是否需要刷新
  Future<bool> needsRefresh() async {
    try {
      final expireTime = await _secureStorage.getTokenExpireTime();
      if (expireTime == null) return false;

      final timeUntilExpiry = expireTime.difference(DateTime.now());
      return timeUntilExpiry <= _refreshAdvanceTime;
    } catch (error) {
      _logger.e('检查Token刷新需求失败', error: error);
      return false;
    }
  }

  /// 获取Token剩余有效时间
  Future<Duration?> getTokenRemainingTime() async {
    try {
      final expireTime = await _secureStorage.getTokenExpireTime();
      if (expireTime == null) return null;

      final remaining = expireTime.difference(DateTime.now());
      return remaining.isNegative ? Duration.zero : remaining;
    } catch (error) {
      _logger.e('获取Token剩余时间失败', error: error);
      return null;
    }
  }

  /// 释放资源
  void dispose() {
    stopAutoRefresh();
  }
}
