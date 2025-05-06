# CC - WhatsApp克隆项目概要

## 1. 项目简介
这是一个使用Flutter开发的WhatsApp克隆应用，实现了即时通讯的核心功能，包括用户认证、聊天、联系人管理和多媒体消息支持。项目采用了清晰的分层架构和模块化设计。

## 2. 技术栈

| 技术领域 | 使用的技术 |
|---------|-----------|
| **UI框架** | Flutter |
| **状态管理** | flutter_bloc (Cubit) |
| **本地数据库** | Isar |
| **测试框架** | integration_test |
| **实时通信** | socket_io_client（与Next.js后端通讯）|
| **数据序列化** | Protocol Buffers (protobuf) |

## 3. 项目结构

```
lib/
├── main.dart                 # 应用入口
├── core/                     # 核心服务和工具
│   ├── database/             # Isar数据库相关实现
│   ├── services/             # 各种服务实现
│   ├── proto/                # Protobuf生成代码
│   ├── adapters/             # 数据模型适配器
│   └── utils/                # 工具类
└── features/                 # 按功能模块划分
    ├── auth/                 # 认证相关
    ├── chat/                 # 聊天功能
    ├── contacts/             # 联系人管理
    └── home/                 # 主页面
```

## 4. 核心服务

| 服务名称 | 主要功能 |
|---------|---------|
| `MediaService` | 处理图片、视频、语音等多媒体文件的加载和播放 |
| `FileUploadService` | 管理文件的上传、下载和本地存储 |
| `ConversationService` | 创建和管理会话，包括私聊和群聊 |
| `MessageService` | 处理消息的发送、接收和存储 |
| `UserService` | 用户信息的管理和存储 |
| `SocketService` | 管理Socket.IO实时通信连接和事件处理 |
| `LogService` | 应用日志记录与管理 |
| `ProtoConverter` | 处理Protobuf与JSON/二进制数据的互相转换 |

## 5. 数据模型

| 模型名称 | 描述 | 主要字段 |
|---------|------|---------|
| `User` | 用户信息 | id, userId, name, avatar, phone, status, isFriend |
| `Conversation` | 会话 | id, conversationId, type, name, lastMessage, participants |
| `Message` | 消息 | id, messageId, conversationId, senderId, content, type, status, timestamp |

## 6. 功能模块详解

### 6.1 认证模块 (auth)

#### 6.1.1 目录结构
```
lib/features/auth/
├── presentation/
    ├── cubit/
    │   ├── auth_cubit.dart     # 认证状态管理
    │   └── auth_state.dart     # 认证状态定义
    └── pages/
        ├── auth_page.dart      # 登录页面
        ├── register_page.dart  # 注册页面
        └── forgot_password_page.dart  # 找回密码页面
```

#### 6.1.2 主要组件

**`auth_state.dart`**
- 定义认证流程中的各种状态：
  - `AuthInitial` - 初始状态
  - `AuthLoading` - 加载中状态
  - `AuthFormState` - 表单状态，包含手机号、验证码、密码等信息
  - `AuthVerificationCodeSent` - 验证码已发送状态
  - `AuthSuccess` - 认证成功状态
  - `AuthError` - 认证错误状态

**`auth_cubit.dart`**
- 管理认证相关的业务逻辑，主要方法：
  - `updatePhoneNumber()` - 更新手机号
  - `updateVerificationCode()` - 更新验证码
  - `updatePassword()` - 更新密码
  - `updateNickname()` - 更新昵称
  - `sendVerificationCode()` - 发送验证码
  - `login()` - 登录逻辑(支持验证码和密码两种方式)
  - `register()` - 注册逻辑
  - `resetPassword()` - 重置密码逻辑
  - `_initUserDatabase()` - 初始化用户数据库
  - `_saveUserInfoToDatabase()` - 保存用户信息到数据库
  - `_initRealTimeConnection()` - 初始化Socket.IO实时通信连接

