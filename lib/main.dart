import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as dev;
import 'package:logger/logger.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/pages/auth_page.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/home/presentation/cubit/home_cubit.dart';
import 'core/database/database_initializer.dart';
import 'features/chat/data/repositories/chat_repository_impl.dart';
import 'features/chat/domain/repositories/chat_repository.dart';
import 'features/chat/presentation/cubit/chat_cubit.dart';
import 'features/chat/presentation/pages/chat_test_page.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'core/database/models/user.dart';
import 'core/database/models/conversation.dart';
import 'core/database/models/message.dart';

void main() async {
  // 确保Flutter初始化完成
  WidgetsFlutterBinding.ensureInitialized();

  // 创建日志记录器
  final logger = Logger();

  // 初始化数据库
  try {
    // 尝试初始化数据库
    logger.i('开始初始化数据库');
    await DatabaseInitializer.init();
    logger.i('数据库初始化成功');

    // 验证数据库集合是否可访问
    try {
      final isar = DatabaseInitializer.isar;
      logger.i('验证数据库集合...');
      logger.d('Isar 实例: $isar');
      // 测试访问各个集合
      final usersCollection = isar.collection<User>();
      final conversationsCollection = isar.collection<Conversation>();
      final messagesCollection = isar.collection<Message>();

      logger.d('用户集合: ${usersCollection.name}');
      logger.d('会话集合: ${conversationsCollection.name}');
      logger.d('消息集合: ${messagesCollection.name}');
      logger.i('数据库集合验证成功');
    } catch (e) {
      logger.e('数据库集合验证失败', error: e);
      throw Exception('数据库集合验证失败: $e');
    }
  } catch (e) {
    logger.e('数据库初始化失败', error: e);

    // 尝试恢复：关闭、删除并重新创建数据库
    try {
      logger.i('开始恢复数据库...');

      // 获取应用文档目录
      final dir = await getApplicationDocumentsDirectory();
      logger.d('应用文档目录: ${dir.path}');

      // 关闭已有的数据库实例
      if (DatabaseInitializer.isInitialized) {
        logger.d('关闭当前数据库实例');
        await DatabaseInitializer.close();
      }

      // 删除数据库文件
      final dbFile = File('${dir.path}/default.isar');
      final lockFile = File('${dir.path}/default.isar.lock');

      if (await dbFile.exists()) {
        logger.d('删除数据库文件: ${dbFile.path}');
        await dbFile.delete();
      }

      if (await lockFile.exists()) {
        logger.d('删除数据库锁文件: ${lockFile.path}');
        await lockFile.delete();
      }

      logger.i('旧数据库文件已清理，准备重新初始化');

      // 重新初始化数据库
      await DatabaseInitializer.init();
      logger.i('数据库恢复初始化成功');

      // 再次验证数据库集合
      final isar = DatabaseInitializer.isar;
      logger.d('验证恢复后的数据库集合...');

      // 测试访问各个集合
      final usersCollection = isar.collection<User>();
      final conversationsCollection = isar.collection<Conversation>();
      final messagesCollection = isar.collection<Message>();

      logger.d('用户集合: ${usersCollection.name}');
      logger.d('会话集合: ${conversationsCollection.name}');
      logger.d('消息集合: ${messagesCollection.name}');
    } catch (e2) {
      logger.e('数据库恢复失败', error: e2);
      runApp(const DatabaseErrorApp());
      return;
    }
  }

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
    dev.log('MyApp build');
    return MultiRepositoryProvider(
      providers: [
        // 注册仓库
        RepositoryProvider<ChatRepository>(
          create: (context) => ChatRepositoryImpl(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>(create: (context) => AuthCubit()),
          BlocProvider<HomeCubit>(create: (context) => HomeCubit()),
          BlocProvider<ChatCubit>(
            create: (context) => ChatCubit(
              repository: context.read<ChatRepository>(),
            ),
          ),
        ],
        child: MaterialApp(
          title: 'WhatsApp Clone',
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
