import 'dart:async';
import 'package:just_audio/just_audio.dart';
import 'package:cc/core/services/log_service.dart';

/// 全局音频播放管理器（单例）
/// 确保同时只有一个语音在播放，所有UI组件状态同步
class AudioPlayerManager {
  static final AudioPlayerManager _instance = AudioPlayerManager._internal();
  factory AudioPlayerManager() => _instance;
  AudioPlayerManager._internal();

  final LogService _logger = LogService.instance;

  // 单例播放器
  AudioPlayer? _player;

  // 当前播放状态
  String? _currentMessageId;
  bool _isPlaying = false;
  bool _isPaused = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  double _progress = 0.0;

  // 状态变化通知
  final StreamController<AudioPlaybackState> _stateController =
      StreamController<AudioPlaybackState>.broadcast();

  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<ProcessingState>? _processingStateSubscription;

  /// 获取状态流
  Stream<AudioPlaybackState> get stateStream => _stateController.stream;

  /// 获取当前状态
  AudioPlaybackState get currentState => AudioPlaybackState(
        messageId: _currentMessageId,
        isPlaying: _isPlaying,
        isPaused: _isPaused,
        position: _position,
        duration: _duration,
        progress: _progress,
      );

  /// 检查指定消息是否正在播放
  bool isMessagePlaying(String messageId) {
    return _currentMessageId == messageId && _isPlaying && !_isPaused;
  }

  /// 检查指定消息是否已暂停
  bool isMessagePaused(String messageId) {
    return _currentMessageId == messageId && !_isPlaying && _isPaused;
  }

  /// 播放或控制语音
  Future<void> playVoice(String messageId, String audioPath) async {
    _logger.i('🎵 播放请求: $messageId');

    // 如果点击的是正在播放的消息 -> 暂停
    if (isMessagePlaying(messageId)) {
      await pause();
      return;
    }

    // 如果点击的是已暂停的消息 -> 恢复播放
    if (isMessagePaused(messageId)) {
      await resume();
      return;
    }

    // 否则开始播放新消息
    await _startNewPlayback(messageId, audioPath);
  }

  /// 开始播放新音频
  Future<void> _startNewPlayback(String messageId, String audioPath) async {
    try {
      _logger.i('🎵 开始新播放: $messageId, 路径: $audioPath');

      // 停止当前播放
      await _stopCurrent();

      // 初始化播放器
      await _ensurePlayerInitialized();

      // 设置新状态
      _currentMessageId = messageId;
      _isPlaying = true;
      _isPaused = false;
      _position = Duration.zero;
      _progress = 0.0;

      // 通知状态变化
      _notifyStateChange();

      // 设置音频源
      if (audioPath.startsWith('http')) {
        await _player!.setUrl(audioPath);
      } else {
        String effectivePath = audioPath;
        if (audioPath.startsWith('file://')) {
          effectivePath = audioPath.substring(7);
        }
        await _player!.setFilePath(effectivePath);
      }

      // 获取时长
      _duration = _player!.duration ?? Duration.zero;
      _notifyStateChange();

      // 设置进度监听
      _setupProgressListener();

      // 开始播放
      await _player!.play();
      _logger.i('✅ 播放开始: $messageId');
    } catch (error) {
      _logger.e('❌ 播放失败', error: error);
      await _reset();
      rethrow;
    }
  }

  /// 暂停播放
  Future<void> pause() async {
    if (_player == null || !_isPlaying) return;

    try {
      await _player!.pause();
      _isPlaying = false;
      _isPaused = true;
      _notifyStateChange();
      _logger.i('⏸️ 已暂停: $_currentMessageId');
    } catch (error) {
      _logger.e('❌ 暂停失败', error: error);
    }
  }

  /// 恢复播放
  Future<void> resume() async {
    if (_player == null || !_isPaused) return;

    try {
      await _player!.play();
      _isPlaying = true;
      _isPaused = false;
      _notifyStateChange();
      _logger.i('▶️ 已恢复: $_currentMessageId');
    } catch (error) {
      _logger.e('❌ 恢复失败', error: error);
    }
  }

  /// 停止当前播放
  Future<void> _stopCurrent() async {
    if (_player == null) return;

    try {
      await _clearSubscriptions();
      await _player!.stop();
      _logger.i('🛑 已停止: $_currentMessageId');
    } catch (error) {
      _logger.e('❌ 停止失败', error: error);
    }
  }

  /// 停止所有音频播放
  Future<void> stopAll() async {
    await _reset();
  }

  /// 重置所有状态
  Future<void> _reset() async {
    await _stopCurrent();
    _currentMessageId = null;
    _isPlaying = false;
    _isPaused = false;
    _position = Duration.zero;
    _duration = Duration.zero;
    _progress = 0.0;
    _notifyStateChange();
  }

  /// 确保播放器已初始化
  Future<void> _ensurePlayerInitialized() async {
    if (_player == null) {
      _player = AudioPlayer();

      // 监听播放完成
      _processingStateSubscription =
          _player!.processingStateStream.listen((state) {
        if (state == ProcessingState.completed) {
          _onPlaybackCompleted();
        }
      });
    }
  }

  /// 设置进度监听
  void _setupProgressListener() {
    _positionSubscription = _player!.positionStream.listen((position) {
      _position = position;

      if (_duration.inMilliseconds > 0) {
        _progress = (position.inMilliseconds / _duration.inMilliseconds)
            .clamp(0.0, 1.0);

        // 播放完成检测
        if (_progress >= 0.99) {
          _onPlaybackCompleted();
          return;
        }
      }

      _notifyStateChange();
    });
  }

  /// 播放完成处理
  void _onPlaybackCompleted() {
    _logger.i('🏁 播放完成: $_currentMessageId');
    _reset();
  }

  /// 清理订阅
  Future<void> _clearSubscriptions() async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  /// 通知状态变化
  void _notifyStateChange() {
    _stateController.add(currentState);
  }

  /// 释放资源
  Future<void> dispose() async {
    await _clearSubscriptions();
    await _processingStateSubscription?.cancel();
    await _player?.dispose();
    await _stateController.close();
  }
}

/// 音频播放状态
class AudioPlaybackState {
  final String? messageId;
  final bool isPlaying;
  final bool isPaused;
  final Duration position;
  final Duration duration;
  final double progress;

  const AudioPlaybackState({
    this.messageId,
    this.isPlaying = false,
    this.isPaused = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.progress = 0.0,
  });

  /// 检查指定消息是否正在播放
  bool isMessagePlaying(String messageId) {
    return this.messageId == messageId && isPlaying && !isPaused;
  }

  /// 检查指定消息是否已暂停
  bool isMessagePaused(String messageId) {
    return this.messageId == messageId && !isPlaying && isPaused;
  }
}
 