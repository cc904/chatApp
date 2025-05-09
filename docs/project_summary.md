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
│   │   ├── ui_notification_service.dart           # UI通知服务
│   │   ├── communication_service.dart             # 通信服务（Socket.IO）
│   │   └── auth_service.dart                      # 认证服务
│   │
│   ├── constants/                                 # 常量定义
│   │   └── app_config.dart                        # 应用配置
│   │
│   └── proto/                                     # Protobuf相关
│       └── generated/                             # 生成的protobuf代码
│           └── auth.pb.dart                       # 认证相关protobuf
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
6. **职责分离**：通信层与业务逻辑分离，各组件职责单一

## 4. 核心服务

| 服务名称 | 主要功能 |
|---------|---------|
| `CommunicationService` | 提供对Socket.IO连接的封装，专注于通信功能，不包含业务逻辑 |
| `MediaService` | 处理图片、视频、语音等多媒体文件的加载和播放 |
| `FileUploadService` | 管理文件的上传、下载和本地存储 |
| `UserService` | 用户信息的管理和存储 |
| `AuthService` | 处理用户认证流程，与后端交互 |
| `LogService` | 应用日志记录与管理 |

## 5. 通信模块

项目使用WebSocket进行实时通信，通过Socket.io客户端连接到Node.js后端服务器。通信模块采用了以下设计原则：

### 5.1 通信服务架构

新的`CommunicationService`作为统一的通信服务，负责：
- 处理Socket连接的建立、维护和断开
- 提供统一的事件发送和接收接口
- 支持不同编码方式的数据传输

### 5.2 职责分离

- **通信层**：`CommunicationService`专注于通信功能，不包含业务逻辑
- **业务层**：各Repository负责处理具体的业务逻辑
- **模型层**：提供数据模型的定义，支持序列化和反序列化

### 5.3 数据序列化

项目使用Protocol Buffers (protobuf)作为主要的数据序列化格式，优势包括：

- **高效性**：比JSON更小的数据体积，更快的序列化/反序列化速度
- **类型安全**：强类型定义，减少运行时错误
- **向前兼容**：协议演化时保持向后兼容性
- **跨平台**：支持多种语言，便于前后端集成

通信服务支持三种数据编码模式：
- `DataEncoding.json` - 标准JSON格式
- `DataEncoding.protobuf` - 二进制Protobuf格式（默认）
- `DataEncoding.base64` - Base64编码的Protobuf（兼容性更好）

协议定义文件位于`protos/`目录，生成的Dart代码位于`lib/core/proto/generated/`目录。

### 5.4 主要组件

1. **CommunicationService**: 负责Socket连接和事件传递
2. **ProtoConverter**: 处理Protobuf与JSON的转换
3. **Repository层**: 负责业务逻辑处理和数据持久化

## 6. 数据模型

| 模型名称 | 描述 | 主要字段 |
|---------|------|---------|
| `MyUser` | 当前登录用户的信息 | id, userId, token, name, avatar, phone, status, tokenExpireTime |
| `User` | 联系人信息 | id, userId, name, avatar, phone, status, pinyin |
| `Conversation` | 会话 | id, conversationId, type, name, lastMessage, participants |
| `Message` | 消息 | id, messageId, conversationId, senderId, content, type, status, timestamp |

## 7. 功能模块详解

### 7.1 认证模块 (auth)

#### 7.1.1 目录结构
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

#### 7.1.2 主要组件

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
  - `_initRealTimeCommunication()` - 认证成功后初始化通信连接

**认证页面**
- `auth_page.dart` - 登录页面，包含手机号输入、验证码/密码输入和登录按钮
- `register_page.dart` - 注册页面，收集用户的手机号、验证码、密码和昵称
- `forgot_password_page.dart` - 忘记密码页面，支持通过验证码重置密码

### 7.2 聊天模块 (chat)

#### 7.2.1 目录结构
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

#### 7.2.2 主要组件

**`chat_repository.dart`**
- 定义聊天功能所需的接口：
  - 联系人管理：`getAllContacts()`, `searchContacts()`, `addContact()`
  - 会话管理：`getAllConversations()`, `getConversationById()`, `getOrCreatePrivateConversation()`
  - 消息操作：`getConversationMessages()`, `sendTextMessage()`, `sendImageMessage()`, `sendVoiceMessage()`
  - 数据监听：`watchConversations()`, `watchConversationMessages()`, `watchContacts()`
  - 通信相关：`sendTypingStatus()`
  - 状态流：`getTypingStatusStream()`, `getOnlineStatusStream()`, `getMessageStatusStream()`, `getSyncStatusStream()`

