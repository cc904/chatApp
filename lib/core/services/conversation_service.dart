import 'dart:async';
import 'package:cc/core/proto/generated/conversation.pb.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/services/communication_service.dart';
import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:cc/core/database/database_initializer.dart';
import 'package:cc/core/database/models/conversation.dart' as db;
import 'package:cc/core/database/models/user.dart';
import 'package:isar/isar.dart';
import 'package:cc/core/proto/generated/conversation.pb.dart' as proto;

/// 会话服务
/// 处理会话相关操作，如同步会话、获取会话列表等
/// 使用Protobuf通信
class ConversationService {
  static final _isar = DatabaseInitializer.isar;
  final LogService _logger = LogService.instance;
  final CommunicationService _communicationService = CommunicationService();

  // 会话列表流控制器
  final StreamController<List<ConversationProto>> _conversationsController = StreamController<List<ConversationProto>>.broadcast();
  Stream<List<ConversationProto>> get conversationsStream => _conversationsController.stream;

  // 维护最新的会话列表
  final List<ConversationProto> _conversations = [];
  List<ConversationProto> get conversations => List.unmodifiable(_conversations);

  // 单例模式
  static final ConversationService _instance = ConversationService._internal();
  factory ConversationService() => _instance;
  ConversationService._internal();

  /// 初始化服务
  Future<void> init() async {
    _logger.i('初始化会话服务');

    // 监听会话更新
    _communicationService.onProto<ConversationProto>('conversation:update').listen((conversation) {
      _updateConversation(conversation);
    });

    // 监听会话创建
    _communicationService.onProto<ConversationProto>('conversation:created').listen((conversation) {
      _addConversation(conversation);
    });

    // 监听会话删除
    _communicationService.onProto<ConversationProto>('conversation:deleted').listen((conversation) {
      _removeConversation(conversation.conversationId);
    });

    // 监听会话同步响应
    _communicationService.onProto<ConversationCollection>('conversation:sync:result').listen((response) {
      _logger.i('收到会话同步响应');
      _handleSyncConversationsResponse(response);
    });

    _logger.i('会话服务初始化完成');
  }

  /// 处理会话同步响应
  void _handleSyncConversationsResponse(ConversationCollection collection) {
    _logger.i('处理会话同步响应', extra: {
      'count': collection.conversations.length,
    });

    // 更新会话列表
    for (final conversation in collection.conversations) {
      _updateConversation(conversation);
    }

    _logger.i('同步完成，更新了 ${collection.conversations.length} 个会话');
  }

  /// 更新会话
  void _updateConversation(ConversationProto conversation) {
    _logger.d('更新会话', extra: {'conversationId': conversation.conversationId});

    // 查找现有会话
    final index = _conversations.indexWhere((c) => c.conversationId == conversation.conversationId);

    if (index >= 0) {
      // 更新现有会话
      _conversations[index] = conversation;
    } else {
      // 添加新会话
      _conversations.add(conversation);
    }

    // 按最后消息时间排序
    _sortConversations();

    // 通知监听器
    _notifyListeners();
  }

  /// 添加会话
  void _addConversation(ConversationProto conversation) {
    _logger.d('添加会话', extra: {'conversationId': conversation.conversationId});

    // 确保不重复添加
    if (!_conversations.any((c) => c.conversationId == conversation.conversationId)) {
      _conversations.add(conversation);

      // 排序
      _sortConversations();

      // 通知监听器
      _notifyListeners();
    }
  }

  /// 移除会话
  void _removeConversation(String conversationId) {
    _logger.d('移除会话', extra: {'conversationId': conversationId});

    _conversations.removeWhere((c) => c.conversationId == conversationId);

    // 通知监听器
    _notifyListeners();
  }

  /// 对会话进行排序
  void _sortConversations() {
    _conversations.sort((a, b) {
      // 先按置顶状态排序
      if (a.pinned && !b.pinned) return -1;
      if (!a.pinned && b.pinned) return 1;

      // 再按最后消息时间排序
      return b.lastMessageTime.compareTo(a.lastMessageTime);
    });
  }

  /// 通知监听器
  void _notifyListeners() {
    _conversationsController.add(List.from(_conversations));
  }

  /// 同步会话
  /// 请求服务器同步最新的会话列表
  Future<void> syncConversations() async {
    _logger.i('请求同步会话');

    try {
      final syncRequest = proto.SyncConversationsRequest()
        ..userId = 'current_user_id'
        ..localConversationIds.addAll([]); // 添加本地会话ID列表

      // 发送同步请求
      _communicationService.emitProto('conversation:sync', syncRequest);
      _logger.i('会话同步请求已发送');
    } catch (error) {
      _logger.e('同步会话失败', error: error, stackTrace: StackTrace.current);
    }
  }

  /// 获取会话详情
  /// [conversationId] - 会话ID
  Future<ConversationProto?> getConversation(String conversationId) async {
    return _conversations.firstWhere(
      (c) => c.conversationId == conversationId,
      orElse: () => ConversationProto(),
    );
  }

  /// 创建新会话
  /// [participants] - 参与者ID列表
  /// [name] - 会话名称（群聊必须，私聊可选）
  /// [type] - 会话类型
  Future<void> createConversation({
    required List<String> participants,
    String? name,
    ConversationType type = ConversationType.private,
  }) async {
    _logger.i('创建会话', extra: {
      'participants': participants,
      'name': name,
      'type': type.toString(),
    });

    final conversation = ConversationProto(
      conversationId: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      type: type,
      createdAt: $fixnum.Int64(DateTime.now().millisecondsSinceEpoch),
    );

    // 添加参与者
    conversation.participantIds.addAll(participants);

    try {
      // 发送创建会话请求
      await _communicationService.emitProto('conversation:create', conversation);
      _logger.i('创建会话请求已发送');
    } catch (error) {
      _logger.e('创建会话失败', error: error, stackTrace: StackTrace.current);
    }
  }

