# 聊天功能优化计划

本文档详细描述了对聊天功能的优化计划，主要针对 HomePage 和 ChatsPage 在收到会话更新通知时全部重绘的问题。

## 项目概述

- 这是一个模仿 Telegram 的 Flutter 项目
- 使用 Cubit 作为状态管理
- 使用 Isar 作为数据库
- 使用 Socket.io + Proto 与后端 Next.js 通讯
- 项目架构为：页面(UI层) → Cubit(业务逻辑层) → Repository(数据层)

## 优化计划

### 第一步：优化会话管理流程

#### 1.1 扩展 ChatRepository 接口

```dart
// lib/features/chat/domain/repositories/chat_repository.dart

import 'package:cc/core/database/models/conversation.dart';
import 'package:cc/core/database/models/user.dart';
import 'package:cc/features/chat/domain/entities/conversation_update_event.dart';

abstract class ChatRepository {
  // 现有方法...
  
  /// 加载会话列表
  ///
  /// 从本地数据库加载所有会话
  Future<List<Conversation>> loadConversations();
  
  /// 同步会话列表
  ///
  /// 从服务器获取最新会话数据并更新本地数据库
  /// 使用 SyncConversationsRequest 和 ConversationCollection proto
  Future<List<Conversation>> syncConversations();
  
  /// 监听会话更新
  ///
  /// 返回一个流，当有会话更新时发出事件
  /// 基于 ConversationUpdateNotification proto
  Stream<ConversationUpdateEvent> listenForConversationUpdates();
  
  /// 根据标签过滤会话
  ///
  /// 根据标签类型过滤会话列表
  Future<List<Conversation>> filterConversationsByTab(int tabIndex);
  
  /// 搜索会话
  ///
  /// 根据搜索关键词搜索会话
  Future<List<Conversation>> searchConversations(String query, List<User> contacts);
  
  /// 更新会话设置
  ///
  /// 更新会话的静音或置顶状态
  /// 使用 ConversationSettingsUpdateRequest proto
  Future<bool> updateConversationSettings(String conversationId, {bool? muted, bool? pinned});
  
  /// 标记会话为已读
  ///
  /// 使用 ConversationMarkReadRequest proto
  Future<int> markConversationAsRead(String conversationId, {String? messageId});
  
  /// 创建新会话
  ///
  /// 使用 ConversationCreateRequest proto
  Future<Conversation> createConversation({
    String? name,
    String? avatar,
    ConversationType type,
    List<String>? participantIds,
    String? contactUserId,
  });
}
```

#### 1.2 实现 ChatRepositoryImpl

