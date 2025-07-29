import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/database/database_initializer.dart';
import 'package:cc/features/auth/presentation/pages/auth_page.dart';
import 'package:cc/core/services/secure_storage_service.dart';
import 'package:cc/core/services/enhanced_token_manager.dart';
import 'package:cc/core/utils/debug_commands.dart';
import 'package:cc/core/constants/app_config.dart';
import 'package:cc/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:cc/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:cc/features/profile/presentation/pages/my_qr_code_page.dart';
import 'package:cc/core/widgets/user_avatar.dart';
import 'package:cc/features/profile/data/repositories/profile_repository.dart';
import 'package:cc/core/database/drift_database.dart';
import 'package:flutter/foundation.dart';
import 'package:cc/features/profile/presentation/pages/language_settings_page.dart';
import 'package:cc/features/profile/presentation/pages/notification_settings_page.dart';
import 'package:cc/features/profile/presentation/pages/account_security_page.dart';
import 'package:cc/features/profile/presentation/pages/about_page.dart';
import 'package:cc/core/services/notification_settings_service.dart';
import 'package:cc/core/l10n/app_localizations.dart';
import 'package:cc/core/constants/app_colors.dart';
import 'package:cc/core/services/user_service.dart';
import 'package:cc/features/home/presentation/cubit/home_cubit.dart';
import 'package:cc/features/chat/presentation/pages/chats_page.dart';
import 'dart:async';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver, RouteAware {
  static final _logger = LogService.instance;

  // 直接创建ProfileCubit，不需要复杂的初始化逻辑
  late final ProfileCubit _profileCubit;

  // 复制按钮状态
  bool _isCopied = false;

  // 💢💢💢 页面是否可见状态标记
  bool _isPageVisible = true;

  // 💢💢💢 最后一次同步时间
  DateTime? _lastSyncTime;

  // 用户信息更新流订阅
  StreamSubscription<CurrentUser>? _userUpdateSubscription;

  /// 获取通知状态
  Future<Map<String, dynamic>> _getNotificationStatus() async {
    return NotificationSettingsService.instance.getSettingsStatus();
  }

  /// 💢💢💢 页面重新显示时的同步检查
  ///
  /// 这是一个被动检查机制，只在页面重新显示或应用恢复前台时触发
  /// 检查规则：
  /// 1. 强制同步 (force = true)
  /// 2. 首次同步 (_lastSyncTime == null)
  /// 3. 距离上次同步超过30秒 (防止频繁同步)
  ///
  /// 注意：没有定时器后台运行，只在特定事件触发时才检查
  Future<void> _checkAndSync({bool force = false}) async {
    try {
      final now = DateTime.now();
      final shouldSync = force ||
          _lastSyncTime == null ||
          now.difference(_lastSyncTime!).inSeconds > 30;

      if (shouldSync) {
        _logger.i('ProfilePage 触发用户信息同步', extra: {
          'trigger': force
              ? 'force'
              : _lastSyncTime == null
                  ? 'first_time'
                  : 'time_interval',
          'force': force,
          'lastSyncTime': _lastSyncTime?.toIso8601String(),
          'timeSinceLastSync': _lastSyncTime != null
              ? now.difference(_lastSyncTime!).inSeconds
              : null,
        });

        // 使用UserService请求当前用户信息同步
        await UserService.instance.requestCurrentUserSync();
        _lastSyncTime = now;
      } else {
        _logger.d('ProfilePage 跳过同步，距离上次同步时间较短');
      }
    } catch (e) {
      _logger.e('ProfilePage 同步检查失败', error: e);
    }
  }

  /// 初始化同步
  Future<void> _initSync() async {
    _logger.i('ProfilePage 初始化同步');
    await _checkAndSync(force: true);
    _lastSyncTime = DateTime.now();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _logger.i('ProfilePage 初始化开始');

    // 添加生命周期监听
    WidgetsBinding.instance.addObserver(this);

    // 直接创建ProfileCubit实例
    _profileCubit = ProfileCubit(repository: ProfileRepository());
    _logger.i('ProfileCubit 创建成功');

    // 初始化同步
    _initSync();

    // 监听用户信息更新
    _userUpdateSubscription = UserService.instance.userUpdateStream.listen((updatedUser) {
      _logger.i('ProfilePage 收到用户信息更新通知', extra: {
        'userId': updatedUser.userId,
        'hasSetPassword': updatedUser.hasSetPassword,
      });
      
      // 自动刷新ProfileCubit
      if (mounted) {
        _profileCubit.refreshUserInfo();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // 💢💢💢 注册 RouteObserver（使用ChatsPage的全局observer）
    final ModalRoute? route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }

    _logger.d('ProfilePage didChangeDependencies 触发', extra: {
      'isPageVisible': _isPageVisible,
      'mounted': mounted,
      'lastSyncTime': _lastSyncTime?.toIso8601String(),
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // 💢💢💢 应用从后台恢复时触发同步
    if (state == AppLifecycleState.resumed && _isPageVisible) {
      _logger.i('应用从后台恢复，ProfilePage 检查是否需要同步');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          // 💢💢💢 重要：检查当前是否是可见的Tab页面
          // ProfilePage是索引2，只有当前Tab索引为2时才执行同步
          try {
            final homeCubit = context.read<HomeCubit>();
            final currentTabIndex = homeCubit.state.currentTabIndex;
            final isCurrentTabVisible = currentTabIndex == 2;
            
            _logger.i('ProfilePage 应用恢复检查可见性', extra: {
              'currentTabIndex': currentTabIndex,
              'isProfileTabVisible': isCurrentTabVisible,
              'shouldSync': isCurrentTabVisible,
            });

            if (isCurrentTabVisible) {
              _logger.i('ProfilePage 当前可见且应用恢复，执行同步');
              _checkAndSync(force: true);
            } else {
              _logger.d('ProfilePage 当前不可见，跳过应用恢复同步');
            }
          } catch (e) {
            // 如果获取HomeCubit失败，作为fallback还是执行同步
            _logger.w('ProfilePage 无法获取HomeCubit，执行fallback同步', extra: {'error': e.toString()});
            _checkAndSync(force: true);
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _logger.i('ProfilePage 开始销毁');
    
    // 💢💢💢 取消 RouteObserver 订阅
    routeObserver.unsubscribe(this);

    // 移除生命周期监听
    WidgetsBinding.instance.removeObserver(this);

    // 取消用户信息更新流订阅
    _userUpdateSubscription?.cancel();

    _profileCubit.close();
    super.dispose();
  }

  // 💢💢💢 RouteAware 生命周期方法
  @override
  void didPopNext() {
    // 💢💢💢 当从其他页面返回到当前页面时触发
    _logger.i('🚀🚀🚀 ProfilePage didPopNext 触发 - 用户从其他页面返回');
    _isPageVisible = true;

    // 检查并执行同步
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _logger.i('🚀🚀🚀 ProfilePage 当前可见，执行同步');
        _checkAndSync(force: true); // 强制同步确保触发
      }
    });
  }

  @override
  void didPushNext() {
    // 💢💢💢 当从当前页面导航到其他页面时触发
    _logger.d('ProfilePage didPushNext 触发 - 用户离开当前页面');
    _isPageVisible = false;
  }

  @override
  void didPush() {
    // 💢💢💢 当页面首次被推入路由栈时触发
    _logger.d('ProfilePage didPush 触发 - 页面首次显示');
    _isPageVisible = true;
  }

  @override
  void didPop() {
    // 💢💢💢 当页面从路由栈中弹出时触发
    _logger.d('ProfilePage didPop 触发 - 页面被移除');
    _isPageVisible = false;
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

              // 如果状态为success但没有用户数据，说明数据已被重置，跳转到登录页面
              // 临时修复：在Web环境下不显示数据重置界面，显示空用户界面
              if (state.status == ProfileStatus.success && state.user == null && !kIsWeb) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _handleDataResetComplete(context);
                });
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.restart_alt,
                        size: 64,
                        color: Colors.orange,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        localizations.dataResetComplete,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
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
                    _buildFunctionList(localizations, state),

                    const SizedBox(height: 16),

                    // 开发者选项
                    _buildDeveloperOptions(localizations),

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
                  case 'logout':
                    _handleLogout();
                    break;
                }
              },
              itemBuilder: (BuildContext context) {
                return [
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
          // 头像和编辑按钮
          Stack(
            children: [
              UserAvatar(
                avatarUrl: user?.avatar,
                name: user?.name ?? '用户',
                radius: 40,
                backgroundColor: Colors.green,
              ),
              // 编辑按钮 - 放在头像左下角
              Positioned(
                left: 0,
                bottom: 0,
                child: GestureDetector(
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
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.grey[300]!,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(26),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.edit,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ),
            ],
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
                const SizedBox(height: 4),
                // 用户ID行
                Row(
                  children: [
                    Text(
                      '${localizations.userId}: ${user?.userId ?? '加载中...'}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (user != null && user.userId.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _copyUserId(user.userId, localizations),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: _isCopied
                                ? Colors.green[200]
                                : Colors.green[50],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Icon(
                            _isCopied ? Icons.check : Icons.copy,
                            size: 14,
                            color: _isCopied
                                ? Colors.green[800]
                                : Colors.green[600],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // 二维码按钮 - 替换原来的编辑按钮位置
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
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.qr_code,
                size: 24,
                color: Colors.green[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 复制用户ID到剪贴板
  void _copyUserId(String userId, AppLocalizations localizations) {
    Clipboard.setData(ClipboardData(text: userId));
    _logger.i('复制用户ID：$userId');

    // 设置为已复制状态
    setState(() {
      _isCopied = true;
    });

    // 3秒后恢复原状态
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isCopied = false;
        });
      }
    });
  }

  Widget _buildFunctionList(AppLocalizations localizations, ProfileState state) {
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
                  _logger.d('点击账号与安全', extra: {'user': state.user?.toString()});
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AccountSecurityPage(user: state.user),
                    ),
                  );
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
                  _showPrivacyNotAvailableDialog();
                },
              ),
              const Divider(height: 1),

              // 通知设置
              ListTile(
                leading: const Icon(Icons.notifications),
                title: Text(localizations.notificationSettings),
                subtitle: FutureBuilder<Map<String, dynamic>>(
                  future: _getNotificationStatus(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Text('检查中...');
                    
                    final status = snapshot.data!;
                    final enabled = status['notificationsEnabled'] as bool? ?? true;
                    final quietMode = status['quietHoursActive'] as bool? ?? false;
                    
                    String statusText;
                    if (!enabled) {
                      statusText = '已关闭';
                    } else if (quietMode) {
                      statusText = '勿扰模式';
                    } else {
                      statusText = '已开启';
                    }
                    
                    return Text(
                      statusText,
                      style: TextStyle(
                        color: enabled && !quietMode ? Colors.green : Colors.orange,
                        fontSize: 12,
                      ),
                    );
                  },
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 快速切换按钮
                    IconButton(
                      icon: const Icon(Icons.notifications_off, size: 20),
                      onPressed: () async {
                        final result = await NotificationSettingsService.instance.toggleNotifications();
                        setState(() {}); // 刷新状态
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(result ? '通知已开启' : '通知已关闭'),
                              backgroundColor: result ? Colors.green : Colors.orange,
                            ),
                          );
                        }
                      },
                      tooltip: '快速切换通知',
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 16),
                  ],
                ),
                onTap: () {
                  _logger.d('点击通知设置');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationSettingsPage(),
                    ),
                  );
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AboutPage(),
                    ),
                  );
                },
              ),
              const Divider(height: 1),
            ],
          ),
        ),
      ],
    );
  }

  /// 显示不可用功能对话框
  void _showPrivacyNotAvailableDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('功能暂不可用'),
        content: const Text('隐私设置功能正在开发中，敬请期待！'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 处理数据重置完成
  void _handleDataResetComplete([BuildContext? context]) {
    _logger.i('数据重置完成');
    // 这里可以添加数据重置后的处理逻辑
  }

  /// 构建开发者选项
  Widget _buildDeveloperOptions([dynamic localizations]) {
    return Container();
  }

  /// 处理登出
  void _handleLogout() async {
    try {
      _logger.i('用户点击登出');
      
      // 显示确认对话框
      final shouldLogout = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('确认登出'),
          content: const Text('您确定要退出登录吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('确定', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      if (shouldLogout != true) return;

      // 清除认证状态和Token
      await _clearAuthenticationState();
      
      // 导航到登录页面
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const AuthPage()),
          (route) => false,
        );
      }
      
      _logger.i('用户已成功登出');
    } catch (e) {
      _logger.e('登出失败', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('登出失败: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 清除认证状态
  Future<void> _clearAuthenticationState() async {
    try {
      final secureStorage = SecureStorageService();
      
      // 清除所有认证相关的存储数据
      await secureStorage.delete('user_id');
      await secureStorage.delete('refresh_token');
      await secureStorage.delete('socket_token');
      await secureStorage.delete('access_token');
      
      // 清除其他用户相关数据（可选）
      await secureStorage.delete('login_servers');
      await secureStorage.delete('selected_server_url');
      
      _logger.i('已清除所有认证状态');
    } catch (e) {
      _logger.e('清除认证状态失败', error: e);
      throw e;
    }
  }
}
