import 'dart:async';

/// 事件监听器
/// 用于处理基于事件的通信
class EventListener<T> {
  final StreamController<T> _controller = StreamController<T>.broadcast();

  /// 获取事件流
  Stream<T> get stream => _controller.stream;

  /// 添加事件
  void add(T event) {
    if (!_controller.isClosed) {
      _controller.add(event);
    }
  }

  /// 关闭事件监听器
  void close() {
    _controller.close();
  }
} 