import 'dart:async';

// ignore: depend_on_referenced_packages
import 'package:bloc/bloc.dart';
import 'package:cc/core/proto/generated/user.pb.dart';
import 'package:cc/core/proto/generated/contacts.pb.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/services/app_lifecycle_service.dart';
import 'package:cc/core/services/proto_socket_service.dart';
import 'package:cc/features/contacts/data/repositories/contacts_repository_impl.dart';
import 'package:cc/features/contacts/domain/repositories/contacts_repository.dart';
import 'package:cc/features/contacts/presentation/cubit/contact_state.dart';

/// 联系人相关的业务逻辑Cubit
class ContactCubit extends Cubit<ContactState> {
  final ContactsRepository _contactsRepository;
  final LogService _logger = LogService.instance;
  final ProtoSocketService _protoSocketService = ProtoSocketService();
  // final CurrentUserProto _currentUser;

  // 保存订阅，以便在dispose时取消
  final Map<String, StreamSubscription> _subscriptions = {};
  
  // 实例计数器，用于调试多实例问题
  static int _instanceCount = 0;
  final int _instanceId;

  /// 是否允许网络重连时自动同步
  bool _allowNetworkReconnectSync = true;
  
  /// 同步请求防重复标志
  bool _isSyncing = false;

  /// 获取联系人仓库实例
  ContactsRepository get repository => _contactsRepository;

  ContactCubit({
    required ContactsRepository contactsRepository,
  })  : _contactsRepository = contactsRepository,
        _instanceId = ++_instanceCount,
        super(ContactState.initial()) {
    _logger.i('ContactCubit实例创建', extra: {
      'instanceId': _instanceId,
      'totalInstances': _instanceCount,
      'repositoryHashCode': contactsRepository.hashCode,
      'stackTrace': StackTrace.current.toString().split('\n').take(10).join('\n'),
    });
    _setupLocalDataSubscriptions();
    _registerProtoEventHandlers();
    _setupAppLifecycleListener();
    // _startPeriodicSync();
  }

  /// 设置事件订阅
  void _setupLocalDataSubscriptions() {
    try {
      // 监听联系人同步状态
      _subscriptions['syncStatus'] =
          _contactsRepository.syncStatusStream.listen(
        (status) {
          _logger.i('联系人同步状态更新', extra: {'status': status.toString()});

          switch (status) {
            case ContactsSyncStatus.syncing:
              emit(state.toSyncingState());
              break;
            case ContactsSyncStatus.success:
              // 同步成功，数据库监听会自动更新联系人列表
              emit(state.copyWith(
                syncStatus: ContactsSyncStatus.success,
                errorMessage: null,
              ));
              break;
            case ContactsSyncStatus.error:
              emit(state.toErrorState('联系人同步失败'));
              break;
            default:
              break;
          }
        },
        onError: (error) {
          _logger.e('联系人同步状态监听错误', error: error);
          emit(state.toErrorState('联系人同步状态监听错误: ${error.toString()}'));
        },
      );

      // 监听联系人变化
      _subscriptions['contacts'] = _contactsRepository.watchContacts().listen(
        (_) {
          // 数据库有变化时，直接从数据库获取最新数据
          _refreshContactsFromDatabase();
        },
        onError: (error) {
          _logger.e('联系人变化监听错误', error: error);
        },
      );
    } catch (e) {
      _logger.e('设置联系人事件订阅失败', error: e, stackTrace: StackTrace.current);
    }
  }

