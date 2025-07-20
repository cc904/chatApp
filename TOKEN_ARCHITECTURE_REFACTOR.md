# Token 架构重构总结

## 重构概述

本次重构将原有的 Access Token + Refresh Token + Socket Token 三Token架构简化为 Refresh Token + Socket Token 双Token架构。

## 新架构设计

### Token 类型和用途

1. **Refresh Token**
   - **用途**: 用于刷新Socket Token
   - **有效期**: 30天
   - **过期处理**: 过期后需要重新登录
   - **使用场景**: 通过Socket.io刷新Socket Token

2. **Socket Token**
   - **用途**: 专门用于Socket.IO实时通信和所有需要认证的业务操作
   - **有效期**: 7天
   - **过期处理**: 到期前使用Refresh Token刷新
   - **使用场景**: WebSocket连接认证、所有需要认证的业务操作

## 主要变更

### 1. SecureStorageService 变更
- ✅ 移除 `saveAccessToken()` 方法
- ✅ 移除 `getAccessToken()` 方法
- ✅ 移除 `getAccessTokenExpireTime()` 方法
- ✅ 移除 `isAccessTokenValid()` 方法
- ✅ 移除 `keyAccessToken` 和 `keyAccessTokenExpireTime` 常量
- ✅ 更新 `clearAllTokens()` 方法，移除Access Token清理

### 2. EnhancedTokenManager 变更
- ✅ 重构 `getApiToken()` 方法：现在返回Refresh Token（注意：REST API不需要token，只有auth相关API使用）
- ✅ 重构 `getSocketToken()` 方法：专门返回Socket Token，自动处理刷新
- ✅ 重构 `saveLoginTokens()` 方法：只保存Refresh Token和Socket Token
- ✅ 重构 `_performTokenRefresh()` 方法：改为刷新Socket Token
- ✅ 重构 `_checkAndRefreshTokens()` 方法：检查Socket Token是否需要刷新
- ✅ 更新刷新配置：Socket Token提前12小时刷新，检查间隔1小时
- ✅ 更新 `getTokenStatus()` 方法：移除Access Token状态

### 3. 其他文件变更
- ✅ `main.dart`: 更新启动时的Token检查逻辑
- ✅ `auth_repository_impl.dart`: 更新登录状态检查逻辑
- ✅ `auth_debug_utils.dart`: 移除所有Access Token相关调试代码
- ✅ `debug_commands.dart`: 移除Access Token状态检查，更新刷新逻辑
- ✅ `profile_page.dart`: 移除Access Token状态显示
- ✅ `account_security_page.dart`: 移除Access Token状态显示

### 4. 配置文件更新
- ✅ `final_minimal_config.md`: 更新Token结构示例
- ✅ `server_interface_specification.md`: 更新登录响应Token结构

## API 接口变更

### 登录响应结构
```json
{
  "success": true,
  "currentUser": { ... },
  "tokens": {
    "refreshToken": "refresh_token_here",
    "refreshTokenExpiresAt": 1642678800000,
    "socketToken": "socket_token_here", 
    "socketTokenExpiresAt": 1642678800000
  }
}
```

### API接口说明
由于 REST API 不需要 token 认证，Socket Token 的刷新完全通过 Socket.io 进行，不再需要额外的 REST API 接口。

## 工作流程

### 1. 登录流程
1. 用户登录成功后，服务器返回Refresh Token和Socket Token
2. 客户端保存两个Token到安全存储
3. 启动Token管理服务，定期检查Socket Token是否需要刷新

### 2. API请求流程
1. **REST API**: 只用于认证相关操作（登录、注册等），**不需要token认证**
2. **Socket.io**: 所有需要认证的业务操作都通过Socket.io进行，使用Socket Token认证
3. Refresh Token主要用于刷新Socket Token，不直接用于业务API请求认证

### 3. Socket连接流程
1. Socket连接使用Socket Token进行认证
2. Socket Token过期前12小时自动刷新
3. 刷新失败时，Socket连接会断开，需要重新登录

### 4. Token刷新流程
1. 只有Socket Token需要定期刷新
2. **使用Socket.io接口**刷新Socket Token，而不是REST API
3. 通过Socket连接发送刷新请求，等待Socket响应
4. 如果Refresh Token过期，刷新失败，需要重新登录

## 优势

1. **简化架构**: 减少了一个Token类型，降低了复杂度
2. **明确职责**: Refresh Token专门用于刷新，Socket Token专门用于所有需要认证的操作
3. **减少刷新频率**: 不再需要频繁刷新Access Token
4. **提高安全性**: 长期Token（Refresh）和短期Token（Socket）分离
5. **统一通信**: 所有需要认证的业务操作和Token刷新都通过Socket.io进行
6. **REST API简化**: REST API只用于认证，不需要token，简化了API设计

## Socket.io Token刷新机制

### 刷新请求
```
事件名: refreshSocketToken
请求数据: {
  refreshToken: "refresh_token_here",
  timestamp: 1642678800000
}
```

### 刷新响应
```
事件名: refreshSocketTokenResponse
响应数据: {
  success: true,
  tokens: {
    refreshToken: "new_refresh_token",
    refreshTokenExpiresAt: 1642678800000,
    socketToken: "new_socket_token",
    socketTokenExpiresAt: 1642678800000
  }
}
```

## 注意事项

1. **服务端配合**: 需要服务端实现Socket.io的Token刷新事件处理
2. **Protobuf支持**: 需要定义相应的protobuf消息结构
3. **超时处理**: Socket刷新请求设置30秒超时
4. **错误处理**: 需要完善Token过期的错误处理逻辑
5. **测试验证**: 需要全面测试新的Socket.io Token刷新逻辑

## 测试建议

1. **登录测试**: 验证新的Token保存逻辑
2. **REST API测试**: 验证认证相关API（登录、注册）不需要token即可访问
3. **Socket测试**: 验证Socket Token用于WebSocket连接和所有需要认证的业务操作
4. **刷新测试**: 验证Socket Token通过Socket.io自动刷新机制
5. **过期测试**: 验证各种Token过期场景的处理

## 后续工作

1. 服务端实现新的Token刷新接口
2. 更新API文档和接口规范
3. 进行全面的集成测试
4. 更新用户文档和开发文档