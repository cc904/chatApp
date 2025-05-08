import 'dart:async';
import 'dart:io';
import 'package:cc/core/database/database_initializer.dart';
import 'package:cc/core/database/models/conversation.dart';
import 'package:cc/core/database/models/message.dart';
import 'package:cc/core/database/models/user.dart';
import 'package:cc/core/database/mock_data_manager.dart';
import 'package:cc/core/network/index.dart';
import 'package:cc/core/services/file_upload_service.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/services/my_user_service.dart';
import 'package:cc/features/chat/domain/repositories/chat_repository.dart';
import 'package:cc/core/constants/app_config.dart';
import 'package:isar/isar.dart';

/// ChatRepository的实现类
class ChatRepositoryImpl implements ChatRepository {
  final LogService _logger = LogService('chat_repository_impl.dart');
  final SocketService _socketService = SocketService.getInstance();
  final FileUploadService _fileUploadService = FileUploadService(); // 实例化文件上传服务

  // 消息流控制器，用于通知UI消息更新
  final StreamController<Message> _messageStreamController = StreamController<Message>.broadcast();

  // 实时通信相关的流控制器
  final StreamController<Map<String, dynamic>> _typingStatusController = StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _onlineStatusController = StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _messageStatusController = StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<SyncStatus> _syncStatusController = StreamController<SyncStatus>.broadcast();

  // Socket事件订阅
  final List<StreamSubscription> _socketSubscriptions = [];

  // 获取消息流
  Stream<Message> get messageStream => _messageStreamController.stream;

  // 获取当前数据库实例
  Isar get _isar => DatabaseInitializer.isar;

  // 获取用户集合
  IsarCollection<User> get _users => _isar.collection<User>();

  // 获取会话集合
  IsarCollection<Conversation> get _conversations => _isar.collection<Conversation>();

  // 获取消息集合
  IsarCollection<Message> get _messages => _isar.collection<Message>();

  // Socket.IO服务器URL
  static const String socketServerUrl = 'http://localhost:3000';

  // Socket连接状态
  bool _isSocketInitialized = false;

  // 构造函数
  ChatRepositoryImpl() {
    _syncStatusController.add(SyncStatus.idle);
  }

  @override
  Future<List<User>> getAllContacts() async {
    // 在模拟模式下直接使用模拟数据
    if (AppConfig().isSimulationMode) {
      return await MockDataManager.getAllMockContacts();
    }

    try {
      return await _users.where().sortByName().findAll();
    } catch (e) {
      _logger.e('获取联系人失败', error: e);
      // 直接返回空列表，不再使用模拟数据作为备选
      return [];
    }
  }

  @override
  Future<List<User>> searchContacts(String keyword) async {
    // 在模拟模式下直接使用模拟数据
    if (AppConfig().isSimulationMode) {
      return await MockDataManager.searchMockContacts(keyword);
    }

    try {
      if (keyword.isEmpty) {
        return getAllContacts();
      }

      return await _users
          .filter()
          .group((q) => q
              .nameContains(keyword, caseSensitive: false)
              .or()
              .optional(keyword.isNotEmpty && keyword.length > 1, (q) => q.pinyinContains(keyword, caseSensitive: false))
              .or()
              .phoneContains(keyword)
              .or()
              .emailContains(keyword, caseSensitive: false))
          .sortByName()
          .findAll();
    } catch (e) {
      _logger.e('搜索联系人失败', error: e);
      // 直接返回空列表，不再使用模拟数据作为备选
      return [];
    }
  }

  @override
  Future<User?> getContactById(String userId) async {
    // 在模拟模式下直接使用模拟数据
    if (AppConfig().isSimulationMode) {
      return await MockDataManager.getMockContactById(userId);
    }

    try {
      int id = int.tryParse(userId) ?? 0;
      return await _users.get(id);
    } catch (e) {
      _logger.e('获取联系人信息失败', error: e);
      // 直接返回null，不再使用模拟数据作为备选
      return null;
    }
  }

  @override
  Future<void> addContact(User user) async {
    try {
      await _isar.writeTxn(() async {
        user.id = await _users.put(user);
        // 同步ID字段
        DatabaseInitializer.syncIds(user);
        await _users.put(user);
      });
    } catch (e) {
      _logger.e('添加联系人失败', error: e);
      rethrow;
    }
  }

