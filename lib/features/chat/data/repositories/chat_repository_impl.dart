import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:cc/core/database/database_initializer.dart';
import 'package:cc/core/database/models/conversation.dart' as db;
import 'package:cc/core/database/models/message.dart';
import 'package:cc/core/database/models/user.dart';
import 'package:cc/core/services/file_upload_service.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/services/communication_service.dart';
import 'package:cc/features/chat/domain/repositories/chat_repository.dart';
import 'package:cc/features/profile/data/repositories/profile_repository.dart';
import 'package:isar/isar.dart';
import 'package:cc/core/proto/generated/message.pb.dart' as message_proto;
import 'package:cc/core/proto/generated/conversation.pb.dart' as conversation_proto;
import 'package:fixnum/fixnum.dart' as $fixnum;

/// 消息异常
class MessageException implements Exception {
  final String message;
  MessageException(this.message);

  @override
  String toString() => message;
}

/// ChatRepository的实现类
/// 负责聊天相关的数据处理、消息收发、实时通信等功能
/// 主要功能包括：
/// 1. 会话管理：创建、获取、删除会话
/// 2. 消息管理：发送、接收、查询、删除消息
/// 3. 实时通信：管理Socket连接、处理实时事件
/// 4. 联系人操作：获取联系人信息、同步联系人
/// 同步响应类，用于内部处理服务器同步结果
class _SyncResponse {
  final bool success;
  final List<db.Conversation> conversations;
  final String? errorMessage;

  _SyncResponse(this.success, this.conversations, this.errorMessage);
}

class ChatRepositoryImpl implements ChatRepository {
  final LogService _logger = LogService.instance;
  final CommunicationService _communicationService = CommunicationService();

  /// 文件上传服务,处理媒体文件上传
  final FileUploadService _fileUploadService = FileUploadService();

  /// 消息流控制器,用于向UI发送新消息通知
  final StreamController<Message> _newMessagesController = StreamController<Message>.broadcast();

  /// 输入状态流控制器,传递用户输入状态事件
  final StreamController<Map<String, dynamic>> _typingStatusController = StreamController<Map<String, dynamic>>.broadcast();

  /// 在线状态流控制器,传递用户在线状态事件
  final StreamController<Map<String, dynamic>> _onlineStatusController = StreamController<Map<String, dynamic>>.broadcast();

  /// 消息状态流控制器,传递消息送达/已读状态事件
  final StreamController<Map<String, dynamic>> _messageStatusController = StreamController<Map<String, dynamic>>.broadcast();

  /// 同步状态流控制器,传递数据同步状态事件
  final StreamController<SyncStatus> _syncStatusController = StreamController<SyncStatus>.broadcast();

  /// 通信服务事件订阅集合
  final List<StreamSubscription> _subscriptions = [];

  // 获取消息流
  Stream<Message> get messageStream => _newMessagesController.stream;

  // 获取当前数据库实例
  final Isar _isar;

  // 获取用户集合
  IsarCollection<User> get _users => _isar.users;

  // 获取会话集合
  IsarCollection<db.Conversation> get _conversations => _isar.conversations;

  // 获取消息集合
  IsarCollection<Message> get _messages => _isar.messages;

  final String _currentUserId;

  final _conversationStateController = StreamController<List<db.Conversation>>.broadcast();

  /// 用户信息仓库
  final ProfileRepository _profileRepository = ProfileRepository();

  // 构造函数
  ChatRepositoryImpl({required Isar isar, required String currentUserId})
      : _isar = isar,
        _currentUserId = currentUserId {
    // 初始化用户信息仓库
    _profileRepository.init().then((_) {
      _logger.i('用户信息仓库初始化成功');
    }).catchError((error) {
      _logger.e('用户信息仓库初始化失败', error: error);
    });
    
    // 注册事件处理
    _registerEventHandlers();
  }

  /// 注册事件监听
  void _registerEventHandlers() {
    // 监听新消息事件
    _communicationService.onProto<message_proto.NewMessageProto>('message:new').listen(_handleNewMessage);

    // 监听消息状态更新
    _communicationService.onProto<message_proto.MessageDeliveredProto>('message:delivered').listen(_handleMessageDelivered);
    _communicationService.onProto<message_proto.MessageReadProto>('message:read').listen(_handleMessageRead);
  }

  /// 处理新消息
  void _handleNewMessage(message_proto.NewMessageProto data) {
    try {
      // 创建消息对象
      final message = Message()
        ..messageId = data.id
        ..conversationId = data.conversationId
        ..senderId = data.senderId
        ..createdAt = DateTime.fromMillisecondsSinceEpoch(data.timestamp.toInt())
        ..text = data.content
        ..type = data.type
        ..isRead = false
        ..status = 'received';

      // 保存消息
      _isar.writeTxn(() async {
        message.id = await _messages.put(message);
      });

      // 通知UI
      _newMessagesController.add(message);
    } catch (error) {
      _logger.e('处理新消息失败', error: error, stackTrace: StackTrace.current);
    }
  }

  /// 处理消息已送达事件
  void _handleMessageDelivered(message_proto.MessageDeliveredProto data) {
    try {
      _messageStatusController.add({
        'messageId': data.messageId,
        'conversationId': data.conversationId,
        'status': 'delivered',
      });
    } catch (error) {
      _logger.e('处理消息已送达事件失败', error: error, stackTrace: StackTrace.current);
    }
  }