**认证页面**
- `auth_page.dart` - 登录页面，包含手机号输入、验证码/密码输入和登录按钮
- `register_page.dart` - 注册页面，收集用户的手机号、验证码、密码和昵称
- `forgot_password_page.dart` - 忘记密码页面，支持通过验证码重置密码

### 6.2 聊天模块 (chat)

#### 6.2.1 目录结构
```
lib/features/chat/
├── data/
│   └── repositories/
│       └── chat_repository_impl.dart   # 聊天仓库实现
├── domain/
│   └── repositories/
│       └── chat_repository.dart        # 聊天仓库接口
└── presentation/
    ├── cubit/
    │   ├── chat_cubit.dart             # 聊天状态管理
    │   ├── chat_state.dart             # 聊天状态定义
    │   └── search_cubit.dart           # 搜索功能状态管理
    ├── pages/                          # 聊天相关页面
    ├── utils/                          # 工具类
    └── widgets/                        # 聊天相关组件
```

#### 6.2.2 主要组件

**`chat_repository.dart`**
- 定义聊天功能所需的接口：
  - 联系人管理：`getAllContacts()`, `searchContacts()`, `addContact()`
  - 会话管理：`getAllConversations()`, `getConversationById()`, `getOrCreatePrivateConversation()`
  - 消息操作：`getConversationMessages()`, `sendTextMessage()`, `sendImageMessage()`, `sendVoiceMessage()`
  - 数据监听：`watchConversations()`, `watchConversationMessages()`, `watchContacts()`
  - 实时通信：`initRealTimeConnection()`, `closeRealTimeConnection()`, `reconnectRealTime()`, `sendTypingStatus()`
  - 状态流：`getTypingStatusStream()`, `getOnlineStatusStream()`, `getMessageStatusStream()`, `getSyncStatusStream()`

**`chat_repository_impl.dart`**
- 实现`ChatRepository`接口，处理与数据库的交互：
  - 对联系人、会话和消息的CRUD操作
  - 使用Isar数据库进行本地存储
  - 消息的发送与接收处理
  - 文件上传与下载管理
  - 监听数据变化并通知UI
  - 使用SocketService实现实时通信
  - 处理用户在线状态、消息状态和打字状态等实时事件

**`chat_state.dart`**
- 定义聊天相关的状态：
  - 会话列表、当前会话ID
  - 按会话分组的消息列表
  - 联系人列表
  - 加载状态和错误信息
  - 在线用户集合
  - 打字状态用户映射
  - 同步状态

**`chat_cubit.dart`**
- 管理聊天相关的业务逻辑：
  - `loadConversations()` - 加载会话列表
  - `loadContacts()` - 加载联系人列表
  - `loadMessagesForConversation()` - 加载指定会话的消息
  - `setCurrentConversation()` - 切换当前会话
  - `sendTextMessage()` - 发送文本消息
  - `sendImageMessage()` - 发送图片消息
  - `sendVoiceMessage()` - 发送语音消息
  - `searchContacts()`, `searchConversations()`, `searchMessages()` - 搜索功能
  - `sendTypingStatus()` - 发送输入状态
  - `_handleTypingStatus()`, `_handleOnlineStatus()`, `_handleMessageStatus()` - 处理实时状态
  - `_setupRealTimeSubscriptions()` - 设置实时通信订阅

**`search_cubit.dart`**
- 专门管理搜索相关的功能：
  - 全局搜索
  - 联系人搜索
  - 会话搜索
  - 消息搜索

### 6.3 实时通信模块

#### 6.3.1 主要组件

**`socket_service.dart`**
- 实现Socket.IO客户端连接和事件处理：
  - `init()` - 初始化Socket连接
  - `disconnect()` - 断开Socket连接
  - `emit()` - 发送事件到服务器
  - `on()` - 监听Socket事件
  - 自定义事件处理：
    - 用户在线状态 (`userOnline`, `userOffline`)
    - 消息事件 (`newMessage`, `messageDelivered`, `messageRead`)
    - 输入状态 (`typing`, `stopTyping`)
  - 连接状态管理和重连逻辑

## 7. 功能清单

