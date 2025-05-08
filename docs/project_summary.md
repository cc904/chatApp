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
├── main.dart                                      # 应用入口点
│ 
├── core/                                          # 核心服务和工具
│   ├── database/                                  # 数据库相关
│   │   ├── database_initializer.dart              # 数据库初始化器
│   │   ├── mock_data_manager.dart                 # 模拟数据管理器
│   │   ├── mock_data_generator.dart               # 模拟数据生成器
│   │   └── models/                                # 数据模型
│   │       ├── user.dart                          # 用户/联系人模型
│   │       ├── my_user.dart                       # 当前用户模型
│   │       ├── conversation.dart                  # 会话模型
│   │       ├── message.dart                       # 消息模型
│   │       ├── friend_request.dart                # 好友请求模型
│   │       └── *.g.dart                           # Isar生成的文件
│   │ 
│   ├── services/                                  # 服务实现
│   │   ├── log_service.dart                       # 日志服务
│   │   ├── my_user_service.dart                   # 当前用户服务
│   │   ├── file_upload_service.dart               # 文件上传服务
│   │   └── ui_notification_service.dart           # UI通知服务
│   │
│   ├── network/                                   # 网络相关
│   │   ├── socket_service.dart                    # Socket.IO服务
│   │   ├── auth_service.dart                      # 认证服务
│   │   ├── proto_converter.dart                   # Protobuf转换器
│   │   ├── event_listener.dart                    # 事件监听器
│   │   ├── types.dart                             # 网络类型定义
│   │   └── index.dart                             # 统一导出
│   │ 
│   ├── proto/                                     # Protobuf相关
│   │   └── generated/                             # 生成的protobuf代码
│   │       └── auth.pb.dart                       # 认证相关protobuf
│   │ 
│   └── adapters/                                  # 数据适配器
│       └── proto_model_adapter.dart               # Protobuf模型适配器
│ 
├── features/                                      # 功能模块
│   ├── auth/                                      # 认证功能
│   │   └── presentation/                          # 表现层
│   │       ├── cubit/                             # 状态管理
│   │       │   ├── auth_cubit.dart                # 认证Cubit
│   │       │   └── auth_state.dart                # 认证状态
│   │       └── pages/                             # 页面
│   │           └── auth_page.dart                 # 认证页面
│   │ 
│   ├── chat/                                      # 聊天功能
│   │   ├── domain/                                # 领域层
│   │   │   └── repositories/                      # 仓库接口
│   │   │       └── chat_repository.dart           # 聊天仓库接口
│   │   ├── data/                                  # 数据层
│   │   │   ├── repositories/                      # 仓库实现
│   │   │   │   └── chat_repository_impl.dart      # 聊天仓库实现
│   │   └── presentation/                          # 表现层
│   │       ├── cubit/                             # 状态管理
│   │       │   ├── chat_cubit.dart                # 聊天Cubit
│   │       │   └── search_cubit.dart              # 搜索Cubit
│   │       └── pages/                             # 页面
│   │           ├── chat_page.dart                 # 聊天页面
│   │           └── chat_search_page.dart          # 聊天搜索页面
│   │ 
│   ├── contacts/                                  # 联系人功能
│   │   ├── domain/                                # 领域层
│   │   │   └── repositories/                      # 仓库接口
│   │   │       └── contacts_repository.dart       # 联系人仓库接口
│   │   │
│   │   ├── data/                                  # 数据层
│   │   │   └── repositories/                      # 仓库实现
│   │   │       └── contacts_repository_impl.dart  # 联系人仓库实现
│   │   │
│   │   └── presentation/                          # 表现层
│   │       ├── cubit/                             # 状态管理
│   │       │   ├── contacts_cubit.dart            # 联系人Cubit
│   │       │   └── contacts_state.dart            # 联系人状态
│   │       └── pages/                             # 页面
│   │           ├── contacts_page.dart             # 联系人页面
│   │           └── friend_requests_page.dart      # 好友请求页面
│   │
│   └── home/                                      # 主页功能
│       └── presentation/                          # 表现层
│           ├── cubit/                             # 状态管理
│           │   └── home_cubit.dart                # 主页Cubit
│           └── pages/                             # 页面
│               ├── home_page.dart                 # 主页
│               ├── chats_page.dart                # 聊天列表页面
│               ├── status_page.dart               # 状态页面
│               ├── calls_page.dart                # 通话页面
│               ├── profile_page.dart              # 个人资料页面
│               └── search_page.dart               # 搜索页面
```

项目采用了清晰的分层架构，遵循了领域驱动设计(DDD)的原则：

1. **特性模块化**：每个主要功能(auth, chat, contacts, home)都在独立的目录中
2. **分层架构**：每个功能模块遵循presentation(表现层) → domain(领域层) → data(数据层)的分层方式
3. **状态管理**：使用Cubit(Flutter Bloc简化版)管理状态
4. **数据存储**：通过Isar数据库实现本地存储
5. **通信**：使用Socket.IO与后端服务进行通信

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
| `MyUser` | 当前登录用户的信息 | id, userId, token, name, avatar, phone, status, tokenExpireTime |
| `User` | 联系人信息 | id, userId, name, avatar, phone, status, pinyin |
| `Conversation` | 会话 | id, conversationId, type, name, lastMessage, participants |
| `Message` | 消息 | id, messageId, conversationId, senderId, content, type, status, timestamp |

## 6. 功能模块详解

### 6.1 认证模块 (auth)

#### 6.1.1 目录结构
```
lib/features/auth/
├── presentation/
    ├── cubit/
    │   ├── auth_cubit.dart             # 认证状态管理
    │   └── auth_state.dart             # 认证状态定义
    └── pages/
        ├── auth_page.dart              # 登录页面
        ├── register_page.dart          # 注册页面
        └── forgot_password_page.dart   # 找回密码页面
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
│       └── chat_repository_impl.dart           # 聊天仓库实现
├── domain/
│   └── repositories/
│       └── chat_repository.dart                # 聊天仓库接口
└── presentation/
    ├── cubit/
    │   ├── chat_cubit.dart                     # 聊天状态管理
    │   ├── chat_state.dart                     # 聊天状态定义
    │   └── search_cubit.dart                   # 搜索功能状态管理
    ├── pages/                                  # 聊天相关页面
    │   ├── chat_page.dart                      # 聊天页面
    │   └── chat_search_page.dart               # 聊天搜索页面
    ├── utils/                                  # 工具类
    └── widgets/                                # 聊天相关组件
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
  - 模拟模式支持：`setIsSimulationMode()`, `_setupSimulationEventControllers()`
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

