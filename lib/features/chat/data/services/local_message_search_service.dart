import 'dart:async';
import 'package:cc/core/database/models/message.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/database/database_initializer.dart';
import 'package:isar/isar.dart';

/// 本地消息搜索服务 - 基于Isar数据库的全文搜索
/// 废弃，使用ChatRepositoryImpl中的searchMessages方法替代
class LocalMessageSearchService {
  final LogService _logger = LogService.instance;

  // 搜索缓存，避免重复搜索
  final Map<String, LocalSearchResult> _searchCache = {};

  // 搜索历史
  final List<String> _searchHistory = [];
  static const int maxHistorySize = 50;
  static const int maxCacheSize = 20;
  static const Duration cacheValidDuration = Duration(minutes: 5);

  /// 获取数据库实例
  Isar get _isar => DatabaseInitializer.isar;

  /// 搜索消息 - 主要入口方法
  Future<LocalSearchResult> searchMessages({
    required String query,
    List<String>? conversationIds,
    LocalSearchOptions? options,
  }) async {
    if (query.trim().isEmpty) {
      throw const LocalSearchException('搜索关键词不能为空');
    }

    final searchKey = _generateSearchKey(query, conversationIds, options);

    // 检查缓存
    if (_searchCache.containsKey(searchKey)) {
      final cachedResult = _searchCache[searchKey]!;
      if (_isCacheValid(cachedResult)) {
        _logger.d('使用本地搜索缓存', extra: {'query': query});
        return cachedResult;
      } else {
        _searchCache.remove(searchKey);
      }
    }

    final stopwatch = Stopwatch()..start();

    try {
      _logger.i('开始本地消息搜索', extra: {
        'query': query,
        'conversationIds': conversationIds?.length ?? 0,
        'searchMode': options?.searchMode.name ?? 'default',
      });

      // 执行搜索
      final results = await _performSearch(query, conversationIds, options);

      stopwatch.stop();

      final searchResult = LocalSearchResult(
        query: query,
        results: results,
        searchTime: DateTime.now(),
        duration: stopwatch.elapsed,
        totalCount: results.length,
      );

      // 缓存结果
      _searchCache[searchKey] = searchResult;
      _manageCacheSize();

      // 添加到搜索历史
      _addToSearchHistory(query);

      _logger.i('本地搜索完成', extra: {
        'query': query,
        'resultCount': results.length,
        'duration': stopwatch.elapsedMilliseconds,
      });

      return searchResult;
    } catch (error) {
      _logger.e('本地消息搜索失败', error: error, extra: {
        'query': query,
        'conversationIds': conversationIds,
      });

      rethrow;
    }
  }

  /// 全局搜索消息
  Future<LocalSearchResult> searchGlobal({
    required String query,
    LocalSearchOptions? options,
  }) async {
    return searchMessages(
      query: query,
      conversationIds: null, // 全局搜索
      options: options,
    );
  }

  /// 在特定会话中搜索
  Future<LocalSearchResult> searchInConversation({
    required String query,
    required String conversationId,
    LocalSearchOptions? options,
  }) async {
    return searchMessages(
      query: query,
      conversationIds: [conversationId],
      options: options,
    );
  }

  /// 在多个会话中搜索
  Future<LocalSearchResult> searchInConversations({
    required String query,
    required List<String> conversationIds,
    LocalSearchOptions? options,
  }) async {
    return searchMessages(
      query: query,
      conversationIds: conversationIds,
      options: options,
    );
  }

  /// 精确搜索
  Future<LocalSearchResult> searchExact({
    required String query,
    List<String>? conversationIds,
    LocalSearchOptions? options,
  }) async {
    final exactOptions = (options ?? const LocalSearchOptions()).copyWith(
      searchMode: LocalSearchMode.exact,
    );

    return searchMessages(
      query: query,
      conversationIds: conversationIds,
      options: exactOptions,
    );
  }

  /// 模糊搜索
  Future<LocalSearchResult> searchFuzzy({
    required String query,
    List<String>? conversationIds,
    LocalSearchOptions? options,
  }) async {
    final fuzzyOptions = (options ?? const LocalSearchOptions()).copyWith(
      searchMode: LocalSearchMode.fuzzy,
    );

    return searchMessages(
      query: query,
      conversationIds: conversationIds,
      options: fuzzyOptions,
    );
  }

