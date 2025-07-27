import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cc/core/services/version_info_service.dart';
import 'package:cc/core/services/version_update_service.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/services/communication_service.dart';
import 'package:cc/core/services/proto_socket_service.dart';
import 'package:cc/core/services/network_latency_service.dart';
import 'dart:async';

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
            
            // 💢💢💢 新增：网络状态
            _buildNetworkStatus(),
            
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

  /// 💢💢💢 新增：构建网络状态部分
  Widget _buildNetworkStatus() {
    return _buildSection(
      title: '网络状态',
      children: [
        _buildNetworkStatusTile(),
      ],
    );
  }

  /// 构建网络状态列表项
  Widget _buildNetworkStatusTile() {
    return StreamBuilder<SocketConnectionStatus>(
      stream: ProtoSocketService().connectionStateStream,
      initialData: ProtoSocketService().status,
      builder: (context, connectionSnapshot) {
        final status = connectionSnapshot.data ?? SocketConnectionStatus.disconnected;
        final isConnected = status == SocketConnectionStatus.connected;
        
        return StreamBuilder<NetworkLatencyInfo>(
          stream: NetworkLatencyService.instance.latencyStream,
          builder: (context, latencySnapshot) {
            final latencyInfo = latencySnapshot.data;
            
            return ListTile(
              leading: Icon(
                isConnected ? Icons.wifi : Icons.wifi_off,
                color: isConnected ? Colors.green : Colors.red,
              ),
              title: Row(
                children: [
                  const Text('网络状态'),
                  const SizedBox(width: 8),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isConnected ? Colors.green : Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              subtitle: Text(
                _getConnectionStatusText(status, latencyInfo),
                style: TextStyle(
                  color: isConnected ? Colors.green : Colors.red,
                  fontSize: 12,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showNetworkStatusDialog(context, status, latencyInfo),
            );
          },
        );
      },
    );
  }

  /// 获取连接状态文本
  String _getConnectionStatusText(SocketConnectionStatus status, [NetworkLatencyInfo? latencyInfo]) {
    switch (status) {
      case SocketConnectionStatus.connected:
        if (latencyInfo?.quality != null && latencyInfo!.quality != LatencyQuality.unknown) {
          return '已连接 • ${latencyInfo.quality.label}';
        }
        return '已连接';
      case SocketConnectionStatus.connecting:
        return '连接中...';
      case SocketConnectionStatus.reconnecting:
        return '重连中...';
      case SocketConnectionStatus.disconnected:
        return '已断开';
      case SocketConnectionStatus.error:
        return '连接错误';
    }
  }

  /// 显示网络状态详情对话框
  void _showNetworkStatusDialog(BuildContext context, SocketConnectionStatus status, [NetworkLatencyInfo? latencyInfo]) {
    final commService = CommunicationService();
    
    // 💢💢💢 打开对话框时启动延迟监控
    if (status == SocketConnectionStatus.connected) {
      NetworkLatencyService.instance.startMonitoring();
      _logger.d('网络状态对话框打开，启动延迟监控');
    }
    
    showDialog(
      context: context,
      builder: (context) => _NetworkStatusDialog(
        status: status,
        initialLatencyInfo: latencyInfo,
        commService: commService,
        onBuildStatusRow: _buildStatusRow,
        getConnectionStatusText: _getConnectionStatusText,
      ),
    ).then((_) {
      // 💢💢💢 关闭对话框时停止延迟监控
      NetworkLatencyService.instance.stopMonitoring();
      _logger.d('网络状态对话框关闭，停止延迟监控');
    });
  }

  /// 构建状态行
  Widget _buildStatusRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 💢💢💢 网络状态对话框
class _NetworkStatusDialog extends StatefulWidget {
  final SocketConnectionStatus status;
  final NetworkLatencyInfo? initialLatencyInfo;
  final CommunicationService commService;
  final Widget Function(String, String, Color) onBuildStatusRow;
  final String Function(SocketConnectionStatus, [NetworkLatencyInfo?]) getConnectionStatusText;

  const _NetworkStatusDialog({
    required this.status,
    required this.initialLatencyInfo,
    required this.commService,
    required this.onBuildStatusRow,
    required this.getConnectionStatusText,
  });

  @override
  State<_NetworkStatusDialog> createState() => _NetworkStatusDialogState();
}

class _NetworkStatusDialogState extends State<_NetworkStatusDialog> {
  NetworkLatencyInfo? currentLatencyInfo;
  StreamSubscription<NetworkLatencyInfo>? _latencySubscription;

  @override
  void initState() {
    super.initState();
    currentLatencyInfo = widget.initialLatencyInfo;
    
    // 监听延迟信息变化
    _latencySubscription = NetworkLatencyService.instance.latencyStream.listen((latencyInfo) {
      if (mounted) {
        setState(() {
          currentLatencyInfo = latencyInfo;
        });
      }
    });
  }

  @override
  void dispose() {
    _latencySubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.network_check, size: 24),
          SizedBox(width: 8),
          Text('网络状态详情'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          widget.onBuildStatusRow('连接状态', widget.getConnectionStatusText(widget.status), 
              widget.status == SocketConnectionStatus.connected ? Colors.green : Colors.red),
          widget.onBuildStatusRow('服务器连接', widget.commService.isConnected ? '正常' : '断开',
              widget.commService.isConnected ? Colors.green : Colors.red),
          widget.onBuildStatusRow('初始化状态', widget.commService.isInitialized ? '已初始化' : '未初始化',
              widget.commService.isInitialized ? Colors.green : Colors.orange),
          
          // 延迟信息部分
          if (widget.status == SocketConnectionStatus.connected && currentLatencyInfo != null) ...[
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            widget.onBuildStatusRow('当前延迟', currentLatencyInfo!.getLatencyText(), currentLatencyInfo!.getQualityColor()),
            if (currentLatencyInfo!.sampleCount > 1) ...[
              widget.onBuildStatusRow('平均延迟', '${currentLatencyInfo!.averageLatency}ms', currentLatencyInfo!.getQualityColor()),
              widget.onBuildStatusRow('延迟范围', '${currentLatencyInfo!.minLatency}-${currentLatencyInfo!.maxLatency}ms', Colors.grey),
            ],
            widget.onBuildStatusRow('网络质量', currentLatencyInfo!.quality.label, currentLatencyInfo!.getQualityColor()),
            widget.onBuildStatusRow('成功测试', '${currentLatencyInfo!.sampleCount}次', Colors.grey),
            // 💢💢💢 修复：直接从NetworkLatencyService获取统计数据
            if (NetworkLatencyService.instance.totalTests > 0) ...[
              widget.onBuildStatusRow('总测试次数', '${NetworkLatencyService.instance.totalTests}次', Colors.grey),
              widget.onBuildStatusRow('失败次数', '${NetworkLatencyService.instance.failedTests}次', 
                NetworkLatencyService.instance.failedTests > 0 ? Colors.orange : Colors.grey),
              widget.onBuildStatusRow('成功率', NetworkLatencyService.instance.getSuccessRateText(), 
                NetworkLatencyService.instance.getSuccessRate() >= 90 ? Colors.green : 
                NetworkLatencyService.instance.getSuccessRate() >= 70 ? Colors.orange : Colors.red),
            ],
          ],
          
          const SizedBox(height: 16),
          Text(
            widget.status == SocketConnectionStatus.connected 
              ? '提示：此页面打开时，延迟测试每1秒自动执行一次，最多测试30次。数据会实时更新。'
              : '提示：网络状态影响消息的发送和接收。如果网络不稳定，请检查网络连接。',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      actions: [
        if (!widget.commService.isConnected)
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                final reconnected = await widget.commService.reconnect();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(reconnected ? '重连成功' : '重连失败'),
                      backgroundColor: reconnected ? Colors.green : Colors.red,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('重连失败: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('重连'),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('关闭'),
        ),
      ],
    );
  }
}