### 7.1 已实现功能
- ✅ 用户认证（登录、注册、密码重置）
- ✅ 会话管理（创建私聊、群聊）
- ✅ 消息收发（文本、图片、语音、文件）
- ✅ 联系人管理
- ✅ 多媒体消息支持
- ✅ 本地数据存储与同步
- ✅ Socket.IO实时通信
  - ✅ 消息实时同步
  - ✅ 用户在线状态显示
  - ✅ 输入状态提示
  - ✅ 消息已读回执

### 7.2 待开发功能
- ⏳ 端到端加密
- ⏳ 消息撤回和删除
- ⏳ 群组高级功能
- ⏳ 语音和视频通话

## 8. 通信协议

### 8.1 Socket.IO 通信概述

本项目使用Socket.IO与后端服务进行实时通信，支持以下数据编码方式：

1. **JSON格式（默认）** - 传统的JSON数据格式
2. **Protobuf二进制** - 高效的二进制序列化格式
3. **Base64编码的Protobuf** - 兼容性更好的Protobuf格式

### 8.2 Protocol Buffers 实现

项目中的通信协议对象使用Protocol Buffers (protobuf)定义，主要包括：

- `message.proto` - 消息相关结构
- `user.proto` - 用户相关结构
- `conversation.proto` - 会话相关结构

这些定义文件位于`protos/`目录，通过`scripts/generate_protos.sh`脚本生成Dart代码。生成的代码位于`lib/core/proto/generated/`目录下。

#### 8.2.1 版本管理

项目使用以下依赖版本确保兼容性：
- **protobuf**: ^3.1.0（Dart库）
- **protoc_plugin**: 21.1.2（代码生成插件）
- **fixnum**: ^1.1.0（处理Int64类型）

> **注意**: 严格遵守版本兼容性至关重要。protoc_plugin 22.0.0及以上版本需要匹配protobuf 4.0.0库，而我们的项目使用21.1.2版本的protoc_plugin，配合protobuf 3.1.0库。

#### 8.2.2 数据模型设计

为确保与数据库模型完美匹配，我们定制了以下protobuf数据模型：

**1. 消息模型 (message.proto)**
```protobuf
// 基本消息结构
message MessageProto {
  string message_id = 1;             // 对应 messageId
  string conversation_id = 2;        // 对应 conversationId 
  string sender_id = 3;              // 对应 senderId
  string text = 10;                  // 对应 text
  MessageType type = 9;              // 对应 type (枚举)
  string status = 8;                 // 对应 status (使用字符串而非枚举)
  // 更多字段...
}
```

**2. 用户模型 (user.proto)**
```protobuf
message UserProto {
  string user_id = 1;                // 对应 userId
  string name = 2;                   // 对应 name
  string avatar = 3;                 // 对应 avatar
  // 更多字段...
}
```

**3. 会话模型 (conversation.proto)**
```protobuf
message ConversationProto {
  string conversation_id = 1;        // 对应 conversationId
  string name = 2;                   // 对应 name
  ConversationType type = 4;         // 对应 type (枚举)
  // 更多字段...
}
```

### 8.3 数据模型转换架构

项目提供了以下工具类处理通信数据转换：

1. **ProtoConverter** - 负责Protobuf与JSON/二进制数据的互相转换
   - `messageToMap()` / `mapToMessage()` - 在Message proto与Map之间转换
   - `userToMap()` / `mapToUser()` - 在User proto与Map之间转换
   - `messageToBytes()` / `bytesToMessage()` - 处理二进制转换
   - `messageToBase64()` / `base64ToMessage()` - 处理Base64转换

2. **ProtoModelAdapter** - 负责数据库模型与Protobuf模型的互相转换
   - `messageToProto()` / `protoToMessage()` - 数据库Message与Proto Message转换
   - `userToProto()` / `protoToUser()` - 数据库User与Proto User转换
   - `conversationToProto()` / `protoToConversation()` - 数据库Conversation与Proto转换
   
### 8.4 通信协议问题排查与解决

在项目实现过程中遇到了"Target of URI hasn't been generated"错误，主要涉及以下核心问题与解决方案：

