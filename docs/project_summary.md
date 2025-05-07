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
│   ├── network/              # 网络相关（Socket.IO, Auth服务等）
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
| `SocketService` | 管理Socket.IO实时通信连接和事件处理，支持模拟模式 |
| `AuthService` | 处理用户认证流程，与后端交互 |
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
- 定义统一认证状态类，使用字段组合和辅助方法判断当前状态：
  - `phoneNumber`, `verificationCode`, `password`, `nickname` - 表单数据
  - `isCodeSent`, `countdown` - 验证码发送状态
  - `isLoading` - 加载状态
  - `errorMessage` - 错误信息
  - `userId`, `token` - 认证成功信息
  - 状态判断方法：`isInitial`, `hasError`, `isAuthenticated`
  - 状态转换方法：`toLoadingState()`, `toErrorState()`, `toAuthenticatedState()`

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
  - `_initRealTimeCommunication()` - 认证成功后初始化Socket.IO实时通信连接

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
  - 设置Socket事件监听器处理各类事件

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

### 6.3 网络通信模块

#### 6.3.1 主要组件

**`socket_service.dart`**
- 实现Socket.IO客户端连接和事件处理：
  - 单例模式设计：`getInstance()`确保全局单一实例
  - `init()` - 初始化Socket连接，支持认证令牌和数据编码设置
  - `initForAuth()` - 专为认证阶段初始化Socket连接
  - `disconnect()` - 断开Socket连接
  - `emit()` - 发送事件到服务器
  - `on()` - 监听Socket事件
  - 事件辅助方法：`sendUserOnline()`, `sendUserOffline()`, `sendMessage()`, `sendMessageRead()`, `sendTyping()`, `sendStopTyping()`
  - 模拟模式支持：`setSimulationMode()`, `_setupSimulationEventControllers()`
  - 连接状态管理：`isConnected`, `isConnecting`

**`auth_service.dart`**
- 实现用户认证服务：
  - 单例模式设计
  - `init()` - 初始化认证服务，配置服务器URL和编码方式
  - `sendVerificationCode()` - 发送验证码
  - `loginWithCode()` - 验证码登录
  - `loginWithPassword()` - 密码登录
  - `register()` - 用户注册
  - `resetPassword()` - 密码重置
  - `_handleAuthResponse()` - 处理认证响应
  - `getConnectionInfo()` - 获取连接信息，供实时通信使用

**`types.dart`**
- 定义通用枚举和类型：
  - `SocketEvent` - Socket事件枚举
  - `DataEncoding` - 数据编码方式枚举（json, protobuf, base64）

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

详细通信协议请参考 `docs/socket_protocol.md`。

### 8.2 认证协议

项目使用基于手机号的认证系统，支持以下认证方式：
- 手机号+验证码登录
- 手机号+密码登录
- 手机号+验证码+密码+昵称注册
- 手机号+验证码+新密码重置密码

详细认证协议请参考 `docs/auth_protocol.md`。

## 9. 最近更新

### 2024-04-10
1. **统一认证状态管理**
   - 重构了`AuthState`，从多状态继承模式改为单状态包含模式
   - 简化了状态管理，防止状态切换时数据丢失
   - 增加了辅助方法判断当前状态：`isInitial`、`hasError`、`isAuthenticated`
   - 添加了状态转换方法：`toLoadingState()`、`toErrorState()`、`toAuthenticatedState()`

2. **完善Socket.IO通信实现**
   - 增强了`SocketService`，添加了`initForAuth()`方法专门处理认证阶段的连接
   - 完善了`DataEncoding`枚举，支持JSON、Protobuf和Base64编码的Protobuf
   - 改进了模拟模式实现，添加更多模拟事件

3. **优化认证与实时通信集成**
   - 完善了`AuthCubit`中的`_initRealTimeCommunication()`方法
   - 确保认证成功后自动建立Socket连接并初始化聊天状态
   - 优化了认证错误处理，确保表单状态不丢失

4. **界面优化**
   - 改进了注册页面UI，增加了密码确认和更好的错误提示
   - 添加了更好的输入验证，确保用户输入有效数据

5. **文档完善**
   - 创建了详细的`socket_protocol.md`记录所有通信协议
   - 创建了`auth_protocol.md`记录认证流程
   - 更新了项目整体文档

## 10. 待办事项
- [ ] 实现消息加密
- [ ] 添加语音/视频通话
- [ ] 优化消息同步机制
- [ ] 添加消息撤回功能
- [ ] 实现文件传输进度显示 