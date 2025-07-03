import 'package:cc/core/proto/generated/contacts.pb.dart';
import 'package:cc/core/services/proto_socket_service.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/database/database_initializer.dart';
import 'package:cc/core/database/models/user.dart';
import 'package:fixnum/fixnum.dart';
import 'package:isar/isar.dart';

/// 联系人服务
/// 负责处理联系人相关的操作，如更新联系人信息
class ContactService {
  static final ContactService _instance = ContactService._internal();
  factory ContactService() => _instance;
  ContactService._internal() {
    // 🔧 自动注册事件监听器
    _initializeEventHandlers();
  }

  static ContactService get instance => _instance;

  final _logger = LogService.instance;
  final _socketService = ProtoSocketService();

  // 是否已初始化事件监听器
  bool _isEventHandlersInitialized = false;

  /// 初始化事件监听器
  void _initializeEventHandlers() {
    if (_isEventHandlersInitialized) {
      _logger.d('ContactService事件监听器已初始化，跳过重复初始化');
      return;
    }

    try {
      registerEventHandlers();
      _isEventHandlersInitialized = true;
      _logger.i('ContactService事件监听器初始化完成');
    } catch (e) {
      _logger.e('ContactService事件监听器初始化失败', extra: {'error': e.toString()});
    }
  }

  /// 更新联系人信息
  ///
  /// [contactId] 联系人ID
  /// [nickname] 自定义昵称（可选）
  /// [remark] 备注信息（可选）
  /// [blocked] 是否拉黑（可选）
  /// [isFavorite] 是否收藏（可选）
  ///
  /// 返回操作是否成功
  Future<bool> updateContact({
    required String contactId,
    String? nickname,
    String? remark,
    bool? blocked,
    bool? isFavorite,
  }) async {
    try {
      _logger.i('开始更新联系人信息', extra: {
        'contactId': contactId,
        'nickname': nickname,
        'remark': remark,
        'blocked': blocked,
        'isFavorite': isFavorite,
      });

      // 1️⃣ 先更新本地数据库，构造updatedFields列表
      final updatedFields = <String>[];
      if (nickname != null) updatedFields.add('custom_nickname');
      if (remark != null) updatedFields.add('remark');
      if (blocked != null) updatedFields.add('blocked');
      if (isFavorite != null) updatedFields.add('is_favorite');

      // 本地更新
      final isar = _getDatabaseInstance();
      if (isar != null) {
        final user = await isar
            .collection<User>()
            .filter()
            .userIdEqualTo(contactId)
            .findFirst();

        if (user != null) {
          await isar.writeTxn(() async {
            if (nickname != null) {
              user.name = nickname; // 显示名使用nickname
            }
            // 备注等字段可扩展到User模型，如果不存在则忽略
            await isar.collection<User>().put(user);
          });

          _logger.d('本地联系人数据已预更新', extra: {
            'contactId': contactId,
            'updatedFields': updatedFields,
          });

          // 发送本地事件，提前刷新UI
          _socketService.emit('local:contact:updated', {
            'contactId': contactId,
            'updatedFields': updatedFields,
            'timestamp': DateTime.now().millisecondsSinceEpoch,
            'source': 'contact_service_local',
          });

          // 如果名称变更，提前刷新私聊会话名称
          if (updatedFields.any((f) => ['custom_nickname'].contains(f))) {
            _socketService.emit('local:conversation:contact_updated', {
              'contactId': contactId,
              'updatedFields': updatedFields,
              'timestamp': DateTime.now().millisecondsSinceEpoch,
              'source': 'contact_service_local',
            });
          }
        }
      }

      // 2️⃣ 然后向服务器发送更新请求
      final request = UpdateContactRequest(
        contactId: contactId,
        nickname: nickname,
        remark: remark,
        blocked: blocked,
        isFavorite: isFavorite,
        timestamp: Int64(DateTime.now().millisecondsSinceEpoch),
      );

      _socketService.emitProto('contact:update', request);

      _logger.i('联系人更新请求已发送');
      return true;
    } catch (e) {
      _logger.e('更新联系人信息失败', extra: {
        'contactId': contactId,
        'error': e.toString(),
      });
      return false;
    }
  }

