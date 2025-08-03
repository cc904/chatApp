import 'package:flutter/material.dart';
import 'package:cc/features/auth/presentation/pages/auth_page.dart';
import 'package:cc/core/constants/app_config.dart';
import 'package:cc/core/constants/app_colors.dart';
import 'package:cc/core/l10n/app_localizations.dart';
import 'package:cc/core/services/language_service.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/services/secure_storage_service.dart';
import 'package:cc/core/services/app_lifecycle_service.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:intl/date_symbol_data_local.dart';
import 'package:cc/core/services/ui_notification_service.dart';
import 'package:cc/core/services/message_notification_service.dart';
import 'package:cc/core/services/notification_action_service.dart';
import 'package:cc/core/services/notification_settings_service.dart';
import 'package:cc/core/utils/timezone_utils.dart';
import 'package:cc/features/chat/presentation/pages/chats_page.dart';
import 'package:cc/core/services/global_overlay_service.dart';
import 'package:cc/core/services/version_info_service.dart';
import 'package:cc/core/services/version_update_service.dart';
import 'package:cc/core/services/server_selection_service.dart';
import 'package:cc/core/services/backup_domain_service.dart';

// 条件导入：根据平台导入不同的平台特定功能
import 'platform_stub.dart'
    if (dart.library.io) 'platform_io.dart'
    if (dart.library.html) 'platform_web.dart';

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
    final hasRefreshToken = await secureStorage.getRefreshToken() != null;

    if (userId != null && userId.isNotEmpty && !hasRefreshToken) {
      logger.w('⚠️ 发现用户ID存在但Token缺失的情况', extra: {
        'userId': userId,
        'hasRefreshToken': hasRefreshToken,
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

  // 🪟 配置桌面窗口（仅在桌面平台）
  await initializePlatform();

  // 🔍 检查和修复Token状态
  await _checkAndFixTokenStatus();

  // 创建日志记录器
  final logger = LogService.instance;
  logger.x('应用启动');

  // 初始化全局配置
  final appConfig = AppConfig();
  await appConfig.init(); // 等待配置初始化完成
  logger.x('应用配置加载完成', extra: {'serverUrl': appConfig.serverUrl});

  // 🔧 初始化后备域名服务
  logger.i('🔧 开始初始化后备域名服务');
  try {
    await BackupDomainService.instance.initialize();
    final serviceStatus = BackupDomainService.instance.getServiceStatus();
    logger.i('🔧 后备域名服务初始化完成', extra: serviceStatus);
  } catch (error) {
    logger.w('🔧 后备域名服务初始化失败，但应用继续运行', extra: {
      'error': error.toString(),
    });
  }

  // 🚀 初始化服务器选择服务（测速选择最优登录服务器）
  logger.i('🚀 开始初始化服务器选择服务');
  try {
    final bestLoginServer = await ServerSelectionService.instance.getBestLoginServer();
    logger.i('🚀 服务器选择服务初始化完成', extra: {
      'bestLoginServer': bestLoginServer,
    });
  } catch (error) {
    logger.w('🚀 服务器选择服务初始化失败，但应用继续运行', extra: {
      'error': error.toString(),
    });
  }

  try {
    // 初始化语言服务
    final languageService = LanguageService();
    await languageService.init();
    final currentLocale = languageService.currentLocale;

    // 🌍 初始化时区系统
    await TimezoneUtils.initialize();

    // 🔔 初始化消息通知服务
    logger.i('🔔 开始初始化消息通知服务');
    try {
      final notificationServiceInitialized = await MessageNotificationService.instance.initialize();
      logger.i('🔔 消息通知服务初始化结果', extra: {
        'initialized': notificationServiceInitialized,
        'status': MessageNotificationService.instance.getServiceStatus(),
      });

      if (!notificationServiceInitialized) {
        logger.w('🔔 消息通知服务初始化失败，但应用继续运行');
      }

      // 🔔 初始化通知动作服务
      logger.i('🔔 开始初始化通知动作服务');
      await NotificationActionService.instance.initialize();

      // 🔔 初始化通知设置服务
      logger.i('🔔 开始初始化通知设置服务');
      await NotificationSettingsService.instance.initialize();
    } catch (error, stackTrace) {
      logger.e('🔔 消息通知服务初始化失败，但应用继续运行', error: error, stackTrace: stackTrace);
      // 不抛出异常，让应用继续运行
    }

    // 📱 初始化版本信息服务
    logger.i('📱 开始初始化版本信息服务');
    try {
      await VersionInfoService.instance.initialize();
      logger.i('📱 版本信息服务初始化完成', extra: {
        'version': VersionInfoService.instance.currentVersion,
        'platform': VersionInfoService.instance.platformName,
      });
    } catch (error, stackTrace) {
      logger.e('📱 版本信息服务初始化失败，但应用继续运行', error: error, stackTrace: stackTrace);
    }

    // 初始化日期格式化的本地化数据
    await initializeDateFormatting(currentLocale.languageCode, null);

    // 初始化timeago本地化
    if (currentLocale.languageCode == 'zh') {
      timeago.setLocaleMessages('zh', timeago.ZhCnMessages());
      timeago.setDefaultLocale('zh');
    } else {
      timeago.setDefaultLocale('en');
    }

    // 初始化必要的文件目录（仅在非Web平台）
    await initializeDirectories(logger);

    // 注意：文件上传服务将在登录成功后初始化，因为需要服务器信息和认证Token
    // FileUploadService(); // 移除早期初始化

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

    // 🔧 新增：运行应用，包装在 RootRestorationScope 中以支持状态恢复
    runApp(const RootRestorationScope(
      restorationId: 'root',
      child: MyApp(),
    ));
  } catch (error) {
    logger.e('应用初始化失败', error: error, stackTrace: StackTrace.current);
    // 处理初始化错误
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('应用初始化失败: $error', style: const TextStyle(color: Colors.red)),
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
                  exitApp(); // 退出应用
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
  static final AppLifecycleObserver _instance = AppLifecycleObserver._internal();
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

    // 延迟启动版本检查，确保UI完全加载后再检查
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkVersionOnStartup();
    });
  }

  /// 启动时检查版本更新
  void _checkVersionOnStartup() {
    _logger.i('🚀 开始启动时版本检查');
    
    // 使用异步执行，不阻塞UI构建
    Future.microtask(() async {
      try {
        if (!mounted) {
          _logger.w('🚀 Widget已unmounted，取消版本检查');
          return;
        }

        final navigatorKey = UINotificationService.instance.navigatorKey;
        final context = navigatorKey.currentContext;
        _logger.i('🚀 获取导航上下文', extra: {
          'hasContext': context != null,
          'navigatorKeyHashCode': navigatorKey.hashCode,
        });
        
        if (context != null && context.mounted) {
          _logger.i('🚀 调用版本更新服务');
          await VersionUpdateService.instance.checkUpdateOnStartup(context);
          _logger.i('🚀 版本检查完成');
        } else {
          _logger.w('🚀 无法获取有效导航上下文，取消版本检查');
        }
      } catch (error) {
        _logger.e('启动时版本检查失败', error: error);
      }
    });
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
            // 🔧 新增：添加状态恢复支持
            restorationScopeId: 'app',
            navigatorKey: UINotificationService.instance.navigatorKey,
            scaffoldMessengerKey: UINotificationService.instance.scaffoldMessengerKey,
            // 💢💢💢 注册路由观察者
            navigatorObservers: [routeObserver],
            // 🌐 桌面端宽度限制（手机平板保持全宽）
            builder: (context, child) {
              final screenWidth = MediaQuery.of(context).size.width;
              
              // 只在桌面端（屏幕宽度大于1024px）限制宽度
              if (screenWidth > 1024) {
                return Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: child,
                  ),
                );
              }
              
              // 手机和平板保持全宽
              return child!;
            },
            theme: ThemeData(
              colorScheme: AppColors.lightColorScheme,
              useMaterial3: true,
              // 明确使用系统字体，禁用谷歌字体
              fontFamily: 'system-ui',
              // 使用系统默认字体，支持动态加载
              fontFamilyFallback: const [
                'system-ui',
                '-apple-system', 
                'BlinkMacSystemFont',
                'Segoe UI',
                'PingFang SC',
                'Hiragino Sans GB',
                'Microsoft YaHei',
                'Helvetica Neue',
                'Arial',
                'sans-serif'
              ],
              // 为所有Material组件明确指定字体
              textTheme: ThemeData.light().textTheme.apply(
                fontFamily: 'system-ui',
                fontFamilyFallback: const [
                  'system-ui',
                  '-apple-system', 
                  'BlinkMacSystemFont',
                  'Segoe UI',
                  'PingFang SC',
                  'Hiragino Sans GB',
                  'Microsoft YaHei',
                  'sans-serif'
                ],
              ),
              primaryTextTheme: ThemeData.light().primaryTextTheme.apply(
                fontFamily: 'system-ui',
                fontFamilyFallback: const [
                  'system-ui',
                  '-apple-system', 
                  'BlinkMacSystemFont',
                  'Segoe UI',
                  'PingFang SC',
                  'Hiragino Sans GB',
                  'Microsoft YaHei',
                  'sans-serif'
                ],
              ),
              appBarTheme: AppBarTheme(
                backgroundColor: AppColors.surfaceVariant,
                foregroundColor: AppColors.textPrimary,
                elevation: 0,
                centerTitle: true,
                titleTextStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // 添加本地化配置
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: locale,
            home: const GlobalOverlayInitializer(
              child: AuthPage(),
            ),
          );
        });
  }
}
