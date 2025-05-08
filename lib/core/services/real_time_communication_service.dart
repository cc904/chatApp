import 'dart:async';

import 'package:cc/core/constants/app_config.dart';
import 'package:cc/core/services/socket_service.dart';
import 'package:cc/core/services/types.dart';
import 'package:cc/core/services/log_service.dart';

/// 用户状态事件
class UserStatusEvent {
  final String userId;
  final bool isOnline;
  final int timestamp;

  UserStatusEvent({
    required this.userId,
    required this.isOnline,
    required this.timestamp,
  });
}

/// 消息事件
class MessageEvent {
  final Map<String, dynamic> data;
  final String type; // 'new', 'delivered', 'read'

  MessageEvent({
    required this.data,
    required this.type,
  });
}

/// 输入状态事件
class TypingStatusEvent {
  final String userId;
  final String conversationId;
  final bool isTyping;
  final int timestamp;

  TypingStatusEvent({
    required this.userId,
    required this.conversationId,
    required this.isTyping,
    required this.timestamp,
  });
}

/// 同步状态枚举
enum SyncStatus {
  idle,
  synchronizing,
  error,
}

/// 实时通信服务
/// 负责管理Socket.IO连接和事件分发
class RealTimeCommunicationService {
  final LogService _logger = LogService('real_time_communication_service.dart');
  final SocketService _socketService = SocketService.getInstance();

  // 标记是否已初始化
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // Socket订阅集合
  final List<StreamSubscription> _socketSubscriptions = [];

  // 事件流控制器
  final StreamController<UserStatusEvent> _userStatusController = StreamController<UserStatusEvent>.broadcast();
  final StreamController<MessageEvent> _messageController = StreamController<MessageEvent>.broadcast();
  final StreamController<TypingStatusEvent> _typingStatusController = StreamController<TypingStatusEvent>.broadcast();
  final StreamController<SyncStatus> _syncStatusController = StreamController<SyncStatus>.broadcast();

  // 通用事件流控制器，用于转发未处理的Socket事件
  final StreamController<Map<String, dynamic>> _genericEventController = StreamController<Map<String, dynamic>>.broadcast();

  // 对外暴露的事件流
  Stream<UserStatusEvent> get userStatusStream => _userStatusController.stream;
  Stream<MessageEvent> get messageStream => _messageController.stream;
  Stream<TypingStatusEvent> get typingStatusStream => _typingStatusController.stream;
  Stream<SyncStatus> get syncStatusStream => _syncStatusController.stream;
  Stream<Map<String, dynamic>> get genericEventStream => _genericEventController.stream;

  // 单例模式
  static final RealTimeCommunicationService _instance = RealTimeCommunicationService._internal();
  factory RealTimeCommunicationService() => _instance;
  RealTimeCommunicationService._internal();

  /// 初始化Socket连接
  Future<bool> initConnection({
    required String userId,
    required String token,
    required String serverUrl,
    DataEncoding encoding = DataEncoding.json,
    bool isSimulationMode = false,
  }) async {
    if (_isInitialized) {
      _logger.w('实时通信服务已初始化，无需重复初始化');
      return true;
    }

    try {
      _logger.i('初始化实时通信连接', extra: {
        'userId': userId,
        'serverUrl': serverUrl,
        'isSimulationMode': isSimulationMode,
      });

      // 设置模拟模式
      if (AppConfig().isSimulationMode != isSimulationMode) {
        AppConfig().isSimulationMode = isSimulationMode;
      }

      // 初始化Socket连接
      final connected = await _socketService.init(
        serverUrl: serverUrl,
        authToken: token,
        encoding: encoding,
      );

      if (!connected) {
        _logger.e('Socket连接初始化失败');
        return false;
      }

      // 设置事件监听
      _setupSocketEventListeners();

      // 发送用户上线状态
      _socketService.sendUserOnline();

      _isInitialized = true;
      _logger.i('实时通信服务初始化成功');
      return true;
    } catch (e) {
      _logger.e('初始化实时通信服务失败', error: e);
      return false;
    }
  }

  /// 关闭Socket连接
  Future<void> closeConnection() async {
    _logger.i('关闭实时通信连接');

    // 取消所有事件订阅
    for (final subscription in _socketSubscriptions) {
      await subscription.cancel();
    }
    _socketSubscriptions.clear();

    // 发送用户下线状态
    if (_isInitialized) {
      _socketService.sendUserOffline();
    }

    // 断开Socket连接
    _socketService.disconnect();
    _isInitialized = false;
  }

  /// 重新连接
  Future<bool> reconnect({
    required String userId,
    required String token,
    required String serverUrl,
  }) async {
    _logger.i('尝试重新连接实时通信');

    // 关闭现有连接
    await closeConnection();

    // 初始化新连接
    return initConnection(
      userId: userId,
      token: token,
      serverUrl: serverUrl,
    );
  }

