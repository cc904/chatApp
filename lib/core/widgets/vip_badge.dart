import 'package:flutter/material.dart';
import 'package:cc/core/enums/vip_level.dart';

/// VIP标志类型
enum VipBadgeType {
  /// 小皇冠图标
  crown,
  /// VIP文字标签
  text,
  /// 客服耳机图标
  customerServiceHeadset,
  /// 客服认证图标
  customerServiceVerified,
  /// 客服盾牌图标
  customerServiceShield,
  /// 游客标签
  guest,
}

/// VIP标志位置
enum VipBadgePosition {
  /// 右上角
  topRight,
  /// 左上角
  topLeft,
  /// 右下角
  bottomRight,
  /// 左下角
  bottomLeft,
}

/// VIP标志组件
/// 
/// 根据用户VIP等级显示不同的标志样式
class VipBadge extends StatelessWidget {
  /// VIP等级
  final VipLevel vipLevel;
  
  /// 标志类型
  final VipBadgeType badgeType;
  
  /// 标志大小
  final double size;
  
  /// 是否显示背景
  final bool showBackground;

  const VipBadge({
    super.key,
    required this.vipLevel,
    this.badgeType = VipBadgeType.crown,
    this.size = 16,
    this.showBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    // 显示条件：VIP用户或游客用户
    if (!vipLevel.isVip && !vipLevel.isGuest) {
      return const SizedBox.shrink();
    }

    switch (badgeType) {
      case VipBadgeType.crown:
        return _buildCrownBadge();
      case VipBadgeType.text:
        return _buildTextBadge();
      case VipBadgeType.customerServiceHeadset:
        return _buildCustomerServiceHeadsetBadge();
      case VipBadgeType.customerServiceVerified:
        return _buildCustomerServiceVerifiedBadge();
      case VipBadgeType.customerServiceShield:
        return _buildCustomerServiceShieldBadge();
      case VipBadgeType.guest:
        return _buildGuestBadge();
    }
  }

  /// 构建皇冠标志
  Widget _buildCrownBadge() {
    return Container(
      width: size,
      height: size,
      decoration: showBackground ? BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFD700), // 金色
            Color(0xFFFF8C00), // 深橙色
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withAlpha(76),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ) : null,
      child: Center(
        child: Icon(
          Icons.star,
          size: size * 0.7,
          color: showBackground ? Colors.white : const Color(0xFFFFD700),
        ),
      ),
    );
  }

  /// 构建文字标志
  Widget _buildTextBadge() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size * 0.3,
        vertical: size * 0.1,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFD700), // 金色
            Color(0xFFFF8C00), // 深橙色
          ],
        ),
        borderRadius: BorderRadius.circular(size * 0.3),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withAlpha(76),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        'VIP',
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.5,
          fontWeight: FontWeight.bold,
          height: 1.0,
        ),
      ),
    );
  }

  /// 构建客服耳机标志（方案一）
  Widget _buildCustomerServiceHeadsetBadge() {
    return Container(
      width: size,
      height: size,
      decoration: showBackground ? BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4CAF50), // 绿色
            Color(0xFF2E7D32), // 深绿色
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withAlpha(76),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ) : null,
      child: Center(
        child: Icon(
          Icons.support_agent,
          size: size * 0.7,
          color: showBackground ? Colors.white : const Color(0xFF4CAF50),
        ),
      ),
    );
  }

  /// 构建客服认证标志（方案二）
  Widget _buildCustomerServiceVerifiedBadge() {
    return Container(
      width: size,
      height: size,
      decoration: showBackground ? BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2196F3), // 蓝色
            Color(0xFF1565C0), // 深蓝色
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withAlpha(76),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ) : null,
      child: Center(
        child: Icon(
          Icons.verified,
          size: size * 0.7,
          color: showBackground ? Colors.white : const Color(0xFF2196F3),
        ),
      ),
    );
  }

  /// 构建客服盾牌标志（方案三）
  Widget _buildCustomerServiceShieldBadge() {
    return Container(
      width: size,
      height: size,
      decoration: showBackground ? BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF00BCD4), // 蓝绿色
            Color(0xFF0097A7), // 深蓝绿色
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.cyan.withAlpha(76),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ) : null,
      child: Center(
        child: Icon(
          Icons.security,
          size: size * 0.7,
          color: showBackground ? Colors.white : const Color(0xFF00BCD4),
        ),
      ),
    );
  }

  /// 构建游客标志
  Widget _buildGuestBadge() {
    return Container(
      width: size,
      height: size,
      decoration: showBackground ? BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF9E9E9E), // 灰色
            Color(0xFF616161), // 深灰色
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(76),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ) : null,
      child: Center(
        child: Icon(
          Icons.person_outline,
          size: size * 0.7,
          color: showBackground ? Colors.white : const Color(0xFF9E9E9E),
        ),
      ),
    );
  }
}

