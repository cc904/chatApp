import 'dart:async';
import 'package:drift/drift.dart' as drift;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/database/drift_database.dart';
import '../../../../core/database/database_initializer.dart';
import '../../../../core/services/proto_socket_service.dart';
import '../../../../core/services/log_service.dart';
import '../../../../core/proto/generated/quick_reply.pb.dart' as qrpb;

/// 快捷回复数据仓库 (使用数据库存储 + Socket.io同步)
class QuickReplyRepository {
  static const String _keyLastSync = 'quick_replies_last_sync';
  
  final ProtoSocketService _socketService = ProtoSocketService();
  final LogService _logger = LogService.instance;
  bool _listenersInitialized = false;
  
  // 缓存最近一次从服务器获取到的原始PB数据，便于获取媒体字段
  final Map<int, qrpb.QuickReply> _pbCacheById = {};
  
  // 响应数据的Completer
  Completer<List<QuickReply>>? _syncCompleter;
  
  // 获取数据库实例
  AppDatabase get _db => DatabaseInitializer.database;

  /// 初始化Socket.io事件监听（protobuf）
  void _initializeSocketListeners() {
    if (_listenersInitialized) return;

    // 列表
    _socketService.onProto<qrpb.GetQuickRepliesResponse>(
      'quickReplies:list',
      () => qrpb.GetQuickRepliesResponse(),
      _handleQuickRepliesList,
    );

    // 新增
    _socketService.onProto<qrpb.QuickReplyResponse>(
      'quickReplies:created',
      () => qrpb.QuickReplyResponse(),
      _handleQuickReplyCreated,
    );

    // 更新
    _socketService.onProto<qrpb.QuickReplyResponse>(
      'quickReplies:updated',
      () => qrpb.QuickReplyResponse(),
      _handleQuickReplyUpdated,
    );

    // 删除
    _socketService.onProto<qrpb.DeleteQuickReplyResponse>(
      'quickReplies:deleted',
      () => qrpb.DeleteQuickReplyResponse(),
      _handleQuickReplyDeleted,
    );

    // 错误
    _socketService.onProto<qrpb.QuickReplyErrorResponse>(
      'quickReplies:error',
      () => qrpb.QuickReplyErrorResponse(),
      _handleQuickRepliesError,
    );

    _listenersInitialized = true;
    _logger.i('快捷回复Socket监听（protobuf）已注册');
  }

  /// 处理列表响应（protobuf）
  void _handleQuickRepliesList(qrpb.GetQuickRepliesResponse resp) async {
    try {
      // 刷新PB缓存
      _pbCacheById
        ..clear()
        ..addEntries(resp.quickReplies.map((e) => MapEntry(e.id.toInt(), e)));

      // 详细输出同步项（使用 error 级别便于在控制台高亮）
      try {
        final detailed = resp.quickReplies.map((q) => {
              'id': q.id.toInt(),
              'name': (q.hasName() && q.name.isNotEmpty) ? q.name : null,
              'content': q.hasContent() ? q.content : null,
              'category': q.hasCategory() ? q.category : null,
              'orderIndex': q.hasOrderIndex() ? q.orderIndex : null,
              'isEnabled': q.hasIsEnabled() ? q.isEnabled : null,
              'mediaType': q.hasMediaType() ? q.mediaType : null,
              'mediaUrl': q.hasMediaUrl() ? q.mediaUrl : null,
              'mimeType': q.hasMimeType() ? q.mimeType : null,
              'width': q.hasWidth() ? q.width : null,
              'height': q.hasHeight() ? q.height : null,
              'duration': q.hasDuration() ? q.duration : null,
              'fileSizeKb': q.hasFileSizeKb() ? q.fileSizeKb : null,
              'fileName': q.hasFileName() ? q.fileName : null,
              'fsId': q.hasFsId() ? q.fsId : null,
              'caption': q.hasCaption() ? q.caption : null,
              'thumbUrl': q.hasThumbUrl() ? q.thumbUrl : null,
            }).toList();
        _logger.e('快捷回复同步明细', extra: {
          'count': detailed.length,
          'items': detailed,
        });
      } catch (_) {
        // 安全兜底，日志不影响主流程
      }

      final replies = resp.quickReplies.map(_mapPbToDb).toList();

      await _saveToDatabase(replies);
      await _updateLastSyncTime();

      _logger.i('快捷回复同步成功，共${replies.length}条');

      if (_syncCompleter != null && !_syncCompleter!.isCompleted) {
        _syncCompleter!.complete(replies);
      }
    } catch (e) {
      _logger.e('处理快捷回复列表失败', error: e);
      if (_syncCompleter != null && !_syncCompleter!.isCompleted) {
        _syncCompleter!.completeError(e);
      }
    }
  }

