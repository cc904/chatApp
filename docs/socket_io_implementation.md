# Socket.IO实现详解

本文档详细介绍CC WhatsApp克隆项目中的Socket.IO实时通信实现方案。

## 1. 架构概述

项目使用分层架构实现Socket.IO通信：

```
┌─────────────────────┐
│    UI层 (Widget)    │
└──────────┬──────────┘
           │
┌──────────▼──────────┐
│ 状态管理层 (Cubit)   │
└──────────┬──────────┘
           │
┌──────────▼──────────┐
│  仓库层 (Repository) │
└──────────┬──────────┘
           │
┌──────────▼──────────┐
│  服务层 (Service)    │
└──────────┬──────────┘
           │
┌──────────▼──────────┐
│   Socket.IO客户端    │
└─────────────────────┘
```

## 2. 核心实现类

### 2.1 SocketService

`SocketService`是实时通信的核心，它封装了Socket.IO客户端的所有交互。

#### 2.1.1 主要功能

- Socket连接的建立与管理
- 事件的发送与监听
- 数据编码方式的处理
- 连接状态的管理
- 模拟模式支持

#### 2.1.2 实现细节

**单例模式**
```dart
// 单例模式
static final SocketService _instance = SocketService._internal();

factory SocketService() {
  return _instance;
}

static SocketService getInstance() {
  return _instance;
}

SocketService._internal();
```

**初始化方法**
```dart
Future<bool> init({
  required String serverUrl,
  required String authToken,
  DataEncoding encoding = DataEncoding.json,
  bool simulationMode = false,
}) async {
  // 根据simulationMode决定是否启用模拟模式
  // 如果非模拟模式，则创建真实Socket连接
  // 设置必要的头信息，如认证令牌、内容类型和编码方式
}
```

**事件处理**
```dart
Stream<dynamic> on(SocketEvent event) {
  // 返回特定事件的流
}

bool emit(String event, dynamic data) {
  // 发送事件到服务器
  // 如果是模拟模式，则模拟发送
}
```

**模拟模式**
```dart
void setSimulationMode(bool enabled) {
  // 切换模拟模式状态
  // 若开启模拟模式，则建立模拟连接
}

void _setupSimulationEventControllers() {
  // 设置模拟事件控制器
  // 为主要的事件类型创建流控制器
}
```

### 2.2 ChatRepository实现

`ChatRepositoryImpl`类整合了Socket通信与本地数据库：

```dart
class ChatRepositoryImpl implements ChatRepository {
  final SocketService _socketService = SocketService.getInstance();
  // 其他依赖...
  
  // Socket订阅集合
  final List<StreamSubscription> _socketSubscriptions = [];
  
  // 状态流控制器
  final _onlineStatusController = StreamController<Set<String>>.broadcast();
  final _typingStatusController = StreamController<Map<String, String>>.broadcast();
  final _messageStatusController = StreamController<MessageStatusUpdate>.broadcast();
  final _syncStatusController = StreamController<SyncStatus>.broadcast();
  
  @override
  Future<bool> initRealTimeConnection(
    String userId,
    String token,
    String serverUrl,
    DataEncoding encoding,
    bool simulationMode,
  ) async {
    // 初始化Socket连接
    // 设置事件监听器
    // 发送上线状态
    _setupSocketEventListeners();
    return true;
  }
  
  void _setupSocketEventListeners() {
    // 设置各种事件的监听器
    // 如连接事件、用户状态事件、消息事件等
  }
  
  @override
  void sendTypingStatus(String conversationId, bool isTyping) {
    // 发送输入状态
    if (isTyping) {
      _socketService.sendTyping(conversationId);
    } else {
      _socketService.sendStopTyping(conversationId);
    }
  }
  
  // 其他方法...
}
```

## 3. 数据编码方式

项目支持三种数据编码方式，定义在`types.dart`中：

```dart
enum DataEncoding {
  json,     // 传统JSON编码
  protobuf, // Protobuf二进制编码
  base64,   // Base64编码的Protobuf (兼容性更好)
}
```

### 3.1 编码选择

编码方式可以在初始化Socket连接时指定：

```dart
// 使用Protobuf二进制格式
await socketService.init(
  serverUrl: 'ws://api.example.com',
  authToken: 'user-auth-token',
  encoding: DataEncoding.protobuf,
);

// 使用JSON格式（默认）
await socketService.init(
  serverUrl: 'ws://api.example.com',
  authToken: 'user-auth-token',
);
```

## 4. 模拟模式

模拟模式是应用开发和测试的重要功能，它可以在没有实际后端服务的情况下模拟Socket事件。

### 4.1 开启模拟模式

