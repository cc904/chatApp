import 'package:flutter/material.dart';
import 'package:cc/core/services/communication_service.dart';

/// 重连状态覆盖层
/// 显示在应用顶部，当连接断开时显示重连状态
class ReconnectingOverlay extends StatelessWidget {
  final CommunicationService _communicationService = CommunicationService();

  ReconnectingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: _communicationService.reconnectingStateStream,
      builder: (context, snapshot) {
        final isReconnecting = snapshot.data ?? false;

        if (!isReconnecting) return const SizedBox.shrink();

        return Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Material(
            color: Colors.orange.withAlpha(230),
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: const Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      '正在重新连接...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
