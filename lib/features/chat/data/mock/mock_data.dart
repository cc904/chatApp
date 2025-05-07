import 'package:cc/core/database/models/user.dart';

/// 模拟数据生成器类
class MockDataGenerator {
  /// 生成模拟联系人数据
  static List<User> generateMockContacts() {
    final List<User> contacts = [];

    // 一些常见的中文姓氏
    final surnames = ['张', '王', '李', '赵', '刘', '陈', '杨', '黄', '周', '吴', '徐', '孙', '胡', '朱', '高', '林', '何', '郭', '马', '罗', '梁', '宋', '郑', '谢', '韩', '唐', '冯', '于', '董', '萧'];

    // 一些常见的中文名字
    final names = ['伟', '芳', '娜', '秀英', '敏', '静', '丽', '强', '磊', '军', '洋', '勇', '艳', '杰', '娟', '涛', '明', '超', '秀兰', '霞', '平', '刚', '桂英', '文', '辉', '云', '建华', '建国', '建军', '小红'];

    // 一些英文名
    final englishNames = [
      'James',
      'John',
      'Robert',
      'Michael',
      'William',
      'David',
      'Richard',
      'Joseph',
      'Thomas',
      'Charles',
      'Mary',
      'Patricia',
      'Jennifer',
      'Linda',
      'Elizabeth',
      'Barbara',
      'Susan',
      'Jessica',
      'Sarah',
      'Karen'
    ];

    // 生成50个中文名联系人
    for (int i = 0; i < 50; i++) {
      final surname = surnames[i % surnames.length];
      final name = names[i % names.length];
      final fullName = '$surname$name';

      final user = User()
        ..userId = 'user_${1000 + i}'
        ..name = fullName
        ..phone = '138${i.toString().padLeft(8, '0')}'
        ..avatar = 'https://randomuser.me/api/portraits/${i % 2 == 0 ? 'men' : 'women'}/${(i % 70) + 1}.jpg'
        ..status = i % 3 == 0 ? 'online' : 'offline'
        ..pinyin = _getPinyin(fullName)
        ..email = 'user$i@example.com';

      contacts.add(user);
    }

    // 生成30个英文名联系人
    for (int i = 0; i < 30; i++) {
      final name = englishNames[i % englishNames.length];
      final lastName = englishNames[(i + 10) % englishNames.length];
      final fullName = '$name $lastName';

      final user = User()
        ..userId = 'user_${2000 + i}'
        ..name = fullName
        ..phone = '139${i.toString().padLeft(8, '0')}'
        ..avatar = 'https://randomuser.me/api/portraits/${i % 2 == 0 ? 'women' : 'men'}/${(i % 70) + 30}.jpg'
        ..status = i % 4 == 0 ? 'online' : 'offline'
        ..pinyin = fullName.toLowerCase()
        ..email = '${name.toLowerCase()}$i@example.com';

      contacts.add(user);
    }

    // 生成20个数字ID联系人
    for (int i = 0; i < 20; i++) {
      final user = User()
        ..userId = 'user_${3000 + i}'
        ..name = '用户${3000 + i}'
        ..phone = '135${i.toString().padLeft(8, '0')}'
        ..avatar = 'https://randomuser.me/api/portraits/${i % 2 == 0 ? 'men' : 'women'}/${(i % 50) + 10}.jpg'
        ..status = i % 5 == 0 ? 'online' : 'offline'
        ..pinyin = 'yonghu${3000 + i}'
        ..email = 'user${3000 + i}@example.com';

      contacts.add(user);
    }

    return contacts;
  }

  /// 简单的拼音转换函数(仅供模拟)
  static String _getPinyin(String name) {
    final Map<String, String> pinyinMap = {
      '张': 'zhang',
      '王': 'wang',
      '李': 'li',
      '赵': 'zhao',
      '刘': 'liu',
      '陈': 'chen',
      '杨': 'yang',
      '黄': 'huang',
      '周': 'zhou',
      '吴': 'wu',
      '徐': 'xu',
      '孙': 'sun',
      '胡': 'hu',
      '朱': 'zhu',
      '高': 'gao',
      '林': 'lin',
      '何': 'he',
      '郭': 'guo',
      '马': 'ma',
      '罗': 'luo',
      '梁': 'liang',
      '宋': 'song',
      '郑': 'zheng',
      '谢': 'xie',
      '韩': 'han',
      '唐': 'tang',
      '冯': 'feng',
      '于': 'yu',
      '董': 'dong',
      '萧': 'xiao',
      '伟': 'wei',
      '芳': 'fang',
      '娜': 'na',
      '秀英': 'xiuying',
      '敏': 'min',
      '静': 'jing',
      '丽': 'li',
      '强': 'qiang',
      '磊': 'lei',
      '军': 'jun',
      '洋': 'yang',
      '勇': 'yong',
      '艳': 'yan',
      '杰': 'jie',
      '娟': 'juan',
      '涛': 'tao',
      '明': 'ming',
      '超': 'chao',
      '秀兰': 'xiulan',
      '霞': 'xia',
      '平': 'ping',
      '刚': 'gang',
      '桂英': 'guiying',
      '文': 'wen',
      '辉': 'hui',
      '云': 'yun',
      '建华': 'jianhua',
      '建国': 'jianguo',
      '建军': 'jianjun',
      '小红': 'xiaohong'
    };

    String result = '';
    for (int i = 0; i < name.length; i++) {
      final char = name[i];
      if (pinyinMap.containsKey(char)) {
        result += pinyinMap[char]!;
      } else {
        result += char.toLowerCase();
      }
    }
    return result;
  }
}
