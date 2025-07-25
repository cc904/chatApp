import 'package:cc/core/proto/generated/user.pb.dart' as proto;
import 'package:cc/core/database/drift_database.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

/// 显示名称工具类
/// 统一处理联系人姓名显示的优先级逻辑
class DisplayNameUtils {
  /// 获取用户的显示名称
  ///
  /// 显示优先级：
  /// 1. 自定义昵称 (customNickname) - 当前用户为此联系人设置的昵称
  /// 2. 用户真实昵称 (nickName) - 用户本人设置的昵称
  /// 3. 用户ID - 如果前两者都没有
  /// 4. "未知联系人" - 兜底显示
  ///
  /// [userProto] - 用户的Protocol Buffer对象
  /// 返回：应该显示的名称
  static String getDisplayName(proto.UserProto userProto) {
    // 1. 优先使用自定义昵称
    if (userProto.hasCustomNickname() && userProto.customNickname.isNotEmpty) {
      return userProto.customNickname;
    }

    // 2. 其次使用用户真实昵称
    if (userProto.hasNickName() && userProto.nickName.isNotEmpty) {
      return userProto.nickName;
    }

    // 3. 使用用户ID作为备选
    if (userProto.hasUserId() && userProto.userId.isNotEmpty) {
      return userProto.userId;
    }

    // 4. 兜底显示
    return '未知联系人';
  }

  /// 获取用户的显示名称（从数据库User对象）
  ///
  /// 注意：数据库User对象只存储最终的显示名称，不区分自定义昵称和真实昵称
  /// 这个方法主要用于向后兼容
  ///
  /// [user] - 数据库User对象
  /// 返回：应该显示的名称
  static String getDisplayNameFromUser(User user) {
    // 优先使用自定义昵称
    if (user.customNickname != null && user.customNickname!.isNotEmpty) {
      return user.customNickname!;
    }
    
    // 其次使用昵称
    if (user.nickName.isNotEmpty) {
      return user.nickName;
    }

    // 最后使用用户ID
    if (user.userId.isNotEmpty) {
      return user.userId;
    }

    return '未知联系人';
  }

  /// 获取头像显示文本
  ///
  /// 根据显示名称生成头像中应该显示的文字
  ///
  /// [displayName] - 显示名称
  /// 返回：头像文本
  static String getAvatarText(String displayName) {
    if (displayName.isEmpty || displayName == '未知联系人') {
      return '?';
    }

    // 判断是否为中文名称(简单判断：如果不包含英文字母和数字，则视为中文)
    bool isChinese = !RegExp(r'[a-zA-Z0-9]').hasMatch(displayName);

    if (isChinese) {
      switch (displayName.length) {
        case 1: // 一个字的中文名，显示全名
          return displayName;
        case 2: // 两个字的中文名，显示全名
          return displayName;
        case 3: // 三个字的中文名，显示后两个字
          return displayName.substring(1);
        default: // 其他情况（超过3个字），只显示第一个字
          return displayName[0];
      }
    } else {
      // 非中文名称，显示第一个字母并大写
      return displayName[0].toUpperCase();
    }
  }

  /// 检查是否有自定义昵称
  ///
  /// [userProto] - 用户的Protocol Buffer对象
  /// 返回：是否设置了自定义昵称
  static bool hasCustomNickname(proto.UserProto userProto) {
    return userProto.hasCustomNickname() && userProto.customNickname.isNotEmpty;
  }

  /// 获取真实昵称（用户本人设置的昵称）
  ///
  /// [userProto] - 用户的Protocol Buffer对象
  /// 返回：用户真实昵称，如果没有则返回null
  static String? getRealNickname(proto.UserProto userProto) {
    if (userProto.hasNickName() && userProto.nickName.isNotEmpty) {
      return userProto.nickName;
    }
    return null;
  }

  /// 获取自定义昵称
  ///
  /// [userProto] - 用户的Protocol Buffer对象
  /// 返回：自定义昵称，如果没有则返回null
  static String? getCustomNickname(proto.UserProto userProto) {
    if (userProto.hasCustomNickname() && userProto.customNickname.isNotEmpty) {
      return userProto.customNickname;
    }
    return null;
  }

  /// 生成显示名称
  static String generateDisplayName(String? name, String? username) {
    if (name != null && name.trim().isNotEmpty) {
      return name.trim();
    }

    if (username != null && username.trim().isNotEmpty) {
      return username.trim();
    }

    return '未知用户';
  }

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

    // 如果是中文名，取第一个字符
    if (_isChinese(trimmedName)) {
      return trimmedName.substring(0, 1);
    }

    // 如果是英文名，取首字母
    final parts = trimmedName.split(' ');
    if (parts.length >= 2) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    } else {
      return trimmedName[0].toUpperCase();
    }
  }

  /// 判断字符串是否包含中文字符
  static bool _isChinese(String text) {
    return RegExp(r'[\u4e00-\u9fa5]').hasMatch(text);
  }

  /// 获取会话的显示名称
  ///
  /// 根据会话类型返回合适的显示名称：
  /// - 私聊会话：返回对方用户的显示名称（优先级：自定义昵称 > 真实昵称 > 用户ID）
  /// - 群聊/频道：返回会话的name字段
  ///
  /// [conversation] - 会话对象
  /// [currentUserId] - 当前用户ID，用于在私聊中区分对方
  /// 返回：应该显示的会话名称
  static String getConversationDisplayName(dynamic conversation, String currentUserId) {
    // 群聊或频道直接返回会话名称
    if (conversation.type == 'GROUP' || conversation.type == 'CHANNEL') {
      return conversation.name ?? '未命名${conversation.type == 'GROUP' ? '群聊' : '频道'}';
    }
    
    // 私聊会话：需要获取对方用户的信息
    if (conversation.type == 'PRIVATE') {
      final otherUser = getOtherUserFromConversation(conversation, currentUserId);
      if (otherUser != null) {
        return getDisplayNameFromParticipant(otherUser);
      }
    }
    
    // 兜底返回会话名称或当前用户ID
    return conversation.name ?? currentUserId;
  }

  /// 从会话参与者中获取对方用户信息（私聊场景）
  ///
  /// [conversation] - 会话对象
  /// [currentUserId] - 当前用户ID
  /// 返回：对方用户的参与者信息，如果找不到则返回null
  static Map<String, dynamic>? getOtherUserFromConversation(dynamic conversation, String currentUserId) {
    try {
      final participantsJson = conversation.participants as String;
      final List<dynamic> participantsList = json.decode(participantsJson);
      final participantsMap = participantsList.cast<Map<String, dynamic>>();
      
      // 在私聊中找到不是当前用户的另一个用户
      for (final participant in participantsMap) {
        if (participant['user_id'] != currentUserId) {
          return participant;
        }
      }
    } catch (e) {
      // JSON解析失败或其他错误
    }
    
    return null;
  }

  /// 从参与者信息获取显示名称
  ///
  /// 注意：参与者信息中存储的name字段通常是用户的显示名称
  /// 但这里我们可以扩展支持更复杂的昵称逻辑
  ///
  /// [participant] - 参与者信息Map
  /// 返回：显示名称
  static String getDisplayNameFromParticipant(Map<String, dynamic> participant) {
    // 从参与者信息中获取name字段
    final name = participant['name'] as String?;
    if (name != null && name.isNotEmpty) {
      return name;
    }
    
    // 备选方案：使用user_id
    final userId = participant['user_id'] as String?;
    if (userId != null && userId.isNotEmpty) {
      return userId;
    }
    
    return '未知联系人';
  }
}
