import 'package:cc/core/database/database_initializer.dart';
import 'package:cc/core/database/models/message_cursor_pair.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:isar/isar.dart';

/// 基于Isar的消息时间线Repository实现
///
/// 负责管理消息游标对的持久化存储，提供高效的查询和管理功能
class MessageTimelineRepositoryIsar {
  static final _logger = LogService.instance;

  /// 获取Isar数据库实例
  Isar get _isar => DatabaseInitializer.isar;

  /// 保存消息游标对
  ///
  /// 参数:
  /// - pair: 要保存的消息游标对
  ///
  /// 返回值:
  /// - 保存成功返回true，失败返回false
  Future<bool> savePair(MessageCursorPairModel pair) async {
    try {
      await _isar.writeTxn(() async {
        await _isar.messageCursorPairModels.put(pair);
      });

      _logger.d('保存消息游标对成功: ${pair.pairId}');
      return true;
    } catch (error) {
      _logger.e('保存消息游标对失败', error: error);
      return false;
    }
  }

  /// 批量保存消息游标对
  ///
  /// 参数:
  /// - pairs: 要保存的消息游标对列表
  ///
  /// 返回值:
  /// - 保存成功返回true，失败返回false
  Future<bool> savePairs(List<MessageCursorPairModel> pairs) async {
    if (pairs.isEmpty) return true;

    try {
      await _isar.writeTxn(() async {
        await _isar.messageCursorPairModels.putAll(pairs);
      });

      _logger.d('批量保存消息游标对成功: ${pairs.length}个');
      return true;
    } catch (error) {
      _logger.e('批量保存消息游标对失败', error: error);
      return false;
    }
  }

  /// 根据pairId获取消息游标对
  ///
  /// 参数:
  /// - pairId: 游标对ID
  ///
  /// 返回值:
  /// - 找到返回MessageCursorPairModel，否则返回null
  Future<MessageCursorPairModel?> getPairById(String pairId) async {
    try {
      final pair = await _isar.messageCursorPairModels
          .where()
          .pairIdEqualTo(pairId)
          .findFirst();

      _logger.d('查询消息游标对: $pairId, 结果: ${pair != null ? '找到' : '未找到'}');
      return pair;
    } catch (error) {
      _logger.e('查询消息游标对失败', error: error);
      return null;
    }
  }

  /// 获取指定会话的所有消息游标对
  ///
  /// 参数:
  /// - conversationId: 会话ID
  /// - limit: 限制返回数量，默认100
  /// - offset: 偏移量，默认0
  ///
  /// 返回值:
  /// - 消息游标对列表，按创建时间倒序排列
  Future<List<MessageCursorPairModel>> getPairsByConversation(
    String conversationId, {
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final pairs = await _isar.messageCursorPairModels
          .filter()
          .conversationIdEqualTo(conversationId)
          .sortByCreatedAtDesc()
          .offset(offset)
          .limit(limit)
          .findAll();

      _logger.d('查询会话游标对: $conversationId, 找到${pairs.length}个');
      return pairs;
    } catch (error) {
      _logger.e('查询会话游标对失败', error: error);
      return [];
    }
  }

  /// 获取指定类型的消息游标对
  ///
  /// 参数:
  /// - type: 游标对类型
  /// - limit: 限制返回数量，默认100
  ///
  /// 返回值:
  /// - 消息游标对列表，按优先级和创建时间排序
  Future<List<MessageCursorPairModel>> getPairsByType(
    String type, {
    int limit = 100,
  }) async {
    try {
      final pairs = await _isar.messageCursorPairModels
          .where()
          .typeEqualTo(type)
          .sortByPriorityDesc()
          .thenByCreatedAtDesc()
          .limit(limit)
          .findAll();

      _logger.d('查询类型游标对: $type, 找到${pairs.length}个');
      return pairs;
    } catch (error) {
      _logger.e('查询类型游标对失败', error: error);
      return [];
    }
  }

  /// 获取未同步的消息游标对
  ///
  /// 参数:
  /// - limit: 限制返回数量，默认50
  ///
  /// 返回值:
  /// - 未同步的消息游标对列表，按优先级排序
  Future<List<MessageCursorPairModel>> getUnsyncedPairs({
    int limit = 50,
  }) async {
    try {
      final pairs = await _isar.messageCursorPairModels
          .where()
          .isSyncedEqualTo(false)
          .sortByPriorityDesc()
          .thenByCreatedAt()
          .limit(limit)
          .findAll();

      _logger.d('查询未同步游标对: 找到${pairs.length}个');
      return pairs;
    } catch (error) {
      _logger.e('查询未同步游标对失败', error: error);
      return [];
    }
  }

