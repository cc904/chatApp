import 'package:cc/core/database/models/user.dart';
import 'package:cc/core/database/models/current_user.dart';
import 'package:cc/core/proto/generated/user.pb.dart' as proto;

/// 用户数据适配器
///
/// 负责处理Proto对象和数据库模型之间的转换
/// 遵循适配器模式，实现关注点分离
/// 新版本不再处理token字段，所有Token操作通过EnhancedTokenManager
class UserAdapter {
  /// 从CurrentUserProto创建CurrentUser对象
  ///
  /// [protoUser] - Proto用户对象
  /// 返回：转换后的CurrentUser对象
  static CurrentUser fromCurrentUserProto(proto.CurrentUserProto protoUser) {
    return CurrentUser.fromProto(protoUser);
  }

  /// 从UserProto创建User对象
  ///
  /// [protoUser] - Proto用户对象
  /// 返回：转换后的User对象
  static User fromUserProto(proto.UserProto protoUser) {
    // 💡 直接使用User.fromProto方法，它已经包含了显示优先级逻辑
    return User.fromProto(protoUser);
  }

  /// 将User对象转换为UserProto
  ///
  /// [user] - 数据库用户对象
  /// 返回：转换后的Proto对象
  static proto.UserProto toUserProto(User user) {
    // 💡 直接使用User.toProto方法，它已经处理了正确的字段映射
    return user.toProto();
  }

  /// 将CurrentUser对象转换为CurrentUserProto
  ///
  /// [currentUser] - 数据库当前用户对象
  /// 返回：转换后的Proto对象
  static proto.CurrentUserProto toCurrentUserProto(CurrentUser currentUser) {
    return currentUser.toProto();
  }

  /// 批量转换：从UserProto列表转换为User列表
  static List<User> fromUserProtoList(List<proto.UserProto> protoList) {
    return protoList.map((proto) => fromUserProto(proto)).toList();
  }

  /// 批量转换：从User列表转换为UserProto列表
  static List<proto.UserProto> toUserProtoList(List<User> users) {
    return users.map((user) => toUserProto(user)).toList();
  }
}
