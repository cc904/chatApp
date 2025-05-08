# Socket.IO实际使用示例

本文档通过一个完整的消息发送流程，展示Socket.IO在CC WhatsApp克隆项目中的实际应用案例。

## 私聊消息发送流程

### 1. 用户在UI界面发送消息

用户在聊天界面输入消息并点击发送按钮，触发以下代码：

```dart
// 用户在ChatScreen点击发送按钮
onSendPressed() {
  final message = textEditingController.text;
  chatCubit.sendTextMessage(
    conversationId: widget.conversationId,
    text: message,
  );
  textEditingController.clear();
}
```

### 2. ChatCubit处理消息

状态管理层负责处理消息的发送逻辑：

```dart
Future<void> sendTextMessage({
  required String conversationId,
  required String text,
}) async {
  // 创建本地消息对象
  final message = Message(
    messageId: generateUniqueId(),
    conversationId: conversationId,
    senderId: _currentUserId,
    content: text,
    type: 'text',
    status: 'sending',
    createdAt: DateTime.now(),
  );
  
  // 先存储到本地数据库并更新UI
  await _chatRepository.saveMessage(message);
  
  // 通过Socket.IO发送到服务器
  await _chatRepository.sendMessage(message);
}
```

### 3. Repository层调用Socket服务

仓库层负责与Socket服务交互：

```dart
Future<bool> sendMessage(Message message) async {
  try {
    // 转换为网络传输格式
    final messageData = {
      'messageId': message.messageId,
      'conversationId': message.conversationId,
      'senderId': message.senderId,
      'content': message.content,
      'type': message.type,
      'createdAt': message.createdAt.millisecondsSinceEpoch,
    };
    
    // 通过Socket.IO发送
    _socketService.sendMessage(messageData);
    
    // 更新本地消息状态为"已发送"
    await _updateMessageStatus(message, 'sent');
    return true;
  } catch (e) {
    _logger.e('发送消息失败', error: e);
    // 更新本地消息状态为"发送失败"
    await _updateMessageStatus(message, 'failed');
    return false;
  }
}
```

### 4. SocketService发送消息到服务器

Socket服务负责实际的消息发送：

```dart
void sendMessage(Map<String, dynamic> message) {
  if (!_isConnected) {
    _logger.w('Socket未连接，无法发送消息');
    return;
  }
  
  try {
    // 使用Socket.IO的emit方法发送new_message事件
    emit('new_message', message);
    _logger.i('消息已发送', extra: {'messageId': message['messageId']});
  } catch (e) {
    _logger.e('发送消息出错', error: e);
  }
}
```

### 5. 接收消息确认

Repository层监听Socket事件：

```dart
// 在ChatRepositoryImpl中设置事件监听
void _setupSocketEventListeners() {
  // ...其他事件监听
  
  // 监听消息已送达事件
  _socketSubscriptions.add(_socketService.on(SocketEvent.messageDelivered).listen((data) {
    _logger.i('消息已送达', extra: {'data': data});
    _handleMessageStatus(data, 'delivered');
  }));
  
  // 监听消息已读事件
  _socketSubscriptions.add(_socketService.on(SocketEvent.messageRead).listen((data) {
    _logger.i('消息已读', extra: {'data': data});
    _handleMessageStatus(data, 'read');
  }));
}

// 处理消息状态变更
Future<void> _handleMessageStatus(Map<String, dynamic> data, String status) async {
  try {
    final messageId = data['messageId'] as String?;
    if (messageId == null) return;
    
    // 更新本地数据库中的消息状态
    final message = await _messages.filter().messageIdEqualTo(messageId).findFirst();
    if (message != null) {
      await _updateMessageStatus(message, status);
    }
  } catch (e) {
    _logger.e('处理消息状态变更失败', error: e);
  }
}
```

## 用户实时状态更新

### 1. 用户输入状态

```dart
// UI层监测用户输入并通知
void _onTypingChanged(bool isTyping) {
  if (_currentTypingStatus != isTyping) {
    _currentTypingStatus = isTyping;
    chatCubit.sendTypingStatus(widget.conversationId, isTyping);
  }
}

// ChatCubit转发
void sendTypingStatus(String conversationId, bool isTyping) {
  _chatRepository.sendTypingStatus(conversationId, isTyping);
}

// Repository实现
void sendTypingStatus(String conversationId, bool isTyping) {
  if (!_isSocketInitialized) {
    _logger.w('Socket未初始化，无法发送输入状态');
    return;
  }

  try {
    if (isTyping) {
      _socketService.sendTyping(conversationId);
    } else {
      _socketService.sendStopTyping(conversationId);
    }
  } catch (e) {
    _logger.e('发送输入状态失败', error: e);
  }
}
```

### 2. 在线状态更新

```dart
// 接收在线状态通知
_socketSubscriptions.add(_socketService.on(SocketEvent.userOnline).listen((data) {
  _logger.i('用户上线', extra: {'data': data});
  _handleUserOnlineStatus(data, true);
}));

// 处理状态并通知UI
void _handleUserOnlineStatus(Map<String, dynamic> data, bool isOnline) {
  try {
    final userId = data['userId'] as String?;
    if (userId == null) return;
    
    // 更新在线状态
    _onlineStatusController.add({
      'userId': userId,
      'isOnline': isOnline,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
    
    // 更新用户数据库记录
    _updateUserOnlineStatus(userId, isOnline);
  } catch (e) {
    _logger.e('处理用户在线状态失败', error: e);
  }
}
```

## Cubit接收状态更新并更新UI

```dart
// 在Cubit中订阅状态流
void initializeSubscriptions() {
  // 订阅在线状态流
  _onlineStatusSubscription = _chatRepository
      .getOnlineStatusStream()
      .listen((data) {
    final userId = data['userId'] as String;
    final isOnline = data['isOnline'] as bool;
    
    final updatedOnlineUsers = Set<String>.from(state.onlineUsers);
    if (isOnline) {
      updatedOnlineUsers.add(userId);
    } else {
      updatedOnlineUsers.remove(userId);
    }
    
    emit(state.copyWith(onlineUsers: updatedOnlineUsers));
  });
  
  // 订阅输入状态流
  _typingStatusSubscription = _chatRepository
      .getTypingStatusStream()
      .listen((data) {
    final updatedTypingUsers = Map<String, String>.from(state.typingUsers);
    final userId = data['userId'] as String;
    final conversationId = data['conversationId'] as String;
    final isTyping = data['isTyping'] as bool;
    
    if (isTyping) {
      updatedTypingUsers[userId] = conversationId;
    } else {
      updatedTypingUsers.remove(userId);
    }
    
    emit(state.copyWith(typingUsers: updatedTypingUsers));
  });
}
```

## Socket.IO与WebSocket的区别

在本项目中选择Socket.IO而非原生WebSocket的主要原因：

1. **自动重连机制**：Socket.IO内置了断线重连功能，无需手动实现
2. **命名空间和房间**：支持更灵活的消息分组方式
3. **降级支持**：在WebSocket不可用时可自动降级到其他传输方式
4. **事件驱动**：使用事件名称进行通信，而不是普通消息
5. **数据格式支持**：除了文本，还支持多种数据格式如JSON、二进制等

这些特性使得实时通信功能的实现更加简洁、健壮，特别是在移动网络环境中具有更好的稳定性。 