  /// 新增响应（增量）
  Future<void> _handleQuickReplyCreated(qrpb.QuickReplyResponse resp) async {
    try {
      // 更新PB缓存
      _pbCacheById[resp.quickReply.id.toInt()] = resp.quickReply;

      final item = _mapPbToDb(resp.quickReply);
      await _upsertQuickReply(item, preferExistingCreatedAt: false);
      _logger.i('快捷回复新增并已写入本地: ${item.id}');
    } catch (e) {
      _logger.e('处理快捷回复新增失败', error: e);
    }
  }

  /// 更新响应（增量）
  Future<void> _handleQuickReplyUpdated(qrpb.QuickReplyResponse resp) async {
    try {
      // 更新PB缓存
      _pbCacheById[resp.quickReply.id.toInt()] = resp.quickReply;

      final item = _mapPbToDb(resp.quickReply);
      await _upsertQuickReply(item, preferExistingCreatedAt: true);
      _logger.i('快捷回复更新并已写入本地: ${item.id}');
    } catch (e) {
      _logger.e('处理快捷回复更新失败', error: e);
    }
  }

  /// 删除响应（增量）
  Future<void> _handleQuickReplyDeleted(qrpb.DeleteQuickReplyResponse resp) async {
    try {
      // 同步删除缓存
      _pbCacheById.remove(resp.id.toInt());

      await (_db.delete(_db.quickReplies)
            ..where((tbl) => tbl.id.equals(resp.id.toInt())))
          .go();
      _logger.i('快捷回复已从本地删除: ${resp.id}');
    } catch (e) {
      _logger.e('处理快捷回复删除失败', error: e);
    }
  }