  /// 搜索媒体消息
  Future<LocalSearchResult> searchMedia({
    required String query,
    List<String>? mediaTypes,
    List<String>? conversationIds,
    LocalSearchOptions? options,
  }) async {
    final mediaOptions = (options ?? const LocalSearchOptions()).copyWith(
      messageTypes: mediaTypes ??
          [
            'image',
            'video',
            'voice',
            'file',
          ],
      searchFields: [LocalSearchField.fileName, LocalSearchField.text],
    );

    return searchMessages(
      query: query,
      conversationIds: conversationIds,
      options: mediaOptions,
    );
  }

  /// 按发送者搜索
  Future<LocalSearchResult> searchBySender({
    required String query,
    required String senderId,
    List<String>? conversationIds,
    LocalSearchOptions? options,
  }) async {
    final senderOptions = (options ?? const LocalSearchOptions()).copyWith(
      senderIds: [senderId],
    );

    return searchMessages(
      query: query,
      conversationIds: conversationIds,
      options: senderOptions,
    );
  }

  /// 按时间范围搜索
  Future<LocalSearchResult> searchByTimeRange({
    required String query,
    required DateTime startTime,
    required DateTime endTime,
    List<String>? conversationIds,
    LocalSearchOptions? options,
  }) async {
    final timeOptions = (options ?? const LocalSearchOptions()).copyWith(
      startTime: startTime,
      endTime: endTime,
    );

    return searchMessages(
      query: query,
      conversationIds: conversationIds,
      options: timeOptions,
    );
  }

  /// 获取搜索建议
  Future<List<String>> getSearchSuggestions(String partialQuery) async {
    if (partialQuery.trim().isEmpty) {
      return _getRecentSearches();
    }

    // 从搜索历史中匹配
    final historySuggestions = _searchHistory
        .where(
            (query) => query.toLowerCase().contains(partialQuery.toLowerCase()))
        .take(5)
        .toList();

    // 可以扩展为从本地数据库获取常用词汇建议
    return historySuggestions;
  }

  /// 获取最近搜索
  List<String> getRecentSearches() => _getRecentSearches();

  /// 清除搜索历史
  void clearSearchHistory() {
    _searchHistory.clear();
    _logger.i('搜索历史已清除');
  }

  /// 清除搜索缓存
  void clearSearchCache() {
    _searchCache.clear();
    _logger.i('搜索缓存已清除');
  }

  /// 执行实际的搜索操作
  Future<List<LocalSearchResultItem>> _performSearch(
    String query,
    List<String>? conversationIds,
    LocalSearchOptions? options,
  ) async {
    final searchOptions = options ?? const LocalSearchOptions();

    // 💢💢💢 如果没有指定消息类型，默认只搜索文本消息，避免图片和表情符被包含
    final effectiveSearchOptions = searchOptions.messageTypes == null
        ? searchOptions.copyWith(messageTypes: ['text'])
        : searchOptions;

    // 获取所有消息，然后在内存中过滤
    List<Message> messages;

    if (conversationIds?.isNotEmpty == true) {
      // 如果指定了会话ID，只查询这些会话的消息
      messages = [];
      for (final conversationId in conversationIds!) {
        final conversationMessages = await _isar.messages
            .filter()
            .conversationIdEqualTo(conversationId)
            .sortByCreatedAtDesc()
            .limit(effectiveSearchOptions.limit)
            .findAll();
        messages.addAll(conversationMessages);
      }
    } else {
      // 全局搜索，获取所有消息
      messages = await _isar.messages
          .where()
          .sortByCreatedAtDesc()
          .limit(effectiveSearchOptions.limit * 2) // 获取更多消息以便过滤
          .findAll();
    }

    // 在内存中应用过滤条件
    messages = _applyFilters(messages, effectiveSearchOptions);

    // 文本搜索过滤
    final filteredMessages =
        _filterByText(messages, query, effectiveSearchOptions);

    // 限制结果数量
    if (filteredMessages.length > effectiveSearchOptions.limit) {
      filteredMessages.removeRange(
          effectiveSearchOptions.limit, filteredMessages.length);
    }

    // 转换为搜索结果项并按相关性排序
    final results = filteredMessages.map((message) {
      final highlights =
          _generateHighlights(message, query, effectiveSearchOptions);
      final snippet = _generateSnippet(message, query, effectiveSearchOptions);
      final score =
          _calculateRelevanceScore(message, query, effectiveSearchOptions);

      return LocalSearchResultItem(
        message: message,
        score: score,
        highlights: highlights,
        snippet: snippet,
      );
    }).toList();

    // 按相关性评分排序
    results.sort((a, b) => b.score.compareTo(a.score));

    return results;
  }

