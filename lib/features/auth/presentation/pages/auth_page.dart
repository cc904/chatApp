import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/auth_cubit.dart';

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
                color: Colors.black.withOpacity(0.1),
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
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
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
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildQuickLogin(),
                      _buildPasswordLogin(),
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: '手机号',
              prefixIcon: Icon(Icons.phone),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _verificationCodeController,
                  decoration: const InputDecoration(
                    labelText: '验证码',
                    prefixIcon: Icon(Icons.message),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  // TODO: 发送验证码
                },
                child: const Text('获取验证码'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // TODO: 验证码登录
            },
            child: const Text('登录'),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordLogin() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: '手机号',
              prefixIcon: Icon(Icons.phone),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            decoration: const InputDecoration(
              labelText: '密码',
              prefixIcon: Icon(Icons.lock),
            ),
            obscureText: true,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _isLogin = false;
                  });
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
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (_isLogin) {
                // TODO: 密码登录
              } else {
                // TODO: 注册
              }
            },
            child: Text(_isLogin ? '登录' : '注册'),
          ),
        ],
      ),
    );
  }
}
