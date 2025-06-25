import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/database/database_initializer.dart';
import 'package:cc/features/auth/presentation/pages/auth_page.dart';
import 'package:cc/core/services/secure_storage_service.dart';
import 'package:cc/core/constants/app_config.dart';
import 'package:cc/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:cc/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:cc/features/profile/presentation/pages/my_qr_code_page.dart';
import 'package:cc/core/widgets/user_avatar.dart';
import 'package:cc/features/profile/data/repositories/profile_repository.dart';
import 'package:cc/core/database/models/current_user.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with AutomaticKeepAliveClientMixin {
  static final _logger = LogService.instance;

  // 直接创建ProfileCubit，不需要复杂的初始化逻辑
  late final ProfileCubit _profileCubit;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _logger.i('ProfilePage 初始化开始');

    // 直接创建ProfileCubit实例
    _profileCubit = ProfileCubit(repository: ProfileRepository());
    _logger.i('ProfileCubit 创建成功');
  }

  @override
  void dispose() {
    _logger.i('ProfilePage 开始销毁');
    _profileCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required by AutomaticKeepAliveClientMixin
    _logger.d('ProfilePage build 开始');

    return BlocProvider.value(
      value: _profileCubit,
      child: Scaffold(
        body: SafeArea(
          child: BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, state) {
              _logger.d(
                  'ProfilePage state: ${state.status}, user: ${state.user?.name}');

              // 如果正在加载且没有用户数据，显示加载指示器
              if (state.status == ProfileStatus.loading && state.user == null) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('加载用户信息中...'),
                    ],
                  ),
                );
              }

              // 如果加载失败，显示错误信息
              if (state.status == ProfileStatus.error) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '加载失败: ${state.error ?? "未知错误"}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          _logger.i('用户点击重试按钮');
                          _profileCubit.refreshUserInfo();
                        },
                        child: const Text('重试'),
                      ),
                    ],
                  ),
                );
              }

              // 正常显示页面内容
              return SingleChildScrollView(
                child: Column(
                  children: [
                    // 标题和操作按钮
                    _buildHeader(),

                    // 个人信息卡片
                    _buildProfileCard(state.user),

                    const SizedBox(height: 16),

                    // 功能列表
                    _buildFunctionList(),

                    const SizedBox(height: 16),

                    // 开发者选项
                    _buildDeveloperOptions(),

                    const SizedBox(height: 24),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '我的',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'refresh':
                  _logger.i('用户手动刷新个人信息');
                  _profileCubit.refreshUserInfo();
                  break;
                case 'logout':
                  _handleLogout();
                  break;
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'refresh',
                  child: Row(
                    children: [
                      Icon(Icons.refresh, size: 20),
                      SizedBox(width: 8),
                      Text('刷新'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'settings',
                  child: Row(
                    children: [
                      Icon(Icons.settings, size: 20),
                      SizedBox(width: 8),
                      Text('账号设置'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'privacy',
                  child: Row(
                    children: [
                      Icon(Icons.privacy_tip, size: 20),
                      SizedBox(width: 8),
                      Text('隐私设置'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'feedback',
                  child: Row(
                    children: [
                      Icon(Icons.feedback, size: 20),
                      SizedBox(width: 8),
                      Text('反馈建议'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, size: 20, color: Colors.red),
                      SizedBox(width: 8),
                      Text('退出登录', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ];
            },
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(CurrentUser? user) {
    _logger.d('构建个人信息卡片, user: ${user?.name}');

    return GestureDetector(
      onTap: () {
        _logger.i('用户点击编辑个人信息');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProvider.value(
              value: _profileCubit,
              child: const EditProfilePage(),
            ),
          ),
        );
      },
      child: Container(
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
            UserAvatar(
              avatarUrl: user?.avatar,
              name: user?.name ?? '用户',
              radius: 40,
              backgroundColor: Colors.green,
            ),
            const SizedBox(width: 20),

            // 个人信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.name ?? '加载中...',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.phone?.isNotEmpty == true
                        ? '手机号: ${user!.phone}'
                        : '手机号: 未绑定',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      _logger.i('用户点击我的二维码');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BlocProvider.value(
                            value: _profileCubit,
                            child: const MyQRCodePage(),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
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
      ),
    );
  }

  Widget _buildFunctionList() {
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
            icon: Icons.photo_album,
            title: '相册',
            subtitle: '查看您的共享相册',
            onTap: () {
              _logger.d('点击相册');
            },
          ),
          const Divider(height: 1, indent: 70),
          _buildListTile(
            icon: Icons.favorite,
            title: '收藏',
            subtitle: '查看您的收藏内容',
            onTap: () {
              _logger.d('点击收藏');
            },
          ),
          const Divider(height: 1, indent: 70),
          _buildListTile(
            icon: Icons.settings,
            title: '设置',
            subtitle: '隐私、安全和通知设置',
            onTap: () {
              _logger.d('点击设置');
            },
          ),
          const Divider(height: 1, indent: 70),
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

  // 处理用户登出
  void _handleLogout() {
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
            onPressed: () async {
              Navigator.pop(context); // 关闭对话框

              // 显示加载指示器
              if (context.mounted) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              try {
                // 直接使用SecureStorageService清除用户凭据
                final secureStorage = SecureStorageService.instance;
                await secureStorage.clearUserCredentials();

                _logger.i('用户已登出，凭据已清除');

                // 关闭数据库连接
                if (DatabaseInitializer.isInitialized) {
                  await DatabaseInitializer.close();
                  _logger.i('数据库连接已关闭');
                }
              } catch (e) {
                _logger.e('登出过程中发生错误', error: e);
              }

              // 关闭加载指示器并导航到登录页面
              if (context.mounted) {
                Navigator.pop(context); // 关闭加载对话框

                // 使用MaterialPageRoute导航到AuthPage，并清除之前的路由
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const AuthPage()),
                  (route) => false,
                );
              }
            },
            child: const Text('确定', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // 显示重置数据确认对话框
  void _showResetDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('重置数据'),
        content: const Text('这将清除所有数据,包括联系人、会话和消息。\n\n此操作不可撤销,确定要继续吗？'),
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

      // 使用ProfileRepository的resetAllData方法
      await _profileCubit.resetAllData();

      // 关闭加载指示器
      if (context.mounted) {
        Navigator.pop(context);

        // 显示确认对话框告知用户数据已重置
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('数据已重置'),
            content: const Text('所有数据已清除。为确保重置生效,应用需要重启。'),
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
    } catch (error) {
      _logger.e('重置数据时出错', error: error);

      // 关闭加载指示器
      if (context.mounted) {
        Navigator.pop(context);

        // 显示错误消息
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('重置数据失败: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 构建开发者选项部分
  Widget _buildDeveloperOptions() {
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
            icon: Icons.info_outline,
            title: '查看用户信息',
            subtitle: '显示当前用户的详细信息',
            onTap: () {
              _showCurrentUserInfo(context);
            },
          ),
          const Divider(height: 1, indent: 70),
          _buildListTile(
            icon: Icons.storage,
            title: '调试数据库状态',
            subtitle: '检查数据库中的用户信息',
            onTap: () {
              _debugDatabaseStatus(context);
            },
          ),
          const Divider(height: 1, indent: 70),
          _buildListTile(
            icon: Icons.cleaning_services,
            title: '重置数据',
            subtitle: '清除所有数据,重新开始模拟',
            onTap: () {
              _showResetDataDialog(context);
            },
          ),
          const Divider(height: 1, indent: 70),
          _buildListTile(
            icon: Icons.refresh,
            title: '刷新令牌',
            subtitle: '测试令牌刷新功能',
            onTap: () {
              _testTokenRefresh(context);
            },
          ),
          const Divider(height: 1, indent: 70),
          _buildListTile(
            icon: Icons.dns,
            title: '服务器设置',
            subtitle: '当前: ${AppConfig().currentServerName}',
            onTap: () {
              _showServerSettingsDialog();
            },
          ),
        ],
      ),
    );
  }

  // 显示当前用户信息对话框
  void _showCurrentUserInfo(BuildContext context) {
    final state = _profileCubit.state;
    final user = state.user;

    if (user == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('错误'),
          content: const Text('用户信息未加载'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('关闭'),
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('当前用户信息'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildInfoRow('用户ID', user.userId),
                _buildInfoRow('用户名', user.name),
                _buildInfoRow('头像URL', user.avatar ?? '未设置'),
                _buildInfoRow('手机号', user.phone ?? '未绑定'),
                _buildInfoRow('邮箱', user.email ?? '未绑定'),
                _buildInfoRow('状态', user.status ?? '未设置'),
                _buildInfoRow('令牌', '${user.token.substring(0, 20)}...'),
                _buildInfoRow('数据库ID', user.id.toString()),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  // 构建信息行
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // 测试令牌刷新功能
  void _testTokenRefresh(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Token刷新测试'),
        content: const Text('此功能需要Token刷新服务的支持'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _logger.i('测试Token刷新');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Token刷新测试功能暂未实现')),
              );
            },
            child: const Text('测试'),
          ),
        ],
      ),
    );
  }

  // 调试数据库状态
  Future<void> _debugDatabaseStatus(BuildContext context) async {
    _logger.i('🔍 开始调试数据库状态');

    try {
      // 检查数据库初始化状态
      final isDbInitialized = DatabaseInitializer.isInitialized;
      _logger.i('数据库初始化状态: $isDbInitialized');

      String debugInfo = '''
🔍 数据库调试信息
===================

数据库初始化: ${isDbInitialized ? '✅' : '❌'}
''';

      if (isDbInitialized) {
        // 使用ProfileRepository查询用户信息
        final profileRepo = ProfileRepository();
        final user = await profileRepo.getCurrentUser();

        debugInfo += '''
数据库用户存在: ${user != null ? '✅' : '❌'}
''';

        if (user != null) {
          debugInfo += '''

📝 数据库中的用户信息:
- 数据库ID: ${user.id}
- 用户ID: ${user.userId}
- 用户名: ${user.name}
- 头像: ${user.avatar ?? '未设置'}
- 手机号: ${user.phone ?? '未设置'}
- 邮箱: ${user.email ?? '未设置'}
- 状态: ${user.status ?? '未设置'}
- Token前缀: ${user.token.length > 20 ? '${user.token.substring(0, 20)}...' : user.token}
''';
        } else {
          debugInfo += '''

⚠️ 数据库中没有用户记录！
这可能是登录后用户信息没有正确保存的原因。
''';
        }
      }

      // 检查安全存储
      final secureStorage = SecureStorageService.instance;
      final token = await secureStorage.getToken();
      final userId = await secureStorage.getUserId();

      debugInfo += '''

🔐 安全存储信息:
- Token存在: ${token != null ? '✅' : '❌'}
- 用户ID: ${userId ?? '不存在'}
''';

      if (token != null) {
        debugInfo += '''
- Token前缀: ${token.length > 20 ? '${token.substring(0, 20)}...' : token}
''';
      }

      // 检查ProfileCubit状态
      final cubitState = _profileCubit.state;
      debugInfo += '''

🎛️ ProfileCubit状态:
- 状态: ${cubitState.status}
- 用户存在: ${cubitState.user != null ? '✅' : '❌'}
- 错误信息: ${cubitState.error ?? '无'}
''';

      if (cubitState.user != null) {
        final user = cubitState.user!;
        debugInfo += '''
- Cubit用户名: ${user.name}
- Cubit头像: ${user.avatar ?? '未设置'}
''';
      }

      _logger.i('调试信息收集完成');

      if (!context.mounted) return;

      // 显示调试信息对话框
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('🔍 数据库调试信息'),
          content: SizedBox(
            width: double.maxFinite,
            height: 500,
            child: SingleChildScrollView(
              child: Text(
                debugInfo,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('关闭'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _fixUserDataIssue(context);
              },
              child: const Text('尝试修复'),
            ),
          ],
        ),
      );
    } catch (error) {
      _logger.e('调试数据库状态失败', error: error);

      if (!context.mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('❌ 调试失败'),
          content: Text('无法获取调试信息：$error'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('关闭'),
            ),
          ],
        ),
      );
    }
  }

  // 尝试修复用户数据问题
  Future<void> _fixUserDataIssue(BuildContext context) async {
    _logger.i('🔧 尝试修复用户数据问题');

    try {
      // 显示加载对话框
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('正在尝试修复...'),
            ],
          ),
        ),
      );

      // 尝试从安全存储恢复用户信息到数据库
      final secureStorage = SecureStorageService.instance;
      final userInfo = await secureStorage.getFullUserInfo();

      if (userInfo != null && DatabaseInitializer.isInitialized) {
        await DatabaseInitializer.isar.writeTxn(() async {
          await DatabaseInitializer.isar.currentUsers.clear();
          await DatabaseInitializer.isar.currentUsers.put(userInfo);
        });

        _logger.i('用户信息已从安全存储恢复到数据库');

        // 刷新ProfileCubit
        await _profileCubit.refreshUserInfo();

        if (context.mounted) {
          Navigator.pop(context); // 关闭加载对话框

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ 用户信息修复成功，请查看页面更新'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        _logger.w('无法修复：安全存储中也没有用户信息');

        if (context.mounted) {
          Navigator.pop(context); // 关闭加载对话框

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ 修复失败：没有找到有效的用户信息'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (error) {
      _logger.e('修复用户数据失败', error: error);

      if (context.mounted) {
        Navigator.pop(context); // 关闭加载对话框

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ 修复失败：$error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 显示服务器设置对话框
  void _showServerSettingsDialog() {
    final appConfig = AppConfig();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('服务器设置'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '当前服务器: ${appConfig.currentServerName}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'URL: ${appConfig.serverUrl}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            const Text('可用服务器列表:'),
            const SizedBox(height: 8),
            ...appConfig.serverDisplayInfo.asMap().entries.map((entry) {
              final index = entry.key;
              final server = entry.value;
              final isActive = index == appConfig.currentServerIndex;

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 2),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.green.withAlpha(25)
                      : Colors.grey.withAlpha(25),
                  borderRadius: BorderRadius.circular(4),
                  border: isActive ? Border.all(color: Colors.green) : null,
                ),
                child: Row(
                  children: [
                    Icon(
                      isActive
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: isActive ? Colors.green : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            server['name']!,
                            style: TextStyle(
                              fontWeight: isActive
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          Text(
                            server['url']!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isActive)
                      TextButton(
                        onPressed: () {
                          appConfig.setServerUrl(server['url']!);
                          Navigator.pop(context);
                          setState(() {});

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('已切换到: ${server['name']}'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                        child: const Text('切换'),
                      ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.info_outline, size: 16, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '连接失败时会自动尝试备用服务器',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              appConfig.resetToFirstServer();
              Navigator.pop(context);
              setState(() {});

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('已重置到主服务器'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            child: const Text('重置'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}
