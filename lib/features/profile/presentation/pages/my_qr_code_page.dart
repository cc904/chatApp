import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:cc/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:cc/core/services/ui_notification_service.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/widgets/user_avatar.dart';

class MyQRCodePage extends StatefulWidget {
  const MyQRCodePage({super.key});

  @override
  State<MyQRCodePage> createState() => _MyQRCodePageState();
}

class _MyQRCodePageState extends State<MyQRCodePage> {
  final _logger = LogService.instance;
  bool _isCopied = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F2F7),
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text('我的二维码'),
        actions: [
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'save',
                child: Row(
                  children: [
                    Icon(Icons.download, color: Colors.black54),
                    SizedBox(width: 8),
                    Text('保存到相册'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share, color: Colors.black54),
                    SizedBox(width: 8),
                    Text('分享'),
                  ],
                ),
              ),
            ],
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          final user = state.user;

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 40),

                // 二维码卡片
                _buildQRCodeCard(user),

                const SizedBox(height: 30),

                // 使用说明
                _buildInstructions(),

                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildQRCodeCard(user) {
    final userId = user?.userId ?? '';
    final qrData = 'user:$userId';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // 用户头像和信息
          Row(
            children: [
              UserAvatar(
                avatarUrl: user?.avatar,
                userId: user?.userId,
                name: user?.name ?? '用户',
                radius: 30,
                backgroundColor: Colors.green,
                roleId: user?.roleId,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.name ?? '用户昵称',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (user?.status?.isNotEmpty == true)
                      Text(
                        user!.status!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          // 二维码
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.grey[200]!,
                width: 1,
              ),
            ),
            child: QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 200,
              gapless: false,
              errorStateBuilder: (context, error) {
                return Container(
                  width: 200,
                  height: 200,
                  color: Colors.grey[100],
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, color: Colors.red, size: 40),
                        SizedBox(height: 8),
                        Text('二维码生成失败'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // 用户ID
          Text(
            'ID: $userId',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontFamily: 'monospace',
            ),
          ),

          const SizedBox(height: 20),

          // 操作按钮
          Row(
            children: [
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: ElevatedButton.icon(
                    onPressed: () => _copyUserData(qrData),
                    icon: Icon(
                      _isCopied ? Icons.check : Icons.copy,
                      size: 18,
                    ),
                    label: Text(_isCopied ? '已复制' : '复制信息'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _isCopied ? Colors.green[200] : Colors.green[50],
                      foregroundColor:
                          _isCopied ? Colors.green[800] : Colors.green[700],
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _shareQRCode(qrData),
                  icon: const Icon(Icons.share, size: 18),
                  label: const Text('分享'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[50],
                    foregroundColor: Colors.green[700],
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.green[700],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '使用说明',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InstructionItem(
                icon: Icons.qr_code_scanner,
                title: '扫描添加',
                subtitle: '朋友可以扫描此二维码添加您为联系人',
              ),
              SizedBox(height: 12),
              _InstructionItem(
                icon: Icons.share,
                title: '分享名片',
                subtitle: '点击分享按钮将您的名片发送给朋友',
              ),
              SizedBox(height: 12),
              _InstructionItem(
                icon: Icons.security,
                title: '隐私保护',
                subtitle: '二维码不包含敏感信息，可以安全分享',
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'save':
        _saveQRCode();
        break;
      case 'share':
        _shareQRCodeImage();
        break;
    }
  }

  void _copyUserData(String qrData) {
    // 从qrData中提取用户ID (格式: 'user:userId')
    final userId = qrData.startsWith('user:') ? qrData.substring(5) : qrData;

    Clipboard.setData(ClipboardData(text: userId));

    _logger.i('复制用户ID', extra: {'userId': userId});

    // 设置为已复制状态
    setState(() {
      _isCopied = true;
    });

    // 3秒后恢复原状态
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isCopied = false;
        });
      }
    });
  }

  void _shareQRCode(String qrData) {
    // TODO: 实现分享功能
            UINotificationService.instance.showInfo('功能暂未开放');

    _logger.i('分享二维码', extra: {'qrData': qrData});
  }

  void _saveQRCode() {
    // TODO: 实现保存到相册功能
            UINotificationService.instance.showInfo('功能暂未开放');

    _logger.i('保存二维码到相册');
  }

  void _shareQRCodeImage() {
    // TODO: 实现二维码图片分享功能
            UINotificationService.instance.showInfo('功能暂未开放');

    _logger.i('分享二维码图片');
  }
}

class _InstructionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InstructionItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.green[700],
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
