import 'package:flutter/material.dart';
import 'dart:developer' as dev;
import '../cubit/home_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    dev.log('ProfilePage build');
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _handleLogout(context);
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'settings',
                  child: Text('账号设置'),
                ),
                const PopupMenuItem<String>(
                  value: 'privacy',
                  child: Text('隐私设置'),
                ),
                const PopupMenuItem<String>(
                  value: 'feedback',
                  child: Text('反馈建议'),
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 个人信息卡片
            _buildProfileCard(),

            const SizedBox(height: 16),

            // 功能列表
            _buildFunctionList(context),
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

  Widget _buildProfileCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // 头像
          CircleAvatar(
            radius: 40,
            backgroundImage: const NetworkImage('https://picsum.photos/200?random=99'),
            backgroundColor: Colors.green[50],
          ),
          const SizedBox(width: 20),

          // 个人信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '用户昵称',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '手机号: +86 138****1234',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.qr_code,
                        size: 16,
                        color: Colors.green[700],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '我的二维码',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 编辑按钮
          Icon(
            Icons.edit,
            color: Colors.grey[400],
          ),
        ],
      ),
    );
  }

  Widget _buildFunctionList(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildListTile(
            icon: Icons.payment,
            title: '支付',
            subtitle: '查看您的支付记录',
            onTap: () {
              dev.log('点击支付');
            },
          ),
          const Divider(height: 1),
          _buildListTile(
            icon: Icons.favorite,
            title: '收藏',
            subtitle: '查看您的收藏内容',
            onTap: () {
              dev.log('点击收藏');
            },
          ),
          const Divider(height: 1),
          _buildListTile(
            icon: Icons.photo_album,
            title: '相册',
            subtitle: '查看您的共享相册',
            onTap: () {
              dev.log('点击相册');
            },
          ),
          const Divider(height: 1),
          _buildListTile(
            icon: Icons.settings,
            title: '设置',
            subtitle: '隐私、安全和通知设置',
            onTap: () {
              dev.log('点击设置');
            },
          ),
          const Divider(height: 1),
          _buildListTile(
            icon: Icons.help_outline,
            title: '帮助与反馈',
            subtitle: '常见问题和提交反馈',
            onTap: () {
              dev.log('点击帮助与反馈');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.green[50],
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.green,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }
}
