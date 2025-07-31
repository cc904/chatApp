import 'dart:async';
import 'package:drift/drift.dart' as drift;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/database/drift_database.dart';
import '../../../../core/database/database_initializer.dart';
import '../../../../core/services/proto_socket_service.dart';
import '../../../../core/services/log_service.dart';

/// 快捷回复数据仓库 (使用数据库存储 + Socket.io同步)
class QuickReplyRepository {
  static const String _keyLastSync = 'quick_replies_last_sync';
  
  final ProtoSocketService _socketService = ProtoSocketService();
  final LogService _logger = LogService.instance;
  
  // 响应数据的Completer
  Completer<List<QuickReply>>? _syncCompleter;
  
  // 获取数据库实例
  AppDatabase get _db => DatabaseInitializer.database;

  /// 初始化Socket.io事件监听
  void _initializeSocketListeners() {
    // 注册事件处理器
    _socketService.on('quick-replies:data', _handleQuickRepliesData);
    _socketService.on('quick-replies:error', _handleQuickRepliesError);
    _logger.i('快捷回复Socket.io监听器已注册');
  }

  /// 处理快捷回复数据响应
  void _handleQuickRepliesData(dynamic data) async {
    try {
      _logger.i('收到快捷回复数据响应');
      
      if (data is Map<String, dynamic>) {
        final List<dynamic> repliesData = data['quick_replies'] ?? [];
        final replies = repliesData
            .map((json) => QuickReplyExtension.fromServerJson(json as Map<String, dynamic>))
            .toList();
        
        // 保存到数据库
        await _saveToDatabase(replies);
        await _updateLastSyncTime();
        
        _logger.i('快捷回复同步成功，共${replies.length}条');
        
        // 完成异步请求
        if (_syncCompleter != null && !_syncCompleter!.isCompleted) {
          _syncCompleter!.complete(replies);
        }
      } else {
        throw Exception('服务器响应数据格式错误');
      }
    } catch (e) {
      _logger.e('处理快捷回复数据失败', error: e);
      if (_syncCompleter != null && !_syncCompleter!.isCompleted) {
        _syncCompleter!.completeError(e);
      }
    }
  }

  /// 处理快捷回复错误响应
  void _handleQuickRepliesError(dynamic data) {
    final error = data is Map ? data['message'] ?? '未知错误' : '服务器错误';
    _logger.e('快捷回复请求失败: $error');
    
    if (_syncCompleter != null && !_syncCompleter!.isCompleted) {
      _syncCompleter!.completeError(Exception(error));
    }
  }

  /// 从服务器同步快捷回复数据
  Future<List<QuickReply>> syncFromServer() async {
    try {
      _logger.i('开始通过Socket.io同步快捷回复数据');
      
      // 初始化Socket监听器
      _initializeSocketListeners();
      
      // 创建新的Completer
      _syncCompleter = Completer<List<QuickReply>>();
      
      // 发送Socket.io请求 - 使用原始emit方法
      _socketService.emit('quick-replies:get', {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      
      // 等待响应，设置超时时间
      final replies = await _syncCompleter!.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('请求超时，请检查网络连接');
        },
      );
      
      return replies;
    } catch (e) {
      _logger.e('快捷回复Socket.io同步失败', error: e);
      // 同步失败时返回本地缓存
      return await _getFromDatabase();
    } finally {
      _syncCompleter = null;
    }
  }

  /// 获取所有快捷回复（优先数据库缓存）
  Future<List<QuickReply>> getAllQuickReplies() async {
    final localReplies = await _getFromDatabase();
    
    // 如果本地有数据且不需要立即同步，直接返回
    if (localReplies.isNotEmpty && !await _needsSync()) {
      return localReplies;
    }
    
    // 尝试从服务器同步，失败则使用本地数据
    try {
      return await syncFromServer();
    } catch (e) {
      _logger.w('使用本地数据库的快捷回复数据');
      return localReplies;
    }
  }

  /// 从数据库获取数据
  Future<List<QuickReply>> _getFromDatabase() async {
    try {
      final query = _db.select(_db.quickReplies)
          ..where((tbl) => tbl.isEnabled.equals(true))
          ..orderBy([
            (tbl) => drift.OrderingTerm.asc(tbl.orderIndex),
            (tbl) => drift.OrderingTerm.asc(tbl.id),
          ]);
      return await query.get();
    } catch (e) {
      _logger.e('从数据库获取快捷回复数据失败', error: e);
      return [];
    }
  }

  /// 根据分类获取快捷回复
  Future<List<QuickReply>> getQuickRepliesByCategory(String category) async {
    try {
      final query = _db.select(_db.quickReplies)
          ..where((tbl) => tbl.isEnabled.equals(true) & tbl.category.equals(category))
          ..orderBy([
            (tbl) => drift.OrderingTerm.asc(tbl.orderIndex),
            (tbl) => drift.OrderingTerm.asc(tbl.id),
          ]);
      return await query.get();
    } catch (e) {
      _logger.e('按分类获取快捷回复失败', error: e);
      return [];
    }
  }

