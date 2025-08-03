import 'dart:convert';
import 'package:cc/core/utils/auth_debug_utils.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/services/secure_storage_service.dart';
import 'package:cc/core/services/enhanced_token_manager.dart';
import 'package:cc/core/database/database_initializer.dart';
import 'package:cc/core/database/drift_database.dart';

/// 调试命令集合
/// 提供各种调试功能的快捷命令
class DebugCommands {
  static final _logger = LogService.instance;

  /// Helper method to extract text from message content JSON
  static String _getTextFromMessage(Message message) {
    try {
      if (message.content != null) {
        final content = jsonDecode(message.content!);
        return content['text'] ?? '';
      }
    } catch (e) {
      // JSON parsing failed
    }
    return '';
  }

  /// 完整的认证状态诊断
  /// 建议在遇到401错误时调用此方法
  static Future<void> diagnoseAuthIssue() async {
    _logger.i('🚨 开始诊断认证问题...');

    // 1. 检查基本认证信息
    await AuthDebugUtils.checkCurrentAuth();

    // 2. 检查Token可用性
    await AuthDebugUtils.checkTokenAvailability();

    // 3. 验证Token格式
    await AuthDebugUtils.validateTokenFormats();

    // 4. 提供修复建议
    await AuthDebugUtils.suggestFixes();

    _logger.i('🚨 认证问题诊断完成');
  }

  /// 快速检查当前用户信息
  static Future<void> whoAmI() async {
    await AuthDebugUtils.checkCurrentAuth();
  }

  /// 检查Token可用性
  static Future<void> checkTokenReady() async {
    await AuthDebugUtils.checkTokenAvailability();
  }

  /// 🚨 快速认证检查和修复
  static Future<void> quickAuthCheck() async {
    _logger.i('🚀 === 快速认证检查 === 🚀');

    try {
      await AuthDebugUtils.checkCurrentAuth();

      _logger.i('🔧 使用新的多Token认证系统:', extra: {
        'info': '现在使用Access Token, Refresh Token, Socket Token三种token',
        'note': '如果遇到401错误，请检查后端是否支持新的多Token验证',
        'suggestion': '使用 DebugCommands.fixTokenSync() 来同步Token',
      });
    } catch (error) {
      _logger.e('快速认证检查失败', error: error);
    }
  }

  /// 🔧 立即修复Token同步问题
  /// 自动获取Token并设置到所有服务
  static Future<void> fixTokenSync() async {
    _logger.i('🔧 === 立即修复Token同步 === 🔧');

    try {
      final tokenManager = EnhancedTokenManager.instance;
      final bestToken = await tokenManager.getApiToken();

      if (bestToken == null) {
        _logger.e('❌ 无法获取可用Token，请先登录');
        return;
      }

      // 注意：Token同步现在由各服务自行管理
      
      _logger.i('✅ Token状态已检查完成！(使用新多Token系统)');
    } catch (error) {
      _logger.e('Token同步修复失败', error: error);
    }
  }

