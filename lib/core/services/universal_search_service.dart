import 'package:cc/core/services/communication_service.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/proto/generated/user.pb.dart';
import 'package:cc/core/proto/generated/conversation.pb.dart';
import 'package:fixnum/fixnum.dart';

/// 统一搜索服务
/// 支持搜索用户、群聊、频道的综合搜索服务
class UniversalSearchService {
  static final UniversalSearchService _instance =
      UniversalSearchService._internal();
  static UniversalSearchService get instance => _instance;
  UniversalSearchService._internal();

  final CommunicationService _communicationService = CommunicationService();
  final LogService _logger = LogService.instance;

  /// 执行统一搜索
  ///
  /// [query] 搜索关键字（用户ID/群聊ID/频道ID）
  /// [searchTypes] 搜索类型列表，默认搜索所有类型
  /// [limit] 每种类型的最大结果数，默认为10
  Future<UniversalSearchResponse?> search({
    required String query,
    List<String>? searchTypes,
    int limit = 10,
  }) async {
    if (query.trim().isEmpty) {
      _logger.w('搜索关键字不能为空');
      return null;
    }

    try {
      _logger.i('执行统一搜索', extra: {
        'query': query,
        'searchTypes': searchTypes ?? ['all'],
        'limit': limit,
      });

      // 检查通信服务是否可用
      if (!_communicationService.isInitialized ||
          !_communicationService.isConnected) {
        _logger.e('通信服务不可用');
        return null;
      }

      // 构建搜索请求
      final request = UniversalSearchRequest()
        ..query = query.trim()
        ..searchTypes.addAll(searchTypes ?? ['all'])
        ..limit = limit
        ..timestamp = Int64(DateTime.now().millisecondsSinceEpoch);

      _logger.d('发送统一搜索请求', extra: {
        'request': {
          'query': request.query,
          'searchTypes': request.searchTypes,
          'limit': request.limit,
        },
      });

      // 发送搜索请求
      final success = await _communicationService.emitProto(
        'search:universal',
        request,
      );

      if (!success) {
        _logger.e('发送统一搜索请求失败');
        return null;
      }

      // 等待搜索响应
      UniversalSearchResponse? response;
      try {
        response = await _communicationService
            .onProto<UniversalSearchResponse>('search:universal:response')
            .timeout(const Duration(seconds: 10))
            .first;
      } catch (timeoutError) {
        _logger.e('等待搜索响应超时', error: timeoutError);
        
        // 检查是否是proto解析错误，可能服务器还在返回旧格式
        if (timeoutError.toString().contains('InvalidProtocolBufferException')) {
          _logger.w('可能是proto格式不匹配，服务器可能还在使用旧的SearchConversationResult格式');
        }
        return null;
      }

      // 检查响应是否为空（理论上不会为空，但增加安全检查）
      _logger.i('收到统一搜索响应', extra: {
        'success': response.success,
        'userCount': response.userCount,
        'conversationCount': response.conversationCount,
        'query': response.query,
      });

      if (!response.success) {
        _logger.w('统一搜索失败: ${response.message}');
      }

      return response;
    } catch (error, stackTrace) {
      _logger.e('统一搜索异常', error: error, stackTrace: stackTrace);
      return null;
    }
  }

  /// 搜索用户
  ///
  /// [query] 搜索关键字（用户ID或手机号）
  /// [limit] 最大结果数
  Future<List<UserProto>> searchUsers({
    required String query,
    int limit = 10,
  }) async {
    final response = await search(
      query: query,
      searchTypes: ['user'],
      limit: limit,
    );

    return response?.users ?? [];
  }

  /// 搜索群聊
  ///
  /// [query] 搜索关键字（群聊ID或名称）
  /// [limit] 最大结果数
  Future<List<ConversationProto>> searchGroups({
    required String query,
    int limit = 10,
  }) async {
    final response = await search(
      query: query,
      searchTypes: ['group'],
      limit: limit,
    );

    return response?.conversations ?? [];
  }

  /// 搜索频道
  ///
  /// [query] 搜索关键字（频道ID或名称）
  /// [limit] 最大结果数
  Future<List<ConversationProto>> searchChannels({
    required String query,
    int limit = 10,
  }) async {
    final response = await search(
      query: query,
      searchTypes: ['channel'],
      limit: limit,
    );

    return response?.conversations ?? [];
  }

  /// 智能搜索
  /// 根据输入自动判断搜索类型并返回最相关的结果
  ///
  /// [query] 搜索关键字
  /// [limit] 每种类型的最大结果数
  Future<UniversalSearchResponse?> smartSearch({
    required String query,
    int limit = 5,
  }) async {
    final trimmedQuery = query.trim();

    // 根据输入特征推断搜索类型
    List<String> searchTypes = ['all'];

    // 如果是纯数字或特定格式，可能是ID
    if (RegExp(r'^[0-9]+$').hasMatch(trimmedQuery)) {
      searchTypes = ['user', 'group', 'channel'];
    }
    // 如果包含@符号，优先搜索用户
    else if (trimmedQuery.contains('@')) {
      searchTypes = ['user'];
    }
    // 如果包含"群"或"组"，优先搜索群聊
    else if (trimmedQuery.contains(RegExp(r'[群组]'))) {
      searchTypes = ['group'];
    }
    // 如果包含"频道"或"channel"，优先搜索频道
    else if (trimmedQuery
        .contains(RegExp(r'频道|channel', caseSensitive: false))) {
      searchTypes = ['channel'];
    }

    return await search(
      query: trimmedQuery,
      searchTypes: searchTypes,
      limit: limit,
    );
  }

  /// 解析搜索结果类型
  static String getSearchResultTypeLabel(String type) {
    switch (type.toLowerCase()) {
      case 'user':
        return '用户';
      case 'group':
        return '群聊';
      case 'channel':
        return '频道';
      default:
        return '未知';
    }
  }

  /// 格式化搜索结果摘要
  static String formatSearchSummary(UniversalSearchResponse response) {
    final List<String> parts = [];

    if (response.userCount > 0) {
      parts.add('${response.userCount}个用户');
    }

    if (response.conversationCount > 0) {
      final groups =
          response.conversations.where((c) => c.type == ConversationType.GROUP).length;
      final channels =
          response.conversations.where((c) => c.type == ConversationType.CHANNEL).length;

      if (groups > 0) {
        parts.add('$groups个群聊');
      }
      if (channels > 0) {
        parts.add('$channels个频道');
      }
    }

    if (parts.isEmpty) {
      return '未找到结果';
    }

    return '找到 ${parts.join('、')}';
  }
}
