import 'dart:async';
import 'dart:io';
import 'package:fixnum/fixnum.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/services/communication_service.dart';
import 'package:cc/core/proto/generated/user.pb.dart';
import 'package:cc/core/database/models/current_user.dart';
import 'package:cc/core/services/upload_api_service.dart';

/// 用户服务
///
/// 负责处理用户信息相关的通信和业务逻辑
/// 包括用户信息更新、用户状态管理等
class UserService {
  final LogService _logger = LogService.instance;
  final CommunicationService _communicationService;
  final _uploadApiService = UploadApiService();

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
        'avatar': avatar != null ? '${avatar.substring(0, 20)}...' : null,
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

      // TODO: 后续完善本地数据库更新逻辑
      // 目前通过ProfileCubit的updateUserInfo已经能更新UI和本地数据库
      _logger.i('用户信息更新事件已处理', extra: {
        'userId': event.user.userId,
        'updatedFields': event.updatedFields,
      });
    } catch (error) {
      _logger.e('处理用户信息更新事件失败', error: error, stackTrace: StackTrace.current);
    }
  }

  /// 构建 CurrentUser 对象从 CurrentUserProto
  ///
  /// 将服务器返回的 Proto 对象转换为本地数据库模型
  CurrentUser currentUserFromProto(CurrentUserProto proto) {
    return CurrentUser()
      ..userId = proto.userId
      ..token = proto.token
      ..name = proto.name
      ..avatar = proto.avatar.isNotEmpty ? proto.avatar : null
      ..phone = proto.phone.isNotEmpty ? proto.phone : null
      ..email = proto.email.isNotEmpty ? proto.email : null
      ..tokenExpireTime = proto.hasTokenExpireTime()
          ? DateTime.fromMillisecondsSinceEpoch(proto.tokenExpireTime.toInt())
          : null
      ..lastLoginTime = proto.hasLastLoginTime()
          ? DateTime.fromMillisecondsSinceEpoch(proto.lastLoginTime.toInt())
          : null
      ..status = proto.status.isNotEmpty ? proto.status : null;
  }

  /// 构建 CurrentUserProto 对象从 CurrentUser
  ///
  /// 将本地数据库模型转换为 Proto 对象
  CurrentUserProto currentUserToProto(CurrentUser user) {
    final proto = CurrentUserProto()
      ..userId = user.userId
      ..token = user.token
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
    if (user.tokenExpireTime != null) {
      proto.tokenExpireTime =
          Int64(user.tokenExpireTime!.millisecondsSinceEpoch);
    }
    if (user.lastLoginTime != null) {
      proto.lastLoginTime = Int64(user.lastLoginTime!.millisecondsSinceEpoch);
    }
    if (user.status != null && user.status!.isNotEmpty) {
      proto.status = user.status!;
    }

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

  /// 释放资源
  void dispose() {
    _logger.i('释放用户服务资源');
    // 如果有需要清理的资源，在这里添加
  }
}
