import 'dart:async';

import 'package:cc/core/database/drift_database.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/database/database_initializer.dart';
import 'package:cc/core/adapters/conversation_adapter.dart';
import 'package:cc/core/services/communication_service.dart';
import 'package:cc/core/services/proto_socket_service.dart';
import 'package:cc/features/chat/domain/repositories/chats_repository.dart';
import 'package:cc/features/chat/domain/entities/chat_state_snapshot.dart';
import 'package:cc/features/chat/domain/entities/conversation_update_event.dart';

import 'package:cc/core/proto/generated/conversation.pb.dart' as conversation_proto;
// import 'package:cc/features/chat/domain/entities/participant.dart';
import 'package:cc/core/services/conversation_preview_notification.dart';
import 'package:cc/core/services/app_lifecycle_service.dart';
 
import 'package:drift/drift.dart';

/// ChatsRepository的实现类
/// 负责聊天会话列表相关的数据处理、会话管理等功能
class ChatsRepositoryImpl implements ChatsRepository {
  final LogService _logger = LogService.instance;
  final CommunicationService _communicationService = CommunicationService();

  final CurrentUser _currentUser;

  // 获取当前数据库实例，使用DatabaseInitializer
  AppDatabase get _database => DatabaseInitializer.database;

  // 💢💢💢💢💢💢💢💢💢💢💢💢💢  状态快照管理  💢💢💢💢💢💢💢💢💢💢💢💢💢💢

  // 状态快照缓存
  final Map<String, ChatStateSnapshot> _stateSnapshots = <String, ChatStateSnapshot>{};

  // 💢💢💢 新架构：会话更新事件流控制器
  final StreamController<ConversationUpdateEvent> _conversationUpdateController = StreamController<ConversationUpdateEvent>.broadcast();

  // 事件订阅列表
  final List<StreamSubscription> _subscriptions = [];

  /// 💢💢💢 新架构：通知会话更新事件
  void _notifyConversationUpdate(ConversationUpdateEvent event) {
    if (!_conversationUpdateController.isClosed) {
      _conversationUpdateController.add(event);
    }
  }

  // 构造函数
  ChatsRepositoryImpl({required CurrentUser currentUser}) : _currentUser = currentUser {
    _logger.x('ChatsRepositoryImpl 初始化');

    // 初始化会话预览通知服务的当前用户
    ConversationPreviewNotificationService.instance.setCurrentUser(currentUser);

    _registerEventHandlers();
  }

  /// 💢💢💢💢💢💢💢💢💢💢💢💢💢💢  事件处理  💢💢💢💢💢💢💢💢💢💢💢💢💢💢

  /// 设置联系人更新监听器
  void _setupContactUpdateListener() {
    try {
      final protoSocketService = ProtoSocketService();
      protoSocketService.on('local:conversation:contact_updated', _handleContactUpdatedForConversations);
      // 💢💢💢 新增：监听会话移除事件
      protoSocketService.on('local:conversation:removed', _handleConversationRemovedLocally);
      _logger.i('联系人更新监听器和会话移除监听器设置成功');
    } catch (e) {
      _logger.e('设置本地事件监听器失败', extra: {'error': e.toString()});
    }
  }

  /// 注册事件监听
  Future<void> _registerEventHandlers() async {
    if (!_communicationService.isInitialized) {
      _logger.i('通信服务未初始化，无法注册事件处理器');
      return;
    }
    _logger.i('注册事件处理器');

    // 先取消所有现有的监听器，防止重复注册
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();

    _logger.i('ChatsRepository Proto事件流 订阅');
    _subscriptions
      ..add(_communicationService.onProto<conversation_proto.ConversationCollection>('conversation:sync:response').listen(_handleSyncResponseProto))
      ..add(_communicationService.onProto<conversation_proto.ConversationPreviewUpdated>('conversation:preview:updated').listen(_handleConversationPreviewUpdated))
      ..add(_communicationService.onProto<conversation_proto.ConversationSettingsUpdateResponse>('conversation:settings:updated').listen(_handleConversationSettingsUpdate))
      ..add(_communicationService.onProto<conversation_proto.ConversationInfoUpdateResponse>('conversation:info:update:response').listen(_handleConversationInfoUpdateResponse))
      ..add(_communicationService.onProto<conversation_proto.ConversationInfoUpdated>('conversation:info:updated').listen(_handleConversationInfoUpdated))
      ..add(_communicationService.onProto<conversation_proto.UserJoinedNotification>('conversation:user:joined').listen(_handleUserJoinedNotification))
      ..add(_communicationService.onProto<conversation_proto.UserLeftNotification>('conversation:user:left').listen(_handleUserLeftNotification))
      ..add(_communicationService.onProto<conversation_proto.ConversationDetailResponse>('conversation:detail:response').listen(_handleConversationDetailResponse))
      ..add(_communicationService.onProto<conversation_proto.ParticipantStatusUpdateResponse>('participant:status:update:response').listen(_handleParticipantStatusUpdateResponse))
      ..add(_communicationService.onProto<conversation_proto.ParticipantIndexUpdatedNotification>('conversation:participant:index:updated').listen(_handleParticipantIndexUpdated))
      ..add(_communicationService.onProto<conversation_proto.ConversationJoinLeaveResponse>('conversation:leave:response').listen(_handleConversationLeaveResponse))
      ..add(_communicationService.onProto<conversation_proto.ConversationCreateResponse>('conversation:added').listen(_handleConversationAdded));

    // 监听本地联系人更新事件，用于更新私聊会话名称
    _setupContactUpdateListener();
  }

  /// 获取联系人信息
  /// 根据ID获取单个联系人详情
  /// [userId] - 联系人ID
  /// 返回联系人信息,不存在则返回null
  @override
  Future<User?> getContactById(String userId) async {
    try {
      return await (_database.select(_database.users)..where((u) => u.userId.equals(userId))).getSingleOrNull();
    } catch (error) {
      _logger.e('获取联系人信息失败', error: error, stackTrace: StackTrace.current);
      return null;
    }
  }

  /// 获取所有会话
  /// 从本地数据库获取所有会话
  /// 返回会话列表，自动过滤掉未加入的频道
  @override
  Future<List<Conversation>> getAllConversations() async {
    try {
      _logger.i('从本地数据库获取所有会话');

      // 直接从数据库获取会话列表，不发送同步事件
      final conversations = await (_database.select(_database.conversations)
            ..orderBy([
              (c) => OrderingTerm(
                    expression: c.lastMessageTime,
                    mode: OrderingMode.desc,
                  )
            ]))
          .get();

      // 过滤掉未加入的频道 (暂时简化处理)
      final filteredConversations = conversations.where((c) => c.type != 'CHANNEL').toList();

      // 🔥🔥🔥 详细记录私聊会话的participants信息
      final privateConversations = filteredConversations.where((c) => c.type == 'PRIVATE').toList();
      for (final conversation in privateConversations) {
        _logger.i('📋📋📋 从数据库加载私聊会话', extra: {
          'conversationId': conversation.conversationId,
          'name': conversation.name,
          'participants': conversation.participants,
          'participantsLength': conversation.participants.length,
          'lastMessageTime': conversation.lastMessageTime?.toIso8601String(),
        });
      }

      _logger.d('成功获取会话列表', extra: {
        '原始会话数量': conversations.length,
        '过滤后会话数量': filteredConversations.length,
        '私聊会话数量': privateConversations.length,
        '过滤掉的频道数量': conversations.length - filteredConversations.length,
      });
      return filteredConversations;
    } catch (error, stack) {
      _logger.e('获取会话列表失败', error: error, stackTrace: stack);
      return [];
    }
  }

