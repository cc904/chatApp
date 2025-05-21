import 'package:cc/core/proto/generated/user.pb.dart';
import 'package:cc/core/database/database_initializer.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/features/home/domain/repositories/home_repository.dart';
import 'package:cc/core/database/models/user.dart';
import 'package:cc/core/database/models/conversation.dart';
import 'package:cc/core/database/models/message.dart';
import 'package:cc/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:cc/features/contacts/data/repositories/contacts_repository_impl.dart';
import 'dart:async';

/// HomeRepository的实现类
/// 负责用户会话初始化相关的业务逻辑
class HomeRepositoryImpl implements HomeRepository {
  final LogService _logger = LogService.instance;
  final CurrentUserProto _currentUser;

  // 使用代理模式，委托给专门的仓库实现
  late final ChatRepositoryImpl _chatRepository;
  late final ContactsRepositoryImpl _contactsRepository;

  // 实时通信相关的控制器
  final _typingStatusController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _onlineStatusController =
      StreamController<Map<String, dynamic>>.broadcast();

  /// 构造函数
  HomeRepositoryImpl({required CurrentUserProto currentUserProto})
      : _currentUser = currentUserProto {
    initUserSession(currentUserProto);
    _chatRepository = ChatRepositoryImpl(currentUserProto: currentUserProto);
    _contactsRepository = ContactsRepositoryImpl(currentUserProto: currentUserProto);
  }

  /// 初始化用户会话
  ///
  /// 完成数据库和通信服务初始化
  ///
  /// 参数:
  /// - user: 用户信息对象
  ///
  /// 返回:
  /// - 操作成功返回true，失败返回false
  @override
  Future<bool> initUserSession(CurrentUserProto currentUserProto) async {
    try {
      _logger.i('repo 初始化用户会话', extra: {'userId': currentUserProto.userId});

      // 初始化数据库
      final dbInitialized = await initDatabase(currentUserProto);
      if (!dbInitialized) {
        _logger.e('数据库初始化失败');
        return false;
      }

      // 初始化通信服务
      final commInitialized = await initCommunication(currentUserProto);
      if (!commInitialized) {
        _logger.e('通信服务初始化失败');
        return false;
      }

      _logger.i('repo 用户会话初始化成功');
      return true;
    } catch (error) {
      _logger.e('初始化用户会话失败', error: error, stackTrace: StackTrace.current);
      return false;
    }
  }

  /// 初始化数据库
  ///
  /// 参数:
  /// - userId: 用户ID
  ///
  /// 返回:
  /// - 操作成功返回true，失败返回false
  @override
  Future<bool> initDatabase(CurrentUserProto currentUserProto) async {
    try {
      _logger.i('初始化数据库', extra: {'userId': currentUserProto.userId});

      await DatabaseInitializer.init(userId: currentUserProto.userId);

      if (DatabaseInitializer.isInitialized) {
        _logger.i('repo 数据库初始化成功');
        return true;
      } else {
        _logger.e('数据库初始化失败');
        return false;
      }
    } catch (error) {
      _logger.e('初始化数据库出错', error: error, stackTrace: StackTrace.current);
      return false;
    }
  }

  /// 初始化实时通信
  ///
  /// 参数:
  /// - userId: 用户ID
  /// - token: 认证令牌
  ///
  /// 返回:
  /// - 操作成功返回true，失败返回false
  @override
  Future<bool> initCommunication(CurrentUserProto currentUserProto) async {
    // 简化实现，不再需要连接服务
    return true;
  }

  // 💢💢💢💢💢💢💢💢💢💢💢💢💢💢 聊天相关 💢💢💢💢💢💢💢💢💢💢💢💢💢💢

  /// 获取所有会话
  @override
  Future<List<Conversation>> getAllConversations() async {
    try {
      return await _chatRepository.getAllConversations();
    } catch (error) {
      _logger.e('获取所有会话失败', error: error);
      return [];
    }
  }

