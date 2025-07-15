import 'package:flutter/material.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/widgets/top_notification.dart';

/// 全局Overlay服务
/// 管理应用级别的Overlay显示，确保顶部通知能够正确显示
class GlobalOverlayService {
  static final GlobalOverlayService _instance = GlobalOverlayService._internal();
  static GlobalOverlayService get instance => _instance;
  GlobalOverlayService._internal();

  final LogService _logger = LogService.instance;
  
  // 全局Overlay状态
  OverlayState? _overlayState;
  
  // 当前显示的通知Entry
  OverlayEntry? _currentNotificationEntry;

  /// 初始化全局Overlay
  void initialize(OverlayState overlayState) {
    _overlayState = overlayState;
    _logger.i('全局Overlay服务已初始化');
  }

  /// 清理全局Overlay
  void dispose() {
    hideNotification();
    _overlayState = null;
    _logger.i('全局Overlay服务已清理');
  }

  /// 显示顶部通知
  void showTopNotification({
    required String title,
    required String message,
    IconData? icon,
    Color? backgroundColor,
    Color? textColor,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onTap,
  }) {
    try {
      if (_overlayState == null) {
        _logger.w('全局Overlay未初始化，无法显示顶部通知');
        return;
      }

      // 隐藏现有通知
      hideNotification();

      _currentNotificationEntry = OverlayEntry(
        builder: (context) => Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: TopNotification(
            title: title,
            message: message,
            icon: icon,
            backgroundColor: backgroundColor,
            textColor: textColor,
            duration: duration,
            onTap: onTap,
            onClose: hideNotification,
          ),
        ),
      );

      _overlayState!.insert(_currentNotificationEntry!);
      _logger.i('全局顶部通知已显示: $title');
    } catch (e) {
      _logger.e('显示全局顶部通知失败', error: e);
    }
  }

  /// 隐藏当前通知
  void hideNotification() {
    if (_currentNotificationEntry != null) {
      try {
        _currentNotificationEntry!.remove();
        _currentNotificationEntry = null;
        _logger.d('全局顶部通知已隐藏');
      } catch (e) {
        _logger.w('隐藏全局顶部通知失败', extra: {'error': e.toString()});
      }
    }
  }

  /// 检查是否有可用的Overlay
  bool get hasOverlay => _overlayState != null;
}

/// 全局Overlay初始化器Widget
/// 在MaterialApp中使用，确保Overlay服务正确初始化
class GlobalOverlayInitializer extends StatefulWidget {
  final Widget child;

  const GlobalOverlayInitializer({
    super.key,
    required this.child,
  });

  @override
  State<GlobalOverlayInitializer> createState() => _GlobalOverlayInitializerState();
}

class _GlobalOverlayInitializerState extends State<GlobalOverlayInitializer> {
  @override
  void initState() {
    super.initState();
    
    // 延迟初始化，确保Overlay已经创建
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final overlay = Overlay.maybeOf(context);
      if (overlay != null) {
        GlobalOverlayService.instance.initialize(overlay);
      }
    });
  }

  @override
  void dispose() {
    GlobalOverlayService.instance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}