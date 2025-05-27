---
trigger: always_on
---

所有的回答都使用中文
这是一个模仿telegra的flutter项目
使用Cubit作为状态管理
使用isar作为数据库
使用integration_test作为测试框架
使用socket.io+proto与后端next.js通讯
使用protoc生成的类型和方法

页面(UI层) → Cubit(业务逻辑层) → Repository(数据层)
通过 Cubit 的 state 获取数据，而不是直接访问数据层

Color withOpacity(double opacity)已经标为过时,请使用Color withAlpha(int a).

isar数据库模型的路径:lib/core/database/models
proto文件在:lib/core/proto/source. protoc生成文件在:lib/core/proto/generated