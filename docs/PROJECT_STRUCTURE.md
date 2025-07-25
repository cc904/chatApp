# 项目结构说明

本文档描述了Flutter聊天应用的目录结构和文件组织方式。

## 根目录文件

### 核心配置文件
- `pubspec.yaml` - Flutter项目依赖配置
- `analysis_options.yaml` - Dart代码分析配置
- `build.yaml` - 代码生成配置
- `devtools_options.yaml` - Flutter开发工具配置

### 项目文档
- `README.md` - 项目主要说明文档
- `CLAUDE.md` - Claude Code使用说明和项目指导

### Docker配置
- `Dockerfile.web` - Web版本Docker构建文件
- `Dockerfile.web.debug` - Web调试版本Docker构建文件
- `docker-compose.web.yml` - Web服务Docker Compose配置
- `docker-compose.debug.yml` - 调试服务Docker Compose配置

### 配置文件
- `login_domains.json` - 登录域名配置

## 主要目录结构

### `/lib/` - 应用源代码
```
lib/
├── core/                          # 核心功能模块
│   ├── adapters/                  # 数据适配器
│   ├── constants/                 # 常量定义
│   ├── database/                  # 数据库相关
│   ├── l10n/                      # 国际化支持
│   ├── proto/                     # Protocol Buffer定义
│   ├── services/                  # 业务服务层
│   ├── utils/                     # 工具函数
│   └── widgets/                   # 通用组件
├── features/                      # 功能模块(DDD架构)
│   ├── auth/                      # 认证功能
│   ├── chat/                      # 聊天功能
│   ├── contacts/                  # 联系人管理
│   ├── home/                      # 首页导航
│   └── profile/                   # 用户资料
├── main.dart                      # 应用入口
└── platform_*.dart               # 平台特定实现
```

### `/docs/` - 项目文档
```
docs/
├── architecture/                  # 架构设计文档
│   ├── TOKEN_ARCHITECTURE_REFACTOR.md
│   ├── DOMAIN_ENCRYPTION_USAGE.md
│   └── server_interface_specification.md
├── docker/                        # Docker相关文档
│   └── DOCKER_WEB_README.md
├── development/                   # 开发文档
│   ├── dynamic_file_server_config_summary.md
│   ├── file_type_limits_example.md
│   ├── simplified_config_example.md
│   ├── socket_io_quick_replies_protocol.md
│   └── quick_reply_backend_prompt.md
├── IMAGE_PASTE_FEATURE.md         # 图片粘贴功能说明
└── PROJECT_STRUCTURE.md           # 本文档
```

### `/docker/` - Docker配置
```
docker/
├── builds/                        # 各种Docker构建变体
│   ├── Dockerfile.web.cirrus
│   ├── Dockerfile.web.minimal
│   ├── Dockerfile.web.simple
│   └── Dockerfile.web.test
├── nginx.conf                     # 生产环境Nginx配置
├── nginx-debug.conf               # 调试环境Nginx配置
├── debug-tools.sh                 # 调试工具脚本
├── daemon.json                    # Docker守护进程配置
└── WASM_TROUBLESHOOTING.md        # WebAssembly问题排查
```

### `/scripts/` - 构建和工具脚本
```
scripts/
├── build-web-docker.sh            # Web Docker构建脚本
├── debug-web-docker.sh            # 调试Docker构建脚本
├── generate_protos.sh             # Protocol Buffer生成脚本
├── build_encrypted_domains.sh     # 域名加密脚本
└── ...                            # 其他工具脚本
```

### `/assets/` - 静态资源
```
assets/
├── config/                        # 配置文件
├── fonts/                         # 字体文件
├── icons/                         # 图标资源
├── images/                        # 图片资源
└── sounds/                        # 音频资源
```

### `/test/` - 测试代码
```
test/
└── core/
    └── services/                  # 服务层测试
```

### `/tools/` - 开发工具
```
tools/
├── encrypt_domains_to_assets.dart # 域名加密工具
└── generate_app_icons.py          # 应用图标生成工具
```

### 平台特定文件夹
- `/android/` - Android平台配置和原生代码
- `/ios/` - iOS平台配置和原生代码
- `/macos/` - macOS平台配置和原生代码
- `/windows/` - Windows平台配置和原生代码
- `/web/` - Web平台特定文件
- `/linux/` - Linux平台配置(如果存在)

### 构建和临时文件夹
- `/build/` - 构建输出目录(git ignored)
- `/logs/` - 日志文件目录(git ignored)
- `/.dart_tool/` - Dart工具缓存目录(git ignored)

## 文件命名规范

### Dart文件
- 使用蛇形命名法(snake_case)
- 文件名应该描述其主要功能或类名
- 测试文件以`_test.dart`结尾

### 文档文件
- 使用大写字母和下划线分割(SCREAMING_SNAKE_CASE)
- 描述性名称，如`PROJECT_STRUCTURE.md`

### 配置文件
- 使用小写字母和连字符(kebab-case)或下划线
- 如`docker-compose.web.yml`、`analysis_options.yaml`

## 架构模式

项目采用**领域驱动设计(DDD)**架构：

1. **Core层**：提供基础设施和通用功能
2. **Features层**：按业务功能模块化，每个feature包含：
   - `data/` - 数据层实现
   - `domain/` - 业务逻辑和实体
   - `presentation/` - UI层(Cubit + Widgets)

3. **平台抽象**：通过`platform_*.dart`文件实现跨平台兼容

这种结构确保了代码的可维护性、可测试性和可扩展性。