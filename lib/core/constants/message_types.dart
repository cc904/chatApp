/// 消息类型常量,用于替代先前的MessageType枚举
/// 使用字符串类型,以便与数据库字段类型保持一致
class MessageType {
  static const String text = 'text'; // 文本消息
  static const String image = 'image'; // 图片消息
  static const String voice = 'voice'; // 语音消息
  static const String file = 'file'; // 文件消息
  static const String video = 'video'; // 视频消息
  static const String location = 'location'; // 位置消息
  static const String system = 'system'; // 系统消息

  /// 返回所有消息类型列表
  static List<String> get values => [text, image, voice, file, video, location, system];

  /// 判断是否为多媒体类型
  static bool isMediaType(String type) {
    return type == image || type == voice || type == video || type == file;
  }
}
