import 'package:cc/core/database/models/user.dart';

/// 模拟数据类
class MockDataGenerator {
  /// 获取模拟联系人数据
  static List<User> generateMockContacts() {
    return mockContacts;
  }

  /// 预定义的模拟联系人数据列表
  static final List<User> mockContacts = [
    // 中文名联系人 (共50个)
     User()
      ..userId = 'user_1000'
      ..name = '张伟'
      ..phone = '13800000000'
      ..avatar = '#1abc9c'
      ..status = 'online'
      ..pinyin = 'zhangwei'
      ..email = 'user0@example.com',
    
    User()
      ..userId = 'user_1001'
      ..name = '王芳'
      ..phone = '13800000001'
      ..avatar = '#2ecc71'
      ..status = 'offline'
      ..pinyin = 'wangfang'
      ..email = 'user1@example.com',
    
    User()
      ..userId = 'user_1002'
      ..name = '李娜'
      ..phone = '13800000002'
      ..avatar = '#3498db'
      ..status = 'offline'
      ..pinyin = 'lina'
      ..email = 'user2@example.com',
    
    User()
      ..userId = 'user_1003'
      ..name = '赵秀英'
      ..phone = '13800000003'
      ..avatar = '#9b59b6'
      ..status = 'online'
      ..pinyin = 'zhaoxiuying'
      ..email = 'user3@example.com',
    
    User()
      ..userId = 'user_1004'
      ..name = '刘敏'
      ..phone = '13800000004'
      ..avatar = '#34495e'
      ..status = 'offline'
      ..pinyin = 'liumin'
      ..email = 'user4@example.com',
    
    User()
      ..userId = 'user_1005'
      ..name = '陈静'
      ..phone = '13800000005'
      ..avatar = '#16a085'
      ..status = 'offline'
      ..pinyin = 'chenjing'
      ..email = 'user5@example.com',
    
    User()
      ..userId = 'user_1006'
      ..name = '杨丽'
      ..phone = '13800000006'
      ..avatar = '#27ae60'
      ..status = 'online'
      ..pinyin = 'yangli'
      ..email = 'user6@example.com',
    
    User()
      ..userId = 'user_1007'
      ..name = '黄强'
      ..phone = '13800000007'
      ..avatar = '#2980b9'
      ..status = 'offline'
      ..pinyin = 'huangqiang'
      ..email = 'user7@example.com',
    
    User()
      ..userId = 'user_1008'
      ..name = '周磊'
      ..phone = '13800000008'
      ..avatar = '#8e44ad'
      ..status = 'offline'
      ..pinyin = 'zhoulei'
      ..email = 'user8@example.com',
    
    User()
      ..userId = 'user_1009'
      ..name = '吴军'
      ..phone = '13800000009'
      ..avatar = '#2c3e50'
      ..status = 'online'
      ..pinyin = 'wujun'
      ..email = 'user9@example.com',
    
    User()
      ..userId = 'user_1010'
      ..name = '徐洋'
      ..phone = '13800000010'
      ..avatar = '#f1c40f'
      ..status = 'offline'
      ..pinyin = 'xuyang'
      ..email = 'user10@example.com',
    
    User()
      ..userId = 'user_1011'
      ..name = '孙勇'
      ..phone = '13800000011'
      ..avatar = '#e67e22'
      ..status = 'offline'
      ..pinyin = 'sunyong'
      ..email = 'user11@example.com',
    
    User()
      ..userId = 'user_1012'
      ..name = '胡艳'
      ..phone = '13800000012'
      ..avatar = '#e74c3c'
      ..status = 'online'
      ..pinyin = 'huyan'
      ..email = 'user12@example.com',
    
    User()
      ..userId = 'user_1013'
      ..name = '朱杰'
      ..phone = '13800000013'
      ..avatar = '#ecf0f1'
      ..status = 'offline'
      ..pinyin = 'zhujie'
      ..email = 'user13@example.com',
    
    User()
      ..userId = 'user_1014'
      ..name = '高娟'
      ..phone = '13800000014'
      ..avatar = '#95a5a6'
      ..status = 'offline'
      ..pinyin = 'gaojuan'
      ..email = 'user14@example.com',
    
    User()
      ..userId = 'user_1015'
      ..name = '林涛'
      ..phone = '13800000015'
      ..avatar = '#f39c12'
      ..status = 'online'
      ..pinyin = 'lintao'
      ..email = 'user15@example.com',
    
    User()
      ..userId = 'user_1016'
      ..name = '何明'
      ..phone = '13800000016'
      ..avatar = '#d35400'
      ..status = 'offline'
      ..pinyin = 'heming'
      ..email = 'user16@example.com',
    
    User()
      ..userId = 'user_1017'
      ..name = '郭超'
      ..phone = '13800000017'
      ..avatar = '#c0392b'
      ..status = 'offline'
      ..pinyin = 'guochao'
      ..email = 'user17@example.com',
    
    User()
      ..userId = 'user_1018'
      ..name = '马秀兰'
      ..phone = '13800000018'
      ..avatar = '#bdc3c7'
      ..status = 'online'
      ..pinyin = 'maxiulan'
      ..email = 'user18@example.com',
    
    User()
      ..userId = 'user_1019'
      ..name = '罗霞'
      ..phone = '13800000019'
      ..avatar = '#7f8c8d'
      ..status = 'offline'
      ..pinyin = 'luoxia'
      ..email = 'user19@example.com',
    
    User()
      ..userId = 'user_1020'
      ..name = '梁平'
      ..phone = '13800000020'
      ..avatar = '#1abc9c'
      ..status = 'offline'
      ..pinyin = 'liangping'
      ..email = 'user20@example.com',
    
    User()
      ..userId = 'user_1021'
      ..name = '宋刚'
      ..phone = '13800000021'
      ..avatar = '#2ecc71'
      ..status = 'online'
      ..pinyin = 'songgang'
      ..email = 'user21@example.com',
    
    User()
      ..userId = 'user_1022'
      ..name = '郑桂英'
      ..phone = '13800000022'
      ..avatar = '#3498db'
      ..status = 'offline'
      ..pinyin = 'zhengguiying'
      ..email = 'user22@example.com',
    
    User()
      ..userId = 'user_1023'
      ..name = '谢文'
      ..phone = '13800000023'
      ..avatar = '#9b59b6'
      ..status = 'offline'
      ..pinyin = 'xiewen'
      ..email = 'user23@example.com',
    
    User()
      ..userId = 'user_1024'
      ..name = '韩辉'
      ..phone = '13800000024'
      ..avatar = '#34495e'
      ..status = 'online'
      ..pinyin = 'hanhui'
      ..email = 'user24@example.com',
    
    User()
      ..userId = 'user_1025'
      ..name = '唐云'
      ..phone = '13800000025'
      ..avatar = '#16a085'
      ..status = 'offline'
      ..pinyin = 'tangyun'
      ..email = 'user25@example.com',
    
    User()
      ..userId = 'user_1026'
      ..name = '冯建华'
      ..phone = '13800000026'
      ..avatar = '#27ae60'
      ..status = 'offline'
      ..pinyin = 'fengjianhua'
      ..email = 'user26@example.com',
    
    User()
      ..userId = 'user_1027'
      ..name = '于建国'
      ..phone = '13800000027'
      ..avatar = '#2980b9'
      ..status = 'online'
      ..pinyin = 'yujianguo'
      ..email = 'user27@example.com',
    
    User()
      ..userId = 'user_1028'
      ..name = '董建军'
      ..phone = '13800000028'
      ..avatar = '#8e44ad'
      ..status = 'offline'
      ..pinyin = 'dongjianjun'
      ..email = 'user28@example.com',
    
    User()
      ..userId = 'user_1029'
      ..name = '萧小红'
      ..phone = '13800000029'
      ..avatar = '#2c3e50'
      ..status = 'offline'
      ..pinyin = 'xiaoxiaohong'
      ..email = 'user29@example.com',
    
    User()
      ..userId = 'user_1030'
      ..name = '张芳'
      ..phone = '13800000030'
      ..avatar = '#f1c40f'
      ..status = 'online'
      ..pinyin = 'zhangfang'
      ..email = 'user30@example.com',
    
    User()
      ..userId = 'user_1031'
      ..name = '王娜'
      ..phone = '13800000031'
      ..avatar = '#e67e22'
      ..status = 'offline'
      ..pinyin = 'wangna'
      ..email = 'user31@example.com',
    
    User()
      ..userId = 'user_1032'
      ..name = '李秀英'
      ..phone = '13800000032'
      ..avatar = '#e74c3c'
      ..status = 'offline'
      ..pinyin = 'lixiuying'
      ..email = 'user32@example.com',
    
    User()
      ..userId = 'user_1033'
      ..name = '赵敏'
      ..phone = '13800000033'
      ..avatar = '#ecf0f1'
      ..status = 'online'
      ..pinyin = 'zhaomin'
      ..email = 'user33@example.com',
    
    User()
      ..userId = 'user_1034'
      ..name = '刘静'
      ..phone = '13800000034'
      ..avatar = '#95a5a6'
      ..status = 'offline'
      ..pinyin = 'liujing'
      ..email = 'user34@example.com',
    
    User()
      ..userId = 'user_1035'
      ..name = '陈丽'
      ..phone = '13800000035'
      ..avatar = '#f39c12'
      ..status = 'offline'
      ..pinyin = 'chenli'
      ..email = 'user35@example.com',
    
    User()
      ..userId = 'user_1036'
      ..name = '杨强'
      ..phone = '13800000036'
      ..avatar = '#d35400'
      ..status = 'online'
      ..pinyin = 'yangqiang'
      ..email = 'user36@example.com',
    
    User()
      ..userId = 'user_1037'
      ..name = '黄磊'
      ..phone = '13800000037'
      ..avatar = '#c0392b'
      ..status = 'offline'
      ..pinyin = 'huanglei'
      ..email = 'user37@example.com',
    
    User()
      ..userId = 'user_1038'
      ..name = '周军'
      ..phone = '13800000038'
      ..avatar = '#bdc3c7'
      ..status = 'offline'
      ..pinyin = 'zhoujun'
      ..email = 'user38@example.com',
    
    User()
      ..userId = 'user_1039'
      ..name = '吴洋'
      ..phone = '13800000039'
      ..avatar = '#7f8c8d'
      ..status = 'online'
      ..pinyin = 'wuyang'
      ..email = 'user39@example.com',
    
    User()
      ..userId = 'user_1040'
      ..name = '徐勇'
      ..phone = '13800000040'
      ..avatar = '#1abc9c'
      ..status = 'offline'
      ..pinyin = 'xuyong'
      ..email = 'user40@example.com',
    
    User()
      ..userId = 'user_1041'
      ..name = '孙艳'
      ..phone = '13800000041'
      ..avatar = '#2ecc71'
      ..status = 'offline'
      ..pinyin = 'sunyan'
      ..email = 'user41@example.com',
    
    User()
      ..userId = 'user_1042'
      ..name = '胡杰'
      ..phone = '13800000042'
      ..avatar = '#3498db'
      ..status = 'online'
      ..pinyin = 'hujie'
      ..email = 'user42@example.com',
    
    User()
      ..userId = 'user_1043'
      ..name = '朱娟'
      ..phone = '13800000043'
      ..avatar = '#9b59b6'
      ..status = 'offline'
      ..pinyin = 'zhujuan'
      ..email = 'user43@example.com',
    
    User()
      ..userId = 'user_1044'
      ..name = '高涛'
      ..phone = '13800000044'
      ..avatar = '#34495e'
      ..status = 'offline'
      ..pinyin = 'gaotao'
      ..email = 'user44@example.com',
    
    User()
      ..userId = 'user_1045'
      ..name = '林明'
      ..phone = '13800000045'
      ..avatar = '#16a085'
      ..status = 'online'
      ..pinyin = 'linming'
      ..email = 'user45@example.com',
    
    User()
      ..userId = 'user_1046'
      ..name = '何超'
      ..phone = '13800000046'
      ..avatar = '#27ae60'
      ..status = 'offline'
      ..pinyin = 'hechao'
      ..email = 'user46@example.com',
    
    User()
      ..userId = 'user_1047'
      ..name = '郭秀兰'
      ..phone = '13800000047'
      ..avatar = '#2980b9'
      ..status = 'offline'
      ..pinyin = 'guoxiulan'
      ..email = 'user47@example.com',
    
    User()
      ..userId = 'user_1048'
      ..name = '马霞'
      ..phone = '13800000048'
      ..avatar = '#8e44ad'
      ..status = 'online'
      ..pinyin = 'maxia'
      ..email = 'user48@example.com',
    
    User()
      ..userId = 'user_1049'
      ..name = '罗平'
      ..phone = '13800000049'
      ..avatar = '#2c3e50'
      ..status = 'offline'
      ..pinyin = 'luoping'
      ..email = 'user49@example.com',

    // 添加更多中文名联系人，共50个...
    // 为简化代码，这里只列出10个示例
    // 实际应用中需要补全50个中文联系人

    // 英文名联系人 (共30个)
    User()
      ..userId = 'user_2000'
      ..name = 'James John'
      ..phone = '13900000000'
      ..avatar = '#e67e22'
      ..status = 'online'
      ..pinyin = 'james john'
      ..email = 'james0@example.com',
    
    User()
      ..userId = 'user_2001'
      ..name = 'John Robert'
      ..phone = '13900000001'
      ..avatar = '#e74c3c'
      ..status = 'offline'
      ..pinyin = 'john robert'
      ..email = 'john1@example.com',
    
    User()
      ..userId = 'user_2002'
      ..name = 'Robert Michael'
      ..phone = '13900000002'
      ..avatar = '#ecf0f1'
      ..status = 'offline'
      ..pinyin = 'robert michael'
      ..email = 'robert2@example.com',
    
    User()
      ..userId = 'user_2003'
      ..name = 'Michael William'
      ..phone = '13900000003'
      ..avatar = '#95a5a6'
      ..status = 'online'
      ..pinyin = 'michael william'
      ..email = 'michael3@example.com',
    
    User()
      ..userId = 'user_2004'
      ..name = 'William David'
      ..phone = '13900000004'
      ..avatar = '#f39c12'
      ..status = 'offline'
      ..pinyin = 'william david'
      ..email = 'william4@example.com',
    
    User()
      ..userId = 'user_2005'
      ..name = 'David Richard'
      ..phone = '13900000005'
      ..avatar = '#d35400'
      ..status = 'offline'
      ..pinyin = 'david richard'
      ..email = 'david5@example.com',
    
    User()
      ..userId = 'user_2006'
      ..name = 'Richard Joseph'
      ..phone = '13900000006'
      ..avatar = '#c0392b'
      ..status = 'online'
      ..pinyin = 'richard joseph'
      ..email = 'richard6@example.com',
    
    User()
      ..userId = 'user_2007'
      ..name = 'Joseph Thomas'
      ..phone = '13900000007'
      ..avatar = '#bdc3c7'
      ..status = 'offline'
      ..pinyin = 'joseph thomas'
      ..email = 'joseph7@example.com',
    
    User()
      ..userId = 'user_2008'
      ..name = 'Thomas Charles'
      ..phone = '13900000008'
      ..avatar = '#7f8c8d'
      ..status = 'offline'
      ..pinyin = 'thomas charles'
      ..email = 'thomas8@example.com',
    
    User()
      ..userId = 'user_2009'
      ..name = 'Charles Mary'
      ..phone = '13900000009'
      ..avatar = '#1abc9c'
      ..status = 'online'
      ..pinyin = 'charles mary'
      ..email = 'charles9@example.com',
    
    User()
      ..userId = 'user_2010'
      ..name = 'Mary Patricia'
      ..phone = '13900000010'
      ..avatar = '#2ecc71'
      ..status = 'offline'
      ..pinyin = 'mary patricia'
      ..email = 'mary10@example.com',
    
    User()
      ..userId = 'user_2011'
      ..name = 'Patricia Jennifer'
      ..phone = '13900000011'
      ..avatar = '#3498db'
      ..status = 'offline'
      ..pinyin = 'patricia jennifer'
      ..email = 'patricia11@example.com',
    
    User()
      ..userId = 'user_2012'
      ..name = 'Jennifer Linda'
      ..phone = '13900000012'
      ..avatar = '#9b59b6'
      ..status = 'online'
      ..pinyin = 'jennifer linda'
      ..email = 'jennifer12@example.com',
    
    User()
      ..userId = 'user_2013'
      ..name = 'Linda Elizabeth'
      ..phone = '13900000013'
      ..avatar = '#34495e'
      ..status = 'offline'
      ..pinyin = 'linda elizabeth'
      ..email = 'linda13@example.com',
    
    User()
      ..userId = 'user_2014'
      ..name = 'Elizabeth Barbara'
      ..phone = '13900000014'
      ..avatar = '#16a085'
      ..status = 'offline'
      ..pinyin = 'elizabeth barbara'
      ..email = 'elizabeth14@example.com',
    
    User()
      ..userId = 'user_2015'
      ..name = 'Barbara Susan'
      ..phone = '13900000015'
      ..avatar = '#27ae60'
      ..status = 'online'
      ..pinyin = 'barbara susan'
      ..email = 'barbara15@example.com',
    
    User()
      ..userId = 'user_2016'
      ..name = 'Susan Jessica'
      ..phone = '13900000016'
      ..avatar = '#2980b9'
      ..status = 'offline'
      ..pinyin = 'susan jessica'
      ..email = 'susan16@example.com',
    
    User()
      ..userId = 'user_2017'
      ..name = 'Jessica Sarah'
      ..phone = '13900000017'
      ..avatar = '#8e44ad'
      ..status = 'offline'
      ..pinyin = 'jessica sarah'
      ..email = 'jessica17@example.com',
    
    User()
      ..userId = 'user_2018'
      ..name = 'Sarah Karen'
      ..phone = '13900000018'
      ..avatar = '#2c3e50'
      ..status = 'online'
      ..pinyin = 'sarah karen'
      ..email = 'sarah18@example.com',
    
    User()
      ..userId = 'user_2019'
      ..name = 'Karen James'
      ..phone = '13900000019'
      ..avatar = '#f1c40f'
      ..status = 'offline'
      ..pinyin = 'karen james'
      ..email = 'karen19@example.com',
    
    User()
      ..userId = 'user_2020'
      ..name = 'James Mary'
      ..phone = '13900000020'
      ..avatar = '#e67e22'
      ..status = 'offline'
      ..pinyin = 'james mary'
      ..email = 'james20@example.com',
    
    User()
      ..userId = 'user_2021'
      ..name = 'John Patricia'
      ..phone = '13900000021'
      ..avatar = '#e74c3c'
      ..status = 'online'
      ..pinyin = 'john patricia'
      ..email = 'john21@example.com',
    
    User()
      ..userId = 'user_2022'
      ..name = 'Robert Jennifer'
      ..phone = '13900000022'
      ..avatar = '#ecf0f1'
      ..status = 'offline'
      ..pinyin = 'robert jennifer'
      ..email = 'robert22@example.com',
    
    User()
      ..userId = 'user_2023'
      ..name = 'Michael Linda'
      ..phone = '13900000023'
      ..avatar = '#95a5a6'
      ..status = 'offline'
      ..pinyin = 'michael linda'
      ..email = 'michael23@example.com',
    
    User()
      ..userId = 'user_2024'
      ..name = 'William Elizabeth'
      ..phone = '13900000024'
      ..avatar = '#f39c12'
      ..status = 'online'
      ..pinyin = 'william elizabeth'
      ..email = 'william24@example.com',
    
    User()
      ..userId = 'user_2025'
      ..name = 'David Barbara'
      ..phone = '13900000025'
      ..avatar = '#d35400'
      ..status = 'offline'
      ..pinyin = 'david barbara'
      ..email = 'david25@example.com',
    
    User()
      ..userId = 'user_2026'
      ..name = 'Richard Susan'
      ..phone = '13900000026'
      ..avatar = '#c0392b'
      ..status = 'offline'
      ..pinyin = 'richard susan'
      ..email = 'richard26@example.com',
    
    User()
      ..userId = 'user_2027'
      ..name = 'Joseph Jessica'
      ..phone = '13900000027'
      ..avatar = '#bdc3c7'
      ..status = 'online'
      ..pinyin = 'joseph jessica'
      ..email = 'joseph27@example.com',
    
    User()
      ..userId = 'user_2028'
      ..name = 'Thomas Sarah'
      ..phone = '13900000028'
      ..avatar = '#7f8c8d'
      ..status = 'offline'
      ..pinyin = 'thomas sarah'
      ..email = 'thomas28@example.com',
    
    User()
      ..userId = 'user_2029'
      ..name = 'Charles Karen'
      ..phone = '13900000029'
      ..avatar = '#1abc9c'
      ..status = 'offline'
      ..pinyin = 'charles karen'
      ..email = 'charles29@example.com',

    // 添加更多英文名联系人，共30个...
    // 为简化代码，这里只列出5个示例
    // 实际应用中需要补全30个英文联系人

    // 数字ID联系人 (共20个)
    User()
      ..userId = 'user_3000'
      ..name = '用户3000'
      ..phone = '13500000000'
      ..avatar = '#d35400'
      ..status = 'online'
      ..pinyin = 'yonghu3000'
      ..email = 'user3000@example.com',
    
    User()
      ..userId = 'user_3001'
      ..name = '用户3001'
      ..phone = '13500000001'
      ..avatar = '#c0392b'
      ..status = 'offline'
      ..pinyin = 'yonghu3001'
      ..email = 'user3001@example.com',
    
    User()
      ..userId = 'user_3002'
      ..name = '用户3002'
      ..phone = '13500000002'
      ..avatar = '#bdc3c7'
      ..status = 'offline'
      ..pinyin = 'yonghu3002'
      ..email = 'user3002@example.com',
    
    User()
      ..userId = 'user_3003'
      ..name = '用户3003'
      ..phone = '13500000003'
      ..avatar = '#7f8c8d'
      ..status = 'online'
      ..pinyin = 'yonghu3003'
      ..email = 'user3003@example.com',
    
    User()
      ..userId = 'user_3004'
      ..name = '用户3004'
      ..phone = '13500000004'
      ..avatar = '#1abc9c'
      ..status = 'offline'
      ..pinyin = 'yonghu3004'
      ..email = 'user3004@example.com',
    
    User()
      ..userId = 'user_3005'
      ..name = '用户3005'
      ..phone = '13500000005'
      ..avatar = '#2ecc71'
      ..status = 'offline'
      ..pinyin = 'yonghu3005'
      ..email = 'user3005@example.com',
    
    User()
      ..userId = 'user_3006'
      ..name = '用户3006'
      ..phone = '13500000006'
      ..avatar = '#3498db'
      ..status = 'online'
      ..pinyin = 'yonghu3006'
      ..email = 'user3006@example.com',
    
    User()
      ..userId = 'user_3007'
      ..name = '用户3007'
      ..phone = '13500000007'
      ..avatar = '#9b59b6'
      ..status = 'offline'
      ..pinyin = 'yonghu3007'
      ..email = 'user3007@example.com',
    
    User()
      ..userId = 'user_3008'
      ..name = '用户3008'
      ..phone = '13500000008'
      ..avatar = '#34495e'
      ..status = 'offline'
      ..pinyin = 'yonghu3008'
      ..email = 'user3008@example.com',
    
    User()
      ..userId = 'user_3009'
      ..name = '用户3009'
      ..phone = '13500000009'
      ..avatar = '#16a085'
      ..status = 'online'
      ..pinyin = 'yonghu3009'
      ..email = 'user3009@example.com',
    
    User()
      ..userId = 'user_3010'
      ..name = '用户3010'
      ..phone = '13500000010'
      ..avatar = '#27ae60'
      ..status = 'offline'
      ..pinyin = 'yonghu3010'
      ..email = 'user3010@example.com',

    // 添加更多数字ID联系人，共20个...
    // 为简化代码，这里只列出5个示例
    // 实际应用中需要补全20个数字ID联系人
  ];
}