## 9. 数据管理

### 9.1 数据库设计

项目使用Isar作为本地NoSQL数据库，以支持高性能的离线数据存储和查询。数据库设计的主要特点：

1. **用户独立数据库** - 每个用户使用独立的数据库文件（`{userId}.isar`）
2. **模拟数据分离** - 使用单独的`mockdata.isar`数据库存储模拟数据
3. **索引优化** - 对常用查询字段（如名称、拼音等）创建索引以提高查询性能
4. **关系映射** - 使用Isar的关系功能表示实体之间的关联

### 9.2 模拟数据管理

项目实现了完善的模拟数据系统，用于开发和测试阶段：

1. **预定义模拟数据** - 使用`mockContacts`保存固定的联系人列表，包括：
   - 中文名联系人（50个）
   - 英文名联系人（30个）
   - 数字ID联系人（20个）

2. **模拟数据管理器** - 通过`MockDataManager`类管理模拟数据：
   - 管理独立的`mockdata.isar`数据库
   - 提供模拟数据的初始化、查询和搜索功能
   - 确保模拟数据与用户数据隔离

3. **模拟数据生成器** - 使用`MockDataGenerator`动态生成模拟数据：
   - 生成联系人、会话和消息数据
   - 支持不同类型和状态的模拟数据生成

### 9.3 模拟模式功能

实现了完整的模拟模式功能，方便开发和测试：

1. **配置管理** - 在`AppConfig`中通过`isSimulationMode`字段控制模拟模式
2. **UI集成** - 在`ProfilePage`中添加模拟模式开关，并提供清晰的状态指示
3. **运行效果**:
   - 模拟模式开启时，应用将使用本地模拟数据，不会尝试进行真实网络连接
   - 模拟模式下，所有网络请求使用本地模拟数据响应
   - 模拟模式下，Socket.IO连接被模拟，不会真正连接到服务器

### 9.4 数据重置功能

实现了完整的数据重置功能，方便开发和测试：

1. **功能入口** - 在`ProfilePage`中添加了"重置数据"按钮
2. **重置流程**:
   - 关闭数据库连接
   - 删除所有数据库文件（位于`/isar`目录）
   - 删除所有媒体文件（位于`/media`目录）
   - 重置后自动退出应用

### 9.5 数据库初始化改进

对数据库初始化进行了以下改进：

1. **移除默认数据库** - 不再支持无用户ID的默认数据库
2. **延迟初始化** - 数据库初始化推迟到用户登录后进行
3. **切换用户支持** - 添加数据库切换功能，支持多用户场景
4. **错误处理优化** - 完善了异常捕获和日志记录

## 10. 最近重要更新

### 10.1 术语统一

最近进行了术语统一，使项目更加一致：

1. **模拟数据命名** - 将所有涉及"测试数据"的术语更改为"模拟数据"：
   - `TestDataManager` → `MockDataManager`
   - `TestDataGenerator` → `MockDataGenerator`
   - `generateTestData()` → `generateMockData()`
   - 所有测试数据相关的方法和描述都统一使用"模拟数据"
   - 数据库文件名从`testData.isar`改为`mockdata.isar`

2. **文件重命名** - 重命名了相关文件以保持一致性：
   - `test_data_manager.dart` → `mock_data_manager.dart`
   - `test_data_generator.dart` → `mock_data_generator.dart`

3. **模拟模式优化** - 完善了模拟模式的配置和使用：
   - 在`AppConfig`中添加了详细的模拟模式描述
   - 优化了模拟模式下的Socket.IO模拟实现
   - 优化了模拟模式下的数据加载逻辑

### 10.2 文件结构变更

最近的文件删除和更新记录表明项目正在持续优化：

1. 删除的文件：
   - `lib/core/database/test_data_generator.dart` - 更名为mock_data_generator.dart
   - `lib/core/database/test_data_manager.dart` - 更名为mock_data_manager.dart

2. 更新的文件：
   - `lib/main.dart` - 更新了模拟数据管理器的引用
   - `lib/features/auth/presentation/cubit/auth_cubit.dart` - 更新了模拟模式的处理逻辑
   - `lib/features/home/presentation/pages/profile_page.dart` - 更新了模拟数据重生成功能和UI
   - `lib/core/database/database_initializer.dart` - 更新了与模拟模式的集成

## 11. 待办事项
- [ ] 实现消息加密
- [ ] 添加语音/视频通话
- [ ] 优化消息同步机制
- [ ] 添加消息撤回功能
- [ ] 实现文件传输进度显示 