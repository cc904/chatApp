import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/features/home/presentation/cubit/home_cubit.dart';
import 'package:cc/features/home/presentation/cubit/home_state.dart';
import 'package:cc/features/home/presentation/pages/chats_page.dart';
import 'package:cc/features/home/presentation/pages/calls_page.dart';
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
  final _secureStorage = SecureStorageService.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentIndex = _tabController.index;
      });
    });

    _init();
  }

  Future<void> _init() async {
    await _checkUserLoggedIn();
    await _initHomeCubit();
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

  Future<void> _initHomeCubit() async {
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

    // 初始化用户会话
    await _homeCubit?.initUserSession();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _homeCubit?.close();
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
    return BlocProvider<HomeCubit>.value(
      // 使用固定的值作为key
      key: const ValueKey('home_cubit_provider'),
      value: _homeCubit!,
      child: BlocConsumer<HomeCubit, HomeState>(
        // 添加listenWhen条件，避免不必要的监听
        listenWhen: (previous, current) =>
            previous.hasError != current.hasError ||
            (current.hasError && previous.errorMessage != current.errorMessage),
        listener: (context, state) {
          // 可以在这里处理状态变化的副作用，如显示弹窗等
          if (state.hasError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? '发生未知错误')),
            );
          }
        },
        // 添加buildWhen条件，避免不必要的重建
        buildWhen: (previous, current) =>
            previous.isInitializing != current.isInitializing ||
            previous.hasError != current.hasError,
        builder: (context, state) {
          return Scaffold(
            body: state.isInitializing
                ? const Center(child: CircularProgressIndicator())
                : state.hasError
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('错误: ${state.errorMessage}'),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () =>
                                  _homeCubit!.retryInitialization(),
                              child: const Text('重试'),
                            ),
                          ],
                        ),
                      )
                    : TabBarView(
                        controller: _tabController,
                        children: const [
                          ChatsPage(),
                          ContactsPage(),
                          CallsPage(),
                          ProfilePage(),
                        ],
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
                  icon: Icon(Icons.call),
                  label: '通话',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: '我的',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