  // 获取当前用户ID
  Future<String> _getCurrentUserId() async {
    final currentUser = await MyUserService.getCurrentUser();
    if (currentUser == null) {
      throw Exception('找不到当前用户信息，请确保已登录');
    }
    return currentUser.userId;
  }

  @override
  Future<List<Conversation>> getAllConversations() async {
    try {
      // 使用生成的访问器
      final conversations = await _conversations.where().findAll();
      // 手动按lastMessageTime降序排序，将null值排在最后
      conversations.sort((a, b) {
        if (a.lastMessageTime == null) return 1;
        if (b.lastMessageTime == null) return -1;
        return b.lastMessageTime!.compareTo(a.lastMessageTime!);
      });
      return conversations;
    } catch (e, stack) {
      _logger.e('获取会话列表失败', error: e, stackTrace: stack);
      _logger.d('获取会话列表失败');
      // 尝试检查是否为数据库初始化问题
      try {
        if (_isar.isOpen) {
          _logger.d('Isar 数据库已打开');
          _logger.d('尝试获取其他集合信息');
          try {
            final usersCount = await _users.count();
            _logger.d('用户集合数量', extra: {'count': usersCount});
          } catch (e) {
            _logger.e('无法获取用户集合', error: e);
          }
        } else {
          _logger.d('Isar 数据库未打开');
        }
      } catch (checkError) {
        _logger.e('检查数据库状态失败', error: checkError);
      }
      return _getMockConversations();
    }
  }

  // 返回模拟会话数据
  List<Conversation> _getMockConversations() {
    return List.generate(3, (index) {
      final isGroup = index == 2;
      final conversation = Conversation();
      conversation.type = isGroup ? ConversationType.group : ConversationType.private;
      conversation.name = isGroup ? '群聊$index' : '联系人$index';
      conversation.lastMessagePreview = '最新消息$index';
      conversation.lastMessageTime = DateTime.now().subtract(Duration(hours: index));
      conversation.unreadCount = index;
      conversation.contactUserId = isGroup ? null : (index + 1).toString(); // 模拟联系人ID
      return conversation;
    });
  }

  @override
  Future<Conversation?> getConversationById(String conversationId) async {
    try {
      int id = int.tryParse(conversationId) ?? 0;
      // 使用生成的访问器
      return await _conversations.get(id);
    } catch (e) {
      _logger.e('获取会话信息失败', error: e);
      return null;
    }
  }

  @override
  Future<Conversation> getOrCreatePrivateConversation(String contactUserId) async {
    try {
      // 先查找已有的私聊会话
      final existing = await _conversations.filter().typeEqualTo(ConversationType.private).and().contactUserIdEqualTo(contactUserId).findFirst();

      if (existing != null) {
        return existing;
      }

      // 创建新会话
      final contact = await getContactById(contactUserId);
      if (contact == null) {
        throw Exception('联系人不存在');
      }

      final conversation = Conversation();
      conversation.type = ConversationType.private;
      conversation.name = contact.name;
      conversation.contactUserId = contactUserId;

      await _isar.writeTxn(() async {
        conversation.id = await _conversations.put(conversation);
        // 同步ID字段
        DatabaseInitializer.syncIds(conversation);
        await _conversations.put(conversation);

        // 添加会话参与者
        conversation.participants.add(contact);
        await conversation.participants.save();
      });

      return conversation;
    } catch (e) {
      _logger.e('获取或创建私聊会话失败', error: e);
      rethrow;
    }
  }

