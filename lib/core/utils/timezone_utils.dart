import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:intl/intl.dart';
import 'package:cc/core/services/log_service.dart';

/// 时区处理工具类
///
/// 提供全局的时区处理方案：
/// - 📦 **存储**：所有时间都以UTC格式存储到数据库
/// - 🌍 **显示**：根据用户设备的时区显示本地时间
/// - ⚙️ **自动检测**：自动使用设备系统本地时区
///
/// ## 核心原则
/// 1. **服务器时间戳**：服务器返回的时间戳统一为UTC毫秒
/// 2. **本地存储**：数据库中所有DateTime字段都保存为UTC时间
/// 3. **显示转换**：UI显示时转换为用户设备的本地时区
/// 4. **时区感知**：自动检测并使用用户设备的系统时区
///
/// ## 使用示例
/// ```dart
/// // 创建当前UTC时间（用于存储）
/// final utcTime = TimezoneUtils.nowUtc();
///
/// // 从服务器时间戳创建UTC时间
/// final utcFromServer = TimezoneUtils.fromServerTimestamp(timestamp);
///
/// // 显示本地时间
/// final displayTime = TimezoneUtils.formatForDisplay(utcTime);
///
/// // 获取用户时区信息
/// final timezone = await TimezoneUtils.getUserTimezone();
/// ```
class TimezoneUtils {
  static final LogService _logger = LogService.instance;

  /// 用户时区缓存
  static tz.Location? _userLocation;

  /// 是否已初始化
  static bool _initialized = false;

  /// 初始化时区系统
  ///
  /// 建议在应用启动时调用，会自动检测用户设备时区
  /// 如果是中文系统，优先使用中国时区（Asia/Shanghai）
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      _logger.i('🌍 初始化时区系统...');

      // 初始化时区数据库
      tz_data.initializeTimeZones();

      // 获取设备时区
      final deviceTimezone = await FlutterTimezone.getLocalTimezone();
      _logger.i('📱 设备时区: $deviceTimezone');

      // 直接使用设备本地时区
      try {
        _userLocation = tz.getLocation(deviceTimezone);
        _logger.i('✅ 时区设置成功: ${_userLocation!.name}');
      } catch (e) {
        // 如果设备时区不存在，回退到UTC
        _logger.w('⚠️ 设备时区 $deviceTimezone 不存在，回退到UTC');
        _userLocation = tz.UTC;
      }

      _initialized = true;
      _logger.i('🎉 时区系统初始化完成');

      // 输出时区信息用于调试
      final now = DateTime.now();
      final utcNow = now.toUtc();
      final localNow = await TimezoneUtils.toUserTimezone(utcNow);

