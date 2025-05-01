import 'package:flutter/material.dart';
import 'dart:developer' as dev;

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        // 切换标签时清空搜索
        _searchController.clear();
        _isSearching = false;
        _hasSearched = false;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        titleSpacing: 0,
        title: const Text('添加'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: '找人'),
            Tab(text: '找群'),
          ],
        ),
      ),
      body: Column(
        children: [
          // 搜索框区域
          Container(
            color: Colors.green,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: _tabController.index == 0 ? '输入ID号或微信号搜索' : '输入群ID号搜索',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _isSearching
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _isSearching = false;
                            _hasSearched = false;
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              ),
              textInputAction: TextInputAction.search,
              onChanged: (value) {
                setState(() {
                  _isSearching = value.isNotEmpty;
                });
              },
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  setState(() {
                    _hasSearched = true;
                  });
                  // 执行搜索
                  _performSearch(value);
                }
              },
            ),
          ),

          // 搜索结果或提示区域
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // 找人的搜索结果
                _buildSearchResultsView(_hasSearched, _tabController.index == 0),

                // 找群的搜索结果
                _buildSearchResultsView(_hasSearched, _tabController.index == 1),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResultsView(bool hasSearched, bool isPerson) {
    if (!hasSearched) {
      // 未搜索时显示的提示
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isPerson ? Icons.person_search : Icons.group,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '输入${isPerson ? 'ID号或微信号' : '群ID号'}开始搜索',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    } else {
      // 模拟搜索结果
      return ListView.separated(
        itemCount: 5, // 模拟5条结果
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          return _buildResultItem(index, isPerson);
        },
      );
    }
  }

  Widget _buildResultItem(int index, bool isPerson) {
    final name = isPerson ? '用户_${_searchController.text}_$index' : '群聊_${_searchController.text}_$index';
    final subtitle = isPerson ? 'ID: ${10000 + index}' : '${20 + index}人 | 群主: 管理员$index';

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isPerson ? Colors.blue[100] : Colors.orange[100],
        child: Icon(
          isPerson ? Icons.person : Icons.group,
          color: isPerson ? Colors.blue : Colors.orange,
        ),
      ),
      title: Text(name),
      subtitle: Text(subtitle),
      trailing: TextButton(
        onPressed: () {
          // 添加好友或加入群聊
          _showAddDialog(name, isPerson);
        },
        style: TextButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          minimumSize: const Size(60, 32),
        ),
        child: Text(isPerson ? '添加' : '加入'),
      ),
      onTap: () {
        // 查看详情
        dev.log('查看${isPerson ? '用户' : '群聊'}详情: $name');
      },
    );
  }

  void _performSearch(String keyword) {
    final type = _tabController.index == 0 ? '用户' : '群聊';
    dev.log('搜索$type: $keyword');
    // 这里应该调用API进行实际搜索
  }

  void _showAddDialog(String name, bool isPerson) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${isPerson ? '添加好友' : '加入群聊'}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('确定要${isPerson ? '添加' : '加入'} $name ${isPerson ? '为好友' : ''}吗？'),
            if (isPerson)
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: '请输入验证信息',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  maxLines: 2,
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // 发送请求
              dev.log('${isPerson ? '添加好友' : '加入群聊'}: $name');
              // 显示结果提示
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('请求已发送，等待${isPerson ? '对方' : '管理员'}确认'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('确定', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }
}
