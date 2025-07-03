import 'package:cc/core/proto/generated/user.pb.dart' as proto;
import 'package:cc/core/database/models/user.dart';

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
    if (user.name.isNotEmpty) {
      return user.name;
    }

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
}