  /// 应用过滤条件
  List<Message> _applyFilters(
      List<Message> messages, LocalSearchOptions options) {
    return messages.where((message) {
      // 时间范围过滤
      if (options.startTime != null &&
          message.createdAt.isBefore(options.startTime!)) {
        return false;
      }
      if (options.endTime != null &&
          message.createdAt.isAfter(options.endTime!)) {
        return false;
      }

      // 消息类型过滤
      if (options.messageTypes?.isNotEmpty == true) {
        if (!options.messageTypes!.contains(message.type)) {
          return false;
        }
      }

      // 发送者过滤
      if (options.senderIds?.isNotEmpty == true) {
        if (!options.senderIds!.contains(message.senderId)) {
          return false;
        }
      }

      // 排除已删除的消息（如果消息模型有这个字段）
      // 注意：当前Message模型没有isDeleted字段，所以暂时跳过

      // 只搜索未读消息
      if (options.onlyUnread && message.status == 'read') {
        return false;
      }

      return true;
    }).toList();
  }

  /// 文本搜索过滤
  List<Message> _filterByText(
    List<Message> messages,
    String query,
    LocalSearchOptions options,
  ) {
    final searchFields = options.searchFields ??
        [
          LocalSearchField.text,
          LocalSearchField.fileName,
        ];

    return messages.where((message) {
      return searchFields.any((field) {
        final fieldText = _getFieldText(message, field);
        if (fieldText.isEmpty) return false;

        switch (options.searchMode) {
          case LocalSearchMode.exact:
            return _exactMatch(fieldText, query, options.caseSensitive);
          case LocalSearchMode.fuzzy:
            return _fuzzyMatch(fieldText, query, options.caseSensitive);
          case LocalSearchMode.contains:
            return _containsMatch(fieldText, query, options.caseSensitive);
        }
      });
    }).toList();
  }

  /// 根据字段获取消息文本
  String _getFieldText(Message message, LocalSearchField field) {
    switch (field) {
      case LocalSearchField.text:
        return message.text ?? '';
      case LocalSearchField.fileName:
        return message.fileName ?? '';
      case LocalSearchField.senderName:
        return message.senderName ?? '';
    }
  }

  /// 精确匹配
  bool _exactMatch(String text, String query, bool caseSensitive) {
    if (!caseSensitive) {
      text = text.toLowerCase();
      query = query.toLowerCase();
    }
    return text == query;
  }

  /// 包含匹配
  bool _containsMatch(String text, String query, bool caseSensitive) {
    if (!caseSensitive) {
      text = text.toLowerCase();
      query = query.toLowerCase();
    }
    return text.contains(query);
  }

  /// 模糊匹配（简单实现）
  bool _fuzzyMatch(String text, String query, bool caseSensitive) {
    if (!caseSensitive) {
      text = text.toLowerCase();
      query = query.toLowerCase();
    }

    // 简单的模糊匹配：允许字符间有其他字符
    int queryIndex = 0;
    for (int i = 0; i < text.length && queryIndex < query.length; i++) {
      if (text[i] == query[queryIndex]) {
        queryIndex++;
      }
    }
    return queryIndex == query.length;
  }