```dart
// lib/features/chat/data/repositories/chat_repository_impl.dart

import 'dart:async';
import 'package:cc/core/database/models/conversation.dart';
import 'package:cc/core/database/models/user.dart';
import 'package:cc/core/services/communication_service.dart';
import 'package:cc/core/database/database_service.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/proto/generated/conversation.pb.dart';
import 'package:cc/features/chat/domain/entities/conversation_update_event.dart';
import 'package:cc/features/chat/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final CommunicationService _communicationService;
  final DatabaseService _databaseService;
  final LogService _logger = LogService.instance;
  final CurrentUserProto _currentUser;
  
  final _conversationUpdateController = StreamController<ConversationUpdateEvent>.broadcast();
  bool _isListeningForUpdates = false;
  
  ChatRepositoryImpl({
    required CommunicationService communicationService,
    required DatabaseService databaseService,
    required CurrentUserProto currentUserProto,
  }) : 
    _communicationService = communicationService,
    _databaseService = databaseService,
    _currentUser = currentUserProto {
    _setupSocketListeners();
  }
  
  void _setupSocketListeners() {
    if (_isListeningForUpdates) return;
    
    // 监听会话更新通知
    _communicationService.on('conversation_update', (data) {
      try {
        final notification = ConversationUpdateNotification.fromJson(data);
        
        // 更新本地数据库
        _updateConversationInDatabase(notification);
        
        // 发出更新事件
        _conversationUpdateController.add(
          ConversationUpdateEvent(
            type: ConversationUpdateType.update,
            conversationId: notification.conversationId,
            lastMessagePreview: notification.lastMessagePreview,
            lastMessageTime: DateTime.fromMillisecondsSinceEpoch(notification.lastMessageTime),
            unreadCount: notification.unreadCount,
            senderId: notification.senderId,
            senderName: notification.senderName,
          ),
        );
      } catch (e) {
        _logger.e('处理会话更新通知失败', error: e);
      }
    });
    
    // 监听新会话创建
    _communicationService.on('new_conversation', (data) {
      try {
        final conversationProto = ConversationProto.fromJson(data);
        final conversation = _convertProtoToConversation(conversationProto);
        
        // 保存到数据库
        _databaseService.saveConversation(conversation);
        
        // 发出更新事件
        _conversationUpdateController.add(
          ConversationUpdateEvent(
            type: ConversationUpdateType.add,
            conversationId: conversation.conversationId,
            conversation: conversation,
          ),
        );
      } catch (e) {
        _logger.e('处理新会话通知失败', error: e);
      }
    });
    
    // 监听会话删除
    _communicationService.on('delete_conversation', (data) {
      try {
        final conversationId = data['conversation_id'];
        
        // 从数据库删除
        _databaseService.deleteConversation(conversationId);
        
        // 发出更新事件
        _conversationUpdateController.add(
          ConversationUpdateEvent(
            type: ConversationUpdateType.remove,
            conversationId: conversationId,
          ),
        );
      } catch (e) {
        _logger.e('处理会话删除通知失败', error: e);
      }
    });
    
    // 监听会话设置更新
    _communicationService.on('conversation_settings_update', (data) {
      try {
        final response = ConversationSettingsUpdateResponse.fromJson(data);
        
        // 更新数据库
        _updateConversationSettings(
          response.conversationId,
          muted: response.muted,
          pinned: response.pinned,
        );
        
        // 发出更新事件
        _conversationUpdateController.add(
          ConversationUpdateEvent(
            type: ConversationUpdateType.update,
            conversationId: response.conversationId,
          ),
        );
      } catch (e) {
        _logger.e('处理会话设置更新通知失败', error: e);
      }
    });
    
    _isListeningForUpdates = true;
  }
  
  @override
  Future<List<Conversation>> loadConversations() async {
    try {
      _logger.d('从数据库加载会话');
      final conversations = await _databaseService.getConversations();
      return _sortConversationsByTime(conversations);
    } catch (e) {
      _logger.e('加载会话失败', error: e);
      throw Exception('加载会话失败: $e');
    }
  }
  
  @override
  Future<List<Conversation>> syncConversations() async {
    try {
      _logger.d('同步会话');
      
      // 创建同步请求
      final request = SyncConversationsRequest()
        ..lastSyncTime = _getLastSyncTime();
      
      // 发送请求到服务器
      final response = await _communicationService.emitWithAck(
        'sync_conversations',
        request.toProto3Json(),
      );
      
      // 解析响应
      final collection = ConversationCollection.fromJson(response);
      
      // 转换并保存到数据库
      final conversations = <Conversation>[];
      for (final proto in collection.conversations) {
        final conversation = _convertProtoToConversation(proto);
        conversations.add(conversation);
      }
      
      await _databaseService.saveConversations(conversations);
      
      // 更新最后同步时间
      _updateLastSyncTime();
      
      // 返回最新的会话列表
      return loadConversations();
    } catch (e) {
      _logger.e('同步会话失败', error: e);
      throw Exception('同步会话失败: $e');
    }
  }
  
  @override
  Stream<ConversationUpdateEvent> listenForConversationUpdates() {
    return _conversationUpdateController.stream;
  }
  
  @override
  Future<List<Conversation>> filterConversationsByTab(int tabIndex) async {
    final conversations = await loadConversations();
    
    switch (tabIndex) {
      case 0: // 全部会话
        return conversations;
      case 1: // 私聊
        return conversations
            .where((c) => c.type == ConversationType.private)
            .toList();
      case 2: // 群组
        return conversations
            .where((c) => c.type == ConversationType.group)
            .toList();
      case 3: // 频道
        return conversations
            .where((c) => c.type == ConversationType.channel)
            .toList();
      case 4: // 未读
        return conversations.where((c) => c.unreadCount > 0).toList();
      default:
        return conversations;
    }
  }
  
  @override
  Future<List<Conversation>> searchConversations(String query, List<User> contacts) async {
    final conversations = await loadConversations();
    final lowercaseQuery = query.toLowerCase();
    
    return conversations.where((conversation) {
      // 查找会话对应的联系人
      final contact = contacts.firstWhere(
        (c) => c.userId == conversation.contactUserId,
        orElse: () => User()..name = '',
      );
      
      // 检查联系人名称、拼音和会话最后消息是否包含搜索关键词
      return contact.name.toLowerCase().contains(lowercaseQuery) ||
          (contact.pinyin?.toLowerCase().contains(lowercaseQuery) ?? false) ||
          (conversation.lastMessagePreview?.toLowerCase().contains(lowercaseQuery) ?? false);
    }).toList();
  }
  
  @override
  Future<bool> updateConversationSettings(String conversationId, {bool? muted, bool? pinned}) async {
    try {
      // 创建请求
      final request = ConversationSettingsUpdateRequest()
        ..conversationId = conversationId;
      
      if (muted != null) request.muted = muted;
      if (pinned != null) request.pinned = pinned;
      
      // 发送请求
      final response = await _communicationService.emitWithAck(
        'update_conversation_settings',
        request.toProto3Json(),
      );
      
      // 解析响应
      final updateResponse = ConversationSettingsUpdateResponse.fromJson(response);
      
      if (updateResponse.success) {
        // 更新本地数据库
        await _updateConversationSettings(
          conversationId,
          muted: muted,
          pinned: pinned,
        );
        
        return true;
      }
      
      return false;
    } catch (e) {
      _logger.e('更新会话设置失败', error: e);
      throw Exception('更新会话设置失败: $e');
    }
  }
  
  @override
  Future<int> markConversationAsRead(String conversationId, {String? messageId}) async {
    try {
      // 创建请求
      final request = ConversationMarkReadRequest()
        ..conversationId = conversationId
        ..userId = _currentUser.userId
        ..readAt = DateTime.now().millisecondsSinceEpoch;
      
      if (messageId != null) {
        request.messageId = messageId;
      }
      
      // 发送请求
      final response = await _communicationService.emitWithAck(
        'mark_conversation_read',
        request.toProto3Json(),
      );
      
      // 解析响应
      final markReadResponse = ConversationMarkReadResponse.fromJson(response);
      
      if (markReadResponse.success) {
        // 更新本地数据库
        await _databaseService.markConversationAsRead(conversationId);
        
        return markReadResponse.remainingUnread;
      }
      
      return -1;
    } catch (e) {
      _logger.e('标记会话为已读失败', error: e);
      throw Exception('标记会话为已读失败: $e');
    }
  }
  
  @override
  Future<Conversation> createConversation({
    String? name,
    String? avatar,
    required ConversationType type,
    List<String>? participantIds,
    String? contactUserId,
  }) async {
    try {
      // 创建请求
      final request = ConversationCreateRequest()
        ..type = type;
      
      if (name != null) request.name = name;
      if (avatar != null) request.avatar = avatar;
      if (participantIds != null) request.participantIds.addAll(participantIds);
      if (contactUserId != null) request.contactUserId = contactUserId;
      
      // 发送请求
      final response = await _communicationService.emitWithAck(
        'create_conversation',
        request.toProto3Json(),
      );
      
      // 解析响应
      final createResponse = ConversationCreateResponse.fromJson(response);
      
      if (createResponse.success) {
        // 转换并保存到数据库
        final conversation = _convertProtoToConversation(createResponse.conversation);
        await _databaseService.saveConversation(conversation);
        
        return conversation;
      }
      
      throw Exception('创建会话失败: ${createResponse.message}');
    } catch (e) {
      _logger.e('创建会话失败', error: e);
      throw Exception('创建会话失败: $e');
    }
  }
  
  // 辅助方法
  
  Future<void> _updateConversationInDatabase(ConversationUpdateNotification notification) async {
    try {
      // 从数据库获取会话
      final conversation = await _databaseService.getConversationById(notification.conversationId);
      
      if (conversation != null) {
        // 更新会话
        conversation.lastMessagePreview = notification.lastMessagePreview;
        conversation.lastMessageTime = DateTime.fromMillisecondsSinceEpoch(notification.lastMessageTime);
        conversation.unreadCount = notification.unreadCount;
        
        // 保存回数据库
        await _databaseService.saveConversation(conversation);
      }
    } catch (e) {
      _logger.e('更新数据库中的会话失败', error: e);
    }
  }
  
  Future<void> _updateConversationSettings(String conversationId, {bool? muted, bool? pinned}) async {
    try {
      // 从数据库获取会话
      final conversation = await _databaseService.getConversationById(conversationId);
      
      if (conversation != null) {
        // 更新设置
        if (muted != null) conversation.isMuted = muted;
        if (pinned != null) conversation.isPinned = pinned;
        
        // 保存回数据库
        await _databaseService.saveConversation(conversation);
      }
    } catch (e) {
      _logger.e('更新会话设置失败', error: e);
    }
  }
  
  Conversation _convertProtoToConversation(ConversationProto proto) {
    final conversation = Conversation()
      ..conversationId = proto.conversationId
      ..name = proto.name
      ..avatar = proto.avatar
      ..type = _convertProtoType(proto.type)
      ..createdAt = DateTime.fromMillisecondsSinceEpoch(proto.createdAt)
      ..lastMessageTime = proto.lastMessageTime > 0 
          ? DateTime.fromMillisecondsSinceEpoch(proto.lastMessageTime)
          : null
      ..lastMessagePreview = proto.lastMessagePreview
      ..lastMessageName = proto.lastMessageName
      ..unreadCount = proto.unreadCount
      ..contactUserId = proto.contactUserId
      ..isMuted = proto.muted
      ..isPinned = proto.pinned;
    
    return conversation;
  }
  
  ConversationType _convertProtoType(cc.ConversationType protoType) {
    switch (protoType) {
      case cc.ConversationType.private:
        return ConversationType.private;
      case cc.ConversationType.group:
        return ConversationType.group;
      case cc.ConversationType.channel:
        return ConversationType.channel;
      default:
        return ConversationType.private;
    }
  }
  
  List<Conversation> _sortConversationsByTime(List<Conversation> conversations) {
    // 分离置顶和非置顶会话
    final pinnedConversations = conversations.where((c) => c.isPinned).toList();
    final unpinnedConversations = conversations.where((c) => !c.isPinned).toList();
    
    // 排序逻辑
    final sortByTime = (Conversation a, Conversation b) {
      if (a.lastMessageTime == null && b.lastMessageTime == null) {
        return b.createdAt.compareTo(a.createdAt);
      } else if (a.lastMessageTime == null) {
        return 1;
      } else if (b.lastMessageTime == null) {
        return -1;
      }
      return b.lastMessageTime!.compareTo(a.lastMessageTime!);
    };
    
    // 分别排序
    pinnedConversations.sort(sortByTime);
    unpinnedConversations.sort(sortByTime);
    
    // 合并两个列表，置顶会话在前面
    return [...pinnedConversations, ...unpinnedConversations];
  }
  
  int _getLastSyncTime() {
    // 从本地存储获取最后同步时间
    // 如果没有，返回一个较早的时间
    return DateTime.now().subtract(const Duration(days: 30)).millisecondsSinceEpoch;
  }
  
  void _updateLastSyncTime() {
    // 将当前时间保存为最后同步时间
    final now = DateTime.now().millisecondsSinceEpoch;
    // 保存到本地存储
  }
  
  void dispose() {
    _conversationUpdateController.close();
  }
}
```

