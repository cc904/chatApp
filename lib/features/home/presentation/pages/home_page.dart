import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as dev;

import '../cubit/home_cubit.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

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
              body: state is HomeLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.green))
                  : TabBarView(
                      controller: _tabController,
                      children: const [
                        ChatsPage(),
                        ContactsPage(),
                        CallsPage(),
                        ProfilePage(),
                      ],
                    ),
              bottomNavigationBar: Material(
                color: Colors.white,
                elevation: 8,
                child: TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(
                      icon: Icon(Icons.chat),
                      text: '聊天',
                    ),
                    Tab(
                      icon: Icon(Icons.contacts),
                      text: '通讯录',
                    ),
                    Tab(
                      icon: Icon(Icons.call),
                      text: '通话',
                    ),
                    Tab(
                      icon: Icon(Icons.person),
                      text: '我的',
                    ),
                  ],
                  labelColor: Colors.green,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.green,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelStyle: const TextStyle(fontSize: 12),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
