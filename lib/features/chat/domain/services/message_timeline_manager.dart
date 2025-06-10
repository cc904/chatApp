import '../entities/message_cursor.dart';
import '../entities/message_cursor_pair.dart';
import '../../data/repositories/message_timeline_repository_isar.dart';
import 'package:cc/core/database/models/message_cursor_pair.dart';
import 'package:cc/core/services/log_service.dart';

/// 消息时间线管理器
/// 负责管理多个游标对，实现智能的消息同步策略
class MessageTimelineManager {
  /// 会话ID
  final String conversationId;

  /// Isar持久化仓库
  final MessageTimelineRepositoryIsar _isarRepository;

  /// 游标对列表（按时间顺序排序）
  final Map<DateTime, MessageCursorPair> _cursorPairs =
      <DateTime, MessageCursorPair>{};

  /// 当前活跃的游标对（用户正在查看的部分）
  MessageCursorPair? _activeCursorPair;

  /// 自动同步开关
  bool _autoSyncEnabled;

  /// 预加载范围（小时）
  final int _preloadHours;

  /// 最大空档时长（小时），超过这个时长才认为是空档
  final int _maxGapHours;

  /// 是否已初始化（从持久化存储加载）
  bool _isInitialized = false;

  final LogService _logger = LogService.instance;

  MessageTimelineManager({
    required this.conversationId,
    MessageTimelineRepositoryIsar? isarRepository,
    bool autoSyncEnabled = true,
    int preloadHours = 24,
    int maxGapHours = 1,
  })  : _isarRepository = isarRepository ?? MessageTimelineRepositoryIsar(),
        _autoSyncEnabled = autoSyncEnabled,
        _preloadHours = preloadHours,
        _maxGapHours = maxGapHours;

  /// 确保已初始化（从持久化存储加载数据）
  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;