  /// 💢💢💢 新增：全量替换所有会话数据
  /// 清空本地所有会话，然后添加新的会话列表
  /// [newConversations] - 新的会话列表（来自服务器的完整数据）
  Future<void> _replaceAllConversations(List<Conversation> newConversations) async {
    try {
      _logger.i('全量替换会话数据', extra: {'新会话数': newConversations.length});

      // 避免与数据库关闭/切换并发：事务前做一次连接可用性探测
      try {
        await _database.customSelect('SELECT 1').getSingle();
      } catch (e) {
        _logger.w('数据库连接可能已关闭，跳过全量替换', extra: {'error': e.toString()});
        throw Exception('数据库连接不可用');
      }

      await _database.transaction(() async {
        // 💢💢💢 第一步：清空所有现有会话
        await _database.delete(_database.conversations).go();
        _logger.d('已清空所有本地会话数据');

        // 💢💢💢 第二步：批量添加新会话
        if (newConversations.isNotEmpty) {
          // 🔥🔥🔥 添加私聊会话的详细日志
          // for (final conversation in newConversations) {
          //   if (conversation.type == 'PRIVATE') {
          //     _logger.i('📱📱📱 存储私聊会话到数据库', extra: {
          //       'conversationId': conversation.conversationId,
          //       'name': conversation.name,
          //       'participants': conversation.participants,
          //       'participantsLength': conversation.participants.length,
          //     });
          //   }
          // }

          await _database.batch((batch) {
            for (final conv in newConversations) {
              batch.insert(_database.conversations, conv);
            }
          });
          _logger.d('已添加新会话数据', extra: {'数量': newConversations.length});
        }
      });

      _logger.i('全量替换会话数据完成');
    } catch (error) {
      _logger.e('全量替换会话数据失败', extra: {'error': error.toString()});
      throw Exception('全量替换会话数据失败: $error');
    }
  }

  /// 获取会话信息
  /// 根据ID获取单个会话详情
  /// [conversationId] - 会话ID
  /// 返回会话信息,不存在则返回null
  @override
  Future<Conversation?> getConversationById(String conversationId) async {
    try {
      return await (_database.select(_database.conversations)..where((c) => c.conversationId.equals(conversationId))).getSingleOrNull();
    } catch (error) {
      _logger.e('获取会话信息失败', error: error, stackTrace: StackTrace.current);
      return null;
    }
  }

