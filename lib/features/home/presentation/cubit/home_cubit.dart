import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'dart:developer' as dev;

// Home状态类
abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

// 初始状态
class HomeInitial extends HomeState {}

// 加载状态
class HomeLoading extends HomeState {}

// 错误状态
class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}

// HomeCubit
class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial());

  /// 用户登出
  Future<void> logout() async {
    dev.log('用户登出');
    emit(HomeLoading());

    try {
      // 在这里实现实际的登出逻辑
      // 例如清除本地存储的登录信息, token等

      // 模拟网络请求延迟
      await Future.delayed(const Duration(seconds: 1));

      // 登出成功后，应用程序会回到登录页面
      // 通过路由处理，这里不需要特殊的状态
    } catch (e) {
      dev.log('登出错误: $e');
      emit(HomeError('登出失败: $e'));
    }
  }

  /// 刷新消息列表
  Future<void> refreshMessages() async {
    dev.log('刷新消息列表');

    try {
      // 实现消息刷新逻辑
      await Future.delayed(const Duration(seconds: 1));

      // 刷新成功，保持当前状态或者更新为特定状态
      emit(HomeInitial());
    } catch (e) {
      dev.log('刷新错误: $e');
      emit(HomeError('刷新失败: $e'));
    }
  }

  /// 处理通知权限
  Future<void> handleNotificationPermission() async {
    dev.log('处理通知权限');

    try {
      // 检查和请求通知权限的逻辑
      await Future.delayed(const Duration(milliseconds: 500));

      // 权限处理完成
      emit(HomeInitial());
    } catch (e) {
      dev.log('权限处理错误: $e');
      emit(HomeError('权限处理失败: $e'));
    }
  }
}
