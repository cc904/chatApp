import 'package:flutter/material.dart';
import 'package:cc/core/services/media_service.dart';
import 'package:cc/core/database/models/message.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/services/voice_record_service.dart';
import 'dart:async';
import 'dart:math' as math;

/// 语音消息Widget
/// 支持播放、暂停、波形显示和倒计时
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
  final MediaService _mediaService = MediaService();
  final LogService _logger = LogService.instance;

  // 播放状态
  bool _isPlaying = false;
  bool _isLoading = false;

  // 进度相关
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = const Duration(seconds: 1); // 默认1秒，避免除零
  Duration _displayDuration = const Duration(seconds: 1); // 用于UI显示的时长
  double _progress = 0.0;

  // 动画控制器
  late AnimationController _waveAnimationController;
  late AnimationController _rippleAnimationController;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeDuration();
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
      _displayDuration = _totalDuration; // 🔧 同时初始化显示时长
      _logger.i('✅ 从消息初始化时长: ${_totalDuration.inSeconds}秒');
    } else {
      // 🔧 没有预存时长时，使用1秒作为内部计算避免除零，但不显示时间
      _totalDuration = const Duration(seconds: 1);
      _displayDuration = Duration.zero; // 不显示时间
      _logger.w('⚠️ 消息中没有时长信息，将在播放时动态获取');
    }
  }

  @override
  void dispose() {
    // 🔧 退出时停止音频播放，避免后台继续播放
    if (_isPlaying) {
      _logger.i('🚪 Widget dispose时停止音频播放');
      _mediaService.stopAudio().catchError((error) {
        _logger.e('❌ dispose时停止音频失败', error: error);
      });
    }

    _stopAnimations();
    _waveAnimationController.dispose();
    _rippleAnimationController.dispose();
    super.dispose();
  }

  /// 播放/暂停切换
  Future<void> _togglePlayback() async {
    _logger.i('🎯 用户点击按钮，当前状态: 播放=$_isPlaying, 加载=$_isLoading');

    if (_isLoading) {
      _logger.w('⏳ 正在加载中，忽略点击');
      return;
    }

    try {
      if (_isPlaying) {
        // 当前正在播放 -> 暂停
        await _pauseAudio();
      } else {
        // 当前暂停/停止 -> 播放
        if (_currentPosition.inMilliseconds > 0 && _progress < 1.0) {
          // 有进度且未播放完 -> 恢复播放
          await _resumeAudio();
        } else {
          // 从头开始播放
          await _playAudio();
        }
      }
    } catch (error) {
      _logger.e('❌ 播放控制失败', error: error);
      _showErrorSnackBar('播放失败: $error');

      // 错误时重置状态
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _isLoading = false;
        });
        _stopAnimations();
      }
    }
  }

  /// 开始播放
  Future<void> _playAudio() async {
    final audioPath = widget.message.mediaUrl ?? widget.message.localPath;
    if (audioPath == null || audioPath.isEmpty) {
      throw Exception('语音文件路径为空');
    }

    _logger.i('🎵 开始播放: $audioPath');

    // 显示加载状态
    setState(() {
      _isLoading = true;
      _isPlaying = false;
    });

    try {
      // 🔧 在调用播放前立即设置播放状态，避免进度回调时的状态不同步
      setState(() {
        _isPlaying = true;
        _isLoading = false;
      });

      // 启动动画
      _startAnimations();

      // 调用MediaService播放
      if (widget.message.mediaUrl != null) {
        await _mediaService.playAudioFromUrl(
          widget.message.mediaUrl!,
          onProgress: _onProgressUpdate,
          onComplete: _onPlaybackCompleted,
        );
      } else {
        await _mediaService.playAudio(
          widget.message.localPath!,
          onProgress: _onProgressUpdate,
          onComplete: _onPlaybackCompleted,
        );
      }

      // 尝试获取音频时长
      _tryGetDuration();

      _logger.i('✅ 播放开始成功');
    } catch (error) {
      _logger.e('❌ 播放失败', error: error);
      setState(() {
        _isPlaying = false;
        _isLoading = false;
      });
      _stopAnimations();
      rethrow;
    }
  }

  /// 暂停播放
  Future<void> _pauseAudio() async {
    _logger.i('⏸️ 暂停播放');

    try {
      await _mediaService.pauseAudio();

      setState(() {
        _isPlaying = false;
        _isLoading = false;
      });

      _stopAnimations();
      _logger.i('✅ 暂停成功');
    } catch (error) {
      _logger.e('❌ 暂停失败', error: error);
      rethrow;
    }
  }

  /// 恢复播放
  Future<void> _resumeAudio() async {
    _logger.i('▶️ 恢复播放');

    try {
      // 🔧 在调用恢复前立即设置播放状态，避免进度回调时的状态不同步
      setState(() {
        _isPlaying = true;
        _isLoading = false;
      });

      _startAnimations();

      await _mediaService.resumeAudio();

      _logger.i('✅ 恢复成功');
    } catch (error) {
      _logger.e('❌ 恢复失败', error: error);
      setState(() {
        _isPlaying = false;
        _isLoading = false;
      });
      _stopAnimations();
      rethrow;
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

  /// 尝试获取音频时长
  void _tryGetDuration() async {
    // 多次尝试获取时长，使用渐进式延迟
    final delays = [0, 100, 300, 500, 1000];

    for (int i = 0; i < delays.length; i++) {
      if (!mounted) break;

      await Future.delayed(Duration(milliseconds: delays[i]));

      final duration = _mediaService.getCurrentAudioDuration();
      if (duration != null && duration.inMilliseconds > 1000) {
        if (mounted) {
          // 🔧 更新内部时长，同时智能更新显示时长
          final oldDisplaySeconds = _displayDuration.inSeconds;
          final newSeconds = duration.inSeconds;

          // 如果没有预存时长（显示时长为0），或者差异不超过5秒，则同步更新显示时长
          final shouldUpdateDisplay = _displayDuration == Duration.zero ||
              (newSeconds - oldDisplaySeconds).abs() <= 5;

          _totalDuration = duration;
          if (shouldUpdateDisplay) {
            setState(() {
              _displayDuration = duration;
            });
            _logger.i('✅ 获取到音频时长: ${duration.inSeconds}秒 (同时更新显示时长)');
          } else {
            _logger.i(
                '✅ 获取到音频时长: ${duration.inSeconds}秒 (显示时长保持: ${_displayDuration.inSeconds}秒)');
          }
          return;
        }
      }
    }

    _logger.w('⚠️ 未能获取到有效时长，将使用默认值');
  }

  /// 进度更新回调
  void _onProgressUpdate(double progress) {
    if (!mounted) return;

    // 🔧 优先处理播放完成，避免状态不同步
    if (progress >= 0.99) {
      _onPlaybackCompleted();
      return;
    }

    // 如果UI显示暂停但仍收到进度更新，说明状态不同步
    // （忽略接近完成时的最后几个更新，因为已在上面处理）
    if (!_isPlaying) {
      _logger
          .w('⚠️ 状态不同步：UI暂停但仍收到进度更新 ${(progress * 100).toStringAsFixed(1)}%');
      return;
    }

    // 动态获取时长
    if (_totalDuration.inMilliseconds <= 1000) {
      final realDuration = _mediaService.getCurrentAudioDuration();
      if (realDuration != null && realDuration.inMilliseconds > 1000) {
        _totalDuration = realDuration;
      }
    }

    final currentPos = Duration(
      milliseconds: (progress * _totalDuration.inMilliseconds).round(),
    );

    setState(() {
      _currentPosition = currentPos;
      _progress = progress.clamp(0.0, 1.0);
    });
  }

  /// 播放完成
  void _onPlaybackCompleted() {
    if (!mounted) return;

    _logger.i('🏁 播放完成');

    setState(() {
      _isPlaying = false;
      _isLoading = false;
      _currentPosition = Duration.zero;
      _progress = 0.0;
    });

    _stopAnimations();
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
    if (_displayDuration == Duration.zero) {
      return '--:--';
    }

    // 🔧 使用真实时长计算倒计时，确保时间能正确变动
    // 但如果真实时长还没获取到，则使用显示时长作为回退
    final effectiveDuration = _totalDuration.inMilliseconds > 1000
        ? _totalDuration
        : _displayDuration;

    final remaining = Duration(
      milliseconds: math.max(
        0,
        effectiveDuration.inMilliseconds - _currentPosition.inMilliseconds,
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

    // 🔧 使用显示时长而不是实际时长，避免UI突变
    final durationSeconds = _displayDuration.inSeconds;

    // 🔧 如果没有时长信息（显示时长为0），使用最小宽度
    if (_displayDuration == Duration.zero || durationSeconds <= 1) {
      return minWidth;
    }

    // 根据时长比例计算宽度，使用VoiceRecordService的最大时长作为基准
    const maxDuration = VoiceRecordService.maxRecordingDuration;
    final ratio = (durationSeconds / maxDuration).clamp(0.0, 1.0);
    final calculatedWidth = minWidth + (maxWidth - minWidth) * ratio;

    _logger.d('计算语音UI宽度', extra: {
      'duration': durationSeconds,
      'maxDuration': maxDuration,
      'ratio': ratio,
      'width': calculatedWidth,
    });

    return calculatedWidth;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foregroundColor = widget.foregroundColor ??
        (widget.isCurrentUser ? Colors.white : theme.colorScheme.onSurface);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      width: _calculateWidthFromDuration(),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          // 播放按钮
          _buildPlayButton(foregroundColor),
          const SizedBox(width: 12),

          // 波形显示区域
          Expanded(
            child: _buildWaveform(foregroundColor),
          ),

          const SizedBox(width: 12),

          // 倒计时显示
          Text(
            _formatRemainingTime(),
            style: TextStyle(
              fontSize: 12,
              color: foregroundColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建播放按钮
  Widget _buildPlayButton(Color foregroundColor) {
    return GestureDetector(
      onTap: _togglePlayback,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: foregroundColor.withAlpha(25),
          border: Border.all(
            color: foregroundColor.withAlpha(77),
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
                        color: foregroundColor.withAlpha(
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
                  valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
                ),
              )
            else
              Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                color: foregroundColor,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  /// 构建波形显示
  Widget _buildWaveform(Color foregroundColor) {
    return SizedBox(
      height: 30,
      child: AnimatedBuilder(
        animation: _waveAnimationController,
        builder: (context, child) {
          return CustomPaint(
            painter: VoiceWavePainter(
              progress: _progress,
              animationValue: _isPlaying ? _waveAnimationController.value : 0.0,
              foregroundColor: foregroundColor,
              backgroundColor: foregroundColor.withAlpha(51),
              durationSeconds: _displayDuration == Duration.zero
                  ? 0 // 🔧 没有时长信息时传递0，让波形绘制器使用默认值
                  : _displayDuration.inSeconds,
            ),
            size: const Size(double.infinity, 30),
          );
        },
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
    final paint = Paint()
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final barCount = _calculateBarCount(); // 🔧 动态计算波形条数量
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
