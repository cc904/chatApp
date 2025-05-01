import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as dev;
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/pages/auth_page.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/home/presentation/cubit/home_cubit.dart';
import 'core/database/database_initializer.dart';
import 'features/chat/data/repositories/chat_repository_impl.dart';
import 'features/chat/domain/repositories/chat_repository.dart';
import 'features/chat/presentation/cubit/chat_cubit.dart';
import 'features/chat/presentation/pages/chat_test_page.dart';

void main() async {
  // 确保Flutter初始化完成
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化数据库
  try {
    await DatabaseInitializer.init();
    dev.log('数据库初始化成功');
  } catch (e) {
    dev.log('数据库初始化失败: $e');
  }

  runApp(const MyApp());
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
