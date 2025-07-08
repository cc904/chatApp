import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cc/core/constants/app_colors.dart';

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
    with SingleTickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // 滑入动画控制器
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
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
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
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
        child: _buildButton(),
      ),
    );
  }

  Widget _buildButton() {
    return SizedBox(
      width: 60,
      height: 60,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 圆形底部，图标居中
          Positioned(
            bottom: 0,
            left: 5,
            right: 5,
            child: Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(25),
              color: Colors.white,
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  widget.onTap?.call();
                },
                borderRadius: BorderRadius.circular(25),
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      _getDirectionIcon(),
                      color: Colors.grey.shade600,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // 数字徽章，蓝底上浮，水平居中对齐
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                constraints: const BoxConstraints(
                  minWidth: 22,
                  minHeight: 22,
                ),
                child: Text(
                  widget.unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getDirectionIcon() {
    if (widget.text != null) {
      if (widget.text!.contains('↑')) {
        return Icons.expand_less;
      } else if (widget.text!.contains('↓')) {
        return Icons.expand_more;
      }
    }
    return Icons.expand_more; // 默认向下
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
                    style: const TextStyle(
                      color: AppColors.primary,
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
                    style: const TextStyle(
                      color: AppColors.primary,
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