**`chat_repository_impl.dart`**
- 实现`ChatRepository`接口，处理与数据库的交互和业务逻辑：
  - 对联系人、会话和消息的CRUD操作
  - 使用Isar数据库进行本地存储
  - 消息的发送与接收处理
  - 文件上传与下载管理
  - 监听数据变化并通知UI
  - 使用CommunicationService实现实时通信
  - 处理用户在线状态、消息状态和打字状态等实时事件
  - 设置Socket事件监听并处理各类事件
  - 包含模拟数据相关的业务逻辑

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
  - `_setupSubscriptions()` - 设置事件订阅

**`search_cubit.dart`**
- 专门管理搜索相关的功能：
  - 全局搜索
  - 联系人搜索
  - 会话搜索
  - 消息搜索

### 7.3 通信模块

#### 7.3.1 主要组件

**`communication_service.dart`**
- 实现Socket.IO客户端连接和事件处理的核心服务：
  - 单例模式设计：`CommunicationService()`工厂构造确保全局单一实例
  - `connect()` - 初始化Socket连接，支持认证令牌和数据编码设置
  - `disconnect()` - 断开Socket连接
  - `reconnect()` - 重新连接
  - `emitEvent()` - 发送事件到服务器
  - `onEvent()` - 获取特定事件的流
  - 事件处理：实现了与服务器的事件交互逻辑
  - 连接状态管理：`isConnected`, `isInitialized`
  - 纯通信功能：专注于通信功能，不包含业务逻辑

**`auth_service.dart`**
- 实现用户认证服务：
  - 单例模式设计
  - `init()` - 初始化认证服务，配置服务器URL
  - `sendVerificationCode()` - 发送验证码
  - `loginWithCode()` - 验证码登录
  - `loginWithPassword()` - 密码登录
  - `register()` - 用户注册
  - `resetPassword()` - 密码重置
  - `getConnectionInfo()` - 获取连接信息，供通信服务使用

## 8. 功能清单

### 8.1 已实现功能
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

### 8.2 待开发功能
- ⏳ 端到端加密
- ⏳ 消息撤回和删除
- ⏳ 群组高级功能
- ⏳ 语音和视频通话

## 9. 通信协议

本项目使用Socket.IO与后端服务进行实时通信，支持以下数据编码方式：

1. **JSON格式（默认）** - 传统的JSON数据格式
2. **Protobuf二进制** - 高效的二进制序列化格式

## 10. 数据管理

### 10.1 数据库设计

项目使用Isar作为本地NoSQL数据库，以支持高性能的离线数据存储和查询。数据库设计的主要特点：

1. **用户独立数据库** - 每个用户使用独立的数据库文件（`{userId}.isar`）
2. **模拟数据分离** - 使用单独的`mockdata.isar`数据库存储模拟数据
3. **索引优化** - 对常用查询字段（如名称、拼音等）创建索引以提高查询性能
4. **关系映射** - 使用Isar的关系功能表示实体之间的关联

### 10.2 模拟数据管理

项目实现了完善的模拟数据系统，用于开发和测试阶段：

1. **预定义模拟数据** - 使用`mockContacts`保存固定的联系人列表，包括：
   - 中文名联系人（50个）
   - 英文名联系人（30个）
   - 数字ID联系人（20个）

2. **模拟数据管理器** - 通过`MockDataManager`类管理模拟数据：
   - 管理独立的`mockdata.isar`数据库
   - 提供模拟数据的初始化、查询和搜索功能
   - 确保模拟数据与用户数据隔离

3. **模拟逻辑位置** - 所有模拟相关的逻辑都放在存储层中：
   - 在仓库实现类中处理模拟数据
   - 通信服务只专注于通信功能，不包含模拟逻辑
   - 模拟模式配置在`AppConfig`中管理

### 10.3 数据重置功能

实现了完整的数据重置功能，方便开发和测试：

