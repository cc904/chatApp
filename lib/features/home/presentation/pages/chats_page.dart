import 'package:flutter/material.dart';
import 'dart:developer' as dev;

class ChatsPage extends StatelessWidget {
  const ChatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    dev.log('ChatsPage build');
    return ListView.separated(
      itemCount: 20, // 模拟数据数量
      separatorBuilder: (context, index) => const Divider(
        height: 1,
        indent: 72,
      ),
      itemBuilder: (context, index) {
        // 模拟聊天列表数据
        return _buildChatItem(
          name: '联系人 ${index + 1}',
          message: '这是最近的一条消息 ${index + 1}',
          time: '下午 ${(index % 12) + 1}:${index % 60 < 10 ? '0' : ''}${index % 60}',
          unreadCount: index % 3 == 0 ? index % 5 : 0,
          avatarUrl: 'https://picsum.photos/200?random=$index',
        );
      },
    );
  }

  Widget _buildChatItem({
    required String name,
    required String message,
    required String time,
    required int unreadCount,
    required String avatarUrl,
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
          Expanded(
            child: Text(
              message,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            time,
            style: TextStyle(
              fontSize: 12,
              color: unreadCount > 0 ? Colors.green : Colors.grey,
            ),
          ),
          if (unreadCount > 0)
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: Text(
                unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else
            const SizedBox(height: 16),
        ],
      ),
      onTap: () {
        // 打开聊天详情页
        dev.log('打开聊天: $name');
      },
    );
  }
}
