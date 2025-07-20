# 域名加密配置使用说明

## 概述

本项目实现了编译时域名加密功能。将项目根目录的 `login_domains.json` 文件用 AES-128 加密后放到 assets 目录中，应用运行时自动解密使用。

## 设计原理

1. **编译时加密**: 构建前运行脚本，将JSON域名列表加密
2. **AES-128-CBC**: 使用强加密算法保护域名安全
3. **Assets存储**: 加密文件放在assets中，随应用打包
4. **运行时解密**: 应用启动时自动解密并缓存域名

## 文件结构

```
login_domains.json                    # 源域名配置文件（项目根目录）
tools/encrypt_domains_to_assets.dart # 域名加密工具
scripts/build_encrypted_domains.sh   # 构建脚本
assets/encrypted_domains.dat         # 加密后的域名文件（自动生成）
lib/core/services/backup_domain_service.dart # 后备域名服务
```

## 使用方法

### 1. 编辑域名配置

编辑项目根目录的 `login_domains.json` 文件：

```json
[
  "https://api.chatcc.com",
  "https://api-backup.chatcc.com",
  "https://api.chatcc.org",
  "https://api-cn.chatcc.com",
  "http://13.158.26.10:7030",
  "http://d2.orb.local:3000"
]
```

### 2. 运行加密脚本

在项目根目录运行：

```bash
# 运行加密脚本
./scripts/build_encrypted_domains.sh

# 或直接运行加密工具
dart tools/encrypt_domains_to_assets.dart
```

### 3. 构建应用

```bash
# 正常构建Flutter应用
flutter build apk
# 或
flutter build ios
```

## 工作流程

### 开发时

1. 修改 `login_domains.json`
2. 运行 `./scripts/build_encrypted_domains.sh`
3. 运行 `flutter build`

### 自动化构建

在CI/CD中添加构建步骤：

```yaml
- name: 加密域名配置
  run: |
    chmod +x scripts/build_encrypted_domains.sh
    ./scripts/build_encrypted_domains.sh

- name: 构建Flutter应用
  run: flutter build apk
```

## 加密算法

- **算法**: AES-128-CBC
- **密钥**: SHA256(固定字符串) 取前16字节
- **IV**: 每次加密生成随机16字节IV
- **格式**: Base64(IV + 密文)
- **填充**: PKCS7填充

## 应用运行流程

1. **服务初始化**
   ```dart
   await BackupDomainService.instance.initialize();
   ```

2. **读取加密文件**
   ```dart
   final encryptedData = await rootBundle.loadString('assets/encrypted_domains.dat');
   ```

3. **AES解密**
   ```dart
   final domains = await service.getBackupDomains();
   ```

4. **服务器选择**
   - 优先使用安全存储中的服务器
   - 安全存储为空时使用后备域名
   - 错误时使用紧急硬编码域名

## API接口

### BackupDomainService

```dart
// 获取所有后备域名
final domains = await BackupDomainService.instance.getBackupDomains();

// 获取综合登录服务器列表（安全存储 + 后备域名）
final servers = await BackupDomainService.instance.getCombinedLoginServers();

// 获取服务状态
final status = BackupDomainService.instance.getServiceStatus();

// 重新加载配置
await BackupDomainService.instance.reloadConfiguration();
```

### 状态检查

```dart
final status = BackupDomainService.instance.getServiceStatus();
print('服务状态: $status');
// 输出: {
//   isInitialized: true,
//   domainCount: 6,
//   encrypted: true,
//   encryptionAlgorithm: 'AES-128-CBC',
//   sourceFile: 'assets/encrypted_domains.dat'
// }
```

## 错误处理

### 1. 解密失败

如果解密失败，服务会：
1. 记录错误日志
2. 自动降级到紧急硬编码域名
3. 确保应用仍可正常使用

### 2. 文件不存在

如果assets文件不存在：
1. 抛出异常并记录日志
2. 使用紧急后备域名
3. 应用可继续运行

### 3. JSON格式错误

如果解密后JSON格式无效：
1. 记录解析错误
2. 使用紧急后备域名
3. 不影响应用启动

## 安全考虑

1. **密钥安全**: 加密密钥硬编码在代码中，编译后相对安全
2. **随机IV**: 每次加密使用不同IV，增强安全性
3. **多级后备**: 解密失败时有多层后备方案
4. **格式验证**: 解密后验证域名URL格式

## 故障排查

### 1. 加密工具运行失败

```bash
# 检查依赖
flutter pub get

# 检查源文件
ls -la login_domains.json

# 手动运行工具
dart tools/encrypt_domains_to_assets.dart
```

### 2. 解密失败

检查应用日志：
```
🔧 AES解密失败: ...
🔧 使用紧急后备域名
```

### 3. 域名格式错误

验证JSON格式：
```bash
# 验证JSON语法
cat login_domains.json | python -m json.tool
```

## 最佳实践

1. **版本控制**: 
   - 提交 `login_domains.json`（源文件）
   - 忽略 `assets/encrypted_domains.dat`（生成文件）

2. **构建流程**:
   ```bash
   git add login_domains.json
   git commit -m "更新域名配置"
   ./scripts/build_encrypted_domains.sh
   flutter build apk
   ```

3. **测试验证**:
   ```dart
   // 测试域名加载
   final domains = await BackupDomainService.instance.getBackupDomains();
   assert(domains.isNotEmpty, '域名列表不能为空');
   ```

4. **监控告警**:
   - 监控解密失败事件
   - 监控紧急域名使用情况
   - 定期检查域名可用性

## .gitignore 配置

```gitignore
# 忽略生成的加密文件
assets/encrypted_domains.dat

# 保留源配置文件
!login_domains.json
```

## 开发指南

### 添加新域名

1. 编辑 `login_domains.json`
2. 添加新的域名URL
3. 运行加密脚本
4. 重新构建应用

### 修改加密算法

如需修改加密算法：
1. 更新 `tools/encrypt_domains_to_assets.dart`
2. 更新 `lib/core/services/backup_domain_service.dart`
3. 确保加密和解密逻辑一致
4. 重新生成加密文件

### 调试加密过程

```dart
// 在工具中添加调试信息
print('原始JSON长度: ${jsonContent.length}');
print('加密后长度: ${encryptedData.length}');
print('密钥长度: ${key.length}');
print('IV长度: ${iv.length}');
```

## 许可证

本功能遵循项目的整体许可证协议。