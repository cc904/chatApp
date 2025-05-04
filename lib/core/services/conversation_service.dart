import 'package:cc/core/database/database_initializer.dart';
import 'package:cc/core/database/models/conversation.dart';
import 'package:cc/core/database/models/user.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:isar/isar.dart';

/// 会话服务
/// 负责处理会话的创建、更新和查询
class ConversationService {
  static final _logger = LogService('conversation_service.dart');
  static final _isar = DatabaseInitializer.isar;

  /// 创建私聊会话
  static Future<Conversation?> createPrivateConversation(String contactUserId) async {
    try {
      _logger.i('创建私聊会话', extra: {'contactUserId': contactUserId});

      // 检查是否已存在私聊会话
      final existingConversation = await _isar.conversations.where().filter().typeEqualTo(ConversationType.private).contactUserIdEqualTo(contactUserId).findFirst();

      if (existingConversation != null) {
        _logger.w('私聊会话已存在', extra: {'conversationId': existingConversation.conversationId});
        return existingConversation;
      }

      // 获取联系人信息
      final contactId = int.tryParse(contactUserId);
      if (contactId == null) {
        _logger.e('无效的联系人ID', extra: {'contactUserId': contactUserId});
        return null;
      }

      final contact = await _isar.users.get(contactId);
      if (contact == null) {
        _logger.e('联系人不存在', extra: {'contactUserId': contactUserId});
        return null;
      }

      // 创建新会话
      final conversation = Conversation()
        ..type = ConversationType.private
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

      _logger.i('私聊会话创建成功', extra: {'conversationId': conversation.conversationId});
      return conversation;
    } catch (e) {
      _logger.e('创建私聊会话失败', error: e);
      return null;
    }
  }

  /// 创建群聊会话
  static Future<Conversation?> createGroupConversation(String name, List<String> participantIds) async {
    try {
      _logger.i('创建群聊会话', extra: {
        'name': name,
        'participantCount': participantIds.length,
      });

      // 创建新会话
      final conversation = Conversation()
        ..type = ConversationType.group
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

      _logger.i('群聊会话创建成功', extra: {'conversationId': conversation.conversationId});
      return conversation;
    } catch (e) {
      _logger.e('创建群聊会话失败', error: e);
      return null;
    }
  }

  /// 获取会话列表
  static Future<List<Conversation>> getConversations({int limit = 20, int offset = 0}) async {
    try {
      _logger.i('获取会话列表', extra: {
        'limit': limit,
        'offset': offset,
      });

      final conversations = await _isar.conversations.where().sortByLastMessageTime().offset(offset).limit(limit).findAll();

      _logger.i('获取会话列表成功', extra: {'count': conversations.length});
      return conversations;
    } catch (e) {
      _logger.e('获取会话列表失败', error: e);
      return [];
    }
  }

  /// 获取会话详情
  static Future<Conversation?> getConversation(String conversationId) async {
    try {
      _logger.i('获取会话详情', extra: {'conversationId': conversationId});

      final id = int.tryParse(conversationId);
      if (id == null) {
        _logger.w('无效的会话ID', extra: {'conversationId': conversationId});
        return null;
      }

      final conversation = await _isar.conversations.get(id);
      if (conversation == null) {
        _logger.w('会话不存在', extra: {'conversationId': conversationId});
        return null;
      }

      _logger.i('获取会话详情成功');
      return conversation;
    } catch (e) {
      _logger.e('获取会话详情失败', error: e);
      return null;
    }
  }

  /// 更新会话信息
  static Future<bool> updateConversation(String conversationId, {String? name, String? avatar}) async {
    try {
      _logger.i('更新会话信息', extra: {
        'conversationId': conversationId,
        'name': name,
        'avatar': avatar,
      });

      final id = int.tryParse(conversationId);
      if (id == null) {
        _logger.w('无效的会话ID', extra: {'conversationId': conversationId});
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

      _logger.i('更新会话信息成功');
      return success;
    } catch (e) {
      _logger.e('更新会话信息失败', error: e);
      return false;
    }
  }

  /// 删除会话
  static Future<bool> deleteConversation(String conversationId) async {
    try {
      _logger.i('删除会话', extra: {'conversationId': conversationId});

      final id = int.tryParse(conversationId);
      if (id == null) {
        _logger.w('无效的会话ID', extra: {'conversationId': conversationId});
        return false;
      }

      final success = await _isar.writeTxn(() async {
        final conversation = await _isar.conversations.get(id);
        if (conversation == null) return false;

        await _isar.conversations.delete(id);
        return true;
      });

      _logger.i('删除会话成功');
      return success;
    } catch (e) {
      _logger.e('删除会话失败', error: e);
      return false;
    }
  }
}
