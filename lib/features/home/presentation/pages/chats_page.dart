import 'package:flutter/material.dart';
import 'dart:developer' as dev;
import '../cubit/home_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatsPage extends StatelessWidget {
  const ChatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    dev.log('ChatsPage build');
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