#### 1.3 定义 ConversationUpdateEvent 类

```dart
// lib/features/chat/domain/entities/conversation_update_event.dart

import 'package:cc/core/database/models/conversation.dart';

enum ConversationUpdateType {
  add,
  update,
  remove,
}

class ConversationUpdateEvent {
  final ConversationUpdateType type;
  final String conversationId;
  final Conversation? conversation;
  final String? lastMessagePreview;
  final DateTime? lastMessageTime;
  final int? unreadCount;
  final String? senderId;
  final String? senderName;
  
  ConversationUpdateEvent({
    required this.type,
    required this.conversationId,
    this.conversation,
    this.lastMessagePreview,
    this.lastMessageTime,
    this.unreadCount,
    this.senderId,
    this.senderName,
  });
}
```

#### 1.4 修改 HomeCubit

```dart
// lib/features/home/presentation/cubit/home_cubit.dart

// 搜索会话
void searchConversations(String query) async {
  _logger.d('搜索会话: $query');
  
  try {
    // 更新搜索关键词
    emit(state.copyWith(searchQuery: query));
    
    if (query.isEmpty) {
      // 如果搜索关键词为空，则根据当前选中的标签过滤会话
      _filterConversationsByTab(state.selectedTabIndex);
      return;
    }
    
    // 使用仓库方法搜索会话
    final filteredList = await _chatRepository.searchConversations(query, state.contacts);
    
    emit(state.copyWith(
      filteredConversations: filteredList,
    ));
  } catch (e) {
    _logger.e('搜索会话出错', error: e);
    // 如果搜索失败，则显示所有会话
    _filterConversationsByTab(state.selectedTabIndex);
  }
}

// 切换标签
void switchTab(int tabIndex) async {
  if (state.selectedTabIndex == tabIndex) return;
  
  emit(state.copyWith(selectedTabIndex: tabIndex));
  _filterConversationsByTab(tabIndex);
}

// 根据标签过滤会话
void _filterConversationsByTab(int tabIndex) async {
  try {
    final filteredList = await _chatRepository.filterConversationsByTab(tabIndex);
    emit(state.copyWith(
      filteredConversations: filteredList,
    ));
  } catch (e) {
    _logger.e('过滤会话失败', error: e);
    emit(state.copyWith(
      errorMessage: '过滤会话失败: ${e.toString()}',
    ));
  }
}
```