  /// 🔍 详细Token状态诊断
  static Future<void> diagnoseTokenStatus() async {
    try {
      _logger.i('=== 🔍 Token状态详细诊断 ===');

      final now = DateTime.now();
      final secureStorage = SecureStorageService();

      // 移除Access Token相关代码，现在只使用Refresh Token + Socket Token

      // Refresh Token状态
      final refreshToken = await secureStorage.getRefreshToken();
      final refreshExpire = await secureStorage.getRefreshTokenExpireTime();

      if (refreshToken != null && refreshExpire != null) {
        final timeUntilExpiry = refreshExpire.difference(now);
        final isExpired = now.isAfter(refreshExpire);

        _logger.i('🔄 Refresh Token状态', extra: {
          'exists': true,
          'length': refreshToken.length,
          'expiresAt': refreshExpire.toIso8601String(),
          'isExpired': isExpired,
          'timeUntilExpiry': isExpired
              ? '已过期 ${now.difference(refreshExpire).inDays} 天'
              : '还有 ${timeUntilExpiry.inDays} 天',
        });
      } else {
        _logger.w('🔄 Refresh Token', extra: {
          'token': refreshToken != null ? 'exists' : 'missing',
          'expireTime': refreshExpire != null
              ? refreshExpire.toIso8601String()
              : 'missing',
        });
      }

      // Socket Token状态
      final socketToken = await secureStorage.getSocketToken();
      final socketExpire = await secureStorage.getSocketTokenExpireTime();

      if (socketToken != null && socketExpire != null) {
        final timeUntilExpiry = socketExpire.difference(now);
        final isExpired = now.isAfter(socketExpire);

        _logger.i('🔌 Socket Token状态', extra: {
          'exists': true,
          'length': socketToken.length,
          'expiresAt': socketExpire.toIso8601String(),
          'isExpired': isExpired,
          'timeUntilExpiry': isExpired
              ? '已过期 ${now.difference(socketExpire).inDays} 天'
              : '还有 ${timeUntilExpiry.inDays} 天',
        });
      } else {
        _logger.w('🔌 Socket Token', extra: {
          'token': socketToken != null ? 'exists' : 'missing',
          'expireTime':
              socketExpire != null ? socketExpire.toIso8601String() : 'missing',
        });
      }

      // 检查Token刷新条件
      final tokenManager = EnhancedTokenManager.instance;
      final tokenStatus = await tokenManager.getTokenStatus();
      _logger.i('🔧 Token管理器状态', extra: {
        'refreshTimerActive': tokenStatus['refreshTimer']?['active'] ?? false,
        'isRefreshing': tokenStatus['refreshTimer']?['isRefreshing'] ?? false,
      });

      _logger.i('=== Token状态诊断完成 ===');
    } catch (error) {
      _logger.e('Token状态诊断失败', error: error, stackTrace: StackTrace.current);
    }
  }

  /// 🔍 用户信息完整性诊断 - 新增！
  static Future<void> diagnoseUserInfo() async {
    try {
      _logger.i('=== 🔍 用户信息完整性诊断 ===');

      final secureStorage = SecureStorageService();

      // 1. 检查安全存储中的用户信息
      _logger.i('📱 安全存储检查...');
      final userId = await secureStorage.read('user_id');
      final userInfo = await secureStorage.readObject('user_info');
      final currentUser = await secureStorage.readUserCredentials();

      _logger.i('🔐 安全存储用户数据', extra: {
        'userId': userId,
        'userInfoExists': userInfo != null,
        'currentUserExists': currentUser != null,
        'userInfoKeys': userInfo?.keys.toList() ?? [],
      });

      if (currentUser != null) {
        _logger.i('👤 完整用户对象字段', extra: {
          'userId': currentUser.userId,
          'name': currentUser.name,
          'phone': currentUser.phone,
          'email': currentUser.email,
          'avatar': currentUser.avatar,
          'status': currentUser.status,
          'lastLoginTime': currentUser.lastLoginTime?.toIso8601String(),
        });
      }

      // 2. 检查数据库中的用户信息
      _logger.i('🗄️ 数据库检查...');
      if (DatabaseInitializer.isInitialized) {
        _logger.i('💾 数据库状态', extra: {
          'databaseInitialized': true,
          'currentUserId': DatabaseInitializer.currentUser?.userId,
        });
      } else {
        _logger.w('数据库未初始化');
      }

      // 3. 字段一致性检查
      if (currentUser != null && userInfo != null) {
        final missingFields = <String>[];
        final inconsistentFields = <String>[];

        // 检查必需字段
        if (currentUser.userId.isEmpty) missingFields.add('userId');
        if (currentUser.name.isEmpty) missingFields.add('name');

        // 检查字段一致性
        if (userInfo['userId'] != currentUser.userId) {
          inconsistentFields.add('userId');
        }
        if (userInfo['name'] != currentUser.name) {
          inconsistentFields.add('name');
        }
        if (userInfo['phone'] != currentUser.phone) {
          inconsistentFields.add('phone');
        }
        if (userInfo['email'] != currentUser.email) {
          inconsistentFields.add('email');
        }

        _logger.i('🔍 字段一致性检查', extra: {
          'missingFields': missingFields,
          'inconsistentFields': inconsistentFields,
          'isComplete': missingFields.isEmpty && inconsistentFields.isEmpty,
        });
      }

      _logger.i('=== 用户信息诊断完成 ===');
    } catch (error) {
      _logger.e('用户信息诊断失败', error: error, stackTrace: StackTrace.current);
    }
  }

