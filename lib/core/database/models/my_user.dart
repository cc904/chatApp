import 'package:isar/isar.dart';

part 'my_user.g.dart';

/// 存储当前登录用户自身的信息模型
@collection
class MyUser {
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
}