  /// 注册Proto事件处理器
  /// 从Repository层移至Cubit层，更符合业务逻辑分层
  void _registerProtoEventHandlers() {
    if (_contactsRepository is! ContactsRepositoryImpl) {
      _logger.w('联系人仓库不是ContactsRepositoryImpl实例，无法注册Proto事件');
      return;
    }

    final repo = _contactsRepository as ContactsRepositoryImpl;
    final communicationService = repo.communicationService;

    if (!communicationService.isInitialized) {
      _logger.i('通信服务未初始化，无法设置Proto事件订阅');
      return;
    }

    _logger.i('开始设置联系人相关Proto事件订阅');

    try {
      // 使用链式调用方式添加订阅
      _subscriptions.addAll({
        // 🔄 监听连接状态变化，重连成功后自动同步联系人
        'reconnection':
            communicationService.connectionStateStream.listen((status) {
          if (status == SocketConnectionStatus.connected) {
            _logger.i('网络重连成功，检查是否允许自动同步联系人', extra: {
              'allowSync': _allowNetworkReconnectSync,
            });
            
            if (_allowNetworkReconnectSync) {
              Future.delayed(const Duration(seconds: 2), () {
                _logger.i('网络重连2秒后，执行联系人同步');
                syncContacts();
              });
            } else {
              _logger.d('网络重连自动同步已禁用，跳过联系人同步');
            }
          }
        }),

        // 订阅用户在线状态事件
        'userOnline': communicationService
            .onProto<UserStatusUpdate>('user:online')
            .listen((data) {
          if (data.hasUserId()) {
            repo.updateUserOnlineStatus(data.userId, true);
          }
        }),

        // 订阅用户离线状态事件
        'userOffline': communicationService
            .onProto<UserStatusUpdate>('user:offline')
            .listen((data) {
          if (data.hasUserId()) {
            repo.updateUserOnlineStatus(data.userId, false);
          }
        }),

        // 订阅联系人同步事件
        'contactSynced': communicationService
            .onProto<UserCollection>('contact:synced')
            .listen(repo.handleContactsSyncedEvent),

        // 订阅联系人同步结果事件
        'contactSyncResponse': communicationService
            .onProto<SyncContactsResponse>('contact:sync:response')
            .listen((response) {
          _logger.d('收到联系人同步结果', extra: {
            'instanceId': _instanceId,
            'responseType': response.runtimeType.toString(),
            'contactsCount': response.contacts.length,
            'timestamp': DateTime.now().toIso8601String(),
          });
          repo.handleContactsSyncResultProto(response);
        }),
      });

      // 🆕 设置本地事件监听器（使用ProtoSocketService的on方法）
      _setupLocalEventListeners();

      _logger.i('Proto和本地事件订阅设置完成', extra: {
        'subscribedEvents': _subscriptions.keys.toList(),
      });
    } catch (e, stack) {
      _logger.e('设置Proto事件订阅失败', error: e, stackTrace: stack);
    }
  }

  /// 设置本地事件监听器
  void _setupLocalEventListeners() {
    // 监听本地联系人更新事件（由ContactService发送）
    _protoSocketService.on('local:contact:updated', (data) {
      _logger.i('收到本地联系人更新通知', extra: data);
      // 刷新联系人列表
      _refreshContactsFromDatabase();
    });

    // 监听本地头像更新事件
    _protoSocketService.on('local:avatar:updated', (data) {
      _logger.i('收到本地头像更新通知', extra: data);
      // 刷新联系人列表以更新头像
      _refreshContactsFromDatabase();
    });

    _logger.d('本地事件监听器设置完成');
  }

  /// 加载联系人列表
  Future<void> loadContacts() async {
    _loadContacts();
  }

  // 防止重复加载的标志
  bool _isLoadingContacts = false;

  /// 从数据库刷新联系人数据（不触发加载状态）
  Future<void> _refreshContactsFromDatabase() async {
    try {
      _logger.d('从数据库刷新联系人数据');
      final contacts = await _contactsRepository.getAllContacts();

      // 直接更新联系人列表，不改变加载状态
      emit(state.copyWith(
        contacts: contacts,
        lastSyncTime: DateTime.now(),
        errorMessage: null,
      ));

      _logger.d('联系人数据刷新成功', extra: {'count': contacts.length});
    } catch (e) {
      _logger.e('从数据库刷新联系人数据失败', error: e);
      // 数据库刷新失败不要改变UI状态，保持当前状态
    }
  }

