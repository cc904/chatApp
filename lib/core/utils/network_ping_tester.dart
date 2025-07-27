import 'dart:async';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/services/proto_socket_service.dart';

/// 网络Ping测试工具类
/// 提供独立的延迟测试功能，可在多个地方复用
class NetworkPingTester {
  final LogService _logger = LogService.instance;
  
  /// 执行单次ping测试
  /// 返回延迟（毫秒）或null（失败）
  Future<int?> performPingTest({
    Duration timeout = const Duration(seconds: 3),
    String? testId,
  }) async {
    if (!ProtoSocketService().isConnected) {
      _logger.w('网络未连接，无法执行ping测试', extra: {
        'testId': testId,
        'socketConnected': ProtoSocketService().isConnected,
        'socketStatus': ProtoSocketService().status.toString(),
      });
      return null;
    }
    
    final testIdStr = testId ?? 'ping_${DateTime.now().millisecondsSinceEpoch}';
    _logger.d('开始ping测试: $testIdStr', extra: {
      'socketConnected': ProtoSocketService().isConnected,
      'timeout': timeout.inMilliseconds,
    });
    
    try {
      final startTime = DateTime.now();
      final completer = Completer<int?>();
      
      // 监听 Socket.IO 内置的 pong 事件
      void pongHandler(dynamic data) {
        if (!completer.isCompleted) {
          final latency = DateTime.now().difference(startTime).inMilliseconds;
          ProtoSocketService().off('pong', pongHandler);
          _logger.d('ping测试成功: $testIdStr, 延迟: ${latency}ms');
          completer.complete(latency);
        }
      }
      
      ProtoSocketService().on('pong', pongHandler);
      
      // 发送 Socket.IO 内置的 ping
      ProtoSocketService().emit('ping', DateTime.now().millisecondsSinceEpoch);
      
      // 设置超时
      Timer(timeout, () {
        if (!completer.isCompleted) {
          ProtoSocketService().off('pong', pongHandler);
          _logger.w('ping测试超时: $testIdStr', extra: {
            'timeout': timeout.inMilliseconds,
            'socketConnected': ProtoSocketService().isConnected,
            'elapsedTime': DateTime.now().difference(startTime).inMilliseconds,
          });
          completer.complete(null);
        }
      });
      
      return await completer.future;
      
    } catch (error) {
      _logger.e('ping测试异常: $testIdStr', error: error);
      return null;
    }
  }
  
  /// 执行多次ping测试并返回统计结果
  Future<PingTestResult> performMultiplePingTests({
    int testCount = 5,
    Duration interval = const Duration(seconds: 1),
    Duration timeout = const Duration(seconds: 3),
  }) async {
    final results = <int>[];
    final failures = <String>[];
    
    _logger.i('开始执行多次ping测试，共$testCount次');
    
    for (int i = 0; i < testCount; i++) {
      final testId = 'batch_${DateTime.now().millisecondsSinceEpoch}_$i';
      final result = await performPingTest(timeout: timeout, testId: testId);
      
      if (result != null) {
        results.add(result);
      } else {
        failures.add(testId);
      }
      
      // 最后一次测试不需要等待间隔
      if (i < testCount - 1) {
        await Future.delayed(interval);
      }
    }
    
    return PingTestResult(
      totalTests: testCount,
      successfulResults: results,
      failedTests: failures,
      testCompletedAt: DateTime.now(),
    );
  }
}

/// Ping测试结果
class PingTestResult {
  final int totalTests;
  final List<int> successfulResults;
  final List<String> failedTests;
  final DateTime testCompletedAt;
  
  const PingTestResult({
    required this.totalTests,
    required this.successfulResults,
    required this.failedTests,
    required this.testCompletedAt,
  });
  
  /// 成功次数
  int get successCount => successfulResults.length;
  
  /// 失败次数
  int get failureCount => failedTests.length;
  
  /// 成功率（百分比）
  double get successRate => totalTests > 0 ? (successCount / totalTests) * 100 : 0.0;
  
  /// 平均延迟
  double get averageLatency => 
    successfulResults.isNotEmpty 
      ? successfulResults.reduce((a, b) => a + b) / successfulResults.length
      : 0.0;
  
  /// 最小延迟
  int? get minLatency => 
    successfulResults.isNotEmpty 
      ? successfulResults.reduce((a, b) => a < b ? a : b)
      : null;
  
  /// 最大延迟
  int? get maxLatency => 
    successfulResults.isNotEmpty 
      ? successfulResults.reduce((a, b) => a > b ? a : b)
      : null;
  
  /// 获取质量评估
  String get qualityAssessment {
    if (successCount == 0) return '网络不可达';
    if (successRate >= 95 && averageLatency <= 50) return '优秀';
    if (successRate >= 90 && averageLatency <= 100) return '良好';
    if (successRate >= 80 && averageLatency <= 200) return '一般';
    if (successRate >= 60) return '较差';
    return '很差';
  }
  
  @override
  String toString() {
    return 'PingTestResult(总测试: $totalTests, 成功: $successCount, '
           '失败: $failureCount, 成功率: ${successRate.toStringAsFixed(1)}%, '
           '平均延迟: ${averageLatency.toStringAsFixed(1)}ms)';
  }
}