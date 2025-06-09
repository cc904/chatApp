import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/message_cursor_pair.dart';

/// 消息时间线持久化仓库
/// 使用SharedPreferences存储游标对数据
class MessageTimelineRepository {
  static const String _keyPrefix = 'timeline_cursor_pairs_';
  static const String _statsPrefix = 'timeline_stats_';

  /// 保存游标对到本地存储
  Future<void> saveCursorPair(MessageCursorPair cursorPair) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_keyPrefix${cursorPair.conversationId}_${cursorPair.id}';
      final data = jsonEncode(cursorPair.toMap());
      await prefs.setString(key, data);
    } catch (error) {
      throw Exception('保存游标对失败: $error');
    }
  }

  /// 批量保存游标对
  Future<void> saveCursorPairs(List<MessageCursorPair> cursorPairs) async {
    if (cursorPairs.isEmpty) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      for (final pair in cursorPairs) {
        final key = '$_keyPrefix${pair.conversationId}_${pair.id}';
        final data = jsonEncode(pair.toMap());
        await prefs.setString(key, data);
      }
    } catch (error) {
      throw Exception('批量保存游标对失败: $error');
    }
  }

  /// 根据会话ID获取所有游标对
  Future<List<MessageCursorPair>> getCursorPairsByConversation(
      String conversationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs
          .getKeys()
          .where((key) => key.startsWith('$_keyPrefix$conversationId'))
          .toList();

      final pairs = <MessageCursorPair>[];
      for (final key in keys) {
        final data = prefs.getString(key);
        if (data != null) {
          final map = jsonDecode(data) as Map<String, dynamic>;
          pairs.add(MessageCursorPair.fromMap(map));
        }
      }

      // 按创建时间排序
      pairs.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return pairs;
    } catch (error) {
      throw Exception('获取游标对失败: $error');
    }
  }

  /// 根据ID获取单个游标对
  Future<MessageCursorPair?> getCursorPairById(
      String conversationId, String pairId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_keyPrefix${conversationId}_$pairId';
      final data = prefs.getString(key);

      if (data != null) {
        final map = jsonDecode(data) as Map<String, dynamic>;
        return MessageCursorPair.fromMap(map);
      }
      return null;
    } catch (error) {
      throw Exception('获取游标对失败: $error');
    }
  }

  /// 获取待同步的游标对
  Future<List<MessageCursorPair>> getUnsyncedCursorPairs(
      String conversationId) async {
    try {
      final allPairs = await getCursorPairsByConversation(conversationId);
      final unsyncedPairs = allPairs.where((pair) => !pair.isSynced).toList();

      // 按优先级排序
      unsyncedPairs.sort((a, b) => b.priority.compareTo(a.priority));
      return unsyncedPairs;
    } catch (error) {
      throw Exception('获取待同步游标对失败: $error');
    }
  }

  /// 获取指定类型的游标对
  Future<List<MessageCursorPair>> getCursorPairsByType(
      String conversationId, CursorPairType type) async {
    try {
      final allPairs = await getCursorPairsByConversation(conversationId);
      return allPairs.where((pair) => pair.type == type).toList();
    } catch (error) {
      throw Exception('获取指定类型游标对失败: $error');
    }
  }

  /// 更新游标对状态
  Future<void> updateCursorPairStatus(
      String conversationId, String pairId, bool isSynced,
      {int? messageCount}) async {
    try {
      final existingPair = await getCursorPairById(conversationId, pairId);
      if (existingPair != null) {
        final updatedPair = existingPair.copyWith(
          isSynced: isSynced,
          messageCount: messageCount ?? existingPair.messageCount,
        );
        await saveCursorPair(updatedPair);
      }
    } catch (error) {
      throw Exception('更新游标对状态失败: $error');
    }
  }

  /// 删除游标对
  Future<void> deleteCursorPair(String conversationId, String pairId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_keyPrefix${conversationId}_$pairId';
      await prefs.remove(key);
    } catch (error) {
      throw Exception('删除游标对失败: $error');
    }
  }

  /// 删除会话的所有游标对
  Future<void> deleteCursorPairsByConversation(String conversationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs
          .getKeys()
          .where((key) => key.startsWith('$_keyPrefix$conversationId'))
          .toList();

      for (final key in keys) {
        await prefs.remove(key);
      }
    } catch (error) {
      throw Exception('删除会话游标对失败: $error');
    }
  }

  /// 清理过期的游标对
  /// [olderThan] - 删除创建时间早于此时间的游标对
  Future<int> cleanupExpiredCursorPairs(
      String conversationId, DateTime olderThan) async {
    try {
      final allPairs = await getCursorPairsByConversation(conversationId);
      final expiredPairs =
          allPairs.where((pair) => pair.createdAt.isBefore(olderThan)).toList();

      for (final pair in expiredPairs) {
        await deleteCursorPair(conversationId, pair.id);
      }

      return expiredPairs.length;
    } catch (error) {
      throw Exception('清理过期游标对失败: $error');
    }
  }

  /// 获取时间线统计信息
  Future<Map<String, dynamic>> getTimelineStats(String conversationId) async {
    try {
      final allPairs = await getCursorPairsByConversation(conversationId);

      final syncedCount = allPairs.where((p) => p.isSynced).length;
      final gapCount =
          allPairs.where((p) => p.type == CursorPairType.gap).length;
      final totalMessages = allPairs
          .where((p) => p.messageCount != null)
          .fold<int>(0, (sum, p) => sum + p.messageCount!);

      var totalTimeSpanMs = 0;
      var syncedTimeSpanMs = 0;

      for (final pair in allPairs) {
        final spanMs = pair.timeSpanMs;
        totalTimeSpanMs += spanMs;

        if (pair.isSynced) {
          syncedTimeSpanMs += spanMs;
        }
      }

      final stats = {
        'totalPairs': allPairs.length,
        'syncedPairs': syncedCount,
        'gapPairs': gapCount,
        'totalMessages': totalMessages,
        'totalTimeSpanMs': totalTimeSpanMs,
        'syncedTimeSpanMs': syncedTimeSpanMs,
        'coveragePercentage': totalTimeSpanMs > 0
            ? (syncedTimeSpanMs / totalTimeSpanMs * 100)
            : 0.0,
        'syncProgress':
            allPairs.isNotEmpty ? (syncedCount / allPairs.length * 100) : 0.0,
      };

      // 缓存统计信息
      final prefs = await SharedPreferences.getInstance();
      final statsKey = '$_statsPrefix$conversationId';
      await prefs.setString(statsKey, jsonEncode(stats));

      return stats;
    } catch (error) {
      throw Exception('获取时间线统计失败: $error');
    }
  }

  /// 获取缓存的统计信息
  Future<Map<String, dynamic>?> getCachedTimelineStats(
      String conversationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsKey = '$_statsPrefix$conversationId';
      final data = prefs.getString(statsKey);

      if (data != null) {
        return jsonDecode(data) as Map<String, dynamic>;
      }
      return null;
    } catch (error) {
      return null;
    }
  }

  /// 导出时间线数据
  Future<Map<String, dynamic>> exportTimelineData(String conversationId) async {
    try {
      final pairs = await getCursorPairsByConversation(conversationId);
      final stats = await getTimelineStats(conversationId);

      return {
        'conversationId': conversationId,
        'exportTime': DateTime.now().toIso8601String(),
        'pairs': pairs.map((p) => p.toMap()).toList(),
        'stats': stats,
      };
    } catch (error) {
      throw Exception('导出时间线数据失败: $error');
    }
  }

  /// 导入时间线数据
  Future<void> importTimelineData(Map<String, dynamic> data) async {
    try {
      final conversationId = data['conversationId'] as String;
      final pairsData = data['pairs'] as List<dynamic>;

      // 先清除现有数据
      await deleteCursorPairsByConversation(conversationId);

      // 批量导入新数据
      final pairs = pairsData
          .map((pairData) =>
              MessageCursorPair.fromMap(pairData as Map<String, dynamic>))
          .toList();

      await saveCursorPairs(pairs);
    } catch (error) {
      throw Exception('导入时间线数据失败: $error');
    }
  }

  /// 获取所有会话的游标对数量统计
  Future<Map<String, int>> getAllConversationStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final allKeys =
          prefs.getKeys().where((key) => key.startsWith(_keyPrefix)).toList();

      final conversationCounts = <String, int>{};

      for (final key in allKeys) {
        // 解析会话ID: timeline_cursor_pairs_conversationId_pairId
        final parts = key.split('_');
        if (parts.length >= 4) {
          final conversationId = parts[3];
          conversationCounts[conversationId] =
              (conversationCounts[conversationId] ?? 0) + 1;
        }
      }

      return conversationCounts;
    } catch (error) {
      throw Exception('获取会话统计失败: $error');
    }
  }

  /// 清理所有时间线数据
  Future<void> clearAllTimelineData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs
          .getKeys()
          .where((key) =>
              key.startsWith(_keyPrefix) || key.startsWith(_statsPrefix))
          .toList();

      for (final key in keys) {
        await prefs.remove(key);
      }
    } catch (error) {
      throw Exception('清理时间线数据失败: $error');
    }
  }
}
