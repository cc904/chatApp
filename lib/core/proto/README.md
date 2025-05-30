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

项目直接使用protoc生成的类型和方法，仅使用二进制模式进行数据传输。

```dart
import 'package:cc/core/proto/generated/message.pb.dart';

// 创建一个消息protobuf对象
final message = MessageProto()
  ..messageId = '123'
  ..text = 'Hello';

// 转换为二进制数据
final bytes = message.writeToBuffer();

// 从二进制数据恢复
final recoveredMessage = MessageProto.fromBuffer(bytes);
```

## 添加新的Proto定义

当添加新的proto消息类型后，需要进行以下更新：

1. 在`protos/`目录下创建或修改.proto文件
2. 运行生成脚本生成Dart代码
3. 在`lib/core/services/proto_events.dart`中注册新的事件和消息类型：
   ```dart
   static final Map<String, GeneratedMessage Function()> _eventTypeMap = {
     // 添加新的事件映射
     'new_event:name': () => NewMessageProto(),
   };
   ```

4. 如果新消息需要持久化存储，在`lib/core/database/models/`目录下创建或更新对应的Isar模型类：
   ```dart
   @collection
   class NewModel {
     // 定义与Proto消息对应的字段
     
     // 添加fromProto方法
     static NewModel fromProto(NewMessageProto proto) {
       final model = NewModel();
       // 转换逻辑
       return model;
     }
     
     // 添加toProto方法
     NewMessageProto toProto() {
       final proto = NewMessageProto();
       // 转换逻辑
       return proto;
     }
   }
   ```

5. 在相应的Repository实现中添加处理新消息类型的逻辑

## 注意事项

- SocketService已配置为仅使用二进制模式传输protobuf数据
- 确保客户端和服务器的proto定义保持同步
- 添加新字段时注意向后兼容性
- 在更新现有proto定义时，遵循protobuf的[兼容性规则](https://developers.google.com/protocol-buffers/docs/proto3#updating)

## 具体示例

假设我们添加了一个新的通知消息类型，步骤如下：

### 1. 创建 notification.proto 文件

```protobuf
syntax = "proto3";

package notification;

message NotificationProto {
  string id = 1;
  string title = 2;
  string body = 3;
  string type = 4;
  int64 created_at = 5;
  bool is_read = 6;
  map<string, string> data = 7;
}

message NotificationCollection {
  repeated NotificationProto notifications = 1;
}
```

### 2. 运行生成脚本

```bash
./scripts/generate_protos.sh
```

生成文件：
- lib/core/proto/generated/notification.pb.dart
- lib/core/proto/generated/notification.pbenum.dart
- lib/core/proto/generated/notification.pbjson.dart
- lib/core/proto/generated/notification.pbserver.dart

### 3. 更新 proto_events.dart

```dart
import '../proto/generated/notification.pb.dart' as notification;

static final Map<String, GeneratedMessage Function()> _eventTypeMap = {
  // 现有事件...
  
  // 添加新的通知事件
  'notification:new': () => notification.NotificationProto(),
  'notification:update': () => notification.NotificationProto(),
  'notification:sync': () => notification.NotificationCollection(),
};
```

### 4. 创建数据库模型

```dart
// lib/core/database/models/notification.dart
import 'package:isar/isar.dart';
import '../../proto/generated/notification.pb.dart';

part 'notification.g.dart';

@collection
class Notification {
  Id id = Isar.autoIncrement;
  
  @Index(unique: true)
  late String notificationId;
  
  late String title;
  late String body;
  late String type;
  late DateTime createdAt;
  late bool isRead;
  
  // 存储额外数据的JSON字符串
  String? dataJson;
  
  // 从Proto转换
  static Notification fromProto(NotificationProto proto) {
    final notification = Notification()
      ..notificationId = proto.id
      ..title = proto.title
      ..body = proto.body
      ..type = proto.type
      ..createdAt = DateTime.fromMillisecondsSinceEpoch(proto.createdAt)
      ..isRead = proto.isRead
      ..dataJson = jsonEncode(proto.data);
    
    return notification;
  }
  
  // 转换为Proto
  NotificationProto toProto() {
    final proto = NotificationProto()
      ..id = notificationId
      ..title = title
      ..body = body
      ..type = type
      ..createdAt = createdAt.millisecondsSinceEpoch
      ..isRead = isRead;
    
    if (dataJson != null) {
      final Map<String, dynamic> dataMap = jsonDecode(dataJson!);
      dataMap.forEach((key, value) {
        if (value is String) {
          proto.data[key] = value;
        }
      });
    }
    
    return proto;
  }
}
```

### 5. 创建或更新Repository

```dart
// lib/features/notifications/data/repositories/notification_repository_impl.dart
import 'package:cc/core/database/models/notification.dart';
import 'package:cc/core/proto/generated/notification.pb.dart';
import 'package:cc/core/services/socket_service.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final SocketService _socketService;
  final IsarService _isarService;
  
  NotificationRepositoryImpl(this._socketService, this._isarService);
  
  @override
  Future<void> handleNewNotification(NotificationProto proto) async {
    // 转换为数据库模型
    final notification = Notification.fromProto(proto);
    
    // 保存到数据库
    await _isarService.isar.writeTxn(() async {
      await _isarService.isar.notifications.put(notification);
    });
    
    // 触发UI更新等操作
  }
  
  // 其他方法实现...
}
```

### 6. 注册Socket监听器

```dart
// 在适当的初始化位置
_socketService.on('notification:new', (data) async {
  try {
    final proto = NotificationProto.fromBuffer(data as List<int>);
    await _notificationRepository.handleNewNotification(proto);
  } catch (e) {
    _logger.e('处理新通知失败', error: e);
  }
});
``` 