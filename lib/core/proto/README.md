# Protobuf 使用指南

本项目使用Protocol Buffers (protobuf)作为Socket.IO通信的数据序列化格式。

## 目录结构

```
lib/core/proto/
├── generated/     # 生成的Dart代码
├── source/        # .proto源文件的备份
└── README.md      # 本文档
```

项目根目录下的 `protos/` 文件夹包含原始的.proto定义文件。

## 安装必要工具

1. 安装protoc编译器：
   - macOS: `brew install protobuf`
   - Ubuntu/Debian: `sudo apt install protobuf-compiler`
   - Windows: 下载并安装[Protobuf发行版](https://github.com/protocolbuffers/protobuf/releases)

2. 安装Dart插件：
   ```bash
   dart pub global activate protoc_plugin
   ```

3. 确保`~/.pub-cache/bin`在你的PATH中（Dart全局包的bin目录）

## 生成Dart代码

项目提供了生成脚本,执行：

```bash
./scripts/generate_protos.sh
```

该脚本会：
1. 编译所有.proto文件
2. 将生成的代码放入`lib/core/proto/generated/`目录

## 在代码中使用

项目提供了`ProtoConverter`工具类,用于在Socket.IO通信中处理protobuf数据：

```dart
import 'package:cc/core/services/proto_converter.dart';

final converter = ProtoConverter();

// 创建一个消息protobuf对象
final message = MessageProto()
  ..messageId = '123'
  ..text = 'Hello';

// 转换为二进制数据
final bytes = converter.messageToBytes(message);

// 转换为Base64字符串
final base64Str = converter.messageToBase64(message);

// 转换为Map (用于JSON)
final map = converter.messageToMap(message);
```

SocketService已配置为支持三种数据编码方式：
- `DataEncoding.json` - 传统JSON格式
- `DataEncoding.protobuf` - Protobuf二进制
- `DataEncoding.base64` - Base64编码的Protobuf (兼容性更好)

通过在初始化SocketService时指定编码方式：

```dart
await socketService.init(
  serverUrl: 'http://example.com',
  authToken: 'your-token',
  encoding: DataEncoding.protobuf,
);
```

## 更新Proto定义

如需更新protobuf定义：

1. 修改`protos/`目录下的.proto文件
2. 重新运行生成脚本
3. 更新相关的转换逻辑

## 注意事项

- 服务器端也需要支持protobuf格式
- socket.io传输二进制数据需要正确配置
- 非Web平台(如Android和iOS)对二进制更友好,而Web平台使用Base64可能更合适 