  /// 注册事件监听器
  void registerEventHandlers() {
    // 监听联系人更新响应
    _socketService.on('contact:update:response', _handleUpdateContactResponse);

    // 监听联系人信息更新事件
    _socketService.on('contact:updated', _handleContactUpdated);
  }

  /// 处理联系人更新响应
  void _handleUpdateContactResponse(dynamic data) {
    try {
      final response = UpdateContactResponse.fromBuffer(data);

      _logger.i('收到联系人更新响应', extra: {
        'success': response.success,
        'message': response.message,
        'contactId':
            response.hasContact() ? response.contact.userId : 'unknown',
        'updatedFields': response.updatedFields,
        'timestamp':
            response.hasTimestamp() ? response.timestamp.toInt() : null,
      });

      if (response.success) {
        _logger.i('联系人信息更新成功');

        // 🎯 成功时的业务逻辑
        _handleUpdateContactSuccess(response);
      } else {
        _logger.w('联系人信息更新失败: ${response.message}');

        // 🔥 失败时的业务逻辑
        _handleUpdateContactFailure(response);
      }
    } catch (e) {
      _logger.e('处理联系人更新响应失败', extra: {'error': e.toString()});

      // 🔥 解析失败的业务逻辑
      _handleUpdateContactParseError(e);
    }
  }

  /// 处理联系人更新成功的情况
  ///
  /// [response] - 成功的更新响应
  Future<void> _handleUpdateContactSuccess(
      UpdateContactResponse response) async {
    try {
      // 1️⃣ 更新本地数据库
      if (response.hasContact()) {
        await _updateLocalContactFromResponse(response);
      }

      // 2️⃣ 通知相关UI组件更新
      await _notifyContactUpdateSuccess(response);

      // 3️⃣ 记录成功日志
      _logger.i('联系人更新成功处理完成', extra: {
        'contactId': response.contact.userId,
        'updatedFields': response.updatedFields,
      });
    } catch (e) {
      _logger.e('处理联系人更新成功响应失败', extra: {
        'contactId':
            response.hasContact() ? response.contact.userId : 'unknown',
        'error': e.toString(),
      });
    }
  }

