import 'package:flutter/material.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/features/home/presentation/pages/chats_page.dart';
import 'package:cc/features/home/presentation/pages/calls_page.dart';
import 'package:cc/features/home/presentation/pages/profile_page.dart';
import 'package:cc/features/home/presentation/pages/contacts_page.dart';

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
  int _currentIndex = 0;

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
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _logger.d('HomePage build');
    return Scaffold(
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
  }
}
