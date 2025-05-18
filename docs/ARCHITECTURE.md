# 项目架构

## 目录结构

```
lib/
  ├── core/                 # 核心功能模块
  │   ├── database/        # 数据库相关
  │   ├── services/        # 服务层
  │   └── utils/           # 工具类
  ├── features/            # 功能模块
  │   ├── auth/           # 认证模块
  │   ├── home/           # 主页模块
  │   └── contacts/       # 联系人模块
  └── main.dart           # 应用入口

assets/                    # 资源文件
  ├── icons/              # 图标资源
  ├── images/             # 图片资源
  ├── sounds/             # 音频资源
  └── fonts/              # 字体资源
```

## 资源管理

### 资源目录
- `assets/icons/`: 存放应用图标和界面图标
- `assets/images/`: 存放图片资源
- `assets/sounds/`: 存放音频资源
- `assets/fonts/`: 存放字体文件

### 资源使用
- 图标：使用 `flutter_svg` 加载 SVG 图标
- 图片：使用 `cached_network_image` 加载网络图片
- 音频：使用 `flutter_sound` 播放音频
- 字体：在 `pubspec.yaml` 中配置字体资源

## 状态管理

### Cubit 模式
- 使用 `flutter_bloc` 包实现状态管理
- 每个功能模块都有自己的 Cubit 和 State
- 状态变更通过 `emit` 方法触发

### 主要 Cubit
- `HomeCubit`: 管理主页状态
- `AuthCubit`: 管理认证状态
- `ContactsCubit`: 管理联系人状态

## 数据持久化

### Isar 数据库
- 使用 `isar` 包实现本地数据存储
- 主要存储用户、联系人、消息等数据
- 通过 `ContactService` 等服务类封装数据库操作

## 网络通信

### Socket.io
- 使用 `socket_io_client` 实现实时通信
- 通过 `SocketService` 管理连接和事件
- 支持消息推送和状态更新

## 通知系统

### 本地通知
- 使用 `flutter_local_notifications` 实现本地通知
- 通过 `UINotificationService` 统一管理通知
- 支持消息提醒和状态更新通知 