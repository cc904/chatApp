import 'package:flutter/material.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:timeago/timeago.dart' as timeago;

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final LogService _logger = LogService('app.dart');

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    _logger.i('开始初始化应用');

    // 不再在应用启动时初始化数据库
    // 数据库初始化推迟到用户登录后，由AuthCubit完成

    // 初始化timeago中文本地化
    timeago.setLocaleMessages('zh', timeago.ZhCnMessages());
    timeago.setDefaultLocale('zh');

    _logger.i('应用初始化完成');
  }

  @override
  Widget build(BuildContext context) {
    return Container(); // 返回一个空容器，避免返回null
  }
}
