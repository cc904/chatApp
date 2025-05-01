import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as dev;
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/pages/auth_page.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/home/presentation/cubit/home_cubit.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    dev.log('MyApp build');
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(create: (context) => AuthCubit()),
        BlocProvider<HomeCubit>(create: (context) => HomeCubit()),
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
        },
        initialRoute: '/',
      ),
    );
  }
}
