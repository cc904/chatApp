/// VIP等级枚举
enum VipLevel {
  /// 游客用户
  guest(1),
  /// 普通用户
  normal(2),
  /// 客服人员
  customerService(3),
  /// VIP会员
  vip(4);

  const VipLevel(this.roleId);
  
  /// 对应的角色ID
  final int roleId;
  
  /// 从角色ID获取VIP等级
  static VipLevel fromRoleId(int? roleId) {
    if (roleId == null) return VipLevel.normal;
    
    for (final level in VipLevel.values) {
      if (level.roleId == roleId) {
        return level;
      }
    }
    return VipLevel.normal;
  }
  
  /// 是否为VIP用户（包括客服）
  bool get isVip => this != VipLevel.normal && this != VipLevel.guest;
  
  /// 是否为客服用户
  bool get isCustomerService => this == VipLevel.customerService;
  
  /// 是否为游客用户
  bool get isGuest => this == VipLevel.guest;
  
  /// VIP等级名称
  String get displayName {
    switch (this) {
      case VipLevel.guest:
        return '游客用户';
      case VipLevel.normal:
        return '普通用户';
      case VipLevel.customerService:
        return '客服人员';
      case VipLevel.vip:
        return 'VIP会员';
    }
  }
}