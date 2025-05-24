import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// 通用用户头像组件
///
/// 支持网络图片和本地图片，包含错误处理和加载状态
/// 当图片加载失败或不存在时，显示用户名首字母
class UserAvatar extends StatelessWidget {
  /// 头像URL，可以是网络URL或本地文件路径
  final String? avatarUrl;

  /// 用户名，用于生成首字母头像
  final String name;

  /// 头像半径
  final double radius;

  /// 背景颜色，用于首字母头像
  final Color? backgroundColor;

  /// 是否显示边框
  final bool showBorder;

  /// 边框颜色
  final Color borderColor;

  /// 边框宽度
  final double borderWidth;

  const UserAvatar({
    super.key,
    this.avatarUrl,
    required this.name,
    this.radius = 20,
    this.backgroundColor,
    this.showBorder = false,
    this.borderColor = Colors.white,
    this.borderWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    final defaultBackgroundColor = backgroundColor ?? Colors.grey[300];
    final hasValidAvatar = avatarUrl != null && avatarUrl!.isNotEmpty;

    // 创建首字母文本
    final initialsText = Text(
      name.isNotEmpty ? name[0].toUpperCase() : '?',
      style: TextStyle(
        color: Colors.white,
        fontSize: radius * 0.7,
        fontWeight: FontWeight.bold,
      ),
    );

    // 创建头像组件
    Widget avatar;

    if (!hasValidAvatar) {
      // 如果没有有效的头像URL，显示首字母头像
      avatar = CircleAvatar(
        radius: radius,
        backgroundColor: defaultBackgroundColor,
        child: initialsText,
      );
    } else {
      // 如果有有效的头像URL，使用CachedNetworkImage
      avatar = CircleAvatar(
        radius: radius,
        backgroundColor: defaultBackgroundColor,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: CachedNetworkImage(
            imageUrl: avatarUrl!,
            fit: BoxFit.cover,
            width: radius * 2,
            height: radius * 2,
            placeholder: (context, url) => Container(
              color: defaultBackgroundColor,
              child: Center(
                child: SizedBox(
                  width: radius * 0.6,
                  height: radius * 0.6,
                  child: CircularProgressIndicator(
                    strokeWidth: radius * 0.1,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            errorWidget: (context, url, error) => initialsText,
          ),
        ),
      );
    }

    // 如果需要显示边框，添加边框
    if (showBorder) {
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: borderColor,
            width: borderWidth,
          ),
        ),
        child: avatar,
      );
    }

    return avatar;
  }
}
 