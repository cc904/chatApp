import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/auth_cubit.dart';
import 'register_page.dart';
import 'forgot_password_page.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/utils/ui_notification_helper.dart';
import 'package:cc/core/constants/app_config.dart';
import 'package:cc/features/home/presentation/pages/home_page.dart';
import 'package:cc/core/l10n/app_localizations.dart';
import 'package:cc/core/services/verification_code_timer.dart';
import 'package:cc/core/services/version_update_service.dart';
import 'package:cc/core/services/ui_notification_service.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _verificationCodeController = TextEditingController();
  final _logger = LogService.instance;
  AuthCubit? _authCubit;
  
  // 🔧 防止重复导航标志
  bool _hasNavigatedToHome = false;
  late final AppConfig _appConfig;
  late VerificationCodeTimer _verificationCodeTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _logger.d('AuthPage initialized', stackTrace: StackTrace.current);

    // 创建AppConfig实例
    _appConfig = AppConfig();
    // 创建验证码倒计时器实例
    _verificationCodeTimer = VerificationCodeTimer();

    // 异步初始化整个认证系统
    _initializeAuthSystem();
  }

  /// 初始化认证系统
  Future<void> _initializeAuthSystem() async {
    try {
      // 1. 初始化AppConfig（获取服务器列表）
      await _appConfig.init();

      // 2. 使用初始化后的AppConfig创建AuthCubit
      _authCubit = AuthCubit(serverUrl: _appConfig.serverUrl);

      // 3. 触发重建以显示认证界面
      if (mounted) {
        setState(() {});
      }

      _logger.i('认证系统初始化完成', extra: {
        'serverUrl': _appConfig.serverUrl,
        'availableServers': _appConfig.allServerUrls.length,
      });
    } catch (error) {
      _logger.e('认证系统初始化失败', error: error);

      // 初始化失败，无法创建AuthCubit
      // 用户界面将显示错误状态
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _verificationCodeController.dispose();
    if (_authCubit != null && !_authCubit!.isClosed) {
      _authCubit!.close(); // 注销AuthCubit
    }
    _verificationCodeTimer.dispose(); // 释放验证码倒计时器
    _logger.d('AuthPage disposed, AuthCubit closed');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 如果AuthCubit还没初始化，显示加载界面或错误信息
    if (_authCubit == null) {
      // 检查是否有可用服务器
      if (_appConfig.allServerUrls.isEmpty) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 64),
                SizedBox(height: 16),
                Text('无可用服务器配置', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('请检查网络连接或联系技术支持', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        );
      }
      
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('正在初始化...'),
            ],
          ),
        ),
      );
    }

    return BlocProvider<AuthCubit>.value(
      value: _authCubit!,
      child: _buildAuthPageContent(context),
    );
  }

  Widget _buildAuthPageContent(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return BlocListener<AuthCubit, AuthState>(
        bloc: _authCubit!,
        listenWhen: (previous, current) =>
            !previous.isAuthenticated && current.isAuthenticated,
        listener: _handleAuthStateChange,
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: Center(
            child: SingleChildScrollView(
              child: Container(
                width: 360,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 欢迎标题
                    Padding(
                      padding: const EdgeInsets.only(top: 30, bottom: 10),
                      child: Column(
                        children: [
                          Icon(
                            Icons.chat,
                            size: 50,
                            color: Colors.green[700],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            localizations.appName,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            localizations.login,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 10),
                          // 服务器切换按钮（仅在调试模式下显示）
                          if (kDebugMode) _buildServerSwitchButton(),
                        ],
                      ),
                    ),
                    // TabBar
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey[200]!,
                            width: 1,
                          ),
                        ),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        tabs: [
                          Tab(text: localizations.quickLogin),
                          Tab(text: localizations.passwordLogin),
                        ],
                        labelColor: Colors.green[800],
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: Colors.green,
                        indicatorWeight: 3,
                        indicatorSize: TabBarIndicatorSize.label,
                        labelStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        unselectedLabelStyle: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                    // 表单内容
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // 手机号输入框
                          TextField(
                            controller: _phoneController,
                            decoration: InputDecoration(
                              labelText: localizations.phoneNumber,
                              prefixIcon: const Icon(Icons.phone),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 16),
                            ),
                            keyboardType: TextInputType.phone,
                            onChanged: (value) =>
                                _authCubit!.updatePhoneNumber(value),
                          ),
                          const SizedBox(height: 24),

                          // 验证码/密码输入框 (根据TabBar切换)
                          SizedBox(
                            height: 70,
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                _buildQuickLogin(),
                                _buildPasswordLogin(),
                              ],
                            ),
                          ),

                          const SizedBox(height: 36),

                          // 登录按钮
                          BlocConsumer<AuthCubit, AuthState>(
                            bloc: _authCubit!,
                            listenWhen: (previous, current) =>
                                !previous.isAuthenticated &&
                                    current.isAuthenticated ||
                                current.hasError &&
                                    current.errorMessage !=
                                        previous.errorMessage,
                            listener: _handleAuthStateChange,
                            builder: (context, state) {
                              return SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: state.isLoading
                                      ? null
                                      : () => _handleLogin(
                                          _tabController.index == 0),
                                  child: state.isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                              color: Colors.white),
                                        )
                                      : Text(localizations.login,
                                          style: const TextStyle(fontSize: 16)),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 24),

                          // 底部链接
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => BlocProvider.value(
                                        value: _authCubit!,
                                        child: const RegisterPage(),
                                      ),
                                    ),
                                  );
                                },
                                child: Text(
                                  localizations.register,
                                  style: TextStyle(color: Colors.green[700]),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => BlocProvider.value(
                                        value: _authCubit!,
                                        child: const ForgotPasswordPage(),
                                      ),
                                    ),
                                  );
                                },
                                child: Text(
                                  localizations.forgotPassword,
                                  style: TextStyle(color: Colors.green[700]),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  /// 处理认证状态变化
  /// 处理登录请求，先检查强制更新
  Future<void> _handleLogin(bool isPasswordLogin) async {
    try {
      _logger.i('开始登录流程，检查强制更新状态');

      // 检查是否需要强制更新
      final needsForceUpdate =
          await VersionUpdateService.instance.isForceUpdateRequired();

      if (needsForceUpdate) {
        _logger.w('检测到强制更新，阻止登录并显示更新对话框');
        if (mounted) {
          await VersionUpdateService.instance.showForceUpdateDialog(context);
        }
        return; // 阻止登录
      }

      // 没有强制更新，继续登录流程
      _logger.i('无强制更新要求，继续登录流程');
      await _authCubit!.login(isPasswordLogin);
    } catch (error) {
      _logger.e('登录前检查失败', error: error);
      // 检查失败时仍允许登录，避免影响用户体验
      await _authCubit!.login(isPasswordLogin);
    }
  }

  void _handleAuthStateChange(BuildContext context, AuthState state) {
    if (state.isAuthenticated && !_hasNavigatedToHome) {
      // 🔧 修复：防止重复导航到Home页面
      _hasNavigatedToHome = true;
      _logger.i('认证成功，直接导航到Home页面');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const HomePage(),
        ),
      );

      // 登录成功后检查版本更新
      _checkLoginVersionUpdate(context);
    } else if (state.isAuthenticated && _hasNavigatedToHome) {
      _logger.d('认证成功，但已导航到Home页面，跳过重复导航');
    } else if (state.hasError) {
      UINotificationHelper.showError(state.errorMessage!);
    }
  }

  /// 检查登录时的版本更新
  void _checkLoginVersionUpdate(BuildContext context) {
    // 延迟检查，确保导航完成后再检查
    Future.delayed(const Duration(seconds: 1), () async {
      if (!mounted) return;

      // 使用全局导航上下文避免跨异步边界问题
      final navigatorKey = UINotificationService.instance.navigatorKey;
      final currentContext = navigatorKey.currentContext;

      if (currentContext != null) {
        await VersionUpdateService.instance
            .checkAndHandleLoginVersionUpdate(currentContext);
      }
    });
  }

  Widget _buildQuickLogin() {
    final localizations = AppLocalizations.of(context);

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _verificationCodeController,
            decoration: InputDecoration(
              labelText: localizations.enterVerificationCode,
              prefixIcon: const Icon(Icons.message),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            ),
            onChanged: (value) => _authCubit!.updateVerificationCode(value),
          ),
        ),
        const SizedBox(width: 8),
        BlocConsumer<AuthCubit, AuthState>(
          bloc: _authCubit!,
          listenWhen: (previous, current) =>
              current.hasError && current.errorMessage != previous.errorMessage,
          listener: _handleVerificationCodeError,
          builder: (context, state) {
            return ListenableBuilder(
              listenable: _verificationCodeTimer,
              builder: (context, child) {
                return ElevatedButton(
                  onPressed: _verificationCodeTimer.isActive || state.isLoading
                      ? null
                      : () => _sendVerificationCode(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    disabledBackgroundColor:
                        Colors.green.withValues(alpha: 0.5),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    _verificationCodeTimer.isActive
                        ? '${_verificationCodeTimer.countdown}s'
                        : state.isLoading
                            ? localizations.sending
                            : localizations.getVerificationCode,
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  /// 发送验证码
  Future<void> _sendVerificationCode() async {
    try {
      // 先进行本地手机号格式验证
      final currentState = _authCubit!.state;
      if (currentState.phoneNumber?.isEmpty ?? true) {
        UINotificationHelper.showError('请输入手机号码');
        return;
      }
      if (currentState.phoneNumber!.length != 11) {
        UINotificationHelper.showError('请输入正确的手机号码');
        return;
      }

      await _authCubit!.sendVerificationCode('login');
      // 只有在发送成功后才开始倒计时
      _verificationCodeTimer.startCountdown();
    } catch (error) {
      // 错误处理已在AuthCubit中处理，这里不启动倒计时
    }
  }

  /// 处理验证码错误
  void _handleVerificationCodeError(BuildContext context, AuthState state) {
    if (state.hasError) {
      UINotificationHelper.showError(state.errorMessage!);
    }
  }

  Widget _buildPasswordLogin() {
    final localizations = AppLocalizations.of(context);

    return SizedBox(
        height: 70,
        child: Align(
          alignment: Alignment.center,
          child: TextField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: localizations.password,
              prefixIcon: const Icon(Icons.lock),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            ),
            obscureText: true,
            onChanged: (value) => _authCubit!.updatePassword(value),
          ),
        ));
  }

  Widget _buildServerSwitchButton() {
    return GestureDetector(
      onTap: _showServerSwitchDialog,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green[200]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.dns,
              size: 16,
              color: Colors.green[700],
            ),
            const SizedBox(width: 6),
            Text(
              _appConfig.currentServerName,
              style: TextStyle(
                fontSize: 12,
                color: Colors.green[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: Colors.green[700],
            ),
          ],
        ),
      ),
    );
  }

  void _showServerSwitchDialog() {
    final localizations = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.switchServer),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: _appConfig.serverDisplayInfo.asMap().entries.map((entry) {
              final index = entry.key;
              final serverInfo = entry.value;
              final isSelected = index == _appConfig.currentServerIndex;

              return ListTile(
                leading: Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: isSelected ? Colors.green : Colors.grey,
                ),
                title: Text(
                  serverInfo['name']!,
                  style: TextStyle(
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                subtitle: Text(
                  serverInfo['url']!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                onTap: () {
                  if (!isSelected) {
                    _switchServer(index);
                  }
                  Navigator.of(context).pop();
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                localizations.cancel,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ],
        );
      },
    );
  }

  void _switchServer(int serverIndex) async {
    try {
      // 保存服务器索引到持久化存储
      await _appConfig.setServerIndex(serverIndex);

      // 关闭旧的AuthCubit实例
      if (_authCubit != null && !_authCubit!.isClosed) {
        _authCubit!.close();
      }

      // 重新初始化认证系统
      await _initializeAuthSystem();

      UINotificationHelper.showSuccess(
        '已切换到${_appConfig.currentServerName}',
      );

      _logger.i('🔄 服务器切换成功', extra: {
        'serverIndex': serverIndex,
        'serverUrl': _appConfig.serverUrl,
        'serverName': _appConfig.currentServerName,
      });
    } catch (e) {
      _logger.e('服务器切换失败', error: e);
      UINotificationHelper.showError('服务器切换失败: ${e.toString()}');
    }
  }
}
