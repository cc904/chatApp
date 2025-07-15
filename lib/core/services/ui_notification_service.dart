import 'package:flutter/material.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/constants/app_colors.dart';
import 'package:cc/core/widgets/top_notification.dart';
import 'package:cc/core/services/global_overlay_service.dart';

/// UI通知服务
/// 用于在应用程序中显示各种通知,不依赖于BuildContext
/// 这种设计模式将异步操作与UI更新完全分离
class UINotificationService {
  final LogService _logger = LogService.instance;

  // 全局ScaffoldMessengerKey
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  // 全局NavigatorKey，用于获取Context
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // 获取当前的ScaffoldMessengerState
  ScaffoldMessengerState? get _messenger => scaffoldMessengerKey.currentState;

  // 获取当前的BuildContext
  BuildContext? get _context {
    // 首先尝试从NavigatorState获取context
    final navigatorState = navigatorKey.currentState;
    if (navigatorState != null && navigatorState.mounted) {
      return navigatorState.context;
    }
    
    // 如果NavigatorState不可用，尝试从key获取
    return navigatorKey.currentContext;
  }

  // 便捷的静态访问方法
  static final UINotificationService _instance = UINotificationService();
  static UINotificationService get instance => _instance;

  /// 显示通知
  /// [title] 通知标题
  /// [body] 通知内容
  Future<void> showNotification(String title, String body,
      {required Duration duration}) async {
    try {
      _logger.i('显示通知: $title - $body');
      _showSnackBar(body);
    } catch (e) {
      _logger.e('显示通知失败', error: e);
    }
  }

  /// 取消所有通知
  Future<void> cancelAllNotifications() async {
    try {
      _logger.i('取消所有通知');
      clearAllMessages();
    } catch (e) {
      _logger.e('取消所有通知失败', error: e);
    }
  }

