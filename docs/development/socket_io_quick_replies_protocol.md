# Socket.io 快捷回复协议文档（简化版）

## 📡 核心事件协议

### 1. 获取快捷回复数据

#### 客户端发送
```javascript
socket.emit('quick-replies:get', {
  timestamp: 1640995200000  // 可选：客户端时间戳
});
```

#### 服务器响应成功
```javascript
socket.emit('quick-replies:data', {
  quick_replies: [
    {
      id: 1,
      content: "您好！欢迎咨询，请问有什么可以帮助您的？",
      category: "问候",
      order_index: 0,
      is_enabled: true
    },
    {
      id: 2,
      content: "非常抱歉给您带来不便，我们会尽快为您解决。",
      category: "道歉", 
      order_index: 1,
      is_enabled: true
    }
  ],
  timestamp: 1640995200000
});
```

#### 服务器响应错误
```javascript
socket.emit('quick-replies:error', {
  message: "获取快捷回复失败",
  error_code: "QUICK_REPLY_FETCH_ERROR",
  timestamp: 1640995200000
});
```

## 🏗️ 功能说明

### 核心特性
- ✅ **只读显示**: 客户端仅展示服务器配置的快捷回复
- ✅ **分类管理**: 按category字段分组显示
- ✅ **顺序控制**: 按order_index字段排序
- ✅ **文本填入**: 点击快捷回复填入输入框，不直接发送
- ✅ **本地缓存**: 使用SharedPreferences缓存数据
- ✅ **智能同步**: 1小时内使用缓存，超时重新同步

### 简化设计
- ❌ **无CRUD操作**: 客户端不支持创建/修改/删除快捷回复
- ❌ **无使用统计**: 不上报使用数据到服务器
- ❌ **无管理界面**: 专注于快捷文本填入功能

## 🏗️ 后端实现示例

### Node.js + Socket.io 实现示例

```javascript
// 服务器端事件处理
io.on('connection', (socket) => {
  
  // 获取快捷回复
  socket.on('quick-replies:get', async (data) => {
    try {
      const userId = socket.user.id; // 从认证中获取用户ID
      const quickReplies = await QuickReplyService.getUserQuickReplies(userId);
      
      socket.emit('quick-replies:data', {
        quick_replies: quickReplies,
        timestamp: Date.now()
      });
    } catch (error) {
      socket.emit('quick-replies:error', {
        message: '获取快捷回复失败',
        error_code: 'QUICK_REPLY_FETCH_ERROR',
        timestamp: Date.now()
      });
    }
  });

  // 创建快捷回复
  socket.on('quick-replies:create', async (data) => {
    try {
      const userId = socket.user.id;
      const quickReply = await QuickReplyService.createQuickReply(userId, data);
      
      socket.emit('quick-replies:created', {
        quick_reply: quickReply
      });
    } catch (error) {
      socket.emit('quick-replies:error', {
        message: '创建快捷回复失败',
        error_code: 'QUICK_REPLY_CREATE_ERROR'
      });
    }
  });

  // 上报使用统计
  socket.on('quick-replies:usage', async (data) => {
    try {
      const userId = socket.user.id;
      await QuickReplyService.recordUsage(userId, data.quick_reply_id);
      
      // 可选：返回新的使用次数
      const updatedReply = await QuickReplyService.getQuickReply(data.quick_reply_id);
      socket.emit('quick-replies:usage-recorded', {
        quick_reply_id: data.quick_reply_id,
        new_usage_count: updatedReply.usage_count
      });
    } catch (error) {
      // 使用统计失败不需要阻塞用户操作
      console.error('记录快捷回复使用失败:', error);
    }
  });

});
```

## 🔑 权限控制

### 用户角色权限
```javascript
// 权限检查中间件
const checkQuickReplyPermission = (action) => {
  return async (socket, next) => {
    const user = socket.user;
    
    switch (action) {
      case 'read':
        // 所有认证用户都可以读取自己的快捷回复
        if (user && user.id) return next();
        break;
        
      case 'write':
        // 客服和管理员可以管理快捷回复
        if (user && ['customer_service', 'admin'].includes(user.role)) {
          return next();
        }
        break;
        
      case 'admin':
        // 只有管理员可以管理全局模板
        if (user && user.role === 'admin') return next();
        break;
    }
    
    next(new Error('权限不足'));
  };
};

// 应用权限中间件
socket.use(checkQuickReplyPermission('read'));
```

## 📝 数据库表结构建议

```sql
-- 快捷回复表
CREATE TABLE quick_replies (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    content TEXT NOT NULL,
    category VARCHAR(50) NOT NULL,
    order_index INT DEFAULT 0,
    is_enabled BOOLEAN DEFAULT TRUE,
    is_global BOOLEAN DEFAULT FALSE,  -- 全局模板
    usage_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_user_enabled (user_id, is_enabled),
    INDEX idx_global_enabled (is_global, is_enabled)
);

-- 使用统计表（可选）
CREATE TABLE quick_reply_usage_logs (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    quick_reply_id BIGINT NOT NULL,
    conversation_id VARCHAR(100),
    used_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_user_reply (user_id, quick_reply_id),
    INDEX idx_used_at (used_at)
);
```

## ⚡ 性能优化建议

### 1. 缓存策略
```javascript
// Redis缓存快捷回复数据
const cacheKey = `quick_replies:user:${userId}`;
const cachedData = await redis.get(cacheKey);

if (cachedData) {
  socket.emit('quick-replies:data', JSON.parse(cachedData));
} else {
  const quickReplies = await database.getQuickReplies(userId);
  await redis.setex(cacheKey, 3600, JSON.stringify(quickReplies)); // 1小时缓存
  socket.emit('quick-replies:data', quickReplies);
}
```

### 2. 批量操作
```javascript
// 支持批量获取
socket.on('quick-replies:batch-get', async (data) => {
  const { user_ids } = data;
  const results = await QuickReplyService.getBatchUserQuickReplies(user_ids);
  socket.emit('quick-replies:batch-data', results);
});
```

这个Socket.io协议设计保持了与现有系统的一致性，同时提供了完整的快捷回复功能支持。