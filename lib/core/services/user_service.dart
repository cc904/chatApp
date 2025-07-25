import 'dart:async';
import 'dart:io';
import 'package:fixnum/fixnum.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/services/communication_service.dart';
import 'package:cc/core/proto/generated/user.pb.dart';
import 'package:cc/core/database/drift_database.dart';
import 'package:cc/core/services/upload_api_service.dart';
import 'package:cc/core/database/database_initializer.dart';
import 'package:cc/core/services/secure_storage_service.dart';
import 'package:drift/drift.dart' as drift;

/// 用户服务
///
/// 负责处理用户信息相关的通信和业务逻辑
/// 包括用户信息更新、用户状态管理等
class UserService {
  final LogService _logger = LogService.instance;
  final CommunicationService _communicationService;
  final _uploadApiService = UploadApiService();

  // 用户信息更新流控制器
  final StreamController<CurrentUser> _userUpdateController = StreamController<CurrentUser>.broadcast();
  
  /// 用户信息更新流
  /// 当用户信息被更新时，通过此流通知其他组件
  Stream<CurrentUser> get userUpdateStream => _userUpdateController.stream;

  // 单例模式
  static UserService? _instance;
  static UserService get instance {
    _instance ??= UserService._();
    return _instance!;
  }

  UserService._() : _communicationService = CommunicationService() {
    _registerEventHandlers();
  }

  /// 注册事件监听器
  void _registerEventHandlers() {
    _handleCurrentUserUpdateEvent();
    _handleGetCurrentUserResponse();
  }

  /// 更新当前用户信息
  ///
  /// 参数:
  ///   - name: 可选，用户名称
  ///   - avatar: 可选，头像URL
  ///   - phone: 可选，手机号
  ///   - email: 可选，邮箱
  ///   - status: 可选，状态信息
  ///
  /// 返回:
  ///   - SetCurrentUserResponse: 服务器响应
  Future<SetCurrentUserResponse?> updateCurrentUser({
    String? name,
    String? avatar,
    String? phone,
    String? email,
    String? status,
  }) async {
    try {
      _logger.i('更新用户信息请求', extra: {
        'name': name,
        'avatar': avatar,
        'phone': phone,
        'email': email,
        'status': status,
      });

      // 构建请求对象
      final request = SetCurrentUserRequest()
        ..timestamp = Int64(DateTime.now().millisecondsSinceEpoch);

      // 只设置有值的字段
      if (name != null && name.isNotEmpty) {
        request.name = name;
      }
      if (avatar != null && avatar.isNotEmpty) {
        request.avatar = avatar;
      }
      if (phone != null && phone.isNotEmpty) {
        request.phone = phone;
      }
      if (email != null && email.isNotEmpty) {
        request.email = email;
      }
      if (status != null && status.isNotEmpty) {
        request.status = status;
      }

      // 检查通信服务状态
      if (!_communicationService.isInitialized) {
        throw Exception('通信服务未初始化');
      }

      if (!_communicationService.isConnected) {
        throw Exception('未连接到服务器');
      }

      // 发送请求
      final success = await _communicationService.emitProto(
        'user:set',
        request,
      );

      if (!success) {
        throw Exception('发送用户更新请求失败');
      }

      // 等待服务器响应
      try {
        final response = await _communicationService
            .onProto<SetCurrentUserResponse>('user:set:response')
            .timeout(const Duration(seconds: 10))
            .first;

        if (response.success) {
          _logger.i('用户信息更新成功', extra: {
            'userId': response.user.userId,
            'message': response.message,
          });

          // 🔧 修复：更新本地数据库和安全存储
          await _updateLocalUserInfo(response.user);
        } else {
          _logger.w('用户信息更新失败', extra: {
            'message': response.message,
          });
        }

        return response;
      } on TimeoutException {
        throw Exception('用户更新请求超时');
      }
    } catch (error, stack) {
      _logger.e('更新用户信息失败', error: error, stackTrace: stack);
      rethrow;
    }
  }

  /// 处理用户信息更新事件
  ///
  /// 监听服务器广播的用户信息变化事件
  void _handleCurrentUserUpdateEvent() {
    _communicationService
        .onProto<CurrentUserUpdateEvent>('user:updated')
        .listen((event) {
      _logger.i('收到用户信息更新事件', extra: {
        'userId': event.user.userId,
        'updatedFields': event.updatedFields,
        'updateSource': event.updateSource,
        'timestamp': event.timestamp.toInt(),
      });

      // 这里可以触发本地数据库更新等逻辑
      // 或者通过事件总线通知其他组件
      _onUserInfoUpdated(event);
    });
  }

