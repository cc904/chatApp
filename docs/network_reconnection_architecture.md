# 网络重连逻辑架构文档

## 概述

当前项目实现了多层次的网络重连机制，包括Socket.io层面的自动重连、应用层面的网络状态监控，以及用户界面的重连反馈。整个重连逻辑分为以下几个层次：

## 架构层次

```
UI层 (重连指示器、状态显示)
    ↓
业务逻辑层 (HomeCubit、ChatsCubit)
    ↓
通信服务层 (CommunicationService)
    ↓
Socket服务层 (ProtoSocketService)
    ↓
网络监控层 (Connectivity + Socket.io)
```

## 1. 核心服务层 - ProtoSocketService

### 重连配置
```dart
static const int _maxReconnectAttempts = 5;        // 最大重连次数
static const Duration _reconnectInterval = Duration(seconds: 3);  // 重连间隔
```

### 连接状态枚举
```dart
enum SocketConnectionStatus {
  disconnected,  // 已断开
  connecting,    // 连接中
  connected,     // 已连接
  reconnecting,  // 重连中
  error         // 连接错误
}
```

### 重连机制实现

#### 1.1 自动重连触发
- **断开连接时**: `onDisconnect` 事件触发 `_attemptReconnect()`
- **连接错误时**: `onError` 事件触发 `_attemptReconnect()`
- **手动重连**: 外部调用 `_attemptReconnect()`

#### 1.2 重连逻辑流程
```
断开连接/错误 → 检查重连条件 → 设置重连状态 → 尝试重连 → 成功/失败处理
```

#### 1.3 重连状态管理
- `_isReconnecting`: 防止重复重连
- `_reconnectAttempts`: 记录重连次数
- `_reconnectTimer`: 定时器控制重连间隔

#### 1.4 Socket.io内置重连
```dart
'reconnection': true,
'reconnectionAttempts': 10,
'reconnectionDelay': 3000,
```

### 状态流控制
- `connectionStateStream`: 连接状态变化流
- `reconnectingStateStream`: 重连状态流

## 2. 通信服务层 - CommunicationService

### 职责
- 封装ProtoSocketService，提供统一的通信接口
- 暴露连接状态和重连状态流
- 简化上层调用

### 关键接口
```dart
Stream<SocketConnectionStatus> get connectionStateStream
Stream<bool> get isConnectedStream  
Stream<bool> get reconnectingStateStream
```

## 3. 网络监控层 - HomeCubit

### 网络状态监控
使用 `connectivity_plus` 包监控设备网络状态：

#### 3.1 网络状态枚举
```dart
enum NetworkStatus {
  connected,    // 已连接
  connecting,   // 连接中  
  disconnected, // 已断开
  error        // 连接错误
}
```

#### 3.2 监控实现
- **初始化**: `_initNetworkMonitoring()` 检查当前网络状态
- **状态监听**: 监听 `connectivity.onConnectivityChanged`
- **状态更新**: `_updateNetworkStatus()` 更新网络状态

#### 3.3 重连方法
```dart
Future<void> reconnect() async {
  await checkNetworkConnection();
}
```

### 网络类型支持
- WiFi: `ConnectivityResult.wifi`
- 移动网络: `ConnectivityResult.mobile`  
- 以太网: `ConnectivityResult.ethernet`
- 无网络: `ConnectivityResult.none`

## 4. 会话管理层 - ChatsCubit

### 重连逻辑
```dart
Future<void> reconnect() async {
  // 1. 更新状态为连接中
  emit(state.copyWith(
    networkStatus: ChatsState.kNetworkStatusConnecting,
    isConnected: false,
  ));

  // 2. TODO: 实现实际的重连逻辑
  
  // 3. 连接成功后更新状态
  emit(state.copyWith(
    networkStatus: ChatsState.kNetworkStatusConnected,
    isConnected: true,
    lastConnectionTime: DateTime.now(),
  ));

  // 4. 重新加载会话列表
  await loadConversations();
}
```

### 状态管理
- `networkStatus`: 网络连接状态
- `isConnected`: 是否已连接
- `lastConnectionTime`: 最后连接时间
- `connectionErrorMessage`: 连接错误信息

## 5. UI层重连反馈

### 5.1 重连覆盖层 - ReconnectingOverlay
```dart
class ReconnectingOverlay extends StatelessWidget {
  // 监听重连状态流
  stream: _communicationService.reconnectingStateStream
  
  // 显示重连进度指示器
  // 位置：应用顶部覆盖层
  // 样式：橙色背景 + 加载指示器 + "正在重新连接..."
}
```

### 5.2 网络状态指示器 - NetworkStatusIndicator
```dart
class NetworkStatusIndicator extends StatelessWidget {
  // 根据网络状态显示不同的图标和文字
  // 提供重试按钮
  // 支持AppBar简洁模式和页面完整模式
}
```

### 5.3 AppBar标题状态 - AppBarTitleWithNetworkStatus
```dart
class AppBarTitleWithNetworkStatus extends StatelessWidget {
  // 在AppBar标题中集成网络状态显示
  // 支持加载指示器
  // 非连接状态下显示网络状态
}
```

