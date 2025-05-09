import 'package:flutter/material.dart';
import 'package:cc/core/services/log_service.dart';
import '../cubit/home_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cc/core/database/database_initializer.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:cc/core/database/mock_data_manager.dart';
import 'package:cc/core/constants/app_config.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  // 创建静态logger实例
  static final _logger = LogService('profile_page.dart');

  @override
  Widget build(BuildContext context) {
    _logger.d('ProfilePage build');
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

            const SizedBox(height: 16),

            // 开发者选项
            _buildDeveloperOptions(context),
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
            color: Colors.black.withAlpha(13),
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
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildListTile(
            icon: Icons.cleaning_services,
            title: '重置数据',
            subtitle: '清除所有数据，重新开始模拟',
            onTap: () {
              _showResetDataDialog(context);
            },
          ),
          const Divider(height: 1),
          _buildListTile(
            icon: Icons.data_array,
            title: '重新生成模拟数据',
            subtitle: '清空并重新生成应用使用的模拟联系人和消息数据',
            onTap: () async {
              // 显示加载对话框
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const AlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [CircularProgressIndicator(), SizedBox(height: 16), Text('正在重新生成模拟数据...')],
                  ),
                ),
              );

              // 重新生成模拟数据
              await MockDataManager.regenerateMockData();

              // 关闭加载对话框并显示确认消息
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('模拟数据已重新生成')),
                );
              }
            },
          ),
          const Divider(height: 1),
          _buildListTile(
            icon: Icons.payment,
            title: '支付',
            subtitle: '查看您的支付记录',
            onTap: () {
              _logger.d('点击支付');
            },
          ),
          const Divider(height: 1),
          _buildListTile(
            icon: Icons.favorite,
            title: '收藏',
            subtitle: '查看您的收藏内容',
            onTap: () {
              _logger.d('点击收藏');
            },
          ),
          const Divider(height: 1),
          _buildListTile(
            icon: Icons.photo_album,
            title: '相册',
            subtitle: '查看您的共享相册',
            onTap: () {
              _logger.d('点击相册');
            },
          ),
          const Divider(height: 1),
          _buildListTile(
            icon: Icons.settings,
            title: '设置',
            subtitle: '隐私、安全和通知设置',
            onTap: () {
              _logger.d('点击设置');
            },
          ),
          const Divider(height: 1),
          _buildListTile(
            icon: Icons.help_outline,
            title: '帮助与反馈',
            subtitle: '常见问题和提交反馈',
            onTap: () {
              _logger.d('点击帮助与反馈');
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

  // 显示重置数据确认对话框
  void _showResetDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('重置数据'),
        content: const Text('这将清除所有数据，包括联系人、会话和消息。\n\n此操作不可撤销，确定要继续吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // 关闭对话框
              _resetAllData(context);
            },
            child: const Text('确定重置', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // 重置所有数据
  Future<void> _resetAllData(BuildContext context) async {
    try {
      _logger.i('开始重置数据');

      // 显示加载指示器
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // 关闭数据库
      if (DatabaseInitializer.isInitialized) {
        await DatabaseInitializer.close();
      }

      // 获取应用文档目录
      final appDocDir = await getApplicationDocumentsDirectory();

      // 删除数据库文件
      _logger.i('数据库文件目录: $appDocDir');
      final isarFiles = await appDocDir.list().where((entity) => entity.path.endsWith('.isar') || entity.path.endsWith('.isar.lock')).toList();

      for (final file in isarFiles) {
        await file.delete();
        _logger.i('删除数据库文件: ${file.path}');
      }

      // 删除媒体文件
      final mediaDir = Directory('${appDocDir.path}/media');
      if (await mediaDir.exists()) {
        await mediaDir.delete(recursive: true);
        _logger.i('媒体文件已删除');
      }

      // 关闭加载指示器
      if (context.mounted) {
        Navigator.pop(context);

        // 显示确认对话框告知用户数据已重置，并提供退出应用选项
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('数据已重置'),
            content: const Text('所有数据已清除。为确保重置生效，应用需要重启。'),
            actions: [
              TextButton(
                onPressed: () {
                  // 退出应用
                  exit(0);
                },
                child: const Text('立即退出', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      }

      _logger.i('数据重置完成');
    } catch (e) {
      _logger.e('重置数据时出错', error: e);

      // 关闭加载指示器
      if (context.mounted) {
        Navigator.pop(context);

        // 显示错误消息
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('重置数据失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 构建开发者选项部分
  Widget _buildDeveloperOptions(BuildContext context) {
    final appConfig = AppConfig();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 16, top: 16, bottom: 8),
            child: Text('开发者选项', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
          ),

          // 模拟模式开关
          StatefulBuilder(
            builder: (context, setState) {
              return SwitchListTile(
                title: const Text('模拟模式'),
                subtitle: Text(appConfig.isSimulationMode ? '当前使用本地模拟数据，无需服务器' : '当前连接真实服务器，需要网络连接'),
                value: appConfig.isSimulationMode,
                activeColor: Colors.green,
                onChanged: (bool value) {
                  setState(() {
                    appConfig.isSimulationMode = value;
                    _logger.i('模拟模式已切换', extra: {'isSimulationMode': value});
                  });

                  // 显示提示
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(value ? '已启用模拟模式，应用将使用本地数据，重启应用后生效' : '已禁用模拟模式，应用将连接真实服务器，重启应用后生效'),
                      duration: const Duration(seconds: 5),
                      action: SnackBarAction(
                        label: '立即重启',
                        onPressed: () {
                          exit(0); // 退出应用
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),

          // 服务器URL设置
          ListTile(
            title: const Text('服务器URL'),
            subtitle: Text(appConfig.serverUrl),
            leading: const Icon(Icons.cloud, color: Colors.green),
            trailing: const Icon(Icons.edit, size: 20),
            onTap: () {
              _showServerUrlDialog(context, appConfig);
            },
          ),
        ],
      ),
    );
  }

  // 显示服务器URL设置对话框
  void _showServerUrlDialog(BuildContext context, AppConfig appConfig) {
    final controller = TextEditingController(text: appConfig.serverUrl);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('设置服务器URL'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: '服务器URL',
                hintText: 'http://localhost:3000',
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '提示：本地服务器通常使用localhost:3000，真实服务器请输入完整URL',
              style: TextStyle(fontSize: 12, color: Colors.grey),
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
              final newUrl = controller.text.trim();
              if (newUrl.isNotEmpty) {
                appConfig.serverUrl = newUrl;
                _logger.i('服务器URL已更新', extra: {'serverUrl': newUrl});

                Navigator.pop(context);

                // 显示提示
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('服务器URL已更新，重启应用后生效'),
                    duration: const Duration(seconds: 5),
                    action: SnackBarAction(
                      label: '立即重启',
                      onPressed: () {
                        exit(0); // 退出应用
                      },
                    ),
                  ),
                );
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }
}