  /// 用户信息更新事件处理
  ///
  /// 当收到用户信息更新事件时调用
  /// 可以在这里实现本地缓存更新、UI刷新等逻辑
  void _onUserInfoUpdated(CurrentUserUpdateEvent event) async {
    try {
      _logger.d('处理用户信息更新事件', extra: {
        'updatedFields': event.updatedFields,
        'updateSource': event.updateSource,
      });

      // 更新本地用户信息
      await _updateLocalUserInfo(event.user);

      _logger.i('用户信息更新事件已处理', extra: {
        'userId': event.user.userId,
        'updatedFields': event.updatedFields,
      });
    } catch (error) {
      _logger.e('处理用户信息更新事件失败', error: error, stackTrace: StackTrace.current);
    }
  }

  /// 处理获取当前用户信息响应事件
  ///
  /// 监听服务器返回的当前用户信息响应
  void _handleGetCurrentUserResponse() {
    _communicationService
        .onProto<SetCurrentUserResponse>('user:getCurrentUser:response')
        .listen((response) {
      _logger.i('收到获取当前用户信息响应', extra: {
        'success': response.success,
        'message': response.message,
        'userId': response.user.userId,  
        'timestamp': response.timestamp.toInt(),
      });

      if (response.success) {
        // 成功获取用户信息，更新本地数据
        _onGetCurrentUserResponseSuccess(response);
      } else {
        _logger.w('获取当前用户信息失败', extra: {
          'message': response.message,
        });
      }
    });
  }

  /// 获取当前用户信息成功处理
  ///
  /// 当服务器成功返回用户信息时调用
  void _onGetCurrentUserResponseSuccess(SetCurrentUserResponse response) async {
    try {
      _logger.i('处理获取用户信息成功响应', extra: {
        'userId': response.user.userId,
        'message': response.message,
      });

      // 更新本地用户信息
      await _updateLocalUserInfo(response.user);

      _logger.i('用户信息同步完成', extra: {
        'userId': response.user.userId,
        'source': 'getCurrentUser_response',
      });
    } catch (error) {
      _logger.e('处理获取用户信息响应失败', error: error, stackTrace: StackTrace.current);
    }
  }

  /// 更新本地用户信息
  ///
  /// 将服务器返回的用户信息同步到本地数据库和安全存储
  /// [userProto] 服务器返回的用户信息
  Future<void> _updateLocalUserInfo(CurrentUserProto userProto) async {
    try {
      _logger.i('开始更新本地用户信息', extra: {
        'userId': userProto.userId,
        'userProto.hasSetPassword': userProto.hasSetPassword,
      });

      // 1. 转换为本地数据库模型
      final currentUser = currentUserFromProto(userProto);

      // 2. 更新数据库
      if (DatabaseInitializer.isInitialized) {
        final db = DatabaseInitializer.database;
        await db.into(db.currentUsers).insertOnConflictUpdate(CurrentUsersCompanion.insert(
          userId: currentUser.userId,
          name: currentUser.name,
          phone: drift.Value(currentUser.phone),
          email: drift.Value(currentUser.email),
          avatar: drift.Value(currentUser.avatar),
          status: drift.Value(currentUser.status),
          lastLoginTime: drift.Value(currentUser.lastLoginTime),
          hasSetPassword: drift.Value(currentUser.hasSetPassword),
        ));
        _logger.d('数据库用户信息已更新');
      }

      // 3. 更新安全存储
      final secureStorage = SecureStorageService();
      await secureStorage.saveUserCredentials(currentUser);
      _logger.d('安全存储用户信息已更新');

      // 4. 发送本地事件通知其他组件
      // 注意：这里发送本地事件，不是发送到服务器
      // 可以通过其他方式通知UI组件，比如使用EventBus或者直接通过Cubit
      _logger.d('本地用户信息更新通知已准备', extra: {
        'userId': currentUser.userId,
        'source': 'user_service',
      });

      _logger.i('本地用户信息更新完成', extra: {
        'userId': currentUser.userId,
        'name': currentUser.name,
        'hasSetPassword': currentUser.hasSetPassword,
      });

      // 5. 通知其他组件用户信息已更新
      _userUpdateController.add(currentUser);
      _logger.d('用户信息更新通知已发送', extra: {
        'userId': currentUser.userId,
        'hasSetPassword': currentUser.hasSetPassword,
      });

    } catch (error) {
      _logger.e('更新本地用户信息失败', error: error, stackTrace: StackTrace.current);
      rethrow;
    }
  }

