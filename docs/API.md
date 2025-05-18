# API 文档

## HomeCubit

### 方法

#### logout
```dart
Future<void> logout() async
```
处理用户退出登录流程：
1. 断开 Socket 连接
2. 清除所有联系人数据
3. 重置状态

## ContactService

### 方法

#### clearContacts
```dart
Future<void> clearContacts() async
```
清除数据库中的所有联系人数据。

## UINotificationService

### 方法

#### showNotification
```dart
void showNotification(
  String title,
  String body, {
  required Duration duration,
})
```
显示通知消息：
- `title`: 通知标题
- `body`: 通知内容
- `duration`: 显示时长 