  /// 🔍 测试消息排序逻辑 - 新增！
  static Future<void> testMessageSorting() async {
    try {
      _logger.i('=== 🔍 消息排序测试开始 ===');

      // 创建测试消息数据
      final now = DateTime.now();
      final testMessages = <Message>[
        // 创建不同时间的消息进行排序测试
        Message( 
          messageId: 'msg_1',
          conversationId: 'test_conv',
          senderId: 'test_user',
          senderName: 'Test User',
          senderAvatar: null,
          // senderRoleId: 0, // 字段已移除
          createdAt: now.subtract(const Duration(minutes: 5)),
          updatedAt: null,
          messageIndex: 100,
          messageType: 'TEXT',
          messageStatus: 'SENT',
          quotedMessageId: null,
          repliedToMessageId: null,
          forwardedFromConversationId: null,
          forwardedFromMessageId: null,
          isEdited: false,
          editedAt: null,
          isPinned: false,
          reactions: null,
          tags: null,
          content: '{"text": "消息1（最早）"}',
        ),
        Message( 
          messageId: 'msg_2',
          conversationId: 'test_conv',
          senderId: 'test_user',
          senderName: 'Test User',
          senderAvatar: null,
          // senderRoleId: 0, // 字段已移除
          createdAt: now.subtract(const Duration(minutes: 4)),
          updatedAt: null,
          messageIndex: 200,
          messageType: 'TEXT',
          messageStatus: 'SENT',
          quotedMessageId: null,
          repliedToMessageId: null,
          forwardedFromConversationId: null,
          forwardedFromMessageId: null,
          isEdited: false,
          editedAt: null,
          isPinned: false,
          reactions: null,
          tags: null,
          content: '{"text": "消息2"}',
        ),
        Message( 
          messageId: 'msg_3',
          conversationId: 'test_conv',
          senderId: 'test_user',
          senderName: 'Test User',
          senderAvatar: null,
          // senderRoleId: 0, // 字段已移除
          createdAt: now.subtract(const Duration(minutes: 3)),
          updatedAt: null,
          messageIndex: 300,
          messageType: 'TEXT',
          messageStatus: 'SENT',
          quotedMessageId: null,
          repliedToMessageId: null,
          forwardedFromConversationId: null,
          forwardedFromMessageId: null,
          isEdited: false,
          editedAt: null,
          isPinned: false,
          reactions: null,
          tags: null,
          content: '{"text": "消息3"}',
        ),
        Message( 
          messageId: 'msg_4',
          conversationId: 'test_conv',
          senderId: 'test_user',
          senderName: 'Test User',
          senderAvatar: null,
          // senderRoleId: 0, // 字段已移除
          createdAt: now.subtract(const Duration(minutes: 2)),
          updatedAt: null,
          messageIndex: 400,
          messageType: 'TEXT',
          messageStatus: 'SENT',
          quotedMessageId: null,
          repliedToMessageId: null,
          forwardedFromConversationId: null,
          forwardedFromMessageId: null,
          isEdited: false,
          editedAt: null,
          isPinned: false,
          reactions: null,
          tags: null,
          content: '{"text": "消息4"}',
        ),
        Message( 
          messageId: 'msg_5',
          conversationId: 'test_conv',
          senderId: 'test_user',
          senderName: 'Test User',
          senderAvatar: null,
          // senderRoleId: 0, // 字段已移除
          createdAt: now.subtract(const Duration(minutes: 1)),
          updatedAt: null,
          messageIndex: 500,
          messageType: 'TEXT',
          messageStatus: 'SENT',
          quotedMessageId: null,
          repliedToMessageId: null,
          forwardedFromConversationId: null,
          forwardedFromMessageId: null,
          isEdited: false,
          editedAt: null,
          isPinned: false,
          reactions: null,
          tags: null,
          content: '{"text": "消息5"}',
        ),
        Message( 
          messageId: 'msg_6',
          conversationId: 'test_conv',
          senderId: 'test_user',
          senderName: 'Test User',
          senderAvatar: null,
          // senderRoleId: 0, // 字段已移除
          createdAt: now,
          updatedAt: null,
          messageIndex: 600,
          messageType: 'TEXT',
          messageStatus: 'SENT',
          quotedMessageId: null,
          repliedToMessageId: null,
          forwardedFromConversationId: null,
          forwardedFromMessageId: null,
          isEdited: false,
          editedAt: null,
          isPinned: false,
          reactions: null,
          tags: null,
          content: '{"text": "消息6（最新）"}',
        ),
      ];

      _logger.i('📋 排序前的消息顺序', extra: {
        'messages': testMessages
            .map((m) => {
                  'messageId': m.messageId,
                  'messageIndex': m.messageIndex,
                  'text': _getTextFromMessage(m),
                  'createdAt': m.createdAt.toIso8601String(),
                })
            .toList(),
      });


      _logger.i('✅ 排序后的消息顺序（显示用）', extra: {
        'messages': testMessages
            .map((m) => {
                  'messageId': m.messageId,
                  'messageIndex': m.messageIndex,
                  'text': _getTextFromMessage(m),
                  'createdAt': m.createdAt.toIso8601String(),
                  'position': testMessages.indexOf(m) + 1,
                })
            .toList(),
      });

      // 验证排序结果
      bool sortCorrect = true;
      final errors = <String>[];

      // 检查时间戳排序是否正确（降序，最新的在前）
      for (int i = 0; i < testMessages.length - 1; i++) {
        final current = testMessages[i];
        final next = testMessages[i + 1];

        if (current.createdAt.isBefore(next.createdAt)) {
          sortCorrect = false;
          errors
              .add('位置${i + 1}: 时间排序错误 - ${_getTextFromMessage(current)} 应该比 ${_getTextFromMessage(next)} 更新');
        }
      }

      _logger.i('🎯 排序验证结果', extra: {
        'sortCorrect': sortCorrect,
        'errors': errors,
        'expectedOrder': [
          '消息6（最新）',
          '消息5',
          '消息4',
          '消息3',
          '消息2',
          '消息1（最早）',
        ],
      });

      if (sortCorrect) {
        _logger.i('✅ 消息排序测试通过！');
      } else {
        _logger.e('❌ 消息排序测试失败', extra: {'errors': errors});
      }

      _logger.i('=== 消息排序测试完成 ===');
    } catch (error) {
      _logger.e('消息排序测试失败', error: error, stackTrace: StackTrace.current);
    }
  }

