import 'dart:io';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cc/core/services/log_service.dart';

/// 平台初始化（IO平台：Windows、macOS、Linux、iOS、Android）
Future<void> initializePlatform() async {
  // 🪟 配置桌面窗口（仅在桌面平台）
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();

    const windowOptions = WindowOptions(
      size: Size(500, 800), // 默认窗口大小
      minimumSize: Size(400, 650), // 最小窗口大小
      // center: true,                  // 居中显示
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }
}

/// 初始化目录（IO平台）
Future<void> initializeDirectories(LogService logger) async {
  // 初始化必要的文件目录
  final appDocDir = await getApplicationDocumentsDirectory();
  final mediaDir = Directory('${appDocDir.path}/media');
  if (!await mediaDir.exists()) {
    await mediaDir.create(recursive: true);
    logger.i('媒体目录已创建：${mediaDir.path}');
  }
}

/// 退出应用（IO平台）
void exitApp() {
  exit(0);
}