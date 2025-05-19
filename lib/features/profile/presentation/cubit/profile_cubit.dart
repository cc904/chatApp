import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/database/models/user.dart';
import 'package:cc/features/profile/data/repositories/profile_repository.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _repository;
  final _logger = LogService.instance;

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

  Future<void> updateUserInfo({
    String? nickname,
    String? avatar,
    String? status,
  }) async {
    try {
      emit(state.copyWith(status: ProfileStatus.loading));
      await _repository.updateUserInfo(
        nickname: nickname,
        avatar: avatar,
        status: status,
      );
      await _loadUserInfo();
    } catch (e) {
      _logger.e('更新用户信息失败', error: e);
      emit(state.copyWith(
        status: ProfileStatus.error,
        error: e.toString(),
      ));
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
      emit(state.copyWith(status: ProfileStatus.success));
    } catch (e) {
      _logger.e('重置数据失败', error: e);
      emit(state.copyWith(
        status: ProfileStatus.error,
        error: e.toString(),
      ));
    }
  }
}
