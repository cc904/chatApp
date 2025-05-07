import 'package:isar/isar.dart';
import 'conversation.dart';

part 'user.g.dart';

/// 联系人/用户信息模型
/// 此模型仅用于存储联系人信息，不存储当前登录用户的信息
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

  // 拼音索引，用于搜索和排序
  @Index(type: IndexType.value)
  String? pinyin;

  // 最后活跃时间
  DateTime? lastActiveTime;

  // 联系人状态: online, offline, away
  String? status;

  // 反向关系 - 该联系人参与的所有会话
  @Backlink(to: 'participants')
  final conversations = IsarLinks<Conversation>();

  // 为UI显示生成联系人头像文本(取名字首字母)
  String get avatarText {
    if (name.isEmpty) return '?';
    return name.substring(0, 1).toUpperCase();
  }
}
