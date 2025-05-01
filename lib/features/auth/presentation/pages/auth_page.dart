import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/auth_cubit.dart';
import 'register_page.dart';

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
  bool _isLogin = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
      backgroundColor: Colors.green[50],
      body: Center(
        child: Container(
          width: 400,
          height: 600,
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
          child: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(text: '快捷登录'),
                      Tab(text: '密码登录'),
                    ],
                    labelColor: Colors.black,
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 30),
                      TextField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: '请输入您的手机号码',
                          prefixIcon: Icon(Icons.phone),
                        ),
                        keyboardType: TextInputType.phone,
                        onChanged: (value) => context.read<AuthCubit>().updatePhoneNumber(value),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        height: 48,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildQuickLogin(),
                            _buildPasswordLogin(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 60),
                      BlocConsumer<AuthCubit, AuthState>(
                        listener: (context, state) {
                          if (state is AuthSuccess) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('登录成功')),
                            );
                          } else if (state is AuthError) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(state.message)),
                            );
                          }
                        },
                        builder: (context, state) {
                          return SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                minimumSize: const Size.fromHeight(48),
                              ),
                              onPressed: state is AuthLoading ? null : () => context.read<AuthCubit>().login(_tabController.index == 0),
                              child: state is AuthLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(color: Colors.white),
                                    )
                                  : const Text('登录'),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BlocProvider.value(
                                    value: context.read<AuthCubit>(),
                                    child: const RegisterPage(),
                                  ),
                                ),
                              );
                            },
                            child: const Text('新用户注册'),
                          ),
                          TextButton(
                            onPressed: () {
                              // TODO: 忘记密码
                            },
                            child: const Text('忘记密码？'),
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
                child: Text(
                  state.isCodeSent ? '${state.countdown}s后重试' : '获取验证码',
                ),
              );
            }
            return const ElevatedButton(
              onPressed: null,
              child: Text('获取验证码'),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPasswordLogin() {
    return TextField(
      controller: _passwordController,
      decoration: const InputDecoration(
        labelText: '请输入密码',
        prefixIcon: Icon(Icons.lock),
      ),
      obscureText: true,
      onChanged: (value) => context.read<AuthCubit>().updatePassword(value),
    );
  }
}
