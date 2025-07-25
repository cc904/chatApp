import 'package:cc/core/database/drift_database.dart';

/// AuthRepository接口
/// 定义了与认证相关的数据操作方法，支持多设备登录
abstract class AuthRepository {
  /// 初始化AuthRepository
  Future<void> init();

  /// 使用令牌登录
  ///
  /// 使用保存的令牌进行登录
  ///
  /// 返回:
  /// - 成功返回包含用户信息的Map，失败抛出异常
  Future<Map<String, dynamic>> loginWithToken();

  /// 使用密码登录
  ///
  /// 参数:
  /// - username: 用户名/手机号
  /// - password: 密码
  ///
  /// 返回:
  /// - 登录成功返回包含用户信息和tokens的Map
  Future<Map<String, dynamic>> loginWithPassword(
      String username, String password);

  /// 使用验证码登录
  ///
  /// 参数:
  /// - username: 用户名/手机号
  /// - code: 验证码
  ///
  /// 返回:
  /// - 登录成功返回包含用户信息和tokens的Map
  Future<Map<String, dynamic>> loginWithCode(String username, String code);

  /// 注册
  ///
  /// 创建新账户
  ///
  /// 参数:
  /// - username: 用户名
  /// - password: 密码
  /// - verificationCode: 验证码
  /// - name: 用户昵称
  ///
  /// 返回:
  /// - 注册成功返回包含用户信息和tokens的Map
  Future<Map<String, dynamic>> register(
      String username, String password, String verificationCode, String name);

  /// 登出
  ///
  /// 注销当前用户会话
  ///
  /// 返回:
  /// - 操作成功返回true，失败返回false
  Future<bool> logout();

  /// 获取当前用户
  ///
  /// 获取当前登录用户信息
  ///
  /// 返回:
  /// - 当前用户信息，未登录返回null
  Future<CurrentUser?> getCurrentUser();

  /// 检查是否已登录
  ///
  /// 返回:
  /// - 已登录返回true，未登录返回false
  Future<bool> isLoggedIn();

  /// 重置密码
  ///
  /// 通过验证码重置用户密码
  ///
  /// 参数:
  /// - phoneOrEmail: 手机号或邮箱
  /// - code: 验证码
  /// - newPassword: 新密码
  ///
  /// 返回:
  /// - 操作成功返回true，失败返回false
  Future<bool> resetPassword(
      String phoneOrEmail, String code, String newPassword);

  /// 发送验证码
  ///
  /// 向指定手机号或邮箱发送验证码
  ///
  /// 参数:
  /// - phoneOrEmail: 手机号或邮箱
  /// - type: 验证码类型（注册/重置密码）
  ///
  /// 返回:
  /// - 发送成功返回true，失败返回false
  Future<bool> sendVerificationCode(String phoneOrEmail, String type);

  /// 验证验证码
  ///
  /// 验证用户输入的验证码是否正确
  ///
  /// 参数:
  /// - phoneOrEmail: 手机号或邮箱
  /// - code: 验证码
  ///
  /// 返回:
  /// - 验证成功返回true，失败返回false
  Future<bool> verifyCode(String phoneOrEmail, String code);

  /// 更新用户令牌
  ///
  /// 刷新当前用户的认证令牌
  ///
  /// 返回:
  /// - 新的令牌，失败返回null
  Future<String?> refreshToken();

  /// 删除账户
  ///
  /// 删除当前用户账户及相关数据
  ///
  /// 返回:
  /// - 操作成功返回true
  Future<bool> deleteAccount();
}