  /// 处理消息已读事件
  void _handleMessageRead(message_proto.MessageReadProto data) {
    try {
      _messageStatusController.add({
        'messageId': data.messageId,
        'conversationId': data.conversationId,
        'status': 'read',
      });
    } catch (error) {
      _logger.e('处理消息已读事件失败', error: error, stackTrace: StackTrace.current);
    }
  }

  /// 获取联系人信息
  /// 根据ID获取单个联系人详情
  /// [userId] - 联系人ID
  /// 返回联系人信息,不存在则返回null
  @override
  Future<User?> getContactById(String userId) async {
    try {
      int id = int.tryParse(userId) ?? 0;
      return await _users.get(id);
    } catch (error) {
      _logger.e('获取联系人信息失败', error: error, stackTrace: StackTrace.current);
      return null;
    }
  }

  /// 获取当前用户ID
  /// 从用户服务获取当前登录用户的ID
  /// 返回用户ID,如未找到则抛出异常
  Future<String> _getCurrentUserId() async {
    final currentUser = await _profileRepository.getCurrentUser();
    if (currentUser == null) {
      throw Exception('找不到当前用户信息,请确保已登录');
    }
    return currentUser.userId;
  }

  /// 获取所有会话
  /// 从服务器同步会话列表，并保存到本地数据库
  /// 只同步有未读消息的会话以及已经保存在本地的会话
  /// 返回会话列表
  @override
  Future<List<db.Conversation>> getAllConversations() async {
    try {
      _logger.i('开始从服务器同步会话列表');

      // 标记同步开始
      _syncStatusController.add(SyncStatus.syncing);

      // 先获取本地已保存的会话列表
      final localConversations = await _conversations.where().findAll();
      final localConversationIds = localConversations.map((c) => c.conversationId).toSet();

      // 从服务器获取会话列表（仅包含有未读消息的会话以及本地已有的会话）
      final syncResponse = await _syncConversationsFromServer(localConversationIds);

      // 如果同步成功，更新本地数据库
      if (syncResponse.success) {
        await _updateLocalConversations(syncResponse.conversations);
        _logger.i('会话列表同步成功', extra: {'count': syncResponse.conversations.length});
      } else {
        _logger.w('会话列表同步失败，使用本地数据', extra: {'error': syncResponse.errorMessage});
      }

      // 从数据库获取最新的会话列表
      final conversations = await _conversations.where().findAll();

      // 手动按lastMessageTime降序排序,将null值排在最后
      conversations.sort((a, b) {
        if (a.lastMessageTime == null) return 1;
        if (b.lastMessageTime == null) return -1;
        return b.lastMessageTime!.compareTo(a.lastMessageTime!);
      });

      // 标记同步完成
      _syncStatusController.add(SyncStatus.completed);
      return conversations;
    } catch (error, stack) {
      _logger.e('获取会话列表失败', error: error, stackTrace: stack);

      // 标记同步错误
      _syncStatusController.add(SyncStatus.error);

      // 尝试返回本地数据
      try {
        final localConversations = await _conversations.where().findAll();

        localConversations.sort((a, b) {
          if (a.lastMessageTime == null) return 1;
          if (b.lastMessageTime == null) return -1;
          return b.lastMessageTime!.compareTo(a.lastMessageTime!);
        });
        _logger.d('返回本地会话列表作为备选', extra: {'count': localConversations.length});
        return localConversations;
      } catch (localError) {
        _logger.e('获取本地会话列表也失败', error: localError);
        return [];
      }
    }
  }

  /// 从服务器同步会话列表
  /// 只同步有未读消息的会话以及本地已有的会话
  /// [localConversationIds] - 本地已有的会话ID集合
  /// 返回同步响应，包含同步是否成功和会话列表
  Future<_SyncResponse> _syncConversationsFromServer(Set<String> localConversationIds) async {
    try {
      if (!_communicationService.isInitialized) {
        return _SyncResponse(false, [], '通信服务未初始化');
      }

      // 创建同步请求数据
      final request = conversation_proto.SyncConversationsRequest()
        ..localConversationIds.addAll(localConversationIds)
        ..userId = _currentUserId;

      // 设置等待响应的Completer
      final completer = Completer<List<conversation_proto.ConversationProto>>();

      // 定义事件处理函数
      void handleSyncResult(dynamic data) {
        _logger.i('收到会话同步响应', extra: {'dataType': data.runtimeType});

        try {
          // 处理二进制数据
          if (data is Uint8List || data is ByteData || (data != null && data.runtimeType.toString().contains('Uint8'))) {
            // 直接解析二进制数据
            final response = conversation_proto.ConversationCollection()..mergeFromBuffer(data);

            _logger.i('解析到 ${response.conversations.length} 个会话');
            if (response.conversations.isEmpty) {
              _logger.i('会话列表为空，这可能是新用户或同步过程中的正常状态');
            }

            if (!completer.isCompleted) {
              completer.complete(response.conversations);
            }

            // 处理同步数据
            _handleSyncedConversations(response.conversations);
          } else {
            _logger.w('同步响应数据格式不支持', extra: {'dataType': data.runtimeType, 'data': data});
            if (!completer.isCompleted) {
              completer.complete([]);
            }
          }
        } catch (e, stack) {
          _logger.e('处理同步响应数据失败', error: e, stackTrace: stack);
          if (!completer.isCompleted) {
            completer.complete([]);
          }
        }
      }

      // 注册事件监听
      _communicationService.onRawEvent('conversation:sync:result', handleSyncResult);

      // 发送同步请求
      await _communicationService.emitProto('conversation:sync', request);

      // 等待响应
      final conversations = await completer.future;

      // 取消事件监听
      _communicationService.offRawEvent('conversation:sync:result');

      // 处理响应
      if (conversations.isNotEmpty) {
        final dbConversations = conversations.map((data) => _convertProtoToDbConversation(data)).whereType<db.Conversation>().toList();
        return _SyncResponse(true, dbConversations, null);
      }

      return _SyncResponse(false, [], '同步失败：未收到会话数据');
    } catch (error) {
      _logger.e('从服务器同步会话列表失败', error: error, stackTrace: StackTrace.current);
      return _SyncResponse(false, [], error.toString());
    }
  }

