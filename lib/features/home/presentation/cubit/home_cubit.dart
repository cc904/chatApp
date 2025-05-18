import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cc/core/services/contact_service.dart';
import 'package:cc/core/services/socket_service.dart';
import 'package:cc/core/services/ui_notification_service.dart';
import 'package:cc/features/home/presentation/cubit/home_state.dart';
import 'package:cc/core/proto/generated/user.pb.dart' as proto;
import 'package:cc/core/proto/generated/message.pb.dart' as proto;

class HomeCubit extends Cubit<HomeState> {
  final ContactService _contactService;
  final SocketService _socketService;
  final UINotificationService _notificationService;
  StreamSubscription? _socketSubscription;

  HomeCubit({
    required ContactService contactService,
    required SocketService socketService,
    required UINotificationService notificationService,
  })  : _contactService = contactService,
        _socketService = socketService,
        _notificationService = notificationService,
        super(const HomeState()) {
    _init();
  }

  void _init() {
    _loadContacts();
    _setupSocketListeners();
  }

  Future<void> _loadContacts() async {
    try {
      emit(state.copyWith(isLoading: true));
      final contacts = await _contactService.getContacts();
      emit(state.copyWith(
        contacts: contacts,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: '加载联系人失败: $e',
        isLoading: false,
      ));
    }
  }

  void _setupSocketListeners() {
    _socketSubscription?.cancel();
    _socketSubscription = _socketService.onMessage.listen((message) {
      if (message is proto.UserStatusUpdate) {
        _handleUserStatusUpdate(message);
      } else if (message is proto.NewMessageProto) {
        _handleNewMessage(message);
      }
    });
  }

  void _handleUserStatusUpdate(proto.UserStatusUpdate update) {
    final userStatus = Map<String, String>.from(state.userStatus);
    userStatus[update.userId] = update.status;
    emit(state.copyWith(userStatus: userStatus));
  }

  void _handleNewMessage(proto.NewMessageProto message) {
    final notification = Notification(
      id: message.id,
      type: NotificationType.message,
      title: '新消息',
      body: message.content,
      timestamp: DateTime.fromMillisecondsSinceEpoch(message.timestamp.toInt()),
      data: {
        'conversationId': message.conversationId,
        'senderId': message.senderId,
      },
    );

    final notifications = List<Notification>.from(state.notifications)..add(notification);
    emit(state.copyWith(notifications: notifications));

    _notificationService.showNotification(
      notification.title,
      notification.body,
      duration: const Duration(seconds: 3),
    );
  }

  Future<void> refreshContacts() async {
    await _loadContacts();
  }

  Future<void> updateUserStatus(String status) async {
    try {
      await _socketService.emit('user:status', {'status': status});
    } catch (e) {
      emit(state.copyWith(error: '更新状态失败: $e'));
    }
  }

  void clearNotifications() {
    emit(state.copyWith(notifications: []));
  }

  Future<void> logout() async {
    try {
      await _socketService.disconnect();
      await _contactService.clearContacts();
      emit(const HomeState());
    } catch (e) {
      emit(state.copyWith(error: '退出登录失败: $e'));
    }
  }

  @override
  Future<void> close() {
    _socketSubscription?.cancel();
    return super.close();
  }
}