  /// ⏰ 检查Token自动刷新机制状态
  static Future<void> checkTokenAutoRefreshStatus() async {
    _logger.i('⏰ === Token自动刷新机制检查 === ⏰');

    try {
      final tokenManager = EnhancedTokenManager.instance;
      final tokenStatus = await tokenManager.getTokenStatus();

      final refreshTimerInfo =
          tokenStatus['refreshTimer'] as Map<String, dynamic>?;

      _logger.i('自动刷新定时器状态', extra: {
        'timerActive': refreshTimerInfo?['active'] ?? false,
        'isRefreshing': refreshTimerInfo?['isRefreshing'] ?? false,
        'nextRefreshCheck': refreshTimerInfo?['nextRefreshCheck'] ?? 'N/A',
      });

      // 检查Socket Token是否需要刷新
      final secureStorage = SecureStorageService();
      final socketExpire = await secureStorage.getSocketTokenExpireTime();

      if (socketExpire != null) {
        final now = DateTime.now();
        final timeUntilExpiry = socketExpire.difference(now);
        final shouldRefresh =
            timeUntilExpiry <= const Duration(hours: 12); // 提前12小时刷新Socket Token

        _logger.i('Socket Token自动刷新条件检查', extra: {
          'socketTokenExpire': socketExpire.toIso8601String(),
          'currentTime': now.toIso8601String(),
          'timeUntilExpiry': '${timeUntilExpiry.inHours} 小时',
          'shouldRefresh': shouldRefresh,
          'refreshAdvanceTime': '12 小时',
        });

        if (shouldRefresh && refreshTimerInfo?['active'] != true) {
          _logger.w('⚠️ Socket Token应该被刷新但定时器未激活！');

          // 手动启动Token管理
          _logger.i('🔧 尝试手动启动Token管理服务...');
          tokenManager.startTokenManagement();

          _logger.i('✅ Token管理服务已手动启动');
        } else if (!shouldRefresh) {
          _logger.i('✅ Socket Token还有足够时间，无需刷新');
        } else {
          _logger.i('✅ Socket Token自动刷新机制正常运行');
        }
      }

      _logger.i('⏰ === Token自动刷新机制检查完成 === ⏰');
    } catch (error) {
      _logger.e('Token自动刷新机制检查失败', error: error);
    }
  }

