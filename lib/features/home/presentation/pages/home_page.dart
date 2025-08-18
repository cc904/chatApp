import 'package:cc/features/chat/data/repositories/chats_repository_impl.dart';
import 'package:cc/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:cc/features/chat/data/repositories/chat_repository_send_impl.dart';
import 'package:cc/features/chat/domain/repositories/chat_repository.dart';
import 'package:cc/features/chat/domain/repositories/chat_repository_send.dart';
import 'package:cc/features/chat/domain/repositories/chats_repository.dart';
import 'package:cc/features/chat/presentation/cubit/chats_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 🔧 新增：用于 SystemNavigator
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/features/home/presentation/cubit/home_cubit.dart';
import 'package:cc/features/chat/presentation/pages/chats_page.dart';
import 'package:cc/features/profile/presentation/pages/profile_page.dart';
import 'package:cc/features/contacts/presentation/pages/contacts_page.dart';
import 'package:cc/core/services/secure_storage_service.dart';
import 'package:cc/features/auth/presentation/pages/auth_page.dart';
import 'package:cc/features/contacts/presentation/cubit/contact_cubit.dart';
import 'package:cc/features/contacts/data/repositories/contacts_repository_impl.dart';
import 'package:cc/features/profile/data/repositories/profile_repository.dart';
import 'package:cc/core/database/drift_database.dart';
import 'package:cc/core/l10n/app_localizations.dart';

