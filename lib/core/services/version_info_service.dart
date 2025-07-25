import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:cc/core/services/log_service.dart';

// 条件导入：根据平台导入不同的版本信息实现
import 'version_platform_stub.dart'
    if (dart.library.io) 'version_platform_io.dart'
    if (dart.library.html) 'version_platform_web.dart';

/// 版本信息管理服务
class VersionInfoService {
  static final VersionInfoService _instance = VersionInfoService._internal();
  static VersionInfoService get instance => _instance;
  VersionInfoService._internal();

  final LogService _logger = LogService.instance;
  
  PackageInfo? _packageInfo;
  DeviceInfo? _deviceInfo;

  /// 初始化版本信息
  Future<void> initialize() async {
    try {
      _packageInfo = await PackageInfo.fromPlatform();
      _deviceInfo = await _getDeviceInfo();
      
      _logger.i('版本信息初始化成功', extra: {
        'version': currentVersion,
        'buildNumber': buildNumber,
        'platform': platformName,
      });
    } catch (error) {
      _logger.e('版本信息初始化失败', error: error);
    }
  }

  /// 获取设备信息
  Future<DeviceInfo> _getDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    
    try {
      final platformInfo = await getPlatformSpecificInfo(deviceInfo);
      return DeviceInfo(
        deviceId: 'device-${DateTime.now().millisecondsSinceEpoch}',
        model: 'Device',
        brand: getPlatformName(),
        osVersion: platformInfo,
        systemName: getPlatformName(),
      );
    } catch (e) {
      return DeviceInfo(
        deviceId: 'unknown-device',
        model: 'Unknown',
        brand: 'Unknown',
        osVersion: 'Unknown',
        systemName: getPlatformName(),
      );
    }
  }

  /// 当前版本号
  String get currentVersion => _packageInfo?.version ?? '1.0.0';

  /// 构建号
  String get buildNumber => _packageInfo?.buildNumber ?? '1';

  /// 应用名称
  String get appName => _packageInfo?.appName ?? 'ChatApp';

  /// 包名
  String get packageName => _packageInfo?.packageName ?? 'com.example.chatapp';

  /// 平台名称
  String get platformName {
    if (kIsWeb) return 'Web';
    return getPlatformName();
  }

  /// 是否调试模式
  bool get isDebugMode => kDebugMode;

  /// 获取设备信息
  DeviceInfo? get deviceInfo => _deviceInfo;

  /// 生成客户端信息用于登录
  Map<String, dynamic> getClientInfo() {
    return {
      'version': currentVersion,
      'buildNumber': buildNumber,
      'platform': platformName,
      'deviceInfo': _deviceInfo?.toMap() ?? {},
      'appName': appName,
      'packageName': packageName,
      'isDebugMode': isDebugMode,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
  }

  /// 比较版本号
  /// 返回: -1 当前版本较低, 0 版本相同, 1 当前版本较高
  int compareVersion(String serverVersion) {
    final currentParts = currentVersion.split('.').map(int.parse).toList();
    final serverParts = serverVersion.split('.').map(int.parse).toList();
    
    final maxLength = [currentParts.length, serverParts.length].reduce((a, b) => a > b ? a : b);
    
    // 补齐版本号长度
    while (currentParts.length < maxLength) {
      currentParts.add(0);
    }
    while (serverParts.length < maxLength) {
      serverParts.add(0);
    }
    
    for (int i = 0; i < maxLength; i++) {
      if (currentParts[i] < serverParts[i]) return -1;
      if (currentParts[i] > serverParts[i]) return 1;
    }
    
    return 0;
  }

  /// 检查是否需要更新
  bool needsUpdate(String serverVersion) {
    return compareVersion(serverVersion) < 0;
  }

  /// 获取版本信息摘要
  String getVersionSummary() {
    return '''
应用版本: $currentVersion ($buildNumber)
平台: $platformName
设备: ${_deviceInfo?.model ?? 'Unknown'}
系统: ${_deviceInfo?.systemName ?? 'Unknown'} ${_deviceInfo?.osVersion ?? ''}
调试模式: ${isDebugMode ? '是' : '否'}
''';
  }
}

/// 设备信息类
class DeviceInfo {
  final String deviceId;
  final String model;
  final String brand;
  final String osVersion;
  final String systemName;

  const DeviceInfo({
    required this.deviceId,
    required this.model,
    required this.brand,
    required this.osVersion,
    required this.systemName,
  });

  factory DeviceInfo.unknown() {
    return const DeviceInfo(
      deviceId: 'unknown',
      model: 'Unknown',
      brand: 'Unknown',
      osVersion: 'Unknown',
      systemName: 'Unknown',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'deviceId': deviceId,
      'model': model,
      'brand': brand,
      'osVersion': osVersion,
      'systemName': systemName,
    };
  }

  @override
  String toString() {
    return '$brand $model ($systemName $osVersion)';
  }
}