  /// 更新本地会话数据
  /// 将服务器返回的会话数据保存到本地数据库
  /// [serverConversations] - 从服务器获取的会话列表
  Future<void> _updateLocalConversations(List<db.Conversation> serverConversations) async {
    try {
      await _isar.writeTxn(() async {
        for (final conversation in serverConversations) {
          // 检查会话是否已存在
          // 根据会话ID查询本地数据库中是否已存在该会话记录
          // _conversations是Isar数据库的会话表访问器
          // filter()创建查询过滤器
          // conversationIdEqualTo()匹配指定的会话ID
          // findFirst()返回第一条匹配的记录,不存在则返回null
          final existing = await _conversations.filter().conversationIdEqualTo(conversation.conversationId).findFirst();

          if (existing != null) {
            // 只有当服务器的最后消息时间更新时才更新本地数据
            if (conversation.lastMessageTime != null && (existing.lastMessageTime == null || conversation.lastMessageTime!.isAfter(existing.lastMessageTime!))) {
              await _conversations.put(conversation);
              _logger.d('更新已有会话', extra: {'conversationId': conversation.conversationId});
            }
          } else {
            // 添加新会话
            await _conversations.put(conversation);
            _logger.d('添加新会话', extra: {'conversationId': conversation.conversationId});
          }
        }
      });
    } catch (error) {
      _logger.e('更新本地会话数据失败', extra: {'error': error.toString()});
      throw Exception('更新本地会话数据失败: $error');
    }
  }

  /// 获取会话信息
  /// 根据ID获取单个会话详情
  /// [conversationId] - 会话ID
  /// 返回会话信息,不存在则返回null
  @override
  Future<db.Conversation?> getConversationById(String conversationId) async {
    try {
      int id = int.tryParse(conversationId) ?? 0;
      // 使用生成的访问器
      return await _conversations.get(id);
    } catch (error) {
      _logger.e('获取会话信息失败', error: error, stackTrace: StackTrace.current);
      return null;
    }
  }

  /// 获取或创建私聊会话
  /// 根据联系人ID查找已有会话,不存在则创建新会话
  /// [contactUserId] - 联系人ID
  /// 返回会话对象
  @override
  Future<db.Conversation> getOrCreatePrivateConversation(String contactUserId) async {
    try {
      // 先查找已有的私聊会话
      final existing = await _conversations.filter().typeEqualTo(db.ConversationType.private).and().contactUserIdEqualTo(contactUserId).findFirst();

      if (existing != null) {
        return existing;
      }

      // 创建新会话
      final contact = await getContactById(contactUserId);
      if (contact == null) {
        throw Exception('联系人不存在');
      }

      final conversation = db.Conversation();
      conversation.type = db.ConversationType.private;
      conversation.name = contact.name;
      conversation.contactUserId = contactUserId;

      await _isar.writeTxn(() async {
        conversation.id = await _conversations.put(conversation);
        await _conversations.put(conversation);

        // 添加会话参与者
        conversation.participants.add(contact);
        await conversation.participants.save();
      });

      return conversation;
    } catch (error) {
      _logger.e('获取或创建私聊会话失败', error: error, stackTrace: StackTrace.current);
      rethrow;
    }
  }

  /// 创建群聊会话
  /// 创建新的群组会话并添加成员
  /// [name] - 群聊名称
  /// [memberIds] - 群成员ID列表
  /// [avatar] - 可选的群头像
  /// 返回创建的群聊会话
  @override
  Future<db.Conversation> createGroupConversation(String name, List<String> memberIds, {String? avatar}) async {
    try {
      // 创建新的群聊会话
      final conversation = db.Conversation()
        ..type = db.ConversationType.group
        ..name = name
        ..avatar = avatar
        ..createdAt = DateTime.now();

      await _isar.writeTxn(() async {
        // 保存会话
        conversation.id = await _conversations.put(conversation);
        await _conversations.put(conversation);

        // 添加当前用户
        final currentUserId = await _getCurrentUserId();
        final currentUser = await getContactById(currentUserId);
        if (currentUser != null) {
          conversation.participants.add(currentUser);
        }

        // 添加其他成员
        for (final memberId in memberIds) {
          final member = await getContactById(memberId);
          if (member != null) {
            conversation.participants.add(member);
          }
        }

        await conversation.participants.save();
      });

      return conversation;
    } catch (error) {
      _logger.e('创建群聊失败', error: error, stackTrace: StackTrace.current);
      rethrow;
    }
  }

  /// 获取会话消息
  /// 获取指定会话的消息列表,支持分页
  /// [conversationId] - 会话ID
  /// [limit] - 获取消息的最大数量
  /// [before] - 可选的时间点,获取此时间之前的消息
  /// 返回消息列表
  @override
  Future<List<Message>> getConversationMessages(String conversationId, {int limit = 20, DateTime? before}) async {
    try {
      final query = _messages.filter().conversationIdEqualTo(conversationId).optional(before != null, (q) => q.createdAtLessThan(before!)).sortByCreatedAtDesc();

      final messages = await query.limit(limit).findAll();
      return messages;
    } catch (error) {
      _logger.e('获取会话消息失败', error: error, stackTrace: StackTrace.current);
      return [];
    }
  }

