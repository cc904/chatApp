# 认证协议文档

本文档记录了CC WhatsApp克隆项目中使用的认证相关协议，包括登录、注册和密码重置功能。

## 1. 认证协议概述

项目目前使用基于手机号的认证系统，支持以下认证方式：
- 手机号+验证码登录
- 手机号+密码登录
- 手机号+验证码+密码+昵称注册
- 手机号+验证码+新密码重置密码

目前项目中的认证协议仅有本地模拟实现，未对接真实API。所有API调用部分都标记为 `TODO`。

## 2. 登录协议

### 2.1 登录请求

登录支持两种模式：快速登录(验证码)和普通登录(密码)。

#### 验证码登录
```javascript
{
  "phoneNumber": "13812345678",       // 手机号
  "verificationCode": "123456",       // 验证码
  "isQuickLogin": true                // 快速登录标志
}
```

#### 密码登录
```javascript
{
  "phoneNumber": "13812345678",       // 手机号
  "password": "password123",          // 密码
  "isQuickLogin": false               // 快速登录标志
}
```

### 2.2 登录响应
```javascript
{
  "success": true,                    // 是否成功
  "userId": "u345678",                // 用户ID
  "token": "auth_token_123456",       // 认证令牌
  "message": "登录成功"                // 提示信息
}
```

## 3. 注册协议

### 3.1 注册请求
```javascript
{
  "phoneNumber": "13812345678",       // 手机号
  "verificationCode": "123456",       // 验证码
  "password": "password123",          // 密码
  "nickname": "张三"                  // 昵称
}
```

### 3.2 注册响应
```javascript
{
  "success": true,                    // 是否成功
  "userId": "u345678",                // 用户ID
  "token": "auth_token_123456",       // 认证令牌
  "message": "注册成功"                // 提示信息
}
```

## 4. 密码重置协议

### 4.1 重置密码请求
```javascript
{
  "phoneNumber": "13812345678",       // 手机号
  "verificationCode": "123456",       // 验证码
  "newPassword": "newpassword123"     // 新密码
}
```

### 4.2 重置密码响应
```javascript
{
  "success": true,                    // 是否成功
  "userId": "u345678",                // 用户ID
  "token": "auth_token_123456",       // 认证令牌
  "message": "密码重置成功"            // 提示信息
}
```

## 5. 验证码发送协议

### 5.1 发送验证码请求
```javascript
{
  "phoneNumber": "13812345678",       // 手机号
  "purpose": "login"                  // 用途：login/register/reset
}
```

### 5.2 发送验证码响应
```javascript
{
  "success": true,                    // 是否成功
  "message": "验证码已发送"            // 提示信息
}
```

## 6. 认证状态

| 状态名称 | 描述 |
|---------|------|
| `AuthInitial` | 初始状态 |
| `AuthLoading` | 加载中状态 |
| `AuthFormState` | 表单填写状态，包含各种表单字段 |
| `AuthVerificationCodeSent` | 验证码已发送状态 |
| `AuthSuccess` | 认证成功状态，包含userId和token |
| `AuthError` | 认证错误状态，包含错误信息 |

## 7. 本地模拟实现细节

目前项目中使用本地模拟方式处理认证流程，主要特点：

1. 用户ID生成规则：`u` + 手机号后6位
2. 令牌生成规则：根据用户ID生成模拟token
3. 验证码发送后有60秒冷却时间
4. 手机号验证规则：必须是11位数字
5. 密码验证规则：长度至少6位
6. 验证码：支持任意6位数字（模拟环境）
7. 默认昵称规则：如未提供昵称，使用"用户+手机号后4位"

## 8. 认证流程后续工作

认证成功后，系统自动执行以下操作：

1. 初始化该用户的本地数据库
2. 保存或更新用户信息到数据库
3. 初始化Socket.IO实时通信连接
4. 初始化ChatCubit管理聊天状态

## 9. 待完成工作

以下API接口需要在未来实现真实对接：

- [ ] 验证码发送API
- [ ] 验证码登录API
- [ ] 密码登录API
- [ ] 用户注册API
- [ ] 密码重置API 