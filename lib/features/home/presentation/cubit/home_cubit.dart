import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/services/communication_service.dart';
import 'package:cc/features/home/domain/repositories/home_repository.dart';
import 'package:cc/features/home/data/repositories/home_repository_impl.dart';
import 'package:cc/core/database/models/current_user.dart';

import 'home_state.dart';

/// HomePage的业务逻辑控制器
/// 负责管理主页相关的状态和业务逻辑
/// 直接管理三个核心仓库：HomeRepository、ChatRepository和ContactsRepository
class HomeCubit extends Cubit<HomeState> {
  final HomeRepository _homeRepository;
  final LogService _logger = LogService.instance;
  final CurrentUser _currentUser;

  // 保存订阅，以便在dispose时取消
  final Map<String, StreamSubscription> _subscriptions = {};

  // 网络连接实例
  final Connectivity _connectivity = Connectivity();

  HomeCubit({required CurrentUser currentUser})
      : _currentUser = currentUser,
        _homeRepository = HomeRepositoryImpl(currentUser: currentUser),
        super(HomeState.initial());

  /// 初始化用户会话
  ///
  /// 初始化数据库和通信
  Future<bool> initUserSession() async {
    try {
      _logger.i('开始初始化用户会话');
      if (!isClosed) {
        emit(state.toInitializingState());
      }

      // 初始化网络状态监听
      await _initNetworkMonitoring();

      // 初始化 initUserSession
      final homeRepositoryInitialized = await _homeRepository.initUserSession();
      if (!homeRepositoryInitialized) {
        _logger.e('HomeRepository初始化失败');
        if (!isClosed) {
          emit(state.toErrorState('HomeRepository初始化失败'));
        }
        return false;
      }

      // 更新状态为已初始化
      if (!isClosed) {
        emit(state.toInitializedState(currentUser: _currentUser));
      }
      _logger.i('用户会话初始化完成');
      return true;
    } catch (error) {
      _logger.e('初始化用户会话失败', error: error, stackTrace: StackTrace.current);
      if (!isClosed) {
        emit(state.toErrorState(error.toString()));
      }
      return false;
    }
  }
  // 💢💢💢💢💢💢💢💢💢💢💢💢💢💢 网络状态相关 💢💢💢💢💢💢💢💢💢💢💢💢💢💢

  /// 初始化网络状态监听
  Future<void> _initNetworkMonitoring() async {
    _logger.i('初始化网络状态监听');

    // 检查当前网络状态
    final connectivityResult = await _connectivity.checkConnectivity();
    _updateNetworkStatus(connectivityResult.first);

    // 监听网络状态变化
    _subscriptions['connectivity'] = _connectivity.onConnectivityChanged
        .listen((result) => _handleNetworkChange(result.first));
  }

  /// 处理网络状态变化
  void _handleNetworkChange(ConnectivityResult result) {
    _logger.i('网络状态变化', extra: {'result': result.toString()});
    _updateNetworkStatus(result);
  }

  /// 更新网络状态
  void _updateNetworkStatus(ConnectivityResult result) {
    if (isClosed) return;
    
    NetworkStatus networkStatus;
    bool isConnected = false;
    String? errorMessage;

    switch (result) {
      case ConnectivityResult.wifi:
      case ConnectivityResult.mobile:
      case ConnectivityResult.ethernet:
        networkStatus = NetworkStatus.connected;
        isConnected = true;
        errorMessage = null;
        break;
      case ConnectivityResult.none:
        networkStatus = NetworkStatus.disconnected;
        isConnected = false;
        errorMessage = '无网络连接';
        break;
      default:
        networkStatus = NetworkStatus.error;
        isConnected = false;
        errorMessage = '网络连接异常';
    }

    if (!isClosed) {
      emit(state.copyWith(
        isConnected: isConnected,
        networkStatus: networkStatus,
        lastConnectionTime:
            isConnected ? DateTime.now() : state.lastConnectionTime,
        connectionErrorMessage: errorMessage,
      ));
    }
  }

  /// 检查网络连接
  Future<void> checkNetworkConnection() async {
    _logger.i('检查网络连接');

    try {
      // 先更新为连接中状态
      if (!isClosed) {
        emit(state.copyWith(
          networkStatus: NetworkStatus.connecting,
        ));
      }

      // 检查当前网络状态
      final connectivityResult = await _connectivity.checkConnectivity();
      _updateNetworkStatus(connectivityResult.first);

    } catch (error) {
      _logger.e('检查网络连接失败', error: error);
      if (!isClosed) {
        emit(state.copyWith(
          networkStatus: NetworkStatus.error,
          isConnected: false,
          connectionErrorMessage: '检查网络连接失败: ${error.toString()}',
        ));
      }
    }
  }

  /// 尝试重新连接
  Future<void> reconnect() async {
    _logger.i('HomeCubit: 尝试重新连接');

    try {
      // 先检查设备网络状态
      await checkNetworkConnection();

      // 如果设备有网络，调用通信服务重连
      if (state.isConnected) {
        final communicationService = CommunicationService();
        final success = await communicationService.reconnect();

        if (success) {
          _logger.i('HomeCubit: 重连成功');
        } else {
          _logger.w('HomeCubit: 重连失败');
        }
      } else {
        _logger.w('HomeCubit: 设备无网络连接，无法重连');
      }
    } catch (error) {
      _logger.e('HomeCubit: 重连异常', error: error);
    }
  }

  /// 设置当前Tab索引
  void setCurrentTabIndex(int index) {
    if (index != state.currentTabIndex && !isClosed) {
      _logger.d('HomeCubit: 切换Tab索引', extra: {
        'from': state.currentTabIndex,
        'to': index,
      });
      emit(state.copyWith(currentTabIndex: index));
    }
  }

  @override
  Future<void> close() {
    _logger.i('关闭HomeCubit');
    // 取消所有订阅
    for (final subscription in _subscriptions.values) {
      subscription.cancel();
    }
    // 取消网络状态监听
    _subscriptions['connectivity']?.cancel();
    _subscriptions.clear();

    // 如果 HomeRepository 也有 dispose 方法，也在这里调用
    if (_homeRepository is HomeRepositoryImpl) {
      (_homeRepository as HomeRepositoryImpl).dispose();
    }

    return super.close();
  }
}