      _logger.d('🕐 时区调试信息', extra: {
        'deviceTimezone': deviceTimezone,
        'userTimezone': _userLocation!.name,
        'systemLocalTime': now.toIso8601String(),
        'utcTime': utcNow.toIso8601String(),
        'userLocalTime': localNow.toIso8601String(),
        'offsetHours':
            _userLocation!.currentTimeZone.offset ~/ (1000 * 60 * 60),
        'isDst': _userLocation!.currentTimeZone.isDst,
      });
    } catch (error) {
      _logger.e('❌ 时区系统初始化失败', error: error);
      // 初始化失败时使用UTC作为回退
      _userLocation = tz.UTC;
      _initialized = true;
    }
  }

  /// 确保时区系统已初始化
  static Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await initialize();
    }
  }

  /// 获取当前UTC时间
  ///
  /// 用于创建新的时间戳，保证所有存储的时间都是UTC格式
  ///
  /// 返回：当前的UTC时间
  static DateTime nowUtc() {
    return DateTime.now().toUtc();
  }

  /// 从服务器时间戳创建UTC时间
  ///
  /// 服务器返回的时间戳应该是UTC毫秒值
  ///
  /// [timestamp] - 服务器返回的UTC毫秒时间戳
  /// 返回：UTC格式的DateTime对象
  static DateTime fromServerTimestamp(int timestamp) {
    try {
      return DateTime.fromMillisecondsSinceEpoch(timestamp, isUtc: true);
    } catch (e) {
      _logger.e('❌ 从服务器时间戳转换失败', error: e, extra: {
        'timestamp': timestamp,
      });
      // 如果转换失败，返回当前UTC时间
      return nowUtc();
    }
  }

  /// 将UTC时间转换为用户本地时区时间
  ///
  /// [utcTime] - UTC格式的时间
  /// 返回：用户时区的本地时间
  static Future<DateTime> toUserTimezone(DateTime utcTime) async {
    await _ensureInitialized();

    try {
      // 确保输入是UTC时间
      final utc = utcTime.isUtc ? utcTime : utcTime.toUtc();

      // 转换为用户时区
      final tzDateTime = tz.TZDateTime.from(utc, _userLocation!);

      // 返回普通DateTime对象（保持时区信息）
      return DateTime(
        tzDateTime.year,
        tzDateTime.month,
        tzDateTime.day,
        tzDateTime.hour,
        tzDateTime.minute,
        tzDateTime.second,
        tzDateTime.millisecond,
        tzDateTime.microsecond,
      );
    } catch (e) {
      _logger.e('❌ 时区转换失败', error: e);
      // 转换失败时返回原时间
      return utcTime;
    }
  }

  /// 将用户本地时间转换为UTC时间
  ///
  /// [localTime] - 用户本地时区的时间
  /// 返回：UTC格式的时间
  static Future<DateTime> toUtc(DateTime localTime) async {
    await _ensureInitialized();

    try {
      // 将本地时间解释为用户时区时间
      final tzDateTime = tz.TZDateTime(
        _userLocation!,
        localTime.year,
        localTime.month,
        localTime.day,
        localTime.hour,
        localTime.minute,
        localTime.second,
        localTime.millisecond,
        localTime.microsecond,
      );

      // 转换为UTC
      return tzDateTime.toUtc();
    } catch (e) {
      _logger.e('❌ 转换为UTC失败', error: e);
      // 转换失败时直接返回UTC
      return localTime.toUtc();
    }
  }

  /// 格式化时间用于显示
  ///
  /// 自动转换UTC时间为用户本地时区并格式化显示
  ///
  /// [utcTime] - UTC格式的时间
  /// [format] - 可选的格式字符串，默认为 'HH:mm'
  /// 返回：格式化后的时间字符串
  static Future<String> formatForDisplay(
    DateTime utcTime, {
    String? format,
  }) async {
    try {
      final localTime = await toUserTimezone(utcTime);
      final formatter = DateFormat(format ?? 'HH:mm');
      return formatter.format(localTime);
    } catch (e) {
      _logger.e('❌ 时间格式化失败', error: e);
      // 格式化失败时返回简单格式
      return DateFormat('HH:mm').format(utcTime);
    }
  }

  /// 智能格式化时间显示
  ///
  /// 根据时间距离当前时间的长短，使用不同的显示格式：
  /// - 今天内：显示时间 (HH:mm)
  /// - 昨天：显示"昨天 HH:mm"
  /// - 一周内：显示"星期X HH:mm"
  /// - 更早：显示"MM月dd日 HH:mm"
  ///
  /// [utcTime] - UTC格式的时间
  /// 返回：智能格式化后的时间字符串
  static Future<String> formatSmart(DateTime utcTime) async {
    try {
      final localTime = await toUserTimezone(utcTime);
      final now = await toUserTimezone(nowUtc());

      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final messageDate =
          DateTime(localTime.year, localTime.month, localTime.day);

      if (messageDate == today) {
        // 今天：只显示时间
        return DateFormat('HH:mm').format(localTime);
      } else if (messageDate == yesterday) {
        // 昨天：显示"昨天 HH:mm"
        return '昨天 ${DateFormat('HH:mm').format(localTime)}';
      } else if (now.difference(messageDate).inDays < 7) {
        // 一周内：显示"星期X HH:mm"
        final weekdays = ['星期一', '星期二', '星期三', '星期四', '星期五', '星期六', '星期日'];
        final weekday = weekdays[localTime.weekday - 1];
        return '$weekday ${DateFormat('HH:mm').format(localTime)}';
      } else if (localTime.year == now.year) {
        // 今年：显示"MM月dd日 HH:mm"
        return DateFormat('MM月dd日 HH:mm').format(localTime);
      } else {
        // 更早：显示"yyyy年MM月dd日 HH:mm"
        return DateFormat('yyyy年MM月dd日 HH:mm').format(localTime);
      }
    } catch (e) {
      _logger.e('❌ 智能时间格式化失败', error: e);
      // 格式化失败时返回简单格式
      return DateFormat('yyyy-MM-dd HH:mm').format(utcTime);
    }
  }

  /// 格式化日期分隔符
  ///
  /// 用于聊天消息的日期分隔符显示
  ///
  /// [utcTime] - UTC格式的时间，或已经转换为本地日期的DateTime
  /// 返回：格式化后的日期字符串
  static Future<String> formatDateSeparator(DateTime utcTime) async {
    try {
      // 检测输入是否已经是本地日期（时分秒为00:00:00且非UTC）
      final bool isAlreadyLocalDate = !utcTime.isUtc &&
          utcTime.hour == 0 &&
          utcTime.minute == 0 &&
          utcTime.second == 0 &&
          utcTime.millisecond == 0;

      final DateTime localTime;
      if (isAlreadyLocalDate) {
        // 如果已经是本地日期，直接使用
        localTime = utcTime;
        _logger.d('🕐 检测到已转换的本地日期，直接使用', extra: {
          'inputTime': utcTime.toIso8601String(),
        });
      } else {
        // 否则进行时区转换
        localTime = await toUserTimezone(utcTime);
        _logger.d('🕐 对UTC时间进行时区转换', extra: {
          'inputUtcTime': utcTime.toIso8601String(),
          'convertedLocalTime': localTime.toIso8601String(),
        });
      }

      final now = await toUserTimezone(nowUtc());

      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final messageDate =
          DateTime(localTime.year, localTime.month, localTime.day);

      _logger.d('🕐 日期分隔符格式化调试', extra: {
        'messageDate': messageDate.toIso8601String(),
        'today': today.toIso8601String(),
        'yesterday': yesterday.toIso8601String(),
        'now': now.toIso8601String(),
        'localTime': localTime.toIso8601String(),
        'inputUtcTime': utcTime.toIso8601String(),
        'isAlreadyLocalDate': isAlreadyLocalDate,
      });

      if (messageDate == today) {
        _logger.d('🕐 日期分隔符格式化调试:今天');
        return '今天';
      } else if (messageDate == yesterday) {
        _logger.d('🕐 日期分隔符格式化调试:昨天');
        return '昨天';
      } else if (now.difference(messageDate).inDays < 7) {
        // 一周内显示星期几
        final weekdays = ['星期一', '星期二', '星期三', '星期四', '星期五', '星期六', '星期日'];
        _logger.d('🕐 日期分隔符格式化调试:一周内');
        return weekdays[localTime.weekday - 1];
      } else {
        // 超过一周显示具体日期
        if (localTime.year == now.year) {
          return DateFormat('MM月dd日').format(localTime);
        } else {
          return DateFormat('yyyy年MM月dd日').format(localTime);
        }
      }
    } catch (e) {
      _logger.e('❌ 日期分隔符格式化失败', error: e);
      return DateFormat('MM月dd日').format(utcTime);
    }
  }

  /// 格式化本地日期分隔符
  ///
  /// 用于已经转换为本地时区的日期分隔符显示
  ///
  /// [localDate] - 本地时区的日期（只包含年月日，时分秒应为00:00:00）
  /// 返回：格式化后的日期字符串
  static Future<String> formatLocalDateSeparator(DateTime localDate) async {
    try {
      final now = await toUserTimezone(nowUtc());

      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final messageDate =
          DateTime(localDate.year, localDate.month, localDate.day);

      _logger.d('🕐 本地日期分隔符格式化调试', extra: {
        'messageDate': messageDate.toIso8601String(),
        'today': today.toIso8601String(),
        'yesterday': yesterday.toIso8601String(),
        'now': now.toIso8601String(),
        'localDate': localDate.toIso8601String(),
      });

      if (messageDate == today) {
        _logger.d('🕐 本地日期分隔符格式化调试:今天');
        return '今天';
      } else if (messageDate == yesterday) {
        _logger.d('🕐 本地日期分隔符格式化调试:昨天');
        return '昨天';
      } else if (now.difference(messageDate).inDays < 7) {
        // 一周内显示星期几
        final weekdays = ['星期一', '星期二', '星期三', '星期四', '星期五', '星期六', '星期日'];
        _logger.d('🕐 本地日期分隔符格式化调试:一周内');
        return weekdays[localDate.weekday - 1];
      } else {
        // 超过一周显示具体日期
        if (localDate.year == now.year) {
          return DateFormat('MM月dd日').format(localDate);
        } else {
          return DateFormat('yyyy年MM月dd日').format(localDate);
        }
      }
    } catch (e) {
      _logger.e('❌ 本地日期分隔符格式化失败', error: e);
      return DateFormat('MM月dd日').format(localDate);
    }
  }

  /// 获取用户时区信息
  ///
  /// 返回：时区信息对象
  static Future<TimezoneInfo> getUserTimezoneInfo() async {
    await _ensureInitialized();

    final now = tz.TZDateTime.now(_userLocation!);

    return TimezoneInfo(
      name: _userLocation!.name,
      displayName: _getTimezoneDisplayName(_userLocation!.name),
      offsetHours: now.timeZoneOffset.inHours,
      offsetMinutes: now.timeZoneOffset.inMinutes % 60,
      isDaylightSaving: now.timeZone.isDst,
    );
  }

  /// 获取时区显示名称
  static String _getTimezoneDisplayName(String timezoneName) {
    switch (timezoneName) {
      case 'Asia/Shanghai':
        return '中国标准时间 (CST)';
      case 'Asia/Tokyo':
        return '日本标准时间 (JST)';
      case 'America/New_York':
        return '美国东部时间 (EST/EDT)';
      case 'America/Los_Angeles':
        return '美国太平洋时间 (PST/PDT)';
      case 'Europe/London':
        return '格林威治标准时间 (GMT/BST)';
      case 'UTC':
        return '协调世界时 (UTC)';
      default:
        return timezoneName;
    }
  }

  /// 创建指定日期的UTC时间范围
  ///
  /// 用于数据库查询指定日期的消息
  ///
  /// [localDate] - 用户选择的本地日期
  /// 返回：该日期在UTC时区的开始和结束时间
  static Future<TimezoneUtilsDateTimeRange> createUtcDateRange(
      DateTime localDate) async {
    await _ensureInitialized();

    try {
      // 创建本地日期的开始和结束时间
      final localStart =
          DateTime(localDate.year, localDate.month, localDate.day, 0, 0, 0);
      final localEnd = DateTime(
          localDate.year, localDate.month, localDate.day, 23, 59, 59, 999);

      // 转换为UTC时间
      final utcStart = await toUtc(localStart);
      final utcEnd = await toUtc(localEnd);

      return TimezoneUtilsDateTimeRange(start: utcStart, end: utcEnd);
    } catch (e) {
      _logger.e('❌ 创建UTC日期范围失败', error: e);
      // 失败时使用输入日期作为UTC时间
      final start =
          DateTime(localDate.year, localDate.month, localDate.day, 0, 0, 0)
              .toUtc();
      final end = DateTime(
              localDate.year, localDate.month, localDate.day, 23, 59, 59, 999)
          .toUtc();
      return TimezoneUtilsDateTimeRange(start: start, end: end);
    }
  }

  /// 从UTC时间提取本地日期（年月日）
  ///
  /// 用于消息分组显示
  ///
  /// [utcTime] - UTC格式的时间
  /// 返回：用户时区的日期部分
  static Future<DateTime> extractLocalDate(DateTime utcTime) async {
    final localTime = await toUserTimezone(utcTime);
    return DateTime(localTime.year, localTime.month, localTime.day);
  }

  /// 调试：输出时区转换信息
  static Future<void> debugTimeConversion(DateTime utcTime) async {
    await _ensureInitialized();

    final localTime = await toUserTimezone(utcTime);
    final timezoneInfo = await getUserTimezoneInfo();

    _logger.d('🕐 时区转换调试', extra: {
      'inputUtc': utcTime.toIso8601String(),
      'outputLocal': localTime.toIso8601String(),
      'timezone': timezoneInfo.name,
      'offset':
          '${timezoneInfo.offsetHours}:${timezoneInfo.offsetMinutes.toString().padLeft(2, '0')}',
      'isDst': timezoneInfo.isDaylightSaving,
    });
  }
}

/// 时区信息类
class TimezoneInfo {
  final String name;
  final String displayName;
  final int offsetHours;
  final int offsetMinutes;
  final bool isDaylightSaving;

  const TimezoneInfo({
    required this.name,
    required this.displayName,
    required this.offsetHours,
    required this.offsetMinutes,
    required this.isDaylightSaving,
  });

  /// 获取时区偏移字符串 (如 "+08:00")
  String get offsetString {
    final sign = offsetHours >= 0 ? '+' : '-';
    final hours = offsetHours.abs().toString().padLeft(2, '0');
    final minutes = offsetMinutes.abs().toString().padLeft(2, '0');
    return '$sign$hours:$minutes';
  }

  @override
  String toString() {
    return '$displayName ($offsetString)';
  }
}

/// 时区日期时间范围类
class TimezoneUtilsDateTimeRange {
  final DateTime start;
  final DateTime end;

  const TimezoneUtilsDateTimeRange({
    required this.start,
    required this.end,
  });

  @override
  String toString() {
    return '${start.toIso8601String()} - ${end.toIso8601String()}';
  }
}