  /// 错误响应
  void _handleQuickRepliesError(qrpb.QuickReplyErrorResponse err) {
    final error = err.message.isNotEmpty ? err.message : '服务器错误';
    _logger.e('快捷回复请求失败: $error', extra: {
      'code': err.errorCode,
      'timestamp': err.timestamp.toString(),
    });

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
      
      // 发送protobuf请求
      final req = qrpb.GetQuickRepliesRequest();
      _socketService.emitProto('quickReplies:get', req);
      
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
            (tbl) => drift.OrderingTerm.asc(tbl.category),
            (tbl) => drift.OrderingTerm.asc(tbl.orderIndex),
            (tbl) => drift.OrderingTerm.asc(tbl.createdAt),
          ]);
      final rows = await query.get();

      // 详细打印本地缓存读取（.e级别）
      try {
        final items = rows
            .map((r) => {
                  'id': r.id,
                  'name': r.name,
                  'content': r.content,
                  'category': r.category,
                  'mediaType': r.mediaType,
                  'mediaUrl': r.mediaUrl,
                  'caption': r.caption,
                  'width': r.width,
                  'height': r.height,
                  'fileSizeKb': r.fileSizeKb,
                  'fileName': r.fileName,
                  'mimeType': r.mimeType,
                  'thumbUrl': r.thumbUrl,
                  'fsId': r.fsId,
                  'orderIndex': r.orderIndex,
                  'isEnabled': r.isEnabled,
                  'createdAt': r.createdAt.toIso8601String(),
                  'updatedAt': r.updatedAt?.toIso8601String(),
                })
            .toList();
        _logger.e('快捷回复本地缓存读取明细', extra: {
          'count': items.length,
          'items': items,
          'source': 'local_database',
        });
      } catch (_) {}

      return rows;
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
          await _db.into(_db.quickReplies).insertOnConflictUpdate(reply);
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

  /// 创建快捷回复（protobuf）
  Future<bool> createQuickReply(qrpb.CreateQuickReplyRequest request) async {
    _initializeSocketListeners();
    return _socketService.emitProto('quickReplies:create', request);
  }

  /// 更新快捷回复（protobuf）
  Future<bool> updateQuickReply(qrpb.UpdateQuickReplyRequest request) async {
    _initializeSocketListeners();
    return _socketService.emitProto('quickReplies:update', request);
  }

  /// 删除快捷回复（protobuf）
  Future<bool> deleteQuickReply(qrpb.DeleteQuickReplyRequest request) async {
    _initializeSocketListeners();
    return _socketService.emitProto('quickReplies:delete', request);
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
    _pbCacheById.clear();
  }

  /// 根据ID获取最近一次同步的PB详情（包含媒体字段）
  qrpb.QuickReply? getPbById(int id) => _pbCacheById[id];

  // 将 protobuf 的 QuickReply 映射到本地数据库实体
  QuickReply _mapPbToDb(qrpb.QuickReply item) {
    return QuickReply(
      id: item.hasId() ? item.id.toInt() : 0,
      content: item.hasContent() ? item.content : '',
      category: item.hasCategory() ? item.category : null,
      name: item.hasName() && item.name.isNotEmpty ? item.name : null,
      userId: item.hasUserId() && item.userId.isNotEmpty ? item.userId : null,
      mediaType: item.hasMediaType() && item.mediaType.isNotEmpty ? item.mediaType : null,
      mediaUrl: item.hasMediaUrl() && item.mediaUrl.isNotEmpty ? item.mediaUrl : null,
      caption: item.hasCaption() && item.caption.isNotEmpty ? item.caption : null,
      width: item.hasWidth() ? item.width : null,
      height: item.hasHeight() ? item.height : null,
      fileSizeKb: item.hasFileSizeKb() ? item.fileSizeKb : null,
      fileName: item.hasFileName() && item.fileName.isNotEmpty ? item.fileName : null,
      mimeType: item.hasMimeType() && item.mimeType.isNotEmpty ? item.mimeType : null,
      thumbUrl: item.hasThumbUrl() && item.thumbUrl.isNotEmpty ? item.thumbUrl : null,
      fsId: item.hasFsId() && item.fsId.isNotEmpty ? item.fsId : null,
      orderIndex: item.hasOrderIndex() ? item.orderIndex : 0,
      isEnabled: item.hasIsEnabled() ? item.isEnabled : true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // 本地增量 Upsert（保留已有 createdAt 可选）
  Future<void> _upsertQuickReply(QuickReply row, {required bool preferExistingCreatedAt}) async {
    final existing = await (_db.select(_db.quickReplies)
          ..where((t) => t.id.equals(row.id)))
        .getSingleOrNull();

    final QuickReply finalRow;
    if (existing != null) {
      finalRow = row.copyWith(
        createdAt: preferExistingCreatedAt ? existing.createdAt : row.createdAt,
        updatedAt: drift.Value<DateTime?>(DateTime.now()),
      );
    } else {
      finalRow = row.copyWith(
        createdAt: DateTime.now(),
        updatedAt: drift.Value<DateTime?>(DateTime.now()),
      );
    }

    await _db.into(_db.quickReplies).insertOnConflictUpdate(finalRow);
  }
}