# macOS 通知权限测试和修复

## 问题分析

根据日志显示，之前的问题是：
```
[ERROR] iOS/macOS通知插件未找到
```

## 根本原因

在 macOS 上使用了错误的插件类型：
- **错误**: 使用 `IOSFlutterLocalNotificationsPlugin` 
- **正确**: 应该使用 `MacOSFlutterLocalNotificationsPlugin`

## 实施的修复

### 1. 分离 iOS 和 macOS 的权限处理

**修复前 (错误的实现):**
```dart
} else if (Platform.isIOS || Platform.isMacOS) {
  final darwinPlugin = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
  // macOS 上会找不到 iOS 插件
}
```

**修复后 (正确的实现):**
```dart
} else if (Platform.isIOS) {
  final iosPlugin = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
  // iOS 专用处理
} else if (Platform.isMacOS) {
  final macosPlugin = _plugin.resolvePlatformSpecificImplementation<MacOSFlutterLocalNotificationsPlugin>();
  // macOS 专用处理
}
```

### 2. 改进的 macOS 权限请求

```dart
} else if (Platform.isMacOS) {
  final macosPlugin = _plugin.resolvePlatformSpecificImplementation<MacOSFlutterLocalNotificationsPlugin>();
  
  if (macosPlugin == null) {
    _logger.e('macOS通知插件未找到');
    return false;
  }

  _logger.i('请求macOS通知权限');
  
  final granted = await macosPlugin.requestPermissions(
    alert: true,
    badge: true,
    sound: true,
  );
  
  _logger.i('macOS通知权限请求结果', extra: {
    'granted': granted,
    'platform': Platform.operatingSystemVersion,
  });
  
  return granted ?? false;
}
```

### 3. 改进的权限状态检查

```dart
} else if (Platform.isMacOS) {
  _logger.d('macOS平台权限检查', extra: {
    'platform': Platform.operatingSystem,
    'storedPermission': _hasPermission,
  });
  
  final macosPlugin = _plugin.resolvePlatformSpecificImplementation<MacOSFlutterLocalNotificationsPlugin>();
  
  if (macosPlugin == null) {
    _logger.w('macOS通知插件未找到，返回存储的权限状态');
    return _hasPermission;
  }

  // 返回存储的权限状态
  return _hasPermission;
}
```

## 测试验证

### 1. 预期的新日志

**权限请求过程:**
```
[INFO] 请求macOS通知权限
[INFO] macOS通知权限请求结果: {granted: true/false, platform: macOS 14.0}
```

**权限状态检查:**
```
[DEBUG] macOS平台权限检查: {platform: macos, storedPermission: true/false}
```

### 2. 手动测试步骤

#### A. 测试权限请求
```dart
// 在应用中调用
final service = MessageNotificationService.instance;
final granted = await service.requestPermissionAgain();
print('macOS权限请求结果: $granted');
```

#### B. 测试权限检查
```dart
// 检查当前权限状态
final hasPermission = await service.checkPermissionStatus();
print('macOS权限状态: $hasPermission');
```

#### C. 测试完整通知流程
```bash
# 运行应用
flutter run -d macos

# 发送测试消息触发会话预览更新
# 查看通知是否正常显示
```

### 3. macOS 系统设置验证

如果应用请求权限成功，你应该能在以下位置看到：
```
系统偏好设置 > 通知 > [你的应用名称]
```

## 故障排除

### 1. 如果仍然看到 "插件未找到" 错误

可能原因：
- Flutter 版本过旧
- `flutter_local_notifications` 版本不支持 macOS
- macOS 目标版本配置问题

解决方案：
```bash
# 检查 Flutter 版本
flutter --version

# 检查 flutter_local_notifications 版本
flutter pub deps | grep flutter_local_notifications

# 更新依赖
flutter pub upgrade flutter_local_notifications
```

### 2. 检查 macOS 配置

确保 `macos/Runner/Info.plist` 包含：
```xml
<key>NSUserNotificationAlertStyle</key>
<string>alert</string>
```

确保 `macos/Runner/DebugProfile.entitlements` 包含：
```xml
<key>com.apple.security.app-sandbox</key>
<true/>
<key>com.apple.security.network.client</key>
<true/>
```

### 3. 如果权限请求对话框没有出现

尝试以下步骤：
1. 完全卸载应用
2. 清理构建缓存：`flutter clean`
3. 重新构建并安装：`flutter run -d macos`
4. 第一次运行时应该会弹出权限对话框

## 后续优化

### 1. 添加权限状态实时检查 (可选)

如果 `flutter_local_notifications` 支持 macOS 权限状态查询：
```dart
// 检查 macOS 是否支持权限状态查询 API
try {
  final currentStatus = await macosPlugin.getNotificationPermissionStatus();
  return currentStatus == NotificationPermissionStatus.granted;
} catch (e) {
  // API 不支持，返回存储的状态
  return _hasPermission;
}
```

### 2. 改进用户引导

为 macOS 用户提供更精确的权限设置指导：
```dart
_uiNotificationService.showTopBanner(
  title: '需要通知权限',
  message: '请在"系统偏好设置 > 通知 > ${appName}"中允许通知',
  onTap: () {
    // 可以尝试打开系统偏好设置
    Process.run('open', ['/System/Library/PreferencePanes/Notifications.prefPane']);
  },
);
```

## 总结

这次修复解决了 macOS 平台上的关键问题：

1. ✅ **正确的插件识别** - 使用 `MacOSFlutterLocalNotificationsPlugin`
2. ✅ **平台特定处理** - 分离 iOS 和 macOS 的权限逻辑  
3. ✅ **详细的日志记录** - 更好的调试信息
4. ✅ **错误处理改进** - 优雅处理插件未找到的情况

现在 macOS 平台上的通知权限请求应该能够正常工作了！