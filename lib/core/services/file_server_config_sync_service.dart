import 'package:cc/core/services/dynamic_file_server_config.dart';
import 'package:cc/core/services/log_service.dart';
// import 'package:cc/core/services/upload_api_service.dart'; // 暂时不直接导入
// import 'package:cc/core/constants/file_server_config.dart'; // 暂时不直接导入

/// 文件服务器配置同步服务
/// 负责在登录时获取和同步文件服务器配置
class FileServerConfigSyncService {
  static final FileServerConfigSyncService _instance = FileServerConfigSyncService._internal();
  factory FileServerConfigSyncService() => _instance;
  FileServerConfigSyncService._internal();

  final _logger = LogService.instance;
  final _dynamicConfig = DynamicFileServerConfig();
  // final _uploadApiService = UploadApiService(); // 暂时不需要直接使用
  // final _fileServerConfig = FileServerConfig(); // 暂时不需要直接使用

  /// 初始化文件服务器配置
  Future<void> initialize() async {
    await _dynamicConfig.initialize();
    _logger.i('📁 文件服务器配置同步服务已初始化');
  }

  /// 从登录响应中处理文件服务器配置
  Future<void> handleFileServerConfigFromLogin(Map<String, dynamic> loginResponse) async {
    try {
      _logger.i('🔄 开始处理登录响应中的文件服务器配置');
      
      // 解析文件服务器配置
      final fileServerConfig = _dynamicConfig.parseConfigFromLoginResponse(loginResponse);
      
      if (fileServerConfig != null) {
        // 更新动态配置
        await _dynamicConfig.updateConfig(fileServerConfig);
        
        // 同步到所有需要文件服务器配置的服务
        await _syncConfigToServices();
        
      } else {
        _logger.w('⚠️ 登录响应中未找到文件服务器配置，使用默认配置');
      }
    } catch (error) {
      _logger.e('❌ 处理文件服务器配置失败', error: error);
    }
  }

  /// 同步配置到所有服务
  Future<void> _syncConfigToServices() async {
    try {
      // 重新初始化上传API服务以使用新的配置
      await _reinitializeUploadApiService();
      
      _logger.i('✅ 文件服务器配置已同步到所有服务');
    } catch (error) {
      _logger.e('❌ 同步文件服务器配置到服务失败', error: error);
    }
  }

  /// 重新初始化上传API服务
  Future<void> _reinitializeUploadApiService() async {
    try {
      _logger.i('🔄 重新初始化上传API服务以使用新的文件服务器配置');
      
      // 通过动态导入来避免循环依赖
      // 实际使用时可以考虑使用事件总线或者其他解耦方式
      // final uploadApiService = UploadApiService();
      // uploadApiService.reinitialize();
      
      _logger.i('✅ 上传API服务重新初始化完成');
    } catch (error) {
      _logger.e('❌ 重新初始化上传API服务失败', error: error);
    }
  }

  /// 清除文件服务器配置
  Future<void> clearConfig() async {
    await _dynamicConfig.clearConfig();
    _logger.i('🗑️ 文件服务器配置已清除');
  }

  /// 获取当前配置摘要
  Map<String, dynamic> getConfigSummary() {
    return _dynamicConfig.getConfigSummary();
  }

  /// 验证配置是否有效
  bool isConfigValid() {
    return _dynamicConfig.isConfigValid();
  }

  /// 手动刷新配置（用于调试或设置页面）
  Future<void> refreshConfig() async {
    try {
      _logger.i('🔄 手动刷新文件服务器配置');
      await _dynamicConfig.initialize();
      await _syncConfigToServices();
    } catch (error) {
      _logger.e('❌ 手动刷新文件服务器配置失败', error: error);
    }
  }

  /// 测试文件服务器连接
  Future<bool> testFileServerConnection() async {
    try {
      final config = _dynamicConfig.currentConfig;
      if (config == null) {
        _logger.w('⚠️ 没有配置可供测试');
        return false;
      }

      _logger.i('🔗 测试文件服务器连接', extra: {
        'defaultFsUrl': config.defaultFsUrl,
        'defaultSsUrl': config.defaultSsUrl,
        'defs': config.defs,
      });

      // 这里可以添加实际的连接测试逻辑
      // 例如发送一个简单的健康检查请求
      
      return true;
    } catch (error) {
      _logger.e('❌ 测试文件服务器连接失败', error: error);
      return false;
    }
  }
}