  /// 搜索消息
  /// 根据关键词搜索消息
  /// [keyword] - 搜索关键词
  /// [conversationId] - 可选的会话ID,限定搜索范围
  /// 返回匹配的消息列表
  @override
  Future<List<Message>> searchMessages(String keyword, {String? conversationId}) async {
    try {
      if (keyword.isEmpty) {
        return [];
      }

      final query = _messages
          .filter()
          .optional(conversationId != null, (q) => q.conversationIdEqualTo(conversationId!))
          .and()
          .optional(keyword.isNotEmpty, (q) => q.textContains(keyword, caseSensitive: false));

      final messages = await query.sortByCreatedAtDesc().findAll();
      return messages;
    } catch (error) {
      _logger.e('搜索消息失败', error: error, stackTrace: StackTrace.current);
      return [];
    }
  }

  /// 将消息标记为已读
  /// 更新指定会话中所有未读消息的状态为已读
  /// [conversationId] - 会话ID
  Future<void> markMessagesAsRead(String conversationId) async {
    try {
      await _isar.writeTxn(() async {
        final messages = await _messages.filter().conversationIdEqualTo(conversationId).and().isReadEqualTo(false).findAll();
        for (final message in messages) {
          message.isRead = true;
          await _messages.put(message);
        }

        // 更新会话未读数
        final conversation = await getConversationById(conversationId);
        if (conversation != null) {
          conversation.unreadCount = 0;
          await _conversations.put(conversation);
        }
      });
    } catch (error) {
      _logger.e('标记消息为已读失败', error: error, stackTrace: StackTrace.current);
    }
  }

  /// 标记会话为已读
  /// 调用markMessagesAsRead方法实现
  /// [conversationId] - 会话ID
  @override
  Future<void> markConversationAsRead(String conversationId) async {
    // 调用已实现的markMessagesAsRead方法
    await markMessagesAsRead(conversationId);
  }

  /// 监听会话变化
  /// 返回会话列表变化的流
  @override
  Stream<void> watchConversations() {
    return _conversations.watchLazy();
  }

  /// 监听会话消息变化
  /// 监听指定会话中消息的变化
  /// [conversationId] - 会话ID
  /// 返回消息变化的流
  @override
  Stream<void> watchConversationMessages(String conversationId) {
    return _messages.filter().conversationIdEqualTo(conversationId).watchLazy();
  }

  /// 监听联系人变化
  /// 返回联系人列表变化的流
  @override
  Stream<void> watchContacts() {
    return _users.watchLazy();
  }

  /// 发送文本消息
  /// 创建并发送文本类型的消息
  /// [conversationId] - 会话ID
  /// [text] - 消息文本内容
  /// 返回创建的消息对象
  @override
  Future<Message> sendTextMessage(String conversationId, String text) async {
    final message = await _createMessage(conversationId, text, 'text');
    await sendMessage(message);
    return message;
  }

  /// 发送图片消息
  /// 创建并发送图片类型的消息,可选上传图片
  /// [conversationId] - 会话ID
  /// [localPath] - 图片本地路径
  /// [mediaUrl] - 可选的媒体URL,如已上传则直接使用
  /// 返回创建的消息对象
  @override
  Future<Message> sendImageMessage(String conversationId, String localPath, {String? mediaUrl}) async {
    final message = await _createMessage(conversationId, '', 'image');

    if (mediaUrl != null) {
      message.mediaUrl = mediaUrl;
    } else {
      final imageFile = File(localPath);
      // 上传图片
      final uploadResult = await _fileUploadService.uploadImage(imageFile);
      if (uploadResult != null) {
        message.mediaUrl = uploadResult.remoteUrl;
      }
    }
    message.localPath = localPath;

    await sendMessage(message);
    return message;
  }

  /// 发送语音消息
  /// 创建并发送语音类型的消息,可选上传语音文件
  /// [conversationId] - 会话ID
  /// [localPath] - 语音文件本地路径
  /// [duration] - 语音时长（秒）
  /// [mediaUrl] - 可选的媒体URL,如已上传则直接使用
  /// 返回创建的消息对象
  @override
  Future<Message> sendVoiceMessage(String conversationId, String localPath, int duration, {String? mediaUrl}) async {
    final message = await _createMessage(conversationId, '', 'voice');

    if (mediaUrl != null) {
      message.mediaUrl = mediaUrl;
      message.duration = duration;
    } else {
      final voiceFile = File(localPath);
      // 上传语音
      final uploadResult = await _fileUploadService.uploadVoice(voiceFile, duration);
      if (uploadResult != null) {
        message.mediaUrl = uploadResult.remoteUrl;
        if (uploadResult.duration != null) {
          message.duration = uploadResult.duration;
        } else {
          message.duration = duration;
        }
      } else {
        message.duration = duration;
      }
    }
    message.localPath = localPath;

    await sendMessage(message);
    return message;
  }

