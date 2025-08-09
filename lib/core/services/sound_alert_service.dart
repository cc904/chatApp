import 'package:cc/core/services/log_service.dart';

// 平台条件导入
import 'sound_alert_platform_stub.dart'
    if (dart.library.io) 'sound_alert_platform_io.dart'
    if (dart.library.html) 'sound_alert_platform_web.dart';

/// 声音提示服务（跨平台包装）
class SoundAlertService {
  SoundAlertService._();
  static final SoundAlertService instance = SoundAlertService._();

  final LogService _logger = LogService.instance;

  /// 播放新消息提示音（各平台内部实现）
  Future<void> playMessageAlert() async {
    try {
      await platformPlayMessageAlert();
    } catch (e) {
      _logger.w('播放消息提示音失败', extra: {'error': e.toString()});
    }
  }

  /// Web 平台：绑定用户手势以解锁音频（其他平台为 no-op）
  void tryUnlockWebAudio() {
    platformTryUnlockWebAudio();
  }
}
