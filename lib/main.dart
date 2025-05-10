import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/constants/app_config.dart';
import 'package:cc/core/services/communication_service.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:cc/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:cc/features/auth/presentation/pages/auth_page.dart';
import 'package:cc/features/home/presentation/cubit/home_cubit.dart';
import 'package:cc/features/home/presentation/pages/home_page.dart';
import 'package:cc/features/home/presentation/pages/home_provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cc/core/services/file_upload_service.dart';
import 'package:cc/core/services/ui_notification_service.dart';

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
  logger.i('应用配置加载完成', extra: {'serverUrl': appConfig.serverUrl});

  try {
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final logger = LogService('main.dart');
    final appConfig = AppConfig();
    logger.i('MyApp build');

    return MultiRepositoryProvider(
      providers: [
        // 注册通信服务
        RepositoryProvider<CommunicationService>(
          create: (context) => communicationService,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          // 只创建AuthCubit,移除对ChatCubit和ContactsCubit的初始化
          BlocProvider<AuthCubit>(
            create: (context) => AuthCubit(
              serverUrl: appConfig.serverUrl, // 使用全局配置的服务器URL
            ),
          ),
          BlocProvider<HomeCubit>(create: (context) => HomeCubit()),
        ],
        child: MaterialApp(
          title: 'WhatsApp',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
            useMaterial3: true,
          ),
          scaffoldMessengerKey: UINotificationService.instance.scaffoldMessengerKey,
          initialRoute: '/auth',
          routes: {
            '/home': (context) => const HomeProvider(),
            '/auth': (context) => const AuthPage(),
          },
        ),
      ),
    );
  }
}
