import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/features/home/data/repositories/home_repository_impl.dart';
import 'package:cc/features/home/presentation/cubit/home_cubit.dart';
import 'package:cc/features/home/presentation/cubit/home_state.dart';
import 'package:cc/features/home/presentation/pages/chats_page.dart';
import 'package:cc/features/home/presentation/pages/calls_page.dart';
import 'package:cc/features/home/presentation/pages/profile_page.dart';
import 'package:cc/features/home/presentation/pages/contacts_page.dart';
import 'package:cc/core/services/secure_storage_service.dart';
import 'package:cc/core/services/socket_service.dart';

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
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentIndex = _tabController.index;
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 在依赖项可用后初始化HomeCubit
    if (!_isInitialized) {
      _initHomeCubit();
      _isInitialized = true;
    }
  }

  void _initHomeCubit() {
    // 从上下文中获取服务
    final secureStorage = context.read<SecureStorageService>();
    final socketService = context.read<SocketService>();

    // 创建HomeRepository和HomeCubit
    final homeRepository = HomeRepositoryImpl(
      secureStorage: secureStorage,
      socketService: socketService,
    );

    _homeCubit = HomeCubit(homeRepository: homeRepository);

    // 初始化用户会话
    _homeCubit?.initUserSession();
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

    return BlocProvider.value(
      value: _homeCubit!,
      child: BlocConsumer<HomeCubit, HomeState>(
        listener: (context, state) {
          // 可以在这里处理状态变化的副作用，如显示弹窗等
          if (state.hasError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? '发生未知错误')),
            );
          }
        },
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