#### 1.5 更新 HomeState

```dart
// lib/features/home/presentation/cubit/home_state.dart

class HomeState {
  // 现有字段...
  
  final List<Conversation> conversations;
  final List<Conversation> filteredConversations;
  final List<User> contacts;
  final int selectedTabIndex;
  final String searchQuery;
  final List<String> updatedConversationIds;
  final List<String> removedConversationIds;
  
  // 网络状态相关
  final bool isConnected;
  final NetworkStatus networkStatus;
  final DateTime? lastConnectionTime;
  final String? connectionErrorMessage;
  
  // 构造函数和 copyWith 方法...
}
```

#### 1.6 测试修改

```dart
// test/features/chat/data/repositories/chat_repository_impl_test.dart

void main() {
  group('ChatRepositoryImpl', () {
    late ChatRepositoryImpl repository;
    late MockCommunicationService mockCommunicationService;
    late MockDatabaseService mockDatabaseService;
    late MockCurrentUserProto mockCurrentUser;
    
    setUp(() {
      mockCommunicationService = MockCommunicationService();
      mockDatabaseService = MockDatabaseService();
      mockCurrentUser = MockCurrentUserProto();
      
      when(mockCurrentUser.userId).thenReturn('user123');
      
      repository = ChatRepositoryImpl(
        communicationService: mockCommunicationService,
        databaseService: mockDatabaseService,
        currentUserProto: mockCurrentUser,
      );
    });
    
    test('loadConversations should return sorted conversations from database', () async {
      // 设置模拟行为
      when(mockDatabaseService.getConversations()).thenAnswer((_) async => [
        Conversation()..conversationId = 'conv1'..isPinned = true..lastMessageTime = DateTime.now(),
        Conversation()..conversationId = 'conv2'..isPinned = false..lastMessageTime = DateTime.now().subtract(Duration(hours: 1)),
      ]);
      
      // 调用方法
      final result = await repository.loadConversations();
      
      // 验证结果
      expect(result.length, 2);
      expect(result[0].conversationId, 'conv1'); // 置顶会话应该在前面
      verify(mockDatabaseService.getConversations()).called(1);
    });
    
    // 更多测试...
  });
}
```

