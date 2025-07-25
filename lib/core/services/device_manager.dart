import 'dart:convert';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/proto/generated/auth.pb.dart';
import 'package:cc/core/services/secure_storage_service.dart';

// 条件导入：根据平台导入不同的设备信息获取实现
import 'device_manager_stub.dart'
    if (dart.library.io) 'device_manager_io.dart'
    if (dart.library.html) 'device_manager_web.dart';

/// 设备管理器
///
/// 负责设备标识符生成、设备信息收集和持久化存储
/// 每个设备具有唯一且持久的标识符，用于多设备会话管理
class DeviceManager {
  static const String _deviceInfoKey = 'cc_device_info';

  static final _logger = LogService.instance;
  static DeviceInfo? _cachedDeviceInfo;
  static String? _cachedDeviceId;

  /// 获取设备唯一标识符
  ///
  /// 如果设备ID不存在，会自动生成UUID并存储到安全存储
  /// 应用更新时保持ID不变，卸载重装后重新生成
  ///
  /// 返回: 设备唯一标识符字符串
  static Future<String> getDeviceId() async {
    if (_cachedDeviceId != null) {
      return _cachedDeviceId!;
    }

    try {
      final secureStorage = SecureStorageService();
      String? deviceId = await secureStorage.read('device_id');

      if (deviceId == null || deviceId.isEmpty) {
        deviceId = await _generateDeviceId();
        await secureStorage.write('device_id', deviceId);
        _logger.i('🆔 生成新设备ID', extra: {'deviceId': deviceId});
      } else {
        _logger.d('📱 获取已存储设备ID', extra: {'deviceId': deviceId});
      }

      _cachedDeviceId = deviceId;
      return deviceId;
    } catch (error) {
      _logger.e('获取设备ID失败', error: error, stackTrace: StackTrace.current);
      // 生成临时ID作为备用方案
      final fallbackId = _generateUUID();
      _cachedDeviceId = fallbackId;
      return fallbackId;
    }
  }

  /// 生成设备唯一标识符
  ///
  /// 简单生成UUID作为设备ID
  static Future<String> _generateDeviceId() async {
    try {
      return _generateUUID();
    } catch (error) {
      _logger.e('生成设备ID失败', error: error, stackTrace: StackTrace.current);
      // 使用简单UUID作为备用方案
      return _generateUUID();
    }
  }

  /// 生成UUID
  static String _generateUUID() {
    const uuid = Uuid();
    return uuid.v4();
  }

  /// 清理字符串，确保只包含HTTP Header允许的ASCII字符
  ///
  /// 移除或替换中文字符、特殊符号等非ASCII字符
  static String _sanitizeForHeader(String input) {
    // 移除中文字符和其他非ASCII字符，保留基本的ASCII字符
    final sanitized = input
        .replaceAll(RegExp(r'[^\x20-\x7E]'), '') // 移除非ASCII字符
        .replaceAll(RegExp(r'\s+'), ' ') // 合并多个空格
        .trim();

    // 如果清理后为空，返回默认值
    return sanitized.isEmpty ? 'Unknown' : sanitized;
  }

  /// 检查字符串是否包含非ASCII字符
  static bool _containsNonAscii(String input) {
    return RegExp(r'[^\x20-\x7E]').hasMatch(input);
  }


  /// 获取设备详细信息
  ///
  /// 收集设备类型、型号、操作系统版本、应用版本等信息
  /// 用于服务器端设备识别和管理
  ///
  /// 返回: DeviceInfo proto对象
  static Future<DeviceInfo> getDeviceInfo() async {
    if (_cachedDeviceInfo != null) {
      return _cachedDeviceInfo!;
    }

    // 先尝试从缓存加载
    final cachedInfo = await loadDeviceInfoFromCache();
    if (cachedInfo != null) {
      return cachedInfo;
    }

    try {
      final deviceId = await getDeviceId();
      final packageInfo = await PackageInfo.fromPlatform();

      // 使用平台特定的方法获取详细设备信息
      final deviceDetails = await getDetailedDeviceInfo(deviceId, packageInfo);

      final deviceInfo = DeviceInfo(
        deviceId: deviceId,
        deviceType: deviceDetails['deviceType']!,
        deviceModel: deviceDetails['deviceModel']!,
        osVersion: deviceDetails['osVersion']!,
        appVersion: deviceDetails['appVersion']!,
      );

      // 缓存设备信息并持久化
      _cachedDeviceInfo = deviceInfo;
      await _saveDeviceInfoToCache(deviceInfo);

      _logger.i('📱 获取设备信息成功', extra: {
        'deviceId': deviceId,
        'deviceType': deviceDetails['deviceType'],
        'deviceModel': deviceDetails['deviceModel'],
        'osVersion': deviceDetails['osVersion'],
        'appVersion': deviceDetails['appVersion'],
      });

      return deviceInfo;
    } catch (error) {
      _logger.e('获取设备信息失败', error: error, stackTrace: StackTrace.current);

      // 创建基础设备信息作为备用方案
      final fallbackDeviceInfo = DeviceInfo(
        deviceId: await getDeviceId(),
        deviceType: getStandardizedPlatformName(),
        deviceModel: 'Unknown',
        osVersion: getOperatingSystemVersion(),
        appVersion: '1.0.0',
      );

      _cachedDeviceInfo = fallbackDeviceInfo;
      return fallbackDeviceInfo;
    }
  }