  /// 构建 CurrentUser 对象从 CurrentUserProto
  ///
  /// 将服务器返回的 Proto 对象转换为本地数据库模型
  CurrentUser currentUserFromProto(CurrentUserProto proto) {
    return CurrentUser(
      userId: proto.userId,
      name: proto.name,
      avatar: proto.avatar.isNotEmpty ? proto.avatar : null,
      phone: proto.phone.isNotEmpty ? proto.phone : null,
      email: proto.email.isNotEmpty ? proto.email : null,
      lastLoginTime: proto.hasLastLoginTime()
          ? DateTime.fromMillisecondsSinceEpoch(proto.lastLoginTime.toInt())
          : null,
      status: proto.status.isNotEmpty ? proto.status : null,
      hasSetPassword: proto.hasSetPassword,
    );
  }

  /// 构建 CurrentUserProto 对象从 CurrentUser
  ///
  /// 将本地数据库模型转换为 Proto 对象
  CurrentUserProto currentUserToProto(CurrentUser user) {
    final proto = CurrentUserProto()
      ..userId = user.userId
      ..name = user.name;

    if (user.avatar != null && user.avatar!.isNotEmpty) {
      proto.avatar = user.avatar!;
    }
    if (user.phone != null && user.phone!.isNotEmpty) {
      proto.phone = user.phone!;
    }
    if (user.email != null && user.email!.isNotEmpty) {
      proto.email = user.email!;
    }
    if (user.lastLoginTime != null) {
      proto.lastLoginTime = Int64(user.lastLoginTime!.millisecondsSinceEpoch);
    }
    if (user.status != null && user.status!.isNotEmpty) {
      proto.status = user.status!;
    }
    
    proto.hasSetPassword = user.hasSetPassword;

    return proto;
  }

  /// 上传头像并更新用户信息
  ///
  /// [avatarFile] 头像文件
  /// [onProgress] 上传进度回调，参数为0-100的进度值
  /// 返回更新后的用户信息响应，如果上传失败则抛出异常
  Future<SetCurrentUserResponse?> uploadAvatar(
    File avatarFile, {
    Function(int)? onProgress,
  }) async {
    try {
      _logger.i('开始上传头像', extra: {
        'filePath': avatarFile.path,
        'fileSize': avatarFile.lengthSync(),
      });

      // 1. 上传头像文件
      final uploadResult = await _uploadApiService.uploadAvatar(
        avatarFile,
        onProgress: onProgress,
      );

      if (!uploadResult.success || uploadResult.url == null) {
        throw Exception('头像上传失败: ${uploadResult.error ?? "未知错误"}');
      }

      _logger.i('头像上传成功', extra: {
        'fileId': uploadResult.fileId,
        'url': uploadResult.url,
      });

      // 2. 更新用户信息，只更新头像URL
      final response = await updateCurrentUser(
        avatar: uploadResult.url!,
      );

      _logger.i('头像更新完成', extra: {
        'avatarUrl': uploadResult.url,
        'success': response?.success ?? false,
      });

      return response;
    } catch (error) {
      _logger.e('上传头像失败', error: error, stackTrace: StackTrace.current);
      rethrow;
    }
  }

  /// 首次设置密码
  ///
  /// 用于验证码注册的用户首次设置密码
  /// [newPassword] 新密码
  /// 返回 SetPasswordResponse 设置结果
  Future<SetPasswordResponse?> setPassword(String newPassword) async {
    try {
      _logger.i('首次设置密码请求');

      // 构建请求对象
      final request = SetPasswordRequest()
        ..newPassword = newPassword
        ..timestamp = Int64(DateTime.now().millisecondsSinceEpoch);
      
      // 调试日志：检查请求数据
      _logger.d('SetPasswordRequest 构建完成', extra: {
        'newPassword': newPassword,
        'passwordLength': newPassword.length,
        'hasNewPassword': request.hasNewPassword(),
        'requestNewPassword': request.newPassword,
        'timestamp': request.timestamp.toInt(),
      });

      // 检查通信服务状态
      if (!_communicationService.isInitialized) {
        throw Exception('通信服务未初始化');
      }

      if (!_communicationService.isConnected) {
        throw Exception('未连接到服务器');
      }

      // 发送请求
      final success = await _communicationService.emitProto(
        'user:set_password',
        request,
      );

      if (!success) {
        throw Exception('发送设置密码请求失败');
      }

      // 等待服务器响应
      try {
        final response = await _communicationService
            .onProto<SetPasswordResponse>('user:set_password:response')
            .timeout(const Duration(seconds: 10))
            .first;

        if (response.success) {
          _logger.i('密码设置成功', extra: {
            'message': response.message,
          });
          
          // 🔧 请求服务器同步用户信息，获取最新的hasSetPassword状态
          await _syncUserInfoFromServer();
        } else {
          _logger.w('密码设置失败', extra: {
            'message': response.message,
          });
        }

        return response;
      } on TimeoutException {
        throw Exception('设置密码请求超时');
      }
    } catch (error, stack) {
      _logger.e('设置密码失败', error: error, stackTrace: stack);
      rethrow;
    }
  }

