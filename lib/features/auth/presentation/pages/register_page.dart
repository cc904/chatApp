import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/auth_cubit.dart';
import 'package:cc/core/utils/ui_notification_helper.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _verificationCodeController = TextEditingController();
  final _nicknameController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _verificationCodeController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('注册账号'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 360,
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 页面标题
                  const Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.person_add,
                          size: 40,
                          color: Colors.green,
                        ),
                        SizedBox(height: 16),
                        Text(
                          '创建新账号',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '请填写以下信息完成注册',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // 表单
                  // 手机号
                  TextField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: '手机号码',
                      prefixIcon: Icon(Icons.phone),
                      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    ),
                    keyboardType: TextInputType.phone,
                    onChanged: (value) => context.read<AuthCubit>().updatePhoneNumber(value),
                  ),
                  const SizedBox(height: 20),

                  // 验证码
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _verificationCodeController,
                          decoration: const InputDecoration(
                            labelText: '验证码',
                            prefixIcon: Icon(Icons.message),
                            contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                          ),
                          onChanged: (value) => context.read<AuthCubit>().updateVerificationCode(value),
                        ),
                      ),
                      const SizedBox(width: 8),
                      BlocBuilder<AuthCubit, AuthState>(
                        builder: (context, state) {
                          return ElevatedButton(
                            onPressed: state.isCodeSent || state.isLoading ? null : () => context.read<AuthCubit>().sendVerificationCode(),
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
                  ),
                  const SizedBox(height: 20),

                  // 昵称
                  TextField(
                    controller: _nicknameController,
                    decoration: const InputDecoration(
                      labelText: '昵称',
                      prefixIcon: Icon(Icons.person),
                      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    ),
                    onChanged: (value) => context.read<AuthCubit>().updateNickname(value),
                  ),
                  const SizedBox(height: 20),

                  // 密码
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: '密码',
                      prefixIcon: Icon(Icons.lock),
                      helperText: '密码长度至少6位',
                      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    ),
                    obscureText: true,
                    onChanged: (value) => context.read<AuthCubit>().updatePassword(value),
                  ),
                  const SizedBox(height: 20),

                  // 确认密码
                  TextField(
                    controller: _confirmPasswordController,
                    decoration: const InputDecoration(
                      labelText: '确认密码',
                      prefixIcon: Icon(Icons.lock_outline),
                      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 30),

                  // 注册按钮
                  BlocConsumer<AuthCubit, AuthState>(
                    listener: (context, state) {
                      if (state.isAuthenticated) {
                        UINotificationHelper.showSuccess('注册成功');
                        Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
                      } else if (state.hasError) {
                        UINotificationHelper.showError(state.errorMessage!);
                      }
                    },
                    builder: (context, state) {
                      return SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: state.isLoading ? null : () => _register(),
                          child: state.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(color: Colors.white),
                                )
                              : const Text('注册', style: TextStyle(fontSize: 16)),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // 返回登录
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        '已有账号？返回登录',
                        style: TextStyle(color: Colors.green[700]),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _register() {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('两次输入的密码不一致')),
      );
      return;
    }

    // 验证密码复杂度
    if (_passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('密码长度至少6位')),
      );
      return;
    }

    // 验证昵称
    if (_nicknameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入昵称')),
      );
      return;
    }

    context.read<AuthCubit>().register(
          _phoneController.text,
          _passwordController.text,
          _verificationCodeController.text,
          _nicknameController.text,
        );
  }
}