  /// 监听会话变化
  @override
  Stream<List<Conversation>> watchConversations() {
    try {
      // 转换Stream<void>为Stream<List<Conversation>>
      final controller = StreamController<List<Conversation>>.broadcast();

      // 原始的监听
      final subscription =
          _chatRepository.watchConversations().listen((_) async {
        // 当收到变化通知时，获取最新数据
        final conversations = await _chatRepository.getAllConversations();
        controller.add(conversations);
      });

      // 确保controller关闭时取消订阅
      controller.onCancel = () {
        subscription.cancel();
      };

      // 立即触发一次数据加载
      _chatRepository.getAllConversations().then((conversations) {
        controller.add(conversations);
      });

      return controller.stream;
    } catch (error) {
      _logger.e('监听会话变化失败', error: error);
      // 返回空流
      return Stream.value([]);
    }
  }

  /// 获取会话消息
  @override
  Future<List<Message>> getMessagesForConversation(
      String conversationId) async {
    try {
      // 使用正确的方法名
      return await _chatRepository.getConversationMessages(conversationId);
    } catch (error) {
      _logger.e('获取会话消息失败', error: error);
      return [];
    }
  }

  /// 监听会话消息变化
  @override
  Stream<List<Message>> watchMessagesForConversation(String conversationId) {
    try {
      // 转换Stream<void>为Stream<List<Message>>
      final controller = StreamController<List<Message>>.broadcast();

      // 原始的监听
      final subscription = _chatRepository
          .watchConversationMessages(conversationId)
          .listen((_) async {
        // 当收到变化通知时，获取最新数据
        final messages =
            await _chatRepository.getConversationMessages(conversationId);
        controller.add(messages);
      });

      // 确保controller关闭时取消订阅
      controller.onCancel = () {
        subscription.cancel();
      };

      // 立即触发一次数据加载
      _chatRepository.getConversationMessages(conversationId).then((messages) {
        controller.add(messages);
      });

      return controller.stream;
    } catch (error) {
      _logger.e('监听会话消息变化失败', error: error);
      // 返回空流
      return Stream.value([]);
    }
  }

  /// 发送消息
  @override
  Future<bool> sendMessage(Message message) async {
    try {
      // 使用sendTextMessage方法，返回的是Message对象
      final sentMessage = await _chatRepository.sendTextMessage(
          message.conversationId, message.text ?? '');
      // 如果消息ID不为空，则表示发送成功
      return sentMessage.messageId.isNotEmpty;
    } catch (error) {
      _logger.e('发送消息失败', error: error);
      return false;
    }
  }

  /// 标记消息为已读
  @override
  Future<bool> markAsRead(String conversationId) async {
    try {
      // 调用无返回值的方法
      await _chatRepository.markConversationAsRead(conversationId);
      // 假设成功执行即为成功标记
      return true;
    } catch (error) {
      _logger.e('标记消息为已读失败', error: error);
      return false;
    }
  }

  /// 获取打字状态流
  @override
  Stream<Map<String, dynamic>> getTypingStatusStream() {
    return _typingStatusController.stream;
  }

  /// 获取在线状态流
  @override
  Stream<Map<String, dynamic>> getOnlineStatusStream() {
    return _onlineStatusController.stream;
  }

  /// 获取或创建私聊会话
  @override
  Future<Conversation> getOrCreatePrivateConversation(
      String contactUserId) async {
    try {
      return await _chatRepository
          .getOrCreatePrivateConversation(contactUserId);
    } catch (error) {
      _logger.e('获取或创建私聊会话失败', error: error);
      throw Exception('无法创建会话: ${error.toString()}');
    }
  }

  // 💢💢💢💢💢💢💢💢💢💢💢💢💢💢 联系人相关 💢💢💢💢💢💢💢💢💢💢💢💢💢💢

