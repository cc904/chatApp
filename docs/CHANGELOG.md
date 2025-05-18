# 更新日志

## [未发布]

### 新增
- 添加了 `HomeCubit` 的 `logout` 方法，用于处理用户退出登录
- 在 `ContactService` 中添加了 `clearContacts` 方法，用于清除所有联系人数据
- 创建了资源目录结构：`assets/icons/`、`assets/images/`、`assets/sounds/` 和 `assets/fonts/`

### 修复
- 修复了 `HomeCubit` 中 `showNotification` 方法缺少必需参数 `duration` 的问题
- 修复了资源目录缺失导致的构建错误

### 变更
- 优化了退出登录流程，确保正确清理用户数据和断开连接 