  /// 设置Socket事件监听器
  void _setupSocketEventListeners() {
    // 取消之前的所有订阅
    for (final subscription in _socketSubscriptions) {
      subscription.cancel();
    }
    _socketSubscriptions.clear();

    // 连接相关事件
    _socketSubscriptions.add(_socketService.on(SocketEvent.connect).listen((_) {
      _logger.i('Socket连接成功');
      _syncStatusController.add(SyncStatus.idle);
    }));

    _socketSubscriptions.add(_socketService.on(SocketEvent.disconnect).listen((reason) {
      _logger.w('Socket断开连接', extra: {'reason': reason});
      _syncStatusController.add(SyncStatus.error);
    }));

    _socketSubscriptions.add(_socketService.on(SocketEvent.connectError).listen((error) {
      _logger.e('Socket连接错误', error: error);
      _syncStatusController.add(SyncStatus.error);
    }));

    // 用户状态事件
    _socketSubscriptions.add(_socketService.on(SocketEvent.userOnline).listen((data) {
      _logger.i('用户上线', extra: {'data': data});
      _handleUserOnlineStatus(data, true);
    }));

    _socketSubscriptions.add(_socketService.on(SocketEvent.userOffline).listen((data) {
      _logger.i('用户下线', extra: {'data': data});
      _handleUserOnlineStatus(data, false);
    }));

    // 消息相关事件
    _socketSubscriptions.add(_socketService.on(SocketEvent.newMessage).listen((data) {
      _logger.i('收到新消息', extra: {'data': data});
      _messageController.add(MessageEvent(data: data, type: 'new'));
    }));

    _socketSubscriptions.add(_socketService.on(SocketEvent.messageDelivered).listen((data) {
      _logger.i('消息已送达', extra: {'data': data});
      _messageController.add(MessageEvent(data: data, type: 'delivered'));
    }));

    _socketSubscriptions.add(_socketService.on(SocketEvent.messageRead).listen((data) {
      _logger.i('消息已读', extra: {'data': data});
      _messageController.add(MessageEvent(data: data, type: 'read'));
    }));

    // 输入状态事件
    _socketSubscriptions.add(_socketService.on(SocketEvent.typing).listen((data) {
      _logger.i('用户正在输入', extra: {'data': data});
      _handleTypingStatus(data, true);
    }));

    _socketSubscriptions.add(_socketService.on(SocketEvent.stopTyping).listen((data) {
      _logger.i('用户停止输入', extra: {'data': data});
      _handleTypingStatus(data, false);
    }));

    // 联系人同步事件
    _socketSubscriptions.add(_socketService.on(SocketEvent.contactsSynced).listen((data) {
      _logger.i('联系人同步完成', extra: {'data': data});
      // 转发原始事件数据，由业务层处理
      _genericEventController.add({
        'event': 'contactsSynced',
        'data': data,
      });
    }));
  }

  /// 处理用户在线状态
  void _handleUserOnlineStatus(Map<String, dynamic> data, bool isOnline) {
    try {
      final userId = data['userId'] as String?;
      if (userId == null) return;

      _userStatusController.add(UserStatusEvent(
        userId: userId,
        isOnline: isOnline,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      ));
    } catch (e) {
      _logger.e('处理用户在线状态失败', error: e);
    }
  }

  /// 处理输入状态
  void _handleTypingStatus(Map<String, dynamic> data, bool isTyping) {
    try {
      final conversationId = data['conversationId'] as String?;
      final userId = data['userId'] as String?;

      if (conversationId == null || userId == null) return;

      _typingStatusController.add(TypingStatusEvent(
        userId: userId,
        conversationId: conversationId,
        isTyping: isTyping,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      ));
    } catch (e) {
      _logger.e('处理输入状态失败', error: e);
    }
  }

  /// 发送原始事件
  /// 向Socket服务发送自定义事件和数据
  /// [eventName] - 事件名称
  /// [data] - 事件数据
  void emitEvent(String eventName, Map<String, dynamic> data) {
    if (!_isInitialized) {
      _logger.w('实时通信服务未初始化，无法发送事件');
      return;
    }

    try {
      _socketService.emit(eventName, data);
      _logger.i('发送事件成功', extra: {'event': eventName, 'data': data});
    } catch (e) {
      _logger.e('发送事件失败', error: e);
    }
  }

  /// 释放资源
  void dispose() {
    closeConnection();
    _userStatusController.close();
    _messageController.close();
    _typingStatusController.close();
    _syncStatusController.close();
    _genericEventController.close();
  }
}
