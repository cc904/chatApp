import 'package:isar/isar.dart';
import 'package:fixnum/fixnum.dart';
import 'package:cc/core/proto/generated/user.pb.dart';
import 'package:cc/core/services/enhanced_token_manager.dart';

part 'current_user.g.dart';

/// CurrentUserProto的Isar适配器
///
/// 适配新的多Token认证系统，不再存储Token字段
/// 所有Token操作通过 EnhancedTokenManager 进行
@collection
class CurrentUser {
  // Isar ID
  Id id = Isar.autoIncrement;

  // 用户ID (来自服务器)
  late String userId;

  // 用户名称/昵称
  late String name;

  // 头像URL
  String? avatar;

  // 手机号
  String? phone;

  // 电子邮箱
  String? email;

  // 最后登录时间
  DateTime? lastLoginTime;

  // 用户状态: online, offline, away
  String? status;

  // 为UI显示生成头像文本(取名字首字母)
  String get avatarText {
    if (name.isEmpty) return '?';
    return name.substring(0, 1).toUpperCase();
  }

  /// 检查是否有有效的认证Token
  Future<bool> hasValidToken() async {
    try {
      final tokenManager = EnhancedTokenManager.instance;
      final accessToken = await tokenManager.getApiToken();
      return accessToken != null && accessToken.isNotEmpty;
    } catch (error) {
      return false;
    }
  }

  /// 获取当前有效的API Token
  Future<String?> getValidApiToken() async {
    try {
      final tokenManager = EnhancedTokenManager.instance;
      return await tokenManager.getApiToken();
    } catch (error) {
      return null;
    }
  }

  /// 获取当前有效的Socket Token
  Future<String?> getValidSocketToken() async {
    try {
      final tokenManager = EnhancedTokenManager.instance;
      return await tokenManager.getSocketToken();
    } catch (error) {
      return null;
    }
  }

  /// 检查用户是否已完整登录
  Future<bool> isFullyAuthenticated() async {
    return userId.isNotEmpty && await hasValidToken();
  }

  /// 从CurrentUserProto创建CurrentUser（移除token字段）
  static CurrentUser fromProto(CurrentUserProto proto) {
    return CurrentUser()
      ..userId = proto.userId
      ..name = proto.name
      ..avatar = proto.avatar
      ..phone = proto.phone
      ..email = proto.email
      ..lastLoginTime = proto.hasLastLoginTime()
          ? DateTime.fromMillisecondsSinceEpoch(proto.lastLoginTime.toInt())
          : null
      ..status = proto.status;
  }

  /// 转换为CurrentUserProto（不包含token字段）
  CurrentUserProto toProto() {
    return CurrentUserProto(
      userId: userId,
      name: name,
      avatar: avatar,
      phone: phone,
      email: email,
      lastLoginTime: lastLoginTime != null
          ? Int64(lastLoginTime!.millisecondsSinceEpoch)
          : null,
      status: status,
    );
  }
}
