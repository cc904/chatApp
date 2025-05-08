# Protobuf通信实现

本文档描述了项目中使用Protocol Buffers (protobuf)作为唯一的数据序列化格式的实现。

## 概述

为了提高应用的性能、减小数据包大小，并使通信更加规范化，我们决定将所有Socket.io通信标准化为仅使用Protocol Buffers序列化格式。这次重构移除了之前支持的多种编码方式（JSON、Base64），简化了通信逻辑，使代码更加清晰和易于维护。

## 主要组件

### 1. ProtoConverter

`ProtoConverter`类负责处理protobuf数据的序列化和反序列化，包括：

- 将Map数据编码为二进制protobuf格式
- 将二进制protobuf数据解码为Map格式
- 支持多种消息类型的转换（消息、会话等）

主要方法：
- `encodeData(Map<String, dynamic> data, String eventType)`: 根据事件类型，将Map数据编码为protobuf二进制数据
- `decodeData(Uint8List data, String eventType)`: 根据事件类型，将protobuf二进制数据解码为Map数据

### 2. CommunicationService

`CommunicationService`类负责与服务器进行Socket.io通信，提供统一的接口用于发送和接收事件，现在它只使用protobuf作为数据序列化格式。

主要特性：
- 统一的事件发送接口
- 基于Stream的事件订阅机制
- 连接状态管理
- 自动重连机制

主要方法：
- `connect()`: 连接到服务器
- `disconnect()`: 断开连接
- `emitEvent(String eventName, Map<String, dynamic> data)`: 发送事件
- `onEvent(String eventName)`: 订阅事件流

## Protobuf消息定义

所有的protobuf消息类型都定义在`lib/core/proto/source`目录中，生成的Dart代码位于`lib/core/proto/generated`目录。主要的消息类型包括：

- `MessageProto`: 聊天消息
- `ConversationProto`: 会话信息
- `UserSession`: 用户会话信息（待完成标准化）
- `AuthRequest`/`AuthResponse`: 认证请求/响应（待完成标准化）

## 技术实现细节

### 1. 序列化流程

前端发送数据到服务器时：
1. 应用层构造Map结构的事件数据
2. 通过`ProtoConverter.encodeData()`转换为protobuf二进制数据
3. 通过Socket.io发送二进制数据包

接收服务器数据时：
1. 接收Socket.io二进制数据包
2. 通过`ProtoConverter.decodeData()`转换为Map结构
3. 分发到对应的Stream流，供应用层使用

### 2. 事件处理

使用Stream机制处理各类事件，确保松耦合：
- 每种事件类型都有独立的StreamController
- 应用层可以单独订阅感兴趣的事件
- 断开连接时，所有Stream会收到通知

## 兼容性和迁移

目前，部分消息类型的protobuf定义尚未完全标准化，包括：
- `AuthRequest`/`AuthResponse`
- `UserSession`
- `UserStatus`

这些类型在未来的迭代中需要完成标准化。为了保持兼容性，当使用这些未完全支持的类型时，系统会记录警告并抛出适当的异常。

## 优势

采用protobuf作为唯一序列化格式的主要优势：

1. **性能提升**：相比JSON，protobuf序列化和反序列化更快，数据包更小
2. **强类型**：消息结构定义清晰，减少运行时错误
3. **向前/向后兼容性**：可以安全地更新消息定义
4. **跨语言支持**：服务端可以使用任何支持protobuf的语言
5. **代码简化**：移除了多种编码方式的支持，使代码更加清晰

## 未来计划

1. 完成所有消息类型的protobuf标准化
2. 改进错误处理机制
3. 添加消息压缩功能
4. 实现二进制数据的缓存机制，减少重复序列化 