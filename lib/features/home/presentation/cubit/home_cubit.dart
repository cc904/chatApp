import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/features/home/domain/repositories/home_repository.dart';
import 'package:cc/features/home/data/repositories/home_repository_impl.dart';
import 'package:cc/core/proto/generated/user.pb.dart';

import 'home_state.dart';

/// HomePage的业务逻辑控制器
/// 负责管理主页相关的状态和业务逻辑
/// 直接管理三个核心仓库：HomeRepository、ChatRepository和ContactsRepository
class HomeCubit extends Cubit<HomeState> {
  final HomeRepository _homeRepository;
  final LogService _logger = LogService.instance;
  final CurrentUserProto _currentUser;

  // 保存订阅，以便在dispose时取消
  final Map<String, StreamSubscription> _subscriptions = {};

  // 网络连接实例
  final Connectivity _connectivity = Connectivity();

  HomeCubit({required CurrentUserProto currentUserProto})
      : _currentUser = currentUserProto,
        _homeRepository =
            HomeRepositoryImpl(currentUserProto: currentUserProto),
        super(HomeState.initial()) {
    initUserSession();
  }

  /// 初始化用户会话
  ///
  /// 初始化数据库和通信
  Future<void> initUserSession() async {
    try {
      _logger.i('开始初始化用户会话');
      emit(state.toInitializingState());

      // 初始化网络状态监听
      await _initNetworkMonitoring();

      // 初始化 initUserSession
      final homeRepositoryInitialized = await _homeRepository.initUserSession();
      if (!homeRepositoryInitialized) {
        _logger.e('HomeRepository初始化失败');
        emit(state.toErrorState('HomeRepository初始化失败'));
        return;
      }

      // 更新状态为已初始化
      emit(state.toInitializedState(currentUserProto: _currentUser));
      _logger.i('用户会话初始化完成');
    } catch (error) {
      _logger.e('初始化用户会话失败', error: error, stackTrace: StackTrace.current);
      emit(state.toErrorState(error.toString()));
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

    emit(state.copyWith(
      isConnected: isConnected,
      networkStatus: networkStatus,
      lastConnectionTime:
          isConnected ? DateTime.now() : state.lastConnectionTime,
      connectionErrorMessage: errorMessage,
    ));
  }

  /// 检查网络连接
  Future<void> checkNetworkConnection() async {
    _logger.i('检查网络连接');

    try {
      // 先更新为连接中状态
      emit(state.copyWith(
        networkStatus: NetworkStatus.connecting,
      ));

      // 检查当前网络状态
      final connectivityResult = await _connectivity.checkConnectivity();
      _updateNetworkStatus(connectivityResult.first);

      // 如果连接上了，尝试加载数据
      if (state.isConnected) {
        // TODO: await _loadConversations();
      }
    } catch (error) {
      _logger.e('检查网络连接失败', error: error);
      emit(state.copyWith(
        networkStatus: NetworkStatus.error,
        isConnected: false,
        connectionErrorMessage: '检查网络连接失败: ${error.toString()}',
      ));
    }
  }

  /// 尝试重新连接
  Future<void> reconnect() async {
    _logger.i('尝试重新连接');
    await checkNetworkConnection();
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
