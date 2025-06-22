import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/services/file_upload_service.dart';
import 'package:cc/core/services/proto_socket_service.dart';

/// 认证Token同步服务
/// 负责在用户登录成功后自动将Token同步到各个需要认证的服务中
class AuthTokenSyncService {
  static final _instance = AuthTokenSyncService._internal();
  static AuthTokenSyncService get instance => _instance;

  final _logger = LogService.instance;
  final _fileUploadService = FileUploadService();
  final _protoSocketService = ProtoSocketService();

  AuthTokenSyncService._internal();

  /// 同步Token到所有需要认证的服务
  /// 在用户登录成功后调用此方法
  void syncTokenToAllServices(String token) {
    _logger.i('🔄 开始同步Token到所有服务...', extra: {
      'tokenPreview': '${token.substring(0, 20)}...',
    });

    try {
      // 1. 设置到文件上传服务
      _fileUploadService.setAuthToken(token);
      _logger.i('✅ Token已同步到FileUploadService');

      // 2. 设置到Socket服务
      _protoSocketService.updateToken(token);
      _logger.i('✅ Token已同步到ProtoSocketService');

      _logger.i('🎉 Token同步完成！所有服务都已获得认证。');
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
 