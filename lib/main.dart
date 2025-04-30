import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/pages/auth_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // 这是你应用程序的主题。
        //
        // 试试这个：用"flutter run"运行你的应用程序。你会看到
        // 应用程序有一个紫色的工具栏。然后，在不退出应用程序的情况下，
        // 尝试将下面colorScheme中的seedColor更改为Colors.green，
        // 然后触发"热重载"（在支持Flutter的IDE中保存更改或按"热重载"
        // 按钮，如果你使用命令行启动应用程序，则按"r"）。
        //
        // 注意计数器没有重置回零；在重载过程中应用程序的状态不会丢失。
        // 要重置状态，请使用热重启。
        //
        // 这不仅适用于值，也适用于代码：大多数代码更改都可以
        // 通过热重载来测试。
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // home: const MyHomePage(title: 'Flutter Demo Home Page'),
      home: BlocProvider(
        create: (context) => AuthCubit(),
        child: const AuthPage(),
      ),
    );
  }
}