  /// 发送文件消息
  /// 创建并发送文件类型的消息,可选上传文件
  /// [conversationId] - 会话ID
  /// [localPath] - 文件本地路径
  /// [fileName] - 文件名
  /// [fileSize] - 文件大小
  /// [mediaUrl] - 可选的媒体URL,如已上传则直接使用
  /// 返回创建的消息对象
  @override
  Future<Message> sendFileMessage(String conversationId, String localPath, String fileName, double fileSize, {String? mediaUrl}) async {
    final message = await _createMessage(conversationId, '', 'file');

    if (mediaUrl != null) {
      message.mediaUrl = mediaUrl;
    } else {
      final file = File(localPath);
      // 上传文件
      final uploadResult = await _fileUploadService.uploadFile(file);
      if (uploadResult != null) {
        message.mediaUrl = uploadResult.remoteUrl;
      }
    }
    message.localPath = localPath;
    message.fileName = fileName;
    message.fileSize = fileSize;

    await sendMessage(message);
    return message;
  }

  /// 发送视频消息
  /// 创建并发送视频类型的消息,可选上传视频文件
  /// [conversationId] - 会话ID
  /// [localPath] - 视频文件本地路径
  /// [duration] - 视频时长（秒）
  /// [thumbnailUrl] - 可选的缩略图URL
  /// [mediaUrl] - 可选的媒体URL,如已上传则直接使用
  /// [isServerProcessed] - 是否由服务器处理缩略图
  /// 返回创建的消息对象
  @override
  Future<Message> sendVideoMessage(String conversationId, String localPath, int duration, {String? thumbnailUrl, String? mediaUrl, bool isServerProcessed = false}) async {
    try {
      final message = Message();
      message.conversationId = conversationId;
      // 获取当前用户ID
      final currentUserId = await _getCurrentUserId();
      message.senderId = currentUserId;
      message.senderName = '我';
      message.type = 'video';
      message.localPath = localPath;
      message.mediaUrl = mediaUrl;
      message.thumbnailUrl = thumbnailUrl;
      message.duration = duration;
      message.isRead = true; // 自己发送的消息默认已读

      // 如果缩略图由服务器处理,且尚未生成,设置状态为处理中
      if (isServerProcessed && thumbnailUrl == null) {
        message.status = 'processing'; // 服务器处理中
      } else {
        message.status = 'sent'; // 正常发送状态
      }

      await _isar.writeTxn(() async {
        message.id = await _messages.put(message);
        await _messages.put(message);

        // 更新会话最后消息预览
        final conversation = await getConversationById(conversationId);
        if (conversation != null) {
          conversation.lastMessageTime = message.createdAt;
          conversation.lastMessagePreview = '[视频]';
          await _conversations.put(conversation);
        }
      });

      // 如果是服务器处理模式且没有缩略图,模拟服务器异步处理
      if (isServerProcessed && thumbnailUrl == null) {
        _simulateServerProcessing(message);
      }

      await sendMessage(message);
      return message;
    } catch (error) {
      _logger.e('发送视频消息失败', error: error, stackTrace: StackTrace.current);
      rethrow;
    }
  }

  /// 模拟服务器异步处理缩略图
  /// 用于模拟模式下服务器生成视频缩略图的过程
  /// [message] - 视频消息对象
  void _simulateServerProcessing(Message message) {
    // 模拟服务器处理时间 (1-3秒)
    final processingTime = 1000 + (DateTime.now().millisecondsSinceEpoch % 2000);

    Future.delayed(Duration(milliseconds: processingTime), () async {
      try {
        // 90%的概率成功
        final isSuccess = (DateTime.now().millisecondsSinceEpoch % 10) < 9;

        await _isar.writeTxn(() async {
          if (isSuccess) {
            // 模拟服务器生成缩略图

            // 获取视频文件以模拟生成缩略图
            if (message.localPath != null) {
              final videoFile = File(message.localPath!);
              if (await videoFile.exists()) {
                // 使用生成缩略图的方法
                final thumbnailFile = await _fileUploadService.generateVideoThumbnail(message.localPath!);
                if (thumbnailFile != null) {
                  message.thumbnailUrl = 'file://${thumbnailFile.path}';
                }
              }
            }

            message.status = 'sent';
          } else {
            // 模拟服务器处理失败
            message.status = 'thumbnail_failed';
          }

          await _messages.put(message);

          // 通知消息更新
          _newMessagesController.add(message);
        });
      } catch (error) {
        _logger.e('模拟服务器处理缩略图失败', error: error, stackTrace: StackTrace.current);
      }
    });
  }

  /// 发送位置消息
  /// 创建并发送位置类型的消息
  /// [conversationId] - 会话ID
  /// [latitude] - 纬度
  /// [longitude] - 经度
  /// [locationAddress] - 位置地址描述
  /// 返回创建的消息对象
  Future<Message> sendLocationMessage(
    String conversationId,
    double latitude,
    double longitude,
    String locationAddress,
  ) async {
    try {
      final message = Message();
      message.conversationId = conversationId;
      // 获取当前用户ID
      final currentUserId = await _getCurrentUserId();
      message.senderId = currentUserId;
      message.senderName = '我';
      message.type = 'location';
      message.latitude = latitude;
      message.longitude = longitude;
      message.locationAddress = locationAddress;
      message.isRead = true; // 自己发送的消息默认已读
      message.status = 'sent';

      await _isar.writeTxn(() async {
        message.id = await _messages.put(message);
        await _messages.put(message);

        // 更新会话最后消息预览
        final conversation = await getConversationById(conversationId);
        if (conversation != null) {
          conversation.lastMessageTime = message.createdAt;
          conversation.lastMessagePreview = '[位置] $locationAddress';
          await _conversations.put(conversation);
        }
      });

      await sendMessage(message);
      return message;
    } catch (error) {
      _logger.e('发送位置消息失败', error: error, stackTrace: StackTrace.current);
      rethrow;
    }
  }