    try {
      // 从Isar加载数据
      final isarPairs =
          await _isarRepository.getPairsByConversation(conversationId);
      _cursorPairs.clear();

      for (final isarPair in isarPairs) {
        final domainPair = _convertFromIsarModel(isarPair);
        if (domainPair != null) {
          _cursorPairs[domainPair.startCursor.timestamp!] = domainPair;

          // 恢复活跃游标对（实时类型的通常是活跃的）
          if (domainPair.type == CursorPairType.realtime &&
              _activeCursorPair == null) {
            _activeCursorPair = domainPair;
          }
        }
      }

      _isInitialized = true;
    } catch (error) {
      // 初始化失败时使用空状态
      _isInitialized = true;
    }
  }

  /// 将Isar模型转换为领域模型
  MessageCursorPair? _convertFromIsarModel(MessageCursorPairModel isarPair) {
    try {
      final startCursor = MessageCursor(
        messageId: isarPair.startCursorMessageId,
        position: isarPair.startCursorPosition,
        timestamp: isarPair.startCursorTimestamp,
      );

      final endCursor = MessageCursor(
        messageId: isarPair.endCursorMessageId,
        position: isarPair.endCursorPosition,
        timestamp: isarPair.endCursorTimestamp,
      );

      // 根据类型创建对应的游标对
      CursorPairType type;
      switch (isarPair.type) {
        case 'history':
          type = CursorPairType.history;
          break;
        case 'realtime':
          type = CursorPairType.realtime;
          break;
        case 'gap':
          type = CursorPairType.gap;
          break;
        default:
          type = CursorPairType.history;
      }

      return MessageCursorPair(
        id: isarPair.pairId,
        conversationId: isarPair.conversationId,
        type: type,
        startCursor: startCursor,
        endCursor: endCursor,
        messageCount: isarPair.messageCount,
        isSynced: isarPair.isSynced,
        priority: isarPair.priority,
        createdAt: isarPair.createdAt,
        updatedAt: isarPair.updatedAt,
        metadata: isarPair.metadataJson != null ? Map<String, dynamic>.from(
            // 这里需要JSON解析，但为了简化先返回空Map
            <String, dynamic>{}) : null,
      );
    } catch (error) {
      _logger.e('转换Isar模型失败', error: error);
      return null;
    }
  }

  /// 将领域模型转换为Isar模型
  MessageCursorPairModel _convertToIsarModel(MessageCursorPair domainPair) {
    final isarPair = MessageCursorPairModel()
      ..pairId = domainPair.id
      ..conversationId = domainPair.conversationId
      ..type = domainPair.type.toString().split('.').last
      ..startCursorMessageId = domainPair.startCursor.messageId
      ..startCursorPosition = domainPair.startCursor.position
      ..startCursorTimestamp = domainPair.startCursor.timestamp
      ..endCursorMessageId = domainPair.endCursor.messageId
      ..endCursorPosition = domainPair.endCursor.position
      ..endCursorTimestamp = domainPair.endCursor.timestamp
      ..messageCount = domainPair.messageCount ?? 0
      ..isSynced = domainPair.isSynced
      ..priority = domainPair.priority
      ..metadataJson = domainPair.metadata != null
          ? '{}' // 简化处理，实际应该JSON序列化
          : null
      ..createdAt = domainPair.createdAt
      ..updatedAt = domainPair.updatedAt;

    return isarPair;
  }

  /// 添加历史消息段
  Future<void> addHistorySegment({
    required MessageCursor startCursor,
    required MessageCursor endCursor,
    int? messageCount,
    bool isSynced = true,
  }) async {
    await _ensureInitialized();

    final pair = MessageCursorPair.history(
      conversationId: conversationId,
      startCursor: startCursor,
      endCursor: endCursor,
      messageCount: messageCount,
      isSynced: isSynced,
    );

    await _addCursorPairWithPersistence(pair);
  }

  /// 添加实时消息段
  Future<void> addRealtimeSegment({
    required MessageCursor startCursor,
    required MessageCursor endCursor,
    int? messageCount,
  }) async {
    await _ensureInitialized();

    final pair = MessageCursorPair.realtime(
      conversationId: conversationId,
      startCursor: startCursor,
      endCursor: endCursor,
      messageCount: messageCount,
    );

    await _addCursorPairWithPersistence(pair);
    _activeCursorPair = pair; // 实时段默认为活跃段
  }

  /// 检测并创建空档游标对
  Future<List<MessageCursorPair>> detectGaps() async {
    await _ensureInitialized();

    final gaps = <MessageCursorPair>[];
    final pairs = _getSortedPairs();

    for (int i = 0; i < pairs.length - 1; i++) {
      final current = pairs[i];
      final next = pairs[i + 1];

      // 检查相邻段之间是否有空档
      if (_hasSignificantGap(current.endCursor, next.startCursor)) {
        final gap = MessageCursorPair.gap(
          conversationId: conversationId,
          startCursor: current.endCursor,
          endCursor: next.startCursor,
          metadata: {
            'beforePair': current.id,
            'afterPair': next.id,
            'gapHours': _calculateGapHours(current.endCursor, next.startCursor),
          },
        );
        gaps.add(gap);
      }
    }

    return gaps;
  }

  /// 自动填充空档
  Future<void> fillGaps() async {
    final gaps = await detectGaps();
    for (final gap in gaps) {
      await _addCursorPairWithPersistence(gap);
    }
  }

  /// 获取优先级最高的待同步游标对
  MessageCursorPair? getNextSyncTarget() {
    final unsyncedPairs =
        _cursorPairs.values.where((pair) => !pair.isSynced).toList();

    if (unsyncedPairs.isEmpty) return null;

    // 按优先级排序
    unsyncedPairs.sort((a, b) => b.priority.compareTo(a.priority));

    // 优先考虑活跃段附近的空档
    if (_activeCursorPair != null) {
      final nearActiveGaps = unsyncedPairs
          .where((pair) => pair.type == CursorPairType.gap)
          .where((gap) => _isNearActivePair(gap))
          .toList();

      if (nearActiveGaps.isNotEmpty) {
        return nearActiveGaps.first;
      }
    }

    return unsyncedPairs.first;
  }

  /// 获取需要预加载的游标对
  List<MessageCursorPair> getPreloadTargets() {
    if (_activeCursorPair == null) return [];

    final preloadTargets = <MessageCursorPair>[];
    final activeStart = _activeCursorPair!.startCursor.timestamp!;
    final activeEnd = _activeCursorPair!.endCursor.timestamp!;

    // 预加载时间范围
    final preloadBefore = activeStart.subtract(Duration(hours: _preloadHours));
    final preloadAfter = activeEnd.add(Duration(hours: _preloadHours));

    for (final pair in _cursorPairs.values) {
      if (pair.isSynced) continue;

      final pairStart = pair.startCursor.timestamp!;
      final pairEnd = pair.endCursor.timestamp!;

      // 检查是否在预加载范围内
      if ((pairEnd.isAfter(preloadBefore) && pairStart.isBefore(activeStart)) ||
          (pairStart.isBefore(preloadAfter) && pairEnd.isAfter(activeEnd))) {
        preloadTargets.add(pair);
      }
    }

    // 按优先级排序
    preloadTargets.sort((a, b) => b.priority.compareTo(a.priority));
    return preloadTargets;
  }

  /// 标记游标对为已同步
  Future<void> markAsSynced(String cursorPairId,
      {int? actualMessageCount}) async {
    await _ensureInitialized();

    final pair = _findPairById(cursorPairId);
    if (pair != null) {
      final updatedPair = pair.copyWith(
        isSynced: true,
        messageCount: actualMessageCount ?? pair.messageCount,
      );
      await _updateCursorPairWithPersistence(updatedPair);
    }
  }

  /// 合并相邻的兼容游标对
  void optimizeTimeline() {
    final pairs = _getSortedPairs();
    final toMerge = <List<MessageCursorPair>>[];
    var currentGroup = <MessageCursorPair>[];

    for (final pair in pairs) {
      if (currentGroup.isEmpty) {
        currentGroup.add(pair);
      } else {
        final lastPair = currentGroup.last;
        if (lastPair.canMergeWith(pair)) {
          currentGroup.add(pair);
        } else {
          if (currentGroup.length > 1) {
            toMerge.add(List.from(currentGroup));
          }
          currentGroup = [pair];
        }
      }
    }

    // 处理最后一组
    if (currentGroup.length > 1) {
      toMerge.add(currentGroup);
    }

    // 执行合并
    for (final group in toMerge) {
      _mergeGroup(group);
    }
  }

  /// 获取时间线统计信息
  TimelineStats getStats() {
    final pairs = _cursorPairs.values.toList();
    final syncedPairs = pairs.where((p) => p.isSynced).length;
    final gapPairs = pairs.where((p) => p.type == CursorPairType.gap).length;
    final totalMessages = pairs
        .where((p) => p.messageCount != null)
        .fold(0, (sum, p) => sum + p.messageCount!);

    var totalTimeSpan = Duration.zero;
    var syncedTimeSpan = Duration.zero;

    for (final pair in pairs) {
      final span =
          pair.endCursor.timestamp!.difference(pair.startCursor.timestamp!);
      totalTimeSpan += span;
      if (pair.isSynced) {
        syncedTimeSpan += span;
      }
    }

    return TimelineStats(
      totalPairs: pairs.length,
      syncedPairs: syncedPairs,
      gapPairs: gapPairs,
      totalMessages: totalMessages,
      totalTimeSpan: totalTimeSpan,
      syncedTimeSpan: syncedTimeSpan,
      coveragePercentage: totalTimeSpan.inMilliseconds > 0
          ? (syncedTimeSpan.inMilliseconds / totalTimeSpan.inMilliseconds * 100)
          : 0.0,
    );
  }

  /// 导出时间线状态（用于调试）
  Map<String, dynamic> exportTimeline() {
    return {
      'conversationId': conversationId,
      'activePairId': _activeCursorPair?.id,
      'autoSyncEnabled': _autoSyncEnabled,
      'pairs': _cursorPairs.values.map((p) => p.toMap()).toList(),
      'stats': getStats().toMap(),
    };
  }

  /// 从导出数据恢复时间线
  void importTimeline(Map<String, dynamic> data) {
    _cursorPairs.clear();

    final pairsData = data['pairs'] as List<dynamic>;
    for (final pairData in pairsData) {
      final pair = MessageCursorPair.fromMap(pairData as Map<String, dynamic>);
      _addCursorPair(pair);
    }

    final activePairId = data['activePairId'] as String?;
    if (activePairId != null) {
      _activeCursorPair = _findPairById(activePairId);
    }

    _autoSyncEnabled = data['autoSyncEnabled'] ?? true;
  }

  // 私有方法

  void _addCursorPair(MessageCursorPair pair) {
    _cursorPairs[pair.startCursor.timestamp!] = pair;
    _tryMergeWithAdjacent(pair);
  }

  /// 添加游标对并持久化
  Future<void> _addCursorPairWithPersistence(MessageCursorPair pair) async {
    _addCursorPair(pair);
    try {
      final isarPair = _convertToIsarModel(pair);
      await _isarRepository.savePair(isarPair);
    } catch (error) {
      // 持久化失败时只记录错误，不影响内存操作
      // 在实际项目中应该使用日志系统
      _logger.e('持久化游标对失败', error: error);
    }
  }

  void _updateCursorPair(MessageCursorPair pair) {
    // 先移除旧的
    _cursorPairs.removeWhere((_, p) => p.id == pair.id);
    // 再添加新的
    _addCursorPair(pair);
  }

  /// 更新游标对并持久化
  Future<void> _updateCursorPairWithPersistence(MessageCursorPair pair) async {
    _updateCursorPair(pair);
    try {
      final isarPair = _convertToIsarModel(pair);
      await _isarRepository.savePair(isarPair);
    } catch (error) {
      _logger.e('持久化更新游标对失败', error: error);
    }
  }

  MessageCursorPair? _findPairById(String id) {
    try {
      return _cursorPairs.values.firstWhere((pair) => pair.id == id);
    } catch (e) {
      return null;
    }
  }

  List<MessageCursorPair> _getSortedPairs() {
    final pairs = _cursorPairs.values.toList();
    pairs.sort(
        (a, b) => a.startCursor.timestamp!.compareTo(b.startCursor.timestamp!));
    return pairs;
  }

  bool _hasSignificantGap(MessageCursor cursor1, MessageCursor cursor2) {
    if (cursor1.timestamp == null || cursor2.timestamp == null) return false;

    final gap = cursor2.timestamp!.difference(cursor1.timestamp!);
    return gap.inHours >= _maxGapHours;
  }

  double _calculateGapHours(MessageCursor cursor1, MessageCursor cursor2) {
    if (cursor1.timestamp == null || cursor2.timestamp == null) return 0.0;

    return cursor2.timestamp!.difference(cursor1.timestamp!).inMinutes / 60.0;
  }

  bool _isNearActivePair(MessageCursorPair gap) {
    if (_activeCursorPair == null) return false;

    final activeStart = _activeCursorPair!.startCursor.timestamp!;
    final activeEnd = _activeCursorPair!.endCursor.timestamp!;
    final gapStart = gap.startCursor.timestamp!;
    final gapEnd = gap.endCursor.timestamp!;

    // 检查空档是否与活跃段相邻或重叠
    return !(gapEnd.isBefore(activeStart.subtract(const Duration(hours: 1))) ||
        gapStart.isAfter(activeEnd.add(const Duration(hours: 1))));
  }

  void _tryMergeWithAdjacent(MessageCursorPair newPair) {
    final pairs = _getSortedPairs();
    final newIndex = pairs.indexWhere((p) => p.id == newPair.id);

    if (newIndex == -1) return;

    // 尝试与前一个合并
    if (newIndex > 0) {
      final prevPair = pairs[newIndex - 1];
      if (newPair.canMergeWith(prevPair)) {
        final merged = prevPair.mergeWith(newPair);
        _cursorPairs
            .removeWhere((_, p) => p.id == prevPair.id || p.id == newPair.id);
        _addCursorPair(merged);
        return;
      }
    }

    // 尝试与后一个合并
    if (newIndex < pairs.length - 1) {
      final nextPair = pairs[newIndex + 1];
      if (newPair.canMergeWith(nextPair)) {
        final merged = newPair.mergeWith(nextPair);
        _cursorPairs
            .removeWhere((_, p) => p.id == newPair.id || p.id == nextPair.id);
        _addCursorPair(merged);
      }
    }
  }

  void _mergeGroup(List<MessageCursorPair> group) {
    if (group.length < 2) return;

    var merged = group.first;
    for (int i = 1; i < group.length; i++) {
      merged = merged.mergeWith(group[i]);
    }

    // 移除原有的游标对
    for (final pair in group) {
      _cursorPairs.removeWhere((_, p) => p.id == pair.id);
    }

    // 添加合并后的游标对
    _addCursorPair(merged);
  }
}

