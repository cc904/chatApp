import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/constants/app_config.dart';
import 'package:cc/core/services/communication_service.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/pages/auth_page.dart';
import 'features/home/presentation/cubit/home_cubit.dart';
import 'dart:io';
import 'core/services/ui_notification_service.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cc/core/database/mock_data_manager.dart';
import 'package:cc/features/home/presentation/pages/home_provider.dart';

// 通信服务实例
final communicationService = CommunicationService();

void main() async {
  // 确保Flutter绑定初始化
  WidgetsFlutterBinding.ensureInitialized();

  // 创建日志记录器
  final logger = LogService('main.dart');
  logger.i('应用启动');

  // 初始化全局配置
  final appConfig = AppConfig();
  logger.i('应用配置加载完成', extra: {'isSimulationMode': appConfig.isSimulationMode, 'serverUrl': appConfig.serverUrl});

  try {
    if (appConfig.isSimulationMode) {
      // 初始化模拟数据管理器
      await MockDataManager.init();
      logger.i('模拟数据管理器初始化完成');
    } else {
      // 初始化匿名通信连接（不需要token和userId）
      await communicationService.connectAnonymous(serverUrl: appConfig.serverUrl);
      logger.i('匿名通信服务初始化完成');
    }

    // 初始化timeago中文本地化
    timeago.setLocaleMessages('zh', timeago.ZhCnMessages());
    timeago.setDefaultLocale('zh');

    // 运行应用
    runApp(const MyApp());
  } catch (e) {
    logger.e('应用初始化失败', error: e);
    // 处理初始化错误
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('应用初始化失败: $e', style: const TextStyle(color: Colors.red)),
          ),
        ),
      ),
    );
  }
}

/// 数据库错误应用程序
/// 当数据库初始化和恢复都失败时显示
class DatabaseErrorApp extends StatelessWidget {
  const DatabaseErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '数据库错误',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 64),
              const SizedBox(height: 16),
              const Text(
                '数据库初始化失败',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                '请尝试重新启动应用程序。如果问题仍然存在，请清除应用数据或联系开发人员。',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final logger = LogService('main.dart');
    final appConfig = AppConfig();
    logger.i('MyApp build', extra: {'isSimulationMode': appConfig.isSimulationMode});

    return MultiRepositoryProvider(
      providers: [
        // 注册通信服务
        RepositoryProvider<CommunicationService>(
          create: (context) => communicationService,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          // 只创建AuthCubit，移除对ChatCubit和ContactsCubit的初始化
          BlocProvider<AuthCubit>(
            create: (context) => AuthCubit(
              serverUrl: appConfig.serverUrl, // 使用全局配置的服务器URL
              isSimulationMode: appConfig.isSimulationMode, // 使用全局配置的模拟模式
            ),
          ),
          BlocProvider<HomeCubit>(create: (context) => HomeCubit()),
        ],
        child: MaterialApp(
          title: 'WhatsApp Clone',
          // 使用UINotificationService的全局key
          scaffoldMessengerKey: UINotificationService().scaffoldMessengerKey,
          // 添加本地化支持
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('zh', 'CN'), // 中文简体
            Locale('en', 'US'), // 英文
          ],
          locale: const Locale('zh', 'CN'), // 默认使用中文简体
          theme: ThemeData(
            // 使用绿色作为主题色
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.green,
              primary: Colors.green,
              secondary: Colors.green[700],
              surface: Colors.green[50],
            ),
            useMaterial3: true,
            // 设置按钮主题
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
            // 设置输入框主题
            inputDecorationTheme: InputDecorationTheme(
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.green),
                borderRadius: BorderRadius.circular(8),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            // 设置TabBar主题
            tabBarTheme: TabBarTheme(
              labelColor: Colors.green[800],
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.green,
              indicatorSize: TabBarIndicatorSize.label,
            ),
          ),
          // 定义路由
          routes: {
            '/': (context) => const AuthPage(),
            '/home': (context) => const HomeProvider(),
          },
          initialRoute: '/',
        ),
      ),
    );
  }
}
