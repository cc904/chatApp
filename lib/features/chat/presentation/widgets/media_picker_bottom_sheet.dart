import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cc/core/services/media_service.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/services/ui_notification_service.dart';

/// 媒体选择器底部弹窗
/// 提供图片、视频、文件、语音等媒体类型的选择功能
class MediaPickerBottomSheet extends StatefulWidget {
  /// 选择图片回调
  final Function(File imageFile)? onImageSelected;

  /// 选择视频回调
  final Function(File videoFile)? onVideoSelected;

  /// 选择文件回调
  final Function(File file)? onFileSelected;

  /// 录音完成回调
  final Function(File audioFile, int duration)? onAudioRecorded;

  const MediaPickerBottomSheet({
    super.key,
    this.onImageSelected,
    this.onVideoSelected,
    this.onFileSelected,
    this.onAudioRecorded,
  });

  @override
  State<MediaPickerBottomSheet> createState() => _MediaPickerBottomSheetState();
}

class _MediaPickerBottomSheetState extends State<MediaPickerBottomSheet>
    with TickerProviderStateMixin {
  final _logger = LogService.instance;
  final _mediaService = MediaService();

  bool _isRecording = false;
  bool _isProcessing = false;

  late AnimationController _recordingAnimationController;
  late Animation<double> _recordingAnimation;

  @override
  void initState() {
    super.initState();

    // 初始化录音动画
    _recordingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _recordingAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _recordingAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _recordingAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 拖拽指示器
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // 标题
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(
                '选择媒体类型',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // 媒体选项网格
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // 第一行：图片和视频
                  Row(
                    children: [
                      Expanded(
                        child: _buildMediaOption(
                          icon: Icons.photo_library,
                          label: '相册',
                          color: Colors.blue,
                          onTap: () => _pickImage(fromCamera: false),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildMediaOption(
                          icon: Icons.camera_alt,
                          label: '拍照',
                          color: Colors.green,
                          onTap: () => _pickImage(fromCamera: true),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 第二行：视频和文件
                  Row(
                    children: [
                      Expanded(
                        child: _buildMediaOption(
                          icon: Icons.videocam,
                          label: '录制视频',
                          color: Colors.red,
                          onTap: () => _pickVideo(fromCamera: true),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildMediaOption(
                          icon: Icons.video_library,
                          label: '视频库',
                          color: Colors.orange,
                          onTap: () => _pickVideo(fromCamera: false),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 第三行：文件和语音
                  Row(
                    children: [
                      Expanded(
                        child: _buildMediaOption(
                          icon: Icons.attach_file,
                          label: '文件',
                          color: Colors.purple,
                          onTap: _pickFile,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildVoiceRecordOption(),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 处理状态指示器
            if (_isProcessing)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 12),
                    Text('正在处理...'),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 构建媒体选项按钮
  Widget _buildMediaOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isProcessing ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: color.withAlpha(26),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withAlpha(77)),
          ),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建语音录制选项
  Widget _buildVoiceRecordOption() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isProcessing ? null : _toggleVoiceRecording,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedBuilder(
          animation: _recordingAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _isRecording ? _recordingAnimation.value : 1.0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: _isRecording
                      ? Colors.red.withAlpha(51)
                      : Colors.amber.withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isRecording
                        ? Colors.red.withAlpha(128)
                        : Colors.amber.withAlpha(77),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      _isRecording ? Icons.stop : Icons.mic,
                      size: 32,
                      color: _isRecording ? Colors.red : Colors.amber,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isRecording ? '停止录音' : '录音',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _isRecording ? Colors.red : Colors.amber,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// 选择图片
  Future<void> _pickImage({required bool fromCamera}) async {
    try {
      setState(() => _isProcessing = true);

      final imageFile = await _mediaService.pickImage(fromCamera: fromCamera);

      if (imageFile != null && widget.onImageSelected != null) {
        widget.onImageSelected!(imageFile);
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (error) {
      _logger.e('选择图片失败', error: error);
      UINotificationService().showError('选择图片失败: $error');
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  /// 选择视频
  Future<void> _pickVideo({required bool fromCamera}) async {
    try {
      setState(() => _isProcessing = true);

      final videoFile = await _mediaService.pickVideo(fromCamera: fromCamera);

      if (videoFile != null && widget.onVideoSelected != null) {
        widget.onVideoSelected!(videoFile);
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (error) {
      _logger.e('选择视频失败', error: error);
      UINotificationService().showError('选择视频失败: $error');
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  /// 选择文件
  Future<void> _pickFile() async {
    try {
      setState(() => _isProcessing = true);

      final file = await _mediaService.pickFile();

      if (file != null && widget.onFileSelected != null) {
        widget.onFileSelected!(file);
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (error) {
      _logger.e('选择文件失败', error: error);
      UINotificationService().showError('选择文件失败: $error');
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  /// 切换语音录制状态
  Future<void> _toggleVoiceRecording() async {
    try {
      if (_isRecording) {
        // 停止录音
        await _stopRecording();
      } else {
        // 开始录音
        await _startRecording();
      }
    } catch (error) {
      _logger.e('录音操作失败', error: error);
      UINotificationService().showError('录音操作失败: $error');
    }
  }

  /// 开始录音
  Future<void> _startRecording() async {
    final success = await _mediaService.startRecording();

    if (success) {
      setState(() => _isRecording = true);
      _recordingAnimationController.repeat(reverse: true);

      // 触觉反馈
      HapticFeedback.mediumImpact();

      _logger.i('开始录音');
    } else {
      UINotificationService().showError('无法开始录音，请检查麦克风权限');
    }
  }

  /// 停止录音
  Future<void> _stopRecording() async {
    setState(() => _isProcessing = true);

    final result = await _mediaService.stopRecording();

    setState(() {
      _isRecording = false;
      _isProcessing = false;
    });

    _recordingAnimationController.stop();
    _recordingAnimationController.reset();

    if (result != null && widget.onAudioRecorded != null) {
      widget.onAudioRecorded!(result.file, result.duration);
      if (mounted) {
        Navigator.pop(context);
      }

      // 触觉反馈
      HapticFeedback.lightImpact();

      _logger.i('录音完成', extra: {'duration': result.duration});
    } else {
      UINotificationService().showError('录音失败，请重试');
    }
  }

  /// 显示媒体选择器
  /// 这是一个公共API方法，供外部组件调用
  // ignore: unused_element
  static Future<void> show(
    BuildContext context, {
    Function(File imageFile)? onImageSelected,
    Function(File videoFile)? onVideoSelected,
    Function(File file)? onFileSelected,
    Function(File audioFile, int duration)? onAudioRecorded,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MediaPickerBottomSheet(
        onImageSelected: onImageSelected,
        onVideoSelected: onVideoSelected,
        onFileSelected: onFileSelected,
        onAudioRecorded: onAudioRecorded,
      ),
    );
  }
}
