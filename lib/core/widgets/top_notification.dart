import 'package:flutter/material.dart';
import 'package:cc/core/constants/app_colors.dart';

/// 顶部通知组件
/// 
/// 显示在应用顶部的滑动通知，用于应用内消息提醒
class TopNotification extends StatefulWidget {
  final String title;
  final String message;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final Duration duration;
  final VoidCallback? onTap;
  final VoidCallback? onClose;
  final bool showCloseButton;

  const TopNotification({
    super.key,
    required this.title,
    required this.message,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.duration = const Duration(seconds: 3),
    this.onTap,
    this.onClose,
    this.showCloseButton = true,
  });

  @override
  State<TopNotification> createState() => _TopNotificationState();
}

class _TopNotificationState extends State<TopNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    // 启动动画
    _animationController.forward();

    // 自动消失
    Future.delayed(widget.duration, () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _dismiss() async {
    await _animationController.reverse();
    if (mounted) {
      widget.onClose?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _opacityAnimation,
            child: Material(
              elevation: 8,
              color: Colors.transparent,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 16,
                  right: 16,
                  bottom: 12,
                ),
                decoration: BoxDecoration(
                  color: widget.backgroundColor ?? AppColors.primary,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(51),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: GestureDetector(
                  onTap: () {
                    _dismiss();
                    widget.onTap?.call();
                  },
                  child: Row(
                    children: [
                      // 图标
                      if (widget.icon != null) ...[
                        Icon(
                          widget.icon,
                          color: widget.textColor ?? Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                      ],

                      // 内容
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: widget.textColor ?? Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.message,
                              style: TextStyle(
                                fontSize: 14,
                                color: (widget.textColor ?? Colors.white).withAlpha(230),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      // 关闭按钮
                      if (widget.showCloseButton) ...[
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _dismiss,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              Icons.close,
                              color: (widget.textColor ?? Colors.white).withAlpha(179),
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 顶部通知管理器
class TopNotificationManager {
  static final TopNotificationManager _instance = TopNotificationManager._internal();
  static TopNotificationManager get instance => _instance;
  TopNotificationManager._internal();

  OverlayEntry? _currentOverlay;

  /// 显示顶部通知
  void show({
    required BuildContext context,
    required String title,
    required String message,
    IconData? icon,
    Color? backgroundColor,
    Color? textColor,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onTap,
    bool showCloseButton = true,
  }) {
    try {
      // 关闭现有通知
      hide();

      // 确保可以找到Overlay
      // 首先尝试从根Navigator获取Overlay
      OverlayState? overlay = Overlay.maybeOf(context, rootOverlay: true);
      
      // 如果根Overlay不可用，尝试最近的Overlay
      overlay ??= Overlay.maybeOf(context, rootOverlay: false);
      
      if (overlay == null) {
        throw Exception('No Overlay found in context');
      }

      _currentOverlay = OverlayEntry(
        builder: (context) => Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: TopNotification(
            title: title,
            message: message,
            icon: icon,
            backgroundColor: backgroundColor,
            textColor: textColor,
            duration: duration,
            onTap: onTap,
            onClose: hide,
            showCloseButton: showCloseButton,
          ),
        ),
      );

      overlay.insert(_currentOverlay!);
    } catch (e) {
      // 如果发生错误，重新抛出让调用者处理
      rethrow;
    }
  }

  /// 隐藏当前通知
  void hide() {
    _currentOverlay?.remove();
    _currentOverlay = null;
  }
}

/// 顶部通知类型
enum TopNotificationType {
  success,
  error,
  warning,
  info,
  message,
}

/// 顶部通知样式配置
class TopNotificationStyle {
  final IconData icon;
  final Color backgroundColor;
  final Color textColor;

  const TopNotificationStyle({
    required this.icon,
    required this.backgroundColor,
    required this.textColor,
  });

  static TopNotificationStyle fromType(TopNotificationType type) {
    switch (type) {
      case TopNotificationType.success:
        return const TopNotificationStyle(
          icon: Icons.check_circle,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      case TopNotificationType.error:
        return const TopNotificationStyle(
          icon: Icons.error,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      case TopNotificationType.warning:
        return const TopNotificationStyle(
          icon: Icons.warning,
          backgroundColor: Colors.orange,
          textColor: Colors.white,
        );
      case TopNotificationType.info:
        return const TopNotificationStyle(
          icon: Icons.info,
          backgroundColor: AppColors.primary,
          textColor: Colors.white,
        );
      case TopNotificationType.message:
        return const TopNotificationStyle(
          icon: Icons.message,
          backgroundColor: Color(0xFF2196F3),
          textColor: Colors.white,
        );
    }
  }
}