# Android 构建错误修复方案

## 问题描述

构建Android应用时出现以下错误：
```
ERROR: resource attr/colorOnSurface (aka com.example.cc:attr/colorOnSurface) not found.
```

## 错误原因

在通知动作按钮的图标文件中使用了 `?attr/colorOnSurface`，这个主题属性在当前应用中没有定义。

## 已实施的修复

### 1. 修复 ic_mark_read.xml
**位置**: `android/app/src/main/res/drawable/ic_mark_read.xml`

**修改前**:
```xml
android:tint="?attr/colorOnSurface"
```

**修改后**:
```xml
android:tint="@android:color/white"
```

### 2. 修复 ic_reply.xml
**位置**: `android/app/src/main/res/drawable/ic_reply.xml`

**修改前**:
```xml
android:tint="?attr/colorOnSurface"
```

**修改后**:
```xml
android:tint="@android:color/white"
```

## 替代解决方案

如果上述修复仍然有问题，可以尝试以下方案：

### 方案1: 移除tint属性
```xml
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp"
    android:height="24dp"
    android:viewportWidth="24"
    android:viewportHeight="24">
  <!-- 移除 android:tint 行 -->
  <path
      android:fillColor="#FFFFFF"
      android:pathData="M12,2C6.48,2 2,6.48 2,12s4.48,10 10,10 10,-4.48 10,-10S17.52,2 12,2zM10,17l-5,-5 1.41,-1.41L10,14.17l7.59,-7.59L19,8l-9,9z"/>
</vector>
```

### 方案2: 使用系统颜色
```xml
android:tint="@android:color/black"
android:tint="@android:color/darker_gray"
```

### 方案3: 定义自定义颜色
在 `android/app/src/main/res/values/colors.xml` 中定义：
```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="notification_icon_color">#FFFFFF</color>
</resources>
```

然后使用：
```xml
android:tint="@color/notification_icon_color"
```

## 临时禁用方案

如果通知图标问题持续存在，可以临时禁用动作按钮：

### 修改 MessageNotificationService.dart
```dart
/// 构建通知动作按钮
List<AndroidNotificationAction> _buildNotificationActions() {
  // 临时返回空列表，禁用动作按钮
  return [];
  
  // 原来的代码：
  // return [
  //   const AndroidNotificationAction(...),
  //   const AndroidNotificationAction(...),
  // ];
}
```

## 验证修复

### 1. 清理构建
```bash
flutter clean
flutter pub get
```

### 2. 重新构建
```bash
flutter build apk --debug
# 或
flutter run --debug -d [DEVICE_ID]
```

### 3. 检查资源文件
确保以下文件存在且格式正确：
- `android/app/src/main/res/drawable/ic_mark_read.xml`
- `android/app/src/main/res/drawable/ic_reply.xml`

## 预防措施

### 1. 使用标准颜色
在Android资源文件中优先使用：
- `@android:color/white`
- `@android:color/black`
- `@android:color/transparent`

### 2. 避免主题属性
除非确定主题中定义了相应属性，否则避免使用：
- `?attr/colorPrimary`
- `?attr/colorOnSurface`
- `?attr/colorSecondary`

### 3. 测试不同Android版本
确保资源文件在不同Android版本上都能正常编译。

## 故障排除

### 如果仍有构建错误：

1. **检查其他drawable文件**
   ```bash
   find android/app/src/main/res/drawable* -name "*.xml" -exec grep -l "attr/" {} \;
   ```

2. **检查values文件**
   ```bash
   find android/app/src/main/res/values* -name "*.xml" -exec grep -l "attr/" {} \;
   ```

3. **完全重新生成资源**
   ```bash
   rm -rf android/app/src/main/res/drawable/ic_*.xml
   flutter clean
   flutter pub get
   ```

4. **查看完整错误日志**
   ```bash
   flutter run --verbose --debug
   ```

## 成功指标

修复成功后应该看到：
- ✅ Android构建无错误
- ✅ 应用正常启动
- ✅ 通知功能正常工作
- ✅ 通知动作按钮显示正确

修复完成后，通知系统应该能够正常工作，包括系统通知和应用内通知功能。