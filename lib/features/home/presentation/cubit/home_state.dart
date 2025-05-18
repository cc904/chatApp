import 'package:equatable/equatable.dart';
import 'package:cc/core/database/models/user.dart';

/// 通知类型枚举
enum NotificationType {
  message, // 新消息通知
  friend, // 好友请求通知
  group, // 群组通知
  system // 系统通知
}

/// 通知模型
class Notification {
  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final DateTime timestamp;
  final Map<String, dynamic>? data;

  Notification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.timestamp,
    this.data,
  });
}

/// 首页状态类
class HomeState extends Equatable {
  final List<User> contacts;
  final Map<String, String> userStatus;
  final List<Notification> notifications;
  final bool isLoading;
  final String? error;

  const HomeState({
    this.contacts = const [],
    this.userStatus = const {},
    this.notifications = const [],
    this.isLoading = false,
    this.error,
  });

  HomeState copyWith({
    List<User>? contacts,
    Map<String, String>? userStatus,
    List<Notification>? notifications,
    bool? isLoading,
    String? error,
  }) {
    return HomeState(
      contacts: contacts ?? this.contacts,
      userStatus: userStatus ?? this.userStatus,
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [contacts, userStatus, notifications, isLoading, error];
}
