import 'package:flutter/material.dart';
import 'package:cc/core/services/proto_socket_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// 网络连接状态指示器
/// 在AppBar标题前显示小图标/动画，实时反映Socket连接状态。
class ConnectionStatusIndicator extends StatelessWidget {
  const ConnectionStatusIndicator({super.key, this.size = 16});

  /// 图标尺寸
  final double size;

  @override
  Widget build(BuildContext context) {
    final socketService = ProtoSocketService();
    final connectivity = Connectivity();

    return StreamBuilder<SocketConnectionStatus>(
      stream: socketService.connectionStateStream,
      initialData: socketService.status,
      builder: (context, socketSnapshot) {
        final socketStatus =
            socketSnapshot.data ?? SocketConnectionStatus.connected;

        // 连接正常时不显示任何图标
        if (socketStatus == SocketConnectionStatus.connected) {
          return const SizedBox.shrink();
        }

        switch (socketStatus) {
          case SocketConnectionStatus.connecting:
          case SocketConnectionStatus.reconnecting:
            // 连接中使用loading转圈圈
            return SizedBox(
              width: size,
              height: size,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
              ),
            );

          case SocketConnectionStatus.disconnected:
          case SocketConnectionStatus.error:
            // 断开时根据网络类型显示不同图标
            return StreamBuilder<List<ConnectivityResult>>(
              stream: connectivity.onConnectivityChanged,
              builder: (context, connectivitySnapshot) {
                return FutureBuilder<List<ConnectivityResult>>(
                  future: connectivity.checkConnectivity(),
                  builder: (context, futureSnapshot) {
                    final connectivityResults = connectivitySnapshot.data ??
                        futureSnapshot.data ??
                        const [ConnectivityResult.none];

                    final connectivityResult = connectivityResults.first;
                    IconData iconData;

                    switch (connectivityResult) {
                      case ConnectivityResult.wifi:
                      case ConnectivityResult.ethernet:
                        iconData = Icons.signal_wifi_connected_no_internet_4;
                        break;
                      case ConnectivityResult.mobile:
                        iconData = Icons.signal_cellular_nodata;
                        break;
                      case ConnectivityResult.none:
                      case ConnectivityResult.vpn:
                      case ConnectivityResult.bluetooth:
                      case ConnectivityResult.other:
                        iconData = Icons.signal_cellular_nodata;
                        break;
                    }

                    return Icon(
                      iconData,
                      size: size,
                    );
                  },
                );
              },
            );

          case SocketConnectionStatus.connected:
            return const SizedBox.shrink();
        }
      },
    );
  }
}
