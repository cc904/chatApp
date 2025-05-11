import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/services/communication_service.dart';
import 'package:cc/core/proto/generated/conversation.pb.dart';
import 'package:fixnum/fixnum.dart' as $fixnum;

/// 演示如何修复sync_conversations功能
///
/// 本示例展示如何正确处理会话同步事件
class ConversationSyncExample {
    final _logger = LogService.instance;
  final CommunicationService _communicationService = CommunicationService();

  /// 初始化并注册正确的会话同步事件处理
  void initAndFixSyncConversations() {
    _logger.i('初始化并修复会话同步功能');

    // 第一步：确保sync_conversations事件注册了正确的消息类型
    // 在proto_events.dart中将其改为:
    // 'sync_conversations': () => ConversationCollection(),

    // 第二步：正确实现ConversationCollection类
    // 应该在protos/conversation_collection.proto中定义，并生成相应的Dart类

    // 第三步：注册自定义事件处理器
    // 这里我们使用示例实现（实际项目应使用生成的Protobuf类）
    _registerConversationSyncEvent();

    // 第四步：更新所有使用该事件的服务
    _logger.i('会话同步功能修复完成');
  }

  /// 注册自定义会话同步事件
  void _registerConversationSyncEvent() {
    // 在实际项目中，应该使用正确的ConversationCollection类
    // 这里仅作为示例，演示如何注册自定义事件

    _communicationService.registerCustomEvent<ConversationProto>('sync_conversations', () => ConversationProto());

    _logger.i('注册自定义会话同步事件');
  }

  /// 发送会话同步请求
  /// [userId] - 用户ID
  /// [lastSyncTime] - 上次同步时间
  Future<void> requestSyncConversations(String userId, int lastSyncTime) async {
    _logger.i('发送会话同步请求', extra: {
      'userId': userId,
      'lastSyncTime': lastSyncTime,
    });

    // 创建一个简单的请求对象
    // 注意：实际项目应该使用SyncConversationsRequest类
    final request = ConversationProto(
      conversationId: 'sync_request',
      createdBy: userId,
      createdAt: $fixnum.Int64(lastSyncTime),
    );

    try {
      // 发送同步请求
      await _communicationService.emitProto('sync_conversations', request);
      _logger.i('会话同步请求已发送');
    } catch (e) {
      _logger.e('发送会话同步请求失败', error: e);
    }
  }

  /// 处理同步响应
  void handleSyncResponse() {
    // 监听会话同步响应
    _communicationService.onProto<ConversationProto>('sync_conversations').listen((response) {
      _logger.i('收到会话同步响应');

      // 在实际项目中，这应该是一个ConversationCollection对象
      // 包含多个会话信息

      // 示例：处理单个会话
      _handleConversation(response);
    });
  }

  /// 处理会话数据
  void _handleConversation(ConversationProto conversation) {
    _logger.i('处理会话数据', extra: {
      'conversationId': conversation.conversationId,
      'participants': conversation.participantIds,
    });

    // 根据业务需求处理会话
  }
}

/// 完整修复步骤总结
/// 
/// 1. 定义正确的Protobuf消息类型:
///    - 创建 conversation_collection.proto 文件
///    - 定义 ConversationCollection, SyncConversationsRequest, SyncConversationsResponse 消息类型
/// 
/// 2. 生成Dart类:
///    - 运行 protoc 命令生成Dart类
///    - 确保生成的类被正确导入
/// 
/// 3. 更新事件映射:
///    - 在 ProtoEvents 类中正确关联 'sync_conversations' 事件与 ConversationCollection 类型
/// 
/// 4. 使用类型安全的API:
///    - 使用 emitProto<SyncConversationsRequest>() 发送请求
///    - 使用 onProto<SyncConversationsResponse>() 接收响应
/// 
/// 5. 处理数据:
///    - 从响应中提取会话列表
///    - 更新UI和本地数据库 