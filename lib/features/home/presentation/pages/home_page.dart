import 'package:cc/features/chat/data/repositories/chats_repository_impl.dart';
import 'package:cc/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:cc/features/chat/domain/repositories/chat_repository.dart';
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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final _logger = LogService.instance;
  HomeCubit? _homeCubit;
  ChatsCubit? _chatsCubit;
  ContactCubit? _contactCubit;
  ChatRepository? _chatRepository;

  final _secureStorage = SecureStorageService.instance;
  late TabController _tabController;
  int _currentIndex = 0;
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
    await _initCubit();
  }

  Future<void> _initCubit() async {
    // 避免重复初始化
    if (_homeCubit != null) return;

    // 直接创建所需服务
    final currentUser = await _secureStorage.getFullUserInfo();

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
    _chatRepository = ChatRepositoryImpl();

    _chatsCubit = ChatsCubit(
      chatsRepository: ChatsRepositoryImpl(),
    );

    _contactCubit = ContactCubit(
      contactsRepository: ContactsRepositoryImpl(currentUserProto: currentUser),
    );

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _homeCubit?.close();
    _chatsCubit?.close();
    _contactCubit?.close();
    // 清理ChatRepository资源
    if (_chatRepository is ChatRepositoryImpl) {
      (_chatRepository as ChatRepositoryImpl).dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _logger.d('HomePage build');

    // 如果HomeCubit还未初始化，显示加载指示器
    if (_homeCubit == null || _chatsCubit == null || _contactCubit == null) {
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
      ),
    );
  }
}
