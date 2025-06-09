# 发送消息逻辑整理

## 概述

本文档整理了Flutter WhatsApp克隆项目中的发送消息逻辑，包括架构设计、数据流、错误处理和用户体验优化。

## 架构设计

### 分层架构
```
UI层 (ChatPage) 
    ↓
业务逻辑层 (ChatCubit)
    ↓
服务层 (MessageSendService) [新增]
    ↓
数据层 (ChatRepository)
    ↓
通信层 (Socket.io + Proto)
```

### 核心组件

1. **ChatPage** - UI层，处理用户输入和显示
2. **ChatCubit** - 状态管理，协调业务逻辑
3. **MessageSendService** - 发送服务，统一发送逻辑
4. **ChatRepository** - 数据仓库，处理数据持久化和网络通信

## 发送流程

### 1. 用户交互层 (ChatPage)

```dart
void _sendMessage() {
  final text = _textController.text.trim();
  
  // 验证输入
  if (text.isEmpty) return;
  if (text.length > 4000) {
    // 显示错误提示
    return;
  }
  
  // 发送消息
  try {
    context.read<ChatCubit>().sendTextMessage(text);
    _textController.clear();
    FocusScope.of(context).unfocus();
    HapticFeedback.lightImpact();
  } catch (error) {
    // 显示错误提示和重试选项
  }
}
```

**特性：**
- 输入验证（空值、长度限制）
- 用户体验优化（清空输入框、收起键盘、震动反馈）
- 错误处理和重试机制

### 2. 业务逻辑层 (ChatCubit)

```dart
Future<void> sendTextMessage(String text) async {
  // 1. 验证输入
  if (text.trim().isEmpty) return;
  
  // 2. 设置发送状态
  _setLoadingState(true);
  
  // 3. 创建临时消息
  tempMessage = await _createTempMessage(text.trim());
  
  // 4. 立即更新UI显示（乐观更新）
  await _addMessageToUI(tempMessage);
  
  // 5. 异步发送消息到服务器
  _sendMessageToServerAsync(tempMessage);
}
```

**特性：**
- 乐观更新：立即显示消息，后台发送
- 异步处理：不阻塞UI
- 状态管理：发送状态指示
- 错误恢复：失败时可重试

### 3. 服务层 (MessageSendService)

```dart
Future<Message> sendTextMessage({
  required ChatRepository repository,
  required String conversationId,
  required String text,
  // 回调函数
}) async {
  // 1. 验证输入
  final validatedText = _validateText(text);
  
  // 2. 创建临时消息
  final message = await repository.createTempMessage(...);
  
  // 3. 发送到服务器
  await repository.sendMessageWithTimeout(message);
  
  return message;
}
```

**特性：**
- 统一验证逻辑
- 回调机制支持
- 错误处理标准化
- 可复用的发送逻辑

### 4. 数据层 (ChatRepository)

```dart
Future<void> sendMessageWithTimeout(Message message) async {
  // 1. 更新消息状态为发送中
  await _updateMessageStatus(message, 'sending');
  
  // 2. 转换为Proto格式
  final protoMsg = message.toProto();
  
  // 3. 通过Socket.io发送
  _communicationService.emitProto('message:send', protoMsg);
  
  // 4. 启动超时计时器
  Timer(timeout, () async {
    // 检查并处理超时
  });
}
```

**特性：**
- 数据持久化
- 网络通信
- 超时处理
- 状态同步

## 消息状态管理

### 状态流转

```
创建 → sending → sent → delivered → read
  ↓       ↓
  ↓    failed
  ↓       ↓
  ↓    resend
  ↓       ↓
  ↓    sending
```

### 状态说明

- **sending**: 正在发送中
- **sent**: 已发送到服务器
- **delivered**: 已送达对方设备
- **read**: 对方已读
- **failed**: 发送失败

## 错误处理机制

### 1. 输入验证错误
- 空消息：静默忽略
- 消息过长：显示提示信息

### 2. 网络错误
- 连接失败：标记为失败，提供重试
- 超时：5秒超时，自动标记失败
- 服务器错误：显示具体错误信息

### 3. 重试机制
```dart
Future<void> resendMessage(String messageId) async {
  // 1. 验证消息状态
  // 2. 重置为发送中
  // 3. 重新发送
  // 4. 处理结果
}
```

## 用户体验优化

### 1. 乐观更新
- 消息立即显示在UI中
- 后台异步发送
- 失败时显示错误状态

### 2. 视觉反馈
- 发送状态指示器
- 消息状态图标
- 错误提示信息

### 3. 交互优化
- 震动反馈
- 自动收起键盘
- 清空输入框

### 4. 错误恢复
- 失败消息可重试
- 重试按钮
- 错误信息显示

## 性能优化

### 1. 异步处理
- 不阻塞UI线程
- 后台发送消息
- 批量状态更新

### 2. 内存管理
- 及时清理临时数据
- 避免内存泄漏
- 合理的超时设置

### 3. 网络优化
- 合理的超时时间（5秒）
- 失败重试机制
- 连接状态检查

## 测试策略

### 1. 单元测试
- 消息验证逻辑
- 状态转换逻辑
- 错误处理逻辑

### 2. 集成测试
- 端到端发送流程
- 网络异常处理
- 状态同步测试

### 3. UI测试
- 用户交互流程
- 错误提示显示
- 重试功能测试

## 未来改进

### 1. 功能增强
- 消息草稿保存
- 离线消息队列
- 消息加密

### 2. 性能优化
- 消息压缩
- 批量发送
- 智能重试

### 3. 用户体验
- 发送进度显示
- 更丰富的状态反馈
- 自定义重试策略

## 总结

整理后的发送消息逻辑具有以下特点：

1. **清晰的分层架构**：职责分离，易于维护
2. **完善的错误处理**：多层次错误处理和恢复机制
3. **优秀的用户体验**：乐观更新、即时反馈、错误恢复
4. **高性能设计**：异步处理、内存优化、网络优化
5. **可扩展性**：模块化设计，易于扩展新功能

这个设计为后续的功能扩展（如多媒体消息、消息加密等）奠定了良好的基础。 