  /// 诊断Token状态详情
  static Future<void> diagnoseTokenDetails() async {
    try {
      _logger.i('=== 🔍 详细Token状态诊断 ===');

      final secureStorage = SecureStorageService();
      final now = DateTime.now();

      // 获取所有Token和过期时间
      final refreshToken = await secureStorage.getRefreshToken();
      final socketToken = await secureStorage.getSocketToken();

      final refreshExpire = await secureStorage.getRefreshTokenExpireTime();
      final socketExpire = await secureStorage.getSocketTokenExpireTime();

      _logger.i('📅 当前时间', extra: {'now': now.toIso8601String()});

      // Access Token已移除，现在只使用Refresh Token + Socket Token架构

      // Refresh Token状态
      if (refreshToken != null && refreshExpire != null) {
        final timeUntilExpiry = refreshExpire.difference(now);
        final isExpired = now.isAfter(refreshExpire);

        _logger.i('🔄 Refresh Token状态', extra: {
          'exists': true,
          'length': refreshToken.length,
          'expiresAt': refreshExpire.toIso8601String(),
          'isExpired': isExpired,
          'timeUntilExpiry': isExpired
              ? '已过期 ${now.difference(refreshExpire).inDays} 天'
              : '还有 ${timeUntilExpiry.inDays} 天',
        });
      } else {
        _logger.w('🔄 Refresh Token', extra: {
          'token': refreshToken != null ? 'exists' : 'missing',
          'expireTime': refreshExpire != null
              ? refreshExpire.toIso8601String()
              : 'missing',
        });
      }

      // Socket Token状态
      if (socketToken != null && socketExpire != null) {
        final timeUntilExpiry = socketExpire.difference(now);
        final isExpired = now.isAfter(socketExpire);

        _logger.i('🔌 Socket Token状态', extra: {
          'exists': true,
          'length': socketToken.length,
          'expiresAt': socketExpire.toIso8601String(),
          'isExpired': isExpired,
          'timeUntilExpiry': isExpired
              ? '已过期 ${now.difference(socketExpire).inDays} 天'
              : '还有 ${timeUntilExpiry.inDays} 天',
        });
      } else {
        _logger.w('🔌 Socket Token', extra: {
          'token': socketToken != null ? 'exists' : 'missing',
          'expireTime':
              socketExpire != null ? socketExpire.toIso8601String() : 'missing',
        });
      }

      // 检查Token刷新条件
      final tokenManager = EnhancedTokenManager.instance;
      final tokenStatus = await tokenManager.getTokenStatus();
      _logger.i('🔧 Token管理器状态', extra: {
        'refreshTimerActive': tokenStatus['refreshTimer']?['active'] ?? false,
        'isRefreshing': tokenStatus['refreshTimer']?['isRefreshing'] ?? false,
      });

      _logger.i('=== Token状态诊断完成 ===');
    } catch (error) {
      _logger.e('Token状态诊断失败', error: error, stackTrace: StackTrace.current);
    }
  }

  /// 诊断ChatState状态详情
  static Future<void> diagnoseChatState(String conversationId) async {
    try {
      _logger.i('=== 🔍 ChatState状态诊断 ===');
      _logger.i('会话ID: $conversationId');

      // 注意：这里我们无法直接获取ChatCubit实例，因为它需要BuildContext
      // 这个方法应该在ChatPage中调用，传入ChatCubit实例
      _logger.w('⚠️ 此方法需要在ChatPage中调用以获取ChatCubit实例');
      _logger.i(
          '请在ChatPage中使用 DebugCommands.diagnoseChatStateWithCubit(context.read<ChatCubit>()) 方法');
    } catch (error) {
      _logger.e('ChatState状态诊断失败',
          error: error, stackTrace: StackTrace.current);
    }
  }