  /// 生成高亮片段
  List<String> _generateHighlights(
    Message message,
    String query,
    LocalSearchOptions options,
  ) {
    final highlights = <String>[];
    final searchFields = options.searchFields ?? [LocalSearchField.text];

    for (final field in searchFields) {
      final fieldText = _getFieldText(message, field);
      if (fieldText.isNotEmpty &&
          _containsMatch(fieldText, query, options.caseSensitive)) {
        final highlighted = _highlightText(fieldText, query, options);
        if (highlighted.isNotEmpty) {
          highlights.add(highlighted);
        }
      }
    }

    return highlights;
  }

  /// 高亮文本
  String _highlightText(String text, String query, LocalSearchOptions options) {
    if (!options.caseSensitive) {
      final lowerText = text.toLowerCase();
      final lowerQuery = query.toLowerCase();
      final index = lowerText.indexOf(lowerQuery);
      if (index != -1) {
        final before = text.substring(0, index);
        final match = text.substring(index, index + query.length);
        final after = text.substring(index + query.length);
        return '$before<mark>$match</mark>$after';
      }
    } else {
      final index = text.indexOf(query);
      if (index != -1) {
        final before = text.substring(0, index);
        final match = text.substring(index, index + query.length);
        final after = text.substring(index + query.length);
        return '$before<mark>$match</mark>$after';
      }
    }
    return text;
  }

  /// 生成摘要片段
  String _generateSnippet(
    Message message,
    String query,
    LocalSearchOptions options,
  ) {
    final text = message.text ?? '';
    if (text.isEmpty) return '';

    const snippetLength = 100;

    if (!options.caseSensitive) {
      final lowerText = text.toLowerCase();
      final lowerQuery = query.toLowerCase();
      final index = lowerText.indexOf(lowerQuery);
      if (index != -1) {
        final start = (index - snippetLength ~/ 2).clamp(0, text.length);
        final end =
            (index + query.length + snippetLength ~/ 2).clamp(0, text.length);
        var snippet = text.substring(start, end);
        if (start > 0) snippet = '...$snippet';
        if (end < text.length) snippet = '$snippet...';
        return snippet;
      }
    } else {
      final index = text.indexOf(query);
      if (index != -1) {
        final start = (index - snippetLength ~/ 2).clamp(0, text.length);
        final end =
            (index + query.length + snippetLength ~/ 2).clamp(0, text.length);
        var snippet = text.substring(start, end);
        if (start > 0) snippet = '...$snippet';
        if (end < text.length) snippet = '$snippet...';
        return snippet;
      }
    }

    // 如果没有找到匹配，返回开头的片段
    return text.length > snippetLength
        ? '${text.substring(0, snippetLength)}...'
        : text;
  }

  /// 计算相关性评分
  double _calculateRelevanceScore(
    Message message,
    String query,
    LocalSearchOptions options,
  ) {
    double score = 0.0;

    // 基础分数
    score += 1.0;

    // 文本匹配分数
    final text = message.text ?? '';
    if (text.isNotEmpty) {
      if (_exactMatch(text, query, options.caseSensitive)) {
        score += 10.0; // 精确匹配最高分
      } else if (_containsMatch(text, query, options.caseSensitive)) {
        score += 5.0; // 包含匹配中等分

        // 匹配位置加分（越靠前分数越高）
        final index = options.caseSensitive
            ? text.indexOf(query)
            : text.toLowerCase().indexOf(query.toLowerCase());
        if (index == 0) {
          score += 2.0; // 开头匹配加分
        } else if (index > 0) {
          score += 1.0 / (index + 1); // 位置越靠前分数越高
        }
      }
    }

    // 文件名匹配分数
    final fileName = message.fileName ?? '';
    if (fileName.isNotEmpty &&
        _containsMatch(fileName, query, options.caseSensitive)) {
      score += 3.0;
    }

    // 时间新近度分数（越新分数越高）
    final daysSinceCreated =
        DateTime.now().difference(message.createdAt).inDays;
    score += 1.0 / (daysSinceCreated + 1);

    return score;
  }

  /// 生成搜索键值
  String _generateSearchKey(
    String query,
    List<String>? conversationIds,
    LocalSearchOptions? options,
  ) {
    return '$query:${conversationIds?.join(',')}:${options.hashCode}';
  }

  /// 检查缓存是否有效
  bool _isCacheValid(LocalSearchResult result) {
    return DateTime.now().difference(result.searchTime) < cacheValidDuration;
  }

