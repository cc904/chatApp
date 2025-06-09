import 'package:cc/core/database/models/user.dart';
import 'package:cc/core/database/models/current_user.dart';
import 'package:cc/core/proto/generated/user.pb.dart' as proto;
import 'package:fixnum/fixnum.dart';

/// 用户数据适配器
///
/// 负责处理Proto对象和数据库模型之间的转换
/// 遵循适配器模式，实现关注点分离
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
    return User()
      ..userId = protoUser.userId
      ..name = protoUser.name
      ..avatar = protoUser.hasAvatar() ? protoUser.avatar : null
      ..phone = protoUser.hasPhone() ? protoUser.phone : null
      ..email = protoUser.hasEmail() ? protoUser.email : null
      ..status = protoUser.hasStatus() ? protoUser.status : null
      ..lastActiveTime = protoUser.hasLastActiveTime()
          ? DateTime.fromMillisecondsSinceEpoch(
              protoUser.lastActiveTime.toInt())
          : null;
  }

  /// 将User对象转换为UserProto
  ///
  /// [user] - 数据库用户对象
  /// 返回：转换后的Proto对象
  static proto.UserProto toUserProto(User user) {
    return proto.UserProto(
      userId: user.userId,
      name: user.name,
      avatar: user.avatar,
      phone: user.phone,
      email: user.email,
      status: user.status,
      lastActiveTime: user.lastActiveTime != null
          ? Int64(user.lastActiveTime!.millisecondsSinceEpoch)
          : null,
    );
  }

  /// 将CurrentUser对象转换为CurrentUserProto
  ///
  /// [currentUser] - 数据库当前用户对象
  /// 返回：转换后的Proto对象
  static proto.CurrentUserProto toCurrentUserProto(CurrentUser currentUser) {
    return currentUser.toProto();
  }

  /// 提取认证令牌
  ///
  /// [protoUser] - Proto用户对象
  /// 返回：认证令牌
  static String extractToken(proto.CurrentUserProto protoUser) {
    return protoUser.token;
  }

  /// 从CurrentUser提取认证令牌
  ///
  /// [currentUser] - 当前用户对象
  /// 返回：认证令牌
  static String extractTokenFromCurrentUser(CurrentUser currentUser) {
    return currentUser.token;
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
