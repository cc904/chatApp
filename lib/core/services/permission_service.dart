import 'package:permission_handler/permission_handler.dart';
import 'package:logger/logger.dart';
import 'dart:io' show Platform;
import 'package:cc/core/services/voice_record_service.dart';

/// 权限管理服务
class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  final Logger _logger = Logger();

  /// 检查麦克风权限状态
  Future<PermissionStatus> checkMicrophonePermission() async {
    try {
      // macOS上permission_handler可能不完全支持，使用record包的权限检查
      if (Platform.isMacOS) {
        _logger.i('macOS平台，使用record包检查权限');
        final voiceService = VoiceRecordService();
        final hasPermission = await voiceService.hasPermission();
        _logger.i('record包权限检查结果: $hasPermission');
        return hasPermission ? PermissionStatus.granted : PermissionStatus.denied;
      }
      
      final status = await Permission.microphone.status;
      _logger.i('麦克风权限状态检查: ${status.toString()}');
      return status;
    } catch (e, stackTrace) {
      _logger.e('检查麦克风权限失败: $e', error: e, stackTrace: stackTrace);
      
      // 如果权限检查失败，在macOS上尝试record包检查
      if (Platform.isMacOS) {
        try {
          _logger.w('permission_handler失败，尝试record包权限检查');
          final voiceService = VoiceRecordService();
          final hasPermission = await voiceService.hasPermission();
          return hasPermission ? PermissionStatus.granted : PermissionStatus.denied;
        } catch (recordError) {
          _logger.e('record包权限检查也失败: $recordError');
          return PermissionStatus.denied;
        }
      }
      
      return PermissionStatus.denied;
    }
  }

  /// 请求麦克风权限
  Future<PermissionStatus> requestMicrophonePermission() async {
    try {
      // macOS上permission_handler可能不完全支持，macOS权限通常在实际使用时由系统处理
      if (Platform.isMacOS) {
        _logger.i('macOS平台，权限将在录音时由系统处理');
        // 在macOS上，当第一次录音时，系统会自动弹出权限对话框
        // 这里我们直接返回granted，让录音逻辑继续
        return PermissionStatus.granted;
      }
      
      _logger.i('开始请求麦克风权限');
      final status = await Permission.microphone.request();
      _logger.i('麦克风权限请求结果: ${status.toString()}');
      return status;
    } catch (e, stackTrace) {
      _logger.e('请求麦克风权限失败: $e', error: e, stackTrace: stackTrace);
      
      // macOS上出错时让系统处理
      if (Platform.isMacOS) {
        _logger.w('macOS权限请求失败，将由系统在录音时处理');
        return PermissionStatus.granted;
      }
      
      return PermissionStatus.denied;
    }
  }

  /// 检查并请求麦克风权限（如果需要）
  /// 返回是否已获得权限
  Future<bool> ensureMicrophonePermission() async {
    try {
      final currentStatus = await checkMicrophonePermission();
      
      // 如果已经有权限，直接返回
      if (currentStatus.isGranted) {
        _logger.i('麦克风权限已授予');
        return true;
      }

      // macOS上如果权限被拒绝，说明用户明确拒绝了，我们尊重这个选择
      if (Platform.isMacOS) {
        _logger.w('macOS平台权限被拒绝，将在录音时由系统处理权限请求');
        // 即使record包说没权限，我们还是让它尝试录音
        // 因为macOS系统会在实际录音时弹出权限对话框
        return true;
      }

      // 移动平台：如果权限被永久拒绝，返回false
      if (currentStatus.isPermanentlyDenied) {
        _logger.w('麦克风权限被永久拒绝');
        return false;
      }

      // 移动平台：请求权限
      final newStatus = await requestMicrophonePermission();
      return newStatus.isGranted;
    } catch (e, stackTrace) {
      _logger.e('确保麦克风权限失败: $e', error: e, stackTrace: stackTrace);
      
      // macOS上出错时让系统处理
      if (Platform.isMacOS) {
        _logger.w('macOS权限确保失败，将由系统在录音时处理');
        return true;
      }
      
      return false;
    }
  }

  /// 检查是否可以显示权限解释对话框
  Future<bool> shouldShowMicrophoneRationale() async {
    try {
      final status = await Permission.microphone.status;
      return status.isDenied;
    } catch (e, stackTrace) {
      _logger.e('检查是否应显示权限解释失败: $e', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// 打开应用设置页面
  Future<bool> openDeviceAppSettings() async {
    try {
      _logger.i('尝试打开应用设置页面');
      return await openAppSettings();
    } catch (e, stackTrace) {
      _logger.e('打开应用设置页面失败: $e', error: e, stackTrace: stackTrace);
      return false;
    }
  }
}