```dart
// 初始化时开启
await socketService.init(
  serverUrl: 'http://localhost:3000',
  authToken: 'fake-token',
  simulationMode: true
);

// 或动态切换
socketService.setSimulationMode(true);
```

### 4.2 模拟行为

模拟模式会自动模拟以下行为：
- 连接和断开连接事件
- 消息发送响应和状态更新
- 用户在线状态变化
- 输入状态变化

## 5. 事件流处理

项目使用Dart的Stream进行事件流处理，每种事件都有对应的StreamController：

```dart
// SocketService中
final Map<SocketEvent, StreamController<dynamic>> _eventControllers = {};

Stream<dynamic> on(SocketEvent event) {
  if (!_eventControllers.containsKey(event)) {
    _eventControllers[event] = StreamController<dynamic>.broadcast();
  }
  return _eventControllers[event]!.stream;
}

// 在Repository层
final _onlineStatusController = StreamController<Set<String>>.broadcast();
Stream<Set<String>> getOnlineStatusStream() => _onlineStatusController.stream;
```

## 6. 认证与Socket连接的集成

认证成功后，会自动建立Socket连接：

```dart
// AuthCubit中
Future<void> _initRealTimeCommunication(String userId, String token) async {
  try {
    // 获取连接信息
    final connectionInfo = _authService.getConnectionInfo();
    
    // 初始化实时连接
    final success = await _chatRepository.initRealTimeConnection(
      userId,
      token,
      connectionInfo['serverUrl'],
      connectionInfo['dataEncoding'],
      connectionInfo['simulationMode'],
    );
    
    // 初始化聊天订阅
    if (success && _chatCubit != null) {
      await _chatCubit.initializeSubscriptions();
    }
  } catch (e) {
    _logger.e('初始化实时通信错误', error: e);
  }
}
```

## 7. 聊天状态与Socket事件的结合

在`ChatCubit`中，通过订阅Socket事件流来更新UI状态：

```dart
Future<void> initializeSubscriptions() async {
  // 订阅在线状态流
  _onlineStatusSubscription = _chatRepository.getOnlineStatusStream().listen((onlineUsers) {
    emit(state.copyWith(onlineUsers: onlineUsers));
  });
  
  // 订阅输入状态流
  _typingStatusSubscription = _chatRepository.getTypingStatusStream().listen((typingMap) {
    emit(state.copyWith(typingUsers: typingMap));
  });
  
  // 订阅消息状态流
  _messageStatusSubscription = _chatRepository.getMessageStatusStream().listen((update) {
    _updateMessageStatus(update.messageId, update.status);
  });
  
  // 订阅同步状态流
  _syncStatusSubscription = _chatRepository.getSyncStatusStream().listen((status) {
    emit(state.copyWith(syncStatus: status));
  });
}
```

## 8. 错误处理与重连机制

SocketService实现了完善的错误处理和重连机制：

```dart
// 设置重连选项
_socket = io.io(
  serverUrl,
  io.OptionBuilder()
      // 其他选项...
      .setReconnectionAttempts(maxReconnectAttempts)
      .setReconnectionDelay(1000) // 1秒后尝试重连
      .setReconnectionDelayMax(5000) // 最大5秒的重连延迟
      .enableReconnection()
      .build(),
);

// 监听连接错误
_socket!.onConnectError((error) {
  _logger.e('Socket连接错误', error: error);
  _isConnected = false;
  _emitEvent(SocketEvent.connectError, error);
});
```

## 9. 最佳实践

### 9.1 单例模式

所有与Socket相关的服务都使用单例模式，确保全局只有一个连接实例。

### 9.2 分层设计

- UI层只与Cubit交互
- Cubit只与Repository交互
- Repository负责整合Socket服务与数据库

### 9.3 流式编程

使用Dart的Stream和StreamController实现事件驱动编程，使代码更简洁、更响应式。

## 10. 调试技巧

### 10.1 日志记录

项目使用`LogService`记录Socket通信的详细日志：

```dart
_logger.i('发送事件', extra: {'event': event, 'data': data});
_logger.e('Socket连接错误', error: error);
```

### 10.2 模拟模式快速切换

开发过程中可随时切换模拟模式，无需真实服务器：

```dart
// 启用/禁用模拟模式
socketService.setSimulationMode(!socketService.isSimulationMode);
```

## 11. 未来拓展

### 11.1 端到端加密

计划实现端到端加密，确保消息在传输过程中的安全。

### 11.2 消息同步优化

完善离线消息同步机制，确保消息不丢失。

### 11.3 语音和视频通话

通过WebRTC与Socket.IO结合，实现实时语音和视频通话功能。 