  /// 按分类和顺序获取快捷回复
  Future<List<QuickReply>> getRepliesOrdered() async {
    try {
      final query = _db.select(_db.quickReplies)
          ..where((tbl) => tbl.isEnabled.equals(true))
          ..orderBy([
            (tbl) => drift.OrderingTerm.asc(tbl.category),
            (tbl) => drift.OrderingTerm.asc(tbl.orderIndex),
            (tbl) => drift.OrderingTerm.asc(tbl.id),
          ]);
      return await query.get();
    } catch (e) {
      _logger.e('按分类和顺序获取快捷回复失败', error: e);
      return [];
    }
  }


  /// 标记为已使用（简化版 - 仅记录日志）
  void markReplyAsUsed(int id) {
    _logger.d('快捷回复被使用: $id');
    // 不需要实际记录使用统计，仅用于调试日志
  }

  /// 搜索快捷回复
  Future<List<QuickReply>> searchQuickReplies(String query) async {
    if (query.isEmpty) return getAllQuickReplies();
    
    try {
      final lowercaseQuery = query.toLowerCase();
      final searchQuery = _db.select(_db.quickReplies)
          ..where((tbl) => 
            tbl.isEnabled.equals(true) & 
            (tbl.content.lower().contains(lowercaseQuery) | 
             tbl.category.lower().contains(lowercaseQuery)))
          ..orderBy([
            (tbl) => drift.OrderingTerm.asc(tbl.orderIndex),
            (tbl) => drift.OrderingTerm.asc(tbl.id),
          ]);
      return await searchQuery.get();
    } catch (e) {
      _logger.e('搜索快捷回复失败', error: e);
      return [];
    }
  }

  /// 获取分类列表
  Future<List<String>> getCategories() async {
    try {
      final query = _db.selectOnly(_db.quickReplies, distinct: true)
          ..addColumns([_db.quickReplies.category])
          ..where(_db.quickReplies.isEnabled.equals(true) & 
                 _db.quickReplies.category.isNotNull())
          ..orderBy([drift.OrderingTerm.asc(_db.quickReplies.category)]);
      
      final result = await query.get();
      
      return result
          .map((row) => row.read(_db.quickReplies.category))
          .where((category) => category != null)
          .cast<String>()
          .toList();
    } catch (e) {
      _logger.e('获取分类列表失败', error: e);
      return [];
    }
  }

  /// 清空所有快捷回复
  Future<void> clearAllQuickReplies() async {
    try {
      await _db.delete(_db.quickReplies).go();
      _logger.i('所有快捷回复已清空');
    } catch (e) {
      _logger.e('清空快捷回复失败', error: e);
      rethrow;
    }
  }

  /// 导出快捷回复
  Future<List<Map<String, dynamic>>> exportQuickReplies() async {
    final replies = await getAllQuickReplies();
    return replies.map((reply) => reply.toJson()).toList();
  }


  /// 保存到数据库
  Future<void> _saveToDatabase(List<QuickReply> replies) async {
    try {
      await _db.transaction(() async {
        // 清空现有数据
        await _db.delete(_db.quickReplies).go();
        
        // 批量插入新数据
        for (final reply in replies) {
          await _db.into(_db.quickReplies).insert(
            QuickRepliesCompanion.insert(
              id: drift.Value(reply.id),
              content: reply.content,
              category: drift.Value(reply.category),
              orderIndex: drift.Value(reply.orderIndex),
              isEnabled: drift.Value(reply.isEnabled),
              createdAt: reply.createdAt,
              updatedAt: drift.Value(reply.updatedAt),
            )
          );
        }
      });
      
      _logger.i('快捷回复数据已保存到数据库，共${replies.length}条');
    } catch (e) {
      _logger.e('保存快捷回复到数据库失败', error: e);
      rethrow;
    }
  }

  /// 更新最后同步时间
  Future<void> _updateLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastSync, DateTime.now().toIso8601String());
  }

  /// 检查是否需要同步
  Future<bool> _needsSync() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSyncStr = prefs.getString(_keyLastSync);
    
    if (lastSyncStr == null) return true;
    
    try {
      final lastSync = DateTime.parse(lastSyncStr);
      final now = DateTime.now();
      
      // 超过1小时未同步则需要重新同步
      return now.difference(lastSync).inHours >= 1;
    } catch (e) {
      return true;
    }
  }

  /// 强制刷新数据
  Future<List<QuickReply>> forceRefresh() async {
    return await syncFromServer();
  }

  /// 获取最后同步时间
  Future<DateTime?> getLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSyncStr = prefs.getString(_keyLastSync);
    
    if (lastSyncStr == null) return null;
    
    try {
      return DateTime.parse(lastSyncStr);
    } catch (e) {
      return null;
    }
  }

  /// 清理资源
  void dispose() {
    if (_syncCompleter != null && !_syncCompleter!.isCompleted) {
      _syncCompleter!.completeError(Exception('Repository disposed'));
    }
    _syncCompleter = null;
  }

}