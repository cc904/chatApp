import 'package:flutter/material.dart';

/// UI通知服务
/// 用于在应用程序中显示各种通知，不依赖于BuildContext
/// 这种设计模式将异步操作与UI更新完全分离
class UINotificationService {
  // 单例实现
  static final UINotificationService _instance = UINotificationService._internal();
  factory UINotificationService() => _instance;
  UINotificationService._internal();

  // 全局ScaffoldMessengerKey
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  // 获取当前的ScaffoldMessengerState
  ScaffoldMessengerState? get _messenger => scaffoldMessengerKey.currentState;

  // 显示一般消息
  void showMessage(String message, {Duration? duration}) {
    _messenger?.showSnackBar(SnackBar(
      content: Text(message),
      duration: duration ?? const Duration(seconds: 3),
    ));
  }

  // 显示错误消息
  void showError(String message, {Duration? duration}) {
    _messenger?.showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
      duration: duration ?? const Duration(seconds: 4),
    ));
  }

  // 显示成功消息
  void showSuccess(String message, {Duration? duration}) {
    _messenger?.showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.green,
      duration: duration ?? const Duration(seconds: 2),
    ));
  }

  // 显示警告消息
  void showWarning(String message, {Duration? duration}) {
    _messenger?.showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.orange,
      duration: duration ?? const Duration(seconds: 3),
    ));
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
      backgroundColor: Colors.blue,
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
