# 本地消息搜索设计文档

## 概述

本项目采用纯本地搜索方案，基于Isar数据库实现消息的全文搜索功能。所有搜索操作都在本地进行，不依赖服务器端搜索接口。

## 设计原则

### 1. 纯本地化
- 所有搜索操作在本地Isar数据库中进行
- 不需要网络连接即可搜索历史消息
- 保护用户隐私，搜索内容不会发送到服务器

### 2. 高性能
- 使用内存缓存避免重复搜索
- 智能的搜索结果限制和分页
- 相关性评分和排序优化

### 3. 灵活性
- 支持多种搜索模式（精确、包含、模糊）
- 可配置的搜索字段和过滤条件
- 丰富的搜索选项和参数

## 核心组件

### 1. LocalMessageSearchService
主要的搜索服务类，提供以下功能：

#### 基础搜索方法
- `searchGlobal()` - 全局搜索
- `searchInConversation()` - 单会话搜索
- `searchInConversations()` - 多会话搜索

#### 专门搜索方法
- `searchExact()` - 精确搜索
- `searchFuzzy()` - 模糊搜索
- `searchMedia()` - 媒体消息搜索
- `searchBySender()` - 按发送者搜索
- `searchByTimeRange()` - 按时间范围搜索

#### 辅助功能
- `getSearchSuggestions()` - 搜索建议
- `getRecentSearches()` - 最近搜索
- `clearSearchHistory()` - 清除搜索历史
- `clearSearchCache()` - 清除搜索缓存

### 2. 搜索选项类

#### LocalSearchOptions
配置搜索行为的选项类：
```dart
class LocalSearchOptions {
  final LocalSearchMode searchMode;      // 搜索模式
  final bool caseSensitive;              // 是否区分大小写
  final List<LocalSearchField>? searchFields; // 搜索字段
  final List<String>? messageTypes;      // 消息类型过滤
  final List<String>? senderIds;         // 发送者过滤
  final DateTime? startTime;             // 开始时间
  final DateTime? endTime;               // 结束时间
  final bool excludeDeleted;             // 排除已删除
  final bool excludeRevoked;             // 排除已撤销
  final bool onlyUnread;                 // 只搜索未读
  final int limit;                       // 结果数量限制
}
```

#### 枚举类型
```dart
enum LocalSearchMode {
  exact,     // 精确匹配
  contains,  // 包含匹配
  fuzzy,     // 模糊匹配
}

enum LocalSearchField {
  text,            // 消息文本
  fileName,        // 文件名
  senderName,      // 发送者名称
  locationAddress, // 位置地址
}
```

### 3. 搜索结果类

#### LocalSearchResult
搜索结果的容器类：
```dart
class LocalSearchResult {
  final String query;                           // 搜索关键词
  final List<LocalSearchResultItem> results;    // 搜索结果列表
  final DateTime searchTime;                    // 搜索时间
  final Duration duration;                      // 搜索耗时
  final int totalCount;                         // 总结果数
}
```

#### LocalSearchResultItem
单个搜索结果项：
```dart
class LocalSearchResultItem {
  final Message message;        // 消息对象
  final double score;           // 相关性评分
  final List<String> highlights; // 高亮片段
  final String snippet;         // 摘要片段
}
```

## 搜索流程

### 1. 搜索执行流程
```
用户输入查询 → 检查缓存 → 构建Isar查询 → 执行数据库查询 → 
内存过滤 → 文本匹配 → 相关性评分 → 排序 → 返回结果 → 缓存结果
```

### 2. 查询优化策略

#### 数据库查询优化
- 优先使用会话ID过滤减少查询范围
- 使用时间范围限制查询结果
- 合理设置查询限制避免内存溢出

#### 内存过滤优化
- 先进行快速过滤（类型、发送者等）
- 再进行文本匹配（相对耗时）
- 最后进行相关性评分和排序

### 3. 相关性评分算法

评分因素包括：
- **精确匹配**：完全匹配给最高分（10分）
- **包含匹配**：部分匹配给中等分（5分）
- **位置权重**：匹配位置越靠前分数越高
- **文件名匹配**：文件名匹配额外加分（3分）
- **时间新近度**：越新的消息分数越高

## 缓存策略

### 1. 搜索结果缓存
- 缓存最近20次搜索结果
- 缓存有效期5分钟
- 使用搜索键值进行缓存管理

### 2. 搜索历史管理
- 保存最近50次搜索关键词
- 支持搜索建议功能
- 可手动清除搜索历史

## 性能优化

### 1. 查询优化
- 使用Isar的索引加速查询
- 合理限制查询结果数量
- 优先查询最相关的会话

### 2. 内存管理
- 及时释放不需要的搜索结果
- 控制缓存大小避免内存泄漏
- 使用流式处理大量结果

### 3. 用户体验优化
- 提供搜索进度指示
- 支持搜索取消操作
- 实现搜索建议和自动完成

## 扩展性设计

### 1. 搜索算法扩展
- 支持更复杂的模糊匹配算法
- 可添加拼音搜索支持
- 支持正则表达式搜索

### 2. 搜索字段扩展
- 可添加更多消息字段搜索
- 支持自定义字段权重
- 支持多语言搜索

### 3. 结果展示扩展
- 支持搜索结果分组
- 提供搜索统计信息
- 支持搜索结果导出

## 使用示例

### 基础搜索
```dart
final searchService = LocalMessageSearchService();

// 全局搜索
final result = await searchService.searchGlobal(query: '重要');

// 会话内搜索
final result = await searchService.searchInConversation(
  query: '文件',
  conversationId: 'conversation_123',
);
```

### 高级搜索
```dart
// 精确搜索
final result = await searchService.searchExact(
  query: '明天开会',
  options: LocalSearchOptions(
    caseSensitive: false,
    limit: 50,
  ),
);

// 媒体搜索
final result = await searchService.searchMedia(
  query: '报告',
  mediaTypes: ['file', 'image'],
);
```

## 注意事项

### 1. 性能考虑
- 大量消息时搜索可能较慢
- 建议合理设置搜索限制
- 考虑在后台线程执行搜索

### 2. 内存使用
- 搜索会将消息加载到内存
- 及时清理不需要的缓存
- 监控内存使用情况

### 3. 用户体验
- 提供搜索状态反馈
- 支持搜索历史和建议
- 合理的搜索结果展示

## 总结

本地消息搜索方案提供了完整的离线搜索能力，具有以下优势：

1. **隐私保护**：所有搜索在本地进行，不会泄露用户数据
2. **快速响应**：无需网络请求，搜索响应迅速
3. **功能丰富**：支持多种搜索模式和过滤条件
4. **易于扩展**：模块化设计便于功能扩展

通过合理的缓存策略和性能优化，可以为用户提供流畅的搜索体验。 