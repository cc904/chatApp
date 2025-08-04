# GitHub Actions Workflows

## Build Flutter Windows

这个 workflow 用于自动构建 Flutter Windows 应用程序，并生成两种分发格式：

### 功能特性

1. **自动构建**: 在推送到 `main` 分支或创建 Pull Request 时自动触发
2. **手动触发**: 支持通过 GitHub Actions 界面手动触发构建
3. **Inno Setup 安装程序**: 生成专业的 Windows 安装程序 (.exe)
4. **便携版**: 生成免安装的压缩包版本
5. **多语言支持**: 安装程序支持英文和简体中文

### 构建产物

构建完成后会生成两个 artifacts：

- **cc-chat-installer**: Windows 安装程序 (`cc-chat-setup.exe`)
- **cc-chat-portable**: 便携版压缩包 (`cc-chat-portable.zip`)

### 安装程序特性

- 支持桌面快捷方式创建（可选）
- 支持快速启动栏图标（Windows 7 及以下）
- 自动创建开始菜单项
- 支持卸载程序
- 现代化安装界面
- LZMA 压缩算法，安装包体积更小

### 使用方法

1. 推送代码到 `main` 分支，或创建 Pull Request
2. 等待构建完成（通常需要 10-15 分钟）
3. 在 Actions 页面下载构建产物
4. 分发给用户使用

### 手动触发

如需手动触发构建：

1. 进入 GitHub 仓库的 Actions 页面
2. 选择 "Build Flutter Windows" workflow
3. 点击 "Run workflow" 按钮
4. 选择分支并确认运行

### 技术细节

- 使用 Inno Setup 6 创建安装程序
- 支持 x64 架构
- 自动验证构建文件完整性
- 包含错误处理和状态检查