  /// 保存设备信息到本地缓存
  static Future<void> _saveDeviceInfoToCache(DeviceInfo deviceInfo) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final deviceInfoMap = {
        'deviceId': deviceInfo.deviceId,
        'deviceType': deviceInfo.deviceType,
        'deviceModel': deviceInfo.deviceModel,
        'osVersion': deviceInfo.osVersion,
        'appVersion': deviceInfo.appVersion,
        'lastUpdated': DateTime.now().millisecondsSinceEpoch,
      };

      await prefs.setString(_deviceInfoKey, jsonEncode(deviceInfoMap));
      _logger.d('设备信息已缓存');
    } catch (error) {
      _logger.w('保存设备信息缓存失败', extra: {'error': error.toString()});
    }
  }

  /// 从本地缓存加载设备信息
  ///
  /// 在应用启动时快速获取设备信息，避免重复收集
  static Future<DeviceInfo?> loadDeviceInfoFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(_deviceInfoKey);

      if (cachedData != null) {
        final Map<String, dynamic> deviceInfoMap = jsonDecode(cachedData);

        // 检查缓存是否过期（7天）
        final lastUpdated = deviceInfoMap['lastUpdated'] as int?;
        if (lastUpdated != null) {
          final cacheAge = DateTime.now().millisecondsSinceEpoch - lastUpdated;
          const maxCacheAge = 7 * 24 * 60 * 60 * 1000; // 7天

          if (cacheAge > maxCacheAge) {
            _logger.d('设备信息缓存已过期，将重新获取');
            return null;
          }
        }

        final deviceInfo = DeviceInfo(
          deviceId: deviceInfoMap['deviceId'] ?? '',
          deviceType: deviceInfoMap['deviceType'] ?? '',
          deviceModel: deviceInfoMap['deviceModel'] ?? '',
          osVersion: deviceInfoMap['osVersion'] ?? '',
          appVersion: deviceInfoMap['appVersion'] ?? '',
        );

        // 检查缓存的设备信息是否包含非ASCII字符，如果有则清除缓存
        if (_containsNonAscii(deviceInfo.osVersion) ||
            _containsNonAscii(deviceInfo.deviceModel)) {
          _logger.d('检测到缓存包含非ASCII字符，清除缓存');
          await prefs.remove(_deviceInfoKey);
          _cachedDeviceInfo = null;
          return null;
        }

        _cachedDeviceInfo = deviceInfo;
        _logger.d('从缓存加载设备信息成功');
        return deviceInfo;
      }
    } catch (error) {
      _logger.w('加载设备信息缓存失败', extra: {'error': error.toString()});
    }

    return null;
  }

  /// 生成User-Agent字符串
  ///
  /// 用于HTTP请求头，提供设备和应用信息
  /// 格式: AppName/Version (Platform; OSVersion; DeviceModel)
  /// 注意：必须只包含ASCII字符，符合HTTP Header规范
  static Future<String> getUserAgent() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final deviceInfo = await getDeviceInfo();

      // 清理系统版本信息，移除中文字符和特殊符号
      final cleanOsVersion = _sanitizeForHeader(deviceInfo.osVersion);
      final cleanDeviceModel = _sanitizeForHeader(deviceInfo.deviceModel);

      return '${packageInfo.appName}/${packageInfo.version} '
          '(${deviceInfo.deviceType}; $cleanOsVersion; $cleanDeviceModel)';
    } catch (error) {
      _logger.w('生成User-Agent失败', extra: {'error': error.toString()});
      return 'CC/1.0.0 (Flutter; Unknown; Unknown)';
    }
  }

  /// 获取设备显示名称
  ///
  /// 生成用户友好的设备名称，用于设备管理界面显示
  static Future<String> getDeviceDisplayName() async {
    try {
      final deviceInfo = await getDeviceInfo();
      final timestamp = DateTime.now();
      final dateStr = '${timestamp.month}/${timestamp.day}';

      if (isMobilePlatform()) {
        return '${deviceInfo.deviceModel} ($dateStr)';
      } else {
        return '${deviceInfo.deviceType} - ${deviceInfo.deviceModel} ($dateStr)';
      }
    } catch (error) {
      _logger.w('生成设备显示名称失败', extra: {'error': error.toString()});
      return '未知设备 (${DateTime.now().month}/${DateTime.now().day})';
    }
  }

  /// 检查设备信息是否有效
  ///
  /// 验证缓存的设备信息是否完整和有效
  static bool isDeviceInfoValid(DeviceInfo? deviceInfo) {
    if (deviceInfo == null) return false;

    return deviceInfo.deviceId.isNotEmpty &&
        deviceInfo.deviceType.isNotEmpty &&
        deviceInfo.deviceModel.isNotEmpty &&
        deviceInfo.osVersion.isNotEmpty &&
        deviceInfo.appVersion.isNotEmpty;
  }
}
