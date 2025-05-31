import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 未读消息指示器按钮
///
/// 显示在聊天页面底部，提供快速跳转到未读消息的功能
class UnreadIndicatorButton extends StatefulWidget {
  /// 未读消息数量
  final int unreadCount;

  /// 点击回调
  final VoidCallback? onTap;

  /// 是否显示
  final bool isVisible;

  /// 按钮文本
  final String? text;

  /// 是否显示动画
  final bool showAnimation;

  const UnreadIndicatorButton({
    super.key,
    required this.unreadCount,
    this.onTap,
    this.isVisible = true,
    this.text,
    this.showAnimation = true,
  });

  @override
  State<UnreadIndicatorButton> createState() => _UnreadIndicatorButtonState();
}

class _UnreadIndicatorButtonState extends State<UnreadIndicatorButton>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // 滑入动画控制器
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // 脉冲动画控制器
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // 滑入动画
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    // 脉冲动画
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // 启动脉冲动画循环
    if (widget.showAnimation) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(UnreadIndicatorButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 处理可见性变化
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _slideController.forward();
      } else {
        _slideController.reverse();
      }
    }

    // 处理动画状态变化
    if (widget.showAnimation != oldWidget.showAnimation) {
      if (widget.showAnimation) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
        _pulseController.reset();
      }
    }

    // 处理未读数量变化
    if (widget.unreadCount != oldWidget.unreadCount && widget.unreadCount > 0) {
      // 新的未读消息，触发一次强调动画
      _triggerEmphasisAnimation();
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _triggerEmphasisAnimation() {
    _pulseController.stop();
    _pulseController.reset();
    _pulseController.forward().then((_) {
      _pulseController.reverse().then((_) {
        if (widget.showAnimation && mounted) {
          _pulseController.repeat(reverse: true);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible || widget.unreadCount <= 0) {
      return const SizedBox.shrink();
    }

    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16, right: 16),
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: _buildButton(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildButton() {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(24),
      color: Colors.blue,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onTap?.call();
        },
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              colors: [
                Colors.blue.shade400,
                Colors.blue.shade600,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 未读数量徽章
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _formatUnreadCount(widget.unreadCount),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // 文本
              Text(
                widget.text ?? _getDefaultText(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(width: 4),

              // 箭头图标
              const Icon(
                Icons.keyboard_arrow_up,
                color: Colors.white,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatUnreadCount(int count) {
    if (count > 99) {
      return '99+';
    }
    return count.toString();
  }

  String _getDefaultText() {
    if (widget.unreadCount == 1) {
      return '1条未读消息';
    } else if (widget.unreadCount <= 99) {
      return '${widget.unreadCount}条未读消息';
    } else {
      return '99+条未读消息';
    }
  }
}

/// 二次跳转选择按钮
///
/// 当有多个跳转选项时显示的顶部提示条
class SecondaryJumpButton extends StatefulWidget {
  /// 是否显示
  final bool isVisible;

  /// 主要跳转文本
  final String primaryText;

  /// 次要跳转文本
  final String secondaryText;

  /// 主要跳转回调
  final VoidCallback? onPrimaryTap;

  /// 次要跳转回调
  final VoidCallback? onSecondaryTap;

  /// 关闭回调
  final VoidCallback? onDismiss;

  const SecondaryJumpButton({
    super.key,
    required this.isVisible,
    required this.primaryText,
    required this.secondaryText,
    this.onPrimaryTap,
    this.onSecondaryTap,
    this.onDismiss,
  });

  @override
  State<SecondaryJumpButton> createState() => _SecondaryJumpButtonState();
}

class _SecondaryJumpButtonState extends State<SecondaryJumpButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    if (widget.isVisible) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(SecondaryJumpButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) {
      return const SizedBox.shrink();
    }

    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.amber.shade100,
          border: Border(
            bottom: BorderSide(
              color: Colors.amber.shade300,
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // 信息图标
                Icon(
                  Icons.info_outline,
                  color: Colors.amber.shade700,
                  size: 20,
                ),

                const SizedBox(width: 8),

                // 提示文本
                Expanded(
                  child: Text(
                    '有多条未读消息，选择跳转位置：',
                    style: TextStyle(
                      color: Colors.amber.shade800,
                      fontSize: 14,
                    ),
                  ),
                ),

                // 主要跳转按钮
                TextButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    widget.onPrimaryTap?.call();
                  },
                  style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    widget.primaryText,
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                // 分隔符
                Container(
                  width: 1,
                  height: 16,
                  color: Colors.amber.shade300,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                ),

                // 次要跳转按钮
                TextButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    widget.onSecondaryTap?.call();
                  },
                  style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    widget.secondaryText,
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                // 关闭按钮
                IconButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    widget.onDismiss?.call();
                  },
                  icon: Icon(
                    Icons.close,
                    color: Colors.amber.shade700,
                    size: 18,
                  ),
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