  /// 删除消息
  /// 删除指定的消息及其相关的媒体文件
  /// [messageId] - 消息ID
  @override
  Future<void> deleteMessage(String messageId) async {
    try {
      final id = int.tryParse(messageId) ?? 0;

      // 先获取消息以获取媒体文件路径信息
      final message = await _messages.get(id);
      if (message == null) {
        throw Exception('找不到要删除的消息');
      }

      // 用于存储要删除的文件路径
      final filesToDelete = _collectMediaFilePaths(message);

      // 在数据库事务中删除消息
      await _isar.writeTxn(() async {
        final success = await _messages.delete(id);
        if (!success) {
          throw Exception('删除消息失败');
        }
      });

      // 删除关联的媒体文件
      await _deleteMediaFiles(filesToDelete);
    } catch (error) {
      _logger.e('删除消息失败', error: error, stackTrace: StackTrace.current);
      rethrow;
    }
  }

  /// 删除会话
  /// 删除指定的会话及其所有消息和相关媒体文件
  /// [conversationId] - 会话ID
  @override
  Future<void> deleteConversation(String conversationId) async {
    try {
      final id = int.tryParse(conversationId) ?? 0;

      // 先获取所有相关消息,以便收集需要删除的媒体文件
      final messages = await _messages.filter().conversationIdEqualTo(conversationId).findAll();

      // 收集所有媒体文件路径
      final filesToDelete = <String>[];
      for (final message in messages) {
        filesToDelete.addAll(_collectMediaFilePaths(message));
      }

      await _isar.writeTxn(() async {
        // 删除会话中的所有消息
        await _messages.filter().conversationIdEqualTo(conversationId).deleteAll();

        // 删除会话本身
        final success = await _conversations.delete(id);
        if (!success) {
          throw Exception('找不到要删除的会话');
        }
      });

      // 删除关联的媒体文件
      await _deleteMediaFiles(filesToDelete);
    } catch (error) {
      _logger.e('删除会话失败', error: error, stackTrace: StackTrace.current);
      rethrow;
    }
  }

  /// 清空会话消息
  /// 删除指定会话中的所有消息和相关媒体文件,但保留会话本身
  /// [conversationId] - 会话ID
  @override
  Future<void> clearConversationMessages(String conversationId) async {
    try {
      // 先获取所有相关消息,以便收集需要删除的媒体文件
      final messages = await _messages.filter().conversationIdEqualTo(conversationId).findAll();

      // 收集所有媒体文件路径
      final filesToDelete = <String>[];
      for (final message in messages) {
        filesToDelete.addAll(_collectMediaFilePaths(message));
      }

      // 在数据库事务中删除所有消息
      await _isar.writeTxn(() async {
        // 删除会话中的所有消息
        await _messages.filter().conversationIdEqualTo(conversationId).deleteAll();

        // 更新会话信息
        final conversation = await getConversationById(conversationId);
        if (conversation != null) {
          conversation.lastMessageTime = null;
          conversation.lastMessagePreview = null;
          conversation.unreadCount = 0;
          await _conversations.put(conversation);
        }
      });

      // 删除关联的媒体文件
      await _deleteMediaFiles(filesToDelete);
    } catch (error) {
      _logger.e('清空会话消息失败', error: error, stackTrace: StackTrace.current);
      rethrow;
    }
  }

  /// 收集消息中的媒体文件路径
  /// 分析消息对象,收集需要删除的媒体文件路径
  /// [message] - 消息对象
  /// 返回文件路径列表
  List<String> _collectMediaFilePaths(Message message) {
    final filesToDelete = <String>[];

    if (message.type == 'image' || message.type == 'video' || message.type == 'voice' || message.type == 'file') {
      // 检查本地文件路径
      if (message.localPath != null && message.localPath!.isNotEmpty) {
        filesToDelete.add(message.localPath!);
      }

      // 检查媒体URL（如果是本地file://）
      if (message.mediaUrl != null && message.mediaUrl!.startsWith('file://')) {
        filesToDelete.add(message.mediaUrl!.substring(7)); // 移除file://前缀
      }

      // 检查缩略图URL（如果是本地file://）
      if (message.thumbnailUrl != null && message.thumbnailUrl!.startsWith('file://')) {
        filesToDelete.add(message.thumbnailUrl!.substring(7)); // 移除file://前缀
      }
    }

    return filesToDelete;
  }

  /// 删除媒体文件
  /// 删除指定路径列表中的所有文件
  /// [filePaths] - 文件路径列表
  Future<void> _deleteMediaFiles(List<String> filePaths) async {
    for (final filePath in filePaths) {
      try {
        final file = File(filePath);
        if (await file.exists()) {
          await file.delete();
          _logger.d('已删除媒体文件', extra: {'path': filePath});
        }
      } catch (fileError) {
        // 文件删除失败,但不要中断整个删除过程
        _logger.w('删除媒体文件失败', extra: {'path': filePath, 'error': fileError.toString()});
      }
    }
  }

