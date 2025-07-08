import 'package:flutter/widgets.dart';
import 'package:cc/core/services/log_service.dart';

/// 自定义应用生命周期状态枚举
enum CustomAppLifecycleState {
  resumed, // 前台活跃
  inactive, // 非活跃状态
  paused, // 后台暂停
  detached, // 分离状态
  hidden, // 隐藏状态
}

/// 应用生命周期管理服务
/// 负责监听应用状态变化，并通知相关服务
class AppLifecycleService with WidgetsBindingObserver {
  static final AppLifecycleService _instance = AppLifecycleService._internal();
  factory AppLifecycleService() => _instance;
  AppLifecycleService._internal();

  static AppLifecycleService get instance => _instance;

  final _logger = LogService.instance;

  CustomAppLifecycleState _currentState = CustomAppLifecycleState.resumed;
  final List<Function(CustomAppLifecycleState)> _listeners = [];

  bool _isInitialized = false;

  /// 当前应用状态
  CustomAppLifecycleState get currentState => _currentState;

  /// 应用是否在前台活跃状态
  bool get isAppActive => _currentState == CustomAppLifecycleState.resumed;

  /// 应用是否在后台
  bool get isAppInBackground =>
      _currentState == CustomAppLifecycleState.paused ||
      _currentState == CustomAppLifecycleState.hidden;

  /// 初始化生命周期监听
  void initialize() {
    if (_isInitialized) {
      _logger.w('AppLifecycleService 已经初始化');
      return;
    }

    _logger.i('初始化应用生命周期监听服务');
    WidgetsBinding.instance.addObserver(this);
    _isInitialized = true;
  }

  /// 添加状态变化监听器
  void addListener(Function(CustomAppLifecycleState) listener) {
    _listeners.add(listener);
    _logger.d('添加应用生命周期监听器，当前监听器数量: ${_listeners.length}');
  }

  /// 移除状态变化监听器
  void removeListener(Function(CustomAppLifecycleState) listener) {
    _listeners.remove(listener);
    _logger.d('移除应用生命周期监听器，当前监听器数量: ${_listeners.length}');
  }

  /// 监听应用生命周期状态变化
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final newState = _convertState(state);

    if (_currentState != newState) {
      final previousState = _currentState;
      _currentState = newState;

      // _logger.i('应用生命周期状态变化', extra: {
      //   'previousState': previousState.toString(),
      //   'newState': newState.toString(),
      // });

      // 通知所有监听器
      for (final listener in _listeners) {
        try {
          listener(newState);
        } catch (e) {
          _logger.e('应用生命周期监听器执行失败', error: e);
        }
      }

      // 处理特定状态变化
      _handleStateChange(previousState, newState);
    }
  }

  /// 转换Flutter的AppLifecycleState到自定义枚举
  CustomAppLifecycleState _convertState(AppLifecycleState flutterState) {
    switch (flutterState) {
      case AppLifecycleState.resumed:
        return CustomAppLifecycleState.resumed;
      case AppLifecycleState.inactive:
        return CustomAppLifecycleState.inactive;
      case AppLifecycleState.paused:
        return CustomAppLifecycleState.paused;
      case AppLifecycleState.detached:
        return CustomAppLifecycleState.detached;
      case AppLifecycleState.hidden:
        return CustomAppLifecycleState.hidden;
    }
  }

  /// 处理状态变化的特定逻辑
  void _handleStateChange(
      CustomAppLifecycleState previousState, CustomAppLifecycleState newState) {
    // 从后台切换到前台
    if (isAppInBackground && newState == CustomAppLifecycleState.resumed) {
      _logger.i('应用从后台切换到前台');
      _onAppResumed();
    }

    // 从前台切换到后台
    if (previousState == CustomAppLifecycleState.resumed && isAppInBackground) {
      _logger.i('应用从前台切换到后台');
      _onAppPaused();
    }
  }

  /// 应用恢复到前台时的处理
  void _onAppResumed() {
    _logger.i('执行应用恢复逻辑');
    // 在这里可以添加恢复时的逻辑，比如重新连接网络、刷新数据等
  }

  /// 应用切换到后台时的处理
  void _onAppPaused() {
    _logger.i('执行应用后台暂停逻辑');
    // 在这里可以添加暂停时的逻辑，比如暂停同步、保存状态等
  }

  /// 清理资源
  void dispose() {
    if (_isInitialized) {
      _logger.i('清理应用生命周期监听服务');
      WidgetsBinding.instance.removeObserver(this);
      _listeners.clear();
      _isInitialized = false;
    }
  }
}
