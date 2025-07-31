import 'dart:async';

/// 动态字体加载服务
/// 负责按需加载中文字体，优化Flutter Web的字体加载性能
class DynamicFontLoaderService {
  static final DynamicFontLoaderService instance = DynamicFontLoaderService._internal();
  
  DynamicFontLoaderService._internal();

  /// 字体加载状态缓存
  final Map<String, bool> _loadedTexts = {};
  
  /// 正在加载的文本队列
  final Set<String> _loadingQueue = {};
  
  /// 批处理定时器
  Timer? _batchTimer;
  
  /// 批处理间隔（毫秒）
  static const int _batchDelay = 100;
  
  /// 每批最大字符数
  static const int _maxBatchSize = 200;

  /// 为消息文本加载字体
  /// 
  /// [text] 需要加载字体的文本内容
  void loadFontsForMessage(String text) {
    if (text.isEmpty) return;
    
    // 过滤中文字符
    final chineseChars = _extractChineseChars(text);
    if (chineseChars.isNotEmpty) {
      _addToLoadingQueue(chineseChars);
    }
  }

  /// 为对话加载字体
  /// 
  /// [texts] 对话中的所有文本内容
  void loadFontsForConversation(List<String> texts) {
    final allChineseChars = <String>{};
    
    for (final text in texts) {
      if (text.isNotEmpty) {
        allChineseChars.addAll(_extractChineseChars(text).split(''));
      }
    }
    
    if (allChineseChars.isNotEmpty) {
      _addToLoadingQueue(allChineseChars.join());
    }
  }

  /// 预加载常用字符
  void preloadCommonChars() {
    const commonChars = '的一是在不了有和人这中大为上个国我以要他时来用们生到作地于出就分对成会可主发年动同工也能下过子说产种面而方后多定行学法所民得经十三四五六七八九零';
    _addToLoadingQueue(commonChars);
  }

  /// 提取中文字符
  String _extractChineseChars(String text) {
    final chineseRegex = RegExp(r'[\u4e00-\u9fff]+');
    final matches = chineseRegex.allMatches(text);
    final chars = <String>{};
    
    for (final match in matches) {
      chars.addAll(match.group(0)!.split(''));
    }
    
    return chars.join();
  }

  /// 添加到加载队列
  void _addToLoadingQueue(String text) {
    if (text.isEmpty) return;
    
    // 过滤已加载的字符
    final newChars = <String>[];
    for (final char in text.split('')) {
      if (!_loadedTexts.containsKey(char) && !_loadingQueue.contains(char)) {
        newChars.add(char);
        _loadingQueue.add(char);
      }
    }
    
    if (newChars.isNotEmpty) {
      _scheduleBatchLoad();
    }
  }

  /// 计划批量加载
  void _scheduleBatchLoad() {
    _batchTimer?.cancel();
    _batchTimer = Timer(const Duration(milliseconds: _batchDelay), () {
      _processBatch();
    });
  }

  /// 处理批量加载
  void _processBatch() {
    if (_loadingQueue.isEmpty) return;
    
    // 取出一批字符进行加载
    final batch = _loadingQueue.take(_maxBatchSize).toList();
    _loadingQueue.removeAll(batch);
    
    final batchText = batch.join();
    
    // 调用JavaScript字体加载器
    _loadFontViaJS(batchText);
    
    // 标记为已加载
    for (final char in batch) {
      _loadedTexts[char] = true;
    }
    
    // 如果还有剩余字符，继续处理
    if (_loadingQueue.isNotEmpty) {
      _scheduleBatchLoad();
    }
  }

  /// 通过JavaScript加载字体
  void _loadFontViaJS(String text) {
    try {
      // 简化的字体加载逻辑 - 实际项目中需要根据具体的JS互操作API实现
      if (_isDebugMode()) {
        print('🎨 字体加载请求: ${text.length > 20 ? '${text.substring(0, 20)}...' : text}');
      }
      
      // TODO: 实现具体的JS互操作调用
      // 这里需要根据实际的Flutter Web字体加载API来实现
      
    } catch (e) {
      if (_isDebugMode()) {
        print('❌ 字体加载错误: $e');
      }
    }
  }

  /// 清理资源
  void dispose() {
    _batchTimer?.cancel();
    _loadingQueue.clear();
    _loadedTexts.clear();
  }

  /// 获取加载统计信息
  Map<String, dynamic> getStats() {
    return {
      'loadedChars': _loadedTexts.length,
      'queueSize': _loadingQueue.length,
      'isProcessing': _batchTimer?.isActive ?? false,
    };
  }

  /// 检查是否为调试模式
  bool _isDebugMode() {
    bool debugMode = false;
    assert(debugMode = true);
    return debugMode;
  }

  /// 强制加载指定文本的字体
  void forceLoadText(String text) {
    final chineseChars = _extractChineseChars(text);
    if (chineseChars.isNotEmpty) {
      _loadFontViaJS(chineseChars);
      
      // 标记为已加载
      for (final char in chineseChars.split('')) {
        _loadedTexts[char] = true;
      }
    }
  }
}