/// VIP皇冠图标组件
/// 
/// 专门用于显示皇冠图标的组件，支持自定义样式
class VipCrown extends StatelessWidget {
  /// 皇冠大小
  final double size;
  
  /// 是否显示阴影
  final bool showShadow;
  
  /// 皇冠颜色
  final Color? color;

  const VipCrown({
    super.key,
    this.size = 16,
    this.showShadow = true,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: showShadow ? BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withAlpha(51),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ) : null,
      child: CustomPaint(
        size: Size(size, size),
        painter: _CrownPainter(
          color: color ?? const Color(0xFFFFD700),
        ),
      ),
    );
  }
}

/// 皇冠图标绘制器
class _CrownPainter extends CustomPainter {
  final Color color;
  
  _CrownPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    final shadowPaint = Paint()
      ..color = Colors.black.withAlpha(25)
      ..style = PaintingStyle.fill;

    final path = Path();
    final shadowPath = Path();
    
    final width = size.width;
    final height = size.height;
    
    // 皇冠主体路径
    path.moveTo(width * 0.1, height * 0.8);  // 左下角
    path.lineTo(width * 0.2, height * 0.3);  // 左边尖峰
    path.lineTo(width * 0.35, height * 0.5); // 左边小峰
    path.lineTo(width * 0.5, height * 0.15); // 中间最高峰
    path.lineTo(width * 0.65, height * 0.5); // 右边小峰
    path.lineTo(width * 0.8, height * 0.3);  // 右边尖峰
    path.lineTo(width * 0.9, height * 0.8);  // 右下角
    path.lineTo(width * 0.1, height * 0.8);  // 回到起点
    
    // 阴影路径（稍微偏移）
    shadowPath.moveTo(width * 0.1 + 1, height * 0.8 + 1);
    shadowPath.lineTo(width * 0.2 + 1, height * 0.3 + 1);
    shadowPath.lineTo(width * 0.35 + 1, height * 0.5 + 1);
    shadowPath.lineTo(width * 0.5 + 1, height * 0.15 + 1);
    shadowPath.lineTo(width * 0.65 + 1, height * 0.5 + 1);
    shadowPath.lineTo(width * 0.8 + 1, height * 0.3 + 1);
    shadowPath.lineTo(width * 0.9 + 1, height * 0.8 + 1);
    shadowPath.lineTo(width * 0.1 + 1, height * 0.8 + 1);
    
    // 绘制阴影
    canvas.drawPath(shadowPath, shadowPaint);
    
    // 绘制皇冠主体
    canvas.drawPath(path, paint);
    
    // 添加渐变效果
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        color.withAlpha(255),
        color.withAlpha(178),
      ],
    );
    
    final rect = Rect.fromLTWH(0, 0, width, height);
    final gradientPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.fill;
    
    canvas.drawPath(path, gradientPaint);
    
    // 添加高光点
    final highlightPaint = Paint()
      ..color = Colors.white.withAlpha(153)
      ..style = PaintingStyle.fill;
    
    // 中间峰的高光
    canvas.drawCircle(
      Offset(width * 0.5, height * 0.25),
      width * 0.06,
      highlightPaint,
    );
    
    // 左右峰的小高光
    canvas.drawCircle(
      Offset(width * 0.2, height * 0.4),
      width * 0.04,
      highlightPaint,
    );
    
    canvas.drawCircle(
      Offset(width * 0.8, height * 0.4),
      width * 0.04,
      highlightPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}