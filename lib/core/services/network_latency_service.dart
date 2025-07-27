import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/services/proto_socket_service.dart';
import 'package:cc/core/utils/network_ping_tester.dart';

/// 网络延迟测试服务
class NetworkLatencyService {
  static final _instance = NetworkLatencyService._internal();
  static NetworkLatencyService get instance => _instance;
  NetworkLatencyService._internal();

  final _logger = LogService.instance;
  final _pingTester = NetworkPingTester(); // 使用独立的ping测试工具
  
  // 延迟历史记录（保存最近10次）
  final List<int> _latencyHistory = [];
  
  // 统计信息
  int _totalTests = 0;        // 总测试次数
  int _successfulTests = 0;   // 成功测试次数
  int _failedTests = 0;       // 失败测试次数
  
  // 测试限制
  static const int _maxTestsPerSession = 30; // 单次最多30次测试
  int _currentSessionTests = 0;               // 当前会话测试次数
  
  // Ping测试相关
  Timer? _latencyTimer;
  bool _isMonitoring = false;
  
  // 延迟状态流
  final _latencyController = StreamController<NetworkLatencyInfo>.broadcast();
  Stream<NetworkLatencyInfo> get latencyStream => _latencyController.stream;
  
  NetworkLatencyInfo? _currentLatency;
  NetworkLatencyInfo? get currentLatency => _currentLatency;
  
  /// 获取当前会话测试进度
  String get sessionProgress => '$_currentSessionTests/$_maxTestsPerSession';
  
  /// 检查是否还可以继续测试
  bool get canContinueTesting => _currentSessionTests < _maxTestsPerSession;
  
  /// 💢💢💢 新增：统一的统计信息获取方法
  /// 总测试次数
  int get totalTests => _totalTests;
  
  /// 成功测试次数  
  int get successfulTests => _successfulTests;
  
  /// 失败测试次数
  int get failedTests => _failedTests;
  
  /// 获取成功率百分比
  double getSuccessRate() {
    if (_totalTests == 0) return 0.0;
    return (_successfulTests / _totalTests) * 100;
  }
  
  /// 获取成功率文本
  String getSuccessRateText() {
    if (_totalTests == 0) return '无测试数据';
    return '${getSuccessRate().toStringAsFixed(1)}%';
  }