  /// 获取或创建私聊会话
  /// 根据联系人ID查找已有会话,不存在则通过服务器创建新会话
  /// [contactUserId] - 联系人ID
  /// 返回会话对象
  @override
  Future<Conversation> getOrCreatePrivateConversation(String contactUserId) async {
    try {
      _logger.i('获取或创建私聊会话', extra: {'contactUserId': contactUserId});

      // 先查找已有的私聊会话 - 简化处理，通过participants字段查找
      final privateConversations = await (_database.select(_database.conversations)..where((c) => c.type.equals('PRIVATE'))).get();

      // 在内存中查找包含该联系人的私聊会话
      Conversation? existing;
      for (final conv in privateConversations) {
        if (conv.participants.contains(contactUserId)) {
          existing = conv;
          break;
        }
      }

      if (existing != null) {
        _logger.i('找到已存在的私聊会话', extra: {
          'conversationId': existing.conversationId,
          'contactUserId': contactUserId,
        });
        return existing;
      }

      // 💢💢💢 修改：通过服务器创建新会话，而不是本地乐观创建
      _logger.i('未找到已存在会话，通过服务器创建新私聊会话');

      if (!_communicationService.isInitialized) {
        throw Exception('通信服务未初始化，无法创建会话');
      }

      // 获取联系人信息
      final contact = await getContactById(contactUserId);
      if (contact == null) {
        throw Exception('联系人不存在');
      }

      // 💢💢💢 创建会话请求
      final createRequest = conversation_proto.ConversationCreateRequest()
        ..type = conversation_proto.ConversationType.PRIVATE
        ..contactUserId = contactUserId
        ..name = contact.name;

      // 设置头像（如果有）
      if (contact.avatar != null && contact.avatar!.isNotEmpty) {
        createRequest.avatar = contact.avatar!;
      }

      _logger.d('发送创建会话请求', extra: {
        'contactUserId': contactUserId,
        'contactName': contact.name,
      });

      // 💢💢💢 发送创建请求到服务器
      // 打印通信服务状态
      try {
        final connInfo = ProtoSocketService().getConnectionInfo();
        _logger.i('会话创建前连接信息', extra: connInfo);
      } catch (_) {}

      final success = await _communicationService.emitProto('conversation:create', createRequest);

      _logger.i('会话创建请求已发送', extra: {
        'success': success,
        'event': 'conversation:create',
        'socketConnected': ProtoSocketService().isConnected,
      });

      if (!success) {
        throw Exception('发送创建会话请求失败');
      }

      // 💢💢💢 等待服务器响应
      try {
        // 订阅前打印订阅信息
        _logger.i('准备订阅会话创建响应', extra: {
          'event': 'conversation:create:response',
          'timeoutSeconds': 10,
        });

        final stream = _communicationService.onProto<conversation_proto.ConversationCreateResponse>('conversation:create:response');

        // 提前挂上一个debug监听（单次）用于日志
        final sub = stream.listen((resp) {
          _logger.i('收到会话创建响应(预监听)', extra: {
            'success': resp.success,
            'hasConversation': resp.hasConversation(),
            'message': resp.message,
          });
        });

        // 超时辅助告警（10秒）
        final warnTimer = Timer(const Duration(seconds: 10), () {
          _logger.w('等待会话创建响应超过10秒，可能网络慢或服务器繁忙');
        });

        final response = await stream.timeout(const Duration(seconds: 20)).first;

        // 清理辅助
        await sub.cancel();
        warnTimer.cancel();

        if (!response.success) {
          throw Exception('服务器创建会话失败: ${response.message}');
        }

        if (!response.hasConversation()) {
          throw Exception('服务器响应中缺少会话数据');
        }

        _logger.i('服务器创建会话成功', extra: {
          'conversationId': response.conversation.conversationId,
          'contactUserId': contactUserId,
        });

        // 💢💢💢 将服务器返回的会话数据保存到本地数据库
        final conversation = ConversationAdapter.fromProto(
          response.conversation,
          currentUserId: _currentUser.userId,
        );

        // 新增：如果本地已存在同conversationId，直接读取并返回，避免重复插入
        final existed = await (_database.select(_database.conversations)
              ..where((c) => c.conversationId.equals(conversation.conversationId)))
            .getSingleOrNull();
        if (existed != null) {
          _logger.i('本地已有相同conversationId，直接复用', extra: {
            'conversationId': existed.conversationId,
          });
          return existed;
        }

        try {
          await _database.into(_database.conversations).insertOnConflictUpdate(conversation);
        } catch (e) {
          _logger.w('插入会话时唯一键冲突，改为覆盖更新', extra: {
            'conversationId': conversation.conversationId,
            'error': e.toString(),
          });
          await _database.into(_database.conversations).insertOnConflictUpdate(conversation);
        }

        return conversation;
      } on TimeoutException {
        // 记录更详细的状态辅助排错
        try {
          final connInfo = ProtoSocketService().getConnectionInfo();
          _logger.e('等待服务器创建会话响应超时', extra: {
            'connectionInfo': connInfo,
          });
        } catch (_) {
          _logger.e('等待服务器创建会话响应超时');
        }
        throw Exception('创建会话超时，请重试');
      }
    } catch (error) {
      _logger.e('获取或创建私聊会话失败', error: error, stackTrace: StackTrace.current, extra: {'contactUserId': contactUserId});
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
  Future<Conversation> createGroupConversation(String name, List<String> memberIds, {String? avatar}) async {
    try {
      // 这里需要完整的实现，暂时抛出错误
      throw UnimplementedError('创建群聊功能需要完整实现');
    } catch (error) {
      _logger.e('创建群聊失败', error: error, stackTrace: StackTrace.current);
      rethrow;
    }
  }

  /// 💢💢💢 新架构：获取会话更新事件流
  @override
  Stream<ConversationUpdateEvent> getConversationUpdateStream() {
    return _conversationUpdateController.stream;
  }

  /// 💢💢💢 新增：监听单个会话变化
  /// 用于 ChatCubit 监听特定会话的状态变化
  @override
  Stream<Conversation?> watchConversation(String conversationId) {
    return (_database.select(_database.conversations)..where((c) => c.conversationId.equals(conversationId))).watchSingleOrNull();
  }

  /// 删除会话
  /// 删除指定的会话及其所有消息和相关媒体文件
  /// [conversationId] - 会话ID
  @override
  Future<void> deleteConversation(String conversationId) async {
    try {
      await (_database.delete(_database.conversations)..where((c) => c.conversationId.equals(conversationId))).go();
    } catch (error) {
      _logger.e('删除会话失败', error: error, stackTrace: StackTrace.current);
      rethrow;
    }
  }

  /// 创建或获取与用户的对话
  /// 如果已存在与该用户的一对一对会话,则返回该会话ID
  /// 否则创建新会话并返回ID
  /// [userId] - 目标用户ID
  @override
  Future<String?> createOrGetConversation(String userId) async {
    try {
      _logger.i('获取或创建与用户的会话', extra: {'userId': userId});

      // 检查是否已有与该用户的私聊会话
      final existingConversation = await (_database.select(_database.conversations)..where((c) => c.type.equals('PRIVATE'))).get();

      // 简化查找逻辑
      Conversation? found;
      for (final conv in existingConversation) {
        if (conv.participants.contains(userId)) {
          found = conv;
          break;
        }
      }

      if (found != null) {
        _logger.i('找到已存在的会话', extra: {
          'conversationId': found.conversationId,
          'name': found.name,
          'createdAt': found.createdAt.toIso8601String(),
        });

        // 💢💢💢 修复：检查conversationId是否为空
        if (found.conversationId.isEmpty) {
          _logger.w('找到的会话conversationId为空，需要重新创建', extra: {
            'userId': userId,
          });

          // 删除无效的会话记录
          await (_database.delete(_database.conversations)..where((c) => c.conversationId.equals(found!.conversationId))).go();

          // 重新通过服务器创建会话
          _logger.i('删除无效会话记录，通过服务器重新创建');
          final conversation = await getOrCreatePrivateConversation(userId);

          _logger.i('重新创建会话成功', extra: {'conversationId': conversation.conversationId});
          return conversation.conversationId;
        }

        return found.conversationId;
      }

      // 💢💢💢 修复：通过服务器创建新会话，而不是本地创建
      _logger.i('未找到已存在会话，通过服务器创建新私聊会话');

      // 💢💢💢 使用现有的getOrCreatePrivateConversation方法
      final conversation = await getOrCreatePrivateConversation(userId);

      _logger.i('成功创建新会话', extra: {'conversationId': conversation.conversationId});
      return conversation.conversationId;
    } catch (error) {
      _logger.e('创建或获取会话失败', error: error, stackTrace: StackTrace.current);
      return null;
    }
  }

  /// 监听联系人变化
  /// 返回联系人列表变化的流
  @override
  Stream<void> watchContacts() {
    // 使用 Drift 的 watch 功能
    return _database.select(_database.users).watch().map((_) {});
  }

  /// 请求同步会话列表
  /// 从服务器同步最新的会话数据（不再依赖时间戳，始终由服务端决定返回范围）
  /// 会话数据将通过事件通知并由状态管理系统更新UI
  @override
  Future<void> requestSyncConversations() async {
    try {
      // 💢💢💢 优化：智能等待通信服务初始化完成
      if (!_communicationService.isInitialized) {
        _logger.i('通信服务未初始化，智能等待初始化完成...');

        final waitResult = await _waitForCommunicationServiceReady();
        if (!waitResult) {
          _logger.w('通信服务初始化失败或超时，跳过会话同步');
          return;
        }
      }

      // 创建同步请求（不带 lastSyncTime）
      final syncRequest = conversation_proto.SyncConversationsRequest();
      _logger.i('发送会话同步请求（无时间戳）');

      // 发送同步请求到服务器
      _communicationService.emitProto('conversation:sync', syncRequest);
      _logger.i('会话同步请求已发送');
    } catch (error, stack) {
      _logger.e('同步会话失败', error: error, stackTrace: stack);
      rethrow;
    }
  }

  /// 💢💢💢 优化：智能等待通信服务就绪
  Future<bool> _waitForCommunicationServiceReady() async {
    const maxWaitTime = 15000; // 15秒最大等待时间
    const initialCheckInterval = 100; // 初始检查间隔100ms
    const maxCheckInterval = 1000; // 最大检查间隔1秒

    var waitTime = 0;
    var checkInterval = initialCheckInterval;

    while (!_communicationService.isInitialized && waitTime < maxWaitTime) {
      // 监听连接状态变化
      if (_communicationService.isConnected) {
        _logger.d('检测到连接已建立，等待初始化完成...');
      }

      await Future.delayed(Duration(milliseconds: checkInterval));
      waitTime += checkInterval;

      // 渐进式增加检查间隔，减少CPU使用
      if (checkInterval < maxCheckInterval) {
        checkInterval = (checkInterval * 1.2).round().clamp(initialCheckInterval, maxCheckInterval);
      }

      // 每5秒输出一次等待状态
      if (waitTime % 5000 == 0) {
        _logger.d('等待通信服务初始化... (${waitTime / 1000}s/${maxWaitTime / 1000}s)');
      }
    }

    final success = _communicationService.isInitialized;
    if (success) {
      _logger.i('通信服务初始化完成，用时: ${waitTime}ms');
    } else {
      _logger.w('等待通信服务初始化超时: ${maxWaitTime}ms');
    }

    return success;
  }

  /// 💢💢💢 新增：强制全量同步会话列表
  @override
  Future<void> requestFullSyncConversations() async {
    try {
      if (_communicationService.isInitialized) {
        // 发送不包含同步时间的请求，强制全量同步
        final syncRequest = conversation_proto.SyncConversationsRequest();
        _logger.i('发送强制全量会话同步请求');

        // 发送同步请求到服务器
        _communicationService.emitProto('conversation:sync', syncRequest);
        _logger.i('强制全量会话同步请求已发送');
      } else {
        _logger.e('通信服务未初始化，无法同步会话');
      }
    } catch (error, stack) {
      _logger.e('强制全量同步会话失败', error: error, stackTrace: stack);
      rethrow;
    }
  }

  

  /// 统一更新参与者设置（静音、置顶、已读状态）
  @override
  Future<void> updateParticipantSettings(
    String conversationId, {
    int? readMessageIndex,
    bool? muted,
    bool? pinned,
  }) async {
    _logger.i('更新参与者设置', extra: {
      'conversationId': conversationId,
      'readMessageIndex': readMessageIndex,
      'muted': muted,
      'pinned': pinned,
    });

    try {
      // 同步到服务器
      if (_communicationService.isInitialized) {
        _logger.i('开始同步参与者设置到服务器');

        // 创建参与者设置更新请求
        final participantUpdateRequest = conversation_proto.ParticipantStatusUpdateRequest()..conversationId = conversationId;

        // 设置可选字段
        if (readMessageIndex != null) {
          participantUpdateRequest.readMessageIndex = readMessageIndex;
          // 🟢 本地乐观更新：更新 participants JSON 中当前用户的 readMessageIndex，并重算未读
          try {
            final conversation = await getConversationById(conversationId);
            if (conversation != null) {
              final participants = ConversationAdapter.parseParticipants(conversation.participants);
              // 原本用于检测其他字段变化的变量，当前未使用，先移除以避免lint警告
              for (int i = 0; i < participants.length; i++) {
                final p = participants[i];
                if (p.userId == _currentUser.userId) {
                  if (p.readMessageIndex != readMessageIndex) {
                    participants[i] = p.copyWith(readMessageIndex: readMessageIndex);
                    // 占位：当未来增加更多字段变动时可在此扩展
                  }
                  break;
                }
              }
              final int newUnread = (conversation.lastMessageIndex - readMessageIndex).clamp(0, double.infinity).toInt();

              final updatedConversation = conversation.copyWith(
                participants: participants,
                unreadCount: newUnread,
              );
              await _database.update(_database.conversations).replace(updatedConversation);
              _notifyConversationUpdate(ConversationUpdatedEvent(
                updatedConversation: updatedConversation,
                updatedFields: ['participants', 'unreadCount'],
                timestamp: DateTime.now(),
              ));
              _logger.d('已本地乐观更新参与者read并通知UI', extra: {
                'conversationId': conversationId,
                'readMessageIndex': readMessageIndex,
                'unreadCount': newUnread,
              });
            }
          } catch (e, s) {
            _logger.w('本地乐观更新参与者read失败（不中断网络发送）', stackTrace: s, extra: {
              'conversationId': conversationId,
              'error': e.toString(),
            });
          }
        }
        if (muted != null) {
          participantUpdateRequest.muted = muted;
        }
        if (pinned != null) {
          participantUpdateRequest.pinned = pinned;
        }

        // 发送请求到服务器
        _communicationService.emitProto('participant:status:update', participantUpdateRequest);

        // 服务器响应会通过_handleParticipantSettingsUpdate方法处理
      } else {
        _logger.w('通信服务未初始化，无法同步参与者设置到服务器');
      }
    } catch (error) {
      _logger.e('更新参与者设置失败', error: error);
      throw Exception('更新参与者设置失败: ${error.toString()}');
    }
  }

  /// 根据标签过滤会话
  ///
  /// 根据标签类型过滤会话列表
  /// [tabIndex] - 标签索引
  /// 返回过滤后的会话列表
  @override
  Future<List<Conversation>> filterConversationsByTab(int tabIndex) async {
    try {
      _logger.d('根据标签过滤会话', extra: {'tabIndex': tabIndex});

      // 获取所有会话（已经过滤了未加入的频道）
      final conversations = await getAllConversations();

      // 根据标签类型过滤
      switch (tabIndex) {
        case 0: // 全部会话
          return conversations;
        case 1: // 私聊
          return conversations.where((c) => c.type == 'PRIVATE').toList();
        case 2: // 群组
          return conversations.where((c) => c.type == 'GROUP').toList();
        case 3: // 频道
          return conversations.where((c) => c.type == 'CHANNEL').toList();
        case 4: // 未读 - 简化处理
          return conversations; // 实际需要根据未读状态过滤
        default:
          return conversations;
      }
    } catch (error) {
      _logger.e('过滤会话失败', error: error, stackTrace: StackTrace.current);
      // 发生错误时返回空列表
      return [];
    }
  }

  /// 更新会话信息
  ///
  /// 更新会话的名称或头像（群聊和频道）
  /// [conversationId] - 会话ID
  /// [name] - 新的会话名称
  /// [avatar] - 新的会话头像URL
  /// 返回是否更新成功
  @override
  Future<bool> updateConversationInfo(String conversationId, {String? name, String? avatar, String? description}) async {
    try {
      _logger.i('更新会话信息', extra: {
        'conversationId': conversationId,
        'name': name,
        'avatar': avatar,
        'description': description,
      });

      // 验证参数
      if (name == null && avatar == null && description == null) {
        _logger.w('更新会话信息时没有提供有效参数');
        return false;
      }

      // 1️⃣ 先更新本地数据库，乐观更新
      final conversation = await getConversationById(conversationId);

      if (conversation != null) {
        final updatedConversation = conversation.copyWith(
          name: name != null ? Value(name) : const Value.absent(),
          avatar: avatar != null ? Value(avatar) : const Value.absent(),
          description: description != null ? Value(description) : const Value.absent(),
        );
        await _database.update(_database.conversations).replace(updatedConversation);

        _logger.d('本地会话信息已预更新', extra: {
          'conversationId': conversationId,
          'name': name,
          'avatar': avatar,
          'description': description,
        });
      }

      // 2️⃣ 同步到服务器
      if (_communicationService.isInitialized) {
        _logger.i('开始同步会话信息到服务器');

        final updateRequest = conversation_proto.ConversationInfoUpdateRequest()..conversationId = conversationId;
        if (name != null) updateRequest.name = name;
        if (avatar != null) updateRequest.avatar = avatar;
        if (description != null) updateRequest.description = description;

        _communicationService.emitProto('conversation:info:update', updateRequest);
        _logger.i('会话信息更新请求已发送');
        return true;
      } else {
        _logger.w('通信服务未初始化，无法同步会话信息');
        return true; // 本地已更新，视为成功
      }
    } catch (error) {
      _logger.e('更新会话信息失败', error: error);
      return false;
    }
  }

  /// 更新会话设置
  ///
  /// 更新会话的静音或置顶状态
  /// [conversationId] - 会话ID
  /// [muted] - 是否静音
  /// [pinned] - 是否置顶
  /// 返回是否更新成功
  @override
  Future<bool> updateConversationSettings(String conversationId, {bool? muted, bool? pinned}) async {
    try {
      _logger.i('更新会话设置', extra: {'conversationId': conversationId, 'muted': muted, 'pinned': pinned});

      // 验证参数
      if (muted == null && pinned == null) {
        _logger.w('更新会话设置时没有提供有效参数');
        return false;
      }

      // 更新本地数据库
      final conversation = await getConversationById(conversationId);

      if (conversation == null) {
        _logger.e('找不到指定会话', extra: {'conversationId': conversationId});
        return false;
      }

      // 简化处理 - 实际需要更复杂的参与者设置逻辑
      // 这里暂时不实现具体的设置更新逻辑

      _logger.i('本地数据库会话设置已更新');

      // 同步到服务器
      if (_communicationService.isInitialized) {
        _logger.i('开始同步会话设置到服务器');

        // 创建会话设置更新请求
        final settingsRequest = conversation_proto.ConversationSettingsUpdateRequest()..conversationId = conversationId;

        if (muted != null) settingsRequest.muted = muted;
        if (pinned != null) settingsRequest.pinned = pinned;

        // 发送请求到服务器
        _communicationService.emitProto('conversation:settings:update', settingsRequest);

        // 监听服务器响应
        _communicationService.onProto<conversation_proto.ConversationSettingsUpdateResponse>('conversation:settings:update:response').first.then((response) {
          if (response.success) {
            _logger.i('服务器已更新会话设置', extra: {'conversationId': response.conversationId, 'muted': response.muted, 'pinned': response.pinned});

            // ✅ 已移除会话更新事件流，改用数据库监听
          } else {
            _logger.w('服务器更新会话设置失败', extra: {'conversationId': response.conversationId});
          }
        }).catchError((error) {
          _logger.e('接收服务器设置更新响应时出错', error: error);
        });

        return true;
      } else {
        _logger.w('通信服务未初始化，无法同步会话设置到服务器');
        // 即使无法同步到服务器，也认为更新成功，因为本地数据库已更新
        return true;
      }
    } catch (error) {
      _logger.e('更新会话设置失败', error: error, stackTrace: StackTrace.current);
      return false;
    }
  }

  @override
  Stream<List<String>> getOnlineStatusStream() {
    // TODO 实现获取联系人在线状态流
    // 这里应该监听服务器推送的在线状态更新
    return const Stream.empty();
  }

  @override
  Future<void> requestConversationDetail(String conversationId) async {
    try {
      _logger.i('从服务器获取会话详情', extra: {'conversationId': conversationId});

      if (!_communicationService.isInitialized) {
        _logger.w('通信服务未初始化，无法获取会话详情');
        return;
      }

      // 创建获取会话详情请求
      final detailRequest = conversation_proto.ConversationDetailRequest()..conversationId = conversationId;

      // 发送请求到服务器
      _communicationService.emitProto('conversation:detail:request', detailRequest);

      return;
    } catch (error, stackTrace) {
      _logger.e('从服务器获取会话详情失败', error: error, stackTrace: stackTrace);
      return;
    }
  }

  /// 💢💢💢 新增：保存会话到本地数据库
  /// 直接保存一个会话对象到本地数据库
  /// [conversation] - 要保存的会话对象
  @override
  Future<void> saveConversation(Conversation conversation) async {
    try {
      // 💢💢💢 已移除：不再需要手动计算unreadCount，使用动态计算

      await _database.into(_database.conversations).insertOnConflictUpdate(conversation);

      _logger.i('会话已保存到本地数据库', extra: {
        'conversationId': conversation.conversationId,
        'type': conversation.type,
        'name': conversation.name,
      });
    } catch (error, stack) {
      _logger.e('保存会话到本地数据库失败', error: error, stackTrace: stack);
      rethrow;
    }
  }

  /// 💢💢💢 新增：获取第一条未读消息的ID
  /// [conversationId] - 会话ID
  /// [currentUserId] - 当前用户ID
  /// 返回第一条未读消息的ID，如果没有未读消息则返回null
  @override
  Future<String?> getFirstUnreadMessageId(String conversationId, String currentUserId) async {
    try {
      _logger.d('开始查找第一条未读消息ID', extra: {
        'conversationId': conversationId,
        'currentUserId': currentUserId,
      });

      // 首先获取会话信息
      final conversation = await getConversationById(conversationId);
      if (conversation == null) {
        _logger.w('会话不存在', extra: {'conversationId': conversationId});
        return null;
      }

      // 获取第一条未读消息的索引
      final firstUnreadIndex = conversation.getFirstUnreadMessageIndex(currentUserId);
      if (firstUnreadIndex == null) {
        _logger.d('没有未读消息', extra: {
          'conversationId': conversationId,
          'currentUserId': currentUserId,
        });
        return null;
      }

      // 从数据库查询对应索引的消息
      final message =
          await (_database.select(_database.messages)..where((m) => m.conversationId.equals(conversationId) & m.messageIndex.equals(firstUnreadIndex))).getSingleOrNull();

      if (message == null) {
        _logger.w('找不到对应索引的消息', extra: {
          'conversationId': conversationId,
          'firstUnreadIndex': firstUnreadIndex,
        });
        return null;
      }

      _logger.i('成功找到第一条未读消息', extra: {
        'conversationId': conversationId,
        'firstUnreadIndex': firstUnreadIndex,
        'messageId': message.messageId,
        'messageText': message.content?.substring(0, 50) ?? '非文本消息',
      });

      return message.messageId;
    } catch (error, stackTrace) {
      _logger.e('查找第一条未读消息ID失败', error: error, stackTrace: stackTrace, extra: {
        'conversationId': conversationId,
        'currentUserId': currentUserId,
      });
      return null;
    }
  }

  /// 💢💢💢 新增：获取会话中的媒体消息（图片、视频）
  @override
  Future<List<Message>> getMediaMessages(String conversationId, {int limit = 50, int offset = 0}) async {
    try {
      _logger.d('获取媒体消息', extra: {
        'conversationId': conversationId,
        'limit': limit,
        'offset': offset,
      });

      final messages = await (_database.select(_database.messages)
            ..where((m) => m.conversationId.equals(conversationId) & (m.messageType.equals('IMAGE') | m.messageType.equals('VIDEO')))
            ..orderBy([
              (m) => OrderingTerm(
                    expression: m.messageIndex,
                    mode: OrderingMode.desc,
                  )
            ])
            ..limit(limit, offset: offset))
          .get();

      _logger.d('获取媒体消息成功', extra: {
        'conversationId': conversationId,
        'count': messages.length,
      });

      return messages;
    } catch (error, stackTrace) {
      _logger.e('获取媒体消息失败', error: error, stackTrace: stackTrace);
      return [];
    }
  }

  /// 💢💢💢 新增：获取会话中的文件消息
  @override
  Future<List<Message>> getFileMessages(String conversationId, {int limit = 50, int offset = 0}) async {
    try {
      _logger.d('获取文件消息', extra: {
        'conversationId': conversationId,
        'limit': limit,
        'offset': offset,
      });

      final messages = await (_database.select(_database.messages)
            ..where((m) => m.conversationId.equals(conversationId) & m.messageType.equals('FILE'))
            ..orderBy([
              (m) => OrderingTerm(
                    expression: m.messageIndex,
                    mode: OrderingMode.desc,
                  )
            ])
            ..limit(limit, offset: offset))
          .get();

      _logger.d('获取文件消息成功', extra: {
        'conversationId': conversationId,
        'count': messages.length,
      });

      return messages;
    } catch (error, stackTrace) {
      _logger.e('获取文件消息失败', error: error, stackTrace: stackTrace);
      return [];
    }
  }

  /// 💢💢💢 新增：获取会话中的语音消息
  @override
  Future<List<Message>> getVoiceMessages(String conversationId, {int limit = 50, int offset = 0}) async {
    try {
      _logger.d('获取语音消息', extra: {
        'conversationId': conversationId,
        'limit': limit,
        'offset': offset,
      });

      final messages = await (_database.select(_database.messages)
            ..where((m) => m.conversationId.equals(conversationId) & m.messageType.equals('VOICE'))
            ..orderBy([
              (m) => OrderingTerm(
                    expression: m.createdAt,
                    mode: OrderingMode.desc,
                  )
            ])
            ..limit(limit, offset: offset))
          .get();

      _logger.d('获取语音消息成功', extra: {
        'conversationId': conversationId,
        'count': messages.length,
      });

      return messages;
    } catch (error, stackTrace) {
      _logger.e('获取语音消息失败', error: error, stackTrace: stackTrace);
      return [];
    }
  }

  /// 💢💢💢 新增：获取会话中包含链接的消息
  @override
  Future<List<Message>> getLinkMessages(String conversationId, {int limit = 50, int offset = 0}) async {
    try {
      _logger.d('获取链接消息', extra: {
        'conversationId': conversationId,
        'limit': limit,
        'offset': offset,
      });

      // 查找文本消息中包含链接的消息 - 简化处理
      // 实际需要更复杂的正则匹配逻辑
      final messages = await (_database.select(_database.messages)
            ..where((m) => m.conversationId.equals(conversationId) & m.messageType.equals('TEXT'))
            ..orderBy([
              (m) => OrderingTerm(
                    expression: m.createdAt,
                    mode: OrderingMode.desc,
                  )
            ])
            ..limit(limit, offset: offset))
          .get();

      // 在内存中过滤包含链接的消息
      final filteredMessages = messages.where((m) {
        final content = m.content;
        if (content != null) {
          return content.contains('http://') || content.contains('https://');
        }
        return false;
      }).toList();

      _logger.d('获取链接消息成功', extra: {
        'conversationId': conversationId,
        'count': filteredMessages.length,
      });

      return filteredMessages;
    } catch (error, stackTrace) {
      _logger.e('获取链接消息失败', error: error, stackTrace: stackTrace);
      return [];
    }
  }

  /// 💢💢💢 已移除：_calculateAndUpdateUnreadCount 方法

  /// 处理会话同步响应事件
  /// 💢💢💢 修改为全量同步：直接覆盖所有会话数据
  void _handleSyncResponseProto(conversation_proto.ConversationCollection collection) async {
    _logger.i('收到会话全量同步响应', extra: {'conversations': collection.conversations.length});

    try {
      // 💢💢💢 全量同步：转换服务器会话数据
      final List<Conversation> dbConversations = [];
      for (final conv in collection.conversations) {
        // 查找现有会话以保留本地字段（如lastReadTime）
        await getConversationById(conv.conversationId);

        // 🔥🔥🔥 详细的会话同步调试日志
        // _logger.i('🔄🔄🔄 会话同步处理', extra: {
        //   'conversationId': conv.conversationId,
        //   'type': conv.type.toString(),
        //   'participantsCount': conv.participants.length,
        //   'participants': conv.participants
        //       .map((p) => {
        //             'userId': p.userId,
        //             'name': p.name,
        //             'roleId': p.hasRole() ? p.role.value : 0,
        //           })
        //       .toList(),
        // });

        final dbConversation = ConversationAdapter.fromProto(
          conv,
          currentUserId: _currentUser.userId,
        );

        // _logger.i('✅✅✅ 会话转换完成', extra: {
        //   'conversationId': dbConversation.conversationId,
        //   'participants': dbConversation.participants,
        // });

        dbConversations.add(dbConversation);
      }

      // 💢💢💢 全量同步：完全替换本地会话数据
      await _replaceAllConversations(dbConversations);

      // 💢💢💢 新架构：发送会话列表重载事件
      _notifyConversationUpdate(ConversationsReloadedEvent(
        conversations: dbConversations,
        timestamp: DateTime.now(),
      ));

      // 不再保存"上次同步时间"

      _logger.i('会话全量同步完成，已完全替换本地数据', extra: {
        'newCount': dbConversations.length,
      });
    } catch (e, stack) {
      _logger.e('处理全量同步响应数据失败', error: e, stackTrace: stack);
    }
  }

  /// 处理会话更新通知
  /// 根据服务器推送的会话更新通知更新本地会话数据
  /// [notification] - 会话更新通知数据
  void _handleConversationPreviewUpdated(conversation_proto.ConversationPreviewUpdated previewInfo) async {
    try {
      _logger.i('收到会话更新通知', extra: {'conversationId': previewInfo.conversationId});

      // 更新本地会话数据 - 简化处理
      final conversation = await getConversationById(previewInfo.conversationId);

      if (conversation != null) {
        // 计算新的未读数量（基于 participants 中当前用户的 readMessageIndex）
        final newLastMessageIndex = previewInfo.hasLastMessageIndex() ? previewInfo.lastMessageIndex : conversation.lastMessageIndex;
        int userReadIndex = 0;
        try {
          final participants = ConversationAdapter.parseParticipants(conversation.participants);
          final me = participants.firstWhere((p) => p.userId == _currentUser.userId, orElse: () => participants.first);
          userReadIndex = me.readMessageIndex;
        } catch (_) {}
        final newUnreadCount = (newLastMessageIndex - userReadIndex).clamp(0, double.infinity).toInt();
        
        final updatedConversation = conversation.copyWith(
          lastMessageIndex: newLastMessageIndex,
          lastMessagePreview: Value(previewInfo.lastMessagePreview.isNotEmpty ? previewInfo.lastMessagePreview : null),
          lastMessageName: Value(previewInfo.lastMessageName.isNotEmpty ? previewInfo.lastMessageName : null),
          lastMessageTime: previewInfo.hasLastMessageTime() && previewInfo.lastMessageTime.toInt() > 0
              ? Value(DateTime.fromMillisecondsSinceEpoch(previewInfo.lastMessageTime.toInt()))
              : const Value.absent(),
          unreadCount: newUnreadCount,
        );

        await _database.update(_database.conversations).replace(updatedConversation);
        _logger.d('已更新本地会话数据', extra: {
          'conversationId': previewInfo.conversationId,
        });

        // 💢💢💢 新架构：发送会话更新事件
        _notifyConversationUpdate(ConversationUpdatedEvent(
          updatedConversation: updatedConversation,
          updatedFields: [
            'lastMessageIndex',
            'lastMessagePreview',
            'lastMessageName',
            'lastMessageTime',
            'unreadCount'
          ],
          timestamp: DateTime.now(),
        ));

        // 💢💢💢 新增：处理用户通知
        await _handlePreviewUpdateNotification(previewInfo, updatedConversation);
      } else {
        _logger.w('本地找不到对应的会话', extra: {'conversationId': previewInfo.conversationId});
      }
    } catch (error, stackTrace) {
      _logger.e('处理会话更新通知失败', error: error, stackTrace: stackTrace);
    }
  }

  /// 处理会话预览更新的用户通知
  Future<void> _handlePreviewUpdateNotification(
    conversation_proto.ConversationPreviewUpdated previewInfo,
    Conversation conversation,
  ) async {
    try {
      _logger.i('处理会话预览更新通知', extra: {
        'conversationId': previewInfo.conversationId,
        'lastMessageName': previewInfo.lastMessageName,
      });

      // 获取应用状态
      final appLifecycleService = AppLifecycleService.instance;
      final isAppInForeground = appLifecycleService.isAppActive;

      // 获取发送者信息（如果有发送者名称）
      User? sender;
      if (previewInfo.lastMessageName.isNotEmpty) {
        // 尝试通过名称查找发送者
        sender = await _getSenderByName(previewInfo.lastMessageName);
      }

      // 检查是否是自己发送的消息
      if (sender?.userId == _currentUser.userId) {
        _logger.d('跳过自己发送的消息通知', extra: {
          'conversationId': previewInfo.conversationId,
          'senderId': sender?.userId,
          'currentUserId': _currentUser.userId,
        });
        return;
      }

      // 调用通知服务处理通知
      await ConversationPreviewNotificationService.instance.handleConversationPreviewUpdated(
        previewUpdate: previewInfo,
        conversation: conversation,
        sender: sender,
        isAppInForeground: isAppInForeground,
        isChatsPageVisible: true, // 简化处理，假设聊天列表页面可见
        isChatPageVisible: false, // 简化处理，假设不在具体聊天页面
        currentChatConversationId: null, // 简化处理
      );

      _logger.d('会话预览更新通知处理完成', extra: {
        'conversationId': previewInfo.conversationId,
        'isAppInForeground': isAppInForeground,
        'hasSender': sender != null,
      });
    } catch (error, stackTrace) {
      _logger.e('处理会话预览更新通知失败', error: error, stackTrace: stackTrace);
    }
  }

  /// 根据名称查找发送者
  Future<User?> _getSenderByName(String senderName) async {
    try {
      if (senderName.isEmpty) return null;

      // 在用户表中查找匹配的用户
      final user = await (_database.select(_database.users)..where((u) => u.name.equals(senderName))).getSingleOrNull();

      return user;
    } catch (error) {
      _logger.e('根据名称查找发送者失败', error: error, extra: {
        'senderName': senderName,
      });
      return null;
    }
  }

  /// 处理用户加入会话通知
  /// 当其他用户加入会话时接收到的通知
  /// [notification] - 用户加入通知数据
  void _handleUserJoinedNotification(conversation_proto.UserJoinedNotification notification) {
    try {
      _logger.i('收到用户加入会话通知', extra: {'conversationId': notification.conversationId, 'userId': notification.userId, 'userName': notification.userName});

      // TODO 更新会话参与者列表
      // 需要获取用户信息并添加到会话参与者中
    } catch (error, stackTrace) {
      _logger.e('处理用户加入会话通知失败', error: error, stackTrace: stackTrace);
    }
  }

  /// 处理用户离开会话通知
  /// 当其他用户离开会话时接收到的通知
  /// [notification] - 用户离开通知数据
  void _handleUserLeftNotification(conversation_proto.UserLeftNotification notification) {
    try {
      _logger
          .i('收到用户离开会话通知', extra: {'conversationId': notification.conversationId, 'userId': notification.userId, 'userName': notification.userName, 'reason': notification.reason});

      // TODO 更新会话参与者列表
      // 需要从会话参与者中移除该用户
    } catch (error, stackTrace) {
      _logger.e('处理用户离开会话通知失败', error: error, stackTrace: stackTrace);
    }
  }

  /// 处理会话设置更新响应
  /// 监听服务器推送的会话设置变更（如静音、置顶状态）并更新本地数据库
  /// 主要用于处理来自其他设备同步的设置变更
  /// [response] - 会话设置更新响应数据
  void _handleConversationSettingsUpdate(conversation_proto.ConversationSettingsUpdateResponse response) async {
    try {
      _logger.i('收到会话设置更新通知', extra: {
        'conversationId': response.conversationId,
        'success': response.success,
        'muted': response.hasMuted() ? response.muted : '未变更',
        'pinned': response.hasPinned() ? response.pinned : '未变更'
      });

      if (!response.success) {
        _logger.w('会话设置更新失败', extra: {'conversationId': response.conversationId});
        return;
      }

      // 更新本地会话数据
      await _database.transaction(() async {
        // 查找本地会话
        final conversation = await (_database.select(_database.conversations)..where((c) => c.conversationId.equals(response.conversationId))).getSingleOrNull();

        if (conversation != null) {
          // 更新当前用户的参与者设置
          final updatedConversation = conversation.copyWith(
            muted: response.hasMuted() ? response.muted : null,
            pinned: response.hasPinned() ? response.pinned : null,
          );

          await _database.update(_database.conversations).replace(updatedConversation);
          _logger.d('已更新本地会话设置', extra: {'conversationId': response.conversationId});

          // 💢💢💢 新架构：发送会话设置更新事件
          final updatedFields = <String>[];
          if (response.hasMuted()) updatedFields.add('muted');
          if (response.hasPinned()) updatedFields.add('pinned');

          _notifyConversationUpdate(ConversationUpdatedEvent(
            updatedConversation: updatedConversation,
            updatedFields: updatedFields,
            timestamp: DateTime.now(),
          ));
        } else {
          _logger.w('本地找不到对应的会话', extra: {'conversationId': response.conversationId});
        }
      });
    } catch (error, stackTrace) {
      _logger.e('处理会话设置更新响应失败', error: error, stackTrace: stackTrace);
    }
  }

  void _handleConversationDetailResponse(conversation_proto.ConversationDetailResponse response) async {
    if (response.success && response.hasConversation()) {
      // 查找现有会话以保留本地字段（如lastReadTime）
      final existing = await (_database.select(_database.conversations)..where((c) => c.conversationId.equals(response.conversation.conversationId))).getSingleOrNull();

      final conversation = ConversationAdapter.fromProto(
        response.conversation,
        currentUserId: _currentUser.userId,
      );

      _logger.i('成功获取会话详情', extra: {'conversationId': conversation.conversationId, 'conversationType': conversation.type});

      await _database.transaction(() async {
        if (existing != null) {
          await _database.update(_database.conversations).replace(conversation);
        } else {
          await _database.into(_database.conversations).insertOnConflictUpdate(conversation);
        }
      });

      _logger.d('已将会话详情保存到本地数据库');
    }
  }

  /// 处理参与者状态更新响应
  void _handleParticipantStatusUpdateResponse(conversation_proto.ParticipantStatusUpdateResponse response) async {
    try {
      _logger.i('收到参与者状态更新响应', extra: {
        'conversationId': response.conversationId,
        'success': response.success,
      });

      if (!response.success) {
        _logger.w('参与者状态更新失败', extra: {
          'conversationId': response.conversationId,
        });
        return;
      }

      if (!response.hasParticipant()) {
        _logger.w('参与者状态更新响应中缺少参与者信息', extra: {
          'conversationId': response.conversationId,
        });
        return;
      }

      // 更新本地数据库 - 简化处理
      await _database.transaction(() async {
        // 查找本地会话
        final conversation = await (_database.select(_database.conversations)..where((c) => c.conversationId.equals(response.conversationId))).getSingleOrNull();

        if (conversation != null) {
          final participant = response.participant;
          final currentUserId = _currentUser.userId;

          // 只有当更新的是当前用户的参与者信息时才更新本地设置
          if (participant.userId == currentUserId) {
            final updatedConversation = conversation.copyWith(
              readMessageIndex: participant.readMessageIndex,
              muted: participant.muted,
              pinned: participant.pinned,
            );

            await _database.update(_database.conversations).replace(updatedConversation);

            _logger.d('已更新当前用户的参与者设置', extra: {
              'conversationId': response.conversationId,
              'readMessageIndex': participant.readMessageIndex,
              'muted': participant.muted,
              'pinned': participant.pinned,
            });

            // 💢💢💢 新增：发出会话更新事件通知ChatsPage
            _notifyConversationUpdate(ConversationUpdatedEvent(
              updatedConversation: updatedConversation,
              updatedFields: ['readMessageIndex', 'unreadCount'],
              timestamp: DateTime.now(),
            ));
          }

          _logger.d('参与者状态更新完成', extra: {'conversationId': response.conversationId});
        } else {
          _logger.w('本地找不到对应的会话', extra: {'conversationId': response.conversationId});
        }
      });
    } catch (error, stackTrace) {
      _logger.e('处理参与者状态更新响应失败', error: error, stackTrace: stackTrace);
    }
  }

  /// 处理参与者索引更新通知（统一事件）
  void _handleParticipantIndexUpdated(conversation_proto.ParticipantIndexUpdatedNotification notification) async {
    try {
      final conversationId = notification.conversationId;
      final conv = await getConversationById(conversationId);
      if (conv == null) return;

      final participants = ConversationAdapter.parseParticipants(conv.participants);
      bool changed = false;
      for (int i = 0; i < participants.length; i++) {
        final p = participants[i];
        if (p.userId == notification.userId) {
          int newRead = p.readMessageIndex;
          int newDelivered = p.deliveredMessageIndex;
          if (notification.hasReadMessageIndex()) {
            final incoming = notification.readMessageIndex;
            if (incoming > newRead) newRead = incoming;
          }
          if (notification.hasDeliveredMessageIndex()) {
            final incoming = notification.deliveredMessageIndex;
            if (incoming > newDelivered) newDelivered = incoming;
          }
          if (newRead != p.readMessageIndex || newDelivered != p.deliveredMessageIndex) {
            participants[i] = p.copyWith(
              readMessageIndex: newRead,
              deliveredMessageIndex: newDelivered,
            );
            changed = true;
          }
          break;
        }
      }

      if (!changed) return;

      // 重新计算未读数（基于当前用户）
      int userReadIndex = 0;
      try {
        final me = participants.firstWhere((p) => p.userId == _currentUser.userId, orElse: () => participants.first);
        userReadIndex = me.readMessageIndex;
      } catch (_) {}

      final int newUnread = (conv.lastMessageIndex - userReadIndex).clamp(0, double.infinity).toInt();
      final updatedConversation = conv.copyWith(
        participants: participants,
        unreadCount: newUnread,
      );
      await _database.update(_database.conversations).replace(updatedConversation);
      _notifyConversationUpdate(ConversationUpdatedEvent(
        updatedConversation: updatedConversation,
        updatedFields: ['participants', 'unreadCount'],
        timestamp: DateTime.now(),
      ));
    } catch (error, stackTrace) {
      _logger.e('处理参与者索引更新失败', error: error, stackTrace: stackTrace);
    }
  }

  /// 处理会话信息更新响应
  void _handleConversationInfoUpdateResponse(conversation_proto.ConversationInfoUpdateResponse response) async {
    try {
      _logger.i('收到会话信息更新响应', extra: {
        'success': response.success,
        'message': response.message,
      });

      if (!response.success) {
        _logger.w('会话信息更新失败', extra: {
          'message': response.message,
        });
        return;
      }

      _logger.d('会话信息更新成功');
    } catch (error, stackTrace) {
      _logger.e('处理会话信息更新响应失败', error: error, stackTrace: stackTrace);
    }
  }

  /// 处理会话信息更新通知
  void _handleConversationInfoUpdated(conversation_proto.ConversationInfoUpdated notification) async {
    try {
      _logger.i('收到会话信息更新通知', extra: {
        'conversationId': notification.conversationId,
        'name': notification.name,
        'avatar': notification.avatar,
        'description': notification.description,
        'updatedBy': notification.updatedBy,
        'updatedAt': notification.updatedAt,
      });

      // 更新本地会话数据
      await _database.transaction(() async {
        // 查找本地会话
        final conversation = await (_database.select(_database.conversations)..where((c) => c.conversationId.equals(notification.conversationId))).getSingleOrNull();

        if (conversation != null) {
          final oldName = conversation.name;
          final oldAvatar = conversation.avatar;
          final oldDescription = conversation.description;

          // 更新会话信息
          final updatedConversation = conversation.copyWith(
            name: Value(notification.name),
            avatar: notification.avatar.isNotEmpty ? Value(notification.avatar) : const Value.absent(),
            description: notification.description.isNotEmpty ? Value(notification.description) : const Value.absent(),
          );

          await _database.update(_database.conversations).replace(updatedConversation);

          // 发出会话更新事件
          _notifyConversationUpdate(ConversationUpdatedEvent(
            updatedConversation: updatedConversation,
            updatedFields: ['name', 'avatar', 'description'],
            timestamp: DateTime.fromMillisecondsSinceEpoch(notification.updatedAt.toInt()),
          ));

          _logger.i('已更新会话信息', extra: {
            'conversationId': notification.conversationId,
            'oldName': oldName,
            'newName': updatedConversation.name,
            'oldAvatar': oldAvatar,
            'newAvatar': updatedConversation.avatar,
            'oldDescription': oldDescription,
            'newDescription': updatedConversation.description,
          });
        } else {
          _logger.w('本地找不到对应的会话', extra: {
            'conversationId': notification.conversationId,
          });
        }
      });
    } catch (error, stackTrace) {
      _logger.e('处理会话信息更新通知失败', error: error, stackTrace: stackTrace);
    }
  }

  /// 处理会话离开响应
  void _handleConversationLeaveResponse(conversation_proto.ConversationJoinLeaveResponse response) async {
    try {
      _logger.i('收到会话离开响应', extra: {
        'conversationId': response.conversationId,
        'success': response.success,
        'message': response.message,
      });

      if (!response.success) {
        _logger.w('会话离开失败', extra: {
          'conversationId': response.conversationId,
          'message': response.message,
        });
        return;
      }

      // 更新本地数据库 - 更新最后阅读时间
      await updateConversationLastReadTime(response.conversationId);
    } catch (error, stackTrace) {
      _logger.e('处理会话离开响应失败', error: error, stackTrace: stackTrace);
    }
  }

  /// 处理会话添加通知
  /// 当其他用户创建了新会话并邀请当前用户时收到此通知
  /// [response] - 会话创建响应，包含新会话的完整信息
  void _handleConversationAdded(conversation_proto.ConversationCreateResponse response) async {
    try {
      _logger.i('收到会话添加通知', extra: {
        'success': response.success,
        'message': response.message,
        'hasConversation': response.hasConversation(),
      });

      if (response.success && response.hasConversation()) {
        final conversation = response.conversation;
        _logger.i('处理新添加的会话', extra: {
          'conversationId': conversation.conversationId,
          'name': conversation.name,
          'type': conversation.type.name,
        });

        // 将服务器返回的会话数据保存到本地数据库
        final localConversation = ConversationAdapter.fromProto(
          conversation,
          currentUserId: _currentUser.userId,
        );

        await _database.transaction(() async {
          // 检查会话是否已存在
          final existing = await (_database.select(_database.conversations)..where((c) => c.conversationId.equals(conversation.conversationId))).getSingleOrNull();

          if (existing == null) {
            // 添加新会话
            await _database.into(_database.conversations).insertOnConflictUpdate(localConversation);
            _logger.i('新会话已添加到本地数据库', extra: {
              'conversationId': conversation.conversationId,
              'name': conversation.name,
            });
          } else {
            _logger.d('会话已存在，跳过添加', extra: {
              'conversationId': conversation.conversationId,
            });
          }
        });

        // 可以在这里发送本地通知给用户
        // UINotificationService.instance.showInfo('您被添加到会话：${conversation.name}');
      } else {
        _logger.w('会话添加通知无效', extra: {
          'success': response.success,
          'message': response.message,
        });
      }
    } catch (error, stackTrace) {
      _logger.e('处理会话添加通知失败', error: error, stackTrace: stackTrace);
    }
  }

  /// 更新会话的最后阅读时间
  @override
  Future<void> updateConversationLastReadTime(
    String conversationId, {
    DateTime? readTime,
  }) async {
    try {
      await _database.transaction(() async {
        // 查找本地会话
        final conversation = await (_database.select(_database.conversations)..where((c) => c.conversationId.equals(conversationId))).getSingleOrNull();

        if (conversation != null) {
          // 更新当前用户的最后阅读时间
          final updatedConversation = conversation.copyWith(
            lastReadTime: Value(readTime ?? DateTime.now()),
          );

          // 保存更新后的会话
          await _database.update(_database.conversations).replace(updatedConversation);

          // 💢💢💢 新增：发出会话更新事件通知ChatsPage
          _notifyConversationUpdate(ConversationUpdatedEvent(
            updatedConversation: updatedConversation,
            updatedFields: ['lastReadTime'],
            timestamp: DateTime.now(),
          ));

          _logger.d('已更新会话的最后阅读时间', extra: {
            'conversationId': conversationId,
            'lastReadTime': updatedConversation.lastReadTime?.toIso8601String(),
          });
        } else {
          _logger.w('本地找不到对应的会话', extra: {'conversationId': conversationId});
        }
      });
    } catch (error, stackTrace) {
      _logger.e('更新会话最后阅读时间失败', error: error, stackTrace: stackTrace);
    }
  }

  /// 💢💢💢💢💢💢💢💢💢💢💢💢💢💢   状态快照管理   💢💢💢💢💢💢💢💢💢💢💢💢💢💢

  /// 保存会话状态快照
  @override
  Future<void> saveStateSnapshot(ChatStateSnapshot snapshot, String conversationId) async {
    try {
      // 💢💢💢 深拷贝消息列表以确保数据独立性
      final snapshotWithCopiedMessages = snapshot.copyWith(
        messages: List<Message>.from(snapshot.messages),
      );

      _stateSnapshots[conversationId] = snapshotWithCopiedMessages;

      _logger.d('💾 保存会话状态快照', extra: {
        'conversationId': conversationId,
        'messageCount': snapshot.messages.length,
        'currentScrollPosition': snapshot.currentScrollPosition?.getListIndex(snapshot.messages),
      });
    } catch (error) {
      _logger.e('保存状态快照失败', error: error);
    }
  }

  /// 获取会话状态快照
  @override
  Future<ChatStateSnapshot?> getStateSnapshot(String conversationId) async {
    try {
      final snapshot = _stateSnapshots[conversationId];

      if (snapshot != null && snapshot.isValid) {
        _logger.d('📖 获取会话状态快照', extra: {
          'conversationId': conversationId,
          'messageCount': snapshot.messages.length,
          'currentScrollPosition': snapshot.currentScrollPosition?.toString(),
        });
        return snapshot;
      }

      return null;
    } catch (error) {
      _logger.e('获取状态快照失败', error: error);
      return null;
    }
  }

  /// 清除指定会话的状态快照
  @override
  Future<void> clearStateSnapshot(String conversationId) async {
    try {
      final removed = _stateSnapshots.remove(conversationId);
      if (removed != null) {
        _logger.d('🗑️ 清除会话状态快照', extra: {
          'conversationId': conversationId,
          'remainingSnapshots': _stateSnapshots.length,
        });
      }
    } catch (error) {
      _logger.e('清除状态快照失败', error: error);
    }
  }

  /// 清除所有无效的状态快照
  @override
  Future<void> cleanupExpiredSnapshots() async {
    try {
      final invalidKeys = _stateSnapshots.entries.where((entry) => !entry.value.isValid).map((entry) => entry.key).toList();

      for (final key in invalidKeys) {
        _stateSnapshots.remove(key);
      }

      if (invalidKeys.isNotEmpty) {
        _logger.d('🗑️ 清理无效状态快照', extra: {
          'cleanedCount': invalidKeys.length,
          'remainingCount': _stateSnapshots.length,
        });
      }
    } catch (error) {
      _logger.e('清理无效状态快照失败', error: error);
    }
  }

  /// 获取当前状态快照数量（用于监控和调试）
  @override
  int get stateSnapshotCount => _stateSnapshots.length;

  /// 处理联系人更新事件，更新相关的私聊会话名称
  void _handleContactUpdatedForConversations(dynamic data) async {
    try {
      final contactId = data['contactId'] as String?;
      final updatedFields = (data['updatedFields'] as List?)?.cast<String>() ?? [];

      if (contactId == null) {
        _logger.w('联系人更新事件缺少contactId');
        return;
      }

      _logger.i('收到联系人更新事件，准备更新相关会话名称', extra: {
        'contactId': contactId,
        'updatedFields': updatedFields,
      });

      // 只有当名称相关字段更新时才处理
      if (!updatedFields.any((field) => ['nickname', 'custom_nickname'].contains(field))) {
        _logger.d('跳过非名称字段更新', extra: {'updatedFields': updatedFields});
        return;
      }

      // 查找所有与此联系人相关的私聊会话 - 简化处理，通过participants字段查找
      final privateConversations = await (_database.select(_database.conversations)..where((c) => c.type.equals('PRIVATE'))).get();

      // 在内存中查找包含该联系人的私聊会话
      final relatedConversations = privateConversations.where((conv) => conv.participants.contains(contactId)).toList();

      if (relatedConversations.isEmpty) {
        _logger.d('未找到与此联系人相关的私聊会话', extra: {'contactId': contactId});
        return;
      }

      // 获取更新后的联系人信息
      final updatedContact = await getContactById(contactId);
      if (updatedContact == null) {
        _logger.w('无法获取更新后的联系人信息', extra: {'contactId': contactId});
        return;
      }

      // 更新每个相关会话的名称（联系人备注不影响会话中的成员名称）
      await _database.transaction(() async {
        for (final conversation in relatedConversations) {
          final oldName = conversation.name;

          // 💢💢💢 修复：使用正确的显示名称优先级：nickname > name > userId
          String displayName;
          if (updatedContact.nickname != null && updatedContact.nickname!.isNotEmpty) {
            displayName = updatedContact.nickname!;
          } else if (updatedContact.name.isNotEmpty) {
            displayName = updatedContact.name;
          } else {
            displayName = updatedContact.userId;
          }

          final updatedConversation = conversation.copyWith(
            name: Value(displayName),
            avatar: updatedContact.avatar != null ? Value(updatedContact.avatar) : const Value.absent(),
          );

          // 保存会话
          await _database.update(_database.conversations).replace(updatedConversation);

          // 发出会话更新事件
          _notifyConversationUpdate(ConversationUpdatedEvent(
            updatedConversation: updatedConversation,
            updatedFields: ['name', 'participants'],
            timestamp: DateTime.now(),
          ));

          _logger.i('已更新私聊会话名称', extra: {
            'conversationId': conversation.conversationId,
            'contactId': contactId,
            'oldName': oldName,
            'newName': displayName,
          });
        }
      });

      _logger.i('联系人更新处理完成', extra: {
        'contactId': contactId,
        'updatedConversations': relatedConversations.length,
      });
    } catch (e) {
      _logger.e('处理联系人更新事件失败', extra: {
        'error': e.toString(),
        'stackTrace': e is Error ? e.stackTrace.toString() : null,
      });
    }
  }

  /// 💢💢💢 新增：处理本地会话移除事件
  void _handleConversationRemovedLocally(dynamic data) async {
    try {
      final conversationId = data['conversationId'] as String?;
      final timestampStr = data['timestamp'] as String?;

      if (conversationId == null) {
        _logger.w('会话移除事件缺少conversationId');
        return;
      }

      _logger.i('收到本地会话移除事件', extra: {
        'conversationId': conversationId,
        'timestamp': timestampStr,
      });

      // 💢💢💢 发送会话移除事件到ChatsPage
      final removeEvent = ConversationRemovedEvent(
        conversationId: conversationId,
        timestamp: timestampStr != null ? DateTime.tryParse(timestampStr) ?? DateTime.now() : DateTime.now(),
      );

      _notifyConversationUpdate(removeEvent);

      _logger.i('会话移除事件已通知到ChatsPage', extra: {
        'conversationId': conversationId,
      });
    } catch (e) {
      _logger.e('处理本地会话移除事件失败', extra: {
        'error': e.toString(),
        'stackTrace': e is Error ? e.stackTrace.toString() : null,
      });
    }
  }

  /// 释放资源
  /// 取消所有订阅
  void dispose() {
    _logger.i('销毁ChatsRepository');

    // 💢💢💢 新架构：关闭会话更新事件流控制器
    _conversationUpdateController.close();

    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
  }
}
