import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/features/home/domain/repositories/home_repository.dart';

import 'home_state.dart';

/// HomePage的业务逻辑控制器
class HomeCubit extends Cubit<HomeState> {
  final HomeRepository _homeRepository;
  final LogService _logger = LogService.instance;

  HomeCubit({required HomeRepository homeRepository})
      : _homeRepository = homeRepository,
        super(HomeState.initial());

  /// 初始化用户会话
  ///
  /// 从安全存储获取用户信息并初始化数据库和通信
  Future<void> initUserSession() async {
    try {
      _logger.i('开始初始化用户会话');
      emit(state.toInitializingState());

      // 从安全存储获取用户信息
      final user = await _homeRepository.getUserFromSecureStorage();
      if (user == null) {
        throw Exception('无法获取用户信息，请重新登录');
      }

      _logger.i('获取到用户信息', extra: {'userId': user.userId});

      // 初始化用户会话
      final success = await _homeRepository.initUserSession(user);
      if (!success) {
        throw Exception('初始化用户会话失败');
      }

      // 更新状态为已初始化
      emit(state.toInitializedState(user: user));
      _logger.i('用户会话初始化完成');
    } catch (error) {
      _logger.e('初始化用户会话失败', error: error, stackTrace: StackTrace.current);
      emit(state.toErrorState(error.toString()));
    }
  }

  /// 重试初始化
  Future<void> retryInitialization() async {
    if (!state.isInitializing) {
      await initUserSession();
    }
  }
}
