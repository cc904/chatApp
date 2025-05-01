import 'package:isar/isar.dart';
import 'conversation.dart';

part 'user.g.dart';

@collection
class User {
  // Isar ID
  Id id = Isar.autoIncrement;

  // 兼容性字段，与id值保持一致
  String userId = '';

  @Index(type: IndexType.value)
  late String name;

  String? avatar;
  String? phone;
  String? email;

  @Index(type: IndexType.value)
  String? pinyin;

  DateTime? lastActiveTime;
  bool isFriend = false;

  // 用户状态: online, offline, away
  String? status;

  // 反向关系 - 该用户参与的所有会话
  @Backlink(to: 'participants')
  final conversations = IsarLinks<Conversation>();

  // 为UI显示生成联系人头像文本(取名字首字母)
  String get avatarText {
    if (name.isEmpty) return '?';
    return name.substring(0, 1).toUpperCase();
  }
}
