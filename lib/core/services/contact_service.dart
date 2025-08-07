import 'package:cc/core/proto/generated/contacts.pb.dart';
import 'package:cc/core/services/proto_socket_service.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/database/drift_database.dart';
import 'package:cc/core/adapters/user_adapter.dart';
import 'package:fixnum/fixnum.dart';
import 'package:drift/drift.dart';

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
      final database = AppDatabase.instance;
      final user = await (database.select(database.users)
          ..where((u) => u.userId.equals(contactId))).getSingleOrNull();

      if (user != null) {
        await database.transaction(() async {
          // 构建要更新的字段Map
          final updateMap = <String, dynamic>{};
          
          if (nickname != null) {
            updateMap['nickname'] = nickname;
          }
          
          if (remark != null) {
            updateMap['remark'] = remark;
          }
          
          // 如果有字段需要更新，则执行更新
          if (updateMap.isNotEmpty) {
            final companionMap = <String, Value<Object?>>{};
            
            if (nickname != null) {
              companionMap['nickname'] = Value(nickname);
            }
            
            if (remark != null) {
              companionMap['remark'] = Value(remark);
            }
            
            await (database.update(database.users)
              ..where((u) => u.userId.equals(contactId)))
              .write(UsersCompanion(
                nickname: nickname != null ? Value(nickname) : const Value.absent(),
                remark: remark != null ? Value(remark) : const Value.absent(),
              ));
          }
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
      final database = AppDatabase.instance;
      final contactId = response.contact.userId;

      // 查找现有联系人
      final existingUser = await (database.select(database.users)
          ..where((u) => u.userId.equals(contactId))).getSingleOrNull();

      if (existingUser == null) {
        _logger.w('本地未找到需要更新的联系人', extra: {'contactId': contactId});
        return;
      }

      // 根据更新的字段进行选择性更新
      await database.transaction(() async {
        var updatedUser = existingUser;
        
        if (response.updatedFields.contains('nickname') ||
            response.updatedFields.contains('custom_nickname')) {
          // 重新计算显示名称
          final protoUser = UserAdapter.fromUserProto(response.contact);
          updatedUser = updatedUser.copyWith(name: protoUser.name);

          _logger.d('更新联系人显示名称', extra: {
            'contactId': contactId,
            'newName': protoUser.name,
          });
        }

        if (response.updatedFields.contains('avatar')) {
          final avatar = response.contact.hasAvatar() ? response.contact.avatar : null;
          updatedUser = updatedUser.copyWith(avatar: Value(avatar));

          _logger.d('更新联系人头像', extra: {
            'contactId': contactId,
            'hasAvatar': avatar != null,
          });
        }

        if (response.updatedFields.contains('phone')) {
          final phone = response.contact.hasPhone() ? response.contact.phone : null;
          updatedUser = updatedUser.copyWith(phone: Value(phone));
        }

        if (response.updatedFields.contains('email')) {
          final email = response.contact.hasEmail() ? response.contact.email : null;
          updatedUser = updatedUser.copyWith(email: Value(email));
        }

        if (response.updatedFields.contains('status')) {
          final status = response.contact.hasStatus() ? response.contact.status : null;
          updatedUser = updatedUser.copyWith(status: Value(status));
        }

        // 更新最后活跃时间
        if (response.contact.hasLastActiveTime()) {
          final lastActiveTime = DateTime.fromMillisecondsSinceEpoch(response.contact.lastActiveTime.toInt());
          updatedUser = updatedUser.copyWith(lastActiveTime: Value(lastActiveTime));
        }

        // 保存更新
        await database.update(database.users).replace(updatedUser);
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
      final database = AppDatabase.instance;
      final contactId = event.contact.userId;

      // 查找现有联系人
      final existingUser = await (database.select(database.users)
          ..where((u) => u.userId.equals(contactId))).getSingleOrNull();

      if (existingUser == null) {
        _logger.i('联系人不存在，创建新联系人', extra: {
          'contactId': contactId,
        });

        // 创建新联系人
        final newUser = UserAdapter.fromUserProto(event.contact);
        await database.transaction(() async {
          await database.into(database.users).insert(newUser);
        });
      } else {
        _logger.i('更新现有联系人信息', extra: {
          'contactId': contactId,
          'updatedFields': event.updatedFields,
        });

        // 更新现有联系人
        await database.transaction(() async {
          var updatedUser = existingUser;
          
          // 🎯 根据更新的字段选择性更新
          if (event.updatedFields.contains('nickname') ||
              event.updatedFields.contains('custom_nickname')) {
            // 重新计算显示名称（因为可能涉及自定义昵称更新）
            final protoUser = UserAdapter.fromUserProto(event.contact);
            updatedUser = updatedUser.copyWith(name: protoUser.name);
          }

          if (event.updatedFields.contains('avatar')) {
            final avatar = event.contact.hasAvatar() ? event.contact.avatar : null;
            updatedUser = updatedUser.copyWith(avatar: Value(avatar));
          }

          if (event.updatedFields.contains('phone')) {
            final phone = event.contact.hasPhone() ? event.contact.phone : null;
            updatedUser = updatedUser.copyWith(phone: Value(phone));
          }

          if (event.updatedFields.contains('email')) {
            final email = event.contact.hasEmail() ? event.contact.email : null;
            updatedUser = updatedUser.copyWith(email: Value(email));
          }

          if (event.updatedFields.contains('status')) {
            final status = event.contact.hasStatus() ? event.contact.status : null;
            updatedUser = updatedUser.copyWith(status: Value(status));
          }

          // 更新最后活跃时间
          if (event.contact.hasLastActiveTime()) {
            final lastActiveTime = DateTime.fromMillisecondsSinceEpoch(event.contact.lastActiveTime.toInt());
            updatedUser = updatedUser.copyWith(lastActiveTime: Value(lastActiveTime));
          }

          // 保存更新
          await database.update(database.users).replace(updatedUser);
        });
      }

      _logger.d('本地联系人数据更新成功', extra: {
        'contactId': contactId,
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
}