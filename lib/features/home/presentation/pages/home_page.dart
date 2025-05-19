import 'package:flutter/material.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/features/home/presentation/pages/chats_page.dart';
import 'package:cc/features/home/presentation/pages/contacts_page.dart';
import 'package:cc/features/home/presentation/pages/calls_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final _logger = LogService.instance;
  late TabController _tabController;
  final bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _logger.d('HomePage build');
    return Scaffold(
      appBar: AppBar(
        title: const Text('WhatsApp', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              _logger.d('搜索');
              // TODO: 实现搜索功能
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              _logger.d('更多选项');
              // TODO: 实现更多选项
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          tabs: const [
            Tab(text: '消息'),
            Tab(text: '联系人'),
            Tab(text: '通话'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('错误: $_error'))
              : TabBarView(
                  controller: _tabController,
                  children: const [
                    ChatsPage(),
                    ContactsPage(),
                    CallsPage(),
                  ],
                ),
    );
  }
}
