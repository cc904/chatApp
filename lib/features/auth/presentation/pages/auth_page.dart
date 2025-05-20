import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/auth_cubit.dart';
import 'register_page.dart';
import 'forgot_password_page.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/utils/ui_notification_helper.dart';
import 'package:cc/core/database/database_initializer.dart';
import 'package:cc/core/services/network_diagnostics.dart';
import 'package:cc/core/services/socket_test.dart';
import 'package:cc/core/services/proto_socket_service.dart';
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
  final _networkDiagnostics = NetworkDiagnostics();
  final _socketTest = SocketTest();
  bool _isRunningDiagnosis = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _logger.d('AuthPage initialized');
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
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 16, horizontal: 16),
                        ),
                        keyboardType: TextInputType.phone,
                        onChanged: (value) =>
                            context.read<AuthCubit>().updatePhoneNumber(value),
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
                                  : () => context
                                      .read<AuthCubit>()
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
                              final authCubit =
                                  BlocProvider.of<AuthCubit>(context);
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
                              final authCubit =
                                  BlocProvider.of<AuthCubit>(context);
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showDiagnosticsDialog,
        backgroundColor: Colors.green[700],
        tooltip: '网络诊断',
        child: const Icon(Icons.bug_report),
      ),
    );
  }

  /// 处理认证状态变化
  void _handleAuthStateChange(BuildContext context, AuthState state) {
    if (state.isAuthenticated) {
      // 确保数据库初始化完成后再导航
      _logger.i('验证数据库初始化状态: ${DatabaseInitializer.isInitialized}');

      if (DatabaseInitializer.isInitialized) {
        _logger.i('数据库已初始化,直接导航到Home页面');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ),
        );
      } else {
        _logger.w('数据库尚未初始化,等待初始化完成后再导航');
      }
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
            onChanged: (value) =>
                context.read<AuthCubit>().updateVerificationCode(value),
          ),
        ),
        const SizedBox(width: 8),
        BlocConsumer<AuthCubit, AuthState>(
          listenWhen: (previous, current) =>
              current.hasError && current.errorMessage != previous.errorMessage,
          listener: _handleVerificationCodeError,
          builder: (context, state) {
            return ElevatedButton(
              onPressed: state.isCodeSent || state.isLoading
                  ? null
                  : () => context
                      .read<AuthCubit>()
                      .sendVerificationCode(purpose: 'login'),
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
            onChanged: (value) =>
                context.read<AuthCubit>().updatePassword(value),
          ),
        ));
  }

  /// 💢💢💢💢💢💢💢💢💢💢💢💢💢💢   诊断   💢💢💢💢💢💢💢💢💢💢💢💢💢💢

  // 显示诊断对话框
  void _showDiagnosticsDialog() {
    final serverUrlController =
        TextEditingController(text: 'http://d2.orb.local:3000');
    final tokenController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => DefaultTabController(
        length: 2,
        child: AlertDialog(
          title: const Text('网络诊断工具'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SizedBox(
                width: 400,
                height: 300,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TabBar(
                      tabs: [
                        Tab(text: '诊断工具'),
                        Tab(text: 'Socket配置'),
                      ],
                      labelColor: Colors.green,
                      unselectedLabelColor: Colors.grey,
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          // 诊断工具标签页
                          SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextField(
                                    controller: serverUrlController,
                                    decoration: const InputDecoration(
                                      labelText: '服务器地址',
                                      helperText: '例如: http://api.example.com',
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  TextField(
                                    controller: tokenController,
                                    decoration: const InputDecoration(
                                      labelText: '认证令牌 (可选)',
                                      helperText: '用于测试Socket.IO连接',
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  if (_isRunningDiagnosis)
                                    const Center(
                                      child: Column(
                                        children: [
                                          CircularProgressIndicator(),
                                          SizedBox(height: 8),
                                          Text('正在运行诊断...'),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),

                          // Socket配置标签页
                          SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: _buildSocketConfigPanel(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('关闭'),
            ),
            ElevatedButton(
              onPressed: _isRunningDiagnosis
                  ? null
                  : () => _runDiagnostics(
                        serverUrlController.text,
                        tokenController.text,
                        setState: (fn) {
                          setState(() => fn());
                        },
                      ),
              child: const Text('运行诊断'),
            ),
          ],
        ),
      ),
    );
  }

  // 构建Socket配置面板
  Widget _buildSocketConfigPanel() {
    // 从偏好设置或全局配置中获取当前的Socket.IO配置
    final currentSettings = _getCurrentSocketSettings();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Socket.IO配置检查',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        if (currentSettings['connected'] == true)
          const Text(
            '当前状态: 已连接',
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
          )
        else
          Text(
            '当前状态: ${currentSettings['status']}',
            style: const TextStyle(
                color: Colors.orange, fontWeight: FontWeight.bold),
          ),
        Text(
          '服务器地址: ${currentSettings['serverUrl']}',
          style: TextStyle(fontSize: 13, color: Colors.grey[800]),
        ),
        const SizedBox(height: 16),
        _buildSocketConfigItem(
          title: '传输方式',
          description: '建议同时启用websocket和polling',
          value: currentSettings['transports'].toString(),
          isWarning: !(currentSettings['transports'] is List &&
              currentSettings['transports'].contains('websocket') &&
              currentSettings['transports'].contains('polling')),
        ),
        _buildSocketConfigItem(
          title: '连接超时',
          description: '推荐值: 10000-20000 (毫秒)',
          value: '${currentSettings['timeout']} ms',
          isWarning: currentSettings['timeout'] < 10000,
        ),
        _buildSocketConfigItem(
          title: '自动重连',
          description: '生产环境建议启用',
          value: currentSettings['reconnection'] ? '已启用' : '已禁用',
          isWarning: !currentSettings['reconnection'],
        ),
        _buildSocketConfigItem(
          title: '重连尝试次数',
          description: '推荐值: 5-10',
          value: '${currentSettings['reconnectionAttempts']}',
          isWarning: currentSettings['reconnectionAttempts'] < 5,
        ),
        _buildSocketConfigItem(
          title: '重连延迟',
          description: '推荐值: 1000-5000 (毫秒)',
          value: '${currentSettings['reconnectionDelay']} ms',
          isWarning: currentSettings['reconnectionDelay'] < 1000 ||
              currentSettings['reconnectionDelay'] > 5000,
        ),
        _buildSocketConfigItem(
          title: '路径前缀',
          description: '应与服务器配置一致',
          value: currentSettings['path'],
          isWarning: currentSettings['path'] != '/socket.io/',
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton.icon(
              onPressed: _showSocketConfigEditDialog,
              icon: const Icon(Icons.edit),
              label: const Text('修改配置'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                // 测试当前连接
                final socketService = ProtoSocketService();
                if (socketService.isConnected) {
                  UINotificationHelper.showSuccess('当前Socket已连接');
                  _logger.i('测试当前连接: 已连接',
                      extra: socketService.getConnectionInfo());
                } else {
                  UINotificationHelper.showMessage('当前Socket未连接，检查连接状态...');
                  _logger.i('测试当前连接: 未连接',
                      extra: socketService.getConnectionInfo());

                  // 对于调试目的，我们可以添加一些额外的检查
                  final status = socketService.checkConnectionStatus();
                  UINotificationHelper.showMessage('连接状态: $status');
                }
              },
              icon: const Icon(Icons.link),
              label: const Text('测试连接'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 8),
        const Text(
          '故障排除提示:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text('• 如果连接失败，尝试同时启用websocket和polling传输方式',
            style: TextStyle(fontSize: 13)),
        const Text('• 移动网络环境下可能需要更长的超时时间', style: TextStyle(fontSize: 13)),
        const Text('• 确保路径前缀与服务器配置一致', style: TextStyle(fontSize: 13)),
        const Text('• 检查服务器是否支持跨域请求(CORS)', style: TextStyle(fontSize: 13)),
        const Text('• 确认服务器Socket.IO版本与客户端兼容', style: TextStyle(fontSize: 13)),
      ],
    );
  }

  // 构建单个Socket配置项
  Widget _buildSocketConfigItem({
    required String title,
    required String description,
    required String value,
    required bool isWarning,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            isWarning ? Icons.warning_amber_rounded : Icons.check_circle,
            color: isWarning ? Colors.orange : Colors.green,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              color: isWarning ? Colors.orange : Colors.green[700],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // 获取当前Socket.IO设置
  Map<String, dynamic> _getCurrentSocketSettings() {
    // 尝试从ProtoSocketService中读取当前配置
    // 这里是模拟，实际上ProtoSocketService并未直接暴露内部配置
    // 通常这些配置应该在应用配置服务或设置中保存

    // 获取当前连接信息作为参考
    final socketInfo = ProtoSocketService().getConnectionInfo();
    _logger.i('当前Socket连接信息', extra: socketInfo);

    return {
      'transports': ['websocket', 'polling'], // Socket服务使用两种传输方式
      'timeout': 20000, // Socket服务使用20秒超时
      'reconnection': true,
      'reconnectionAttempts': 10,
      'reconnectionDelay': 3000,
      'path': '/socket.io/',
      'serverUrl': socketInfo['serverUrl'] ?? 'http://d2.orb.local:3000',
      'connected': socketInfo['connected'] ?? false,
      'status': socketInfo['status'] ?? 'disconnected',
    };
  }

  // 保存Socket.IO设置
  void _saveSocketSettings(Map<String, dynamic> settings) {
    _logger.i('保存Socket.IO配置', extra: settings);

    // 在实际应用中，我们应该将这些设置保存到全局配置或SharedPreferences中
    // 然后在初始化ProtoSocketService时使用这些配置

    // 如果当前已连接，尝试断开并使用新配置重连
    final socketService = ProtoSocketService();
    if (socketService.isConnected) {
      UINotificationHelper.showMessage('Socket配置已更新，将在下次连接时生效');
    }

    // 这里我们可以将设置保存到一个静态变量或应用配置中
    // 例如：ConfigService.setSocketConfig(settings);
    // 在本示例中，我们仅记录日志
    _logger.i('Socket.IO配置已更新，新配置为：', extra: settings);
  }

  // 显示Socket配置编辑对话框
  void _showSocketConfigEditDialog() {
    final settings = _getCurrentSocketSettings();
    var useWebsocket = settings['transports'] is List &&
        settings['transports'].contains('websocket');
    var usePolling = settings['transports'] is List &&
        settings['transports'].contains('polling');
    final serverUrlController =
        TextEditingController(text: settings['serverUrl'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑Socket.IO配置'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: serverUrlController,
                    decoration: const InputDecoration(
                      labelText: '服务器地址',
                      helperText: '例如: http://api.example.com',
                    ),
                    onChanged: (value) {
                      settings['serverUrl'] = value;
                    },
                  ),

                  const SizedBox(height: 16),
                  const Text('传输方式:'),
                  CheckboxListTile(
                    title: const Text('WebSocket'),
                    subtitle: const Text('首选方式，需要服务器支持WebSocket协议'),
                    value: useWebsocket,
                    onChanged: (value) {
                      setState(() {
                        if (value ?? false) {
                          if (!settings['transports'].contains('websocket')) {
                            settings['transports'].add('websocket');
                          }
                        } else {
                          settings['transports'].remove('websocket');
                          // 确保至少有一种传输方式
                          if (settings['transports'].isEmpty) {
                            settings['transports'].add('polling');
                            setState(() => usePolling = true);
                          }
                        }
                      });
                    },
                    dense: true,
                  ),
                  CheckboxListTile(
                    title: const Text('Long Polling'),
                    subtitle: const Text('备选方式，使用HTTP轮询，兼容性更好'),
                    value: usePolling,
                    onChanged: (value) {
                      setState(() {
                        if (value ?? false) {
                          if (!settings['transports'].contains('polling')) {
                            settings['transports'].add('polling');
                          }
                        } else {
                          settings['transports'].remove('polling');
                          // 确保至少有一种传输方式
                          if (settings['transports'].isEmpty) {
                            settings['transports'].add('websocket');
                            setState(() => useWebsocket = true);
                          }
                        }
                      });
                    },
                    dense: true,
                  ),

                  const SizedBox(height: 16),

                  // 其他配置项...
                  SwitchListTile(
                    title: const Text('启用自动重连'),
                    subtitle: const Text('当连接断开时自动尝试重新连接'),
                    value: settings['reconnection'],
                    onChanged: (value) {
                      setState(() => settings['reconnection'] = value);
                    },
                    dense: true,
                  ),

                  const Text('连接超时 (毫秒):'),
                  Slider(
                    value: settings['timeout'].toDouble(),
                    min: 5000,
                    max: 30000,
                    divisions: 25,
                    label: '${settings['timeout']}ms',
                    onChanged: (value) {
                      setState(() => settings['timeout'] = value.toInt());
                    },
                  ),
                  Text('当前值: ${settings['timeout']}ms',
                      style: TextStyle(fontSize: 12, color: Colors.grey[700])),

                  if (settings['reconnection']) ...[
                    const SizedBox(height: 8),
                    const Text('重连尝试次数:'),
                    Slider(
                      value: settings['reconnectionAttempts'].toDouble(),
                      min: 1,
                      max: 20,
                      divisions: 19,
                      label: '${settings['reconnectionAttempts']}次',
                      onChanged: (value) {
                        setState(() =>
                            settings['reconnectionAttempts'] = value.toInt());
                      },
                    ),
                    Text('当前值: ${settings['reconnectionAttempts']}次',
                        style:
                            TextStyle(fontSize: 12, color: Colors.grey[700])),
                    const SizedBox(height: 8),
                    const Text('重连延迟 (毫秒):'),
                    Slider(
                      value: settings['reconnectionDelay'].toDouble(),
                      min: 1000,
                      max: 10000,
                      divisions: 9,
                      label: '${settings['reconnectionDelay']}ms',
                      onChanged: (value) {
                        setState(() =>
                            settings['reconnectionDelay'] = value.toInt());
                      },
                    ),
                    Text('当前值: ${settings['reconnectionDelay']}ms',
                        style:
                            TextStyle(fontSize: 12, color: Colors.grey[700])),
                  ],

                  const SizedBox(height: 16),

                  TextField(
                    decoration: const InputDecoration(
                      labelText: '路径前缀',
                      helperText: '通常为 /socket.io/',
                    ),
                    controller: TextEditingController(text: settings['path']),
                    onChanged: (value) {
                      settings['path'] = value;
                    },
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              // 更新服务器URL
              settings['serverUrl'] = serverUrlController.text;

              // 保存修改后的配置
              _saveSocketSettings(settings);
              Navigator.of(context).pop();

              // 提示用户修改已保存
              UINotificationHelper.showSuccess('Socket.IO配置已更新');
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  // 运行诊断
  Future<void> _runDiagnostics(
    String serverUrl,
    String token, {
    required Function(Function()) setState,
  }) async {
    if (serverUrl.isEmpty) {
      UINotificationHelper.showError('请输入服务器地址');
      return;
    }

    setState(() => _isRunningDiagnosis = true);

    try {
      final results = token.isNotEmpty
          ? await _socketTest.runTest(serverUrl, token)
          : await _networkDiagnostics.runDiagnostics(serverUrl);

      setState(() => _isRunningDiagnosis = false);

      // 显示结果对话框
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('诊断结果'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDiagnosticResultsWidget(results),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('关闭'),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() => _isRunningDiagnosis = false);
      UINotificationHelper.showError('诊断过程中出错: ${e.toString()}');
    }
  }

  // 构建诊断结果显示
  Widget _buildDiagnosticResultsWidget(Map<String, dynamic> results) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (results.containsKey('diagnostics')) ...[
          _buildSocketTestResultsWidget(results),
        ] else ...[
          // DNS诊断
          if (results.containsKey('dns')) ...[
            Text(
              'DNS解析: ${results['dns']['success'] ? '成功' : '失败'}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: results['dns']['success'] ? Colors.green : Colors.red,
              ),
            ),
            if (results['dns']['success']) ...[
              const SizedBox(height: 4),
              Text('IP地址: ${results['dns']['addresses'].join(', ')}'),
            ],
            if (!results['dns']['success'] &&
                results['dns'].containsKey('error'))
              Text('错误: ${results['dns']['error']}'),
            const SizedBox(height: 12),
          ],

          // TCP连接诊断
          if (results.containsKey('tcp')) ...[
            Text(
              'TCP连接: ${results['tcp']['success'] ? '成功' : '失败'}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: results['tcp']['success'] ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 12),
          ],

          // HTTP请求诊断
          if (results.containsKey('http')) ...[
            Text(
              'HTTP请求: ${results['http']['success'] ? '成功' : '失败'}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: results['http']['success'] ? Colors.green : Colors.red,
              ),
            ),
            if (results['http']['success']) ...[
              const SizedBox(height: 4),
              Text('状态码: ${results['http']['statusCode']}'),
            ],
            if (!results['http']['success'] &&
                results['http'].containsKey('error'))
              Text('错误: ${results['http']['error']}'),
            const SizedBox(height: 12),
          ],

          // Socket.IO握手诊断
          if (results.containsKey('socketio')) ...[
            Text(
              'Socket.IO握手: ${results['socketio']['success'] ? '成功' : '失败'}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color:
                    results['socketio']['success'] ? Colors.green : Colors.red,
              ),
            ),
            if (results['socketio']['success']) ...[
              const SizedBox(height: 4),
              Text('SID: ${results['socketio']['sid'] ?? '未获取'}'),
            ],
            if (!results['socketio']['success'] &&
                results['socketio'].containsKey('error'))
              Text('错误: ${results['socketio']['error']}'),
            const SizedBox(height: 12),
          ],

          // 系统信息
          if (results.containsKey('system')) ...[
            const Text(
              '系统信息:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text('平台: ${results['system']['platform']}'),
            Text('版本: ${results['system']['version']}'),
            Text('主机名: ${results['system']['localHostname']}'),
          ],
        ],
      ],
    );
  }

  // 处理Socket测试结果
  Widget _buildSocketTestResultsWidget(Map<String, dynamic> results) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 显示诊断结果
        if (results.containsKey('diagnostics')) ...[
          // DNS诊断
          if (results['diagnostics'].containsKey('dns')) ...[
            Text(
              'DNS解析: ${results['diagnostics']['dns']['success'] ? '成功' : '失败'}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: results['diagnostics']['dns']['success']
                    ? Colors.green
                    : Colors.red,
              ),
            ),
            if (results['diagnostics']['dns']['success']) ...[
              const SizedBox(height: 4),
              Text(
                  'IP地址: ${results['diagnostics']['dns']['addresses'].join(', ')}'),
            ],
            if (!results['diagnostics']['dns']['success'] &&
                results['diagnostics']['dns'].containsKey('error'))
              Text('错误: ${results['diagnostics']['dns']['error']}'),
            const SizedBox(height: 12),
          ],

          // TCP连接诊断
          if (results['diagnostics'].containsKey('tcp')) ...[
            Text(
              'TCP连接: ${results['diagnostics']['tcp']['success'] ? '成功' : '失败'}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: results['diagnostics']['tcp']['success']
                    ? Colors.green
                    : Colors.red,
              ),
            ),
            const SizedBox(height: 12),
          ],

          // HTTP请求诊断
          if (results['diagnostics'].containsKey('http')) ...[
            Text(
              'HTTP请求: ${results['diagnostics']['http']['success'] ? '成功' : '失败'}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: results['diagnostics']['http']['success']
                    ? Colors.green
                    : Colors.red,
              ),
            ),
            if (results['diagnostics']['http']['success']) ...[
              const SizedBox(height: 4),
              Text('状态码: ${results['diagnostics']['http']['statusCode']}'),
            ],
            if (!results['diagnostics']['http']['success'] &&
                results['diagnostics']['http'].containsKey('error'))
              Text('错误: ${results['diagnostics']['http']['error']}'),
            const SizedBox(height: 12),
          ],

          // Socket.IO握手诊断
          if (results['diagnostics'].containsKey('socketio')) ...[
            Text(
              'Socket.IO握手: ${results['diagnostics']['socketio']['success'] ? '成功' : '失败'}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: results['diagnostics']['socketio']['success']
                    ? Colors.green
                    : Colors.red,
              ),
            ),
            if (results['diagnostics']['socketio']['success']) ...[
              const SizedBox(height: 4),
              Text(
                  'SID: ${results['diagnostics']['socketio']['sid'] ?? '未获取'}'),
            ],
            if (!results['diagnostics']['socketio']['success'] &&
                results['diagnostics']['socketio'].containsKey('error'))
              Text('错误: ${results['diagnostics']['socketio']['error']}'),
            const SizedBox(height: 12),
          ],

          // 系统信息
          if (results['diagnostics'].containsKey('system')) ...[
            const Text(
              '系统信息:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text('平台: ${results['diagnostics']['system']['platform']}'),
            Text('版本: ${results['diagnostics']['system']['version']}'),
            Text('主机名: ${results['diagnostics']['system']['localHostname']}'),
            const SizedBox(height: 12),
          ],
        ],

        const Divider(),

        // Socket连接结果
        Text(
          'Socket连接: ${results['success'] ? '成功' : '失败'}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: results['success'] ? Colors.green : Colors.red,
          ),
        ),
        if (results.containsKey('socket') && results['socket'] is Map) ...[
          const SizedBox(height: 8),
          ...results['socket'].entries.map((e) => Text('${e.key}: ${e.value}')),
        ],
      ],
    );
  }
}
