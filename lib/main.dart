import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:cc/core/constants/app_config.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/services/file_upload_service.dart';
import 'package:cc/core/services/ui_notification_service.dart';
import 'package:cc/core/services/network_notification_service.dart';
import 'package:cc/core/services/secure_storage_service.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:cc/features/auth/presentation/pages/auth_page.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  // 确保Flutter绑定初始化
  WidgetsFlutterBinding.ensureInitialized();

  // 创建日志记录器
  final logger = LogService.instance;
  logger.x('应用启动');

  // 初始化全局配置
  final appConfig = AppConfig();
  logger.x('应用配置加载完成', extra: {'serverUrl': appConfig.serverUrl});

  try {
    // 初始化日期格式化的本地化数据
    await initializeDateFormatting('zh_CN', null);

    // 初始化timeago中文本地化
    timeago.setLocaleMessages('zh', timeago.ZhCnMessages());
    timeago.setDefaultLocale('zh');

    // 初始化必要的文件目录
    final appDocDir = await getApplicationDocumentsDirectory();
    final mediaDir = Directory('${appDocDir.path}/media');
    if (!await mediaDir.exists()) {
      await mediaDir.create(recursive: true);
      logger.i('媒体目录已创建：${mediaDir.path}');
    }

    // 初始化文件上传服务
    FileUploadService();

    // 💢💢💢 新增：初始化网络状态通知服务
    NetworkNotificationService.instance.initialize();

    // 初始化安全存储服务并检查是否有保存的服务器URL
    try {
      final secureStorage = SecureStorageService.instance;
      final savedServerUrl = await secureStorage.getServerUrl();
      if (savedServerUrl != null && savedServerUrl.isNotEmpty) {
        appConfig.serverUrl = savedServerUrl;
        logger.x('从安全存储加载服务器URL', extra: {'serverUrl': savedServerUrl});
      } else {
        // 保存当前服务器URL到安全存储
        try {
          await secureStorage.saveServerUrl(appConfig.serverUrl);
        } catch (e) {
          // 保存服务器URL失败，但不影响应用启动
          logger.w('保存服务器URL到安全存储失败，将使用默认URL', extra: {'error': e.toString()});
        }
      }
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

    return MaterialApp(
      title: 'WhatsApp',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      // 添加本地化配置
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('zh', 'CN'), // 中文简体
        Locale('en', 'US'), // 英文
      ],
      locale: const Locale('zh', 'CN'), // 默认使用中文
      scaffoldMessengerKey: UINotificationService.instance.scaffoldMessengerKey,
      home: const AuthPage(),
    );
  }
}
