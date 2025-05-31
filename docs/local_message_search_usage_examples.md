# 本地消息搜索服务使用示例

本文档展示如何使用基于Isar数据库的本地消息搜索功能。

## 目录

1. [基础搜索示例](#基础搜索示例)
2. [高级搜索功能](#高级搜索功能)
3. [搜索选项配置](#搜索选项配置)
4. [最佳实践](#最佳实践)

## 基础搜索示例

### 1. 全局搜索

```dart
// 创建搜索服务实例
final searchService = LocalMessageSearchService();

// 全局搜索包含"重要"的消息
final result = await searchService.searchGlobal(
  query: '重要',
);

print('搜索到 ${result.results.length} 条消息');
print('搜索耗时: ${result.duration.inMilliseconds}ms');

for (final item in result.results) {
  print('评分: ${item.score.toStringAsFixed(2)}');
  print('消息: ${item.message.text}');
  print('片段: ${item.snippet}');
  print('高亮: ${item.highlights.join(', ')}');
  print('---');
}
```

### 2. 在特定会话中搜索

```dart
// 在特定会话中搜索
final result = await searchService.searchInConversation(
  query: '文件',
  conversationId: 'conversation_123',
);

print('在会话中找到 ${result.results.length} 条相关消息');
```

### 3. 在多个会话中搜索

```dart
// 在多个会话中搜索
final result = await searchService.searchInConversations(
  query: '项目',
  conversationIds: ['conversation_123', 'conversation_456', 'conversation_789'],
);

print('在指定会话中找到 ${result.results.length} 条消息');
```

## 高级搜索功能

### 1. 精确搜索

```dart
// 精确匹配搜索
final result = await searchService.searchExact(
  query: '明天开会',
  options: LocalSearchOptions(
    caseSensitive: false, // 不区分大小写
    limit: 50,
  ),
);

print('精确匹配结果: ${result.results.length} 条');
```

### 2. 模糊搜索

```dart
// 模糊搜索，允许字符间有其他字符
final result = await searchService.searchFuzzy(
  query: '会议',
  options: LocalSearchOptions(
    limit: 30,
  ),
);

print('模糊搜索结果: ${result.results.length} 条');
```

### 3. 搜索媒体消息

```dart
// 搜索包含特定关键词的媒体文件
final result = await searchService.searchMedia(
  query: '报告',
  mediaTypes: ['file', 'image'], // 只搜索文件和图片
  options: LocalSearchOptions(
    searchFields: [
      LocalSearchField.fileName,
      LocalSearchField.text,
    ],
  ),
);

print('找到相关媒体文件: ${result.results.length} 个');
for (final item in result.results) {
  final message = item.message;
  print('文件: ${message.fileName} (${message.fileSize}KB)');
  print('类型: ${message.type}');
}
```

### 4. 按发送者搜索

```dart
// 搜索特定用户发送的消息
final result = await searchService.searchBySender(
  query: '任务',
  senderId: 'user_123',
  options: LocalSearchOptions(
    limit: 20,
  ),
);

print('该用户关于任务的消息: ${result.results.length} 条');
```

### 5. 按时间范围搜索

```dart
// 搜索上周的消息
final now = DateTime.now();
final lastWeekStart = now.subtract(const Duration(days: 14));
final lastWeekEnd = now.subtract(const Duration(days: 7));

final result = await searchService.searchByTimeRange(
  query: '重要',
  startTime: lastWeekStart,
  endTime: lastWeekEnd,
);

print('上周包含"重要"的消息: ${result.results.length} 条');
```

## 搜索选项配置

### 1. 基础选项

```dart
final options = LocalSearchOptions(
  searchMode: LocalSearchMode.contains, // 搜索模式
  caseSensitive: false, // 是否区分大小写
  limit: 100, // 结果数量限制
);
```

### 2. 搜索字段配置

```dart
final options = LocalSearchOptions(
  searchFields: [
    LocalSearchField.text,        // 搜索消息文本
    LocalSearchField.fileName,    // 搜索文件名
    LocalSearchField.senderName,  // 搜索发送者名称
    LocalSearchField.locationAddress, // 搜索位置地址
  ],
);
```

### 3. 消息类型过滤

```dart
final options = LocalSearchOptions(
  messageTypes: [
    'text',     // 文本消息
    'image',    // 图片消息
    'file',     // 文件消息
    'voice',    // 语音消息
  ],
);
```

### 4. 发送者过滤

```dart
final options = LocalSearchOptions(
  senderIds: ['user_123', 'user_456'], // 只搜索这些用户的消息
);
```

### 5. 时间范围过滤

```dart
final options = LocalSearchOptions(
  startTime: DateTime.now().subtract(const Duration(days: 30)), // 30天前
  endTime: DateTime.now(), // 现在
);
```

### 6. 其他过滤选项

```dart
final options = LocalSearchOptions(
  excludeDeleted: true,  // 排除已删除消息
  excludeRevoked: true,  // 排除已撤销消息
  onlyUnread: false,     // 只搜索未读消息
);
```

## 搜索建议和历史

### 1. 获取搜索建议

```dart
// 获取基于输入的搜索建议
final suggestions = await searchService.getSearchSuggestions('项目');
print('搜索建议: ${suggestions.join(', ')}');

// 获取最近搜索历史
final recentSearches = searchService.getRecentSearches();
print('最近搜索: ${recentSearches.join(', ')}');
```

### 2. 管理搜索历史

```dart
// 清除搜索历史
searchService.clearSearchHistory();

// 清除搜索缓存
searchService.clearSearchCache();
```

## 最佳实践

### 1. 搜索性能优化

```dart
class OptimizedSearchManager {
  final LocalMessageSearchService _searchService = LocalMessageSearchService();
  
  /// 智能搜索 - 根据查询内容选择最佳搜索策略
  Future<LocalSearchResult> smartSearch(String query) async {
    // 根据查询长度和内容选择搜索模式
    LocalSearchMode mode;
    if (query.length <= 2) {
      mode = LocalSearchMode.exact; // 短查询使用精确匹配
    } else if (query.contains(' ')) {
      mode = LocalSearchMode.contains; // 多词查询使用包含匹配
    } else {
      mode = LocalSearchMode.fuzzy; // 单词查询使用模糊匹配
    }
    
    return await _searchService.searchGlobal(
      query: query,
      options: LocalSearchOptions(
        searchMode: mode,
        limit: 50,
      ),
    );
  }
  
  /// 分类搜索 - 按消息类型分别搜索
  Future<Map<String, LocalSearchResult>> categorizedSearch(String query) async {
    final results = <String, LocalSearchResult>{};
    
    // 搜索文本消息
    results['text'] = await _searchService.searchGlobal(
      query: query,
      options: LocalSearchOptions(
        messageTypes: ['text'],
        searchFields: [LocalSearchField.text],
      ),
    );
    
    // 搜索文件
    results['files'] = await _searchService.searchMedia(
      query: query,
      mediaTypes: ['file'],
    );
    
    // 搜索图片
    results['images'] = await _searchService.searchMedia(
      query: query,
      mediaTypes: ['image'],
    );
    
    return results;
  }
}
```

### 2. 搜索结果处理

```dart
class SearchResultProcessor {
  /// 格式化搜索结果用于显示
  List<SearchDisplayItem> formatResults(LocalSearchResult result) {
    return result.results.map((item) {
      return SearchDisplayItem(
        messageId: item.message.messageId,
        conversationId: item.message.conversationId,
        senderName: item.message.senderName ?? '未知用户',
        content: _formatContent(item.message),
        snippet: item.snippet,
        highlights: item.highlights,
        score: item.score,
        timestamp: item.message.createdAt,
        messageType: item.message.type,
      );
    }).toList();
  }
  
  String _formatContent(Message message) {
    switch (message.type) {
      case 'text':
        return message.text ?? '';
      case 'image':
        return '[图片] ${message.fileName ?? ''}';
      case 'file':
        return '[文件] ${message.fileName ?? ''}';
      case 'voice':
        return '[语音] ${message.duration ?? 0}秒';
      case 'video':
        return '[视频] ${message.fileName ?? ''}';
      case 'location':
        return '[位置] ${message.locationAddress ?? ''}';
      default:
        return '[${message.type}]';
    }
  }
}

class SearchDisplayItem {
  final String messageId;
  final String conversationId;
  final String senderName;
  final String content;
  final String snippet;
  final List<String> highlights;
  final double score;
  final DateTime timestamp;
  final String messageType;
  
  const SearchDisplayItem({
    required this.messageId,
    required this.conversationId,
    required this.senderName,
    required this.content,
    required this.snippet,
    required this.highlights,
    required this.score,
    required this.timestamp,
    required this.messageType,
  });
}
```

### 3. 错误处理

```dart
class RobustSearchService {
  final LocalMessageSearchService _searchService = LocalMessageSearchService();
  
  Future<LocalSearchResult?> safeSearch(String query) async {
    try {
      return await _searchService.searchGlobal(query: query);
    } on LocalSearchException catch (e) {
      print('搜索失败: ${e.message}');
      return null;
    } catch (e) {
      print('搜索出现未知错误: $e');
      return null;
    }
  }
  
  /// 带重试的搜索
  Future<LocalSearchResult?> searchWithRetry(
    String query, {
    int maxRetries = 3,
  }) async {
    for (int i = 0; i < maxRetries; i++) {
      try {
        return await _searchService.searchGlobal(query: query);
      } catch (e) {
        print('搜索失败，第 ${i + 1} 次重试: $e');
        if (i == maxRetries - 1) rethrow;
        await Future.delayed(Duration(milliseconds: 500 * (i + 1)));
      }
    }
    return null;
  }
}
```

### 4. 搜索缓存管理

```dart
class SearchCacheManager {
  final LocalMessageSearchService _searchService = LocalMessageSearchService();
  
  /// 预热搜索缓存
  Future<void> warmupCache(List<String> commonQueries) async {
    for (final query in commonQueries) {
      try {
        await _searchService.searchGlobal(query: query);
        print('预热缓存: $query');
      } catch (e) {
        print('预热失败: $query - $e');
      }
    }
  }
  
  /// 定期清理缓存
  void scheduleCleanup() {
    Timer.periodic(const Duration(hours: 1), (timer) {
      _searchService.clearSearchCache();
      print('定期清理搜索缓存');
    });
  }
}
```

## 使用注意事项

1. **性能考虑**：
   - 本地搜索在大量消息时可能较慢，建议限制搜索结果数量
   - 使用缓存机制避免重复搜索
   - 考虑在后台线程执行搜索操作

2. **搜索准确性**：
   - 模糊搜索可能返回不太相关的结果
   - 精确搜索可能遗漏相关内容
   - 建议根据用户需求选择合适的搜索模式

3. **内存使用**：
   - 搜索会将消息加载到内存中
   - 大量搜索结果可能占用较多内存
   - 及时清理不需要的搜索缓存

4. **用户体验**：
   - 提供搜索建议提升用户体验
   - 显示搜索进度和结果统计
   - 支持搜索历史记录

这个本地搜索服务提供了强大而灵活的消息搜索功能，可以满足各种搜索需求。通过合理配置搜索选项和优化搜索策略，可以为用户提供快速准确的搜索体验。 