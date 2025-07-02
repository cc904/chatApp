import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/l10n/app_localizations.dart';

/// 语言服务
/// 用于管理应用程序的语言设置
class LanguageService {
  static const String _languageCodeKey = 'language_code';
  static const String _countryCodeKey = 'country_code';

  final LogService _logger = LogService.instance;

  // 单例模式
  static final LanguageService _instance = LanguageService._internal();
  factory LanguageService() => _instance;
  LanguageService._internal();

  // 语言变化通知器
  final ValueNotifier<Locale> localeNotifier = ValueNotifier<Locale>(
    const Locale('zh', 'CN'), // 默认使用中文简体
  );

  /// 获取当前语言设置
  Locale get currentLocale => localeNotifier.value;

  /// 初始化语言服务
  /// 从SharedPreferences中读取保存的语言设置
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_languageCodeKey);
      final countryCode = prefs.getString(_countryCodeKey);

      if (languageCode != null) {
        final newLocale = Locale(languageCode, countryCode);
        // 检查是否是支持的语言
        if (_isSupportedLocale(newLocale)) {
          localeNotifier.value = newLocale;
          _logger.i('初始化语言设置: $languageCode-$countryCode');
        } else {
          _logger.w('不支持的语言设置: $languageCode-$countryCode，使用默认语言');
        }
      } else {
        // 如果没有保存的语言设置，则使用系统语言
        final systemLocale = PlatformDispatcher.instance.locale;
        if (_isSupportedLocale(systemLocale)) {
          localeNotifier.value = systemLocale;
          _logger.i(
              '使用系统语言: ${systemLocale.languageCode}-${systemLocale.countryCode}');
        } else {
          // 如果系统语言不受支持，则使用默认语言
          _logger.i('系统语言不受支持，使用默认语言: zh-CN');
        }
      }
    } catch (e) {
      _logger.e('初始化语言服务失败', error: e);
    }
  }

  /// 切换语言
  /// [locale] 要切换到的语言
  Future<bool> switchLanguage(Locale locale) async {
    try {
      if (!_isSupportedLocale(locale)) {
        _logger.w('不支持的语言: ${locale.languageCode}-${locale.countryCode}');
        return false;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageCodeKey, locale.languageCode);
      if (locale.countryCode != null) {
        await prefs.setString(_countryCodeKey, locale.countryCode!);
      } else {
        await prefs.remove(_countryCodeKey);
      }

      localeNotifier.value = locale;
      _logger.i('语言已切换: ${locale.languageCode}-${locale.countryCode}');
      return true;
    } catch (e) {
      _logger.e('切换语言失败', error: e);
      return false;
    }
  }

  /// 检查是否是支持的语言
  bool _isSupportedLocale(Locale locale) {
    return AppLocalizations.supportedLocales.any(
      (supportedLocale) => supportedLocale.languageCode == locale.languageCode,
    );
  }

  /// 获取所有支持的语言
  List<Locale> get supportedLocales => AppLocalizations.supportedLocales;

  /// 获取语言显示名称
  String getLanguageName(Locale locale) {
    switch (locale.languageCode) {
      case 'zh':
        return '中文';
      case 'en':
        return 'English';
      default:
        return locale.languageCode;
    }
  }
}