  /// 内部加载联系人方法
  Future<void> _loadContacts() async {
    // 防止重复加载
    if (_isLoadingContacts) {
      _logger.d('联系人正在加载中，跳过重复请求');
      return;
    }

    try {
      _isLoadingContacts = true;
      emit(state.toLoadingState());

      final contacts = await _contactsRepository.getAllContacts();
      
      // 🔥🔥🔥 详细的联系人数据日志
      for (final contact in contacts) {
        _logger.i('💼💼💼 加载的联系人数据', extra: {
          'contactName': contact.nickName,
          'contactId': contact.userId,
          'roleId': contact.roleId,
          'isFriend': contact.isFriend,
        });
      }

      emit(state.toLoadedState(
        contacts: contacts,
        lastSyncTime: DateTime.now(),
      ));

      _logger.i('联系人加载成功', extra: {'count': contacts.length});
    } catch (e) {
      _logger.e('加载联系人失败', error: e);
      // 如果是本地数据库访问失败，尝试返回空列表而非错误状态
      if (e.toString().contains('database') || e.toString().contains('isar')) {
        _logger.w('本地数据库访问失败，返回空联系人列表');
        emit(state.toLoadedState(
          contacts: [],
          lastSyncTime: DateTime.now(),
        ));
      } else {
        emit(state.toErrorState('本地数据访问失败: ${e.toString()}'));
      }
    } finally {
      _isLoadingContacts = false;
    }
  }

  /// 同步联系人列表（从服务器获取最新联系人列表）
  Future<void> syncContacts() async {
    // 🔧 保留基础的防重复同步检查（简化版本）
    if (_isSyncing) {
      _logger.d('联系人正在同步中，跳过重复请求');
      return;
    }

    try {
      _isSyncing = true;
      emit(state.toSyncingState());

      _logger.i('开始联系人同步');
      await _contactsRepository.syncContacts();

      // 同步状态会通过订阅的流来更新
      _logger.i('联系人同步请求已发送');
    } catch (e) {
      _logger.e('同步联系人失败', error: e);
      emit(state.toErrorState('同步联系人失败: ${e.toString()}'));
    } finally {
      _isSyncing = false;
    }
  }

  /// 搜索联系人
  Future<void> searchContacts(String query) async {
    if (query.isEmpty) {
      emit(state.toClearSearchState());
      return;
    }

    try {
      emit(state.toSearchingState(query));

      final results = await _contactsRepository.searchContacts(query);

      emit(state.toSearchCompletedState(results));

      _logger.i('联系人搜索完成', extra: {'query': query, 'count': results.length});
    } catch (e) {
      _logger.e('搜索联系人失败', error: e);
      emit(state.toErrorState('搜索联系人失败: ${e.toString()}'));
    }
  }

  /// 清除搜索
  void clearSearch() {
    emit(state.toClearSearchState());
  }

  /// 加载好友请求列表
  Future<void> loadFriendRequests() async {
    try {
      emit(state.toLoadingFriendRequestsState());

      final requests = await _contactsRepository.getFriendRequests();

      emit(state.toLoadedFriendRequestsState(friendRequests: requests));

      _logger.i('好友请求加载成功', extra: {'count': requests.length});
    } catch (e) {
      _logger.e('加载好友请求失败', error: e);
      emit(state.toErrorState('加载好友请求失败: ${e.toString()}'));
    }
  }

  /// 发送好友请求
  Future<bool> sendFriendRequest(String targetUserId, String message) async {
    try {
      await _contactsRepository.sendFriendRequest(
        targetUserId,
        message,
      );

      _logger.i('发送好友请求成功', extra: {'targetUserId': targetUserId});
      return true;
    } catch (e) {
      _logger.e('发送好友请求失败', error: e);
      emit(state.toErrorState('发送好友请求失败: ${e.toString()}'));
      rethrow;
    }
  }

  /// 接受好友请求
  Future<bool> acceptFriendRequest(String requestId) async {
    try {
      final result = await _contactsRepository.acceptFriendRequest(requestId);

      if (result) {
        _logger.i('接受好友请求成功', extra: {'requestId': requestId});
        loadFriendRequests(); // 重新加载好友请求列表
        loadContacts(); // 重新加载联系人列表
      } else {
        _logger.w('接受好友请求失败', extra: {'requestId': requestId});
      }

      return result;
    } catch (e) {
      _logger.e('接受好友请求失败', error: e);
      emit(state.toErrorState('接受好友请求失败: ${e.toString()}'));
      return false;
    }
  }

