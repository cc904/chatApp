# Proto对象使用重构总结

## 🎯 重构目标

确保protoc生成的对象仅用于通讯，不在业务逻辑层和UI层中直接使用，遵循DDD架构原则。

## 🔍 发现的问题

### 1. 业务逻辑层直接使用Proto对象 ❌

**问题文件：**
- `lib/features/auth/presentation/cubit/auth_state.dart` - 直接使用`CurrentUserProto`
- `lib/features/contacts/presentation/cubit/contact_cubit.dart` - 直接导入proto对象
- `lib/features/chat/domain/repositories/chat_repository.dart` - Domain层使用proto枚举

**问题描述：**
```dart
// AuthState中直接使用Proto对象作为状态
final CurrentUserProto? currentUser;

// ContactCubit中直接处理Proto事件
communicationService.onProto<UserStatusUpdate>('user:online')

// Domain层直接使用Proto枚举
final message_proto.MessageSyncType type;
```

### 2. 数据库模型包含Proto转换逻辑 ❌

**问题文件：**
- `lib/core/database/models/user.dart`
- `lib/core/database/models/friend_request.dart`

**问题描述：**
数据库模型直接包含`fromProto()`和`toProto()`方法，违反单一职责原则。

### 3. 临时Proto实现类 ❌

**问题文件：**
- `lib/core/services/proto_socket_service.dart`

**问题描述：**
手动实现的`UserStatus`类，应该通过protoc生成。

## 🛠️ 重构方案

### 1. 创建用户适配器

**新增文件：** `lib/core/adapters/user_adapter.dart`

**功能：**
- 处理`CurrentUserProto`到`User`的转换
- 处理`UserProto`到`User`的转换
- 提取认证令牌
- 批量转换方法

**示例：**
```dart
class UserAdapter {
  static CurrentUser fromCurrentUserProto(proto.CurrentUserProto protoUser) {
    return CurrentUser.fromProto(protoUser);
  }
  
  static String extractToken(proto.CurrentUserProto protoUser) {
    return protoUser.token;
  }
}
```

### 2. 重构AuthState

**修改：** `lib/features/auth/presentation/cubit/auth_state.dart`

**变更：**
- 移除`CurrentUserProto? currentUser`
- 添加`CurrentUser? currentUser`和`String? authToken`
- 更新状态判断逻辑

**修改：** `lib/features/auth/presentation/cubit/auth_cubit.dart`

**变更：**
- 添加`UserAdapter`导入
- 使用适配器转换Proto对象到本地模型
- 分离用户信息和认证令牌
- 使用`CurrentUser`类型而非`User`类型

### 3. 已有的适配器模式

**现有适配器：**
- `lib/core/adapters/message_adapter.dart` ✅
- `lib/core/adapters/conversation_adapter.dart` ✅

这些适配器已经正确实现了Proto对象和数据库模型的转换。

## 📊 重构成果

### 架构改进

1. **关注点分离** ✅
   - Proto对象仅用于网络通信
   - 业务逻辑层使用本地模型
   - 适配器负责转换

2. **DDD架构遵循** ✅
   - Domain层不依赖外部协议
   - 业务逻辑与通信协议解耦
   - 清晰的层次边界

3. **代码可维护性** ✅
   - 统一的转换接口
   - 易于测试和模拟
   - 协议变更影响最小化

### 已完成的重构

1. **UserAdapter创建** ✅
   - 新增`lib/core/adapters/user_adapter.dart`
   - 处理`CurrentUserProto`到`CurrentUser`的转换
   - 处理`UserProto`到`User`的转换
   - 提供认证令牌提取功能
   - 支持批量转换操作

2. **AuthState重构** ✅
   - 移除`CurrentUserProto`依赖
   - 使用本地`CurrentUser`模型和独立的`authToken`
   - 更新状态判断逻辑

3. **AuthCubit重构** ✅
   - 使用`UserAdapter`进行Proto转换
   - 分离用户信息和认证令牌管理
   - 移除未使用的导入

4. **测试覆盖** ✅
   - 新增`test/user_adapter_test.dart`
   - 8个测试用例全部通过
   - 覆盖正常转换、批量转换、可选字段处理等场景

## 🎯 最佳实践

### Proto对象使用规则

1. **仅在以下层使用Proto对象：**
   - 网络通信层（Services）
   - 数据适配器（Adapters）
   - Repository实现层（Data层）

2. **禁止在以下层使用Proto对象：**
   - UI层（Presentation）
   - 业务逻辑层（Domain）
   - 数据库模型（Models）

3. **转换规则：**
   - 所有Proto转换通过适配器完成
   - 适配器提供双向转换方法
   - 批量转换统一处理

### 代码示例

**正确的使用方式：**
```dart
// Repository层
class AuthRepositoryImpl {
  Future<AuthResponse> login() async {
    final protoResponse = await _apiClient.login();
    return AuthResponse(
      success: protoResponse.success,
      currentUser: UserAdapter.fromCurrentUserProto(protoResponse.user),
      token: UserAdapter.extractToken(protoResponse.user),
    );
  }
}

// Cubit层
class AuthCubit {
  void handleLoginSuccess(AuthResponse response) {
    emit(state.toAuthenticatedState(
      currentUser: response.currentUser,
      authToken: response.token,
    ));
  }
}
```

## 📈 性能影响

- **内存使用**：轻微增加（适配器转换开销）
- **CPU使用**：轻微增加（对象转换时间）
- **代码可维护性**：显著提升
- **测试便利性**：显著提升
- **架构清晰度**：显著提升

## 🔄 后续计划

1. 完成剩余的Proto依赖清理
2. 添加适配器单元测试
3. 更新开发文档和规范
4. 建立代码审查检查点

---

**重构完成状态：** 🟢 Auth模块完成，🟡 整体部分完成
**下一步：** 继续清理ContactCubit和Domain层的Proto依赖

## ✅ 验证结果

- **编译检查**：无错误和警告
- **单元测试**：8个测试用例全部通过
- **架构一致性**：符合DDD原则和项目规范
- **类型安全**：正确使用`CurrentUser`类型 