/// 时间线统计信息
class TimelineStats {
  /// 总游标对数量
  final int totalPairs;

  /// 已同步游标对数量
  final int syncedPairs;

  /// 空档游标对数量
  final int gapPairs;

  /// 总消息数量
  final int totalMessages;

  /// 总时间跨度
  final Duration totalTimeSpan;

  /// 已同步时间跨度
  final Duration syncedTimeSpan;

  /// 覆盖率百分比
  final double coveragePercentage;

  const TimelineStats({
    required this.totalPairs,
    required this.syncedPairs,
    required this.gapPairs,
    required this.totalMessages,
    required this.totalTimeSpan,
    required this.syncedTimeSpan,
    required this.coveragePercentage,
  });

  /// 同步进度百分比
  double get syncProgress {
    return totalPairs > 0 ? (syncedPairs / totalPairs * 100) : 0.0;
  }

  /// 转换为Map
  Map<String, dynamic> toMap() {
    return {
      'totalPairs': totalPairs,
      'syncedPairs': syncedPairs,
      'gapPairs': gapPairs,
      'totalMessages': totalMessages,
      'totalTimeSpanMs': totalTimeSpan.inMilliseconds,
      'syncedTimeSpanMs': syncedTimeSpan.inMilliseconds,
      'coveragePercentage': coveragePercentage,
      'syncProgress': syncProgress,
    };
  }

  @override
  String toString() {
    return 'TimelineStats(pairs: $syncedPairs/$totalPairs, gaps: $gapPairs, messages: $totalMessages, coverage: ${coveragePercentage.toStringAsFixed(1)}%)';
  }
}
