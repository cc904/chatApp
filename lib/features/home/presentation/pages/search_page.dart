import 'package:flutter/material.dart';
import 'dart:developer' as dev;
import 'package:flutter/services.dart';

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
  String _selectedFilter = '全部'; // 当前选中的筛选选项

  // 筛选选项
  final List<String> _personFilters = ['全部', '国内', '国外', '最近活跃'];
  final List<String> _groupFilters = ['全部', '游戏', '学习', '旅行', '工作'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        // 切换标签时清空搜索和重置筛选
        _searchController.clear();
        _isSearching = false;
        _hasSearched = false;
        _selectedFilter = '全部';
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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '添加${_tabController.index == 0 ? '好友' : '群聊'}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
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
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Material(
              elevation: 2,
              shadowColor: Colors.black26,
              borderRadius: BorderRadius.circular(8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: _tabController.index == 0 ? '输入ID号或手机号搜索' : '输入群ID号搜索',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: const Icon(Icons.search, color: Colors.green),
                  suffixIcon: _isSearching
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                  _isSearching = false;
                                  _hasSearched = false;
                                });
                              },
                            ),
                            Container(
                              height: 24,
                              width: 1,
                              color: Colors.grey[300],
                              margin: const EdgeInsets.symmetric(vertical: 8),
                            ),
                            IconButton(
                              icon: const Icon(Icons.search, color: Colors.green),
                              onPressed: () {
                                if (_searchController.text.isNotEmpty) {
                                  setState(() {
                                    _hasSearched = true;
                                  });
                                  _performSearch(_searchController.text);
                                  // 收起键盘
                                  FocusScope.of(context).unfocus();
                                }
                              },
                            ),
                          ],
                        )
                      : IconButton(
                          icon: const Icon(Icons.search, color: Colors.green),
                          onPressed: () {
                            if (_searchController.text.isNotEmpty) {
                              setState(() {
                                _hasSearched = true;
                              });
                              _performSearch(_searchController.text);
                              // 收起键盘
                              FocusScope.of(context).unfocus();
                            }
                          },
                        ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                ),
                textInputAction: TextInputAction.search,
                style: const TextStyle(fontSize: 16),
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
          ),

          // 筛选选项
          if (_hasSearched)
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(10),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _tabController.index == 0 ? _personFilters.length : _groupFilters.length,
                itemBuilder: (context, index) {
                  final filter = _tabController.index == 0 ? _personFilters[index] : _groupFilters[index];
                  final isSelected = _selectedFilter == filter;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedFilter = filter;
                          });
                        }
                      },
                      backgroundColor: Colors.grey[100],
                      selectedColor: Colors.green[50],
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.green : Colors.black87,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  );
                },
              ),
            ),

          // 搜索结果或提示区域
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // 找人的搜索结果
                _buildSearchResultsView(_hasSearched, true),

                // 找群的搜索结果
                _buildSearchResultsView(_hasSearched, false),
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
      return Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isPerson ? Colors.blue[50] : Colors.orange[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPerson ? Icons.person_search : Icons.group_add,
                  size: 60,
                  color: isPerson ? Colors.blue : Colors.orange,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '输入${isPerson ? 'ID号或手机号' : '群ID号'}开始搜索',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                isPerson ? '可以通过ID号或手机号找到好友' : '输入群ID可以快速找到想要加入的群聊',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // 模拟搜索结果
      return Container(
        color: Colors.white,
        child: ListView.separated(
          itemCount: 5, // 模拟5条结果
          separatorBuilder: (context, index) => const Divider(height: 1, indent: 72),
          itemBuilder: (context, index) {
            return _buildResultItem(index, isPerson);
          },
        ),
      );
    }
  }

  Widget _buildResultItem(int index, bool isPerson) {
    final name = isPerson ? '用户_${_searchController.text}_$index' : '群聊_${_searchController.text}_$index';
    final subtitle = isPerson ? 'ID: ${10000 + index}' : '${20 + index}人 | 群主: 管理员$index';
    final description = isPerson
        ? '地区: ${index % 2 == 0 ? '中国' : '国外'} | 在线状态: ${index % 3 == 0 ? '在线' : '离线'}'
        : '简介: 这是一个${_selectedFilter == '全部' ? ['游戏', '学习', '旅行', '工作'][index % 4] : _selectedFilter}相关的群聊';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        radius: 28,
        backgroundColor: isPerson ? Colors.blue[100] : Colors.orange[100],
        child: Icon(
          isPerson ? Icons.person : Icons.group,
          color: isPerson ? Colors.blue : Colors.orange,
          size: 32,
        ),
      ),
      title: Row(
        children: [
          Text(
            name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 8),
          if (index % 3 == 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Text(
                isPerson ? '好友' : '已加入',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.green[800],
                ),
              ),
            ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 13,
            ),
          ),
        ],
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
      onTap: () {
        // 进入用户/群聊详情页
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => isPerson
                ? UserDetailPage(
                    name: name,
                    userId: (10000 + index).toString(),
                    description: description,
                    isOnline: index % 3 == 0,
                    isFriend: index % 3 == 0,
                  )
                : GroupDetailPage(
                    name: name,
                    groupId: (20000 + index).toString(),
                    description: description,
                    memberCount: 20 + index,
                    isJoined: index % 3 == 0,
                  ),
          ),
        );
      },
    );
  }

  void _performSearch(String keyword) {
    final type = _tabController.index == 0 ? '用户' : '群聊';
    dev.log('搜索$type: $keyword, 筛选条件: $_selectedFilter');
    // 这里应该调用API进行实际搜索
  }
}

