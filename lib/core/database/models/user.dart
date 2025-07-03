import 'package:isar/isar.dart';
import 'package:fixnum/fixnum.dart';
import 'package:cc/core/proto/generated/user.pb.dart' as proto;
import 'package:lpinyin/lpinyin.dart';

part 'user.g.dart';

/// 联系人/用户信息模型
/// 此模型仅用于存储联系人信息,不存储当前登录用户的信息
@collection
class User {
  // Isar ID
  Id id = Isar.autoIncrement;

  // 用户ID (来自服务器)
  String userId = '';

  // 联系人名称
  @Index(type: IndexType.value)
  late String name;

  // 联系人头像URL
  String? avatar;

  // 联系人手机号
  String? phone;

  // 联系人电子邮箱
  String? email;

  // 拼音索引,用于搜索和排序
  @Index(type: IndexType.value)
  String? pinyin;

  // 最后活跃时间
  DateTime? lastActiveTime;

  // 联系人状态: online, offline, away
  String? status;

  // 为UI显示生成联系人头像文本(取名字首字母)
  String get avatarText {
    if (name.isEmpty) return '?';
    return name.substring(0, 1).toUpperCase();
  }

  /// 从Protocol Buffer对象创建数据库对象
  ///
  /// 直接从UserProto对象创建User实例
  /// 简化了在仓库中的数据转换逻辑
  ///
  /// 💡 名称显示优先级：
  /// 1. 自定义昵称 (customNickname) - 当前用户为此联系人设置的昵称
  /// 2. 用户真实昵称 (nickName) - 用户本人设置的昵称
  /// 3. 用户ID - 如果前两者都没有
  /// 4. "未知联系人" - 兜底显示
  ///
  /// [proto] - 原始的Protocol Buffer对象
  /// 返回：转换后的数据库对象
  static User fromProto(proto.UserProto proto) {
    // 🎯 确定显示名称：优先使用自定义昵称，其次使用真实昵称
    String displayName;
    if (proto.hasCustomNickname() && proto.customNickname.isNotEmpty) {
      displayName = proto.customNickname;
    } else if (proto.hasNickName() && proto.nickName.isNotEmpty) {
      displayName = proto.nickName;
    } else if (proto.hasUserId() && proto.userId.isNotEmpty) {
      displayName = proto.userId;
    } else {
      displayName = '未知联系人';
    }

    final user = User()
      ..userId = proto.userId
      ..name = displayName // 💡 使用计算出的显示名称
      ..avatar = proto.hasAvatar() ? proto.avatar : null
      ..phone = proto.hasPhone() ? proto.phone : null
      ..email = proto.hasEmail() ? proto.email : null
      ..lastActiveTime = proto.hasLastActiveTime()
          ? DateTime.fromMillisecondsSinceEpoch(proto.lastActiveTime.toInt())
          : null
      ..status = proto.hasStatus() ? proto.status : null;

    // 如果proto中有拼音字段，则使用它；否则生成拼音
    if (proto.hasPinyin() && proto.pinyin.isNotEmpty) {
      user.pinyin = proto.pinyin;
    } else if (user.name.isNotEmpty) {
      try {
        // 生成拼音
        user.pinyin = PinyinHelper.getPinyin(user.name, separator: '');
      } catch (e) {
        // 生成失败时使用原名称
        user.pinyin = user.name;
      }
    }

    return user;
  }

  /// 将数据库对象转换为Protocol Buffer对象
  ///
  /// 用于将User对象转换为可序列化的Proto对象
  /// 便于网络传输和存储
  ///
  /// 注意：数据库中的name字段是经过显示优先级处理后的最终显示名称，
  /// 转换为Proto时暂时放在nickName字段中
  ///
  /// 返回：转换后的Protocol Buffer对象
  proto.UserProto toProto() {
    return proto.UserProto(
      userId: userId,
      nickName: name, // 💡 将显示名称放在nickName字段中
      avatar: avatar,
      phone: phone,
      email: email,
      pinyin: pinyin,
      lastActiveTime: lastActiveTime != null
          ? Int64(lastActiveTime!.millisecondsSinceEpoch)
          : null,
      status: status,
    );
  }
}
