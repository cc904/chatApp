import 'package:cc/core/database/drift_database.dart';
import 'package:cc/core/proto/generated/user.pb.dart' as proto;
import 'package:drift/drift.dart';
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
      lastLoginTime: protoUser.hasLastLoginTime() ? DateTime.fromMillisecondsSinceEpoch(protoUser.lastLoginTime.toInt()) : null,
      status: protoUser.hasStatus() ? protoUser.status : null,
      hasSetPassword: protoUser.hasHasSetPassword() ? protoUser.hasSetPassword : false,
      roleId: protoUser.hasRoleId() ? protoUser.roleId : 2, // 默认为普通用户
    );
  }

  /// 从UserProto创建User对象
  ///
  /// [protoUser] - Proto用户对象
  /// 返回：转换后的User对象
  static User fromUserProto(proto.UserProto protoUser) {
    return User(
      userId: protoUser.userId,
      name: protoUser.hasName() ? protoUser.name : '',
      avatar: protoUser.hasAvatar() ? protoUser.avatar : null,
      phone: protoUser.hasPhone() ? protoUser.phone : null,
      email: protoUser.hasEmail() ? protoUser.email : null,
      pinyin: protoUser.hasPinyin() ? protoUser.pinyin : null,
      lastActiveTime: protoUser.hasLastActiveTime() ? DateTime.fromMillisecondsSinceEpoch(protoUser.lastActiveTime.toInt()) : null,
      status: protoUser.hasStatus() ? protoUser.status : null,
      online: false, // 默认值
      isFriend: false, // 默认值，在调用处设置
      roleId: protoUser.hasRoleId() ? protoUser.roleId : 2, // 默认为普通用户
      nickname: protoUser.hasNickname() && protoUser.nickname.isNotEmpty ? protoUser.nickname : null,
      remark: protoUser.hasRemark() && protoUser.remark.isNotEmpty ? protoUser.remark : null,
    );
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
      roleId: user.roleId,
      nickname: user.nickname,
      remark: user.remark,
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
      lastLoginTime: currentUser.lastLoginTime != null ? Int64(currentUser.lastLoginTime!.millisecondsSinceEpoch) : null,
      status: currentUser.status,
      hasSetPassword: currentUser.hasSetPassword,
      roleId: currentUser.roleId,
    );
  }

  /// 从UserProto创建联系人User对象（专用于联系人同步）
  ///
  /// [protoUser] - Proto用户对象
  /// [existingNickname] - 现有的自定义昵称（用于保留用户设置的昵称）
  /// 返回：转换后的User对象，已设置为联系人
  static User fromUserProtoForContact(proto.UserProto protoUser, {String? existingNickname}) {
    return User(
      userId: protoUser.userId,
      name: protoUser.hasName() ? protoUser.name : '',
      avatar: protoUser.hasAvatar() ? protoUser.avatar : null,
      phone: protoUser.hasPhone() ? protoUser.phone : null,
      email: protoUser.hasEmail() ? protoUser.email : null,
      pinyin: protoUser.hasPinyin() ? protoUser.pinyin : null,
      lastActiveTime: protoUser.hasLastActiveTime() ? DateTime.fromMillisecondsSinceEpoch(protoUser.lastActiveTime.toInt()) : null,
      status: protoUser.hasStatus() ? protoUser.status : null,
      online: false, // 默认值
      isFriend: true, // 联系人标记为朋友
      roleId: protoUser.hasRoleId() ? protoUser.roleId : 2, // 默认为普通用户
      // 自定义昵称处理逻辑：
      // 1. 如果现有记录有自定义昵称，保留现有的
      // 2. 如果现有记录没有，但Proto中有，使用Proto中的
      // 3. 否则为null
      nickname: existingNickname?.isNotEmpty == true
          ? existingNickname
          : (protoUser.hasNickname() && protoUser.nickname.isNotEmpty ? protoUser.nickname : null),
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

  /// 从User对象创建UsersCompanion用于数据库更新操作
  ///
  /// [user] - User对象
  /// 返回：用于数据库操作的UsersCompanion对象
  static UsersCompanion toUsersCompanion(User user) {
    return UsersCompanion(
      userId: Value(user.userId),
      name: Value(user.name),
      avatar: Value(user.avatar),
      phone: Value(user.phone),
      email: Value(user.email),
      pinyin: Value(user.pinyin),
      lastActiveTime: Value(user.lastActiveTime),
      status: Value(user.status),
      roleId: Value(user.roleId),
      online: Value(user.online),
      isFriend: Value(user.isFriend),
      nickname: Value(user.nickname),
    );
  }
}
