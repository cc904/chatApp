import 'package:cc/core/utils/auth_debug_utils.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/services/auth_token_sync_service.dart';
import 'package:cc/core/services/secure_storage_service.dart';
import 'package:cc/core/services/enhanced_token_manager.dart';
import 'package:cc/core/database/database_initializer.dart';
import 'package:cc/core/database/models/message.dart';
import 'package:cc/core/utils/message_sort_utils.dart';

/// 调试命令集合
/// 提供各种调试功能的快捷命令
class DebugCommands {
  static final _logger = LogService.instance;

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

      // 立即同步Token到所有服务
      await AuthTokenSyncService.instance.syncTokenToAllServices();

      _logger.i('✅ Token同步修复完成！(使用新多Token系统)');
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

      // Access Token状态
      final accessToken = await secureStorage.getAccessToken();
      final accessExpire = await secureStorage.getAccessTokenExpireTime();

      if (accessToken != null && accessExpire != null) {
        final timeUntilExpiry = accessExpire.difference(now);
        final isExpired = now.isAfter(accessExpire);

        _logger.i('🔑 Access Token状态', extra: {
          'exists': true,
          'length': accessToken.length,
          'expiresAt': accessExpire.toIso8601String(),
          'isExpired': isExpired,
          'timeUntilExpiry': isExpired
              ? '已过期 ${now.difference(accessExpire).inMinutes} 分钟'
              : '还有 ${timeUntilExpiry.inMinutes} 分钟',
        });
      } else {
        _logger.w('🔑 Access Token', extra: {
          'token': accessToken != null ? 'exists' : 'missing',
          'expireTime':
              accessExpire != null ? accessExpire.toIso8601String() : 'missing',
        });
      }

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
        // 正常消息（正数messageIndex）
        Message()
          ..messageId = 'msg_1'
          ..messageIndex = 100
          ..text = '正常消息1'
          ..createdAt = now.subtract(const Duration(minutes: 5)),
        Message()
          ..messageId = 'msg_2'
          ..messageIndex = 200
          ..text = '正常消息2'
          ..createdAt = now.subtract(const Duration(minutes: 4)),
        Message()
          ..messageId = 'msg_3'
          ..messageIndex = 300
          ..text = '正常消息3'
          ..createdAt = now.subtract(const Duration(minutes: 3)),

