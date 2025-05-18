import 'package:flutter/material.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/database/models/user.dart';

class CallsPage extends StatelessWidget {
  final List<User> contacts;

  const CallsPage({
    super.key,
    required this.contacts,
  });

  @override
  Widget build(BuildContext context) {
    final logger = LogService.instance;
    logger.d('CallsPage build');
    return Scaffold(
      appBar: AppBar(
        title: const Text('通话', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
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
                        logger.d('清空通话记录');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.settings),
                      title: const Text('通话设置'),
                      onTap: () {
                        Navigator.pop(context);
                        logger.d('通话设置');
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
                    '分享一个链接,邀请任何人加入WhatsApp通话,即使他们没有WhatsApp',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      // 创建通话连接
                      logger.d('创建通话连接');
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
              itemCount: contacts.length,
              separatorBuilder: (context, index) => const Divider(
                height: 1,
                indent: 72,
              ),
              itemBuilder: (context, index) {
                final contact = contacts[index];
                final isVideo = index % 2 == 0;
                final isOutgoing = index % 3 == 0;

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: contact.avatar != null ? NetworkImage(contact.avatar!) : null,
                    child: contact.avatar == null ? Text(contact.name[0]) : null,
                  ),
                  title: Text(contact.name),
                  subtitle: Text(
                    '${isOutgoing ? '拨出' : '拨入'} · 今天 ${(index % 12) + 1}:${index % 60 < 10 ? '0' : ''}${index % 60}',
                  ),
                  trailing: Icon(
                    isVideo ? Icons.videocam : Icons.call,
                    color: isOutgoing ? Colors.green : Colors.red,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
