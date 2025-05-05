# 全局UI通知系统使用指南

## 介绍

这个通知系统可以避免在Flutter应用中常见的"`Don't use 'BuildContext's across async gaps`"警告，并提供一种统一的方式来显示各种类型的通知，如错误、成功、警告等。

## 核心组件

1. `UINotificationService` - 核心服务，管理全局ScaffoldMessenger
2. `UINotificationHelper` - 辅助工具类，提供便捷方法和异步操作封装

## 基本用法

### 1. 直接使用UINotificationService

```dart
// 显示错误消息
UINotificationService.instance.showError('操作失败');

// 显示成功消息
UINotificationService.instance.showSuccess('操作成功');

// 显示警告消息
UINotificationService.instance.showWarning('请注意');

// 显示普通消息
UINotificationService.instance.showMessage('普通消息');

// 显示处理中消息
UINotificationService.instance.showProcessing('处理中...');
```

### 2. 使用UINotificationHelper（推荐）

```dart
// 显示错误消息
UINotificationHelper.showError('操作失败');

// 显示成功消息
UINotificationHelper.showSuccess('操作成功');

// 显示警告消息
UINotificationHelper.showWarning('请注意');

// 显示普通消息
UINotificationHelper.showMessage('普通消息');

// 显示处理中消息
UINotificationHelper.showProcessing('处理中...');
```

## 异步操作中的使用

### 常规异步操作

```dart
Future<void> someAsyncOperation() async {
  try {
    UINotificationHelper.showProcessing('处理中...');
    await Future.delayed(Duration(seconds: 2)); // 模拟异步操作
    UINotificationHelper.showSuccess('操作成功');
  } catch (e) {
    UINotificationHelper.showError('操作失败: $e');
  }
}
```

### 使用wrapWithNotification（最佳实践）

```dart
Future<void> loadData() async {
  final result = await UINotificationHelper.wrapWithNotification<List<Data>>(
    action: () => dataRepository.fetchData(),  // 您的异步操作
    loadingMessage: '加载数据中...',
    successMessage: '数据加载成功',
    errorMessage: '数据加载失败',
  );
  
  if (result != null) {
    // 处理结果
  }
}
```

## 避免常见问题

1. **不要在异步操作后使用BuildContext**
   ```dart
   // 错误示例
   Future<void> badExample(BuildContext context) async {
     try {
       await someAsyncOperation();
       ScaffoldMessenger.of(context).showSnackBar(...); // 错误!
     } catch (e) {
       // ...
     }
   }
   
   // 正确示例
   Future<void> goodExample() async {
     try {
       await someAsyncOperation();
       UINotificationHelper.showSuccess('成功');
     } catch (e) {
       UINotificationHelper.showError('失败: $e');
     }
   }
   ```

2. **使用mounted检查是不够的**
   ```dart
   // 不推荐示例 (虽然可行但不优雅)
   Future<void> notRecommended(BuildContext context) async {
     try {
       await someAsyncOperation();
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(...);
       }
     } catch (e) {
       // ...
     }
   }
   
   // 推荐示例
   Future<void> recommended() async {
     try {
       await someAsyncOperation();
       UINotificationHelper.showSuccess('成功');
     } catch (e) {
       UINotificationHelper.showError('失败: $e');
     }
   }
   ```

## 高级用法

### 多消息栈管理

```dart
// 清除当前显示的消息
UINotificationService.instance.hideCurrentMessage();

// 清除所有排队的消息
UINotificationService.instance.clearAllMessages();

// 在错误处理时强制清除所有消息
await UINotificationHelper.wrapWithNotification(
  action: () => someComplexOperation(),
  shouldForceCleanupOnError: true,
);
```

## 结论

使用全局UI通知系统可以使代码更加清晰，避免常见的Flutter异步上下文问题，同时提供统一的用户体验。推荐在所有异步操作中使用`UINotificationHelper`来处理消息通知。 