  /// 显示snackbar通知
  void _showSnackBar(
    String message, {
    Color backgroundColor = AppColors.primary,
    Duration duration = const Duration(seconds: 2),
    SnackBarAction? action,
  }) {
    _messenger?.hideCurrentSnackBar();
    _messenger?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration,
        action: action,
      ),
    );
  }

  /// 显示成功通知
  void showSuccess(String message,
      {Duration duration = const Duration(seconds: 2)}) {
    _showSnackBar(
      message,
      backgroundColor: Colors.green,
      duration: duration,
    );
  }

  /// 显示错误通知
  void showError(String message,
      {Duration duration = const Duration(seconds: 3)}) {
    _showSnackBar(
      message,
      backgroundColor: Colors.red,
      duration: duration,
    );
  }

  /// 显示警告通知
  void showWarning(String message,
      {Duration duration = const Duration(seconds: 3)}) {
    _showSnackBar(
      message,
      backgroundColor: Colors.orange,
      duration: duration,
    );
  }

  /// 显示信息通知
  void showInfo(String message,
      {Duration duration = const Duration(seconds: 2)}) {
    _showSnackBar(
      message,
      backgroundColor: AppColors.primary,
      duration: duration,
    );
  }

  // 显示处理中消息
  void showProcessing(String message, {Duration? duration}) {
    _messenger?.showSnackBar(SnackBar(
      content: Row(
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(width: 10),
          Text(message),
        ],
      ),
      duration: duration ?? const Duration(seconds: 2),
      backgroundColor: AppColors.primary,
    ));
  }

  // 隐藏当前消息
  void hideCurrentMessage() {
    _messenger?.hideCurrentSnackBar();
  }

  // 移除所有消息
  void clearAllMessages() {
    _messenger?.clearSnackBars();
  }

  /// 显示顶部横幅通知
  /// [title] 通知标题
  /// [message] 通知内容
  /// [duration] 显示时长
  /// [icon] 通知图标
  /// [onTap] 点击回调
  void showTopBanner({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 3),
    IconData? icon,
    VoidCallback? onTap,
  }) {
    final content = Row(
      children: [
        if (icon != null) ...[
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                message,
                style: const TextStyle(color: Colors.white),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );

    _messenger?.hideCurrentSnackBar();
    _messenger?.showSnackBar(
      SnackBar(
        content: GestureDetector(
          onTap: () {
            hideCurrentMessage();
            onTap?.call();
          },
          child: content,
        ),
        backgroundColor: AppColors.primary,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// 显示Toast通知
  /// [message] 通知内容
  /// [duration] 显示时长
  /// [type] 通知类型
  void showToast({
    required String message,
    Duration duration = const Duration(seconds: 2),
    ToastType type = ToastType.info,
  }) {
    final Color backgroundColor = switch (type) {
      ToastType.success => Colors.green,
      ToastType.error => Colors.red,
      ToastType.warning => Colors.orange,
      ToastType.info => AppColors.primary,
    };

    _showSnackBar(
      message,
      backgroundColor: backgroundColor,
      duration: duration,
    );
  }

  /// 显示顶部通知（新的主要通知方式）
  /// [title] 通知标题
  /// [message] 通知内容
  /// [type] 通知类型
  /// [duration] 显示时长
  /// [onTap] 点击回调
  void showTopNotification({
    required String title,
    required String message,
    TopNotificationType type = TopNotificationType.info,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onTap,
  }) {
    try {
      // 优先尝试使用全局Overlay服务
      if (GlobalOverlayService.instance.hasOverlay) {
        _logger.i('使用全局Overlay服务显示顶部通知: $title - $message');
        
        final style = TopNotificationStyle.fromType(type);
        
        GlobalOverlayService.instance.showTopNotification(
          title: title,
          message: message,
          icon: style.icon,
          backgroundColor: style.backgroundColor,
          textColor: style.textColor,
          duration: duration,
          onTap: onTap,
        );
        return;
      }

      // 如果全局Overlay服务不可用，尝试传统方式
      _logger.w('全局Overlay服务不可用，尝试传统方式');
      
      // 多种Context获取策略
      BuildContext? context = _context;
      
      // 如果主要context不可用，尝试其他方式
      if (context == null) {
        _logger.w('主要Context不可用，尝试其他获取方式');
        
        // 尝试从ScaffoldMessenger获取context
        context = scaffoldMessengerKey.currentContext;
        
        if (context == null) {
          _logger.w('无法获取任何Context，降级使用SnackBar');
          _showSnackBar('$title: $message');
          return;
        }
      }

      // 详细的Overlay查找和调试
      _logger.d('开始查找Overlay', extra: {
        'contextType': context.runtimeType.toString(),
        'contextWidget': context.widget.runtimeType.toString(),
      });

      // 尝试多种Overlay查找策略
      OverlayState? overlay;
      
      // 策略1: 根Overlay
      try {
        overlay = Overlay.maybeOf(context, rootOverlay: true);
        if (overlay != null) {
          _logger.d('找到根Overlay');
        }
      } catch (e) {
        _logger.w('根Overlay查找失败', extra: {'error': e.toString()});
      }
      
      // 策略2: 最近的Overlay
      if (overlay == null) {
        try {
          overlay = Overlay.maybeOf(context, rootOverlay: false);
          if (overlay != null) {
            _logger.d('找到最近的Overlay');
          }
        } catch (e) {
          _logger.w('最近Overlay查找失败', extra: {'error': e.toString()});
        }
      }
      
      // 策略3: 尝试查找祖先Navigator的Overlay
      if (overlay == null) {
        try {
          final navigator = Navigator.maybeOf(context);
          if (navigator != null) {
            overlay = navigator.overlay;
            if (overlay != null) {
              _logger.d('从Navigator找到Overlay');
            }
          }
        } catch (e) {
          _logger.w('Navigator Overlay查找失败', extra: {'error': e.toString()});
        }
      }
      
      // 策略4: 尝试直接使用全局NavigatorKey的Overlay
      if (overlay == null) {
        try {
          final globalNavigator = navigatorKey.currentState;
          if (globalNavigator != null && globalNavigator.mounted) {
            overlay = globalNavigator.overlay;
            if (overlay != null) {
              _logger.d('从全局Navigator找到Overlay');
            }
          }
        } catch (e) {
          _logger.w('全局Navigator Overlay查找失败', extra: {'error': e.toString()});
        }
      }
      
      if (overlay == null) {
        _logger.w('所有Overlay查找策略都失败，降级使用SnackBar');
        _showSnackBar('$title: $message');
        return;
      }

      _logger.i('显示顶部通知: $title - $message');
      
      final style = TopNotificationStyle.fromType(type);
      
      TopNotificationManager.instance.show(
        context: context,
        title: title,
        message: message,
        icon: style.icon,
        backgroundColor: style.backgroundColor,
        textColor: style.textColor,
        duration: duration,
        onTap: onTap,
      );
    } catch (e) {
      _logger.e('显示顶部通知失败', error: e);
      // 降级使用SnackBar
      _showSnackBar('$title: $message');
    }
  }

  /// 显示消息通知（专门用于聊天消息）
  /// [senderName] 发送者名称
  /// [messageText] 消息内容
  /// [conversationName] 会话名称（可选）
  /// [onTap] 点击回调
  void showMessageNotification({
    required String senderName,
    required String messageText,
    String? conversationName,
    VoidCallback? onTap,
  }) {
    final title = conversationName != null 
        ? '$conversationName ($senderName)'
        : senderName;

    showTopNotification(
      title: title,
      message: messageText,
      type: TopNotificationType.message,
      duration: const Duration(seconds: 4),
      onTap: onTap,
    );
  }

  /// 隐藏顶部通知
  void hideTopNotification() {
    // 优先使用全局Overlay服务
    if (GlobalOverlayService.instance.hasOverlay) {
      GlobalOverlayService.instance.hideNotification();
    } else {
      TopNotificationManager.instance.hide();
    }
  }
}

/// Toast通知类型
enum ToastType {
  success,
  error,
  warning,
  info,
}