  /// 处理联系人更新失败的情况
  ///
  /// [response] - 失败的更新响应
  Future<void> _handleUpdateContactFailure(
      UpdateContactResponse response) async {
    try {
      // 1️⃣ 发送错误通知给UI层
      _socketService.emit('local:contact:update:failed', {
        'contactId': response.hasContact() ? response.contact.userId : null,
        'message': response.message,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

      // 2️⃣ 根据错误类型进行特殊处理
      if (response.message.contains('网络')) {
        _logger.w('联系人更新网络错误，可能需要重试');
        // TODO: 实现重试机制
      } else if (response.message.contains('权限')) {
        _logger.w('联系人更新权限错误，用户可能需要重新登录');
        // TODO: 触发权限错误处理
      }

      _logger.w('联系人更新失败处理完成', extra: {
        'message': response.message,
      });
    } catch (e) {
      _logger.e('处理联系人更新失败响应失败', extra: {
        'error': e.toString(),
      });
    }
  }

  /// 处理联系人更新响应解析错误
  ///
  /// [error] - 解析错误
  void _handleUpdateContactParseError(dynamic error) {
    try {
      // 1️⃣ 发送解析错误通知
      _socketService.emit('local:contact:update:parse_error', {
        'error': error.toString(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

      // 2️⃣ 记录详细错误信息
      _logger.e('联系人更新响应解析失败', extra: {
        'error': error.toString(),
        'errorType': error.runtimeType.toString(),
      });
    } catch (e) {
      _logger.e('处理联系人更新解析错误失败', extra: {
        'originalError': error.toString(),
        'handlingError': e.toString(),
      });
    }
  }

  /// 从更新响应中更新本地联系人数据
  ///
  /// [response] - 联系人更新响应
  Future<void> _updateLocalContactFromResponse(
      UpdateContactResponse response) async {
    try {
      final isar = _getDatabaseInstance();
      if (isar == null) {
        _logger.w('数据库未初始化，跳过联系人本地更新');
        return;
      }

      final contactId = response.contact.userId;

      // 查找现有联系人
      final existingUser = await isar
          .collection<User>()
          .filter()
          .userIdEqualTo(contactId)
          .findFirst();

      if (existingUser == null) {
        _logger.w('本地未找到需要更新的联系人', extra: {'contactId': contactId});
        return;
      }

      // 根据更新的字段进行选择性更新
      await isar.writeTxn(() async {
        if (response.updatedFields.contains('nickname') ||
            response.updatedFields.contains('custom_nickname')) {
          // 重新计算显示名称
          final updatedUser = User.fromProto(response.contact);
          existingUser.name = updatedUser.name;

          _logger.d('更新联系人显示名称', extra: {
            'contactId': contactId,
            'newName': existingUser.name,
          });
        }

        if (response.updatedFields.contains('avatar')) {
          existingUser.avatar =
              response.contact.hasAvatar() ? response.contact.avatar : null;

          _logger.d('更新联系人头像', extra: {
            'contactId': contactId,
            'hasAvatar': existingUser.avatar != null,
          });
        }

        if (response.updatedFields.contains('phone')) {
          existingUser.phone =
              response.contact.hasPhone() ? response.contact.phone : null;
        }

        if (response.updatedFields.contains('email')) {
          existingUser.email =
              response.contact.hasEmail() ? response.contact.email : null;
        }

        if (response.updatedFields.contains('status')) {
          existingUser.status =
              response.contact.hasStatus() ? response.contact.status : null;
        }

        // 更新最后活跃时间
        if (response.contact.hasLastActiveTime()) {
          existingUser.lastActiveTime = DateTime.fromMillisecondsSinceEpoch(
              response.contact.lastActiveTime.toInt());
        }

        // 保存更新
        await isar.collection<User>().put(existingUser);
      });

      _logger.d('本地联系人数据更新完成', extra: {
        'contactId': contactId,
        'updatedFields': response.updatedFields,
      });
    } catch (e) {
      _logger.e('更新本地联系人数据失败', extra: {
        'contactId':
            response.hasContact() ? response.contact.userId : 'unknown',
        'error': e.toString(),
      });
      rethrow;
    }
  }

  /// 通知联系人更新成功
  ///
  /// [response] - 成功的更新响应
  Future<void> _notifyContactUpdateSuccess(
      UpdateContactResponse response) async {
    try {
      final contactId = response.contact.userId;

      // 1️⃣ 通知ContactCubit刷新联系人列表
      _socketService.emit('local:contact:updated', {
        'contactId': contactId,
        'updatedFields': response.updatedFields,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'source': 'contact_service_response',
      });

      // 2️⃣ 如果更新了名称相关字段，通知ChatsCubit更新会话列表
      if (response.updatedFields
          .any((field) => ['nickname', 'custom_nickname'].contains(field))) {
        _socketService.emit('local:conversation:contact_updated', {
          'contactId': contactId,
          'updatedFields': response.updatedFields,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'source': 'contact_service_response',
        });

        _logger.d('已通知会话联系人信息更新', extra: {
          'contactId': contactId,
          'updatedFields': response.updatedFields,
        });
      }

      // 3️⃣ 如果更新了头像，发送头像更新通知
      if (response.updatedFields.contains('avatar')) {
        _socketService.emit('local:avatar:updated', {
          'userId': contactId,
          'avatar':
              response.contact.hasAvatar() ? response.contact.avatar : null,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'source': 'contact_service_response',
        });

        _logger.d('已通知头像更新', extra: {
          'contactId': contactId,
        });
      }

      // 4️⃣ 发送成功通知给UI（用于显示成功提示）
      _socketService.emit('local:contact:update:success', {
        'contactId': contactId,
        'message': response.message,
        'updatedFields': response.updatedFields,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

      _logger.d('联系人更新成功通知发送完成', extra: {
        'contactId': contactId,
        'notificationsSent': [
          'contact_updated',
          'conversation_contact_updated',
          'avatar_updated',
          'update_success'
        ].where((notif) {
          if (notif == 'conversation_contact_updated') {
            return response.updatedFields.any(
                (field) => ['nickname', 'custom_nickname'].contains(field));
          }
          if (notif == 'avatar_updated') {
            return response.updatedFields.contains('avatar');
          }
          return true;
        }).toList(),
      });
    } catch (e) {
      _logger.e('发送联系人更新成功通知失败', extra: {
        'contactId':
            response.hasContact() ? response.contact.userId : 'unknown',
        'error': e.toString(),
      });
      // 通知失败不应该阻断主流程
    }
  }

  /// 处理联系人信息更新事件
  ///
  /// 当其他用户或设备更新了联系人信息时，会收到此事件
  /// 需要更新本地数据库中的联系人信息，并通知相关UI组件
  void _handleContactUpdated(dynamic data) async {
    try {
      final event = ContactUpdateEvent.fromBuffer(data);

      _logger.i('收到联系人信息更新事件', extra: {
        'contactId': event.contact.userId,
        'updatedFields': event.updatedFields,
        'updateSource': event.updateSource,
      });

      // 🎯 核心业务逻辑：更新本地数据库中的联系人信息
      await _updateLocalContactData(event);

      // 🔔 通知相关系统组件数据已更新
      await _notifyContactUpdated(event);

      _logger.i('联系人更新事件处理完成', extra: {
        'contactId': event.contact.userId,
        'success': true,
      });
    } catch (e) {
      _logger.e('处理联系人更新事件失败', extra: {
        'error': e.toString(),
        'stackTrace': e is Error ? e.stackTrace.toString() : null,
      });
    }
  }

  /// 更新本地数据库中的联系人信息
  ///
  /// [event] - 联系人更新事件
  Future<void> _updateLocalContactData(ContactUpdateEvent event) async {
    try {
      // 获取数据库实例
      final isar = _getDatabaseInstance();
      if (isar == null) {
        _logger.w('数据库未初始化，跳过联系人更新');
        return;
      }

      // 查找现有联系人
      final existingUser = await isar
          .collection<User>()
          .filter()
          .userIdEqualTo(event.contact.userId)
          .findFirst();

      if (existingUser == null) {
        _logger.i('联系人不存在，创建新联系人', extra: {
          'contactId': event.contact.userId,
        });

        // 创建新联系人
        final newUser = User.fromProto(event.contact);
        await isar.writeTxn(() async {
          await isar.collection<User>().put(newUser);
        });
      } else {
        _logger.i('更新现有联系人信息', extra: {
          'contactId': event.contact.userId,
          'updatedFields': event.updatedFields,
        });

        // 更新现有联系人
        await isar.writeTxn(() async {
          // 🎯 根据更新的字段选择性更新
          if (event.updatedFields.contains('nickname') ||
              event.updatedFields.contains('custom_nickname')) {
            // 重新计算显示名称（因为可能涉及自定义昵称更新）
            final updatedUser = User.fromProto(event.contact);
            existingUser.name = updatedUser.name;
          }

          if (event.updatedFields.contains('avatar')) {
            existingUser.avatar =
                event.contact.hasAvatar() ? event.contact.avatar : null;
          }

          if (event.updatedFields.contains('phone')) {
            existingUser.phone =
                event.contact.hasPhone() ? event.contact.phone : null;
          }

          if (event.updatedFields.contains('email')) {
            existingUser.email =
                event.contact.hasEmail() ? event.contact.email : null;
          }

          if (event.updatedFields.contains('status')) {
            existingUser.status =
                event.contact.hasStatus() ? event.contact.status : null;
          }

          // 更新最后活跃时间
          if (event.contact.hasLastActiveTime()) {
            existingUser.lastActiveTime = DateTime.fromMillisecondsSinceEpoch(
                event.contact.lastActiveTime.toInt());
          }

          // 保存更新
          await isar.collection<User>().put(existingUser);
        });
      }

      _logger.d('本地联系人数据更新成功', extra: {
        'contactId': event.contact.userId,
        'updatedFields': event.updatedFields,
      });
    } catch (e) {
      _logger.e('更新本地联系人数据失败', extra: {
        'contactId': event.contact.userId,
        'error': e.toString(),
      });
      rethrow;
    }
  }

  /// 通知相关组件联系人已更新
  ///
  /// [event] - 联系人更新事件
  Future<void> _notifyContactUpdated(ContactUpdateEvent event) async {
    try {
      // 🔄 通知ContactCubit刷新联系人列表
      await _notifyContactCubit();

      // 🔄 通知ChatsCubit刷新会话列表（如果涉及会话中的联系人）
      await _notifyChatsCubit(event);

      // 🔄 如果更新的是头像，通知相关UI组件刷新
      if (event.updatedFields.contains('avatar')) {
        await _notifyAvatarUpdated(event.contact.userId);
      }

      _logger.d('联系人更新通知发送完成', extra: {
        'contactId': event.contact.userId,
      });
    } catch (e) {
      _logger.e('发送联系人更新通知失败', extra: {
        'contactId': event.contact.userId,
        'error': e.toString(),
      });
      // 通知失败不应该阻断主流程，只记录错误
    }
  }

  /// 通知ContactCubit刷新联系人列表
  Future<void> _notifyContactCubit() async {
    try {
      // 💡 这里可以通过EventBus或依赖注入的方式获取ContactCubit实例
      // 由于这是一个服务类，我们使用间接的方式通知

      // 发送一个自定义事件，UI层可以监听此事件来刷新数据
      _socketService.emit('local:contact:updated', {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'source': 'contact_service',
      });

      _logger.d('已发送联系人更新通知给ContactCubit');
    } catch (e) {
      _logger.e('通知ContactCubit失败', extra: {'error': e.toString()});
    }
  }

  /// 通知ChatsCubit相关会话需要刷新
  Future<void> _notifyChatsCubit(ContactUpdateEvent event) async {
    try {
      // 如果联系人的名称或头像发生变化，需要更新相关的私聊会话
      if (event.updatedFields.any((field) =>
          ['nickname', 'custom_nickname', 'avatar'].contains(field))) {
        _socketService.emit('local:conversation:contact_updated', {
          'contactId': event.contact.userId,
          'updatedFields': event.updatedFields,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });

        _logger.d('已发送会话联系人更新通知', extra: {
          'contactId': event.contact.userId,
        });
      }
    } catch (e) {
      _logger.e('通知ChatsCubit失败', extra: {'error': e.toString()});
    }
  }

  /// 通知头像更新事件
  Future<void> _notifyAvatarUpdated(String userId) async {
    try {
      _socketService.emit('local:avatar:updated', {
        'userId': userId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

      _logger.d('已发送头像更新通知', extra: {'userId': userId});
    } catch (e) {
      _logger.e('通知头像更新失败', extra: {'error': e.toString()});
    }
  }

  /// 获取数据库实例
  ///
  /// 返回Isar数据库实例，如果未初始化则返回null
  Isar? _getDatabaseInstance() {
    try {
      if (!DatabaseInitializer.isInitialized) {
        _logger.w('数据库未初始化');
        return null;
      }
      return DatabaseInitializer.isar;
    } catch (e) {
      _logger.e('获取数据库实例失败', extra: {'error': e.toString()});
      return null;
    }
  }
}
