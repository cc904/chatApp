import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/auth_cubit.dart';
import 'package:cc/core/utils/ui_notification_helper.dart';
import 'package:cc/core/l10n/app_localizations.dart';
import 'package:cc/features/home/presentation/pages/home_page.dart';
import 'package:cc/core/services/verification_code_timer.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _phoneController = TextEditingController();
  final _verificationCodeController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  late VerificationCodeTimer _verificationCodeTimer;

  @override
  void initState() {
    super.initState();
    _verificationCodeTimer = VerificationCodeTimer();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _verificationCodeController.dispose();
    _nicknameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _verificationCodeTimer.dispose();
    super.dispose();
  }

  /// 发送验证码
  Future<void> _sendVerificationCode() async {
    try {
      await context.read<AuthCubit>().sendVerificationCode('register');
      // 发送成功后开始倒计时
      _verificationCodeTimer.startCountdown();
    } catch (error) {
      // 错误处理已在AuthCubit中处理
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(localizations.register),
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
                  Center(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.person_add,
                          size: 40,
                          color: Colors.green,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          localizations.registerInfo,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 表单
                  // 手机号
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
                        context.read<AuthCubit>().updatePhoneNumber(value),
                  ),
                  const SizedBox(height: 12),

                  // 验证码
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _verificationCodeController,
                          decoration: InputDecoration(
                            labelText: localizations.verificationCode,
                            prefixIcon: const Icon(Icons.message),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 16),
                          ),
                          onChanged: (value) => context
                              .read<AuthCubit>()
                              .updateVerificationCode(value),
                        ),
                      ),
                      const SizedBox(width: 8),
                      BlocBuilder<AuthCubit, AuthState>(
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
                  ),
                  const SizedBox(height: 12),

                  // 昵称
                  TextField(
                    controller: _nicknameController,
                    decoration: InputDecoration(
                      labelText: localizations.nickname,
                      prefixIcon: const Icon(Icons.person),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 16),
                    ),
                    onChanged: (value) =>
                        context.read<AuthCubit>().updateNickname(value),
                  ),
                  const SizedBox(height: 12),

                  // 密码
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: localizations.password,
                      prefixIcon: const Icon(Icons.lock),
                      helperText: localizations.passwordLength,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 16),
                    ),
                    obscureText: true,
                    onChanged: (value) =>
                        context.read<AuthCubit>().updatePassword(value),
                  ),
                  const SizedBox(height: 12),

                  // 确认密码
                  TextField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: localizations.confirmPassword,
                      prefixIcon: const Icon(Icons.lock_outline),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 16),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 12),

                  // 注册按钮
                  BlocConsumer<AuthCubit, AuthState>(
                    listener: (context, state) {
                      if (state.isAuthenticated) {
                        UINotificationHelper.showSuccess(
                            localizations.registerSuccess);
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => const HomePage(),
                          ),
                          (route) => false,
                        );
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
                                  child: CircularProgressIndicator(
                                      color: Colors.white),
                                )
                              : Text(
                                  localizations.register,
                                  style: const TextStyle(fontSize: 16),
                                ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 0),

                  // 返回登录
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        localizations.alreadyHaveAccount,
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
    final localizations = AppLocalizations.of(context);

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.passwordMismatch)),
      );
      return;
    }

    // 验证密码复杂度
    if (_passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.passwordTooShort)),
      );
      return;
    }

    // 验证昵称
    if (_nicknameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.pleaseEnterNickname)),
      );
      return;
    }

    context.read<AuthCubit>().register();
  }
}