  /// 获取所有联系人
  @override
  Future<List<User>> getAllContacts() async {
    try {
      return await _contactsRepository.getAllContacts();
    } catch (error) {
      _logger.e('获取所有联系人失败', error: error);
      return [];
    }
  }

  /// 监听联系人变化
  @override
  Stream<List<User>> watchContacts() {
    try {
      // 转换Stream<void>为Stream<List<User>>
      final controller = StreamController<List<User>>.broadcast();

      // 原始的监听
      final subscription =
          _contactsRepository.watchContacts().listen((_) async {
        // 当收到变化通知时，获取最新数据
        final contacts = await _contactsRepository.getAllContacts();
        controller.add(contacts);
      });

      // 确保controller关闭时取消订阅
      controller.onCancel = () {
        subscription.cancel();
      };

      // 立即触发一次数据加载
      _contactsRepository.getAllContacts().then((contacts) {
        controller.add(contacts);
      });

      return controller.stream;
    } catch (error) {
      _logger.e('监听联系人变化失败', error: error);
      // 返回空流
      return Stream.value([]);
    }
  }

  /// 获取联系人详情
  @override
  Future<User?> getContact(String userId) async {
    try {
      // 使用正确的方法名
      return await _contactsRepository.getContactById(userId);
    } catch (error) {
      _logger.e('获取联系人详情失败', error: error);
      return null;
    }
  }

  /// 添加联系人
  @override
  Future<bool> addContact(User contact) async {
    try {
      return await _contactsRepository.addContact(contact);
    } catch (error) {
      _logger.e('添加联系人失败', error: error);
      return false;
    }
  }

  // 💢💢💢💢💢💢💢💢💢💢💢💢💢💢 通话相关 💢💢💢💢💢💢💢💢💢💢💢💢💢💢

  /// 获取通话记录
  @override
  Future<List<dynamic>> getCallHistory() async {
    try {
      _logger.i('获取通话记录');

      // 获取联系人列表，用于生成模拟通话记录
      final contacts = await _contactsRepository.getAllContacts();
      if (contacts.isEmpty) {
        return [];
      }
      

      return contacts;
    } catch (error) {
      _logger.e('获取通话记录失败', error: error, stackTrace: StackTrace.current);
      return [];
    }
  }

  /// 发起通话
  @override
  Future<bool> initiateCall(String contactId, bool isVideo) async {
    // 暂未实现，返回false
    return false;
  }

  /// 结束通话
  @override
  Future<bool> endCall(String callId) async {
    // 暂未实现，返回true
    return true;
  }

  // 💢💢💢💢💢💢💢💢💢💢💢💢💢💢 个人资料相关 💢💢💢💢💢💢💢💢💢💢💢💢💢💢

  /// 获取当前用户资料
  @override
  Future<User?> getCurrentUserProfile() async {
    try {
      final currentUserId = DatabaseInitializer.currentUserId;
      if (currentUserId == null) return null;

      // 使用正确的方法名
      return await _contactsRepository.getContactById(currentUserId);
    } catch (error) {
      _logger.e('获取当前用户资料失败', error: error);
      return null;
    }
  }

  /// 更新用户资料
  @override
  Future<bool> updateUserProfile(User user) async {
    try {
      // 暂不实现，返回true
      return true;
    } catch (error) {
      _logger.e('更新用户资料失败', error: error);
      return false;
    }
  }

  /// 获取用户状态
  @override
  Future<String> getUserStatus() async {
    try {
      // 暂时返回固定状态
      return 'online';
    } catch (error) {
      _logger.e('获取用户状态失败', error: error);
      return 'offline';
    }
  }

  /// 更新用户状态
  @override
  Future<bool> updateUserStatus(String status) async {
    try {
      // 暂不实现，返回true
      return true;
    } catch (error) {
      _logger.e('更新用户状态失败', error: error);
      return false;
    }
  }

  /// 释放资源
  void dispose() {
    _typingStatusController.close();
    _onlineStatusController.close();
  }
}
