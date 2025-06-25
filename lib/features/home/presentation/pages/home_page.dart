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
import 'dart:async';

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
  ChatsRepository? _chatsRepository;
  ChatRepositorySend? _chatRepositorySend;
  CurrentUser? _currentUser;
  Timer? _cleanupTimer;

  final _secureStorage = SecureStorageService.instance;
  late TabController _tabController;
  int _currentIndex = 0;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    _init();
  }

  Future<void> _init() async {
    await _initCubit();
  }

  Future<void> _initCubit() async {
    if (_homeCubit != null) return;

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
    });

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

  @override
  Widget build(BuildContext context) {
    _logger.d('HomePage build');

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
          onTap: (index) {
            // 只有真正切换页面时才触发setState，避免重复build
            if (_currentIndex != index) {
              setState(() {
                _currentIndex = index;
              });
              _tabController.animateTo(index);
            }
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
