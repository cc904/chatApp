import 'dart:async';
import 'package:flutter/foundation.dart';

/// 验证码倒计时管理器
/// 
/// 用于管理页面特定的验证码倒计时状态，确保不同页面的倒计时互相独立
class VerificationCodeTimer extends ChangeNotifier {
  Timer? _timer;
  int _countdown = 0;
  bool _isActive = false;
  
  static const int countdownDuration = 30; // 30秒倒计时
  
  /// 当前倒计时时间
  int get countdown => _countdown;
  
  /// 是否正在倒计时
  bool get isActive => _isActive;
  
  /// 开始倒计时
  void startCountdown() {
    if (_isActive) return; // 如果已经在倒计时，不重复启动
    
    _countdown = countdownDuration;
    _isActive = true;
    notifyListeners();
    
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _countdown--;
      if (_countdown <= 0) {
        _stopCountdown();
      } else {
        notifyListeners();
      }
    });
  }
  
  /// 停止倒计时
  void _stopCountdown() {
    _timer?.cancel();
    _timer = null;
    _countdown = 0;
    _isActive = false;
    notifyListeners();
  }
  
  /// 重置倒计时状态
  void reset() {
    _stopCountdown();
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
} 