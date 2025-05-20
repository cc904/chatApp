import 'package:cc/core/proto/generated/user.pb.dart';

/// 定义与主页面相关的数据操作方法
abstract class HomeRepository {
  /// 初始化用户会话
  ///
  /// 初始化数据库和通信服务
  ///
  /// 参数:
  /// - user: 用户信息对象
  ///
  /// 返回:
  /// - 操作成功返回true，失败返回false
  Future<bool> initUserSession(MyUserProto user);

  /// 初始化数据库
  ///
  /// 参数:
  /// - userId: 用户ID
  ///
  /// 返回:
  /// - 操作成功返回true，失败返回false
  Future<bool> initDatabase(String userId);

  /// 初始化实时通信
  ///
  /// 参数:
  /// - userId: 用户ID
  /// - token: 认证令牌
  ///
  /// 返回:
  /// - 操作成功返回true，失败返回false
  Future<bool> initCommunication(String userId, String token);

  /// 从安全存储获取用户信息
  ///
  /// 返回:
  /// - 用户信息对象，失败返回null
  Future<MyUserProto?> getUserFromSecureStorage();
}
