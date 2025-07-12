/// 字符串工具类
///
/// 提供常用的字符串操作工具方法
class StringUtils {
  StringUtils._(); // 私有构造函数，防止实例化

  /// 安全地截取字符串用于日志显示
  ///
  /// [str] - 要截取的字符串
  /// [maxLength] - 最大长度，默认20
  /// [suffix] - 当字符串被截取时添加的后缀，默认'...'
  /// 返回截取后的字符串
  static String truncateForLog(String? str,
      {int maxLength = 20, String suffix = '...'}) {
    if (str == null || str.isEmpty) {
      return '';
    }

    if (str.length <= maxLength) {
      return str;
    }

    return '${str.substring(0, maxLength)}$suffix';
  }

  /// 安全地截取字符串，不添加后缀
  ///
  /// [str] - 要截取的字符串
  /// [maxLength] - 最大长度
  /// 返回截取后的字符串
  static String truncate(String? str, int maxLength) {
    if (str == null || str.isEmpty) {
      return '';
    }

    if (str.length <= maxLength) {
      return str;
    }

    return str.substring(0, maxLength);
  }

  /// 检查字符串是否为空或null
  ///
  /// [str] - 要检查的字符串
  /// 返回是否为空
  static bool isEmpty(String? str) {
    return str == null || str.trim().isEmpty;
  }

  /// 检查字符串是否不为空且不为null
  ///
  /// [str] - 要检查的字符串
  /// 返回是否不为空
  static bool isNotEmpty(String? str) {
    return !isEmpty(str);
  }

  /// 首字母大写
  ///
  /// [str] - 要处理的字符串
  /// 返回首字母大写的字符串
  static String capitalize(String? str) {
    if (isEmpty(str)) {
      return '';
    }

    final trimmed = str!.trim();
    if (trimmed.isEmpty) {
      return '';
    }

    return trimmed[0].toUpperCase() + trimmed.substring(1);
  }

  /// 移除字符串中的所有空白字符
  ///
  /// [str] - 要处理的字符串
  /// 返回移除空白字符后的字符串
  static String removeWhitespace(String? str) {
    if (isEmpty(str)) {
      return '';
    }

    return str!.replaceAll(RegExp(r'\s+'), '');
  }

  /// 格式化文件大小显示
  ///
  /// [bytes] - 字节数
  /// [decimals] - 小数位数，默认1
  /// 返回格式化的文件大小字符串
  static String formatFileSize(int bytes, {int decimals = 1}) {
    if (bytes <= 0) return '0 B';

    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    final i = (bytes.bitLength - 1) ~/ 10;

    if (i >= suffixes.length) {
      return '${(bytes / (1 << ((suffixes.length - 1) * 10))).toStringAsFixed(decimals)} ${suffixes.last}';
    }

    return '${(bytes / (1 << (i * 10))).toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  /// 格式化时长显示
  ///
  /// [duration] - 时长（秒）
  /// 返回格式化的时长字符串（如：1:23）
  static String formatDuration(int durationInSeconds) {
    if (durationInSeconds < 0) {
      return '0:00';
    }

    final minutes = durationInSeconds ~/ 60;
    final seconds = durationInSeconds % 60;

    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }

  /// 验证邮箱格式
  ///
  /// [email] - 邮箱地址
  /// 返回是否为有效邮箱格式
  static bool isValidEmail(String? email) {
    if (isEmpty(email)) {
      return false;
    }

    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email!);
  }

  /// 验证手机号格式（中国大陆）
  ///
  /// [phone] - 手机号
  /// 返回是否为有效手机号格式
  static bool isValidChinesePhone(String? phone) {
    if (isEmpty(phone)) {
      return false;
    }

    return RegExp(r'^1[3-9]\d{9}$').hasMatch(phone!);
  }

  /// 脱敏手机号显示
  ///
  /// [phone] - 手机号
  /// 返回脱敏后的手机号（如：138****1234）
  static String maskPhone(String? phone) {
    if (isEmpty(phone) || phone!.length < 7) {
      return phone ?? '';
    }

    if (phone.length == 11) {
      // 中国大陆手机号
      return '${phone.substring(0, 3)}****${phone.substring(7)}';
    } else {
      // 其他情况，显示前3位和后2位
      final visibleStart = phone.length > 5 ? 3 : 1;
      final visibleEnd = phone.length > 3 ? 2 : 1;

      return '${phone.substring(0, visibleStart)}${'*' * (phone.length - visibleStart - visibleEnd)}${phone.substring(phone.length - visibleEnd)}';
    }
  }

  /// 脱敏邮箱显示
  ///
  /// [email] - 邮箱地址
  /// 返回脱敏后的邮箱（如：abc***@gmail.com）
  static String maskEmail(String? email) {
    if (isEmpty(email) || !email!.contains('@')) {
      return email ?? '';
    }

    final parts = email.split('@');
    if (parts.length != 2) {
      return email;
    }

    final username = parts[0];
    final domain = parts[1];

    if (username.length <= 3) {
      return '${username[0]}***@$domain';
    } else {
      return '${username.substring(0, 2)}***${username[username.length - 1]}@$domain';
    }
  }
}
