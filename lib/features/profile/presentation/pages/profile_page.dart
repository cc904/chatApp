import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/database/database_initializer.dart';
import 'package:cc/features/auth/presentation/pages/auth_page.dart';
import 'package:cc/core/services/secure_storage_service.dart';
import 'package:cc/core/services/enhanced_token_manager.dart';
import 'package:cc/core/services/auth_token_sync_service.dart';
import 'package:cc/core/utils/debug_commands.dart';
import 'package:cc/core/constants/app_config.dart';
import 'package:cc/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:cc/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:cc/features/profile/presentation/pages/my_qr_code_page.dart';
import 'package:cc/core/widgets/user_avatar.dart';
import 'package:cc/features/profile/data/repositories/profile_repository.dart';
import 'package:cc/core/database/models/current_user.dart';
import 'package:cc/features/chat/domain/repositories/chats_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:cc/features/profile/presentation/pages/language_settings_page.dart';
import 'package:cc/core/l10n/app_localizations.dart';

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

              final localizations = AppLocalizations.of(context);

              // 如果正在加载且没有用户数据，显示加载指示器
              if (state.status == ProfileStatus.loading && state.user == null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(localizations.loadingUserInfo),
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
                        '${localizations.loadFailed}: ${state.error ?? localizations.unknownError}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          _logger.i('用户点击重试按钮');
                          _profileCubit.refreshUserInfo();
                        },
                        child: Text(localizations.retry),
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
                    _buildHeader(localizations),

                    // 个人信息卡片
                    _buildProfileCard(state.user, localizations),

                    const SizedBox(height: 16),

                    // 功能列表
                    _buildFunctionList(localizations),

                    const SizedBox(height: 16),

                    // 开发者选项
                    _buildDeveloperOptions(localizations),

                    const SizedBox(height: 24),

                    // 调试模式下显示用户信息诊断按钮
                    if (kDebugMode)
                      ListTile(
                        leading: const Icon(Icons.bug_report),
                        title: Text(localizations.userInfoDiagnosis),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () async {
                          await _showUserInfoDiagnostic(context);
                        },
                      ),

                    // 调试模式下显示消息排序测试按钮
                    if (kDebugMode)
                      ListTile(
                        leading: const Icon(Icons.sort),
                        title: Text(localizations.messageSort),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () async {
                          await _testMessageSorting(context);
                        },
                      ),

                    // 调试模式下显示同步时间管理按钮
                    if (kDebugMode)
                      ListTile(
                        leading: const Icon(Icons.sync),
                        title: Text(localizations.conversationSyncManagement),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () async {
                          await _showSyncManagement(context);
                        },
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations localizations) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Stack(
        children: [
          // 居中的标题
          Align(
            alignment: Alignment.center,
            child: Text(
              localizations.myProfile,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // 右侧的菜单按钮
          Positioned(
            right: 0,
            child: PopupMenuButton<String>(
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
                  PopupMenuItem<String>(
                    value: 'refresh',
                    child: Row(
                      children: [
                        const Icon(Icons.refresh, size: 20),
                        const SizedBox(width: 8),
                        Text(localizations.refreshProfile),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'settings',
                    child: Row(
                      children: [
                        const Icon(Icons.settings, size: 20),
                        const SizedBox(width: 8),
                        Text(localizations.accountSecurity),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'privacy',
                    child: Row(
                      children: [
                        const Icon(Icons.privacy_tip, size: 20),
                        const SizedBox(width: 8),
                        Text(localizations.privacySettings),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'feedback',
                    child: Row(
                      children: [
                        const Icon(Icons.feedback, size: 20),
                        const SizedBox(width: 8),
                        Text(localizations.feedback),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(
                      children: [
                        const Icon(Icons.logout, size: 20, color: Colors.red),
                        const SizedBox(width: 8),
                        Text(localizations.logout,
                            style: const TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ];
              },
              icon: const Icon(Icons.more_vert),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(CurrentUser? user, AppLocalizations localizations) {
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
                        ? '${localizations.phoneNumber}: ${user!.phone}'
                        : '${localizations.phoneNumber}: ${localizations.phoneNotBound}',
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
                            localizations.myQRCode,
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

  Widget _buildFunctionList(AppLocalizations localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          child: Text(
            localizations.settings,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              // 账号与安全
              ListTile(
                leading: const Icon(Icons.security),
                title: Text(localizations.accountSecurity),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  _logger.d('点击账号与安全');
                  // TODO: 导航到账号与安全页面
                },
              ),
              const Divider(height: 1),

              // 隐私设置
              ListTile(
                leading: const Icon(Icons.privacy_tip),
                title: Text(localizations.privacySettings),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  _logger.d('点击隐私设置');
                  // TODO: 导航到隐私设置页面
                },
              ),
              const Divider(height: 1),

              // 通知设置
              ListTile(
                leading: const Icon(Icons.notifications),
                title: Text(localizations.notificationSettings),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  _logger.d('点击通知设置');
                  // TODO: 导航到通知设置页面
                },
              ),
              const Divider(height: 1),

              // 语言设置
              ListTile(
                leading: const Icon(Icons.language),
                title: Text(localizations.language),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  _logger.d('点击语言设置');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LanguageSettingsPage(),
                    ),
                  );
                },
              ),
              const Divider(height: 1),

              // 关于我们
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(localizations.aboutUs),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  _logger.d('点击关于我们');
                  // TODO: 导航到关于我们页面
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 构建开发者选项
  Widget _buildDeveloperOptions(AppLocalizations localizations) {
    if (!kDebugMode) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          child: Text(
            localizations.developerOptions,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(localizations.viewUserInfo),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  _showCurrentUserInfo(context);
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.storage),
                title: Text(localizations.debugDatabaseStatus),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  _debugDatabaseStatus(context);
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.token),
                title: Text(localizations.tokenStatusDiagnosis),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  _diagnoseTokenStatus(context);
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.cleaning_services),
                title: Text(localizations.resetData),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  _showResetDataDialog(context);
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.refresh),
                title: Text(localizations.refreshToken),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  _performTokenRefreshTest(context);
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.dns),
                title: Text(localizations.serverSettings),
                subtitle: Text(
                    '${localizations.currentServer}: ${AppConfig().currentServerName}'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  _showServerSettingsDialog();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 处理用户登出
  void _handleLogout() {
    final localizations = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.confirmLogout),
        content: Text(localizations.confirmLogoutMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.cancel),
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
                // 清除所有认证信息
                final secureStorage = SecureStorageService();

                // 1. 清除用户凭据
                await secureStorage.clearUserCredentials();
                _logger.i('用户凭据已清除');

                // 2. 清除所有Token
                await secureStorage.clearAllTokens();
                _logger.i('所有Token已清除');

                // 3. 清除所有服务的Token
                AuthTokenSyncService.instance.clearTokenFromAllServices();
                _logger.i('所有服务的Token已清除');

                // 关闭数据库连接
                if (DatabaseInitializer.isInitialized) {
                  await DatabaseInitializer.close();
                  _logger.i('数据库连接已关闭');
                }

                _logger.i('用户已完全登出，所有认证信息已清除');
              } catch (e) {
                _logger.e(localizations.logoutFailed, error: e);
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
            child: Text(localizations.confirm,
                style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // 显示重置数据确认对话框
  void _showResetDataDialog(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.resetData),
        content: Text(localizations.resetDataWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // 关闭对话框
              _resetAllData(context);
            },
            child: Text(localizations.confirmReset,
                style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // 重置所有数据
  Future<void> _resetAllData(BuildContext context) async {
    final localizations = AppLocalizations.of(context);

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
            title: Text(localizations.dataResetComplete),
            content: Text(localizations.dataResetCompleteMessage),
            actions: [
              TextButton(
                onPressed: () {
                  // 退出应用
                  exit(0);
                },
                child: Text(localizations.exitNow,
                    style: const TextStyle(color: Colors.red)),
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
            content: Text('${localizations.resetDataFailed}: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 显示当前用户信息对话框
  void _showCurrentUserInfo(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final state = _profileCubit.state;
    final user = state.user;

    if (user == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(localizations.errorOccurred),
          content: Text(localizations.noUserInfoLoaded),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(localizations.close),
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.currentUserInfo),
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
                _buildInfoRow('认证状态', '使用新多Token系统'),
                _buildInfoRow('数据库ID', user.id.toString()),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.close),
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

  // 执行Token刷新测试
  Future<void> _performTokenRefreshTest(BuildContext context) async {
    final localizations = AppLocalizations.of(context);
    _logger.i('测试Token刷新');

    try {
      // 显示加载对话框
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(localizations.testTokenStatus),
            ],
          ),
        ),
      );

      // 导入EnhancedTokenManager
      final tokenManager = EnhancedTokenManager.instance;

      // 检查当前Token状态
      final tokenStatus = await tokenManager.getTokenStatus();
      final apiToken = await tokenManager.getApiToken();
      final socketToken = await tokenManager.getSocketToken();

      // 🔍 详细Token状态诊断
      await DebugCommands.diagnoseTokenStatus();

      // 关闭加载对话框
      if (context.mounted) Navigator.pop(context);

      // 构建测试结果
      String testResult = '''
🔍 Token状态测试结果
===================

📊 Token状态摘要:
''';

      // 添加Token状态信息
      if (tokenStatus['accessToken'] != null) {
        final accessTokenInfo =
            tokenStatus['accessToken'] as Map<String, dynamic>;
        testResult += '''
- Access Token: ${accessTokenInfo['exists'] == true ? '✅存在' : '❌不存在'}
- 有效性: ${accessTokenInfo['valid'] == true ? '✅有效' : '❌无效'}
''';
      }

      if (tokenStatus['refreshToken'] != null) {
        final refreshTokenInfo =
            tokenStatus['refreshToken'] as Map<String, dynamic>;
        testResult += '''
- Refresh Token: ${refreshTokenInfo['exists'] == true ? '✅存在' : '❌不存在'}
- 有效性: ${refreshTokenInfo['valid'] == true ? '✅有效' : '❌无效'}
''';
      }

      if (tokenStatus['socketToken'] != null) {
        final socketTokenInfo =
            tokenStatus['socketToken'] as Map<String, dynamic>;
        testResult += '''
- Socket Token: ${socketTokenInfo['exists'] == true ? '✅存在' : '❌不存在'}
- 有效性: ${socketTokenInfo['valid'] == true ? '✅有效' : '❌无效'}
''';
      }

      testResult += '''

🔧 功能测试:
- API Token获取: ${apiToken != null ? '✅成功' : '❌失败'}
- Socket Token获取: ${socketToken != null ? '✅成功' : '❌失败'}
- 刷新定时器: ${tokenStatus['refreshTimer']?['active'] == true ? '✅运行中' : '❌未运行'}
''';

      // 尝试手动刷新Token
      testResult += '''

🔄 ${localizations.manualRefreshTest}:
''';

      try {
        final refreshSuccess = await tokenManager.manualRefreshToken();
        testResult +=
            '''- ${localizations.manualRefreshTest}: ${refreshSuccess ? '✅成功' : '❌失败'}''';
      } catch (refreshError) {
        testResult +=
            '''- ${localizations.manualRefreshTest}: ❌失败 ($refreshError)''';
      }

      // 显示测试结果
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(localizations.testResults),
            content: SingleChildScrollView(
              child: Text(testResult),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(localizations.close),
              ),
            ],
          ),
        );
      }
    } catch (error) {
      _logger.e('Token刷新测试失败', error: error);

      if (context.mounted) {
        Navigator.pop(context); // 关闭加载对话框
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${localizations.testFailed}：$error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Token状态诊断
  Future<void> _diagnoseTokenStatus(BuildContext context) async {
    final localizations = AppLocalizations.of(context);
    _logger.i('🔍 开始Token状态诊断');

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
              Text('正在诊断Token状态...'),
            ],
          ),
        ),
      );

      // 调用详细Token状态诊断
      await DebugCommands.diagnoseTokenDetails();

      // 关闭加载对话框
      if (context.mounted) Navigator.pop(context);

      // 显示成功提示
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${localizations.diagnosisComplete}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      _logger.e('Token状态诊断失败', error: error);

      // 关闭加载对话框
      if (context.mounted) Navigator.pop(context);

      // 显示错误对话框
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('❌ ${localizations.diagnosisFailed}'),
            content: Text('${localizations.diagnosisFailed}：$error'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(localizations.close),
              ),
            ],
          ),
        );
      }
    }
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
- 认证方式: 新多Token系统
''';
        } else {
          debugInfo += '''

⚠️ 数据库中没有用户记录！
这可能是登录后用户信息没有正确保存的原因。
''';
        }
      }

      // 检查安全存储
      final secureStorage = SecureStorageService();
      final tokenManager = EnhancedTokenManager.instance;

      // 比较原始Token和自动刷新Token
      final storedToken = await secureStorage.getAccessToken();
      final refreshedToken = await tokenManager.getApiToken();
      final userId = await secureStorage.read('user_id');

      debugInfo += '''

🔐 安全存储信息:
- 存储Token: ${storedToken != null ? '✅' : '❌'}
- 刷新Token: ${refreshedToken != null ? '✅' : '❌'}
- 自动刷新: ${refreshedToken != null ? '✅ 正常' : '❌ 失败'}
- 用户ID: ${userId ?? '不存在'}
''';

      if (refreshedToken != null) {
        debugInfo += '''
- Token前缀: ${refreshedToken.length > 20 ? '${refreshedToken.substring(0, 20)}...' : refreshedToken}
''';
      } else if (storedToken != null) {
        debugInfo += '''
- 存储Token前缀: ${storedToken.length > 20 ? '${storedToken.substring(0, 20)}...' : storedToken}
- 注意: 存储Token存在但自动刷新失败
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
      final secureStorage = SecureStorageService();
      final userInfo = await secureStorage.readUserCredentials();

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

  // 显示用户信息诊断对话框
  Future<void> _showUserInfoDiagnostic(BuildContext context) async {
    final localizations = AppLocalizations.of(context);
    _logger.i('🔍 开始用户信息诊断');

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
              Text('正在诊断用户信息...'),
            ],
          ),
        ),
      );

      // 调用用户信息诊断
      await DebugCommands.diagnoseUserInfo();

      // 关闭加载对话框
      if (context.mounted) Navigator.pop(context);

      // 显示成功提示
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${localizations.diagnosisComplete}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      _logger.e('用户信息诊断失败', error: error);

      // 关闭加载对话框
      if (context.mounted) Navigator.pop(context);

      // 显示错误对话框
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('❌ ${localizations.diagnosisFailed}'),
            content: Text('${localizations.diagnosisFailed}：$error'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(localizations.close),
              ),
            ],
          ),
        );
      }
    }
  }

  // 测试消息排序
  Future<void> _testMessageSorting(BuildContext context) async {
    final localizations = AppLocalizations.of(context);
    _logger.i('🔍 开始测试消息排序');

    try {
      // 显示加载对话框
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(localizations.messageSortTest),
            ],
          ),
        ),
      );

      // 调用消息排序测试
      await DebugCommands.testMessageSorting();

      // 关闭加载对话框
      if (context.mounted) Navigator.pop(context);

      // 显示成功提示
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${localizations.diagnosisComplete}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      _logger.e('消息排序测试失败', error: error);

      // 关闭加载对话框
      if (context.mounted) Navigator.pop(context);

      // 显示错误对话框
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('❌ ${localizations.testFailed}'),
            content: Text('${localizations.testFailed}：$error'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(localizations.close),
              ),
            ],
          ),
        );
      }
    }
  }

  // 显示同步管理对话框
  Future<void> _showSyncManagement(BuildContext context) async {
    _logger.i('🔍 显示会话同步管理');

    try {
      // 获取ChatsRepository实例
      final chatsRepository = context.read<ChatsRepository>();

      // 获取当前同步时间
      final lastSyncTime = await chatsRepository.getLastSyncTime();

      if (!context.mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('🔄 会话同步管理'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '同步状态信息：',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  lastSyncTime != null
                      ? '上次同步时间：\n${lastSyncTime.toIso8601String()}\n(${_formatTimeAgo(lastSyncTime)})'
                      : '尚未进行过同步',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: lastSyncTime != null ? Colors.green : Colors.orange,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '操作选项：',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  '• 增量同步：只获取自上次同步以来的更新\n'
                  '• 全量同步：获取所有会话数据\n'
                  '• 清除记录：清除同步时间，下次将全量同步',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _performIncrementalSync(context, chatsRepository);
              },
              child: const Text('增量同步'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _performFullSync(context, chatsRepository);
              },
              child: const Text('全量同步'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _clearSyncTime(context, chatsRepository);
              },
              child: const Text('清除记录'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('关闭'),
            ),
          ],
        ),
      );
    } catch (error) {
      _logger.e('显示同步管理失败', error: error);

      if (!context.mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('❌ 错误'),
          content: Text('无法显示同步管理：$error'),
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

  // 格式化时间差显示
  String _formatTimeAgo(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }

  // 执行增量同步
  Future<void> _performIncrementalSync(
      BuildContext context, ChatsRepository chatsRepository) async {
    try {
      _logger.i('🔄 执行增量同步');

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
              Text('正在执行增量同步...'),
            ],
          ),
        ),
      );

      await chatsRepository.requestSyncConversations();

      // 等待一下让同步完成
      await Future.delayed(const Duration(seconds: 2));

      if (context.mounted) {
        Navigator.pop(context); // 关闭加载对话框
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ 增量同步已触发，请查看会话列表更新'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      _logger.e('增量同步失败', error: error);

      if (context.mounted) {
        Navigator.pop(context); // 关闭加载对话框
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ 增量同步失败：$error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 执行全量同步
  Future<void> _performFullSync(
      BuildContext context, ChatsRepository chatsRepository) async {
    try {
      _logger.i('🔄 执行全量同步');

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
              Text('正在执行全量同步...'),
            ],
          ),
        ),
      );

      await chatsRepository.requestFullSyncConversations();

      // 等待一下让同步完成
      await Future.delayed(const Duration(seconds: 2));

      if (context.mounted) {
        Navigator.pop(context); // 关闭加载对话框
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ 全量同步已触发，请查看会话列表更新'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      _logger.e('全量同步失败', error: error);

      if (context.mounted) {
        Navigator.pop(context); // 关闭加载对话框
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ 全量同步失败：$error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 清除同步时间记录
  Future<void> _clearSyncTime(
      BuildContext context, ChatsRepository chatsRepository) async {
    try {
      _logger.i('🗑️ 清除同步时间记录');

      await chatsRepository.clearSyncTime();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ 同步时间记录已清除，下次同步将执行全量同步'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (error) {
      _logger.e('清除同步时间记录失败', error: error);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ 清除失败：$error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
