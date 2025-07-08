import 'package:flutter/material.dart';

/// 应用全局颜色配置
///
/// 统一管理应用中使用的所有颜色，确保设计一致性
/// 支持主题切换和品牌色彩管理
class AppColors {
  // 私有构造函数，防止实例化
  AppColors._();

  // ===== 主色调 =====
  /// 主色调 - 绿色系
  static const Color primary = Colors.green;
  static final Color primaryLight = Colors.green[300]!;
  static final Color primaryDark = Colors.green[700]!;

  /// 主色调的不同深度
  static final Color primary50 = Colors.green[50]!;
  static final Color primary100 = Colors.green[100]!;
  static final Color primary200 = Colors.green[200]!;
  static final Color primary300 = Colors.green[300]!;
  static final Color primary400 = Colors.green[400]!;
  static final Color primary500 = Colors.green[500]!;
  static final Color primary600 = Colors.green[600]!;
  static final Color primary700 = Colors.green[700]!;
  static final Color primary800 = Colors.green[800]!;
  static final Color primary900 = Colors.green[900]!;

  // ===== 状态颜色 =====
  /// 成功状态
  static const Color success = Colors.green;
  static final Color successLight = Colors.green[100]!;
  static final Color successDark = Colors.green[700]!;

  /// 错误状态
  static const Color error = Colors.red;
  static final Color errorLight = Colors.red[100]!;
  static final Color errorDark = Colors.red[700]!;

  /// 警告状态
  static const Color warning = Colors.orange;
  static final Color warningLight = Colors.orange[100]!;
  static final Color warningDark = Colors.orange[700]!;

  /// 信息状态
  static final Color info = primary600;
  static final Color infoLight = primary100;
  static final Color infoDark = primary700;

  // ===== 中性颜色 =====
  /// 灰色系
  static final Color grey50 = Colors.grey[50]!;
  static final Color grey100 = Colors.grey[100]!;
  static final Color grey200 = Colors.grey[200]!;
  static final Color grey300 = Colors.grey[300]!;
  static final Color grey400 = Colors.grey[400]!;
  static final Color grey500 = Colors.grey[500]!;
  static final Color grey600 = Colors.grey[600]!;
  static final Color grey700 = Colors.grey[700]!;
  static final Color grey800 = Colors.grey[800]!;
  static final Color grey900 = Colors.grey[900]!;

  /// 文本颜色
  static const Color textPrimary = Colors.black87;
  static const Color textSecondary = Colors.black54;
  static final Color textTertiary = Colors.grey[600]!;
  static final Color textDisabled = Colors.grey[400]!;

  // ===== 背景颜色 =====
  /// 页面背景
  static const Color background = Color(0xFFF2F2F7);
  static const Color surface = Colors.white;
  static final Color surfaceVariant = Colors.grey[50]!;

  // ===== 聊天相关颜色 =====
  /// 消息气泡颜色
  static final Color messageBubbleOwn = primary200;
  static final Color messageBubbleOther = grey100;

  /// 在线状态
  static const Color online = Colors.green;
  static final Color offline = Colors.grey[400]!;

  /// 未读消息
  static const Color unread = Colors.red;
  static final Color unreadBackground = Colors.red[100]!;

  // ===== 角色颜色 =====
  /// CEO/Owner 角色
  static final Color roleOwner = Colors.purple[700]!;
  static final Color roleOwnerBackground = Colors.purple[100]!;

  /// Admin 角色
  static final Color roleAdmin = primary700;
  static final Color roleAdminBackground = primary100;

  /// 普通成员
  static final Color roleMember = grey700;
  static final Color roleMemberBackground = grey200;

  // ===== 媒体类型颜色 =====
  /// 图片
  static final Color mediaImage = primary700;
  static final Color mediaImageBackground = primary100;

  /// 视频
  static final Color mediaVideo = Colors.purple[700]!;
  static final Color mediaVideoBackground = Colors.purple[100]!;

  /// 语音
  static final Color mediaVoice = primary700;
  static final Color mediaVoiceBackground = primary100;

  /// 文件
  static final Color mediaFile = Colors.orange[700]!;
  static final Color mediaFileBackground = Colors.orange[100]!;

  /// 链接
  static final Color mediaLink = primary700;
  static final Color mediaLinkBackground = primary100;

  // ===== 系统颜色 =====
  /// 分割线
  static final Color divider = Colors.grey[300]!;

  /// 边框
  static final Color border = Colors.grey[200]!;

  /// 阴影
  static final Color shadow = Colors.black.withAlpha(26);

  // ===== 主题相关方法 =====
  /// 获取主色调的 MaterialColor
  static MaterialColor get primarySwatch => Colors.green;

  /// 获取 ColorScheme
  static ColorScheme get lightColorScheme => ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
      );

  static ColorScheme get darkColorScheme => ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.dark,
      );

  /// 根据主题模式获取对应的颜色
  static Color getAdaptiveColor({
    required Color lightColor,
    required Color darkColor,
    required bool isDark,
  }) {
    return isDark ? darkColor : lightColor;
  }

  /// 获取对比色（用于文本等）
  static Color getContrastColor(Color backgroundColor) {
    // 计算亮度
    final luminance = backgroundColor.computeLuminance();
    // 如果背景较暗，返回白色；否则返回黑色
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }
}