  /// 拒绝好友请求
  Future<bool> rejectFriendRequest(String requestId) async {
    try {
      final result = await _contactsRepository.rejectFriendRequest(requestId);

      if (result) {
        _logger.i('拒绝好友请求成功', extra: {'requestId': requestId});
        loadFriendRequests(); // 重新加载好友请求列表
      } else {
        _logger.w('拒绝好友请求失败', extra: {'requestId': requestId});
      }

      return result;
    } catch (e) {
      _logger.e('拒绝好友请求失败', error: e);
      emit(state.toErrorState('拒绝好友请求失败: ${e.toString()}'));
      return false;
    }
  }

  /// 设置是否允许网络重连时自动同步
  void setNetworkReconnectSyncEnabled(bool enabled) {
    _allowNetworkReconnectSync = enabled;
    _logger.d('ContactCubit 网络重连自动同步设置', extra: {
      'enabled': enabled,
    });
  }

  @override
  Future<void> close() {
    _instanceCount--;
    _logger.i('关闭ContactCubit，取消所有订阅', extra: {
      'instanceId': _instanceId,
      'remainingInstances': _instanceCount,
    });
    // 取消所有订阅
    for (var subscription in _subscriptions.values) {
      subscription.cancel();
    }
    _subscriptions.clear();

    return super.close();
  }

  /// 设置应用生命周期监听
  void _setupAppLifecycleListener() {
    try {
      final appLifecycleService = AppLifecycleService.instance;
      
      // 首先取消现有的监听器（如果有的话）
      _subscriptions['appLifecycle']?.cancel();

      // 🔧 优化：减少轮询频率到10秒，并添加防重复机制
      CustomAppLifecycleState? lastState;
      DateTime? lastProcessTime;
      
      _subscriptions['appLifecycle'] = Stream.periodic(
        const Duration(seconds: 10), // 进一步降低轮询频率
        (_) => appLifecycleService.currentState,
      ).where((currentState) {
        final now = DateTime.now();
        
        // 只在状态真正发生变化且距离上次处理超过3秒时才处理
        if (lastState != currentState && 
            (lastProcessTime == null || now.difference(lastProcessTime!).inSeconds > 3)) {
          lastState = currentState;
          lastProcessTime = now;
          return true;
        }
        return false;
      }).listen((currentState) {
        _handleAppLifecycleChange(currentState);
      });

      _logger.i('应用生命周期监听已设置', extra: {
        'instanceId': _instanceId,
        'pollingInterval': '10秒',
        'minProcessInterval': '3秒',
      });
    } catch (e) {
      _logger.e('设置应用生命周期监听失败', error: e, extra: {
        'instanceId': _instanceId,
      });
    }
  }

  /// 处理应用生命周期变化
  void _handleAppLifecycleChange(CustomAppLifecycleState newState) {
    _logger.d('联系人模块收到应用状态变化', extra: {
      'instanceId': _instanceId,
      'newState': newState.toString(),
    });

    // 当应用从后台恢复到前台时，仅清理错误，不自动同步，由页面切换逻辑决定
    if (newState == CustomAppLifecycleState.resumed) {
      _logger.i('应用恢复到前台，清除错误状态');

      if (state.errorMessage != null) {
        emit(state.copyWith(errorMessage: null));
      }
    }
  }

  /// 启动定期同步
  // void _startPeriodicSync() {
  //   _logger.i('启动联系人定期同步', extra: {'interval': '${_syncInterval.inMinutes}分钟'});
  //   _periodicSyncTimer = Timer.periodic(_syncInterval, (timer) {
  //     if (!isClosed) {
  //       // 🔄 只在应用活跃时进行定期同步
  //       final appLifecycleService = AppLifecycleService.instance;
  //       if (appLifecycleService.isAppActive) {
  //         _logger.d('定期同步联系人');
  //         syncContacts();
  //       } else {
  //         _logger.d('应用在后台，跳过定期同步');
  //       }
  //     }
  //   });
  // }
}
