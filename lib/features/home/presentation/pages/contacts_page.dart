import 'package:flutter/material.dart';
import 'dart:developer' as dev;

class ContactsPage extends StatelessWidget {
  const ContactsPage({super.key});

  @override
  Widget build(BuildContext context) {
    dev.log('ContactsPage build');
    return ListView.separated(
      itemCount: 30, // 模拟数据数量
      separatorBuilder: (context, index) => const Divider(
        height: 1,
        indent: 72,
      ),
      itemBuilder: (context, index) {
        // 显示分组标题
        if (index == 0) {
          return _buildSectionHeader('A');
        } else if (index == 6) {
          return _buildSectionHeader('B');
        } else if (index == 12) {
          return _buildSectionHeader('C');
        } else if (index == 18) {
          return _buildSectionHeader('L');
        } else if (index == 24) {
          return _buildSectionHeader('Z');
        }

        // 显示联系人项
        return _buildContactItem(
          name: '联系人 ${index + 1}',
          subtitle: index % 3 == 0 ? '+86 1381234${(1000 + index).toString().padLeft(4, '0')}' : '状态: ${index % 2 == 0 ? '在线' : '离线'}',
          avatarUrl: 'https://picsum.photos/200?random=${index + 50}',
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey[100],
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.green,
        ),
      ),
    );
  }

  Widget _buildContactItem({
    required String name,
    required String subtitle,
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
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 14,
        ),
      ),
      onTap: () {
        // 打开联系人详情
        dev.log('打开联系人: $name');
      },
    );
  }
}
