import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/features/home/presentation/cubit/home_cubit.dart';
import 'package:cc/features/home/presentation/cubit/home_state.dart';
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

    if (mounted) {
      setState(() {});
    }
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
            previous.homePageIsInitializing != current.homePageIsInitializing ||
            previous.hasError != current.hasError ||
            previous.currentUser != current.currentUser,
        // TODO: 根据实际需求添加其他需要触发重建的条件，但不包括会话列表和联系人列表的变化
        builder: (context, state) {
          return Scaffold(
            body: state.homePageIsInitializing
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
                    : PageStorage(
                        bucket: PageStorageBucket(),
                        child: RepaintBoundary(
                          child: TabBarView(
                            controller: _tabController,
                            physics: const NeverScrollableScrollPhysics(),
                            children: const [
                              ChatsPage(key: PageStorageKey('chats_page')),
                              ContactsPage(
                                  key: PageStorageKey('contacts_page')),
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
          );
        },
      ),
    );
  }
}
