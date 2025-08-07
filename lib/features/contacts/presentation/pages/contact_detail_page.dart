import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cc/core/database/drift_database.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/widgets/user_avatar.dart';

/// 联系人详情页面
/// 显示联系人的详细信息，提供聊天、音视频通话等操作
class ContactDetailPage extends StatefulWidget {
  final User contact;

  const ContactDetailPage({
    super.key,
    required this.contact,
  });

  @override
  State<ContactDetailPage> createState() => _ContactDetailPageState();
}

class _ContactDetailPageState extends State<ContactDetailPage> {
  final _logger = LogService.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('联系人信息'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: _showMoreOptions,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 联系人基本信息卡片
            _buildContactInfoCard(),

            const SizedBox(height: 10),

            // 操作按钮区域
            _buildActionButtons(),

            const SizedBox(height: 10),

            // 详细资料
            _buildDetailInfo(),

            const SizedBox(height: 10),

            // 朋友圈
            _buildMomentsSection(),
          ],
        ),
      ),
    );
  }

  /// 获取联系人显示名称
  /// 优先级：nickname > name
  String _getContactDisplayName() {
    // 1. 优先使用自定义联系人昵称
    if (widget.contact.nickname != null && widget.contact.nickname!.isNotEmpty) {
      return widget.contact.nickname!;
    }

    // 2. 使用用户昵称
    return widget.contact.name;
  }

  /// 构建联系人基本信息卡片
  Widget _buildContactInfoCard() {
    final displayName = _getContactDisplayName();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 头像
          UserAvatar(
        avatarUrl: widget.contact.avatar,
        userId: widget.contact.userId,
            name: displayName,
            radius: 40,
            roleId: widget.contact.roleId,
          ),
          const SizedBox(width: 20),
          // 名称和其他基本信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'ID: ',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      widget.contact.userId,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 16, color: Colors.grey),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: widget.contact.userId));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('ID已复制到剪贴板'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                        _logger.i('复制ID：${widget.contact.userId}');
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建操作按钮区域
  Widget _buildActionButtons() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            icon: Icons.message,
            label: '发消息',
            onTap: _openChatPage,
          ),
          _buildActionButton(
            icon: Icons.call,
            label: '语音通话',
            onTap: () => _makeCall(isVideo: false),
          ),
          _buildActionButton(
            icon: Icons.videocam,
            label: '视频通话',
            onTap: () => _makeCall(isVideo: true),
          ),
        ],
      ),
    );
  }

  /// 构建单个操作按钮
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Column(
          children: [
            Icon(icon, color: Colors.green, size: 28),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建详细资料区域
  Widget _buildDetailInfo() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '详细资料',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoItem('备注', ''),
          _buildInfoItem('标签', ''),
        ],
      ),
    );
  }

  /// 构建单个信息项
  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : '未设置',
              style: TextStyle(
                color: value.isNotEmpty ? Colors.black87 : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建朋友圈区域
  Widget _buildMomentsSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '朋友圈',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios, size: 16),
                onPressed: () {
                  _logger.i('查看朋友圈');
                  // TODO 实现查看朋友圈功能
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 朋友圈预览（示例）
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text('暂无朋友圈动态'),
            ),
          ),
        ],
      ),
    );
  }

  /// 打开聊天页面
  void _openChatPage() async {
    _logger.i('打开与${widget.contact.name}的聊天');

    // final homeCubit = context.read<HomeCubit>();
    // final conversationId =
    //     await homeCubit.getOrCreatePrivateConversation(widget.contact.userId);

    // if (conversationId != null && mounted) {
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //       builder: (context) => BlocProvider.value(
    //         value: homeCubit,
    //         child: ChatDetailPage(
    //           contact: widget.contact,
    //           conversationId: conversationId,
    //         ),
    //       ),
    //     ),
    //   );
    // }
  }

  /// 发起通话
  void _makeCall({required bool isVideo}) {
    _logger.i('发起${isVideo ? '视频' : '语音'}通话');
    // TODO 实现通话功能
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('功能暂未开放'),
      ),
    );
  }

  /// 显示更多选项
  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('设置备注和标签'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO 实现设置备注和标签功能
                },
              ),
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('分享联系人'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO 实现分享联系人功能
                },
              ),
              ListTile(
                leading: const Icon(Icons.star_border),
                title: const Text('设为星标朋友'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO 实现设为星标朋友功能
                },
              ),
              ListTile(
                leading: const Icon(Icons.block, color: Colors.red),
                title: const Text('拉黑', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  // TODO 实现拉黑功能
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('删除联系人', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmDialog();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// 显示删除确认对话框
  void _showDeleteConfirmDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('删除联系人'),
          content: Text('确定要删除联系人 ${widget.contact.name} 吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // TODO 实现删除联系人功能
                _logger.i('删除联系人: ${widget.contact.name}');
                Navigator.pop(context); // 返回上一页
              },
              child: const Text('删除', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
