import 'dart:convert';
import 'package:flutter/material.dart';

/// 用户显示工具类
/// 提供用户头像颜色生成和首字母获取功能
class UserDisplayUtils {
  /// 基于用户名生成固定颜色
  /// 使用用户名的hash值来确保相同名字总是对应相同颜色
  static Color generateUserColor(String? name) {
    if (name == null || name.trim().isEmpty) {
      return Colors.grey[600]!; // 默认颜色
    }

    // 预定义的颜色列表，选择对比度好、视觉友好的颜色
    final List<Color> colors = [
      const Color(0xFF1976D2), // 蓝色
      const Color(0xFF388E3C), // 绿色
      const Color(0xFF7B1FA2), // 紫色
      const Color(0xFFE64A19), // 橙红色
      const Color(0xFF5D4037), // 棕色
      const Color(0xFF00796B), // 青色
      const Color(0xFFAF52DE), // 紫罗兰色
      const Color(0xFFFF6F00), // 橙色
      const Color(0xFF455A64), // 蓝灰色
      const Color(0xFF8BC34A), // 浅绿色
      const Color(0xFF9C27B0), // 品红色
      const Color(0xFFFF5722), // 深橙色
      const Color(0xFF607D8B), // 青灰色
      const Color(0xFFFF9800), // 琥珀色
      const Color(0xFF795548), // 深棕色
      const Color(0xFF009688), // 蓝绿色
    ];

    // 使用用户名的hash值计算颜色索引
    final int hash = name.trim().hashCode;
    final int colorIndex = hash.abs() % colors.length;

    return colors[colorIndex];
  }

  /// 获取用户名的首字母
  static String getInitials(String? name) {
    if (name == null || name.trim().isEmpty) {
      return 'U';
    }

    final trimmedName = name.trim();
    if (trimmedName.length == 1) {
      return trimmedName.toUpperCase();
    }

    // 判断是否为中文名称
    final bool isChinese = RegExp(r'[\u4e00-\u9fa5]').hasMatch(trimmedName);

    if (isChinese) {
      switch (trimmedName.length) {
        case 1: // 一个字的中文名，显示全名
          return trimmedName;
        case 2: // 两个字的中文名，显示全名
          return trimmedName;
        case 3: // 三个字的中文名，显示后两个字
          return trimmedName.substring(1);
        default: // 其他情况（超过3个字），只显示第一个字
          return trimmedName[0];
      }
    } else {
      // 非中文名称，显示第一个字母并大写
      return trimmedName[0].toUpperCase();
    }
  }

  /// 从会话参与者中获取对方用户信息（私聊场景）
  ///
  /// [conversation] - 会话对象
  /// [currentUserId] - 当前用户ID
  /// 返回：对方用户的参与者信息，如果找不到则返回null
  static Map<String, dynamic>? getOtherUserFromConversation(
    dynamic conversation,
    String currentUserId,
  ) {
    if (conversation == null || conversation.participants == null) {
      return null;
    }

    try {
      List<dynamic> participants;
      
      // 处理不同的数据格式
      if (conversation.participants is String) {
        // 数据库中的JSON字符串格式
        final participantsJson = json.decode(conversation.participants as String);
        if (participantsJson is List) {
          participants = participantsJson;
        } else {
          return null;
        }
      } else if (conversation.participants is List) {
        // 直接的列表格式
        participants = conversation.participants as List<dynamic>;
      } else {
        return null;
      }
      
      if (participants.isEmpty) return null;

      for (final participant in participants) {
        if (participant is Map<String, dynamic>) {
          final userId = participant['userId'];
          if (userId != null && userId != currentUserId) {
            return participant;
          }
        }
      }
    } catch (e) {
      return null;
    }

    return null;
  }
}