import 'dart:async';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin, WidgetsBindingObserver, RestorationMixin {
  final _logger = LogService.instance;
  HomeCubit? _homeCubit;
  ChatsCubit? _chatsCubit;
  ContactCubit? _contactCubit;
  ChatRepository? _chatRepository;
  ChatsRepository? _chatsRepository;
  ChatRepositorySend? _chatRepositorySend;
  CurrentUser? _currentUser;
  Timer? _cleanupTimer;

  final _secureStorage = SecureStorageService();
  late TabController _tabController;

  // 动画控制器
  late List<AnimationController> _iconAnimationControllers; // 用于摆动动画
  late List<AnimationController> _iconStateControllers; // 用于选中状态动画
  late List<Animation<double>> _iconScaleAnimations;
  late List<Animation<double>> _iconRotationAnimations;
  late List<Animation<Color?>> _iconColorAnimations;

  // 🔧 新增：使用 RestorableInt 保存当前选中的 Tab 索引
  late RestorableInt _currentIndex;

  // 🔧 新增：状态保存标志
  bool _isInitialized = false;
  bool _isInitializing = false;
  bool _isInitializingRepositories = false;

  // 🔧 调试用：跟踪初始化调用次数
  static int _initCallCounter = 0;

  @override
  void initState() {
    super.initState();

    _logger.i('🔧 initState执行', extra: {
      'initCallCounter': _initCallCounter,
    });

    // 🔧 新增：添加应用生命周期监听
    WidgetsBinding.instance.addObserver(this);

    // 🔧 新增：初始化 RestorableInt
    _currentIndex = RestorableInt(0);

    // 🔧 修复：TabController 将在 restoreState 后正确设置初始索引
    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);

    // 初始化摆动动画控制器
    _iconAnimationControllers = List.generate(
      3,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 400),
        vsync: this,
      ),
    );

    // 初始化状态动画控制器
    _iconStateControllers = List.generate(
      3,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      ),
    );

    // 初始化缩放动画 - 使用弹性曲线
    _iconScaleAnimations = _iconStateControllers.map((controller) {
      return Tween<double>(begin: 1.0, end: 1.2).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.elasticOut,
          reverseCurve: Curves.easeInOut,
        ),
      );
    }).toList();

    // 初始化旋转动画 - 轻微摆动效果
    _iconRotationAnimations = _iconAnimationControllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 0.1).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeInOut,
        ),
      );
    }).toList();

    // 初始化颜色动画 - 从灰色到绿色的渐变
    _iconColorAnimations = _iconStateControllers.map((controller) {
      return ColorTween(
        begin: Colors.grey,
        end: Colors.green,
      ).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();

    // 设置初始选中状态
    _iconStateControllers[0].forward();

    _init();
  }

  // 🔧 新增：RestorationMixin 必需的方法
  @override
  String? get restorationId => 'home_page';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    _logger.i('🔄 HomePage restoreState 被调用', extra: {
      'initialRestore': initialRestore,
      'hasOldBucket': oldBucket != null,
    });

    registerForRestoration(_currentIndex, 'current_tab_index');

    // 🔧 新增：监听 _currentIndex 变化以便调试
    _currentIndex.addListener(() {
      _logger.i('🔄 Tab 索引发生变化', extra: {
        'newIndex': _currentIndex.value,
      });
    });

    _logger.i('🔄 当前恢复的 Tab 索引', extra: {
      'currentIndex': _currentIndex.value,
    });

    // 延迟同步 TabController 和动画状态，确保在组件完全初始化后执行
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _syncTabState();
      }
    });
  }

  // 🔧 新增：同步 Tab 状态的方法
  void _syncTabState() {
    _logger.i('🔄 同步 Tab 状态', extra: {
      'targetIndex': _currentIndex.value,
      'currentTabIndex': _tabController.index,
    });

    // 同步 TabController
    if (_tabController.index != _currentIndex.value) {
      _tabController.index = _currentIndex.value;
    }

    // 同步动画状态
    for (int i = 0; i < _iconStateControllers.length; i++) {
      if (i == _currentIndex.value) {
        if (!_iconStateControllers[i].isCompleted) {
          _iconStateControllers[i].forward();
        }
      } else {
        if (_iconStateControllers[i].isCompleted) {
          _iconStateControllers[i].reverse();
        }
      }
    }

    _logger.i('✅ Tab 状态同步完成');
  }

  Future<void> _init() async {
    _logger.i('🚀 _init被调用，开始初始化流程');
    await _initCubit();
  }

  // 🔧 新增：处理应用生命周期状态变化
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // 🔧 简化日志：只有resumed和paused状态才输出info级别，其他状态用debug级别
    // if (state == AppLifecycleState.resumed || state == AppLifecycleState.paused) {
    //   _logger.i('HomePage 应用生命周期状态变化', extra: {
    //     'state': state.toString(),
    //     'isInitialized': _isInitialized,
    //   });
    // } else {
    //   _logger.d('HomePage 应用生命周期状态变化', extra: {
    //     'state': state.toString(),
    //     'isInitialized': _isInitialized,
    //   });
    // }

    // 🔧 强化：当应用从后台恢复时，检查状态是否需要重新初始化
    if (state == AppLifecycleState.resumed && !_isInitialized && !_isInitializing && _homeCubit == null && _contactCubit == null && _chatsCubit == null) {
      _logger.w('应用从后台恢复，但状态未初始化，重新初始化', extra: {
        'isInitialized': _isInitialized,
        'isInitializing': _isInitializing,
        'hasHomeCubit': _homeCubit != null,
        'hasContactCubit': _contactCubit != null,
        'hasChatsCubit': _chatsCubit != null,
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _init();
        }
      });
    } else if (state == AppLifecycleState.resumed) {
      // _logger.d('应用从后台恢复，但初始化状态正常，跳过重新初始化', extra: {
      //   'isInitialized': _isInitialized,
      //   'isInitializing': _isInitializing,
      //   'hasHomeCubit': _homeCubit != null,
      //   'hasContactCubit': _contactCubit != null,
      //   'hasChatsCubit': _chatsCubit != null,
      // });
    }
  }

  Future<void> _initCubit() async {
    _logger.i('🔍 进入_initCubit方法');
    final callId = ++_initCallCounter;
    _logger.i('_initCubit被调用', extra: {
      'callId': callId,
      'homeCubitExists': _homeCubit != null,
      'isInitialized': _isInitialized,
      'isInitializing': _isInitializing,
    });

    // 🔧 修复：简化保护逻辑，移除可能永远为true的_globalInitializationInProgress检查
    if (_homeCubit != null || _isInitialized || _isInitializing) {
      _logger.d('初始化已进行或进行中，跳过重复调用', extra: {
        'callId': callId,
        'homeCubitExists': _homeCubit != null,
        'isInitialized': _isInitialized,
        'isInitializing': _isInitializing,
        'reason': _homeCubit != null
            ? 'HomeCubit已存在'
            : _isInitialized
                ? '已初始化完成'
                : _isInitializing
                    ? '正在初始化中'
                    : '未知',
      });
      return;
    }

    setState(() {
      _isInitializing = true;
      // 🔧 修复：不要在开始时就设置_isInitialized，等初始化完成后再设置
    });

    try {
      CurrentUser? currentUser = await _secureStorage.readUserCredentials();

      if (currentUser == null) {
        _logger.e('无法获取用户信息，返回登录页面');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const AuthPage()),
          );
        });
        return;
      }

      // 🚨🚨🚨 错误检查：初始化时currentUser的roleId不应该为0
      _logger.e('❌❌❌ INITIAL_USER_CHECK: 从安全存储读取的用户信息检查', extra: {
        'userId': currentUser.userId,
        'name': currentUser.name,
        'roleId': currentUser.roleId,
        'hasSetPassword': currentUser.hasSetPassword,
        'avatar': currentUser.avatar != null ? 'HAS_AVATAR' : 'NO_AVATAR',
        'phone': currentUser.phone != null ? 'HAS_PHONE' : 'NO_PHONE',
        'email': currentUser.email != null ? 'HAS_EMAIL' : 'NO_EMAIL',
      });

      // 🔥🔥🔥 错误：如果roleId为0，说明数据来源有问题
      if (currentUser.roleId == 0) {
        _logger.e('🚨🚨🚨 CRITICAL_ERROR: currentUser的roleId为0是错误的！', extra: {
          'possibleCauses': ['1. 服务器登录响应没有正确传递roleId', '2. SecureStorageService保存时丢失了roleId', '3. 数据库同步时roleId未正确更新', '4. Proto转换过程中roleId丢失'],
          'currentUserData': {'userId': currentUser.userId, 'name': currentUser.name, 'roleId': currentUser.roleId, 'expectedRoleId': '应该是1,2,3,4中的一个，不应该是0'}
        });
        _logger.w('安全存储中的用户roleId为0，尝试从数据库获取最新用户信息');
        _logger.i('🔄🔄🔄 FIXING_ROLE_ID: secureStorageRoleId=${currentUser.roleId}, fetching from database...');

        try {
          final profileRepository = ProfileRepository();
          final databaseUser = await profileRepository.getCurrentUser();

          if (databaseUser != null && databaseUser.roleId != 0) {
            _logger.i('从数据库获取到正确的用户信息', extra: {
              'secureStorageRoleId': currentUser.roleId,
              'databaseRoleId': databaseUser.roleId,
            });
            _logger.d('🔄🔄🔄 FIXED_ROLE_ID: databaseRoleId=${databaseUser.roleId}');

            // 使用数据库中的用户信息，并重新保存到安全存储
            currentUser = databaseUser;
            await _secureStorage.saveUserCredentials(currentUser);
            _logger.i('已将正确的用户信息保存到安全存储');
          } else {
            _logger.w('数据库中也没有找到有效的用户roleId信息');
            _logger.w('🔄🔄🔄 DATABASE_ALSO_NO_ROLE_ID: databaseUser=${databaseUser?.roleId}');
          }
        } catch (e) {
          _logger.e('从数据库获取用户信息失败', error: e);
          _logger.e('🔄🔄🔄 DATABASE_FETCH_ERROR: $e');
        }
      }

      _currentUser = currentUser;

      if (mounted) {
        setState(() {});
      }

      // 确保currentUser不为null（前面已经有null检查）
      assert(currentUser != null, 'currentUser should not be null at this point');
      _homeCubit = HomeCubit(currentUser: currentUser!);

      // 初始化用户会话
      final success = await _homeCubit!.initUserSession();
      if (!success) {
        _logger.e('用户会话初始化失败，返回登录页面');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const AuthPage()),
          );
        });
        return;
      }

      _logger.i('🎉 用户会话初始化成功，准备初始化服务');

      // 🔧 优化：并行初始化所有Repository和Cubit，减少等待时间
      if (mounted) {
        setState(() {});
      }

      // 🔧 修复：在调用initializeRepositoriesAndCubits前检查mounted状态
      if (!mounted) {
        _logger.w('Widget已unmounted，取消Repository初始化');
        return;
      }

      await _initializeRepositoriesAndCubits(currentUser);

      // 🔧 修复：初始化完成后再次检查mounted状态
      if (!mounted) {
        _logger.w('初始化完成后Widget已unmounted，跳过状态更新');
        return;
      }

      // 🔧 新增：标记初始化完成
      _isInitializing = false;
      _isInitialized = true; // 🔧 修复：在初始化完成后才设置为true

      _logger.i('HomePage 初始化完成', extra: {
        'isInitialized': _isInitialized,
        'isInitializing': _isInitializing,
        'hasHomeCubit': _homeCubit != null,
        'hasContactCubit': _contactCubit != null,
        'hasChatsCubit': _chatsCubit != null,
      });

      if (mounted) {
        setState(() {
          _logger.d('强制UI重建，显示HomePage主界面');
        });
      }

      // 🔄 登录成功后自动同步数据（异步执行，不阻塞UI）
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _initializeDataSync();
        }
      });
    } catch (error) {
      _logger.e('HomePage 初始化失败', error: error);
      if (mounted) {
        setState(() {
          _isInitializing = false;
          _isInitialized = false; // 初始化失败，重置状态
        });
      }

      // 初始化失败，返回登录页面
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const AuthPage()),
        );
      });
    }
  }

  /// 🔧 新增：并行初始化所有Repository和Cubit
  Future<void> _initializeRepositoriesAndCubits(CurrentUser currentUser) async {
    _logger.i('_initializeRepositoriesAndCubits被调用', extra: {
      'contactCubitExists': _contactCubit != null,
      'chatsCubitExists': _chatsCubit != null,
      'isInitializingRepositories': _isInitializingRepositories,
      'mounted': mounted,
      'stackTrace': StackTrace.current.toString().split('\n').take(5).join('\n'),
    });

    // 🔧 强化检查：多重保护机制
    if (!mounted) {
      _logger.w('Widget已unmounted，取消初始化');
      return;
    }

    if (_isInitializingRepositories) {
      _logger.w('Repository和Cubit正在初始化中，跳过重复调用', extra: {
        'isInitializingRepositories': _isInitializingRepositories,
      });
      return;
    }

    if (_contactCubit != null && _chatsCubit != null) {
      _logger.i('Repository和Cubit已存在，跳过初始化', extra: {
        'contactCubitInstanceId': (_contactCubit as dynamic)?._instanceId,
        'chatsCubitHashCode': _chatsCubit.hashCode,
      });
      return;
    }

    // 🔧 设置初始化锁
    _isInitializingRepositories = true;

    // 如果有部分初始化的实例，先清理
    if (_contactCubit != null) {
      _logger.w('发现已存在的ContactCubit，先清理');
      await _contactCubit!.close();
      _contactCubit = null;
    }
    if (_chatsCubit != null) {
      _logger.w('发现已存在的ChatsCubit，先清理');
      await _chatsCubit!.close();
      _chatsCubit = null;
    }

    try {
      // 并行创建所有Repository（它们相互独立）
      final futures = await Future.wait([
        Future(() => ChatRepositoryImpl(currentUser: currentUser)),
        Future(() => ChatsRepositoryImpl(currentUser: currentUser)),
        Future(() => ContactsRepositoryImpl(currentUser: currentUser)),
      ]);

      _chatRepository = futures[0] as ChatRepositoryImpl;
      _chatsRepository = futures[1] as ChatsRepositoryImpl;
      final contactsRepository = futures[2] as ContactsRepositoryImpl;

      // 创建ChatRepositorySend（需要ChatRepository）
      _chatRepositorySend = ChatRepositorySendImpl(
        currentUser: currentUser,
        chatRepository: _chatRepository!,
      );

      // 并行创建所有Cubit
      final cubitFutures = await Future.wait([
        Future(() => ChatsCubit(
              chatsRepository: _chatsRepository!,
              currentUser: currentUser,
            )),
        Future(() => ContactCubit(
              contactsRepository: contactsRepository,
            )),
      ]);

      _chatsCubit = cubitFutures[0] as ChatsCubit;
      _contactCubit = cubitFutures[1] as ContactCubit;

      _logger.i('所有Repository和Cubit初始化完成');
    } catch (error) {
      _logger.e('并行初始化Repository和Cubit失败', error: error);
      rethrow;
    } finally {
      // 🔧 释放初始化锁
      _isInitializingRepositories = false;
      _logger.d('释放Repository初始化锁', extra: {
        'isInitializingRepositories': _isInitializingRepositories,
      });
    }
  }

  /// 🔧 新增：初始化数据同步
  void _initializeDataSync() {
    _logger.i('开始初始化数据同步');

    // 设置初始网络重连同步权限（默认ChatsPage可见）
    _updateNetworkReconnectSyncPermissions(_currentIndex.value);

    // 异步开始数据同步，不阻塞UI
    Future.microtask(() async {
      try {
        // 优先同步会话列表（用户最关心的）
        _chatsCubit?.requestSyncConversations();

        // 🎯🎯🎯 预加载联系人到缓存，减少名称闪烁问题
        _logger.i('📇📇📇 开始预加载联系人');
        _contactCubit?.loadContacts();

        // 稍后同步联系人
        await Future.delayed(const Duration(milliseconds: 500));
        _contactCubit?.syncContacts();

        _logger.i('数据同步已启动');
      } catch (error) {
        _logger.e('数据同步启动失败', error: error);
      }
    });
  }

  @override
  void dispose() {
    // 🔧 新增：移除应用生命周期监听
    WidgetsBinding.instance.removeObserver(this);

    _tabController.dispose();
    // 销毁动画控制器
    for (var controller in _iconAnimationControllers) {
      controller.dispose();
    }
    for (var controller in _iconStateControllers) {
      controller.dispose();
    }
    _homeCubit?.close();
    _chatsCubit?.close();
    _contactCubit?.close();
    // 清理Repository资源
    if (_chatRepository is ChatRepositoryImpl) {
      (_chatRepository as ChatRepositoryImpl).dispose();
    }
    if (_chatsRepository is ChatsRepositoryImpl) {
      (_chatsRepository as ChatsRepositoryImpl).dispose();
    }
    _cleanupTimer?.cancel();
    super.dispose();
  }

  // 切换Tab时的动画处理
  void _onTabTapped(int index) {
    if (_currentIndex.value != index) {
      // 重置之前选中的状态动画
      _iconStateControllers[_currentIndex.value].reverse();

      // 启动新选中的状态动画
      _iconStateControllers[index].forward();

      // 播放摆动动画（一次性）
      _iconAnimationControllers[index].forward().then((_) {
        _iconAnimationControllers[index].reverse();
      });

      setState(() {
        _currentIndex.value = index;
      });
      _tabController.animateTo(index);

      // 更新HomeCubit的当前Tab索引
      _homeCubit?.setCurrentTabIndex(index);

      // 根据当前Tab设置网络重连同步权限
      _updateNetworkReconnectSyncPermissions(index);

      // 根据切换目标页面执行同步
      if (index == 0) {
        _logger.i('切换到会话Tab，同步会话列表');
        _chatsCubit?.requestSyncConversations();
      } else if (index == 1) {
        _logger.i('切换到联系人Tab，同步联系人');
        _contactCubit?.syncContacts();
      }
    }
  }

  /// 根据当前Tab更新网络重连同步权限
  void _updateNetworkReconnectSyncPermissions(int currentTabIndex) {
    _logger.d('更新网络重连同步权限', extra: {
      'currentTabIndex': currentTabIndex,
    });

    // ChatsPage 是索引 0，ContactsPage 是索引 1
    final isChatsTabActive = currentTabIndex == 0;
    final isContactsTabActive = currentTabIndex == 1;

    // 设置ChatsCubit的网络重连同步权限
    _chatsCubit?.setNetworkReconnectSyncEnabled(isChatsTabActive);

    // 设置ContactCubit的网络重连同步权限
    _contactCubit?.setNetworkReconnectSyncEnabled(isContactsTabActive);

    _logger.i('网络重连同步权限已更新', extra: {
      'chatsCanSync': isChatsTabActive,
      'contactsCanSync': isContactsTabActive,
    });
  }

  // 🔧 新增：处理返回键，将应用切换到后台而不是关闭
  Future<bool> _onWillPop() async {
    _logger.i('用户在主页面按下返回键，将应用切换到后台');

    try {
      // 🔧 修复：使用 MethodChannel 调用 Android 的 moveTaskToBack 而不是 SystemNavigator.pop
      // SystemNavigator.pop() 会终止应用进程，而 moveTaskToBack 只是将应用移到后台
      const platform = MethodChannel('app.channel.shared.data');
      await platform.invokeMethod('moveToBackground');
      return false; // 阻止默认的关闭行为
    } catch (e) {
      _logger.e('切换应用到后台失败，使用默认行为', error: e);
      // 如果切换到后台失败，允许默认行为（关闭应用）
      return true;
    }
  }

  // 创建动画图标
  Widget _buildAnimatedIcon(int index, IconData icon) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _iconAnimationControllers[index], // 摆动动画
        _iconStateControllers[index], // 状态动画
      ]),
      builder: (context, child) {
        return Transform.scale(
          scale: _iconScaleAnimations[index].value,
          child: Transform.rotate(
            angle: _iconRotationAnimations[index].value,
            child: Icon(
              icon,
              color: _iconColorAnimations[index].value ?? Colors.grey,
              size: 24,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _logger.d('HomePage build');
    final localizations = AppLocalizations.of(context);

    // 🔧 新方案：总是显示基本框架，根据初始化状态决定内容
    return _buildHomeFramework(context, localizations);
  }

  /// 构建主界面框架
  Widget _buildHomeFramework(BuildContext context, AppLocalizations localizations) {
    // 🔧 总是显示基本框架，使用PopScope处理返回键
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          await _onWillPop();
        }
      },
      child: Scaffold(
        body: PageStorage(
          bucket: PageStorageBucket(),
          child: RepaintBoundary(
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildTabContent(0, localizations), // 聊天页面
                _buildTabContent(1, localizations), // 联系人页面
                _buildTabContent(2, localizations), // 个人资料页面
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex.value,
          selectedItemColor: Colors.green,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          onTap: _onTabTapped,
          items: [
            BottomNavigationBarItem(
              icon: _buildAnimatedIcon(0, Icons.chat),
              label: localizations.chats,
            ),
            BottomNavigationBarItem(
              icon: _buildAnimatedIcon(1, Icons.contacts),
              label: localizations.contacts,
            ),
            BottomNavigationBarItem(
              icon: _buildAnimatedIcon(2, Icons.person),
              label: localizations.profile,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建Tab内容 - 仅在依赖未就绪时返回轻量占位；骨架屏移除，改由子页面自行处理
  Widget _buildTabContent(int tabIndex, AppLocalizations localizations) {
    // 仅在关键依赖未就绪时占位（不再显示整页骨架屏）
    final shouldPlaceholder = _homeCubit == null || _chatsCubit == null || _contactCubit == null;
    final bool isCurrent = _currentIndex.value == tabIndex;

    if (shouldPlaceholder) {
      // 显示顶部AppBar骨架 + 当前Tab的内容骨架（不覆盖底部TabBar）
      if (isCurrent) {
        _logger.d('显示Home骨架屏（不覆盖底部TabBar）', extra: {
          'tabIndex': tabIndex,
          'hasHomeCubit': _homeCubit != null,
          'hasChatsCubit': _chatsCubit != null,
          'hasContactCubit': _contactCubit != null,
        });
      }
      return Column(
        children: [
          // 顶部AppBar骨架
          Container(
            height: 90,
            padding: const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                Container(width: 120, height: 20, color: Colors.grey[300]),
                const Spacer(),
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.green[700]!)),
                ),
              ],
            ),
          ),
          // 内容骨架：根据tab简化不同形态
          Expanded(
            child: _buildHomeSkeletonForTab(tabIndex),
          ),
        ],
      );
    }

    // 初始化完成，显示实际内容
    // _logger.d('显示实际内容', extra: {
    //   'tabIndex': tabIndex,
    //   'isInitialized': _isInitialized,
    //   'isInitializing': _isInitializing,
    //   'allCubitsReady': true,
    // });

    return MultiRepositoryProvider(
      providers: [
        // Repository providers - 全局共享
        RepositoryProvider<ChatRepository>.value(value: _chatRepository!),
        RepositoryProvider<ChatsRepository>.value(value: _chatsRepository!),
        RepositoryProvider<ChatRepositorySend>.value(value: _chatRepositorySend!),

        // CurrentUser provider - 提供当前用户信息
        RepositoryProvider<CurrentUser>.value(value: _currentUser!),

        // BLoC providers - 状态管理
        BlocProvider<HomeCubit>.value(value: _homeCubit!),
        BlocProvider<ChatsCubit>.value(value: _chatsCubit!),
        BlocProvider<ContactCubit>.value(value: _contactCubit!),
      ],
      child: _buildActualTabContent(tabIndex),
    );
  }

  /// 构建实际的Tab内容
  Widget _buildActualTabContent(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return const ChatsPage(key: PageStorageKey('chats_page'));
      case 1:
        return const ContactsPage(key: PageStorageKey('contacts_page'));
      case 2:
        return const ProfilePage(key: PageStorageKey('profile_page'));
      default:
        return Container();
    }
  }

  /// Home页骨架：不覆盖底部TabBar，仅覆盖顶部+内容
  Widget _buildHomeSkeletonForTab(int tabIndex) {
    switch (tabIndex) {
      case 0:
        // Chats骨架：头像+两行
        return ListView.builder(
          itemCount: 10,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[300],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Container(height: 14, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(6))),
                      const SizedBox(height: 8),
                      Container(width: 160, height: 12, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(6))),
                    ]),
                  ),
                  const SizedBox(width: 8),
                  Container(width: 40, height: 12, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(6))),
                ],
              ),
            );
          },
        );
      case 1:
        // Contacts骨架：头像+单行
        return ListView.builder(
          itemCount: 12,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[300],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: Container(height: 14, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(6)))),
              ]),
            );
          },
        );
      case 2:
      default:
        // Profile骨架：头像+数行
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[300],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(child: Container(width: 120, height: 18, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(8)))),
            const SizedBox(height: 8),
            Center(child: Container(width: 80, height: 12, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(6)))),
            const SizedBox(height: 24),
            ...List.generate(6, (i) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(children: [
                Container(width: 24, height: 24, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(6))),
                const SizedBox(width: 12),
                Expanded(child: Container(height: 14, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(6)))),
              ]),
            )),
          ],
        );
    }
  }
}
