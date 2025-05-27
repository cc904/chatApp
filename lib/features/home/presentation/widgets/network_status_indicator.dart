import 'package:flutter/material.dart';
import 'package:cc/features/home/presentation/cubit/home_state.dart';

/// 网络状态指示器组件
/// 用于在 AppBar 中显示网络状态
/// 只在网络异常时显示
class NetworkStatusIndicator extends StatelessWidget {
  final NetworkStatus networkStatus;
  final VoidCallback onRetry;
  final bool showInAppBar;
  
  const NetworkStatusIndicator({
    super.key,
    required this.networkStatus,
    required this.onRetry,
    this.showInAppBar = true,
  });

  @override
  Widget build(BuildContext context) {
    // 如果网络正常且在AppBar中显示，则不显示任何内容
    if (networkStatus == NetworkStatus.connected && showInAppBar) {
      return const SizedBox.shrink();
    }

    return _buildNetworkStatusWidget(context);
  }

  Widget _buildNetworkStatusWidget(BuildContext context) {
    final theme = Theme.of(context);
    
    // 根据网络状态选择不同的图标和颜色
    IconData icon;
    Color color;
    String message;
    bool showSpinner = false;
    
    switch (networkStatus) {
      case NetworkStatus.connected:
        icon = Icons.wifi;
        color = Colors.green;
        message = "网络已连接";
        break;
      case NetworkStatus.connecting:
        icon = Icons.wifi_find;
        color = Colors.orange;
        message = "正在连接网络...";
        showSpinner = true;
        break;
      case NetworkStatus.disconnected:
        icon = Icons.wifi_off;
        color = Colors.red;
        message = "网络已断开";
        break;
      case NetworkStatus.error:
        icon = Icons.error_outline;
        color = Colors.red;
        message = "网络连接错误";
        break;
    }

    // 在AppBar中显示的简洁版本
    if (showInAppBar) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showSpinner)
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            )
          else
            Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            message,
            style: theme.textTheme.bodySmall?.copyWith(color: color),
          ),
        ],
      );
    }
    
    // 页面中显示的完整版本
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      color: color.withAlpha(30),
      child: Row(
        children: [
          if (showSpinner)
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            )
          else
            Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(color: color),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: const Size(60, 30),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              "重试",
              style: theme.textTheme.bodySmall?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}

/// AppBar 标题带网络状态指示器
class AppBarTitleWithNetworkStatus extends StatelessWidget {
  final String title;
  final NetworkStatus networkStatus;
  final bool isLoading;
  final VoidCallback onRetry;

  const AppBarTitleWithNetworkStatus({
    super.key,
    required this.title,
    required this.networkStatus,
    required this.onRetry,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 标题行：标题文本 + 加载指示器（如果正在加载）
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title),
            if (isLoading) ...[
              const SizedBox(width: 8),
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ],
        ),
        
        // 网络状态指示器（只在非连接状态下显示）
        if (networkStatus != NetworkStatus.connected)
          NetworkStatusIndicator(
            networkStatus: networkStatus,
            onRetry: onRetry,
            showInAppBar: true,
          ),
      ],
    );
  }
}