  /// 诊断ChatState状态详情（带ChatCubit实例）
  static void diagnoseChatStateWithCubit(dynamic chatCubit) async {
    try {
      _logger.i('=== 🔍 ChatState状态诊断 ===');

      // 获取当前状态
      final state = chatCubit.state;

      _logger.i('📊 基本状态', extra: {
        'conversationId': state.conversationId,
        'messagesCount': state.messages.length,
        'hasConversation': state.conversation != null,
      });

      _logger.i('🔄 加载状态', extra: {
        'isLoadingMessages': state.isLoadingMessages,
        'isLoadingMoreMessages': state.isLoadingMoreMessages,
        'isFetching': state.isFetching,
        'isCleaningMessages': state.isCleaningMessages,
        'isSending': state.isSending,
      });

      _logger.i('🔍 搜索状态', extra: {
        'isSearchMode': state.isSearchMode,
        'searchQuery': state.searchQuery,
        'isSearching': state.isSearching,
        'searchResultsCount': state.searchResults.length,
      });

      _logger.i('🌐 网络状态', extra: {
        'networkStatus': state.networkStatus,
        'isConnected': state.networkStatus == 'connected',
      });

      _logger.i('📍 滚动状态', extra: {
        'currentScrollPosition': {
          'messageId': state.currentScrollPosition.messageId,
          'relativePosition': state.currentScrollPosition.relativePosition,
        },
      });

      if (state.conversation != null) {
        _logger.i('💬 会话信息', extra: {
          'firstMessageIndex': state.conversation!.firstMessageIndex,
          'lastMessageIndex': state.conversation!.lastMessageIndex,
          'totalMessages': state.conversation!.getTotalMessageCount(),
        });

        if (state.messages.isNotEmpty) {
          final firstMessage = state.messages.first;
          final lastMessage = state.messages.last;

          _logger.i('📄 消息范围', extra: {
            'loadedFirstIndex': firstMessage.messageIndex,
            'loadedLastIndex': lastMessage.messageIndex,
            'canLoadBefore': lastMessage.messageIndex >
                state.conversation!.firstMessageIndex,
            'canLoadAfter': firstMessage.messageIndex <
                state.conversation!.lastMessageIndex,
          });
        }
      }

      // 检查是否可以触发加载更多
      final canTriggerLoadMore = !state.isSearchMode &&
          !state.isCleaningMessages &&
          !state.isLoadingMessages &&
          !state.isLoadingMoreMessages &&
          !state.isFetching &&
          state.messages.isNotEmpty;

      _logger.i('🚀 加载更多条件检查', extra: {
        'canTriggerLoadMore': canTriggerLoadMore,
        'blockingReasons': _getLoadMoreBlockingReasons(state),
      });

      _logger.i('=== ChatState状态诊断完成 ===');
    } catch (error) {
      _logger.e('ChatState状态诊断失败',
          error: error, stackTrace: StackTrace.current);
    }
  }

  /// 获取阻止加载更多的原因
  static List<String> _getLoadMoreBlockingReasons(dynamic state) {
    List<String> reasons = [];

    if (state.isSearchMode) reasons.add('处于搜索模式');
    if (state.isCleaningMessages) reasons.add('正在清理消息');
    if (state.isLoadingMessages) reasons.add('正在加载消息');
    if (state.isLoadingMoreMessages) reasons.add('正在加载更多消息');
    if (state.isFetching) reasons.add('正在获取数据');
    if (state.messages.isEmpty) reasons.add('消息列表为空');

    if (reasons.isEmpty) reasons.add('无阻止原因');

    return reasons;
  }
}

/// 在需要调试时，可以在代码中任何地方调用：
/// 
/// ```dart
/// // 完整诊断（推荐在遇到401错误时使用）
/// await DebugCommands.diagnoseAuthIssue();
/// 
/// // 🔧 立即修复401错误 - 推荐！
/// await DebugCommands.fixTokenSync();
/// 
/// // 🔍 详细Token状态诊断 - 新增！
/// await DebugCommands.diagnoseTokenStatus();
/// 
/// // 🔍 用户信息完整性诊断 - 新增！
/// await DebugCommands.diagnoseUserInfo();
/// 
/// // 🔍 测试消息排序逻辑 - 新增！
/// await DebugCommands.testMessageSorting();
/// 
/// // 快速检查用户信息
/// await DebugCommands.whoAmI();
/// ``` 