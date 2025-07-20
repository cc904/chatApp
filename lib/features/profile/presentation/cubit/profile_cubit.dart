import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/database/models/current_user.dart';
import 'package:cc/features/profile/data/repositories/profile_repository.dart';
import 'package:cc/core/services/enhanced_token_manager.dart';
import 'package:cc/core/services/version_info_service.dart';
import 'package:cc/core/services/device_manager.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _repository;
  final _logger = LogService.instance;
  final _tokenManager = EnhancedTokenManager.instance;

  // 🔧 修复：添加操作标志，避免重复状态更新
  bool _isUpdating = false;

  ProfileCubit({
    required ProfileRepository repository,
  })  : _repository = repository,
        super(ProfileState.initial()) {
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      emit(state.copyWith(status: ProfileStatus.loading));
      final user = await _repository.getCurrentUser();
      emit(state.copyWith(
        status: ProfileStatus.success,
        user: user,
      ));
    } catch (e) {
      _logger.e('加载用户信息失败', error: e);
      emit(state.copyWith(
        status: ProfileStatus.error,
        error: e.toString(),
      ));
    }
  }

  /// 公有方法：刷新用户信息
  Future<void> refreshUserInfo() async {
    await _loadUserInfo();
  }

  Future<void> updateUserInfo({
    String? nickname,
    String? avatar,
    String? status,
  }) async {
    // 🔧 修复：防止重复更新操作
    if (_isUpdating) {
      _logger.w('用户信息更新操作正在进行中，忽略重复请求');
      return;
    }

    try {
      _isUpdating = true;
      emit(state.copyWith(status: ProfileStatus.loading));
      await _repository.updateUserInfo(
        nickname: nickname,
        avatar: avatar,
        status: status,
      );
      // 🔧 修复：UserService已经自动更新了本地数据，直接重新加载即可
      // 避免重复的状态更新导致多次Navigator.pop()调用
      await _loadUserInfo();
    } catch (e) {
      _logger.e('更新用户信息失败', error: e);
      emit(state.copyWith(
        status: ProfileStatus.error,
        error: e.toString(),
      ));
    } finally {
      _isUpdating = false;
    }
  }

  Future<void> updateServerUrl(String url) async {
    try {
      emit(state.copyWith(status: ProfileStatus.loading));
      await _repository.updateServerUrl(url);
      emit(state.copyWith(
        status: ProfileStatus.success,
        serverUrl: url,
      ));
    } catch (e) {
      _logger.e('更新服务器URL失败', error: e);
      emit(state.copyWith(
        status: ProfileStatus.error,
        error: e.toString(),
      ));
    }
  }

  Future<void> resetAllData() async {
    try {
      emit(state.copyWith(status: ProfileStatus.loading));
      await _repository.resetAllData();
      // 数据重置成功后，清除用户状态
      emit(const ProfileState(
        status: ProfileStatus.success,
        user: null,
        error: null,
        serverUrl: null,
      ));
    } catch (e) {
      _logger.e('重置数据失败', error: e);
      emit(state.copyWith(
        status: ProfileStatus.error,
        error: e.toString(),
      ));
    }
  }

  /// 验证Token并自动刷新
  ///
  /// 使用新的Token验证接口，支持自动刷新即将过期的Token
  Future<void> verifyTokenAndRefresh() async {
    try {
      emit(state.copyWith(status: ProfileStatus.loading));
      
      // 获取设备信息
      final deviceInfo = await DeviceManager.getDeviceInfo();
      
      // 获取版本信息
      final versionInfo = VersionInfoService.instance;
      
      // 构建客户端信息
      final clientInfo = {
        'version': versionInfo.currentVersion,
        'buildNumber': versionInfo.buildNumber,
        'platform': versionInfo.platformName,
        'deviceInfo': {
          'deviceId': deviceInfo.deviceId,
          'deviceName': deviceInfo.deviceModel,
          'systemVersion': deviceInfo.osVersion,
          'deviceModel': deviceInfo.deviceModel,
        }
      };

      // 调用Token验证接口
      final result = await _tokenManager.verifyTokenWithAutoRefresh(
        clientInfo: clientInfo,
        autoRefresh: true,
      );

      if (result != null && result['success'] == true) {
        // 检查是否有更新的用户信息
        if (result['currentUser'] != null || result['user'] != null) {
          // 更新用户信息到状态
          await _loadUserInfo();
          
          _logger.i('Token验证成功，用户信息已更新');
        }
        
        emit(state.copyWith(
          status: ProfileStatus.success,
          error: null,
        ));
      } else {
        _logger.w('Token验证失败，可能需要重新登录');
        emit(state.copyWith(
          status: ProfileStatus.error,
          error: 'Token验证失败，请重新登录',
        ));
      }
    } catch (e) {
      _logger.e('Token验证失败', error: e);
      emit(state.copyWith(
        status: ProfileStatus.error,
        error: e.toString(),
      ));
    }
  }

  /// 检查Token状态
  ///
  /// 检查Token是否即将过期并自动刷新
  Future<bool> checkTokenStatus() async {
    try {
      // 获取设备信息
      final deviceInfo = await DeviceManager.getDeviceInfo();
      
      // 获取版本信息
      final versionInfo = VersionInfoService.instance;
      
      // 构建客户端信息
      final clientInfo = {
        'version': versionInfo.currentVersion,
        'buildNumber': versionInfo.buildNumber,
        'platform': versionInfo.platformName,
        'deviceInfo': {
          'deviceId': deviceInfo.deviceId,
          'deviceName': deviceInfo.deviceModel,
          'systemVersion': deviceInfo.osVersion,
          'deviceModel': deviceInfo.deviceModel,
        }
      };

      // 检查并自动刷新Token
      final success = await _tokenManager.checkAndAutoRefreshToken(
        clientInfo: clientInfo,
      );

      if (success) {
        _logger.d('Token状态检查成功');
      } else {
        _logger.w('Token状态检查失败');
      }

      return success;
    } catch (e) {
      _logger.e('检查Token状态失败', error: e);
      return false;
    }
  }
}

enum ProfileStatus {
  initial,
  loading,
  success,
  error,
}

class ProfileState extends Equatable {
  final ProfileStatus status;
  final CurrentUser? user;
  final String? error;
  final String? serverUrl;

  const ProfileState({
    required this.status,
    this.user,
    this.error,
    this.serverUrl,
  });

  factory ProfileState.initial() {
    return const ProfileState(status: ProfileStatus.initial);
  }

  ProfileState copyWith({
    ProfileStatus? status,
    CurrentUser? user,
    String? error,
    String? serverUrl,
  }) {
    return ProfileState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error ?? this.error,
      serverUrl: serverUrl ?? this.serverUrl,
    );
  }

  @override
  List<Object?> get props => [status, user, error, serverUrl];
}
