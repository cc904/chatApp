import 'package:cc/core/database/models/conversation.dart';
import 'package:lpinyin/lpinyin.dart';

/// 参与者排序工具类
///
/// 排序规则：
/// 1. 按权限优先级（owner > admin > member）
/// 2. 同一权限下按姓名首字母/拼音升序
class ParticipantSortUtils {
  ParticipantSortUtils._();

  /// 获取角色优先级，数字越小优先级越高
  static int _rolePriority(MemberRole role) {
    switch (role) {
      case MemberRole.owner:
        return 0;
      case MemberRole.admin:
        return 1;
      case MemberRole.member:
        return 2;
    }
  }

  /// 比较函数：按权限 -> 姓名拼音
  static int compareByRoleAndName(Participant a, Participant b) {
    final rpA = _rolePriority(a.role);
    final rpB = _rolePriority(b.role);

    if (rpA != rpB) return rpA - rpB;

    // 权限相同，按姓名拼音排序
    final pinyinA = _nameToPinyin(a.name);
    final pinyinB = _nameToPinyin(b.name);
    return pinyinA.compareTo(pinyinB);
  }

  /// 将姓名转换为拼音首字母+全拼，便于排序
  static String _nameToPinyin(String name) {
    if (name.isEmpty) return '';
    // 使用lpinyin获取完整拼音，去掉音调，转小写
    return PinyinHelper.getPinyinE(name,
            separator: '', format: PinyinFormat.WITHOUT_TONE)
        .toLowerCase();
  }

  /// 就地排序
  static void sortParticipants(List<Participant> list) {
    list.sort(compareByRoleAndName);
  }

  /// 返回排序后的新列表
  static List<Participant> getSorted(List<Participant> list) {
    final newList = List<Participant>.from(list);
    sortParticipants(newList);
    return newList;
  }
}
