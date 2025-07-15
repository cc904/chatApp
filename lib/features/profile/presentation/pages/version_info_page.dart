import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cc/core/services/version_info_service.dart';
import 'package:cc/core/services/version_update_service.dart';
import 'package:cc/core/services/log_service.dart';

/// 版本信息页面
class VersionInfoPage extends StatefulWidget {
  const VersionInfoPage({super.key});

  @override
  State<VersionInfoPage> createState() => _VersionInfoPageState();
}

class _VersionInfoPageState extends State<VersionInfoPage> {
  final LogService _logger = LogService.instance;
  final VersionInfoService _versionService = VersionInfoService.instance;
  final VersionUpdateService _updateService = VersionUpdateService.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('版本信息'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // 应用图标和版本
            _buildAppVersionHeader(),
            
            const SizedBox(height: 30),
            
            // 版本详细信息
            _buildVersionDetails(),
            
            const SizedBox(height: 20),
            
            // 设备信息
            _buildDeviceInfo(),
            
            const SizedBox(height: 20),
            
            // 操作按钮
            _buildActionButtons(),
            
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildAppVersionHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 应用图标
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(
              Icons.chat,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          
          // 应用名称
          Text(
            _versionService.appName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          
          // 版本号
          Text(
            'v${_versionService.currentVersion}',
            style: const TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          
          // 构建号
          Text(
            'Build ${_versionService.buildNumber}',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionDetails() {
    return _buildSection(
      title: '版本详情',
      children: [
        _buildInfoTile(
          icon: Icons.info_outline,
          title: '应用版本',
          content: _versionService.currentVersion,
        ),
        const Divider(height: 1),
        _buildInfoTile(
          icon: Icons.build,
          title: '构建号',
          content: _versionService.buildNumber,
        ),
        const Divider(height: 1),
        _buildInfoTile(
          icon: Icons.developer_mode,
          title: '调试模式',
          content: _versionService.isDebugMode ? '是' : '否',
        ),
        const Divider(height: 1),
        _buildInfoTile(
          icon: Icons.apps,
          title: '包名',
          content: _versionService.packageName,
          copyable: true,
        ),
      ],
    );
  }

  Widget _buildDeviceInfo() {
    final deviceInfo = _versionService.deviceInfo;
    
    return _buildSection(
      title: '设备信息',
      children: [
        _buildInfoTile(
          icon: Icons.phone_android,
          title: '平台',
          content: _versionService.platformName,
        ),
        const Divider(height: 1),
        _buildInfoTile(
          icon: Icons.devices,
          title: '设备型号',
          content: deviceInfo?.model ?? 'Unknown',
        ),
        const Divider(height: 1),
        _buildInfoTile(
          icon: Icons.business,
          title: '品牌',
          content: deviceInfo?.brand ?? 'Unknown',
        ),
        const Divider(height: 1),
        _buildInfoTile(
          icon: Icons.system_security_update,
          title: '系统版本',
          content: '${deviceInfo?.systemName ?? 'Unknown'} ${deviceInfo?.osVersion ?? ''}',
        ),
        const Divider(height: 1),
        _buildInfoTile(
          icon: Icons.fingerprint,
          title: '设备ID',
          content: deviceInfo?.deviceId ?? 'Unknown',
          copyable: true,
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.system_update, color: Colors.blue),
            title: const Text('检查更新'),
            subtitle: const Text('手动检查是否有新版本'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _updateService.manualCheckUpdate(context);
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.content_copy, color: Colors.green),
            title: const Text('复制版本信息'),
            subtitle: const Text('复制详细版本信息到剪贴板'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _copyVersionInfo,
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.bug_report, color: Colors.orange),
            title: const Text('测试版本更新'),
            subtitle: const Text('模拟登录时的版本更新通知'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _updateService.simulateLoginVersionUpdate(context);
            },
          ),
        ],
      ),
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
                color: Colors.black.withValues(alpha: 0.05),
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

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String content,
    bool copyable = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.green),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        content,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black87,
        ),
      ),
      trailing: copyable
          ? IconButton(
              icon: const Icon(Icons.copy, size: 20),
              onPressed: () => _copyToClipboard(content),
            )
          : null,
      onTap: copyable ? () => _copyToClipboard(content) : null,
    );
  }

  /// 复制到剪贴板
  Future<void> _copyToClipboard(String text) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('已复制到剪贴板: $text'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _logger.e('复制到剪贴板失败', error: e);
    }
  }

  /// 复制版本信息
  Future<void> _copyVersionInfo() async {
    try {
      final versionSummary = _versionService.getVersionSummary();
      await Clipboard.setData(ClipboardData(text: versionSummary));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('版本信息已复制到剪贴板'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _logger.e('复制版本信息失败', error: e);
    }
  }
}