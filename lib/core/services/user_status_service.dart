import 'dart:async';
import 'package:cc/core/services/communication_service.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/services/proto_socket_service.dart';

/// 用户在线状态
enum UserOnlineStatus { online, offline, away, busy, unknown }

/// 用户状态信息
class UserStatusInfo {
  final String userId;
  final UserOnlineStatus status;
  final DateTime lastActive;
  final bool typing;
  final String? conversationId; // 如果用户正在某个会话中输入

  UserStatusInfo({
    required this.userId,
    required this.status,
    required this.lastActive,
    this.typing = false,
    this.conversationId,
  });

  @override
  String toString() => 'UserStatusInfo(userId: $userId, status: $status, lastActive: $lastActive, typing: $typing, conversationId: $conversationId)';
}

/// 用户状态服务
/// 处理用户在线状态和输入状态等相关事件
class UserStatusService {
  final LogService _logger = LogService.instance;
  final CommunicationService _communicationService = CommunicationService();
  final ProtoSocketService _socketService = ProtoSocketService();

  // 用户状态数据缓存
  final Map<String, UserStatusInfo> _userStatusCache = {};

  // 状态变更事件流控制器
  final _statusStreamController = StreamController<UserStatusInfo>.broadcast();
  Stream<UserStatusInfo> get statusStream => _statusStreamController.stream;

  // 单例模式
  static final UserStatusService _instance = UserStatusService._internal();
  factory UserStatusService() => _instance;

  UserStatusService._internal() {
    _registerStatusEvents();
  }

  /// 注册用户状态相关的事件监听
  void _registerStatusEvents() {
    // 监听用户状态事件
    _communicationService.onRawEvent('user:status', _handleUserStatusEvent);

    // 监听用户开始输入事件
    _communicationService.onRawEvent('typing', _handleTypingEvent);

    // 监听用户停止输入事件
    _communicationService.onRawEvent('typing:stop', _handleTypingStopEvent);

    _logger.i('用户状态事件注册完成');
  }

  /// 处理用户状态事件
  void _handleUserStatusEvent(dynamic data) {
    try {
      _logger.i('收到用户状态事件', extra: {'data': data});

      if (data is Map && data['userId'] != null) {
        final userId = data['userId'].toString();
        final statusStr = data['status']?.toString() ?? 'unknown';
        final timestamp = data['timestamp'] != null ? DateTime.fromMillisecondsSinceEpoch(int.parse(data['timestamp'].toString())) : DateTime.now();

        // 解析状态
        final status = _parseStatus(statusStr);

        // 更新状态缓存
        final userStatus = UserStatusInfo(
          userId: userId,
          status: status,
          lastActive: timestamp,
          typing: _userStatusCache[userId]?.typing ?? false,
          conversationId: _userStatusCache[userId]?.conversationId,
        );

        _userStatusCache[userId] = userStatus;

        // 发送状态变更事件
        _statusStreamController.add(userStatus);

        _logger.i('用户状态已更新', extra: {'userId': userId, 'status': status});
      } else {
        _logger.w('收到的用户状态数据格式无效', extra: {'data': data});
      }
    } catch (e, stack) {
      _logger.e('处理用户状态事件出错', error: e, stackTrace: stack);
    }
  }

  /// 处理用户开始输入事件
  void _handleTypingEvent(dynamic data) {
    try {
      _logger.i('收到用户开始输入事件', extra: {'data': data});

      if (data is Map && data['userId'] != null && data['conversationId'] != null) {
        final userId = data['userId'].toString();
        final conversationId = data['conversationId'].toString();

        // 获取当前状态（如果存在）或创建新状态
        final currentStatus = _userStatusCache[userId] ??
            UserStatusInfo(
              userId: userId,
              status: UserOnlineStatus.online, // 如果用户正在输入，假设他们在线
              lastActive: DateTime.now(),
            );

        // 更新为输入状态
        final userStatus = UserStatusInfo(
          userId: userId,
          status: currentStatus.status,
          lastActive: DateTime.now(), // 更新最后活动时间
          typing: true,
          conversationId: conversationId,
        );

        _userStatusCache[userId] = userStatus;

        // 发送状态变更事件
        _statusStreamController.add(userStatus);

        _logger.i('用户开始输入', extra: {'userId': userId, 'conversationId': conversationId});
      }
    } catch (e, stack) {
      _logger.e('处理用户输入事件出错', error: e, stackTrace: stack);
    }
  }

  /// 处理用户停止输入事件
  void _handleTypingStopEvent(dynamic data) {
    try {
      _logger.i('收到用户停止输入事件', extra: {'data': data});

      if (data is Map && data['userId'] != null) {
        final userId = data['userId'].toString();

        // 获取当前状态
        final currentStatus = _userStatusCache[userId];
        if (currentStatus != null) {
          // 更新为非输入状态
          final userStatus = UserStatusInfo(
            userId: userId,
            status: currentStatus.status,
            lastActive: DateTime.now(), // 更新最后活动时间
            typing: false,
            conversationId: null, // 清除会话ID
          );

          _userStatusCache[userId] = userStatus;

          // 发送状态变更事件
          _statusStreamController.add(userStatus);

          _logger.i('用户停止输入', extra: {'userId': userId});
        }
      }
    } catch (e, stack) {
      _logger.e('处理用户停止输入事件出错', error: e, stackTrace: stack);
    }
  }

  /// 解析状态字符串为枚举值
  UserOnlineStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'online':
        return UserOnlineStatus.online;
      case 'offline':
        return UserOnlineStatus.offline;
      case 'away':
        return UserOnlineStatus.away;
      case 'busy':
        return UserOnlineStatus.busy;
      default:
        return UserOnlineStatus.unknown;
    }
  }

  /// 获取用户当前状态
  UserStatusInfo? getUserStatus(String userId) {
    return _userStatusCache[userId];
  }

  /// 获取所有在线用户
  List<UserStatusInfo> getOnlineUsers() {
    return _userStatusCache.values
        .where((status) => status.status == UserOnlineStatus.online || status.status == UserOnlineStatus.busy || status.status == UserOnlineStatus.away)
        .toList();
  }

  /// 设置当前用户状态
  Future<void> setMyStatus(UserOnlineStatus status) async {
    try {
      _logger.i('设置当前用户状态', extra: {'status': status});

      // 准备状态数据
      final statusData = {
        'status': status.toString().split('.').last,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      // 使用Socket.IO的emit方法发送原始事件数据
      // 不使用Protobuf，直接发送JSON数据
      _socketService.emit('user:status:update', statusData);

      _logger.i('状态更新已发送');
    } catch (e, stack) {
      _logger.e('设置用户状态失败', error: e, stackTrace: stack);
    }
  }

  /// 释放资源
  void dispose() {
    _statusStreamController.close();
  }
}