  /// 释放资源
  void dispose() {
    _logger.i('释放会话服务资源');
    _conversationsController.close();
  }

  /// 创建私聊会话
  static Future<db.Conversation?> createPrivateConversation(String contactUserId) async {
    final logger = LogService.instance;
    try {
      logger.i('创建私聊会话', extra: {'contactUserId': contactUserId});

      // 检查是否已存在私聊会话
      final existingConversation = await _isar.conversations.where().filter().typeEqualTo(db.ConversationType.private).contactUserIdEqualTo(contactUserId).findFirst();

      if (existingConversation != null) {
        logger.w('私聊会话已存在', extra: {'conversationId': existingConversation.conversationId});
        return existingConversation;
      }

      // 获取联系人信息
      final contactId = int.tryParse(contactUserId);
      if (contactId == null) {
        logger.e('无效的联系人ID', extra: {'contactUserId': contactUserId});
        return null;
      }

      final contact = await _isar.users.get(contactId);
      if (contact == null) {
        logger.e('联系人不存在', extra: {'contactUserId': contactUserId});
        return null;
      }

      // 创建新会话
      final conversation = db.Conversation()
        ..type = db.ConversationType.private
        ..name = contact.name
        ..contactUserId = contactUserId
        ..createdAt = DateTime.now();

      // 保存会话
      await _isar.writeTxn(() async {
        conversation.id = await _isar.conversations.put(conversation);
        conversation.conversationId = conversation.id.toString();
        await _isar.conversations.put(conversation);

        // 添加参与者
        conversation.participants.add(contact);
        await conversation.participants.save();
      });

      logger.i('私聊会话创建成功', extra: {'conversationId': conversation.conversationId});
      return conversation;
    } catch (error) {
      logger.e('创建私聊会话失败', error: error, stackTrace: StackTrace.current);
      return null;
    }
  }

  /// 创建群聊会话
  static Future<db.Conversation?> createGroupConversation(String name, List<String> participantIds) async {
    final logger = LogService.instance;
    try {
      logger.i('创建群聊会话', extra: {
        'name': name,
        'participantCount': participantIds.length,
      });

      // 创建新会话
      final conversation = db.Conversation()
        ..type = db.ConversationType.group
        ..name = name
        ..createdAt = DateTime.now();

      // 保存会话
      await _isar.writeTxn(() async {
        conversation.id = await _isar.conversations.put(conversation);
        conversation.conversationId = conversation.id.toString();
        await _isar.conversations.put(conversation);

        // 添加参与者
        for (final participantId in participantIds) {
          final id = int.tryParse(participantId);
          if (id != null) {
            final participant = await _isar.users.get(id);
            if (participant != null) {
              conversation.participants.add(participant);
            }
          }
        }
        await conversation.participants.save();
      });

      logger.i('群聊会话创建成功', extra: {'conversationId': conversation.conversationId});
      return conversation;
    } catch (error) {
      logger.e('创建群聊会话失败', error: error, stackTrace: StackTrace.current);
      return null;
    }
  }

  /// 获取会话列表
  static Future<List<db.Conversation>> getConversations({int limit = 20, int offset = 0}) async {
    final logger = LogService.instance;
    try {
      logger.i('获取会话列表', extra: {
        'limit': limit,
        'offset': offset,
      });

      final conversations = await _isar.conversations.where().sortByLastMessageTime().offset(offset).limit(limit).findAll();

      logger.i('获取会话列表成功', extra: {'count': conversations.length});
      return conversations;
    } catch (error) {
      logger.e('获取会话列表失败', error: error, stackTrace: StackTrace.current);
      return [];
    }
  }

  /// 更新会话信息
  static Future<bool> updateConversation(String conversationId, {String? name, String? avatar}) async {
    final logger = LogService.instance;
    try {
      logger.i('更新会话信息', extra: {
        'conversationId': conversationId,
        'name': name,
        'avatar': avatar,
      });

      final id = int.tryParse(conversationId);
      if (id == null) {
        logger.w('无效的会话ID', extra: {'conversationId': conversationId});
        return false;
      }

      final success = await _isar.writeTxn(() async {
        final conversation = await _isar.conversations.get(id);
        if (conversation == null) return false;

        if (name != null) conversation.name = name;
        if (avatar != null) conversation.avatar = avatar;

        await _isar.conversations.put(conversation);
        return true;
      });

      logger.i('更新会话信息成功');
      return success;
    } catch (error) {
      logger.e('更新会话信息失败', error: error, stackTrace: StackTrace.current);
      return false;
    }
  }

  /// 删除会话
  static Future<bool> deleteConversation(String conversationId) async {
    final logger = LogService.instance;
    try {
      logger.i('删除会话', extra: {'conversationId': conversationId});

      final id = int.tryParse(conversationId);
      if (id == null) {
        logger.w('无效的会话ID', extra: {'conversationId': conversationId});
        return false;
      }

      final success = await _isar.writeTxn(() async {
        final conversation = await _isar.conversations.get(id);
        if (conversation == null) return false;

        await _isar.conversations.delete(id);
        return true;
      });

      logger.i('删除会话成功');
      return success;
    } catch (error) {
      logger.e('删除会话失败', error: error, stackTrace: StackTrace.current);
      return false;
    }
  }
}
