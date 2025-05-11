import '../services/ui_notification_service.dart';

/// UI通知辅助工具类
/// 提供在各种场景中使用UINotificationService的便捷方法
class UINotificationHelper {
  /// 在异步操作中安全地显示消息
  /// 不需要检查context.mounted或在异步操作后使用context
  static void showMessage(String message, {Duration? duration}) {
    UINotificationService.instance.showNotification(message, duration: duration ?? const Duration(seconds: 2));
  }

  /// 在异步操作中安全地显示错误消息
  static void showError(String message, {Duration? duration}) {
    UINotificationService.instance.showError(message, duration: duration ?? const Duration(seconds: 3));
  }

  /// 在异步操作中安全地显示成功消息
  static void showSuccess(String message, {Duration? duration}) {
    UINotificationService.instance.showSuccess(message, duration: duration ?? const Duration(seconds: 2));
  }

  /// 在异步操作中安全地显示警告消息
  static void showWarning(String message, {Duration? duration}) {
    UINotificationService.instance.showWarning(message, duration: duration ?? const Duration(seconds: 3));
  }

  /// 在异步操作中安全地显示处理中消息
  static void showProcessing(String message, {Duration? duration}) {
    UINotificationService.instance.showProcessing(message, duration: duration ?? const Duration(seconds: 2));
  }

  /// 示例：如何在异步操作中使用此辅助工具
  static Future<void> exampleAsyncOperation() async {
    try {
      // 显示处理中状态
      showProcessing('正在处理...');

      // 模拟异步操作
      await Future.delayed(const Duration(seconds: 2));

      // 操作成功
      showSuccess('操作成功！');
    } catch (error) {
      // 处理错误
      showError('操作失败: $error');
    }
  }

  /// 包装异步函数并处理通知
  ///
  /// [action] 要执行的异步操作
  /// [loadingMessage] 加载时显示的消息
  /// [successMessage] 成功时显示的消息
  /// [errorMessage] 错误前缀消息
  /// [shouldShowLoading] 是否显示加载消息
  /// [shouldShowSuccess] 是否显示成功消息
  /// [shouldForceCleanupOnError] 是否在错误发生时强制清除所有通知
  static Future<T?> wrapWithNotification<T>({
    required Future<T> Function() action,
    String loadingMessage = '正在处理...',
    String successMessage = '操作成功',
    String errorMessage = '操作失败',
    bool shouldShowLoading = true,
    bool shouldShowSuccess = true,
    bool shouldForceCleanupOnError = false,
  }) async {
    try {
      // 显示加载中消息
      if (shouldShowLoading) {
        showProcessing(loadingMessage);
      }

      // 执行操作
      final result = await action();

      // 操作成功,清除当前消息并显示成功消息
      UINotificationService.instance.hideCurrentMessage();
      if (shouldShowSuccess) {
        showSuccess(successMessage);
      }

      return result;
    } catch (error) {
      // 发生错误,清除当前消息并显示错误消息
      if (shouldForceCleanupOnError) {
        UINotificationService.instance.clearAllMessages();
      } else {
        UINotificationService.instance.hideCurrentMessage();
      }

      showError('$errorMessage: $error');
      return null;
    }
  }
}
