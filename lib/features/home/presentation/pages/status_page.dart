import 'package:flutter/material.dart';
import 'package:cc/core/services/log_service.dart';
import 'dart:math' as math;

class StatusPage extends StatelessWidget {
  const StatusPage({super.key});

  static final _logger = LogService('status_page.dart');

  // 获取随机颜色
  static Color getRandomColor(int seed) {
    final random = math.Random(seed);
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.amber,
      Colors.cyan,
      Colors.indigo,
      Colors.pink,
    ];
    return colors[random.nextInt(colors.length)];
  }

  @override
  Widget build(BuildContext context) {
    _logger.d('StatusPage build');
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 我的状态部分
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Stack(
                children: [
                  CircleAvatar(
                    backgroundColor: getRandomColor(0),
                    child: const Text('我', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20)),
                    radius: 30,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
              title: const Text('我的状态'),
              subtitle: const Text('点击添加状态更新'),
              onTap: () {
                // 添加状态更新
                _logger.d('添加状态更新');
              },
            ),

            const SizedBox(height: 16),

            // 最近更新部分
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Text(
                '最近更新',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),

            // 最近更新列表
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: 5,
              itemBuilder: (context, index) {
                return _buildStatusItem(
                  name: '好友 ${index + 1}',
                  time: '${index + 1}小时前',
                  avatarSeed: index + 10,
                  hasUnviewedStatus: index < 2,
                );
              },
            ),

            const SizedBox(height: 16),

            // 已查看更新部分
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Text(
                '已查看的更新',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),

            // 已查看更新列表
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: 3,
              itemBuilder: (context, index) {
                return _buildStatusItem(
                  name: '好友 ${index + 6}',
                  time: '${index + 5}小时前',
                  avatarSeed: index + 20,
                  hasUnviewedStatus: false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem({
    required String name,
    required String time,
    required int avatarSeed,
    required bool hasUnviewedStatus,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: hasUnviewedStatus ? Colors.green : Colors.grey,
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: CircleAvatar(
            backgroundColor: getRandomColor(avatarSeed),
            child: Text(
              name.substring(0, 1),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            radius: 24,
          ),
        ),
      ),
      title: Text(
        name,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(time),
      onTap: () {
        // 查看状态
        _logger.d('查看状态', extra: {'name': name});
      },
    );
  }
}
