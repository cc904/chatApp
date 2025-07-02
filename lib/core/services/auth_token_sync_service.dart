import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/services/file_upload_service.dart';
import 'package:cc/core/services/proto_socket_service.dart';
import 'package:cc/core/services/enhanced_token_manager.dart';

/// 认证Token同步服务
/// 负责在用户登录成功后自动将Token同步到各个需要认证的服务中
class AuthTokenSyncService {
  static final _instance = AuthTokenSyncService._internal();
  static AuthTokenSyncService get instance => _instance;

  final _logger = LogService.instance;
  final _fileUploadService = FileUploadService();
  final _protoSocketService = ProtoSocketService();
  final _tokenManager = EnhancedTokenManager.instance;

  bool _callbackInitialized = false;

  AuthTokenSyncService._internal();

  /// 初始化Token更新回调
  void _initTokenUpdateCallback() {
    // 设置Token更新回调，避免循环依赖
    _tokenManager.setTokenUpdateCallback(() async {
      await syncTokenToAllServices();
    });
  }

  /// 同步Token到所有需要认证的服务
  /// 登录成功后调用此方法，会自动获取各服务需要的正确Token类型
  Future<void> syncTokenToAllServices() async {
    // 延迟初始化回调，避免构造函数中的循环依赖
    if (!_callbackInitialized) {
      _initTokenUpdateCallback();
      _callbackInitialized = true;
    }

    _logger.i('🔄 开始同步Token到所有服务...');

    try {
      // 1. 设置文件上传服务 - 使用Access Token
      final accessToken = await _tokenManager.getApiToken();
      if (accessToken != null) {
        _fileUploadService.setAuthToken(accessToken);
        _logger.i('✅ Access Token已同步到FileUploadService');
      } else {
        _logger.w('⚠️ 没有可用的Access Token用于FileUploadService');
      }

      // 2. 设置Socket服务 - 使用Socket Token（优先）或Access Token（备用）
      final socketToken = await _tokenManager.getSocketToken();
      if (socketToken != null) {
        _protoSocketService.updateToken(socketToken);
        _logger.i('✅ Socket Token已同步到ProtoSocketService');
      } else {
        _logger.w('⚠️ 没有可用的Socket Token用于ProtoSocketService');
      }

      _logger.i('🎉 Token同步完成！所有服务都已获得正确类型的认证Token。');
    } catch (error) {
      _logger.e('Token同步失败', error: error, stackTrace: StackTrace.current);
    }
  }

  /// 清除所有服务的Token
  /// 在用户登出时调用此方法
  void clearTokenFromAllServices() {
    _logger.i('🧹 清除所有服务的Token...');

    try {
      // 清除文件上传服务的Token
      _fileUploadService.clearAuthToken();
      _logger.i('✅ 已清除FileUploadService的Token');

      // Socket服务的Token清除在断开连接时自动处理

      _logger.i('🎉 Token清除完成！');
    } catch (error) {
      _logger.e('Token清除失败', error: error, stackTrace: StackTrace.current);
    }
  }

  /// 检查所有服务的Token状态
  /// 用于调试和验证
  void checkAllServicesTokenStatus() {
    _logger.i('🔍 检查所有服务的Token状态...');

    // 这里可以添加具体的Token状态检查逻辑
    // 目前大部分服务没有提供Token状态查询接口

    _logger.i('💡 提示：如果遇到401错误，请确保调用了syncTokenToAllServices()方法');
  }
}
