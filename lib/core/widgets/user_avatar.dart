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
    // 根据名字生成随机颜色（保持一致性）
    Color getColorFromName(String name) {
      if (name.isEmpty) return Colors.blueGrey;

      // 使用名字的哈希值生成颜色，这样同一个名字总是得到相同的颜色
      final int hash = name.hashCode;

      // 预定义一组漂亮的背景颜色
      final List<Color> colors = [
        Colors.blue[400]!,
        Colors.green[400]!,
        Colors.purple[400]!,
        Colors.orange[400]!,
        Colors.teal[400]!,
        Colors.pink[400]!,
        Colors.indigo[400]!,
        Colors.cyan[400]!,
        Colors.deepOrange[400]!,
        Colors.deepPurple[400]!,
      ];

      // 使用哈希值选择颜色
      return colors[hash.abs() % colors.length];
    }

    final nameColor = backgroundColor ?? getColorFromName(name);
    final hasValidAvatar = avatarUrl != null && avatarUrl!.isNotEmpty;

    // 获取要显示的文本内容
    String displayText = '?';
    if (name.isNotEmpty) {
      // 判断是否为中文名称(简单判断：如果不包含英文字母和数字，则视为中文)
      bool isChinese = !RegExp(r'[a-zA-Z0-9]').hasMatch(name);

      if (isChinese) {
        switch (name.length) {
          case 2: // 两个字的中文名，显示全名
            displayText = name;
            break;
          case 3: // 三个字的中文名，显示后两个字
            displayText = name.substring(1);
            break;
          default: // 其他情况，只显示第一个字
            displayText = name[0];
        }
      } else {
        // 非中文名称，显示第一个字母并大写
        displayText = name[0].toUpperCase();
      }
    }

    // 创建首字母/姓名文本的样式
    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: displayText.length > 1 ? radius * 0.5 : radius * 0.7,
      fontWeight: FontWeight.bold,
      letterSpacing: -0.5, // 减小字母间距，使文字更紧凑
    );

    // 创建头像组件
    Widget avatar;

    if (!hasValidAvatar) {
      // 如果没有有效的头像URL，显示美化的首字母头像
      avatar = Container(
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              nameColor.withAlpha(255), // 完全不透明
              nameColor.withAlpha(190), // 稍微暗一些
            ],
          ),
          boxShadow: [
            // 内部高光 - 顶部边缘更亮，增加立体感
            BoxShadow(
              color: Colors.white.withAlpha(50),
              blurRadius: 5,
              spreadRadius: -2,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            displayText,
            style: textStyle,
            textAlign: TextAlign.center,
          ),
        ),
      );
    } else {
      // 如果有有效的头像URL，使用CachedNetworkImage
      avatar = CircleAvatar(
        radius: radius,
        backgroundColor: nameColor,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: CachedNetworkImage(
            imageUrl: avatarUrl!,
            fit: BoxFit.cover,
            width: radius * 2,
            height: radius * 2,
            placeholder: (context, url) => Container(
              color: nameColor,
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
            errorWidget: (context, url, error) => Container(
              width: radius * 2,
              height: radius * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    nameColor.withAlpha(255), // 完全不透明
                    nameColor.withAlpha(190), // 稍微暗一些
                  ],
                ),
              ),
              child: Center(
                child: Text(
                  displayText,
                  style: textStyle,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
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
