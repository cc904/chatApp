import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/auth_cubit.dart';
import 'register_page.dart';
import 'forgot_password_page.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/utils/ui_notification_helper.dart';
import 'package:cc/core/constants/app_config.dart';
import 'package:cc/features/home/presentation/pages/home_page.dart';

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
  late final AuthCubit _authCubit;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _logger.d('AuthPage initialized', stackTrace: StackTrace.current);

    // 创建AuthCubit实例
    final appConfig = AppConfig();
    _authCubit = AuthCubit(serverUrl: appConfig.serverUrl);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _verificationCodeController.dispose();
    _authCubit.close(); // 注销AuthCubit
    _logger.d('AuthPage disposed, AuthCubit closed');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthCubit>.value(
      value: _authCubit,
      child: _buildAuthPageContent(context),
    );
  }

  Widget _buildAuthPageContent(BuildContext context) {
    return Scaffold(
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
                      const Text(
                        '欢迎使用WhatsApp',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '登录您的账号',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
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
                    tabs: const [
                      Tab(text: '快捷登录'),
                      Tab(text: '密码登录'),
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
                        decoration: const InputDecoration(
                          labelText: '请输入您的手机号码',
                          prefixIcon: Icon(Icons.phone),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 16, horizontal: 16),
                        ),
                        keyboardType: TextInputType.phone,
                        onChanged: (value) =>
                            _authCubit.updatePhoneNumber(value),
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
                        bloc: _authCubit,
                        listenWhen: (previous, current) =>
                            !previous.isAuthenticated &&
                                current.isAuthenticated ||
                            current.hasError &&
                                current.errorMessage != previous.errorMessage,
                        listener: _handleAuthStateChange,
                        builder: (context, state) {
                          return SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: state.isLoading
                                  ? null
                                  : () => _authCubit
                                      .login(_tabController.index == 0),
                              child: state.isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                          color: Colors.white),
                                    )
                                  : const Text('登录',
                                      style: TextStyle(fontSize: 16)),
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
                                    value: _authCubit,
                                    child: const RegisterPage(),
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              '新用户注册',
                              style: TextStyle(color: Colors.green[700]),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => BlocProvider.value(
                                    value: _authCubit,
                                    child: const ForgotPasswordPage(),
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              '忘记密码？',
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
    );
  }

  /// 处理认证状态变化
  void _handleAuthStateChange(BuildContext context, AuthState state) {
    if (state.isAuthenticated) {
      // 不再检查数据库初始化状态，直接导航到Home页面
      _logger.i('认证成功，直接导航到Home页面');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const HomePage(),
        ),
      );
    } else if (state.hasError) {
      UINotificationHelper.showError(state.errorMessage!);
    }
  }

  Widget _buildQuickLogin() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _verificationCodeController,
            decoration: const InputDecoration(
              labelText: '请输入验证码',
              prefixIcon: Icon(Icons.message),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            ),
            onChanged: (value) => _authCubit.updateVerificationCode(value),
          ),
        ),
        const SizedBox(width: 8),
        BlocConsumer<AuthCubit, AuthState>(
          bloc: _authCubit,
          listenWhen: (previous, current) =>
              current.hasError && current.errorMessage != previous.errorMessage,
          listener: _handleVerificationCodeError,
          builder: (context, state) {
            return ElevatedButton(
              onPressed: state.isCodeSent || state.isLoading
                  ? null
                  : () => _authCubit.sendVerificationCode(purpose: 'login'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                disabledBackgroundColor: Colors.green.withValues(alpha: 0.5),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                state.isCodeSent && state.countdown != null
                    ? '${state.countdown}s'
                    : state.isLoading
                        ? '发送中...'
                        : '获取验证码',
              ),
            );
          },
        ),
      ],
    );
  }

  /// 处理验证码错误
  void _handleVerificationCodeError(BuildContext context, AuthState state) {
    if (state.hasError) {
      UINotificationHelper.showError(state.errorMessage!);
    }
  }

  Widget _buildPasswordLogin() {
    return SizedBox(
        height: 70,
        child: Align(
          alignment: Alignment.center,
          child: TextField(
            controller: _passwordController,
            decoration: const InputDecoration(
              labelText: '请输入密码',
              prefixIcon: Icon(Icons.lock),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            ),
            obscureText: true,
            onChanged: (value) => _authCubit.updatePassword(value),
          ),
        ));
  }
}
