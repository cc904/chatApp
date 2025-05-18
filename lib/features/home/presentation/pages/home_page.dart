import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/services/contact_service.dart';
import 'package:cc/core/services/socket_service.dart';
import 'package:cc/core/services/ui_notification_service.dart';
import 'package:cc/core/database/database_initializer.dart';

import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import 'chats_page.dart';
import 'contacts_page.dart';
import 'calls_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _logger = LogService.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabChange);
    _logger.d('HomePage initState');
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      _logger.d('切换到标签页: ${_tabController.index}');
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit(
        contactService: ContactService(DatabaseInitializer.isar),
        socketService: SocketService(),
        notificationService: UINotificationService.instance,
      ),
      child: Scaffold(
        body: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.error != null) {
              return Center(child: Text('错误: ${state.error}'));
            }

            return TabBarView(
              controller: _tabController,
              children: [
                // 聊天页面
                ChatsPage(contacts: state.contacts),
                // 联系人页面
                ContactsPage(contacts: state.contacts),
                // 通话页面
                CallsPage(contacts: state.contacts),
                // 我的页面
                const ProfilePage(),
              ],
            );
          },
        ),
        bottomNavigationBar: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.chat), text: '聊天'),
            Tab(icon: Icon(Icons.contacts), text: '联系人'),
            Tab(icon: Icon(Icons.call), text: '通话'),
            Tab(icon: Icon(Icons.person), text: '我的'),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // TODO: 根据当前标签页显示不同的操作
            switch (_tabController.index) {
              case 0: // 聊天
                // 显示新建聊天对话框
                break;
              case 1: // 联系人
                // 显示新建联系人对话框
                break;
              case 2: // 通话
                // 显示新建通话对话框
                break;
              case 3: // 我的
                // 不显示浮动按钮
                break;
            }
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