  /// 管理缓存大小
  void _manageCacheSize() {
    if (_searchCache.length > maxCacheSize) {
      // 移除最旧的缓存项
      final oldestKey = _searchCache.keys.first;
      _searchCache.remove(oldestKey);
    }
  }

  /// 添加到搜索历史
  void _addToSearchHistory(String query) {
    // 移除重复项
    _searchHistory.remove(query);

    // 添加到开头
    _searchHistory.insert(0, query);

    // 限制历史大小
    if (_searchHistory.length > maxHistorySize) {
      _searchHistory.removeRange(maxHistorySize, _searchHistory.length);
    }
  }

  /// 获取最近搜索
  List<String> _getRecentSearches() {
    return List.from(_searchHistory.take(10));
  }
}

/// 本地搜索选项
class LocalSearchOptions {
  final LocalSearchMode searchMode;
  final bool caseSensitive;
  final List<LocalSearchField>? searchFields;
  final List<String>? messageTypes;
  final List<String>? senderIds;
  final DateTime? startTime;
  final DateTime? endTime;
  final bool excludeDeleted;
  final bool excludeRevoked;
  final bool onlyUnread;
  final int limit;

  const LocalSearchOptions({
    this.searchMode = LocalSearchMode.contains,
    this.caseSensitive = false,
    this.searchFields,
    this.messageTypes,
    this.senderIds,
    this.startTime,
    this.endTime,
    this.excludeDeleted = true,
    this.excludeRevoked = true,
    this.onlyUnread = false,
    this.limit = 100,
  });

  LocalSearchOptions copyWith({
    LocalSearchMode? searchMode,
    bool? caseSensitive,
    List<LocalSearchField>? searchFields,
    List<String>? messageTypes,
    List<String>? senderIds,
    DateTime? startTime,
    DateTime? endTime,
    bool? excludeDeleted,
    bool? excludeRevoked,
    bool? onlyUnread,
    int? limit,
  }) {
    return LocalSearchOptions(
      searchMode: searchMode ?? this.searchMode,
      caseSensitive: caseSensitive ?? this.caseSensitive,
      searchFields: searchFields ?? this.searchFields,
      messageTypes: messageTypes ?? this.messageTypes,
      senderIds: senderIds ?? this.senderIds,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      excludeDeleted: excludeDeleted ?? this.excludeDeleted,
      excludeRevoked: excludeRevoked ?? this.excludeRevoked,
      onlyUnread: onlyUnread ?? this.onlyUnread,
      limit: limit ?? this.limit,
    );
  }

  @override
  int get hashCode => Object.hash(
        searchMode,
        caseSensitive,
        searchFields,
        messageTypes,
        senderIds,
        startTime,
        endTime,
        excludeDeleted,
        excludeRevoked,
        onlyUnread,
        limit,
      );

  @override
  bool operator ==(Object other) {
    // TODO implement ==
    return super == other;
  }
}

/// 本地搜索模式
enum LocalSearchMode {
  exact, // 精确匹配
  contains, // 包含匹配
  fuzzy, // 模糊匹配
}

/// 本地搜索字段
enum LocalSearchField {
  text, // 消息文本
  fileName, // 文件名
  senderName, // 发送者名称
  // locationAddress, // 位置地址 - 已移除
}

/// 本地搜索结果
class LocalSearchResult {
  final String query;
  final List<LocalSearchResultItem> results;
  final DateTime searchTime;
  final Duration duration;
  final int totalCount;

  const LocalSearchResult({
    required this.query,
    required this.results,
    required this.searchTime,
    required this.duration,
    required this.totalCount,
  });
}

/// 本地搜索结果项
class LocalSearchResultItem {
  final Message message;
  final double score;
  final List<String> highlights;
  final String snippet;

  const LocalSearchResultItem({
    required this.message,
    required this.score,
    required this.highlights,
    required this.snippet,
  });
}

/// 本地搜索异常
class LocalSearchException implements Exception {
  final String message;

  const LocalSearchException(this.message);

  @override
  String toString() => 'LocalSearchException: $message';
}
