import 'package:flutter/material.dart';
import 'package:cc/core/services/ui_notification_service.dart';
import 'package:cc/core/widgets/top_notification.dart';

/// 通知测试页面
/// 用于测试和演示各种通知功能
class NotificationTestPage extends StatelessWidget {
  const NotificationTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('通知测试'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            '顶部通知测试',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          // 消息通知测试
          _buildTestButton(
            title: '消息通知',
            subtitle: '模拟聊天消息通知',
            onTap: () {
              UINotificationService.instance.showMessageNotification(
                senderName: '张三',
                messageText: '这是一条测试消息，用来验证顶部通知功能是否正常工作。',
                conversationName: '测试群聊',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('点击了消息通知')),
                  );
                },
              );
            },
          ),
          
          // 成功通知测试
          _buildTestButton(
            title: '成功通知',
            subtitle: '显示成功状态通知',
            onTap: () {
              UINotificationService.instance.showTopNotification(
                title: '操作成功',
                message: '您的操作已成功完成',
                type: TopNotificationType.success,
              );
            },
          ),
          
          // 错误通知测试
          _buildTestButton(
            title: '错误通知',
            subtitle: '显示错误状态通知',
            onTap: () {
              UINotificationService.instance.showTopNotification(
                title: '操作失败',
                message: '网络连接超时，请稍后重试',
                type: TopNotificationType.error,
              );
            },
          ),
          
          // 警告通知测试
          _buildTestButton(
            title: '警告通知',
            subtitle: '显示警告状态通知',
            onTap: () {
              UINotificationService.instance.showTopNotification(
                title: '注意',
                message: '您的账户余额不足，请及时充值',
                type: TopNotificationType.warning,
              );
            },
          ),
          
          // 信息通知测试
          _buildTestButton(
            title: '信息通知',
            subtitle: '显示一般信息通知',
            onTap: () {
              UINotificationService.instance.showTopNotification(
                title: '系统提示',
                message: '新版本已发布，建议您升级到最新版本',
                type: TopNotificationType.info,
              );
            },
          ),
          
          // 长消息测试
          _buildTestButton(
            title: '长消息测试',
            subtitle: '测试长文本消息的显示效果',
            onTap: () {
              UINotificationService.instance.showMessageNotification(
                senderName: '测试用户',
                messageText: '这是一条非常长的测试消息，用来验证顶部通知在处理长文本时的显示效果。消息内容可能会超过两行，需要检查是否正确处理了文本截断和显示。',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('点击了长消息通知')),
                  );
                },
              );
            },
          ),
          
          const SizedBox(height: 32),
          const Text(
            '底部通知测试',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          // SnackBar 通知测试
          _buildTestButton(
            title: 'SnackBar 通知',
            subtitle: '传统的底部通知',
            onTap: () {
              UINotificationService.instance.showInfo('这是一条底部 SnackBar 通知');
            },
          ),
          
          // Toast 通知测试
          _buildTestButton(
            title: 'Toast 通知',
            subtitle: '简短的提示消息',
            onTap: () {
              UINotificationService.instance.showToast(
                message: '这是一条 Toast 通知',
                type: ToastType.success,
              );
            },
          ),
          
          const SizedBox(height: 32),
          
          // 隐藏通知按钮
          ElevatedButton(
            onPressed: () {
              UINotificationService.instance.hideTopNotification();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('隐藏当前顶部通知'),
          ),
        ],
      ),
    );
  }

  Widget _buildTestButton({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.play_arrow),
        onTap: onTap,
      ),
    );
  }
}