### 第二步：优化 UI 层

#### 2.1 修改 ChatsPage

1. 使用 `SliverList` 替代 `AnimatedList`
2. 优化 `BlocBuilder` 的 `buildWhen` 条件
3. 移除不必要的状态管理代码

#### 2.2 优化 ConversationItem 组件

1. 使用 `const` 构造函数
2. 添加 `RepaintBoundary` 隔离重绘区域
3. 实现不同类型会话的显示逻辑

### 第三步：优化性能和用户体验

#### 3.1 实现分页加载

1. 修改 Repository 接口，添加分页支持
2. 更新 Cubit 以支持分页加载
3. 修改 UI 以显示加载状态和支持上拉加载更多

#### 3.2 优化网络状态管理

1. 完善网络状态监听
2. 添加网络状态指示器
3. 实现离线模式支持

## 实施计划

1. 先完成第一步，建立基础架构
2. 测试第一步的修改，确保会话管理流程正常工作
3. 实施第二步，优化 UI 层
4. 测试第二步的修改，确保 UI 渲染正常
5. 实施第三步，优化性能和用户体验
6. 全面测试，确保整个流程正常工作

## 预期效果

1. 减少不必要的 UI 重建
2. 提高应用响应速度
3. 改善用户体验
4. 降低内存和 CPU 使用率
