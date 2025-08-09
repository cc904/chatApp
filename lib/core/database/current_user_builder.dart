import 'package:cc/core/database/drift_database.dart';
import 'package:cc/core/services/log_service.dart';

/// CurrentUser对象的构建器扩展
/// 
/// 提供从各种数据源创建CurrentUser对象的静态方法
/// 确保所有必要字段都被正确处理，避免字段遗漏
extension CurrentUserBuilder on CurrentUser {
  
  /// 从JSON数据构建CurrentUser对象
  /// 
  /// 这个方法确保所有字段都被正确处理，特别是roleId字段
  /// 如果关键字段缺失，会抛出异常或记录错误
  /// 
  /// 参数:
  /// - userData: 来自服务器的用户数据Map
  /// 
  /// 返回:
  /// - CurrentUser对象
  /// 
  /// 抛出:
  /// - Exception: 当必需字段缺失时
  static CurrentUser fromJson(Map<String, dynamic> userData) {
    final logger = LogService.instance;
    
    // 🔍 详细记录原始数据，用于调试
    logger.i('🔧 CurrentUserBuilder.fromJson - 开始构建', extra: {
      'allFields': userData.keys.toList(),
      'rawUserData': userData,
      'fieldsCount': userData.length,
    });
    
    // 🚨 必需字段检查
    final userId = userData['userId']?.toString();
    if (userId == null || userId.isEmpty) {
      throw Exception('JSON数据缺少必需字段: userId');
    }
    
    // 🔥 关键字段：roleId
    // 尝试多种可能的字段名
    int? roleId = userData['roleId'] as int? ?? 
                  userData['role_id'] as int? ??
                  userData['role'] as int?;
    
    if (roleId == null) {
      logger.e('🚨🚨🚨 CRITICAL: JSON数据中没有找到roleId字段！', extra: {
        'availableFields': userData.keys.toList(),
        'userId': userId,
        'possibleFieldNames': ['roleId', 'role_id', 'role'],
        'userData': userData,
      });
      throw Exception('JSON数据缺少关键字段: roleId (检查服务器响应格式)');
    }
    
    if (roleId == 0) {
      logger.w('🚨 WARNING: 服务器返回的roleId为0，这可能不正确', extra: {
        'userId': userId,
        'roleId': roleId,
        'userData': userData,
      });
    }
    
    // 构建名称，尝试多种字段
    final name = userData['nickname']?.toString() ??
                 userData['name']?.toString() ??
                 userData['username']?.toString() ??
                 '用户${userId.substring(0, userId.length > 6 ? 6 : userId.length)}';
    
    // 处理时间字段
    DateTime? lastLoginTime;
    if (userData['lastLoginTime'] != null) {
      try {
        final timestamp = userData['lastLoginTime'];
        if (timestamp is int) {
          lastLoginTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        } else if (timestamp is String) {
          lastLoginTime = DateTime.parse(timestamp);
        }
      } catch (e) {
        logger.w('解析lastLoginTime失败', extra: {
          'rawValue': userData['lastLoginTime'],
          'error': e.toString(),
        });
      }
    }
    
    final currentUser = CurrentUser(
      userId: userId,
      name: name,
      phone: userData['phone']?.toString().isEmpty == true ? null : userData['phone']?.toString(),
      email: userData['email']?.toString().isEmpty == true ? null : userData['email']?.toString(),
      avatar: userData['avatar']?.toString().isEmpty == true ? null : userData['avatar']?.toString(),
      status: userData['status'] == null
          ? null
          : int.tryParse(userData['status'].toString()),
      lastLoginTime: lastLoginTime,
      hasSetPassword: userData['hasSetPassword'] as bool? ?? false,
      roleId: roleId,
    );
    
    // 🎯 最终验证
    logger.i('✅ CurrentUser从JSON构建成功', extra: {
      'userId': currentUser.userId,
      'name': currentUser.name,
      'roleId': currentUser.roleId,
      'hasSetPassword': currentUser.hasSetPassword,
      'phone': currentUser.phone != null ? 'HAS_PHONE' : 'NO_PHONE',
      'avatar': currentUser.avatar != null ? 'HAS_AVATAR' : 'NO_AVATAR',
      'dataSource': 'JSON',
    });
    
    return currentUser;
  }
  
  /// 从Proto对象构建CurrentUser对象
  /// 
  /// 将服务器返回的Proto对象转换为CurrentUser
  /// 确保roleId字段被正确处理
  /// 
  /// 参数:
  /// - proto: CurrentUserProto对象
  /// 
  /// 返回:
  /// - CurrentUser对象
  /// 
  /// 抛出:
  /// - Exception: 当必需字段缺失时
  static CurrentUser fromProto(dynamic proto) {
    final logger = LogService.instance;
    
    // 检查必需字段
    if (proto.userId == null || proto.userId.isEmpty) {
      throw Exception('Proto缺少必需字段: userId');
    }
    
    // 检查roleId
    final roleId = proto.hasRoleId() ? proto.roleId : 0;
    if (!proto.hasRoleId() || roleId == 0) {
      logger.e('🚨🚨🚨 PROTO_CONVERSION_ERROR: Proto中roleId不正确！', extra: {
        'userId': proto.userId,
        'name': proto.name,
        'protoHasRoleId': proto.hasRoleId(),
        'protoRoleId': proto.hasRoleId() ? proto.roleId : 'NONE',
        'finalRoleId': roleId,
      });
      
      if (!proto.hasRoleId()) {
        throw Exception('Proto缺少roleId字段 (服务器数据问题)');
      }
    }
    
    final currentUser = CurrentUser(
      userId: proto.userId,
      name: proto.name,
      avatar: proto.avatar.isNotEmpty ? proto.avatar : null,
      phone: proto.phone.isNotEmpty ? proto.phone : null,
      email: proto.email.isNotEmpty ? proto.email : null,
      lastLoginTime: proto.hasLastLoginTime()
          ? DateTime.fromMillisecondsSinceEpoch(proto.lastLoginTime.toInt())
          : null,
      status: proto.hasStatus() ? proto.status.value : null,
      hasSetPassword: proto.hasSetPassword,
      roleId: roleId,
    );
    
    logger.i('✅ CurrentUser从Proto构建成功', extra: {
      'userId': currentUser.userId,
      'name': currentUser.name,
      'roleId': currentUser.roleId,
      'dataSource': 'Proto',
    });
    
    return currentUser;
  }
}