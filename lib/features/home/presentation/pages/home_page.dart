import 'package:cc/features/chat/presentation/cubit/chats_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/features/home/presentation/cubit/home_cubit.dart';
import 'package:cc/features/home/presentation/pages/chats_page.dart';
// 已移除 calls_page.dart 的引用
import 'package:cc/features/home/presentation/pages/profile_page.dart';
import 'package:cc/features/home/presentation/pages/contacts_page.dart';
import 'package:cc/core/services/secure_storage_service.dart';
import 'package:cc/features/auth/presentation/pages/auth_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final _logger = LogService.instance;
  late TabController _tabController;
  int _currentIndex = 0;
  HomeCubit? _homeCubit;
  ChatsCubit? _chatsCubit;
  final _secureStorage = SecureStorageService.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentIndex = _tabController.index;
      });
    });

    _init();
  }

  Future<void> _init() async {
    await _checkUserLoggedIn();
    await _initCubit();
  }

  // 检查用户是否已登录
  Future<void> _checkUserLoggedIn() async {
    final token = await _secureStorage.getToken();
    if (token == null || token.isEmpty) {
      _logger.w('用户未登录，返回登录页面');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const AuthPage()),
        );
      });
    }
  }

  Future<void> _initCubit() async {
    // 避免重复初始化
    if (_homeCubit != null) return;

    // 直接创建所需服务
    final secureStorage = SecureStorageService.instance;
    final currentUser = await secureStorage.getFullUserInfo();

    if (currentUser == null) {
      _logger.e('无法获取用户信息，返回登录页面');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const AuthPage()),
        );
      });
      return;
    }

    _homeCubit = HomeCubit(currentUserProto: currentUser);
    _chatsCubit = ChatsCubit();

    // 初始化用户会话
    await _homeCubit!.initUserSession();

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _homeCubit?.close();
    _chatsCubit?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _logger.d('HomePage build');

    // 如果HomeCubit还未初始化，显示加载指示器
    if (_homeCubit == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // 使用稳定的key来避免BlocProvider重建
    return MultiBlocProvider(
        providers: [
          BlocProvider<HomeCubit>(create: (context) => _homeCubit!),
          BlocProvider<ChatsCubit>(create: (context) => _chatsCubit!),
          // BlocProvider<ContactsCubit>(create: (context) => ContactsCubit()),
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
            onTap: (index) {
              setState(() {
                _currentIndex = index;
                _tabController.animateTo(index);
              });
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.chat),
                label: '消息',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.contacts),
                label: '联系人',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: '我的',
              ),
            ],
          ),
        ));
  }
}
