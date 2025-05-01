import 'package:flutter/material.dart';
import 'dart:developer' as dev;
import '../cubit/home_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key});

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    dev.log('ChatsPage build');
    return Scaffold(
      // AppBar: 自定义导航栏，包含标题、编辑按钮和新建聊天按钮
      // 顶部导航区配置了底部搜索栏作为扩展部分
      appBar: AppBar(
        // 中间标题
        title: const Text('消息', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // 禁用默认返回按钮

        // 左侧编辑按钮：底部对齐，点击进入多选模式
        leading: Container(
          padding: const EdgeInsets.only(bottom: 4),
          alignment: Alignment.bottomCenter,
          child: TextButton(
            onPressed: () {
              // 进入多选删除模式
              dev.log('进入多选删除模式');
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              '编辑',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ),

        // 右侧操作按钮区域 - 添加新聊天
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // 新建聊天窗口
              dev.log('新建聊天窗口');
            },
          ),
        ],
        centerTitle: true, // 标题居中显示

        // 底部搜索区域：包含搜索框和筛选按钮
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60), // 设置底部区域高度
          child: Container(
            color: Colors.green,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                // 搜索框：占据大部分空间，用于搜索聊天内容
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: '搜索',
                        prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                        isDense: true,
                        // 当有输入内容时显示清除按钮
                        suffixIcon: _isSearching
                            ? IconButton(
                                icon: const Icon(Icons.clear, color: Colors.grey, size: 18),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () {
                                  setState(() {
                                    _searchController.clear();
                                    _isSearching = false;
                                  });
                                },
                              )
                            : null,
                      ),
                      style: const TextStyle(fontSize: 14),
                      onChanged: (value) {
                        setState(() {
                          _isSearching = value.isNotEmpty;
                        });
                        // 搜索内容
                        dev.log('搜索内容: $value');
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // 筛选按钮：显示筛选选项的弹出菜单
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.filter_list, color: Colors.white, size: 20),
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      // 筛选功能
                      dev.log('打开筛选');
                      _showFilterDialog();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: ListView.separated(
        itemCount: 20, // 模拟数据数量
        separatorBuilder: (context, index) => const Divider(
          height: 1,
          indent: 72,
        ),
        itemBuilder: (context, index) {
          // 模拟聊天列表数据
          return _buildChatItem(
            name: '联系人 ${index + 1}',
            message: '这是最近的一条消息 ${index + 1}',
            time: '下午 ${(index % 12) + 1}:${index % 60 < 10 ? '0' : ''}${index % 60}',
            unreadCount: index % 3 == 0 ? index % 5 : 0,
            avatarUrl: 'https://picsum.photos/200?random=$index',
          );
        },
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '筛选会话',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.message, color: Colors.green),
              title: const Text('未读消息'),
              onTap: () {
                Navigator.pop(context);
                dev.log('筛选未读消息');
              },
            ),
            ListTile(
              leading: const Icon(Icons.group, color: Colors.green),
              title: const Text('群聊'),
              onTap: () {
                Navigator.pop(context);
                dev.log('筛选群聊');
              },
            ),
            ListTile(
              leading: const Icon(Icons.star, color: Colors.green),
              title: const Text('星标会话'),
              onTap: () {
                Navigator.pop(context);
                dev.log('筛选星标会话');
              },
            ),
          ],
        ),
      ),
    );
  }

  // 处理用户登出
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
              context.read<HomeCubit>().logout();
            },
            child: const Text('确定', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildChatItem({
    required String name,
    required String message,
    required String time,
    required int unreadCount,
    required String avatarUrl,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(avatarUrl),
        radius: 24,
      ),
      title: Text(
        name,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      subtitle: Row(
        children: [
          Expanded(
            child: Text(
              message,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            time,
            style: TextStyle(
              fontSize: 12,
              color: unreadCount > 0 ? Colors.green : Colors.grey,
            ),
          ),
          if (unreadCount > 0)
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: Text(
                unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else
            const SizedBox(height: 16),
        ],
      ),
      onTap: () {
        // 打开聊天详情页
        dev.log('打开聊天: $name');
      },
    );
  }
}