        // 临时消息（0值messageIndex）
        Message()
          ..messageId = ''
          ..tempId = 'temp_1'
          ..messageIndex = 0
          ..text = '临时消息1（较早）'
          ..createdAt = now.subtract(const Duration(minutes: 2)),
        Message()
          ..messageId = ''
          ..tempId = 'temp_2'
          ..messageIndex = 0
          ..text = '临时消息2（较新）'
          ..createdAt = now.subtract(const Duration(minutes: 1)),
        Message()
          ..messageId = ''
          ..tempId = 'temp_3'
          ..messageIndex = 0
          ..text = '临时消息3（最新）'
          ..createdAt = now,
      ];

      _logger.i('📋 排序前的消息顺序', extra: {
        'messages': testMessages
            .map((m) => {
                  'messageId': m.messageId.isEmpty ? m.tempId : m.messageId,
                  'messageIndex': m.messageIndex,
                  'text': m.text,
                  'isTemp': m.messageIndex == 0,
                })
            .toList(),
      });

      // 使用自定义排序
      testMessages.sort(MessageSortUtils.compareForDisplay);

      _logger.i('✅ 排序后的消息顺序（显示用）', extra: {
        'messages': testMessages
            .map((m) => {
                  'messageId': m.messageId.isEmpty ? m.tempId : m.messageId,
                  'messageIndex': m.messageIndex,
                  'text': m.text,
                  'isTemp': m.messageIndex == 0,
                  'position': testMessages.indexOf(m) + 1,
                })
            .toList(),
      });

      // 验证排序结果
      bool sortCorrect = true;
      final errors = <String>[];

      // 检查临时消息是否在前面
      for (int i = 0; i < testMessages.length; i++) {
        final current = testMessages[i];

        // 前3个应该是临时消息（0值）
        if (i < 3) {
          if (current.messageIndex != 0) {
            sortCorrect = false;
            errors
                .add('位置${i + 1}应该是临时消息，但messageIndex=${current.messageIndex}');
          }
        }
        // 后3个应该是正常消息（正数）
        else {
          if (current.messageIndex == 0) {
            sortCorrect = false;
            errors
                .add('位置${i + 1}应该是正常消息，但messageIndex=${current.messageIndex}');
          }
        }
      }

      // 检查临时消息内部排序（最新的在前）
      if (testMessages.length >= 3) {
        for (int i = 0; i < 2; i++) {
          final current = testMessages[i];
          final next = testMessages[i + 1];
          if (current.messageIndex == 0 && next.messageIndex == 0) {
            // 都是临时消息，应该按时间降序（最新的在前）
            if (current.createdAt.isBefore(next.createdAt)) {
              sortCorrect = false;
              errors.add('临时消息排序错误：${current.text} 应该比 ${next.text} 更新');
            }
          }
        }
      }

      _logger.i('🎯 排序验证结果', extra: {
        'sortCorrect': sortCorrect,
        'errors': errors,
        'expectedOrder': [
          '临时消息3（最新）- messageIndex=0',
          '临时消息2（较新）- messageIndex=0',
          '临时消息1（较早）- messageIndex=0',
          '正常消息3 - messageIndex=300',
          '正常消息2 - messageIndex=200',
          '正常消息1 - messageIndex=100',
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

      // 检查是否需要刷新
      final secureStorage = SecureStorageService();
      final accessExpire = await secureStorage.getAccessTokenExpireTime();

      if (accessExpire != null) {
        final now = DateTime.now();
        final timeUntilExpiry = accessExpire.difference(now);
        final shouldRefresh =
            timeUntilExpiry <= const Duration(minutes: 5); // 提前5分钟刷新

        _logger.i('自动刷新条件检查', extra: {
          'accessTokenExpire': accessExpire.toIso8601String(),
          'currentTime': now.toIso8601String(),
          'timeUntilExpiry': '${timeUntilExpiry.inMinutes} 分钟',
          'shouldRefresh': shouldRefresh,
          'refreshAdvanceTime': '5 分钟',
        });

        if (shouldRefresh && refreshTimerInfo?['active'] != true) {
          _logger.w('⚠️ Token应该被刷新但定时器未激活！');

          // 手动启动Token管理
          _logger.i('🔧 尝试手动启动Token管理服务...');
          tokenManager.startTokenManagement();

          _logger.i('✅ Token管理服务已手动启动');
        } else if (!shouldRefresh) {
          _logger.i('✅ Token还有足够时间，无需刷新');
        } else {
          _logger.i('✅ 自动刷新机制正常运行');
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
      final accessToken = await secureStorage.getAccessToken();
      final refreshToken = await secureStorage.getRefreshToken();
      final socketToken = await secureStorage.getSocketToken();

      final accessExpire = await secureStorage.getAccessTokenExpireTime();
      final refreshExpire = await secureStorage.getRefreshTokenExpireTime();
      final socketExpire = await secureStorage.getSocketTokenExpireTime();

      _logger.i('📅 当前时间', extra: {'now': now.toIso8601String()});

      // Access Token状态
      if (accessToken != null && accessExpire != null) {
        final timeUntilExpiry = accessExpire.difference(now);
        final isExpired = now.isAfter(accessExpire);

        _logger.i('🔑 Access Token状态', extra: {
          'exists': true,
          'length': accessToken.length,
          'expiresAt': accessExpire.toIso8601String(),
          'isExpired': isExpired,
          'timeUntilExpiry': isExpired
              ? '已过期 ${now.difference(accessExpire).inMinutes} 分钟'
              : '还有 ${timeUntilExpiry.inMinutes} 分钟',
        });
      } else {
        _logger.w('🔑 Access Token', extra: {
          'token': accessToken != null ? 'exists' : 'missing',
          'expireTime':
              accessExpire != null ? accessExpire.toIso8601String() : 'missing',
        });
      }

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