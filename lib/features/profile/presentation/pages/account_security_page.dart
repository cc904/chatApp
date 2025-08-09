import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cc/core/l10n/app_localizations.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/services/enhanced_token_manager.dart';
import 'package:cc/core/services/user_service.dart';
import 'package:cc/core/database/drift_database.dart';

class AccountSecurityPage extends StatefulWidget {
  final CurrentUser? user;

  const AccountSecurityPage({
    super.key,
    this.user,
  });

  @override
  State<AccountSecurityPage> createState() => _AccountSecurityPageState();
}

class _AccountSecurityPageState extends State<AccountSecurityPage> {
  static final _logger = LogService.instance;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.accountSecurity),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      backgroundColor: Colors.grey[100],
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  
                  // 账号信息区域
                  _buildAccountInfoSection(localizations),
                  
                  const SizedBox(height: 16),
                  
                  // 安全设置区域
                  _buildSecuritySettingsSection(localizations),
                  
                  const SizedBox(height: 16),
                  
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildAccountInfoSection(AppLocalizations localizations) {
    return _buildSection(
      title: '账号信息',
      children: [
        _buildListTile(
          icon: Icons.lock_outline,
          title: widget.user?.hasSetPassword == true ? '修改密码' : '设置密码',
          subtitle: widget.user?.hasSetPassword == true 
              ? '定期更换密码保护账号安全'
              : '首次设置密码以保护账号安全',
          onTap: () => widget.user?.hasSetPassword == true 
              ? _showPasswordChangeDialog(localizations)
              : _showPasswordSetDialog(localizations),
        ),
        const Divider(height: 1),
        _buildListTile(
          icon: Icons.phone_outlined,
          title: '绑定手机',
          subtitle: widget.user?.phone?.isNotEmpty == true 
              ? '已绑定: ${_maskPhone(widget.user!.phone!)}'
              : '未开放',
          onTap: () => _showPhoneBindingDialog(localizations),
        ),
        const Divider(height: 1),
        _buildListTile(
          icon: Icons.email_outlined,
          title: '绑定邮箱',
          subtitle: widget.user?.email?.isNotEmpty == true 
              ? '已绑定: ${_maskEmail(widget.user!.email!)}'
              : '未开放',
          onTap: () => _showEmailBindingDialog(localizations),
        ),
        const Divider(height: 1),
        _buildListTile(
          icon: Icons.info_outline,
          title: '账号状态',
          subtitle: '查看账号详细信息',
          onTap: () => _showAccountStatusDialog(localizations),
        ),
      ],
    );
  }

  Widget _buildSecuritySettingsSection(AppLocalizations localizations) {
    return _buildSection(
      title: '安全设置',
      children: [
        _buildListTile(
          icon: Icons.devices_outlined,
          title: '登录设备管理',
          subtitle: '未开放',
          onTap: () => _showDeviceManagementDialog(localizations),
        ),
        const Divider(height: 1),
        _buildListTile(
          icon: Icons.token_outlined,
          title: 'Token管理',
          subtitle: '查看和管理访问令牌',
          onTap: () => _showTokenManagementDialog(localizations),
        ),
        const Divider(height: 1),
        _buildListTile(
          icon: Icons.history_outlined,
          title: '安全日志',
          subtitle: '未开放',
          onTap: () => _showSecurityLogDialog(localizations),
        ),
      ],
    );
  }


  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          child: Text(
            title,
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
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(13),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? textColor,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor),
      title: Text(
        title,
        style: TextStyle(color: textColor),
      ),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  // 脱敏手机号
  String _maskPhone(String phone) {
    if (phone.length <= 7) return phone;
    return '${phone.substring(0, 3)}****${phone.substring(phone.length - 4)}';
  }

  // 脱敏邮箱
  String _maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    
    final username = parts[0];
    final domain = parts[1];
    
    if (username.length <= 3) return email;
    
    return '${username.substring(0, 2)}****@$domain';
  }

  // 首次设置密码对话框
  void _showPasswordSetDialog(AppLocalizations localizations) {
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool obscureNewPassword = true;
    bool obscureConfirmPassword = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('设置密码'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '请设置您的账号密码，用于保护账号安全。',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: newPasswordController,
                  obscureText: obscureNewPassword,
                  decoration: InputDecoration(
                    labelText: '新密码',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(obscureNewPassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          obscureNewPassword = !obscureNewPassword;
                        });
                      },
                    ),
                    border: const OutlineInputBorder(),
                    helperText: '请输入您的密码',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: '确认密码',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          obscureConfirmPassword = !obscureConfirmPassword;
                        });
                      },
                    ),
                    border: const OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(localizations.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                _handlePasswordSet(
                  context,
                  newPasswordController.text,
                  confirmPasswordController.text,
                  localizations,
                );
              },
              child: const Text('设置密码'),
            ),
          ],
        ),
      ),
    );
  }

  // 修改密码对话框
  void _showPasswordChangeDialog(AppLocalizations localizations) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool obscureCurrentPassword = true;
    bool obscureNewPassword = true;
    bool obscureConfirmPassword = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('修改密码'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: currentPasswordController,
                  obscureText: obscureCurrentPassword,
                  decoration: InputDecoration(
                    labelText: '当前密码',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(obscureCurrentPassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          obscureCurrentPassword = !obscureCurrentPassword;
                        });
                      },
                    ),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: newPasswordController,
                  obscureText: obscureNewPassword,
                  decoration: InputDecoration(
                    labelText: '新密码',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(obscureNewPassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          obscureNewPassword = !obscureNewPassword;
                        });
                      },
                    ),
                    border: const OutlineInputBorder(),
                    helperText: '请输入您的密码',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: '确认新密码',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          obscureConfirmPassword = !obscureConfirmPassword;
                        });
                      },
                    ),
                    border: const OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(localizations.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                _handlePasswordChange(
                  context,
                  currentPasswordController.text,
                  newPasswordController.text,
                  confirmPasswordController.text,
                  localizations,
                );
              },
              child: const Text('确认修改'),
            ),
          ],
        ),
      ),
    );
  }

  // 处理首次设置密码
  void _handlePasswordSet(
    BuildContext context,
    String newPassword,
    String confirmPassword,
    AppLocalizations localizations,
  ) async {
    // 验证输入
    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      _showSnackBar('请填写所有密码字段', Colors.red);
      return;
    }

    if (newPassword != confirmPassword) {
      _showSnackBar('新密码和确认密码不一致', Colors.red);
      return;
    }

    Navigator.pop(context);
    
    // 显示加载状态
    setState(() {
      _isLoading = true;
    });

    try {
      _logger.i('用户请求首次设置密码');
      
      // 调用UserService设置密码
      final response = await UserService.instance.setPassword(newPassword);
      
      if (response != null && response.success) {
        _showSnackBar('密码设置成功！', Colors.green);
        _logger.i('密码设置成功');
      } else {
        _showSnackBar(response?.message ?? '密码设置失败', Colors.red);
        _logger.w('密码设置失败: ${response?.message}');
      }
    } catch (error) {
      _showSnackBar('密码设置失败: $error', Colors.red);
      _logger.e('密码设置异常', error: error);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // 处理密码修改
  void _handlePasswordChange(
    BuildContext context,
    String currentPassword,
    String newPassword,
    String confirmPassword,
    AppLocalizations localizations,
  ) async {
    // 验证输入
    if (currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      _showSnackBar('请填写所有密码字段', Colors.red);
      return;
    }

    if (newPassword != confirmPassword) {
      _showSnackBar('新密码和确认密码不一致', Colors.red);
      return;
    }

    Navigator.pop(context);
    
    // 显示加载状态
    setState(() {
      _isLoading = true;
    });

    try {
      _logger.i('用户请求修改密码');
      
      // 调用UserService修改密码
      final response = await UserService.instance.changePassword(
        currentPassword,
        newPassword,
      );
      
      if (response != null && response.success) {
        _showSnackBar('密码修改成功！', Colors.green);
        _logger.i('密码修改成功');
      } else {
        _showSnackBar(response?.message ?? '密码修改失败', Colors.red);
        _logger.w('密码修改失败: ${response?.message}');
      }
    } catch (error) {
      _showSnackBar('密码修改失败: $error', Colors.red);
      _logger.e('密码修改异常', error: error);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }


  // 显示SnackBar
  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }

  // 手机绑定对话框
  void _showPhoneBindingDialog(AppLocalizations localizations) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('绑定手机'),
        content: const Text('该功能未开放'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.close),
          ),
        ],
      ),
    );
  }

  // 邮箱绑定对话框
  void _showEmailBindingDialog(AppLocalizations localizations) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('绑定邮箱'),
        content: const Text('该功能未开放'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.close),
          ),
        ],
      ),
    );
  }

  // 账号状态对话框
  void _showAccountStatusDialog(AppLocalizations localizations) {
    final user = widget.user;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('账号状态'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('用户ID', user?.userId ?? '未知'),
              _buildInfoRow('用户名', user?.name ?? '未知'),
              _buildInfoRow('手机号', user?.phone ?? '未绑定'),
              _buildInfoRow('邮箱', user?.email ?? '未绑定'),
              _buildInfoRow('状态', _statusText(user?.status)),
              _buildInfoRow('密码状态', user?.hasSetPassword == true ? '已设置' : '未设置'),
              _buildInfoRow('创建时间', '未开放'),
              _buildInfoRow('最后登录', '未开放'),
            ],
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

  String _statusText(int? status) {
    switch (status) {
      case 1:
        return '在线';
      case 2:
        return '挂起';
      case 0:
        return '离线';
      default:
        return '未知';
    }
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
            ),
          ),
        ],
      ),
    );
  }

  // Token管理对话框
  void _showTokenManagementDialog(AppLocalizations localizations) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final tokenManager = EnhancedTokenManager.instance;
      final tokenStatus = await tokenManager.getTokenStatus();
      
      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Token管理'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Token状态：',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  // Access Token已移除，现在只使用Refresh Token + Socket Token
                  if (tokenStatus['refreshToken'] != null)
                    _buildTokenStatusRow(
                      'Refresh Token',
                      tokenStatus['refreshToken'] as Map<String, dynamic>,
                    ),
                  if (tokenStatus['socketToken'] != null)
                    _buildTokenStatusRow(
                      'Socket Token',
                      tokenStatus['socketToken'] as Map<String, dynamic>,
                    ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _refreshTokens(localizations);
                    },
                    child: const Text('刷新Token'),
                  ),
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
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      
      _showSnackBar('获取Token状态失败: $error', Colors.red);
    }
  }

  Widget _buildTokenStatusRow(String tokenType, Map<String, dynamic> tokenInfo) {
    final exists = tokenInfo['exists'] as bool? ?? false;
    final valid = tokenInfo['valid'] as bool? ?? false;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$tokenType:',
              style: const TextStyle(fontSize: 12),
            ),
          ),
          Icon(
            exists ? Icons.check_circle : Icons.cancel,
            size: 16,
            color: exists ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 4),
          Text(
            exists ? (valid ? '有效' : '无效') : '不存在',
            style: TextStyle(
              fontSize: 12,
              color: exists ? (valid ? Colors.green : Colors.orange) : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  // 刷新Token
  void _refreshTokens(AppLocalizations localizations) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final tokenManager = EnhancedTokenManager.instance;
      final success = await tokenManager.manualRefreshToken();
      
      setState(() {
        _isLoading = false;
      });

      _showSnackBar(
        success ? 'Token刷新成功' : 'Token刷新失败',
        success ? Colors.green : Colors.red,
      );
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      
      _showSnackBar('Token刷新失败: $error', Colors.red);
    }
  }

  // 其他对话框（占位实现）
  void _showDeviceManagementDialog(AppLocalizations localizations) {
    _showPlaceholderDialog('登录设备管理', localizations);
  }

  void _showSecurityLogDialog(AppLocalizations localizations) {
    _showPlaceholderDialog('安全日志', localizations);
  }

  void _showPlaceholderDialog(String title, AppLocalizations localizations) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: const Text('该功能未开放'),
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