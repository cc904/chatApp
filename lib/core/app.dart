import 'package:flutter/material.dart';
import 'package:cc/core/database/database_initializer.dart';
import 'package:timeago/timeago.dart' as timeago;

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    // 初始化数据库
    await DatabaseInitializer.init();

    // 初始化timeago中文本地化
    timeago.setLocaleMessages('zh', timeago.ZhCnMessages());
    timeago.setDefaultLocale('zh');
  }

  @override
  Widget build(BuildContext context) {
    return Container(); // 返回一个空容器，避免返回null
  }
}
