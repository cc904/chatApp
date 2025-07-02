# LoadingType 枚举迁移到 Protocol Buffers

## 修改概述

将本地的 `LoadingType` 枚举迁移到 Protocol Buffers 定义，实现前后端统一的加载类型定义。

## 修改内容

### 1. Protocol Buffers 定义更新

**文件：** `lib/core/proto/source/message.proto`

- 添加了 `LoadingType` 枚举定义：
  ```protobuf
  enum LoadingType {
    INITIAL = 0;         // 初始加载 - 定位到最新消息
    LOAD_MORE_BEFORE = 1; // 向上加载历史消息 - 保持当前位置
    LOAD_MORE_AFTER = 2;  // 向下加载新消息 - 保持当前位置
    ADD = 3;              // 添加单个消息 - 可能需要滚动定位
    UPDATE = 4;           // 更新单个消息 - 保持当前位置
    SEARCH = 5;           // 搜索消息 - 定位到搜索结果
    REFRESH = 6;          // 刷新当前视图 - 保持当前位置
  }
  ```

- 修改 `MessagesFetchRequest` 消息：
  - 移除：`bool is_before = 4;`
  - 添加：`LoadingType loading_type = 4;`

### 2. Dart 代码更新

**移除本地定义：** `lib/features/chat/domain/entities/message_update_event.dart`
- 移除了本地的 `LoadingType` 枚举定义
- 改为导入 proto 生成的枚举：`import 'package:cc/core/proto/generated/message.pb.dart' show LoadingType;`

**更新接口定义：** `lib/features/chat/domain/repositories/chat_repository.dart`
- 添加 LoadingType 导入
- 更新 `requestMessages` 方法签名：
  - 参数从 `bool? isBefore = false` 改为 `LoadingType? loadingType = LoadingType.LOAD_MORE_BEFORE`

**更新实现：** `lib/features/chat/data/repositories/chat_repository_impl.dart`
- 添加 LoadingType 导入
- 更新所有枚举值引用：
  - `LoadingType.initial` → `LoadingType.INITIAL`
  - `LoadingType.loadMoreBefore` → `LoadingType.LOAD_MORE_BEFORE`
  - `LoadingType.loadMoreAfter` → `LoadingType.LOAD_MORE_AFTER`
  - `LoadingType.add` → `LoadingType.ADD`
  - `LoadingType.update` → `LoadingType.UPDATE`
  - `LoadingType.search` → `LoadingType.SEARCH`
  - `LoadingType.refresh` → `LoadingType.REFRESH`
- 更新 `requestMessages` 方法实现，使用 `loadingType` 字段替代 `isBefore`

**更新业务逻辑：** `lib/features/chat/presentation/cubit/chat_cubit.dart`
- 添加 LoadingType 导入
- 更新所有枚举值引用为大写形式

### 3. 重新生成 Proto 文件

运行 `./scripts/generate_protos.sh` 重新生成了所有 proto 相关的 Dart 文件。

## 枚举值映射

| 原本地枚举值 | 新Proto枚举值 | 说明 |
|-------------|---------------|------|
| `initial` | `INITIAL` | 初始加载 |
| `loadMoreBefore` | `LOAD_MORE_BEFORE` | 向上加载历史消息 |
| `loadMoreAfter` | `LOAD_MORE_AFTER` | 向下加载新消息 |
| `add` | `ADD` | 添加单个消息 |
| `update` | `UPDATE` | 更新单个消息 |
| `search` | `SEARCH` | 搜索消息 |
| `refresh` | `REFRESH` | 刷新当前视图 |

## 兼容性说明

- **前后端协议统一**：前后端现在使用相同的 LoadingType 定义
- **类型安全**：保持了强类型检查
- **向后兼容**：功能逻辑完全保持一致，只是枚举值命名从小写改为大写

## 测试验证

- ✅ 所有单元测试通过（76个测试）
- ✅ 集成测试通过
- ✅ Proto 文件生成正确
- ✅ 枚举值映射正确

## 影响范围

- 消息获取请求的参数结构
- 加载状态管理的类型定义
- 前后端通信协议统一

这次修改实现了前后端加载类型定义的统一，提高了系统的一致性和可维护性。 