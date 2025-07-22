import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import '../../../../core/database/models/quick_reply.dart';
import '../../../../core/services/proto_socket_service.dart';
import '../../../../core/services/log_service.dart';

/// 快捷回复数据仓库 (支持Socket.io同步)
class QuickReplyRepository {
  static const String _keyQuickReplies = 'quick_replies';
  static const String _keyLastSync = 'quick_replies_last_sync';
  
  final ProtoSocketService _socketService = ProtoSocketService();
  final LogService _logger = LogService.instance;
  
  // 响应数据的Completer
  Completer<List<QuickReply>>? _syncCompleter;

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
            .map((json) => QuickReply.fromServerJson(json))
            .toList();
        
        // 保存到本地缓存
        await _saveToLocal(replies);
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
      return await _getFromLocal();
    } finally {
      _syncCompleter = null;
    }
  }

  /// 获取所有快捷回复（优先本地缓存）
  Future<List<QuickReply>> getAllQuickReplies() async {
    final localReplies = await _getFromLocal();
    
    // 如果本地有数据且不需要立即同步，直接返回
    if (localReplies.isNotEmpty && !await _needsSync()) {
      return localReplies;
    }
    
    // 尝试从服务器同步，失败则使用本地数据
    try {
      return await syncFromServer();
    } catch (e) {
      _logger.w('使用本地缓存的快捷回复数据');
      return localReplies;
    }
  }

  /// 从本地缓存获取数据
  Future<List<QuickReply>> _getFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_keyQuickReplies);
    if (data == null) return [];
    
    try {
      final List<dynamic> jsonList = json.decode(data);
      return jsonList
          .map((json) => QuickReply.fromJson(json))
          .where((reply) => reply.isEnabled)
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order));
    } catch (e) {
      _logger.e('解析本地快捷回复数据失败', error: e);
      return [];
    }
  }

  /// 根据分类获取快捷回复
  Future<List<QuickReply>> getQuickRepliesByCategory(String category) async {
    final allReplies = await getAllQuickReplies();
    return allReplies.where((reply) => reply.category == category).toList();
  }

  /// 按分类和顺序获取快捷回复
  Future<List<QuickReply>> getRepliesOrdered() async {
    final allReplies = await getAllQuickReplies();
    // 按分类和order字段排序
    allReplies.sort((a, b) {
      final categoryCompare = a.category.compareTo(b.category);
      if (categoryCompare != 0) return categoryCompare;
      return a.order.compareTo(b.order);
    });
    return allReplies;
  }


  /// 标记为已使用（简化版 - 仅记录日志）
  void markReplyAsUsed(int id) {
    _logger.d('快捷回复被使用: $id');
    // 不需要实际记录使用统计，仅用于调试日志
  }

  /// 搜索快捷回复
  Future<List<QuickReply>> searchQuickReplies(String query) async {
    if (query.isEmpty) return getAllQuickReplies();
    
    final allReplies = await getAllQuickReplies();
    return allReplies
        .where((reply) => 
            reply.content.toLowerCase().contains(query.toLowerCase()) ||
            reply.category.toLowerCase().contains(query.toLowerCase()))
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  /// 获取分类列表
  Future<List<String>> getCategories() async {
    final allReplies = await getAllQuickReplies();
    final categories = allReplies
        .map((r) => r.category)
        .toSet()
        .toList()
      ..sort();
    return categories;
  }

  /// 清空所有快捷回复
  Future<void> clearAllQuickReplies() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyQuickReplies);
  }

  /// 导出快捷回复
  Future<List<Map<String, dynamic>>> exportQuickReplies() async {
    final replies = await getAllQuickReplies();
    return replies.map((reply) => reply.toJson()).toList();
  }


  /// 保存到本地缓存
  Future<void> _saveToLocal(List<QuickReply> replies) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = replies.map((reply) => reply.toJson()).toList();
    await prefs.setString(_keyQuickReplies, json.encode(jsonList));
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