## 6. 重连流程详解

### 6.1 完整重连流程
```
网络断开检测
    ↓
ProtoSocketService检测到断开
    ↓
触发_attemptReconnect()
    ↓
更新状态为reconnecting
    ↓
发送重连状态到UI层
    ↓
UI显示"正在重新连接..."
    ↓
尝试重新连接Socket
    ↓
连接成功/失败处理
    ↓
更新最终状态
    ↓
UI更新显示
```

### 6.2 多层防护机制
1. **Socket.io内置重连**: 底层自动重连机制
2. **应用层重连**: ProtoSocketService的重连逻辑
3. **网络状态监控**: 设备网络状态变化监听
4. **手动重连**: 用户主动触发重连

### 6.3 重连策略
- **指数退避**: 每次重连间隔3秒
- **最大次数限制**: 最多重连5次
- **状态同步**: 多层状态保持一致
- **用户反馈**: 实时显示重连状态

## 7. 状态同步机制

### 7.1 状态流向
```
ProtoSocketService (Socket状态)
    ↓
CommunicationService (封装状态)
    ↓
HomeCubit (网络状态) + ChatsCubit (会话状态)
    ↓
UI组件 (状态显示)
```

### 7.2 状态一致性
- **单一数据源**: ProtoSocketService作为连接状态的权威来源
- **流式更新**: 通过Stream确保状态实时同步
- **分层管理**: 不同层次管理不同粒度的状态

## 8. 错误处理机制

### 8.1 连接错误类型
- **网络不可达**: 设备无网络连接
- **服务器不可达**: 服务器宕机或网络问题
- **认证失败**: Token过期或无效
- **协议错误**: Socket.io协议层面的错误

### 8.2 错误恢复策略
- **自动重连**: 网络恢复后自动重连
- **手动重连**: 用户主动触发重连
- **状态重置**: 重连成功后重置错误状态
- **数据同步**: 重连后重新同步数据

## 9. 性能优化

### 9.1 重连优化
- **避免重复重连**: `_isReconnecting` 标志防止并发重连
- **合理间隔**: 3秒间隔避免频繁重连
- **次数限制**: 5次上限避免无限重连
- **资源清理**: 及时清理定时器和监听器

### 9.2 状态更新优化
- **流式更新**: 使用Stream避免轮询
- **状态缓存**: 避免重复的状态计算
- **UI优化**: 只在状态真正变化时更新UI

## 10. 待优化项

### 10.1 ChatsCubit重连逻辑
当前ChatsCubit的`reconnect()`方法标记为TODO，需要实现：
```dart
// TODO 实现实际的重连逻辑，可能需要调用repository中的方法
```

**建议实现**:
```dart
Future<void> reconnect() async {
  try {
    // 1. 更新状态为连接中
    emit(state.copyWith(
      networkStatus: ChatsState.kNetworkStatusConnecting,
      isConnected: false,
    ));

    // 2. 调用通信服务重连
    final communicationService = CommunicationService();
    final success = await communicationService.reconnect();

    if (success) {
      // 3. 连接成功，更新状态
      emit(state.copyWith(
        networkStatus: ChatsState.kNetworkStatusConnected,
        isConnected: true,
        lastConnectionTime: DateTime.now(),
        connectionErrorMessage: null,
      ));

      // 4. 重新同步数据
      await requestSyncConversations();
    } else {
      // 5. 连接失败，更新错误状态
      emit(state.copyWith(
        networkStatus: ChatsState.kNetworkStatusError,
        isConnected: false,
        connectionErrorMessage: '重连失败',
      ));
    }
  } catch (error) {
    emit(state.copyWith(
      networkStatus: ChatsState.kNetworkStatusError,
      isConnected: false,
      connectionErrorMessage: '连接失败: ${error.toString()}',
    ));
  }
}
```

### 10.2 CommunicationService重连接口
需要在CommunicationService中添加重连方法：
```dart
Future<bool> reconnect() async {
  return await _socketService.reconnect();
}
```

### 10.3 数据同步策略
重连成功后需要考虑数据同步：
- **消息同步**: 同步离线期间的消息
- **会话状态同步**: 同步会话列表变化
- **用户状态同步**: 同步在线状态等

## 11. 总结

当前项目的网络重连逻辑已经具备了完整的框架：

### 优势
- ✅ **多层次重连**: Socket.io + 应用层双重保障
- ✅ **实时状态反馈**: 完整的UI状态指示
- ✅ **网络状态监控**: 设备网络状态感知
- ✅ **用户体验**: 重连过程可视化

### 待完善
- ⚠️ **ChatsCubit重连逻辑**: 需要实现具体的重连逻辑
- ⚠️ **数据同步策略**: 重连后的数据同步机制
- ⚠️ **错误分类处理**: 不同错误类型的差异化处理
- ⚠️ **重连策略优化**: 可考虑指数退避等高级策略

整体而言，当前的重连架构设计合理，具备良好的扩展性和维护性，只需要完善部分实现细节即可达到生产环境的要求。 