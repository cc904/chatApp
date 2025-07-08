import 'package:flutter/material.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/constants/app_colors.dart';

/// UI通知服务
/// 用于在应用程序中显示各种通知,不依赖于BuildContext
/// 这种设计模式将异步操作与UI更新完全分离
class UINotificationService {
  final LogService _logger = LogService.instance;

  // 全局ScaffoldMessengerKey
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  // 获取当前的ScaffoldMessengerState
  ScaffoldMessengerState? get _messenger => scaffoldMessengerKey.currentState;

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
}
