import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/auth_cubit.dart';
import 'register_page.dart';
import 'forgot_password_page.dart';
import 'dart:developer' as dev;

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _verificationCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    dev.log('AuthPage initialized');
  }

  @override
  void dispose() {
    _tabController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _verificationCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                        ),
                        keyboardType: TextInputType.phone,
                        onChanged: (value) => context.read<AuthCubit>().updatePhoneNumber(value),
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
                        listener: (context, state) {
                          if (state is AuthSuccess) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('登录成功')),
                            );
                            Navigator.of(context).pushReplacementNamed('/home');
                          } else if (state is AuthError) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(state.message)),
                            );
                          }
                        },
                        builder: (context, state) {
                          return SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: state is AuthLoading ? null : () => context.read<AuthCubit>().login(_tabController.index == 0),
                              child: state is AuthLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(color: Colors.white),
                                    )
                                  : const Text('登录', style: TextStyle(fontSize: 16)),
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
                              final authCubit = BlocProvider.of<AuthCubit>(context);
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => BlocProvider.value(
                                    value: authCubit,
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
                              final authCubit = BlocProvider.of<AuthCubit>(context);
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => BlocProvider.value(
                                    value: authCubit,
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

  Widget _buildQuickLogin() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _verificationCodeController,
            decoration: const InputDecoration(
              labelText: '请输入验证码',
              prefixIcon: Icon(Icons.message),
              contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            ),
            onChanged: (value) => context.read<AuthCubit>().updateVerificationCode(value),
          ),
        ),
        const SizedBox(width: 8),
        BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            if (state is AuthFormState) {
              return ElevatedButton(
                onPressed: state.isCodeSent ? null : () => context.read<AuthCubit>().sendVerificationCode(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  disabledBackgroundColor: Colors.green.withValues(alpha: 0.5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  state.isCodeSent ? '${state.countdown}s' : '获取验证码',
                ),
              );
            }
            return ElevatedButton(
              onPressed: null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('获取验证码'),
            );
          },
        ),
      ],
    );
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
              contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            ),
            obscureText: true,
            onChanged: (value) => context.read<AuthCubit>().updatePassword(value),
          ),
        ));
  }
}