  /// 开始延迟监控（按需启动）
  void startMonitoring() {
    if (_isMonitoring) return;
    
    _isMonitoring = true;
    _currentSessionTests = 0; // 重置会话测试次数
    
    // 💢💢💢 修复：重置所有统计信息，确保UI和日志数据一致
    _totalTests = 0;
    _successfulTests = 0;
    _failedTests = 0;
    _latencyHistory.clear();
    _currentLatency = null;
    
    _logger.i('开始按需延迟监控（最多$_maxTestsPerSession次测试）');
    
    // 💢💢💢 修复：缩短延迟时间，立即执行第一次测试
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_isMonitoring) {
        _logger.d('执行第一次延迟测试，Socket连接状态: ${ProtoSocketService().isConnected}');
        _performLatencyTest();
      }
    });
    
    // 每1秒测试一次延迟（仅在监控期间）
    _latencyTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_isMonitoring && _currentSessionTests < _maxTestsPerSession) {
        _performLatencyTest();
      } else if (_currentSessionTests >= _maxTestsPerSession) {
        _logger.i('已达到单次测试上限（$_maxTestsPerSession次），停止测试');
        stopMonitoring();
      }
    });
    
    _logger.i('延迟监控已启动，每1秒测试一次，最多$_maxTestsPerSession次');
  }
  
  /// 停止延迟监控
  void stopMonitoring() {
    _isMonitoring = false;
    _latencyTimer?.cancel();
    _latencyTimer = null;
    _logger.i('停止网络延迟监控');
  }
  
  /// 执行单次延迟测试
  /// 使用独立的NetworkPingTester工具
  Future<int?> performSingleLatencyTest() async {
    if (!ProtoSocketService().isConnected) {
      _logger.w('未连接到服务器，无法测试延迟');
      return null;
    }
    
    // 增加总测试次数
    _totalTests++;
    
    // 使用独立的ping测试工具
    final latency = await _pingTester.performPingTest(
      testId: 'user_manual_${DateTime.now().millisecondsSinceEpoch}',
    );
    
    if (latency != null) {
      _successfulTests++;
      _logger.i('延迟测试成功: ${latency}ms (成功率: ${(_successfulTests/_totalTests*100).toStringAsFixed(1)}%)');
      return latency;
    } else {
      _failedTests++;
      _logger.w('延迟测试失败，服务器未响应 ping 请求 (失败率: ${(_failedTests/_totalTests*100).toStringAsFixed(1)}%)');
      return null;
    }
  }
  
  
  
  
  /// 执行延迟测试（内部使用）
  void _performLatencyTest() async {
    if (!ProtoSocketService().isConnected) {
      _updateLatencyInfo(null);
      return;
    }
    
    // 检查是否达到单次测试上限
    if (_currentSessionTests >= _maxTestsPerSession) {
      _logger.w('已达到单次测试上限（$_maxTestsPerSession次），跳过测试');
      return;
    }
    
    _logger.d('开始执行自动延迟测试 (${_currentSessionTests + 1}/$_maxTestsPerSession)');
    
    // 增加会话测试次数和总测试次数
    _currentSessionTests++;
    _totalTests++;
    
    // 使用独立的ping测试工具
    final latency = await _pingTester.performPingTest(
      testId: 'auto_${DateTime.now().millisecondsSinceEpoch}',
    );
    
    if (latency != null) {
      _successfulTests++;
      _addLatencyMeasurement(latency);
      _logger.d('自动延迟测试完成: ${latency}ms ($_currentSessionTests/$_maxTestsPerSession)');
    } else {
      _failedTests++;
      _logger.w('自动延迟测试失败 ($_currentSessionTests/$_maxTestsPerSession)');
      // 测试失败时不更新UI延迟信息，统计数据通过getter方法获取
    }
    
    // 检查是否达到上限，达到则停止监控
    if (_currentSessionTests >= _maxTestsPerSession) {
      _logger.i('单次测试已完成$_maxTestsPerSession次，自动停止监控');
      Future.delayed(const Duration(milliseconds: 100), () {
        stopMonitoring();
      });
    }
  }
  
  /// 添加延迟测量值
  void _addLatencyMeasurement(int latency) {
    _latencyHistory.add(latency);
    
    // 只保留最近10次测量
    if (_latencyHistory.length > 10) {
      _latencyHistory.removeAt(0);
    }
    
    // 计算统计信息
    final info = NetworkLatencyInfo(
      currentLatency: latency,
      averageLatency: _calculateAverageLatency(),
      minLatency: _latencyHistory.reduce((a, b) => a < b ? a : b),
      maxLatency: _latencyHistory.reduce((a, b) => a > b ? a : b),
      quality: _determineLatencyQuality(latency),
      sampleCount: _successfulTests, // 💢💢💢 修复: 使用成功测试总数而不是历史记录长度
      lastUpdated: DateTime.now(),
    );
    
    _updateLatencyInfo(info);
  }
  
  /// 更新延迟信息
  void _updateLatencyInfo(NetworkLatencyInfo? info) {
    _currentLatency = info;
    _latencyController.add(info ?? NetworkLatencyInfo.disconnected());
  }
  
  
  /// 计算平均延迟
  int _calculateAverageLatency() {
    if (_latencyHistory.isEmpty) return 0;
    return (_latencyHistory.reduce((a, b) => a + b) / _latencyHistory.length).round();
  }
  
  /// 确定延迟质量等级
  LatencyQuality _determineLatencyQuality(int latency) {
    if (latency <= 50) return LatencyQuality.excellent;
    if (latency <= 100) return LatencyQuality.good;
    if (latency <= 200) return LatencyQuality.fair;
    if (latency <= 500) return LatencyQuality.poor;
    return LatencyQuality.terrible;
  }
  
  
  /// 清理资源
  void dispose() {
    stopMonitoring();
    _latencyController.close();
  }
}

/// 延迟质量等级
enum LatencyQuality {
  excellent('优秀', '≤50ms'),
  good('良好', '51-100ms'),
  fair('一般', '101-200ms'),
  poor('较差', '201-500ms'),
  terrible('很差', '>500ms'),
  unknown('未知', '测试中...');

  const LatencyQuality(this.label, this.description);
  final String label;
  final String description;
}

/// 网络延迟信息
class NetworkLatencyInfo {
  final int? currentLatency;
  final int averageLatency;
  final int minLatency;
  final int maxLatency;
  final LatencyQuality quality;
  final int sampleCount;
  final DateTime lastUpdated;

  const NetworkLatencyInfo({
    required this.currentLatency,
    required this.averageLatency,
    required this.minLatency,
    required this.maxLatency,
    required this.quality,
    required this.sampleCount,
    required this.lastUpdated,
  });

  /// 创建断开连接状态的延迟信息
  factory NetworkLatencyInfo.disconnected() {
    return NetworkLatencyInfo(
      currentLatency: null,
      averageLatency: 0,
      minLatency: 0,
      maxLatency: 0,
      quality: LatencyQuality.unknown,
      sampleCount: 0,
      lastUpdated: DateTime.now(),
    );
  }

  /// 获取延迟显示文本
  String getLatencyText() {
    if (currentLatency == null) return '未连接';
    return '${currentLatency}ms';
  }
  

  /// 获取延迟质量颜色
  Color getQualityColor() {
    switch (quality) {
      case LatencyQuality.excellent:
        return const Color(0xFF4CAF50); // 绿色
      case LatencyQuality.good:
        return const Color(0xFF8BC34A); // 浅绿色
      case LatencyQuality.fair:
        return const Color(0xFFFF9800); // 橙色
      case LatencyQuality.poor:
        return const Color(0xFFFF5722); // 深橙色
      case LatencyQuality.terrible:
        return const Color(0xFFF44336); // 红色
      case LatencyQuality.unknown:
        return const Color(0xFF9E9E9E); // 灰色
    }
  }

  @override
  String toString() {
    return 'NetworkLatencyInfo(current: ${currentLatency}ms, avg: ${averageLatency}ms, quality: ${quality.label})';
  }
}

