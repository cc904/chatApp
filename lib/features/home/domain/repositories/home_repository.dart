
/// 定义与主页面相关的数据操作方法
abstract class HomeRepository {
  /// 初始化用户会话
  ///
  /// 初始化数据库和通信服务
  ///
  /// 参数:
  /// - currentUser: 用户信息对象
  ///
  /// 返回:
  /// - 操作成功返回true，失败返回false
  Future<bool> initUserSession();

  /// 初始化数据库
  ///
  /// 参数:
  /// - currentUser: 用户信息对象
  ///
  /// 返回:
  /// - 操作成功返回true，失败返回false
  Future<bool> initDatabase();

  /// 初始化实时通信
  ///
  /// 参数:
  /// - currentUser: 用户信息对象
  ///
  /// 返回:
  /// - 操作成功返回true，失败返回false
  Future<bool> initCommunication();

}
