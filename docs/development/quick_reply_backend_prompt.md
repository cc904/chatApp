# 快捷回复功能后端开发需求

## 功能说明
为Flutter聊天应用实现快捷回复功能，客服用户可以快速插入预设回复文本到输入框。

## Socket.io事件协议

### 1. 获取快捷回复
**客户端发送:**
```javascript
socket.emit('quick-replies:get', {
  timestamp: 1640995200000
});
```

**服务器成功响应:**
```javascript
socket.emit('quick-replies:data', {
  quick_replies: [
    {
      id: 1,
      content: "您好！欢迎咨询，请问有什么可以帮助您的？",
      category: "问候",
      order_index: 0,
      is_enabled: true
    }
  ],
  timestamp: 1640995200000
});
```

**服务器错误响应:**
```javascript
socket.emit('quick-replies:error', {
  message: "获取快捷回复失败",
  error_code: "QUICK_REPLY_FETCH_ERROR",
  timestamp: 1640995200000
});
```

## 数据库表结构
```sql
CREATE TABLE quick_replies (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    content TEXT NOT NULL,
    category VARCHAR(50) NOT NULL,
    order_index INT DEFAULT 0,
    is_enabled BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_user_enabled (user_id, is_enabled)
);
```

## 关键要求
- 只需实现**读取**功能，客户端不支持CRUD操作
- 按`category`分组，按`order_index`排序返回
- 只返回`is_enabled=true`的记录
- 支持用户权限验证
- 建议使用Redis缓存提升性能

客户端已完成实现，只需要后端提供上述Socket.io事件处理即可。