class UserDetailPage extends StatelessWidget {
  final String name;
  final String userId;
  final String description;
  final bool isOnline;
  final bool isFriend;

  const UserDetailPage({
    super.key,
    required this.name,
    required this.userId,
    required this.description,
    this.isOnline = false,
    this.isFriend = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('个人资料'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // 更多操作菜单
              showModalBottomSheet(
                context: context,
                builder: (context) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.block),
                      title: const Text('拉黑该用户'),
                      onTap: () {
                        Navigator.pop(context);
                        dev.log('拉黑用户: $name');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.report),
                      title: const Text('举报'),
                      onTap: () {
                        Navigator.pop(context);
                        dev.log('举报用户: $name');
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 用户资料卡片
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // 头像和基本信息
                  Row(
                    children: [
                      // 头像
                      Hero(
                        tag: 'avatar-$userId',
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.blue[100],
                          child: const Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),

                      // 基本信息
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // ID显示和复制按钮
                            Row(
                              children: [
                                Text(
                                  'ID: $userId',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                InkWell(
                                  onTap: () {
                                    Clipboard.setData(ClipboardData(text: userId));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('已复制用户ID到剪贴板'),
                                        backgroundColor: Colors.green,
                                        duration: Duration(seconds: 1),
                                      ),
                                    );
                                  },
                                  child: const Icon(
                                    Icons.copy,
                                    size: 16,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),
                            // 在线状态
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isOnline ? Colors.green : Colors.grey,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  isOnline ? '在线' : '离线',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // 添加好友按钮
                  if (!isFriend)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _showAddFriendDialog(context, name, userId);
                        },
                        icon: const Icon(Icons.person_add),
                        label: const Text('添加好友'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // 详细资料
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '详细资料',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildInfoItem('地区', '中国'),
                  _buildInfoItem('标签', '#社交 #工作'),
                  _buildInfoItem('状态', description),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // 操作按钮
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: isFriend
                  ? SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // 发送消息
                          dev.log('发送消息给: $name');
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.message),
                        label: const Text('发送消息'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    )
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _showAddFriendDialog(context, name, userId);
                        },
                        icon: const Icon(Icons.person_add),
                        label: const Text('添加好友'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddFriendDialog(BuildContext context, String name, String userId) {
    final TextEditingController verificationController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          '添加好友',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '确定要添加 $name 为好友吗？',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: verificationController,
              decoration: InputDecoration(
                hintText: '请输入验证信息',
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // 发送请求
              final verification = verificationController.text;
              dev.log('添加好友: $name, ID: $userId, 验证信息: $verification');

              // 显示结果提示
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text('请求已发送，等待对方确认'),
                      ),
                    ],
                  ),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  margin: const EdgeInsets.all(8),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}

class GroupDetailPage extends StatelessWidget {
  final String name;
  final String groupId;
  final String description;
  final int memberCount;
  final bool isJoined;

  const GroupDetailPage({
    super.key,
    required this.name,
    required this.groupId,
    required this.description,
    required this.memberCount,
    this.isJoined = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('群聊资料'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 群资料卡片
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // 头像和基本信息
                  Row(
                    children: [
                      // 头像
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.orange[100],
                        child: const Icon(
                          Icons.group,
                          size: 50,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 20),

                      // 基本信息
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // ID显示和复制按钮
                            Row(
                              children: [
                                Text(
                                  'ID: $groupId',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                InkWell(
                                  onTap: () {
                                    Clipboard.setData(ClipboardData(text: groupId));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('已复制群ID到剪贴板'),
                                        backgroundColor: Colors.green,
                                        duration: Duration(seconds: 1),
                                      ),
                                    );
                                  },
                                  child: const Icon(
                                    Icons.copy,
                                    size: 16,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),
                            // 群人数
                            Text(
                              '成员: $memberCount人',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // 加入群聊按钮
                  if (!isJoined)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _showJoinGroupDialog(context, name, groupId);
                        },
                        icon: const Icon(Icons.group_add),
                        label: const Text('加入群聊'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // 打开群聊
                          dev.log('打开群聊: $name');
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.message),
                        label: const Text('打开群聊'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.green,
                          side: const BorderSide(color: Colors.green),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // 群公告
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '群公告',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // 群成员
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '群成员($memberCount)',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '查看全部 >',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      4,
                      (index) => Column(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: index == 0 ? Colors.red[100] : Colors.blue[100],
                            child: Icon(
                              index == 0 ? Icons.star : Icons.person,
                              color: index == 0 ? Colors.red : Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            index == 0 ? '群主' : '成员$index',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showJoinGroupDialog(BuildContext context, String name, String groupId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          '加入群聊',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '确定要加入 $name 群聊吗？',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // 发送请求
              dev.log('加入群聊: $name, ID: $groupId');

              // 显示结果提示
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text('请求已发送，等待管理员确认'),
                      ),
                    ],
                  ),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  margin: const EdgeInsets.all(8),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
