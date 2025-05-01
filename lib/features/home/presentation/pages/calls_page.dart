import 'package:flutter/material.dart';
import 'dart:developer' as dev;
import 'dart:math' as math;

class CallsPage extends StatelessWidget {
  const CallsPage({super.key});

  @override
  Widget build(BuildContext context) {
    dev.log('CallsPage build');
    return Scaffold(
      appBar: AppBar(
        title: const Text('通话', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // 搜索通话记录
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // 更多选项
              showModalBottomSheet(
                context: context,
                builder: (context) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.delete),
                      title: const Text('清空通话记录'),
                      onTap: () {
                        Navigator.pop(context);
                        dev.log('清空通话记录');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.settings),
                      title: const Text('通话设置'),
                      onTap: () {
                        Navigator.pop(context);
                        dev.log('通话设置');
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 通话连接卡片
          Card(
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.link,
                        color: Colors.green[700],
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          '创建通话连接',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '分享一个链接，邀请任何人加入WhatsApp通话，即使他们没有WhatsApp',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      // 创建通话连接
                      dev.log('创建通话连接');
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.green[50],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: Text(
                      '创建连接',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 通话历史记录标题
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  '最近',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          // 通话历史记录列表
          Expanded(
            child: ListView.separated(
              itemCount: 10,
              separatorBuilder: (context, index) => const Divider(
                height: 1,
                indent: 72,
              ),
              itemBuilder: (context, index) {
                // 随机生成通话类型和方向
                final bool isVideo = math.Random().nextBool();
                final bool isOutgoing = math.Random().nextBool();
                final bool isMissed = !isOutgoing && math.Random().nextBool();

                return _buildCallItem(
                  name: '联系人 ${index + 1}',
                  time: '${isOutgoing ? '拨出' : '拨入'} · 今天 ${(index % 12) + 1}:${index % 60 < 10 ? '0' : ''}${index % 60}',
                  avatarUrl: 'https://picsum.photos/200?random=${index + 30}',
                  isVideo: isVideo,
                  isOutgoing: isOutgoing,
                  isMissed: isMissed,
                  callCount: math.Random().nextInt(3) + 1,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallItem({
    required String name,
    required String time,
    required String avatarUrl,
    required bool isVideo,
    required bool isOutgoing,
    required bool isMissed,
    required int callCount,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(avatarUrl),
        radius: 24,
      ),
      title: Text(
        name,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      subtitle: Row(
        children: [
          Icon(
            isOutgoing ? Icons.call_made : Icons.call_received,
            size: 16,
            color: isMissed ? Colors.red : Colors.green,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              time,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          if (callCount > 1)
            Text(
              '($callCount)',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
        ],
      ),
      trailing: IconButton(
        icon: Icon(
          isVideo ? Icons.videocam : Icons.call,
          color: Colors.green,
        ),
        onPressed: () {
          // 发起通话
          dev.log('发起${isVideo ? '视频' : '语音'}通话: $name');
        },
      ),
      onTap: () {
        // 查看通话详情
        dev.log('查看通话详情: $name');
      },
    );
  }
}
