# 为什么要统一使用Isar而不是SharedPreferences？

## 🤔 问题分析

你的问题很有道理！使用两套存储系统确实有问题：

### 当前架构的问题
```
❌ 分散存储架构：
├── Isar数据库：基础游标（sync/local cursor）
└── SharedPreferences：多游标对（timeline pairs）
```

**主要问题：**
1. **存储分散**：数据分布在两个不同的存储系统
2. **事务问题**：无法保证跨系统的数据一致性
3. **性能问题**：SharedPreferences不适合存储大量结构化数据
4. **查询限制**：无法进行复杂的关联查询和索引优化
5. **维护复杂**：需要维护两套不同的存储逻辑

## 🎯 统一Isar存储的优势

### 1. **数据一致性**
```dart
// ✅ 统一事务处理
await isar.writeTxn(() async {
  // 更新基础游标
  conversation.syncCursorMessageId = newCursor.messageId;
  await isar.conversations.put(conversation);
  
  // 同时更新相关的游标对
  final cursorPair = await isar.messageCursorPairModels
      .filter()
      .pairIdEqualTo(pairId)
      .findFirst();
  if (cursorPair != null) {
    cursorPair.isSynced = true;
    await isar.messageCursorPairModels.put(cursorPair);
  }
});
```

### 2. **高效查询和索引**
```dart
// ✅ 复合索引优化查询
@Index(composite: [CompositeIndex('conversationId'), CompositeIndex('createdAt')])
class MessageCursorPairModel {
  // 可以高效查询特定会话的时间线游标对
}

// ✅ 复杂查询支持
final gapPairs = await isar.messageCursorPairModels
    .filter()
    .conversationIdEqualTo(conversationId)
    .typeEqualTo('gap')
    .isSyncedEqualTo(false)
    .sortByPriorityDesc()
    .limit(10)
    .findAll();
```

### 3. **关系数据管理**
```dart
// ✅ 建立数据关系
class MessageCursorPairModel {
  final conversation = IsarLink<Conversation>();
}

// ✅ 级联操作
final conversation = await isar.conversations
    .filter()
    .conversationIdEqualTo(conversationId)
    .findFirst();

await conversation.cursorPairs.load(); // 自动加载关联的游标对
```

### 4. **性能优势**
```dart
// ✅ 批量操作优化
await isar.writeTxn(() async {
  await isar.messageCursorPairModels.putAll(models); // 批量插入
});

// ✅ 内存映射文件，比SharedPreferences快很多
// ✅ 支持并发读取
// ✅ 自动压缩和优化
```

## 📊 性能对比

| 特性 | SharedPreferences | Isar数据库 |
|------|------------------|------------|
| **存储容量** | 小量键值对 | 大量结构化数据 |
| **查询能力** | 只能按key查询 | 复杂SQL式查询 |
| **索引支持** | 无 | 多种索引类型 |
| **事务支持** | 无 | 完整ACID事务 |
| **并发性能** | 差 | 优秀 |
| **内存使用** | 全部加载到内存 | 按需加载 |
| **关系数据** | 不支持 | 完整支持 |

## 🔧 迁移方案

### 第一步：扩展现有Isar模式

```dart
// 在现有的数据库中添加MessageCursorPairModel
@collection
class MessageCursorPairModel {
  Id id = Isar.autoIncrement;
  
  @Index(unique: true, replace: true)
  late String pairId;
  
  @Index(composite: [CompositeIndex('createdAt')])
  late String conversationId;
  
  @Index()
  late String type;
  
  @Index()
  bool isSynced = false;
  
  @Index()
  int priority = 0;
  
  // ... 其他字段
  
  final conversation = IsarLink<Conversation>();
}
```

### 第二步：数据迁移

```dart
class TimelineDataMigration {
  static Future<void> migrateFromSharedPreferences(Isar isar) async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys()
        .where((key) => key.startsWith('timeline_cursor_pairs_'))
        .toList();
    
    await isar.writeTxn(() async {
      for (final key in keys) {
        final data = prefs.getString(key);
        if (data != null) {
          final map = jsonDecode(data) as Map<String, dynamic>;
          final pair = MessageCursorPair.fromMap(map);
          final model = MessageCursorPairModel.fromDomain(pair);
          await isar.messageCursorPairModels.put(model);
        }
      }
    });
    
    // 清理SharedPreferences中的旧数据
    for (final key in keys) {
      await prefs.remove(key);
    }
  }
}
```

### 第三步：更新Repository

```dart
class MessageTimelineRepositoryIsar {
  final Isar _isar;
  
  // 统一的数据库操作
  Future<void> saveCursorPair(MessageCursorPair cursorPair) async {
    await _isar.writeTxn(() async {
      final model = MessageCursorPairModel.fromDomain(cursorPair);
      await _isar.messageCursorPairModels.put(model);
    });
  }
  
  Future<List<MessageCursorPair>> getCursorPairsByConversation(
      String conversationId) async {
    final models = await _isar.messageCursorPairModels
        .filter()
        .conversationIdEqualTo(conversationId)
        .sortByCreatedAt()
        .findAll();
    
    return models.map(_convertToDomain).toList();
  }
}
```

## 🚀 最终架构

### 统一Isar存储架构
```
✅ 统一存储架构：
└── Isar数据库
    ├── Conversation（会话 + 基础游标）
    ├── Message（消息）
    ├── MessageCursorPairModel（多游标对）
    └── 其他模型...
```

**优势总结：**
- ✅ **数据一致性**：单一事务保证
- ✅ **查询性能**：复杂索引和查询优化
- ✅ **关系管理**：自动关联和级联操作
- ✅ **存储效率**：内存映射文件，高性能
- ✅ **维护简单**：统一的数据访问层
- ✅ **扩展性好**：支持复杂的业务查询需求

## 💡 结论

**你的质疑是对的！** 使用SharedPreferences确实是一个不好的设计决策。

**正确的做法应该是：**
1. **统一使用Isar数据库**存储所有游标相关数据
2. **建立合适的索引**优化查询性能
3. **使用事务**保证数据一致性
4. **建立数据关系**简化复杂查询

这样既保持了架构的一致性，又获得了更好的性能和可维护性。感谢你的提醒，这是一个很好的架构改进建议！ 