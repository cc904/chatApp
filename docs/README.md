# 项目文档

欢迎使用CC WhatsApp克隆项目文档。此目录包含了项目的所有技术文档，帮助你理解和使用本项目。

## 核心文档

| 文档名称 | 描述 |
|---------|------|
| [API参考文档](api_reference.md) | 完整的客户端API参考，包括所有服务的详细方法说明 |
| [通信协议文档](communication_protocol.md) | Socket.IO和Protobuf通信协议的整合文档 |
| [项目概述](project_summary.md) | 项目结构、架构和主要功能概述 |

## 详细文档

### 通信相关

- [Protobuf通信实现](protobuf_communication.md) - Protobuf数据序列化实现详情
- [Proto实现细节](proto_implementation.md) - Proto文件定义和实现细节
- [认证协议](auth_protocol.md) - 用户认证机制说明

### 后端相关

- [Next.js后端需求](nextjs_backend_requirements.md) - 后端服务实现要求

## 修改Proto文件流程

当需要修改Proto文件定义时，请按以下步骤操作：

1. 在`protos/`目录下编辑或创建.proto文件
2. 运行Protobuf编译命令生成Dart代码：
   ```shell
   protoc --dart_out=lib/core/proto/generated protos/*.proto
   ```
3. 在`lib/core/services/proto_events.dart`中注册新的消息类型
4. 更新[通信协议文档](communication_protocol.md)中的相关定义
5. 测试新的消息类型，确保客户端和服务器正确处理

## 文档结构

为了保持文档的一致性和可维护性，我们将文档分为以下几类：

1. **核心参考文档** - 面向开发者的API参考和通信协议
2. **实现细节文档** - 描述特定功能的实现方式
3. **指南文档** - 如何使用或扩展特定功能

## 文档更新指南

更新文档时请遵循以下原则：

1. 保持文档与代码同步更新
2. 使用清晰、简洁的语言
3. 提供示例代码说明复杂概念
4. 遵循标记语言规范
5. 保持文档的内部链接有效

---

如有任何问题或需要补充，请联系项目维护者。 