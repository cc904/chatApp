import 'package:isar/isar.dart';
import 'package:fixnum/fixnum.dart';
import 'package:cc/core/proto/generated/user.pb.dart';

part 'current_user.g.dart';

/// CurrentUserProto的Isar适配器
///
/// 这是一个适配器类，将CurrentUserProto对象适配为Isar数据库可用的格式
/// 不直接存储用户数据，而是作为CurrentUserProto和Isar之间的桥梁
@collection
class CurrentUser {
  // Isar ID
  Id id = Isar.autoIncrement;

  // 用户ID (来自服务器)
  late String userId;

  // 认证令牌
  late String token;

  // 用户名称/昵称
  late String name;

  // 头像URL
  String? avatar;

  // 手机号
  String? phone;

  // 电子邮箱
  String? email;

  // 令牌过期时间
  DateTime? tokenExpireTime;

  // 最后登录时间
  DateTime? lastLoginTime;

  // 用户状态: online, offline, away
  String? status;

  // 为UI显示生成头像文本(取名字首字母)
  String get avatarText {
    if (name.isEmpty) return '?';
    return name.substring(0, 1).toUpperCase();
  }

  /// 从CurrentUserProto创建CurrentUser
  static CurrentUser fromProto(CurrentUserProto proto) {
    return CurrentUser()
      ..userId = proto.userId
      ..token = proto.token
      ..name = proto.name
      ..avatar = proto.avatar
      ..phone = proto.phone
      ..email = proto.email
      ..tokenExpireTime = proto.hasTokenExpireTime()
          ? DateTime.fromMillisecondsSinceEpoch(proto.tokenExpireTime.toInt())
          : null
      ..lastLoginTime = proto.hasLastLoginTime()
          ? DateTime.fromMillisecondsSinceEpoch(proto.lastLoginTime.toInt())
          : null
      ..status = proto.status;
  }

  /// 转换为CurrentUserProto
  CurrentUserProto toProto() {
    return CurrentUserProto(
      userId: userId,
      token: token,
      name: name,
      avatar: avatar,
      phone: phone,
      email: email,
      tokenExpireTime: tokenExpireTime != null
          ? Int64(tokenExpireTime!.millisecondsSinceEpoch)
          : null,
      lastLoginTime: lastLoginTime != null
          ? Int64(lastLoginTime!.millisecondsSinceEpoch)
          : null,
      status: status,
    );
  }
}
