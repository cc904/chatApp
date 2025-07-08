import 'package:flutter/material.dart';
import 'package:cc/features/auth/presentation/pages/auth_page.dart';
import 'package:cc/core/constants/app_config.dart';
import 'package:cc/core/constants/app_colors.dart';
import 'package:cc/core/l10n/app_localizations.dart';
import 'package:cc/core/services/language_service.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/services/file_upload_service.dart';
import 'package:cc/core/services/secure_storage_service.dart';
import 'package:cc/core/services/app_lifecycle_service.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:timeago/timeago.dart' as timeago;
import 'package:intl/date_symbol_data_local.dart';
import 'package:cc/core/services/ui_notification_service.dart';
import 'package:cc/core/utils/timezone_utils.dart';

/// 检查和修复Token状态
Future<void> _checkAndFixTokenStatus() async {
  try {
    final logger = LogService.instance;
    final secureStorage = SecureStorageService();

    logger.i('🔍 启动时检查Token状态');

    // // 调试存储状态
    // await secureStorage.debugStorageStatus();

    // 检查是否有用户ID但没有Token的情况
    final userId = await secureStorage.read('user_id');
    final hasAccessToken = await secureStorage.getAccessToken() != null;

    if (userId != null && userId.isNotEmpty && !hasAccessToken) {
      logger.w('⚠️ 发现用户ID存在但Token缺失的情况', extra: {
        'userId': userId,
        'hasAccessToken': hasAccessToken,
      });

      // 这种情况下，清除用户状态，要求重新登录
      logger.i('🧹 清除不完整的认证状态，要求用户重新登录');
      await secureStorage.clearUserCredentials();
      await secureStorage.clearAllTokens();
    }

    logger.i('✅ Token状态检查完成');
  } catch (error) {
    LogService.instance.e('Token状态检查失败', error: error);
  }
}

void main() async {
  // 确保Flutter绑定初始化
  WidgetsFlutterBinding.ensureInitialized();

  // 🔍 检查和修复Token状态
  await _checkAndFixTokenStatus();

  // 创建日志记录器
  final logger = LogService.instance;
  logger.x('应用启动');

  // 初始化全局配置
  final appConfig = AppConfig();
  await appConfig.init(); // 等待配置初始化完成
  logger.x('应用配置加载完成', extra: {'serverUrl': appConfig.serverUrl});

  try {
    // 初始化语言服务
    final languageService = LanguageService();
    await languageService.init();
    final currentLocale = languageService.currentLocale;

    // 🌍 初始化时区系统
    await TimezoneUtils.initialize();

    // 初始化日期格式化的本地化数据
    await initializeDateFormatting(currentLocale.languageCode, null);

    // 初始化timeago本地化
    if (currentLocale.languageCode == 'zh') {
      timeago.setLocaleMessages('zh', timeago.ZhCnMessages());
      timeago.setDefaultLocale('zh');
    } else {
      timeago.setDefaultLocale('en');
    }

    // 初始化必要的文件目录
    final appDocDir = await getApplicationDocumentsDirectory();
    final mediaDir = Directory('${appDocDir.path}/media');
    if (!await mediaDir.exists()) {
      await mediaDir.create(recursive: true);
      logger.i('媒体目录已创建：${mediaDir.path}');
    }

    // 初始化文件上传服务
    FileUploadService();

    // 🔄 初始化应用生命周期服务
    AppLifecycleService.instance.initialize();
    logger.i('应用生命周期服务已初始化');

    // 初始化安全存储服务
    try {
      // 移除旧的服务器URL存储逻辑，现在使用AppConfig的SharedPreferences存储
      logger.i('安全存储服务已初始化');
    } catch (e) {
      // 安全存储服务初始化失败，但不影响应用启动
      logger.w('安全存储服务初始化失败，将使用默认设置', extra: {'error': e.toString()});
    }

    // 运行应用
    runApp(const MyApp());
  } catch (error) {
    logger.e('应用初始化失败', error: error, stackTrace: StackTrace.current);
    // 处理初始化错误
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('应用初始化失败: $error',
                style: const TextStyle(color: Colors.red)),
          ),
        ),
      ),
    );
  }
}

/// 数据库错误应用程序
/// 当数据库初始化和恢复都失败时显示
class DatabaseErrorApp extends StatelessWidget {
  final String errorMessage;

  const DatabaseErrorApp({super.key, required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 64),
              const SizedBox(height: 16),
              const Text(
                '数据库初始化失败',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  exit(0); // 退出应用
                },
                child: const Text('退出应用'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 应用生命周期观察器
class AppLifecycleObserver extends WidgetsBindingObserver {
  static final AppLifecycleObserver _instance =
      AppLifecycleObserver._internal();
  static bool _isInitialized = false;

  factory AppLifecycleObserver() {
    return _instance;
  }

  AppLifecycleObserver._internal();

  static void initialize() {
    if (!_isInitialized) {
      WidgetsBinding.instance.addObserver(_instance);
      _isInitialized = true;
    }
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _logger = LogService.instance;
  final _languageService = LanguageService();

  @override
  void initState() {
    super.initState();
    _logger.x('初始化MyApp状态');
  }

  @override
  Widget build(BuildContext context) {
    _logger.x('MyApp build');

    // 确保在应用运行时服务仍然存在，应用退出时释放资源
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 初始化生命周期观察者（只添加一次）
      AppLifecycleObserver.initialize();
    });

    return ValueListenableBuilder<Locale>(
        valueListenable: _languageService.localeNotifier,
        builder: (context, locale, child) {
          return MaterialApp(
            title: 'ThisApp',
            scaffoldMessengerKey:
                UINotificationService.instance.scaffoldMessengerKey,
            theme: ThemeData(
              colorScheme: AppColors.lightColorScheme,
              useMaterial3: true,
              appBarTheme: AppBarTheme(
                backgroundColor: AppColors.surfaceVariant,
                foregroundColor: AppColors.textPrimary,
                elevation: 0,
                centerTitle: true,
              ),
            ),
            // 添加本地化配置
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: locale,
            home: const AuthPage(),
          );
        });
  }
}