1. **功能入口** - 在`ProfilePage`中添加了"重置数据"按钮
2. **重置流程**:
   - 关闭数据库连接
   - 删除所有数据库文件（`.isar`和`.isar.lock`文件，位于应用文档目录根目录）
   - 删除所有媒体文件（位于应用文档目录下的`media/`子目录）
   - 重置后自动退出应用

## 11. 最近重要更新

### 11.1 通信服务重构

最近对通信服务进行了重要重构，清晰分离了职责：

1. **统一通信服务** - 移除了旧的`SocketService`和`RealTimeCommunicationService`，统一使用`CommunicationService`：
   - 精简通信接口，专注于Socket通信
   - 移除服务中的业务逻辑，使通信层专注于通信功能
   - 优化事件订阅和处理方式

2. **业务逻辑分离** - 将业务逻辑从通信服务移至仓库实现：
   - `ChatRepositoryImpl`和`ContactsRepositoryImpl`现在包含所有业务逻辑
   - 模拟数据相关的逻辑统一在存储层处理
   - 明确区分通信与业务职责

3. **架构优化** - 重构后的架构更加符合职责单一原则：
   - 通信服务：专注于Socket连接和基本事件收发
   - 仓库实现：负责业务逻辑和数据管理
   - 模拟逻辑：集中在数据层处理

### 11.2 代码清理

重构过程中删除了一系列文件，精简了代码库：

1. 删除的文件：
   - `lib/core/services/real_time_communication_service.dart` - 已合并到统一通信服务
   - `lib/core/services/socket_service.dart` - 已合并到统一通信服务
   - `lib/core/network/socket_service.dart` - 已迁移到新的通信服务
   - `lib/core/network/data_encoding.dart` - 已整合到通信服务
   - `lib/core/network/proto_converter.dart` - 功能已优化整合
   - `lib/core/network/event_listener.dart` - 功能已整合到通信服务

2. 更新的文件：
   - `lib/main.dart` - 更新了服务依赖注入
   - `lib/features/auth/presentation/cubit/auth_cubit.dart` - 更新了通信服务的使用
   - `lib/features/chat/data/repositories/chat_repository_impl.dart` - 更新了通信和业务逻辑
   - `lib/features/contacts/data/repositories/contacts_repository_impl.dart` - 更新了通信和业务逻辑

### 11.3 架构改进

最新的重构带来了显著的架构改进：

1. **清晰的层次分离**：
   - 通信层 → 业务层 → 视图层 的清晰分层
   - 单一职责原则的更好实现
   - 依赖方向的优化

2. **更好的可测试性**：
   - 更容易模拟通信服务进行单元测试
   - 业务逻辑更容易隔离测试
   - 明确的接口定义

3. **更灵活的架构**：
   - 通信层可以独立更换实现
   - 更好的模块化和可替换性
   - 减少组件间的耦合

### 11.4 最新更新 (2023-05-XX)

以下是最新的更新内容:

1. **数据序列化标准化**
   - 移除了JSON和Base64序列化方式，仅使用Protocol Buffers (protobuf)作为唯一的数据序列化格式
   - 优化了`ProtoConverter`类，移除冗余代码，只保留protobuf相关功能
   - 更新了`CommunicationService`类，简化数据处理逻辑，专注于二进制数据传输

2. **模型改进与错误修复**
   - 为`Conversation`模型添加`lastMessageId`字段，用于追踪最后一条消息
   - 修复数据库查询中的排序问题，优化`sortByLastMessageTimeDesc`实现
   - 改进文档注释，避免HTML解析错误，特别是使用反引号(`)包裹泛型类型表示，如`Map<String, dynamic>`

3. **技术文档完善**
   - 更新项目文档，反映新的通信架构
   - 添加详细的protobuf通信实现文档
   - 改进代码注释，提高可读性和可维护性

4. **重构改进**
   - 简化`ChatRepositoryImpl`中的消息处理逻辑，优化`sendMessage`和`_handleNewMessage`方法
   - 移除不再需要的`LegacyDataEncoding`枚举
   - 统一消息传输格式，提高系统一致性和稳定性

这些更新使我们的通信架构更加简洁高效，并修复了几个潜在的错误，提高了整体代码质量。

## 12. 待办事项
- [ ] 实现消息加密
- [ ] 添加语音/视频通话
- [ ] 优化消息同步机制
- [ ] 添加消息撤回功能
- [ ] 实现文件传输进度显示 