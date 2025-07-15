import 'package:cc/features/chat/data/repositories/chats_repository_impl.dart';
import 'package:cc/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:cc/features/chat/data/repositories/chat_repository_send_impl.dart';
import 'package:cc/features/chat/domain/repositories/chat_repository.dart';
import 'package:cc/features/chat/domain/repositories/chat_repository_send.dart';
import 'package:cc/features/chat/domain/repositories/chats_repository.dart';
import 'package:cc/features/chat/presentation/cubit/chats_cubit.dart';
import 'package:flutter/material.dart';
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
import 'package:cc/core/database/models/current_user.dart';
import 'package:cc/core/l10n/app_localizations.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
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

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

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

  Future<void> _init() async {
    await _initCubit();
  }

  Future<void> _initCubit() async {
    if (_homeCubit != null) return;

    final currentUser = await _secureStorage.readUserCredentials();

    if (currentUser == null) {
      _logger.e('无法获取用户信息，返回登录页面');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const AuthPage()),
        );
      });
      return;
    }

    _currentUser = currentUser;
    _homeCubit = HomeCubit(currentUser: currentUser);

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

    // 创建全局共享的ChatRepository
    _chatRepository = ChatRepositoryImpl(currentUser: currentUser);

    // 创建ChatRepositorySend（需要传入ChatRepository以便发出事件）
    _chatRepositorySend = ChatRepositorySendImpl(
      currentUser: currentUser,
      chatRepository: _chatRepository!,
    );

    // 创建ChatsRepository
    _chatsRepository = ChatsRepositoryImpl(currentUser: currentUser);

    _chatsCubit = ChatsCubit(
      chatsRepository: _chatsRepository!,
      currentUser: currentUser,
    );

    _contactCubit = ContactCubit(
      contactsRepository: ContactsRepositoryImpl(currentUser: currentUser),
    );

    // 🔄 登录成功后自动同步联系人
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _logger.i('登录成功，开始自动同步联系人');
      _contactCubit?.syncContacts();
      
      // 设置初始网络重连同步权限（默认ChatsPage可见）
      _updateNetworkReconnectSyncPermissions(_currentIndex);
    });

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
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
    if (_currentIndex != index) {
      // 重置之前选中的状态动画
      _iconStateControllers[_currentIndex].reverse();

      // 启动新选中的状态动画
      _iconStateControllers[index].forward();

      // 播放摆动动画（一次性）
      _iconAnimationControllers[index].forward().then((_) {
        _iconAnimationControllers[index].reverse();
      });

      setState(() {
        _currentIndex = index;
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

    // 如果HomeCubit还未初始化，显示加载指示器
    if (_homeCubit == null ||
        _chatsCubit == null ||
        _contactCubit == null ||
        _chatsRepository == null ||
        _chatRepositorySend == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return MultiRepositoryProvider(
      providers: [
        // Repository providers - 全局共享
        RepositoryProvider<ChatRepository>.value(value: _chatRepository!),
        RepositoryProvider<ChatsRepository>.value(value: _chatsRepository!),
        RepositoryProvider<ChatRepositorySend>.value(
            value: _chatRepositorySend!),

        // CurrentUser provider - 提供当前用户信息
        RepositoryProvider<CurrentUser>.value(value: _currentUser!),

        // BLoC providers - 状态管理
        BlocProvider<HomeCubit>.value(value: _homeCubit!),
        BlocProvider<ChatsCubit>.value(value: _chatsCubit!),
        BlocProvider<ContactCubit>.value(value: _contactCubit!),
      ],
      child: Scaffold(
        body: PageStorage(
          bucket: PageStorageBucket(),
          child: RepaintBoundary(
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                ChatsPage(key: PageStorageKey('chats_page')),
                ContactsPage(key: PageStorageKey('contacts_page')),
                ProfilePage(key: PageStorageKey('profile_page')),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
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
}