1. **版本兼容问题**
   - **问题**: protoc_plugin 22.0.x版本与protobuf 3.1.0库不兼容
   - **解决方案**: 降级protoc_plugin至21.1.2版本，确保与protobuf 3.1.0兼容

2. **模型定义匹配问题**
   - **问题**: .proto文件中的字段定义与数据库模型不完全匹配
   - **解决方案**: 重写message.proto、user.proto和conversation.proto文件，确保字段名称与类型与数据库模型一致

3. **枚举类型问题**
   - **问题**: 枚举类型大小写和命名不一致
   - **解决方案**: 统一枚举值命名为小写(如`text = 0`而非`TEXT = 0`)，与数据库模型保持一致

4. **适配器修正**
   - **问题**: 字段名称变更导致ProtoModelAdapter中的字段访问错误
   - **解决方案**: 更新adapter中的字段访问，确保正确映射新的proto字段名

5. **生成脚本更新**
   - **问题**: 生成脚本寻找路径不正确
   - **解决方案**: 修复generate_protos.sh脚本，确保能正确指向proto文件

### 8.5 通信协议的使用方式

在初始化Socket连接时指定编码方式：

```dart
await socketService.init(
  serverUrl: 'ws://api.example.com',
  authToken: 'user-auth-token',
  encoding: DataEncoding.protobuf, // 或 DataEncoding.base64, DataEncoding.json
);
```

SocketService会自动处理数据的编码和解码过程。发送消息时，通过ProtoModelAdapter将数据库模型转换为proto模型，再通过SocketService发送；接收消息时则相反。

### 8.6 Socket.IO 模拟模式

为了便于开发和测试，SocketService提供了一个模拟模式，无需真实的服务器连接即可进行开发：

#### 8.6.1 启用模拟模式

可以通过两种方式启用模拟模式：

1. 初始化时直接启用：

```dart
await socketService.init(
  serverUrl: 'http://localhost:3000',
  authToken: 'fake-token',
  simulationMode: true // 启用模拟模式
);
```

2. 动态切换模拟模式：

```dart
// 启用模拟模式
socketService.setSimulationMode(true);

// 禁用模拟模式，切换回真实通信
socketService.setSimulationMode(false);
```

#### 8.6.2 模拟功能

模拟模式中会自动模拟以下行为：

- 模拟连接和断开连接事件
- 模拟消息发送响应，包括：
  - 自动回传消息确认
  - 自动生成消息已送达状态通知
  - 自动生成消息已读状态通知
- 模拟用户在线状态变化
- 模拟响应延迟，增加真实感

#### 8.6.3 自定义模拟行为

可以通过以下方法自定义模拟行为：

```dart
// 设置特定事件的模拟延迟时间（毫秒）
socketService.setSimulationDelay('new_message', 500);
socketService.setSimulationDelay('message_read', 2000);
```

#### 8.6.4 使用场景

模拟模式特别适用于以下场景：

- 开发初期，后端服务尚未准备就绪
- 单元测试和集成测试
- 演示和展示应用功能
- 网络不可用环境下的开发
- 快速原型验证

### 8.7 Proto更新流程

如需更新通信协议，遵循以下步骤：

1. 修改`protos/*.proto`文件
2. 执行`scripts/generate_protos.sh`生成代码
3. 更新`ProtoModelAdapter`确保字段映射正确
4. 运行测试验证兼容性

维护版本兼容性是保证通信稳定的关键。

## 9. 总结与展望

该项目是一个功能完备的WhatsApp克隆应用，采用了清晰的分层架构和模块化设计。项目使用Cubit进行状态管理，Isar作为本地数据库，Socket.IO实现实时通信，并通过Protocol Buffers优化数据传输效率。

主要特点:
- 分层架构确保代码可维护性
- 多种消息类型支持
- 高效的二进制通信协议
- 实时状态同步与推送

未来计划:
- 实现端到端加密确保通信安全
- 增强群组功能与管理
- 添加语音和视频通话能力
- 优化离线消息同步机制 