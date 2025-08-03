import 'package:cc/core/database/drift_database.dart';
import 'package:cc/core/proto/generated/user.pb.dart' as proto;
import 'package:fixnum/fixnum.dart';

/// 用户数据适配器 (Drift版本)
///
/// 负责处理Proto对象和Drift数据库模型之间的转换
/// 遵循适配器模式，实现关注点分离
/// 新版本不再处理token字段，所有Token操作通过EnhancedTokenManager
class UserAdapter {
  /// 从CurrentUserProto创建CurrentUser对象
  ///
  /// [protoUser] - Proto用户对象
  /// 返回：转换后的CurrentUser对象
  static CurrentUser fromCurrentUserProto(proto.CurrentUserProto protoUser) {
    return CurrentUser(
      userId: protoUser.userId,
      name: protoUser.hasName() ? protoUser.name : '',
      avatar: protoUser.hasAvatar() ? protoUser.avatar : null,
      phone: protoUser.hasPhone() ? protoUser.phone : null,
      email: protoUser.hasEmail() ? protoUser.email : null,
      lastLoginTime: protoUser.hasLastLoginTime() 
          ? DateTime.fromMillisecondsSinceEpoch(protoUser.lastLoginTime.toInt())
          : null,
      status: protoUser.hasStatus() ? protoUser.status : null,
      hasSetPassword: protoUser.hasHasSetPassword() ? protoUser.hasSetPassword : false,
      roleId: 0, // roleId字段在proto中不存在，使用默认值 // roleId字段在proto中不存在，使用默认值
    );
  }

  /// 从UserProto创建User对象
  ///
  /// [protoUser] - Proto用户对象
  /// 返回：转换后的User对象
  static User fromUserProto(proto.UserProto protoUser) {
    return User(
      userId: protoUser.userId,
      nickName: protoUser.hasNickName() ? protoUser.nickName : '',
      avatar: protoUser.hasAvatar() ? protoUser.avatar : null,
      phone: protoUser.hasPhone() ? protoUser.phone : null,
      email: protoUser.hasEmail() ? protoUser.email : null,
      online: false, // 默认值
      isFriend: false, // 默认值
      roleId: 0, // roleId字段在proto中不存在，使用默认值 // roleId字段在proto中不存在，使用默认值 // 添加roleId支持
    );
  }

  /// 将User对象转换为UserProto
  ///
  /// [user] - 数据库用户对象
  /// 返回：转换后的Proto对象
  static proto.UserProto toUserProto(User user) {
    return proto.UserProto(
      userId: user.userId,
      nickName: user.nickName,
      avatar: user.avatar,
      phone: user.phone,
      email: user.email,
      status: user.status,
      // roleId: user.roleId, // Proto中没有此字段
    );
  }

  /// 将CurrentUser对象转换为CurrentUserProto
  ///
  /// [currentUser] - 数据库当前用户对象
  /// 返回：转换后的Proto对象
  static proto.CurrentUserProto toCurrentUserProto(CurrentUser currentUser) {
    return proto.CurrentUserProto(
      userId: currentUser.userId,
      name: currentUser.name,
      avatar: currentUser.avatar,
      phone: currentUser.phone,
      email: currentUser.email,
      lastLoginTime: currentUser.lastLoginTime != null 
          ? Int64(currentUser.lastLoginTime!.millisecondsSinceEpoch)
          : null,
      status: currentUser.status,
      hasSetPassword: currentUser.hasSetPassword,
      // roleId: currentUser.roleId, // Proto中没有此字段
    );
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