  /// 修改密码
  ///
  /// 用于已有密码的用户修改密码
  /// [currentPassword] 当前密码
  /// [newPassword] 新密码
  /// 返回 ChangePasswordResponse 修改结果
  Future<ChangePasswordResponse?> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      _logger.i('修改密码请求');

      // 构建请求对象
      final request = ChangePasswordRequest()
        ..currentPassword = currentPassword
        ..newPassword = newPassword
        ..timestamp = Int64(DateTime.now().millisecondsSinceEpoch);
      
      // 调试日志：检查请求数据
      _logger.d('ChangePasswordRequest 构建完成', extra: {
        'currentPassword': currentPassword.isNotEmpty ? '****' : 'EMPTY',
        'newPassword': newPassword.isNotEmpty ? '****' : 'EMPTY',
        'currentPasswordLength': currentPassword.length,
        'newPasswordLength': newPassword.length,
        'hasCurrentPassword': request.hasCurrentPassword(),
        'hasNewPassword': request.hasNewPassword(),
        'timestamp': request.timestamp.toInt(),
      });

      // 检查通信服务状态
      if (!_communicationService.isInitialized) {
        throw Exception('通信服务未初始化');
      }

      if (!_communicationService.isConnected) {
        throw Exception('未连接到服务器');
      }

      // 发送请求
      final success = await _communicationService.emitProto(
        'user:change_password',
        request,
      );

      if (!success) {
        throw Exception('发送修改密码请求失败');
      }

      // 等待服务器响应
      try {
        final response = await _communicationService
            .onProto<ChangePasswordResponse>('user:change_password:response')
            .timeout(const Duration(seconds: 10))
            .first;

        if (response.success) {
          _logger.i('密码修改成功', extra: {
            'message': response.message,
          });
          
          // 🔧 请求服务器同步用户信息，获取最新的hasSetPassword状态
          await _syncUserInfoFromServer();
        } else {
          _logger.w('密码修改失败', extra: {
            'message': response.message,
          });
        }

        return response;
      } on TimeoutException {
        throw Exception('修改密码请求超时');
      }
    } catch (error, stack) {
      _logger.e('修改密码失败', error: error, stackTrace: stack);
      rethrow;
    }
  }

  /// 请求获取当前用户信息
  /// 
  /// 类似于ChatsPage的会话同步，从服务器获取最新的用户信息
  /// 发送user:getCurrentUser请求，服务器会通过user:getCurrentUser:response响应
  Future<void> requestCurrentUserSync() async {
    try {
      _logger.i('🔄 请求获取当前用户信息');

      // 检查通信服务状态
      if (!_communicationService.isInitialized) {
        _logger.w('通信服务未初始化，无法获取用户信息');
        return;
      }

      if (!_communicationService.isConnected) {
        _logger.w('未连接到服务器，无法获取用户信息');
        return;
      }

      // 构建获取用户信息的请求
      final request = GetCurrentUserRequest()
        ..timestamp = Int64(DateTime.now().millisecondsSinceEpoch);

      // 发送获取用户信息请求
      final success = await _communicationService.emitProto(
        'user:getCurrentUser',
        request,
      );

      if (success) {
        _logger.i('✅ 获取用户信息请求已发送');
      } else {
        _logger.w('发送获取用户信息请求失败');
      }
      
    } catch (error) {
      _logger.e('❌ 获取用户信息请求失败', error: error, stackTrace: StackTrace.current);
    }
  }

  /// 从服务器同步用户信息
  /// 
  /// 密码操作成功后调用，确保本地用户信息与服务器保持一致
  Future<void> _syncUserInfoFromServer() async {
    try {
      _logger.i('🔄 请求服务器同步用户信息');

      // 检查通信服务状态
      if (!_communicationService.isInitialized) {
        _logger.w('通信服务未初始化，无法同步用户信息');
        return;
      }

      if (!_communicationService.isConnected) {
        _logger.w('未连接到服务器，无法同步用户信息');
        return;
      }

      // 构建同步请求（使用现有的设置用户信息请求来获取最新信息）
      final request = SetCurrentUserRequest()
        ..timestamp = Int64(DateTime.now().millisecondsSinceEpoch);

      // 发送同步请求
      final success = await _communicationService.emitProto(
        'user:sync',
        request,
      );

      if (success) {
        _logger.i('✅ 用户信息同步请求已发送');
      } else {
        _logger.w('发送用户信息同步请求失败');
      }
      
    } catch (error) {
      _logger.e('❌ 用户信息同步请求失败', error: error, stackTrace: StackTrace.current);
    }
  }

  /// 释放资源
  void dispose() {
    _logger.i('释放用户服务资源');
    _userUpdateController.close();
  }
}