  /// 获取高优先级的消息游标对
  ///
  /// 参数:
  /// - minPriority: 最小优先级，默认5
  /// - limit: 限制返回数量，默认20
  ///
  /// 返回值:
  /// - 高优先级的消息游标对列表
  Future<List<MessageCursorPairModel>> getHighPriorityPairs({
    int minPriority = 5,
    int limit = 20,
  }) async {
    try {
      final pairs = await _isar.messageCursorPairModels
          .where()
          .priorityGreaterThan(minPriority - 1)
          .sortByPriorityDesc()
          .thenByCreatedAtDesc()
          .limit(limit)
          .findAll();

      _logger.d('查询高优先级游标对: 优先级>=$minPriority, 找到${pairs.length}个');
      return pairs;
    } catch (error) {
      _logger.e('查询高优先级游标对失败', error: error);
      return [];
    }
  }

  /// 更新消息游标对的同步状态
  ///
  /// 参数:
  /// - pairId: 游标对ID
  /// - isSynced: 同步状态
  ///
  /// 返回值:
  /// - 更新成功返回true，失败返回false
  Future<bool> updateSyncStatus(String pairId, bool isSynced) async {
    try {
      await _isar.writeTxn(() async {
        final pair = await _isar.messageCursorPairModels
            .where()
            .pairIdEqualTo(pairId)
            .findFirst();

        if (pair != null) {
          pair.isSynced = isSynced;
          pair.updatedAt = DateTime.now();
          await _isar.messageCursorPairModels.put(pair);
        }
      });

      _logger.d('更新同步状态成功: $pairId -> $isSynced');
      return true;
    } catch (error) {
      _logger.e('更新同步状态失败', error: error);
      return false;
    }
  }

  /// 更新消息游标对的优先级
  ///
  /// 参数:
  /// - pairId: 游标对ID
  /// - priority: 新的优先级
  ///
  /// 返回值:
  /// - 更新成功返回true，失败返回false
  Future<bool> updatePriority(String pairId, int priority) async {
    try {
      await _isar.writeTxn(() async {
        final pair = await _isar.messageCursorPairModels
            .where()
            .pairIdEqualTo(pairId)
            .findFirst();

        if (pair != null) {
          pair.priority = priority;
          pair.updatedAt = DateTime.now();
          await _isar.messageCursorPairModels.put(pair);
        }
      });

      _logger.d('更新优先级成功: $pairId -> $priority');
      return true;
    } catch (error) {
      _logger.e('更新优先级失败', error: error);
      return false;
    }
  }

  /// 删除消息游标对
  ///
  /// 参数:
  /// - pairId: 要删除的游标对ID
  ///
  /// 返回值:
  /// - 删除成功返回true，失败返回false
  Future<bool> deletePair(String pairId) async {
    try {
      await _isar.writeTxn(() async {
        await _isar.messageCursorPairModels
            .where()
            .pairIdEqualTo(pairId)
            .deleteFirst();
      });

      _logger.d('删除消息游标对成功: $pairId');
      return true;
    } catch (error) {
      _logger.e('删除消息游标对失败', error: error);
      return false;
    }
  }

  /// 删除指定会话的所有消息游标对
  ///
  /// 参数:
  /// - conversationId: 会话ID
  ///
  /// 返回值:
  /// - 删除的数量
  Future<int> deletePairsByConversation(String conversationId) async {
    try {
      int deletedCount = 0;
      await _isar.writeTxn(() async {
        deletedCount = await _isar.messageCursorPairModels
            .filter()
            .conversationIdEqualTo(conversationId)
            .deleteAll();
      });

      _logger.d('删除会话游标对成功: $conversationId, 删除$deletedCount个');
      return deletedCount;
    } catch (error) {
      _logger.e('删除会话游标对失败', error: error);
      return 0;
    }
  }

  /// 清理过期的消息游标对
  ///
  /// 参数:
  /// - expireDays: 过期天数，默认30天
  ///
  /// 返回值:
  /// - 清理的数量
  Future<int> cleanupExpiredPairs({int expireDays = 30}) async {
    try {
      final expireDate = DateTime.now().subtract(Duration(days: expireDays));
      int deletedCount = 0;

      await _isar.writeTxn(() async {
        deletedCount = await _isar.messageCursorPairModels
            .filter()
            .createdAtLessThan(expireDate)
            .deleteAll();
      });

      _logger.d('清理过期游标对成功: 删除$deletedCount个');
      return deletedCount;
    } catch (error) {
      _logger.e('清理过期游标对失败', error: error);
      return 0;
    }
  }

  /// 获取统计信息
  ///
  /// 返回值:
  /// - 包含各种统计数据的Map
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      final totalCount = await _isar.messageCursorPairModels.count();
      final syncedCount = await _isar.messageCursorPairModels
          .where()
          .isSyncedEqualTo(true)
          .count();
      final unsyncedCount = await _isar.messageCursorPairModels
          .where()
          .isSyncedEqualTo(false)
          .count();

      final stats = {
        'totalCount': totalCount,
        'syncedCount': syncedCount,
        'unsyncedCount': unsyncedCount,
        'syncRate': totalCount > 0
            ? (syncedCount / totalCount * 100).toStringAsFixed(1)
            : '0.0',
      };

      _logger.d('获取统计信息: $stats');
      return stats;
    } catch (error) {
      _logger.e('获取统计信息失败', error: error);
      return {};
    }
  }
}