  /// 按日期范围获取消息
  /// 获取指定会话中特定日期范围内的消息
  /// [conversationId] - 会话ID
  /// [startDate] - 开始日期
  /// [endDate] - 结束日期
  /// [limit] - 消息数量限制
  /// 返回符合条件的消息列表
  @override
  Future<List<Message>> getMessagesByDateRange(
    String conversationId,
    DateTime startDate,
    DateTime endDate, {
    int limit = 50,
  }) async {
    try {
      int id = int.tryParse(conversationId) ?? 0;

      // 确保转换为有效的DateTime对象,避免日期比较问题
      final safeStartDate = DateTime.utc(
        startDate.year,
        startDate.month,
        startDate.day,
      );
      final safeEndDate = DateTime.utc(
        endDate.year,
        endDate.month,
        endDate.day,
        23,
        59,
        59,
      );

      _logger.d('按日期范围查询消息', extra: {'会话ID': id, '开始日期': safeStartDate.toString(), '结束日期': safeEndDate.toString(), '限制': limit});

      // 查询指定日期范围内的消息
      final messages = await _messages
          .filter()
          .conversationIdEqualTo(id.toString())
          .createdAtBetween(safeStartDate, safeEndDate)
          .sortByCreatedAt() // 按时间正序排序
          .limit(limit)
          .findAll();

      _logger.d('按日期范围查询结果', extra: {'找到消息数': messages.length});
      return messages;
    } catch (error) {
      _logger.e('根据日期范围获取消息失败', error: error, stackTrace: StackTrace.current);
      return [];
    }
  }

  /// 从指定日期获取会话消息
  /// 获取从指定日期开始的会话消息
  /// [conversationId] - 会话ID
  /// [startDate] - 开始日期
  /// [limit] - 消息数量限制
  /// 返回符合条件的消息列表
  @override
  Future<List<Message>> getConversationMessagesFromDate(
    String conversationId,
    DateTime startDate, {
    int limit = 30,
  }) async {
    try {
      int id = int.tryParse(conversationId) ?? 0;

      // 确保使用日期的开始时间
      final dayStart = DateTime(startDate.year, startDate.month, startDate.day, 0, 0, 0);

      // 查询从指定日期开始的消息
      final messages = await _messages
          .filter()
          .conversationIdEqualTo(id.toString())
          .createdAtGreaterThan(dayStart.subtract(const Duration(seconds: 1))) // 大于等于指定日期
          .sortByCreatedAt() // 按时间正序排序,确保最早的消息在前
          .limit(limit)
          .findAll();

      _logger.d('从日期获取消息结果', extra: {'找到消息数': messages.length});
      return messages;
    } catch (error) {
      _logger.e('从指定日期获取消息失败', error: error, stackTrace: StackTrace.current);
      return [];
    }
  }

  /// 发送消息
  Future<String> sendMessage(Message message) async {
    try {
      // 保存消息到数据库
      await _isar.writeTxn(() async {
        message.id = await _isar.messages.put(message);
      });

      // 创建Map用于发送
      final protoMsg = message_proto.NewMessageProto()
        ..id = message.messageId
        ..senderId = message.senderId
        ..conversationId = message.conversationId
        ..content = message.text ?? ''
        ..timestamp = $fixnum.Int64(message.createdAt.millisecondsSinceEpoch)
        ..type = message.type;

      // 通过通信服务发送消息
      _communicationService.emitProto('message:new', protoMsg);

      return message.messageId;
    } catch (error) {
      _logger.e('发送消息失败', extra: {'error': error.toString()});
      throw MessageException('发送消息失败: ${error.toString()}');
    }
  }

  /// 发送输入状态
  /// 通知其他用户当前用户正在输入或停止输入
  /// [conversationId] - 会话ID
  /// [isTyping] - 是否正在输入
  @override
  Future<void> sendTypingStatus(String conversationId, bool isTyping) async {
    if (_communicationService.isInitialized) {
      final typingProto = message_proto.TypingProto()
        ..conversationId = conversationId
        ..isTyping = isTyping;
      _communicationService.emitProto(isTyping ? 'typing' : 'typing:stop', typingProto);
      return;
    }

    _logger.w('通信服务未初始化,无法发送输入状态');
  }

  /// 发送消息已读状态
  /// 通知发送者消息已被读取
  /// [messageId] - 消息ID
  /// [conversationId] - 会话ID
  void sendMessageRead(String messageId, String conversationId) {
    if (_communicationService.isInitialized) {
      final readProto = message_proto.MessageReadProto()
        ..messageId = messageId
        ..conversationId = conversationId;
      _communicationService.emitProto('message:read', readProto);
      return;
    }

    _logger.w('通信服务未初始化,无法发送已读状态');
  }

  /// 获取输入状态流
  /// 返回用户输入状态变化的流
  @override
  Stream<Map<String, dynamic>> getTypingStatusStream() {
    return _typingStatusController.stream;
  }

  /// 获取在线状态流
  /// 返回用户在线状态变化的流
  @override
  Stream<Map<String, dynamic>> getOnlineStatusStream() {
    return _onlineStatusController.stream;
  }

  /// 获取消息状态流
  /// 返回消息状态变化的流
  @override
  Stream<Map<String, dynamic>> getMessageStatusStream() {
    return _messageStatusController.stream;
  }

  /// 获取同步状态流
  /// 返回数据同步状态变化的流
  @override
  Stream<SyncStatus> getSyncStatusStream() {
    return _syncStatusController.stream;
  }

  /// 创建消息通用方法
  /// 创建基本的消息对象,设置共同属性
  /// [conversationId] - 会话ID
  /// [text] - 消息文本
  /// [type] - 消息类型
  /// 返回创建的消息对象
  Future<Message> _createMessage(String conversationId, String text, String type) async {
    try {
      final message = Message();
      message.conversationId = conversationId;
      // 获取当前用户ID
      final currentUserId = await _getCurrentUserId();
      message.senderId = currentUserId;
      message.senderName = '我';
      message.type = type;
      message.text = text.isEmpty ? null : text;
      message.isRead = true; // 自己发送的消息默认已读
      message.status = 'sending';
      message.createdAt = DateTime.now();

      return message;
    } catch (error) {
      _logger.e('创建消息失败', error: error, stackTrace: StackTrace.current);
      rethrow;
    }
  }