  @override
  Future<Conversation> createGroupConversation(String name, List<String> memberIds, {String? avatar}) async {
    try {
      // 创建新的群聊会话
      final conversation = Conversation()
        ..type = ConversationType.group
        ..name = name
        ..avatar = avatar
        ..createdAt = DateTime.now();

      await _isar.writeTxn(() async {
        // 保存会话
        conversation.id = await _conversations.put(conversation);
        // 同步ID字段
        DatabaseInitializer.syncIds(conversation);
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
    } catch (e) {
      _logger.e('创建群聊失败', error: e);
      rethrow;
    }
  }

  @override
  Future<List<Message>> getConversationMessages(String conversationId, {int limit = 20, DateTime? before}) async {
    try {
      final query = _messages.filter().conversationIdEqualTo(conversationId).optional(before != null, (q) => q.createdAtLessThan(before!)).sortByCreatedAtDesc();

      final messages = await query.limit(limit).findAll();
      return messages;
    } catch (e) {
      _logger.e('获取会话消息失败', error: e);
      return [];
    }
  }

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
    } catch (e) {
      _logger.e('搜索消息失败', error: e);
      return [];
    }
  }

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
    } catch (e) {
      _logger.e('标记消息为已读失败', error: e);
    }
  }

  @override
  Future<void> markConversationAsRead(String conversationId) async {
    // 调用已实现的markMessagesAsRead方法
    await markMessagesAsRead(conversationId);
  }

  @override
  Stream<void> watchConversations() {
    return _conversations.watchLazy();
  }

  @override
  Stream<void> watchConversationMessages(String conversationId) {
    return _messages.filter().conversationIdEqualTo(conversationId).watchLazy();
  }

  @override
  Stream<void> watchContacts() {
    return _users.watchLazy();
  }

  /// 创建文本消息
  @override
  Future<Message> sendTextMessage(String conversationId, String text) async {
    final message = await _createMessage(conversationId, text, 'text');
    return await _sendMessage(message);
  }

  /// 创建图片消息
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

    return await _sendMessage(message);
  }

  /// 创建语音消息
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

    return await _sendMessage(message);
  }

  /// 创建文件消息
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

    return await _sendMessage(message);
  }

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

      // 如果缩略图由服务器处理，且尚未生成，设置状态为处理中
      if (isServerProcessed && thumbnailUrl == null) {
        message.status = 'processing'; // 服务器处理中
      } else {
        message.status = 'sent'; // 正常发送状态
      }

      await _isar.writeTxn(() async {
        message.id = await _messages.put(message);
        // 同步ID字段
        DatabaseInitializer.syncIds(message);
        await _messages.put(message);

        // 更新会话最后消息预览
        final conversation = await getConversationById(conversationId);
        if (conversation != null) {
          conversation.lastMessageTime = message.createdAt;
          conversation.lastMessagePreview = '[视频]';
          // 同步会话ID字段
          DatabaseInitializer.syncIds(conversation);
          await _conversations.put(conversation);
        }
      });

      // 如果是服务器处理模式且没有缩略图，模拟服务器异步处理
      if (isServerProcessed && thumbnailUrl == null) {
        _simulateServerProcessing(message);
      }

      return message;
    } catch (e) {
      _logger.e('发送视频消息失败', error: e);
      rethrow;
    }
  }

  /// 模拟服务器异步处理缩略图
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
          _messageStreamController.add(message);
        });
      } catch (e) {
        _logger.e('模拟服务器处理缩略图失败', error: e);
      }
    });
  }

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
        // 同步ID字段
        DatabaseInitializer.syncIds(message);
        await _messages.put(message);

        // 更新会话最后消息预览
        final conversation = await getConversationById(conversationId);
        if (conversation != null) {
          conversation.lastMessageTime = message.createdAt;
          conversation.lastMessagePreview = '[位置] $locationAddress';
          // 同步会话ID字段
          DatabaseInitializer.syncIds(conversation);
          await _conversations.put(conversation);
        }
      });

      return message;
    } catch (e) {
      _logger.e('发送位置消息失败', error: e);
      rethrow;
    }
  }

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
    } catch (e) {
      _logger.e('删除消息失败', error: e);
      rethrow;
    }
  }

  @override
  Future<void> deleteConversation(String conversationId) async {
    try {
      final id = int.tryParse(conversationId) ?? 0;

      // 先获取所有相关消息，以便收集需要删除的媒体文件
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
    } catch (e) {
      _logger.e('删除会话失败', error: e);
      rethrow;
    }
  }

  @override
  Future<void> clearConversationMessages(String conversationId) async {
    try {
      // 先获取所有相关消息，以便收集需要删除的媒体文件
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
    } catch (e) {
      _logger.e('清空会话消息失败', error: e);
      rethrow;
    }
  }

  /// 辅助方法：收集消息中的媒体文件路径
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

  /// 辅助方法：删除媒体文件
  Future<void> _deleteMediaFiles(List<String> filePaths) async {
    for (final filePath in filePaths) {
      try {
        final file = File(filePath);
        if (await file.exists()) {
          await file.delete();
          _logger.d('已删除媒体文件', extra: {'path': filePath});
        }
      } catch (fileError) {
        // 文件删除失败，但不要中断整个删除过程
        _logger.w('删除媒体文件失败', extra: {'path': filePath, 'error': fileError.toString()});
      }
    }
  }

  @override
  Future<List<Message>> getMessagesByDateRange(
    String conversationId,
    DateTime startDate,
    DateTime endDate, {
    int limit = 50,
  }) async {
    try {
      int id = int.tryParse(conversationId) ?? 0;

      // 确保转换为有效的DateTime对象，避免日期比较问题
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
    } catch (e) {
      _logger.e('根据日期范围获取消息失败', error: e);
      return [];
    }
  }

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
          .sortByCreatedAt() // 按时间正序排序，确保最早的消息在前
          .limit(limit)
          .findAll();

      _logger.d('从日期获取消息结果', extra: {'找到消息数': messages.length});
      return messages;
    } catch (e) {
      _logger.e('从指定日期获取消息失败', error: e);
      return [];
    }
  }

  @override
  Future<bool> initRealTimeConnection(
    String userId,
    String token,
    String serverUrl,
    bool isSimulationMode,
  ) async {
    try {
      _logger.i('初始化实时通信连接', extra: {'userId': userId, 'isSimulationMode': isSimulationMode});

      if (_isSocketInitialized) {
        _logger.w('Socket连接已初始化，断开旧连接');
        await closeRealTimeConnection();
      }

      // 初始化Socket连接
      final success = await _socketService.init(
        serverUrl: serverUrl,
        authToken: token,
      );

      if (success) {
        _isSocketInitialized = true;
        _setupSocketEventListeners();

        // 发送用户上线状态
        _socketService.sendUserOnline();

        _logger.i('实时通信连接初始化成功');
        return true;
      } else {
        _logger.e('实时通信连接初始化失败');
        return false;
      }
    } catch (e) {
      _logger.e('初始化实时通信连接失败', error: e);
      return false;
    }
  }

  @override
  Future<void> closeRealTimeConnection() async {
    _logger.i('关闭实时通信连接');

    // 取消所有事件订阅
    for (final subscription in _socketSubscriptions) {
      await subscription.cancel();
    }
    _socketSubscriptions.clear();

    // 发送用户下线状态
    if (_isSocketInitialized) {
      _socketService.sendUserOffline();
    }

    // 断开Socket连接
    _socketService.disconnect();
    _isSocketInitialized = false;
  }

  @override
  Future<bool> reconnectRealTime() async {
    _logger.i('尝试重新连接实时通信');

    // 获取当前用户信息和令牌
    try {
      final currentUser = await MyUserService.getCurrentUser();
      if (currentUser == null) {
        _logger.e('无法重连：未找到当前用户信息');
        return false;
      }

      // 获取令牌
      final token = currentUser.token;
      // 初始化新连接
      return initRealTimeConnection(currentUser.userId, token, socketServerUrl, AppConfig().isSimulationMode);
    } catch (e) {
      _logger.e('重连失败', error: e);
      return false;
    }
  }

  @override
  Future<bool> syncContacts() async {
    try {
      _logger.i('开始同步联系人列表');

      // 获取当前用户信息
      final currentUser = await MyUserService.getCurrentUser();
      if (currentUser == null) {
        _logger.e('同步失败：未找到当前用户信息');
        return false;
      }

      // 向服务器发送同步请求
      if (_socketService.isConnected) {
        _socketService.emit('sync_contacts', {
          'userId': currentUser.userId,
          'token': currentUser.token,
        });
        _logger.i('已发送联系人同步请求');
      }

      return true;
    } catch (e) {
      _logger.e('同步联系人失败', error: e);
      return false;
    }
  }

  @override
  Future<String?> createOrGetConversation(String userId) async {
    try {
      _logger.i('创建或获取与用户的对话', extra: {'userId': userId});

      // 获取当前用户ID

      // 检查是否已存在会话
      final existingConversation = await _isar.conversations.filter().contactUserIdEqualTo(userId).findFirst();

      if (existingConversation != null) {
        _logger.i('找到已存在的会话', extra: {'conversationId': existingConversation.id.toString()});
        return existingConversation.id.toString();
      }

      // 获取联系人信息
      final user = await _isar.users.filter().userIdEqualTo(userId).findFirst();

      if (user == null) {
        _logger.e('创建会话失败：未找到用户信息');
        return null;
      }

      // 创建新会话
      final conversation = Conversation()
        ..conversationId = '' // 会在保存后设置
        ..type = ConversationType.private
        ..contactUserId = userId
        ..name = user.name
        ..avatar = user.avatar
        ..lastMessagePreview = ''
        ..lastMessageTime = DateTime.now()
        ..unreadCount = 0
        ..createdAt = DateTime.now();

      await _isar.writeTxn(() async {
        await _isar.conversations.put(conversation);
        // 设置conversationId为id的字符串表示
        conversation.conversationId = conversation.id.toString();
        await _isar.conversations.put(conversation);
      });

      _logger.i('创建了新会话', extra: {'conversationId': conversation.id.toString()});
      return conversation.id.toString();
    } catch (e) {
      _logger.e('创建或获取会话失败', error: e);
      return null;
    }
  }

  /// 设置Socket事件监听
  void _setupSocketEventListeners() {
    // 取消之前的所有订阅
    for (final subscription in _socketSubscriptions) {
      subscription.cancel();
    }
    _socketSubscriptions.clear();

    // 连接相关事件
    _socketSubscriptions.add(_socketService.on(SocketEvent.connect).listen((_) {
      _logger.i('Socket连接成功');
      _syncStatusController.add(SyncStatus.idle);
    }));

    _socketSubscriptions.add(_socketService.on(SocketEvent.disconnect).listen((reason) {
      _logger.w('Socket断开连接', extra: {'reason': reason});
      _syncStatusController.add(SyncStatus.error);
    }));

    _socketSubscriptions.add(_socketService.on(SocketEvent.connectError).listen((error) {
      _logger.e('Socket连接错误', error: error);
      _syncStatusController.add(SyncStatus.error);
    }));

    // 用户状态事件
    _socketSubscriptions.add(_socketService.on(SocketEvent.userOnline).listen((data) {
      _logger.i('用户上线', extra: {'data': data});
      _handleUserOnlineStatus(data, true);
    }));

    _socketSubscriptions.add(_socketService.on(SocketEvent.userOffline).listen((data) {
      _logger.i('用户下线', extra: {'data': data});
      _handleUserOnlineStatus(data, false);
    }));

    // 消息相关事件
    _socketSubscriptions.add(_socketService.on(SocketEvent.newMessage).listen((data) {
      _logger.i('收到新消息', extra: {'data': data});
      _handleNewMessage(data);
    }));

    _socketSubscriptions.add(_socketService.on(SocketEvent.messageDelivered).listen((data) {
      _logger.i('消息已送达', extra: {'data': data});
      _handleMessageStatus(data, 'delivered');
    }));

    _socketSubscriptions.add(_socketService.on(SocketEvent.messageRead).listen((data) {
      _logger.i('消息已读', extra: {'data': data});
      _handleMessageStatus(data, 'read');
    }));

    // 输入状态事件
    _socketSubscriptions.add(_socketService.on(SocketEvent.typing).listen((data) {
      _logger.i('对方正在输入', extra: {'data': data});
      _handleTypingStatus(data, true);
    }));

    _socketSubscriptions.add(_socketService.on(SocketEvent.stopTyping).listen((data) {
      _logger.i('对方停止输入', extra: {'data': data});
      _handleTypingStatus(data, false);
    }));
  }

  /// 处理用户在线状态
  void _handleUserOnlineStatus(Map<String, dynamic> data, bool isOnline) {
    try {
      final userId = data['userId'] as String?;
      if (userId == null) return;

      // 更新联系人状态
      _isar.writeTxn(() async {
        final user = await _users.get(int.tryParse(userId) ?? 0);
        if (user != null) {
          user.status = isOnline ? 'online' : 'offline';
          user.lastActiveTime = isOnline ? null : DateTime.now();
          await _users.put(user);
        }
      });

      // 通知UI
      _onlineStatusController.add({
        'userId': userId,
        'isOnline': isOnline,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      _logger.e('处理用户在线状态失败', error: e);
    }
  }

  /// 处理新消息
  Future<void> _handleNewMessage(Map<String, dynamic> data) async {
    try {
      _syncStatusController.add(SyncStatus.syncing);

      // 提取消息数据
      final messageId = data['messageId'] as String?;
      final conversationId = data['conversationId'] as String?;
      final senderId = data['senderId'] as String?;
      final content = data['content'] as String?;
      final messageType = data['type'] as String?;
      final timestamp = data['timestamp'] as int?;

      if (messageId == null || conversationId == null || senderId == null) {
        _logger.w('收到的消息数据不完整', extra: {'data': data});
        _syncStatusController.add(SyncStatus.error);
        return;
      }

      // 检查消息是否已存在
      final existingMessage = await _messages.filter().messageIdEqualTo(messageId).findFirst();
      if (existingMessage != null) {
        _logger.i('消息已存在，跳过', extra: {'messageId': messageId});
        // 更新消息状态为已送达
        await _updateMessageStatus(existingMessage, 'delivered');
        // 通知服务器消息已送达
        _socketService.sendMessageRead(messageId, conversationId);
        _syncStatusController.add(SyncStatus.completed);
        return;
      }

      // 创建新消息
      final message = Message();
      message.messageId = messageId;
      message.conversationId = conversationId;
      message.senderId = senderId;
      message.text = content ?? '';
      message.type = messageType ?? 'text';
      message.createdAt = timestamp != null ? DateTime.fromMillisecondsSinceEpoch(timestamp) : DateTime.now();
      message.status = 'delivered';

      // 处理特殊消息类型（如媒体消息）
      if (message.type == 'image' || message.type == 'voice' || message.type == 'file' || message.type == 'video') {
        _handleMediaMessage(message, data);
      }

      // 保存消息到数据库
      await _isar.writeTxn(() async {
        message.id = await _messages.put(message);
        // 同步ID字段
        DatabaseInitializer.syncIds(message);
        await _messages.put(message);

        // 更新会话的最后一条消息
        await _updateConversationLastMessage(conversationId, message);
      });

      // 通知服务器消息已送达
      _socketService.sendMessageRead(messageId, conversationId);

      // 通知UI新消息
      _messageStreamController.add(message);

      _syncStatusController.add(SyncStatus.completed);
    } catch (e) {
      _logger.e('处理新消息失败', error: e);
      _syncStatusController.add(SyncStatus.error);
    }
  }

  /// 处理媒体消息
  void _handleMediaMessage(Message message, Map<String, dynamic> data) {
    // 解析媒体URL
    final mediaUrl = data['mediaUrl'] as String?;
    if (mediaUrl != null) {
      message.mediaUrl = mediaUrl;
    }

    // 处理其他属性
    if (message.type == 'voice') {
      message.duration = data['duration'] as int? ?? 0;
    } else if (message.type == 'video') {
      message.duration = data['duration'] as int? ?? 0;
      message.thumbnailUrl = data['thumbnailUrl'] as String?;
    } else if (message.type == 'file') {
      message.fileName = data['fileName'] as String?;
      message.fileSize = data['fileSize'] as double? ?? 0;
    }
  }

  /// 更新会话的最后一条消息
  Future<void> _updateConversationLastMessage(String conversationId, Message message) async {
    final conversation = await _conversations.filter().conversationIdEqualTo(conversationId).findFirst();
    if (conversation != null) {
      conversation.lastMessagePreview = _generateMessagePreview(message);
      conversation.lastMessageTime = message.createdAt;

      // 如果消息不是当前用户发送的，增加未读计数
      try {
        final currentUserId = await _getCurrentUserId();
        if (message.senderId != currentUserId) {
          conversation.unreadCount = (conversation.unreadCount) + 1;
        }
      } catch (e) {
        _logger.e('获取当前用户ID失败', error: e);
      }

      await _conversations.put(conversation);
    }
  }

  /// 生成消息预览
  String _generateMessagePreview(Message message) {
    switch (message.type) {
      case 'text':
        return message.text != null && message.text!.length > 20 ? '${message.text!.substring(0, 20)}...' : (message.text ?? '');
      case 'image':
        return '[图片]';
      case 'voice':
        return '[语音]';
      case 'video':
        return '[视频]';
      case 'file':
        return '[文件]${message.fileName ?? ''}';
      case 'location':
        return '[位置]';
      case 'system':
        return '[系统消息]';
      default:
        return '[未知类型消息]';
    }
  }

  /// 更新消息状态
  Future<void> _updateMessageStatus(Message message, String status) async {
    await _isar.writeTxn(() async {
      message.status = status;
      await _messages.put(message);
    });

    // 通知UI消息状态已更新
    _messageStatusController.add({
      'messageId': message.messageId,
      'status': status,
      'conversationId': message.conversationId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// 处理消息状态变更
  Future<void> _handleMessageStatus(Map<String, dynamic> data, String status) async {
    try {
      final messageId = data['messageId'] as String?;
      if (messageId == null) return;

      // 查找消息
      final message = await _messages.filter().messageIdEqualTo(messageId).findFirst();
      if (message != null) {
        // 更新消息状态
        await _updateMessageStatus(message, status);
      }
    } catch (e) {
      _logger.e('处理消息状态变更失败', error: e);
    }
  }

  /// 处理输入状态
  void _handleTypingStatus(Map<String, dynamic> data, bool isTyping) {
    try {
      final conversationId = data['conversationId'] as String?;
      final userId = data['userId'] as String?;

      if (conversationId == null || userId == null) return;

      // 通知UI
      _typingStatusController.add({
        'conversationId': conversationId,
        'userId': userId,
        'isTyping': isTyping,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      _logger.e('处理输入状态失败', error: e);
    }
  }

  @override
  Future<void> sendTypingStatus(String conversationId, bool isTyping) async {
    if (!_isSocketInitialized) {
      _logger.w('Socket未初始化，无法发送输入状态');
      return;
    }

    try {
      if (isTyping) {
        _socketService.sendTyping(conversationId);
      } else {
        _socketService.sendStopTyping(conversationId);
      }
    } catch (e) {
      _logger.e('发送输入状态失败', error: e);
    }
  }

  @override
  Stream<Map<String, dynamic>> getTypingStatusStream() {
    return _typingStatusController.stream;
  }

  @override
  Stream<Map<String, dynamic>> getOnlineStatusStream() {
    return _onlineStatusController.stream;
  }

  @override
  Stream<Map<String, dynamic>> getMessageStatusStream() {
    return _messageStatusController.stream;
  }

  @override
  Stream<SyncStatus> getSyncStatusStream() {
    return _syncStatusController.stream;
  }

  /// 将消息对象转换为JSON
  Map<String, dynamic> _messageToJson(Message message) {
    return {
      'messageId': message.messageId,
      'conversationId': message.conversationId,
      'senderId': message.senderId,
      'content': message.text,
      'type': message.type,
      'timestamp': message.createdAt.millisecondsSinceEpoch,
      'mediaUrl': message.mediaUrl,
      'thumbnailUrl': message.thumbnailUrl,
      'duration': message.duration,
      'fileName': message.fileName,
      'fileSize': message.fileSize,
    };
  }

  /// 创建消息通用方法
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
    } catch (e) {
      _logger.e('创建消息失败', error: e);
      rethrow;
    }
  }

  /// 发送消息通用方法
  Future<Message> _sendMessage(Message message) async {
    try {
      await _isar.writeTxn(() async {
        message.id = await _messages.put(message);
        // 同步ID字段
        DatabaseInitializer.syncIds(message);

        // 更新状态
        message.status = 'sent';
        await _messages.put(message);

        // 更新会话最后消息预览
        final conversation = await getConversationById(message.conversationId);
        if (conversation != null) {
          conversation.lastMessageTime = message.createdAt;

          // 根据消息类型生成不同预览
          String preview;
          switch (message.type) {
            case 'text':
              preview = message.text ?? '';
              break;
            case 'image':
              preview = '[图片]';
              break;
            case 'voice':
              preview = '[语音]';
              break;
            case 'file':
              preview = '[文件]';
              break;
            case 'video':
              preview = '[视频]';
              break;
            case 'location':
              preview = '[位置]';
              break;
            case 'system':
              preview = '[系统消息]';
              break;
            default:
              preview = '';
          }

          conversation.lastMessagePreview = preview;
          DatabaseInitializer.syncIds(conversation);
          await _conversations.put(conversation);
        }
      });

      // 通过Socket发送消息
      if (_isSocketInitialized) {
        final messageJson = _messageToJson(message);
        _socketService.sendMessage(messageJson);
      }

      // 通知消息更新
      _messageStreamController.add(message);

      return message;
    } catch (e) {
      _logger.e('发送消息失败', error: e);

      // 更新消息状态为失败
      try {
        await _isar.writeTxn(() async {
          message.status = 'failed';
          await _messages.put(message);
        });
      } catch (updateError) {
        _logger.e('更新消息状态失败', error: updateError);
      }

      rethrow;
    }
  }
}
