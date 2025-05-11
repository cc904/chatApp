import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/auth_cubit.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/utils/ui_notification_helper.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _phoneController = TextEditingController();
  final _verificationCodeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _logger = LogService.instance;

  // 重置密码的步骤
  int _currentStep = 0;

  @override
  void dispose() {
    _phoneController.dispose();
    _verificationCodeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// 构建忘记密码页面的UI
  ///
  /// 包含三个步骤的Stepper组件：手机号验证、验证码验证和设置新密码
  @override
  Widget build(BuildContext context) {
    _logger.d('ForgotPasswordPage build');
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('忘记密码'),
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
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // 页面标题
                  const Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.lock_reset,
                          size: 40,
                          color: Colors.green,
                        ),
                        SizedBox(height: 16),
                        Text(
                          '重置密码',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '请完成以下步骤重置您的密码',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 步骤指示器
                  Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.fromSwatch().copyWith(
                        primary: Colors.green,
                        secondary: Colors.green[700],
                      ),
                    ),
                    child: Stepper(
                      currentStep: _currentStep,
                      type: StepperType.vertical,
                      physics: const NeverScrollableScrollPhysics(),
                      controlsBuilder: (context, details) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: details.onStepContinue,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  child: Text(_currentStep == 2 ? '完成重置' : '下一步'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              if (_currentStep > 0)
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: details.onStepCancel,
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.grey[700],
                                      side: BorderSide(color: Colors.grey[300]!),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                    child: const Text('返回'),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                      onStepCancel: () {
                        if (_currentStep > 0) {
                          setState(() {
                            _currentStep -= 1;
                          });
                        }
                      },
                      onStepContinue: () {
                        // 验证当前步骤
                        bool canProceed = _validateCurrentStep();
                        if (canProceed) {
                          if (_currentStep < 2) {
                            setState(() {
                              _currentStep += 1;
                            });
                          } else {
                            // 最后一步,提交重置密码
                            _resetPassword();
                          }
                        }
                      },
                      onStepTapped: (step) {
                        // 只允许访问已完成或当前步骤
                        if (step <= _currentStep) {
                          setState(() {
                            _currentStep = step;
                          });
                        }
                      },
                      steps: [
                        Step(
                          title: const Text('验证手机号'),
                          content: _buildPhoneVerificationStep(),
                          isActive: _currentStep >= 0,
                          state: _currentStep > 0 ? StepState.complete : StepState.indexed,
                        ),
                        Step(
                          title: const Text('验证码验证'),
                          content: _buildCodeVerificationStep(),
                          isActive: _currentStep >= 1,
                          state: _currentStep > 1 ? StepState.complete : StepState.indexed,
                        ),
                        Step(
                          title: const Text('设置新密码'),
                          content: _buildNewPasswordStep(),
                          isActive: _currentStep >= 2,
                          state: _currentStep > 2 ? StepState.complete : StepState.indexed,
                        ),
                      ],
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

  /// 构建手机号验证步骤的UI
  Widget _buildPhoneVerificationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
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
        const SizedBox(height: 12),
        Text(
          '我们将向您的手机发送验证码,请确保输入正确的手机号。',
          style: TextStyle(color: Colors.grey[600], fontSize: 13),
        ),
      ],
    );
  }

  /// 构建验证码验证步骤的UI
  Widget _buildCodeVerificationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
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
                  onPressed: state.isCodeSent || state.isLoading ? null : () => context.read<AuthCubit>().sendVerificationCode(purpose: 'reset'),
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
        const SizedBox(height: 12),
        Text(
          '请输入您收到的验证码,验证码有效期为5分钟。',
          style: TextStyle(color: Colors.grey[600], fontSize: 13),
        ),
      ],
    );
  }

  /// 构建设置新密码步骤的UI
  Widget _buildNewPasswordStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        TextField(
          controller: _newPasswordController,
          decoration: const InputDecoration(
            labelText: '新密码',
            prefixIcon: Icon(Icons.lock),
            helperText: '密码长度至少6位',
            contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          ),
          obscureText: true,
          onChanged: (value) => context.read<AuthCubit>().updatePassword(value),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _confirmPasswordController,
          decoration: const InputDecoration(
            labelText: '确认密码',
            prefixIcon: Icon(Icons.lock_outline),
            contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 12),
        Text(
          '请设置一个安全的新密码,并牢记您的密码。',
          style: TextStyle(color: Colors.grey[600], fontSize: 13),
        ),
      ],
    );
  }

  /// 验证当前步骤的输入是否有效
  ///
  /// 根据当前步骤[_currentStep]验证对应的输入字段
  /// 返回bool值表示验证是否通过
  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        // 验证手机号
        if (_phoneController.text.isEmpty) {
          _showErrorMessage('请输入手机号码');
          return false;
        }
        if (_phoneController.text.length != 11) {
          _showErrorMessage('请输入正确的手机号码');
          return false;
        }
        return true;
      case 1:
        // 验证验证码
        if (_verificationCodeController.text.isEmpty) {
          _showErrorMessage('请输入验证码');
          return false;
        }
        // 可以添加验证码长度检查
        return true;
      case 2:
        // 验证新密码
        if (_newPasswordController.text.isEmpty) {
          _showErrorMessage('请输入新密码');
          return false;
        }
        if (_newPasswordController.text.length < 6) {
          _showErrorMessage('密码长度至少6位');
          return false;
        }
        if (_confirmPasswordController.text != _newPasswordController.text) {
          _showErrorMessage('两次输入的密码不一致');
          return false;
        }
        return true;
      default:
        return false;
    }
  }

  /// 执行重置密码的操作
  ///
  /// 向AuthCubit发送重置密码请求,并处理成功和失败的情况
  /// 成功时显示成功对话框,失败时显示错误消息
  void _resetPassword() {
    _logger.d('重置密码', extra: {'phoneNumber': _phoneController.text});

    // 保存当前需要的数据
    final phoneNumber = _phoneController.text;
    final newPassword = _newPasswordController.text;
    final verificationCode = _verificationCodeController.text;

    // 显示加载指示器
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Colors.green),
      ),
    );

    context
        .read<AuthCubit>()
        .resetPassword(
          phoneNumber,
          newPassword,
          verificationCode,
        )
        .then((_) {
      // 关闭加载指示器
      if (!mounted) return;
      Navigator.pop(context);

      // 显示成功消息和确认对话框
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('密码重置成功'),
          content: const Text('您的密码已成功重置,请使用新密码登录。'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // 关闭对话框
                Navigator.pop(context); // 返回登录页
              },
              child: Text(
                '返回登录',
                style: TextStyle(color: Colors.green[700]),
              ),
            ),
          ],
        ),
      );
    }).catchError((error) {
      // 关闭加载指示器
      if (!mounted) return;
      Navigator.pop(context);

      // 显示错误消息
      _showErrorMessage(error.toString());

      // 出错时不返回登录页,留在当前页面
    });
  }

  /// 显示错误消息提示
  ///
  /// [message] 要显示的错误消息文本
  void _showErrorMessage(String message) {
    UINotificationHelper.showError(message);
  }
}
