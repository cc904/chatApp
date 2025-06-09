import 'dart:async';

import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/services/communication_service.dart';
import 'package:cc/core/services/proto_socket_service.dart';
import 'package:cc/core/services/ui_notification_service.dart';

/// 网络状态通知服务
/// 统一管理网络状态的UI反馈和用户通知
class NetworkNotificationService {
  static final NetworkNotificationService _instance =
      NetworkNotificationService._internal();
  static NetworkNotificationService get instance => _instance;
  NetworkNotificationService._internal();

  final LogService _logger = LogService.instance;
  final CommunicationService _communicationService = CommunicationService();
  final UINotificationService _uiNotificationService =
      UINotificationService.instance;

  StreamSubscription<SocketConnectionStatus>? _connectionStateSubscription;
  StreamSubscription<bool>? _reconnectingStateSubscription;

  // 当前显示的通知状态
  SocketConnectionStatus? _currentNotificationState;
  bool _isReconnectingNotificationShown = false;

  /// 初始化网络状态通知监听
  void initialize() {
    _logger.i('初始化网络状态通知服务');

    // 监听连接状态变化
    _connectionStateSubscription = _communicationService.connectionStateStream
        .listen(_handleConnectionStateChange);

    // 监听重连状态变化
    _reconnectingStateSubscription = _communicationService
        .reconnectingStateStream
        .listen(_handleReconnectingStateChange);
  }

  /// 处理连接状态变化
  void _handleConnectionStateChange(SocketConnectionStatus state) {
    _logger.d('网络状态通知: 连接状态变化', extra: {'state': state.toString()});

    // 避免重复通知相同状态
    if (_currentNotificationState == state) {
      return;
    }

    _currentNotificationState = state;

    switch (state) {
      case SocketConnectionStatus.connecting:
        _showConnectingNotification();
        break;
      case SocketConnectionStatus.connected:
        _showConnectedNotification();
        break;
      case SocketConnectionStatus.disconnected:
        _showDisconnectedNotification();
        break;
      case SocketConnectionStatus.error:
        _showErrorNotification();
        break;
      case SocketConnectionStatus.reconnecting:
        // 重连状态由重连状态流单独处理
        break;
    }
  }

  /// 处理重连状态变化
  void _handleReconnectingStateChange(bool isReconnecting) {
    _logger.d('网络状态通知: 重连状态变化', extra: {'isReconnecting': isReconnecting});

    if (isReconnecting && !_isReconnectingNotificationShown) {
      _showReconnectingNotification();
      _isReconnectingNotificationShown = true;
    } else if (!isReconnecting && _isReconnectingNotificationShown) {
      _hideReconnectingNotification();
      _isReconnectingNotificationShown = false;
    }
  }

  /// 显示连接中通知 (轻量提示)
  void _showConnectingNotification() {
    _logger.d('显示连接中通知');
    // 使用info通知，2秒后自动消失
    _uiNotificationService.showInfo('正在连接...');
  }

  /// 显示已连接通知
  void _showConnectedNotification() {
    _logger.d('显示已连接通知');

    // 如果之前有错误状态，显示恢复连接的提示
    if (_currentNotificationState == SocketConnectionStatus.error ||
        _currentNotificationState == SocketConnectionStatus.disconnected) {
      _uiNotificationService.showSuccess('网络连接已恢复');
    }

    // 隐藏所有网络相关的持久通知
    _hideAllPersistentNotifications();
  }

  /// 显示断开连接通知
  void _showDisconnectedNotification() {
    _logger.d('显示断开连接通知');
    _uiNotificationService.showWarning(
      '网络连接已断开',
      duration: const Duration(seconds: 5),
    );
  }

  /// 显示连接错误通知
  void _showErrorNotification() {
    _logger.d('显示连接错误通知');
    _uiNotificationService.showError(
      '网络连接异常',
      duration: const Duration(seconds: 8),
    );
  }

  /// 显示重连中通知 (覆盖层)
  void _showReconnectingNotification() {
    _logger.d('显示重连中通知');
    // 显示处理中通知，较长的持续时间
    _uiNotificationService.showProcessing(
      '正在重新连接...',
      duration: const Duration(seconds: 30),
    );
  }

  /// 隐藏重连中通知
  void _hideReconnectingNotification() {
    _logger.d('隐藏重连中通知');
    // 隐藏重连相关的通知
    _uiNotificationService.hideCurrentMessage();
  }

  /// 隐藏所有持久通知
  void _hideAllPersistentNotifications() {
    _logger.d('隐藏所有持久通知');
    _uiNotificationService.hideCurrentMessage();
  }

  /// 手动触发重连
  /// 提供给UI层调用的重连方法
  Future<void> triggerReconnect() async {
    _logger.i('手动触发重连');

    try {
      _uiNotificationService.showInfo('正在尝试重连...');

      final success = await _communicationService.reconnect();

      if (success) {
        _uiNotificationService.showSuccess('重连成功');
      } else {
        _uiNotificationService.showError('重连失败，请稍后再试');
      }
    } catch (error) {
      _logger.e('手动重连失败', error: error);
      _uiNotificationService.showError('重连异常: ${error.toString()}');
    }
  }

  /// 获取当前网络状态信息
  Map<String, dynamic> getNetworkInfo() {
    return {
      'isConnected': _communicationService.isConnected,
      'isInitialized': _communicationService.isInitialized,
      'currentNotificationState': _currentNotificationState?.toString(),
      'isReconnectingNotificationShown': _isReconnectingNotificationShown,
      'connectionInfo': _communicationService.getConnectionInfo(),
    };
  }

  /// 释放资源
  void dispose() {
    _logger.i('释放网络状态通知服务资源');
    _connectionStateSubscription?.cancel();
    _reconnectingStateSubscription?.cancel();
    _hideAllPersistentNotifications();
  }
}
