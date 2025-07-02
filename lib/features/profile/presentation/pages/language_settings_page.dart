import 'package:flutter/material.dart';
import 'package:cc/core/services/language_service.dart';
import 'package:cc/core/l10n/app_localizations.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/utils/ui_notification_helper.dart';

/// 语言设置页面
/// 允许用户切换应用程序的语言
class LanguageSettingsPage extends StatefulWidget {
  const LanguageSettingsPage({super.key});

  @override
  State<LanguageSettingsPage> createState() => _LanguageSettingsPageState();
}

class _LanguageSettingsPageState extends State<LanguageSettingsPage> {
  final _languageService = LanguageService();
  final _logger = LogService.instance;
  late Locale _selectedLocale;

  @override
  void initState() {
    super.initState();
    _selectedLocale = _languageService.currentLocale;
  }

  /// 切换语言
  Future<void> _switchLanguage(Locale locale) async {
    try {
      if (locale == _selectedLocale) return;

      setState(() {
        _selectedLocale = locale;
      });

      final success = await _languageService.switchLanguage(locale);
      if (success) {
        final localizations = AppLocalizations.of(context);
        UINotificationHelper.showSuccess(localizations.languageSwitched);
      } else {
        final localizations = AppLocalizations.of(context);
        UINotificationHelper.showError(localizations.languageSwitchFailed);
      }
    } catch (e) {
      _logger.e('切换语言失败', error: e);
      final localizations = AppLocalizations.of(context);
      UINotificationHelper.showError(localizations.languageSwitchFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final supportedLocales = _languageService.supportedLocales;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          localizations.language,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: supportedLocales.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final locale = supportedLocales[index];
          final isSelected =
              locale.languageCode == _selectedLocale.languageCode;

          return ListTile(
            title: Text(
              _languageService.getLanguageName(locale),
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            trailing: isSelected
                ? Icon(Icons.check, color: Theme.of(context).primaryColor)
                : null,
            onTap: () => _switchLanguage(locale),
            tileColor: Colors.white,
          );
        },
      ),
      bottomSheet: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: Text(
          localizations.languageSwitched,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