  /// 释放资源
  /// 取消所有订阅并关闭流控制器
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();

    _newMessagesController.close();
    _typingStatusController.close();
    _onlineStatusController.close();
    _messageStatusController.close();
    _syncStatusController.close();
    
    // 关闭用户信息仓库
    _profileRepository.close().catchError((error) {
      _logger.e('关闭用户信息仓库失败', error: error);
    });
  }

  /// 创建或获取与用户的对话
  /// 如果已存在与该用户的一对一会话,则返回该会话ID
  /// 否则创建新会话并返回ID
  /// [userId] - 目标用户ID
  @override
  Future<String?> createOrGetConversation(String userId) async {
    try {
      _logger.i('获取或创建与用户的会话', extra: {'userId': userId});

      // 获取当前用户ID
      final currentUserId = DatabaseInitializer.currentUserId;
      if (currentUserId == null) {
        _logger.e('当前用户未登录,无法创建会话');
        return null;
      }

      // 检查是否已有与该用户的私聊会话
      final existingConversation = await _conversations.filter().typeEqualTo(db.ConversationType.private).and().contactUserIdEqualTo(userId).findFirst();

      if (existingConversation != null) {
        _logger.i('找到已存在的会话', extra: {'conversationId': existingConversation.conversationId});
        return existingConversation.conversationId;
      }

      // 获取目标用户信息
      final contactUser = await _users.filter().userIdEqualTo(userId).findFirst();
      if (contactUser == null) {
        _logger.e('未找到目标用户信息', extra: {'userId': userId});
        return null;
      }

      // 创建新会话
      final conversation = db.Conversation()
        ..type = db.ConversationType.private
        ..name = contactUser.name
        ..contactUserId = userId
        ..avatar = contactUser.avatar
        ..createdAt = DateTime.now();

      // 保存会话
      await _isar.writeTxn(() async {
        await _conversations.put(conversation);
        // 建立会话与用户的关联
        await conversation.participants.save();
      });

      _logger.i('创建了新会话', extra: {'conversationId': conversation.conversationId});
      return conversation.conversationId;
    } catch (error) {
      _logger.e('创建或获取会话失败', error: error, stackTrace: StackTrace.current);
      return null;
    }
  }

  void _handleSyncedConversations(List<conversation_proto.ConversationProto> conversations) {
    try {
      final List<db.Conversation> dbConversations = conversations.map((conv) => _convertProtoToDbConversation(conv)).toList();

      // 更新本地数据库
      _updateLocalConversations(dbConversations);

      // 通知UI层更新
      if (dbConversations.isNotEmpty) {
        _conversationStateController.add(dbConversations);
      }
    } catch (e, stackTrace) {
      _logger.e('处理同步会话数据时出错: $e\n$stackTrace');
    }
  }

  db.Conversation _convertProtoToDbConversation(conversation_proto.ConversationProto conv) {
    final conversation = db.Conversation()
      ..conversationId = conv.conversationId
      ..type = conv.type == conversation_proto.ConversationType.private ? db.ConversationType.private : db.ConversationType.group
      ..name = conv.name
      ..avatar = conv.avatar
      ..lastMessagePreview = conv.lastMessagePreview
      ..lastMessageTime = DateTime.fromMillisecondsSinceEpoch(conv.lastMessageTime.toInt())
      ..createdAt = DateTime.fromMillisecondsSinceEpoch(conv.createdAt.toInt())
      ..unreadCount = conv.unreadCount
      ..contactUserId = conv.contactUserId
      ..lastMessageId = conv.lastMessageId;

    return conversation;
  }

  /// 从服务器获取消息
  /// 获取指定会话的消息列表,支持分页
  /// [conversationId] - 会话ID
  /// [limit] - 获取消息的最大数量
  /// [before] - 可选的时间点,获取此时间之前的消息
  /// 返回消息列表
  @override
  Future<List<Message>> fetchMessagesFromServer(String conversationId, {int limit = 20, DateTime? before}) async {
    try {
      _logger.i('从服务器获取消息', extra: {'conversationId': conversationId, 'limit': limit});

      // 创建请求参数
      final request = message_proto.MessageProto()
        ..conversationId = conversationId
        ..text = 'fetch'; // 用作临时标记

      if (before != null) {
        request.createdAt = $fixnum.Int64(before.millisecondsSinceEpoch);
      }

      // 发送请求到服务器
      await _communicationService.emitProto('messages:fetch', request);

      // 等待响应
      final response = await _communicationService.onProto<message_proto.MessageCollection>('messages:fetch:result').first;

      // 转换服务器响应为消息列表
      final messages = response.messages.map((msg) {
        final message = Message()
          ..messageId = msg.messageId
          ..conversationId = msg.conversationId
          ..senderId = msg.senderId
          ..createdAt = DateTime.fromMillisecondsSinceEpoch(msg.createdAt.toInt())
          ..text = msg.text
          ..type = msg.type.toString()
          ..isRead = false
          ..status = 'received';

        // 保存消息到本地数据库
        _isar.writeTxn(() async {
          message.id = await _messages.put(message);
        });

        return message;
      }).toList();

      _logger.i('从服务器获取消息成功', extra: {'count': messages.length});
      return messages;
    } catch (error) {
      _logger.e('从服务器获取消息失败', error: error, stackTrace: StackTrace.current);
      return [];
    }
  }
}
