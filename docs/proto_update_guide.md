# 服务端Proto文件更新后的项目配合更改指南

## 概述

当服务端更新proto文件后，客户端项目需要进行相应的配合更改以确保功能正常运行。本文档详细说明了需要更新的地方和步骤。

## 更新内容

### 新增字段
- `is_read` (bool): 消息已读状态
- `is_delivered` (bool): 消息已送达状态

这两个字段用于更精确地跟踪消息状态，替代了之前仅依赖`status`字段的方式。

## 需要更改的地方

### 1. 重新生成Proto文件

```bash
./scripts/generate_protos.sh
```

这会根据最新的proto定义生成Dart代码。

### 2. 数据库模型更新

**文件**: `lib/core/database/models/message.dart`

**更改内容**:
- 添加`isDelivered`字段
- 更新`fromProto`方法以处理新字段
- 更新`toProto`方法以包含新字段

```dart
// 新增字段
bool isDelivered = false;

// fromProto方法中添加
..isDelivered = proto.hasIsDelivered() ? proto.isDelivered : false

// toProto方法中添加
isDelivered: isDelivered,
```

### 3. 重新生成数据库模型

```bash
dart run build_runner build --delete-conflicting-outputs
```

这会为新的`isDelivered`字段生成相应的数据库访问代码。

### 4. Repository层更新

**文件**: `lib/features/chat/data/repositories/chat_repository_impl.dart`

**更改内容**:
- 在创建消息时同时设置`isRead`和`isDelivered`
- 在标记消息为已读时同时设置两个字段

```dart
// 自己发送的消息
message.isRead = true;
message.isDelivered = true;

// 标记为已读时
message.isRead = true;
message.isDelivered = true;
```

### 5. Cubit层更新

**文件**: `lib/features/chat/presentation/cubit/chat_cubit.dart`

**更改内容**:
- 更新消息状态处理逻辑
- 在不同状态下正确设置`isDelivered`字段

```dart
// delivered状态
..isDelivered = true

// read状态
..isRead = true
..isDelivered = true
```

### 6. UI层更新

**文件**: 
- `lib/features/chat/presentation/widgets/message_bubble_enhanced.dart`
- `lib/features/chat/presentation/widgets/advanced_message_bubble.dart`

**更改内容**:
- 更新状态图标显示逻辑，优先使用`isRead`和`isDelivered`字段

```dart
Widget _buildStatusIcon() {
  // 优先根据isRead和isDelivered字段判断状态
  if (widget.message.isRead) {
    return const Icon(Icons.done_all, size: 14, color: Colors.blue);
  } else if (widget.message.isDelivered) {
    return Icon(Icons.done_all, size: 14, color: Colors.grey[500]);
  }
  
  // 回退到status字段判断
  // ...
}
```

### 7. 测试文件更新

**文件**: `test/features/chat/presentation/cubit/chat_cubit_media_test.dart`

**更改内容**:
- 在测试中同时设置`isRead`和`isDelivered`字段

```dart
..isRead = true
..isDelivered = true;
```

## 状态显示逻辑

### 消息状态优先级

1. **已读** (`isRead = true`): 显示蓝色双勾 ✓✓
2. **已送达** (`isDelivered = true`): 显示灰色双勾 ✓✓  
3. **已发送** (`status = 'sent'`): 显示灰色单勾 ✓
4. **发送中** (`status = 'sending'`): 显示加载动画
5. **失败** (`status = 'failed'`): 显示红色错误图标

### 字段含义

- `isRead`: 表示消息是否已被接收方阅读
- `isDelivered`: 表示消息是否已送达到接收方设备
- `status`: 消息的基本状态（发送中、已发送、失败等）

## 验证步骤

1. 运行proto生成脚本
2. 重新生成数据库模型
3. 运行测试确保功能正常
4. 检查UI显示是否正确

```bash
# 生成proto文件
./scripts/generate_protos.sh

# 生成数据库模型
dart run build_runner build --delete-conflicting-outputs

# 运行测试
flutter test test/features/chat/presentation/cubit/chat_cubit_media_test.dart

# 检查代码分析
flutter analyze
```

## 注意事项

1. **向后兼容**: 新字段的处理逻辑会回退到原有的`status`字段，确保与旧版本服务端的兼容性
2. **数据库迁移**: 新增字段会自动处理，无需手动迁移
3. **测试覆盖**: 确保所有涉及消息状态的测试都已更新
4. **UI一致性**: 确保所有消息气泡组件都使用相同的状态显示逻辑

## 常见问题

### Q: 如果服务端还没有发送新字段怎么办？
A: 代码会自动回退到使用`status`字段，保持向后兼容性。

### Q: 数据库中的旧消息会受影响吗？
A: 不会，新字段有默认值，旧消息会正常显示。

### Q: 如何确认更新是否成功？
A: 运行测试套件，所有测试通过即表示更新成功。

## 总结

通过以上更改，项目已完全支持新的消息状态字段，提供了更精确的消息状态跟踪功能，同时保持了与旧版本的兼容性。 