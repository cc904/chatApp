import 'package:flutter/material.dart';
import 'package:cc/core/database/models/message.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/services/voice_record_service.dart';
import 'package:cc/core/services/audio_player_manager.dart';
import 'package:cc/core/services/media_cache_service.dart';
import 'dart:async';
import 'dart:math' as math;

/// 语音消息Widget
/// 支持播放、暂停、波形显示和倒计时
/// 使用全局单例AudioPlayerManager确保同时只有一个语音播放
class VoiceMessageWidget extends StatefulWidget {
  final Message message;
  final bool isCurrentUser;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const VoiceMessageWidget({
    super.key,
    required this.message,
    required this.isCurrentUser,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  State<VoiceMessageWidget> createState() => _VoiceMessageWidgetState();
}

class _VoiceMessageWidgetState extends State<VoiceMessageWidget>
    with TickerProviderStateMixin {
  final LogService _logger = LogService.instance;
  final AudioPlayerManager _audioManager = AudioPlayerManager();
  final MediaCacheService _cacheService = MediaCacheService();

  // 本地UI状态
  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  double _progress = 0.0;

  // 动画控制器
  late AnimationController _waveAnimationController;
  late AnimationController _rippleAnimationController;

  // 状态监听订阅
  StreamSubscription<AudioPlaybackState>? _stateSubscription;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeDuration();
    _listenToGlobalState();
  }

  void _initializeAnimations() {
    _waveAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _rippleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
  }

  void _initializeDuration() {
    if (widget.message.duration != null) {
      _totalDuration = Duration(milliseconds: widget.message.duration!);
    } else {
      _totalDuration = const Duration(seconds: 1);
    }
  }

  /// 🆕 监听全局播放状态
  void _listenToGlobalState() {
    _stateSubscription = _audioManager.stateStream.listen((state) {
      if (!mounted) return;

      final messageId = widget.message.id.toString();
      final isThisMessage = state.messageId == messageId;

      setState(() {
        _isPlaying = isThisMessage && state.isPlaying && !state.isPaused;
        _isLoading = false; // 全局状态更新时清除加载状态

        if (isThisMessage) {
          _currentPosition = state.position;
          _progress = state.progress;
          if (state.duration.inMilliseconds > 0) {
            _totalDuration = state.duration;
          }
        } else {
          // 不是当前消息，重置播放状态但保持进度
          _isPlaying = false;
        }
      });

      // 根据播放状态控制动画
      if (_isPlaying) {
        _startAnimations();
      } else {
        _stopAnimations();
      }
    });

    // 检查初始状态
    final currentState = _audioManager.currentState;
    final messageId = widget.message.id.toString();
    if (currentState.messageId == messageId) {
      setState(() {
        _isPlaying = currentState.isPlaying && !currentState.isPaused;
        _currentPosition = currentState.position;
        _progress = currentState.progress;
        if (currentState.duration.inMilliseconds > 0) {
          _totalDuration = currentState.duration;
        }
      });

      if (_isPlaying) {
        _startAnimations();
      }
    }
  }

  @override
  void dispose() {
    _stateSubscription?.cancel();
    _stopAnimations();
    _waveAnimationController.dispose();
    _rippleAnimationController.dispose();
    super.dispose();
  }

  /// 🆕 新的播放控制 - 使用统一缓存策略
  Future<void> _togglePlayback() async {
    final messageId = widget.message.id.toString();
    
    // 显示短暂加载状态
    setState(() {
      _isLoading = true;
    });

    try {
      _logger.d('开始获取语音文件缓存 - 消息ID: $messageId');
      
      // 🔥 使用新的统一缓存策略：基于消息ID获取本地缓存的语音文件
      final cachedAudioPath = await _cacheService.getVoiceByMessageId(
        messageId, 
        widget.message.mediaUrl,
        messageDate: widget.message.createdAt,
      );
      
      if (cachedAudioPath == null) {
        _showErrorSnackBar('语音文件获取失败');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      _logger.d('语音文件缓存获取成功: $cachedAudioPath');
      
      // 只播放本地缓存文件，从不直接播放网络URL
      await _audioManager.playVoice(messageId, cachedAudioPath);
    } catch (error) {
      _logger.e('播放失败', error: error);
      
      // 根据错误类型显示不同的提示
      String errorMessage = '播放失败';
      if (error.toString().contains('-11800')) {
        errorMessage = '音频格式不支持';
      } else if (error.toString().contains('HTTP')) {
        errorMessage = '网络连接问题，无法下载语音';
      } else if (error.toString().contains('timeout')) {
        errorMessage = '下载超时，请检查网络连接';
      } else {
        errorMessage = '播放失败: ${error.toString()}';
      }
      
      _showErrorSnackBar(errorMessage);

      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 启动动画
  void _startAnimations() {
    _waveAnimationController.repeat();
    _rippleAnimationController.repeat();
  }

  /// 停止动画
  void _stopAnimations() {
    _waveAnimationController.stop();
    _rippleAnimationController.stop();
  }

  /// 显示错误提示
  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// 格式化时间显示（倒计时）
  String _formatRemainingTime() {
    // 🔧 如果显示时长为0，说明没有预存时长信息，不显示时间
    if (_totalDuration == Duration.zero) {
      return '--:--';
    }

    final remaining = Duration(
      milliseconds: math.max(
        0,
        _totalDuration.inMilliseconds - _currentPosition.inMilliseconds,
      ),
    );

    final minutes = remaining.inMinutes;
    final seconds = remaining.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  /// 根据音频时长计算UI宽度
  double _calculateWidthFromDuration() {
    const double minWidth = 180.0; // 最小宽度（对应很短的语音）
    const double maxWidth = 300.0; // 最大宽度（对应60秒语音）

    if (_totalDuration == Duration.zero || _totalDuration.inSeconds <= 1) {
      return minWidth;
    }

    // 根据时长比例计算宽度，使用VoiceRecordService的最大时长作为基准
    const maxDuration = VoiceRecordService.maxRecordingDuration;
    final ratio = (_totalDuration.inSeconds / maxDuration).clamp(0.0, 1.0);
    final calculatedWidth = minWidth + (maxWidth - minWidth) * ratio;

    return calculatedWidth;
  }

  @override
  Widget build(BuildContext context) {
    // 检查关键数据
    if (widget.message.mediaUrl == null && widget.message.localPath == null) {
      _logger.w('语音消息文件路径为空 - ID: ${widget.message.id}');
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        // ignore: prefer_const_constructors
        child: Row(
          children: const [
            Icon(Icons.error, color: Colors.red, size: 16),
            SizedBox(width: 8),
            Text('语音文件丢失', style: TextStyle(color: Colors.red, fontSize: 12)),
          ],
        ),
      );
    }

    // 添加调试日志
    final width = _calculateWidthFromDuration();
    // _logger.d('语音消息渲染 - ID: ${widget.message.id}, 宽度: $width, 时长: ${_totalDuration.inSeconds}秒, mediaUrl: ${widget.message.mediaUrl}, localPath: ${widget.message.localPath}');
    
    // 添加最小宽度保护
    final safeWidth = math.max(width, 180.0);
    
    // 统一使用深色方案 - 因为所有气泡都是白色的
    final displayColor = widget.foregroundColor ?? const Color(0xFF555555);
            
    // _logger.d('颜色调试 - displayColor: $displayColor, isCurrentUser: ${widget.isCurrentUser}, alpha: ${displayColor.a}');
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      width: safeWidth,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          // 播放按钮
          _buildPlayButton(displayColor),
          const SizedBox(width: 12),

          // 波形显示区域
          Expanded(
            child: _buildWaveform(displayColor),
          ),

          const SizedBox(width: 12),

          // 倒计时显示
          Text(
            _formatRemainingTime(),
            style: TextStyle(
              fontSize: 12,
              color: displayColor.withAlpha(220), // 稍微透明的文字
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建播放按钮
  Widget _buildPlayButton(Color displayColor) {
    return GestureDetector(
      onTap: _togglePlayback,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: displayColor.withAlpha(30),  // 轻微的背景色
          border: Border.all(
            color: displayColor.withAlpha(80), // 稍深的边框
            width: 1,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 波纹动画（播放时）
            if (_isPlaying)
              AnimatedBuilder(
                animation: _rippleAnimationController,
                builder: (context, child) {
                  return Container(
                    width: 40 + (_rippleAnimationController.value * 20),
                    height: 40 + (_rippleAnimationController.value * 20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: displayColor.withAlpha(
                          (77 * (1 - _rippleAnimationController.value)).round(),
                        ),
                        width: 1,
                      ),
                    ),
                  );
                },
              ),

            // 播放/暂停/加载图标
            if (_isLoading)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(displayColor),
                ),
              )
            else
              Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                color: displayColor,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  /// 构建波形显示
  Widget _buildWaveform(Color displayColor) {
    return SizedBox(
      height: 30,
      child: CustomPaint(
        painter: VoiceWavePainter(
          progress: _progress,
          animationValue: _isPlaying ? _waveAnimationController.value : 0.0,
          foregroundColor: displayColor,               // 已播放部分
          backgroundColor: displayColor.withAlpha(60), // 未播放部分，更透明
          durationSeconds:
              _totalDuration == Duration.zero ? 0 : _totalDuration.inSeconds,
        ),
        size: const Size(double.infinity, 30),
      ),
    );
  }
}

/// 语音波形绘制器
class VoiceWavePainter extends CustomPainter {
  final double progress;
  final double animationValue;
  final Color foregroundColor;
  final Color backgroundColor;
  final int durationSeconds;

  VoiceWavePainter({
    required this.progress,
    required this.animationValue,
    required this.foregroundColor,
    required this.backgroundColor,
    required this.durationSeconds,
  });

  /// 根据时长计算波形条数量
  int _calculateBarCount() {
    // 设定密度：每4像素一个波形条，保持视觉一致性
    const int minBars = 15; // 最少波形条数
    const int maxBars = 60; // 最多波形条数

    // 🔧 如果时长为0（没有预存时长信息），使用默认的中等条数
    if (durationSeconds == 0) {
      return 30; // 默认30条波形条
    }

    // 根据时长比例计算基础条数
    const maxDuration = VoiceRecordService.maxRecordingDuration;
    final ratio = (durationSeconds / maxDuration).clamp(0.0, 1.0);
    final calculatedBars = minBars + ((maxBars - minBars) * ratio).round();

    return calculatedBars.clamp(minBars, maxBars);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // 防止空画布
    if (size.width <= 0 || size.height <= 0) {
      return;
    }
    
    final paint = Paint()
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final barCount = _calculateBarCount(); // 🔧 动态计算波形条数量
    if (barCount <= 0) {
      return;
    }
    
    final barWidth = size.width / barCount;
    final centerY = size.height / 2;

    for (int i = 0; i < barCount; i++) {
      final x = i * barWidth + barWidth / 2;
      final normalizedX = i / (barCount - 1);

      // 基础波形高度
      double baseHeight = _generateWaveHeight(normalizedX);

      // 添加动画效果
      if (animationValue > 0) {
        final animationOffset = (animationValue * 2 + normalizedX) % 1.0;
        baseHeight *=
            (0.5 + 0.5 * (1 + math.sin(animationOffset * 2 * math.pi)) / 2);
      }

      final barHeight = baseHeight * (size.height * 0.8);

      // 根据播放进度确定颜色
      // 🔧 修复第一格在进度为0时显示为已播放的问题
      final isPlayed = progress > 0 && normalizedX < progress;
      paint.color = isPlayed ? foregroundColor : backgroundColor;

      // 绘制波形条
      canvas.drawLine(
        Offset(x, centerY - barHeight / 2),
        Offset(x, centerY + barHeight / 2),
        paint,
      );
    }
  }

  /// 生成波形高度（模拟真实语音波形）
  double _generateWaveHeight(double x) {
    return (0.3 * math.sin(x * 8 * math.pi) +
            0.4 * math.sin(x * 12 * math.pi + 1.5) +
            0.2 * math.sin(x * 20 * math.pi + 3.0) +
            0.1 * math.sin(x * 30 * math.pi + 4.5))
        .abs()
        .clamp(0.1, 1.0);
  }

  @override
  bool shouldRepaint(VoiceWavePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.animationValue != animationValue ||
        oldDelegate.foregroundColor != foregroundColor ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.durationSeconds != durationSeconds;
  }
}
