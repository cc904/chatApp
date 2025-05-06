import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:cc/core/services/log_service.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/pages/auth_page.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/home/presentation/cubit/home_cubit.dart';
import 'features/chat/data/repositories/chat_repository_impl.dart';
import 'features/chat/domain/repositories/chat_repository.dart';
import 'features/chat/presentation/cubit/chat_cubit.dart';
import 'features/chat/presentation/pages/chat_test_page.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'features/contacts/data/repositories/contacts_repository_impl.dart';
import 'features/contacts/domain/repositories/contacts_repository.dart';
import 'features/contacts/presentation/cubit/contacts_cubit.dart';
import 'core/services/ui_notification_service.dart';

void main() async {
  // 确保Flutter初始化完成
  WidgetsFlutterBinding.ensureInitialized();

  // 创建日志记录器
  final logger = LogService('main.dart');

  // 初始化媒体目录
  try {
    logger.i('开始初始化媒体目录');
    await _initMediaDirectories();
    logger.i('媒体目录初始化成功');
  } catch (e) {
    logger.e('媒体目录初始化失败', error: e);
  }

  // 不再在应用启动时初始化数据库
  // 而是等待用户登录后再初始化

  runApp(const MyApp());
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
    logger.i('MyApp build');
    return MultiRepositoryProvider(
      providers: [
        // 注册仓库
        RepositoryProvider<ChatRepository>(
          create: (context) => ChatRepositoryImpl(),
        ),
        // 添加ContactsRepository
        RepositoryProvider<ContactsRepository>(
          create: (context) => ContactsRepositoryImpl(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          // 先创建ChatCubit，以便可以将其传递给AuthCubit
          BlocProvider<ChatCubit>(
            create: (context) => ChatCubit(
              repository: context.read<ChatRepository>(),
            ),
          ),
          // 创建AuthCubit，并传入ChatCubit
          BlocProvider<AuthCubit>(
            create: (context) => AuthCubit(
              chatRepository: context.read<ChatRepository>(),
              chatCubit: context.read<ChatCubit>(),
            ),
          ),
          BlocProvider<HomeCubit>(create: (context) => HomeCubit()),
          // 添加ContactsCubit
          BlocProvider<ContactsCubit>(
            create: (context) => ContactsCubit(
              repository: context.read<ContactsRepository>(),
            ),
          ),
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
            '/home': (context) => const HomePage(),
            '/chat_test': (context) => const ChatTestPage(),
          },
          initialRoute: '/',
        ),
      ),
    );
  }
}

/// 初始化媒体目录
Future<void> _initMediaDirectories() async {
  final appDocDir = await getApplicationDocumentsDirectory();
  final logger = LogService('main.dart');

  // 创建所有需要的媒体目录
  final directories = [
    'media/images',
    'media/videos',
    'media/voice',
    'media/files',
    'media/thumbnails',
    'temp',
  ];

  for (final dirPath in directories) {
    final dir = Directory('${appDocDir.path}/$dirPath');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
      logger.d('创建目录: ${dir.path}');
    }
  }

  // 清理临时目录中的文件
  try {
    final tempDir = Directory('${appDocDir.path}/temp');
    if (await tempDir.exists()) {
      await for (final entity in tempDir.list()) {
        if (entity is File) {
          try {
            await entity.delete();
            logger.d('删除临时文件: ${entity.path}');
          } catch (e) {
            logger.w('删除临时文件失败: ${entity.path}, 错误: $e');
          }
        }
      }
    }
  } catch (e) {
    logger.w('清理临时目录失败', extra: {'error': e});
  }
}
