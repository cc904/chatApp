import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as dev;

import '../cubit/home_cubit.dart';
import 'chats_page.dart';
import 'status_page.dart';
import 'calls_page.dart';
import '../../../../features/auth/presentation/pages/auth_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // 添加监听器以响应标签切换
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    dev.log('HomePage build');
    return BlocProvider(
      create: (context) => HomeCubit(),
      child: BlocListener<HomeCubit, HomeState>(
        listener: (context, state) {
          if (state is HomeError) {
            // 显示错误消息
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('WhatsApp', style: TextStyle(fontWeight: FontWeight.w600)),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                elevation: 0,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      // 搜索功能
                    },
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      // 处理菜单选项
                      switch (value) {
                        case 'settings':
                          // 打开设置页面
                          break;
                        case 'logout':
                          _handleLogout(context);
                          break;
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return [
                        const PopupMenuItem<String>(
                          value: 'new_group',
                          child: Text('新建群组'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'new_broadcast',
                          child: Text('新建广播'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'linked_devices',
                          child: Text('已关联的设备'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'starred_messages',
                          child: Text('标星消息'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'settings',
                          child: Text('设置'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'logout',
                          child: Text('退出登录'),
                        ),
                      ];
                    },
                  ),
                ],
                bottom: TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: '聊天'),
                    Tab(text: '状态'),
                    Tab(text: '通话'),
                  ],
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  indicatorColor: Colors.white,
                  indicatorWeight: 3.0,
                ),
              ),
              body: state is HomeLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.green))
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        ChatsPage(),
                        StatusPage(),
                        CallsPage(),
                      ],
                    ),
              floatingActionButton: _buildFloatingActionButton(),
            );
          },
        ),
      ),
    );
  }

  /// 处理用户登出
  void _handleLogout(BuildContext context) {
    // 显示确认对话框
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('退出登录'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // 关闭对话框
              _confirmLogout(context);
            },
            child: const Text('确定', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// 确认登出，执行登出操作
  void _confirmLogout(BuildContext context) {
    context.read<HomeCubit>().logout().then((_) {
      // 登出成功，导航到登录页面
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const AuthPage()),
        (route) => false, // 清除所有路由历史
      );
    });
  }

  /// 根据当前选中的标签页构建相应的浮动按钮
  Widget _buildFloatingActionButton() {
    switch (_tabController.index) {
      case 0: // 聊天页
        return FloatingActionButton(
          onPressed: () {
            // 打开联系人列表或新建聊天
          },
          backgroundColor: Colors.green,
          child: const Icon(Icons.chat, color: Colors.white),
        );
      case 1: // 状态页
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton.small(
              onPressed: () {
                // 创建文字状态
              },
              backgroundColor: Colors.grey[200],
              child: Icon(Icons.edit, color: Colors.green[800]),
            ),
            const SizedBox(height: 16),
            FloatingActionButton(
              onPressed: () {
                // 创建相机状态
              },
              backgroundColor: Colors.green,
              child: const Icon(Icons.camera_alt, color: Colors.white),
            ),
          ],
        );
      case 2: // 通话页
        return FloatingActionButton(
          onPressed: () {
            // 新建通话
          },
          backgroundColor: Colors.green,
          child: const Icon(Icons.add_call, color: Colors.white),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
