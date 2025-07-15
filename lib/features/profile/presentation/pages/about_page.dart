import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cc/core/l10n/app_localizations.dart';
import 'package:cc/core/services/log_service.dart';

/// 关于我们页面
class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  final LogService _logger = LogService.instance;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.aboutUs),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // 应用图标和名称
            _buildAppHeader(),
            
            const SizedBox(height: 30),
            
            // 应用信息
            _buildAppInfo(localizations),
            
            const SizedBox(height: 20),
            
            // 团队信息
            _buildTeamInfo(localizations),
            
            const SizedBox(height: 20),
            
            // 联系方式
            _buildContactInfo(localizations),
            
            const SizedBox(height: 20),
            
            // 版权信息
            _buildCopyright(localizations),
            
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildAppHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 应用图标
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(
              Icons.chat,
              size: 50,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          
          // 应用名称
          const Text(
            'ChatApp',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          
          // 版本号
          const Text(
            'v1.0.0',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppInfo(AppLocalizations localizations) {
    return _buildSection(
      title: '应用简介',
      children: [
        _buildInfoTile(
          icon: Icons.description,
          title: '产品简介',
          content: '这是一个现代化即时通讯应用，'
              '支持文字、语音、图片、视频等多种消息类型，'
              '提供流畅的聊天体验。',
        ),
        const Divider(height: 1),
        _buildInfoTile(
          icon: Icons.star,
          title: '核心特性',
          content: '• 实时消息同步\n'
              '• 多媒体消息支持\n'
              '• 群聊和私聊\n'
              '• 消息推送通知\n'
              '• 跨平台支持',
        ),
        const Divider(height: 1),
        _buildInfoTile(
          icon: Icons.security,
          title: '安全保障',
          content: '采用端到端加密技术，保护用户隐私和数据安全。'
              '所有消息传输都经过严格的安全验证。',
        ),
      ],
    );
  }

  Widget _buildTeamInfo(AppLocalizations localizations) {
    return _buildSection(
      title: '开发团队',
      children: [
        _buildInfoTile(
          icon: Icons.group,
          title: '团队介绍',
          content: '由一群热爱技术的开发者组成，致力于打造优秀的移动应用产品。',
        ),
        const Divider(height: 1),
        _buildInfoTile(
          icon: Icons.code,
          title: '技术理念',
          content: '追求代码质量，注重用户体验，持续创新和优化。',
        ),
        const Divider(height: 1),
        _buildInfoTile(
          icon: Icons.favorite,
          title: '开源精神',
          content: '积极参与开源社区，分享技术经验，回馈开发者生态。',
        ),
      ],
    );
  }

  Widget _buildContactInfo(AppLocalizations localizations) {
    return _buildSection(
      title: '联系我们',
      children: [
        _buildContactTile(
          icon: Icons.email,
          title: '客服邮箱',
          subtitle: 'support@chatapp.com',
          onTap: () => _copyToClipboard('support@chatapp.com'),
        ),
        const Divider(height: 1),
        _buildContactTile(
          icon: Icons.web,
          title: '官方网站',
          subtitle: 'www.chatapp.com',
          onTap: () => _copyToClipboard('https://www.chatapp.com'),
        ),
        const Divider(height: 1),
        _buildContactTile(
          icon: Icons.bug_report,
          title: '问题反馈',
          subtitle: '点击反馈使用问题',
          onTap: () => _showFeedbackDialog(),
        ),
      ],
    );
  }

  Widget _buildCopyright(AppLocalizations localizations) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: const Column(
        children: [
          Text(
            '版权信息',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: 12),
          Text(
            '© 2024 ChatApp Team',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '保留所有权利',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 16),
          Text(
            '感谢您的使用和支持 ❤️',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(13),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.green),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          content,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            height: 1.4,
          ),
        ),
      ),
      isThreeLine: true,
    );
  }

  Widget _buildContactTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.green),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.blue,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  // 复制到剪贴板
  Future<void> _copyToClipboard(String text) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('已复制到剪贴板: $text'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _logger.e('复制到剪贴板失败', error: e);
      _showErrorDialog('复制失败');
    }
  }

  // 显示反馈对话框
  void _showFeedbackDialog() {
    final TextEditingController feedbackController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('问题反馈'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('请描述您遇到的问题或建议：'),
            const SizedBox(height: 16),
            TextField(
              controller: feedbackController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: '请详细描述问题...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _submitFeedback(feedbackController.text);
            },
            child: const Text('提交'),
          ),
        ],
      ),
    );
  }

  // 提交反馈
  void _submitFeedback(String feedback) {
    if (feedback.trim().isEmpty) {
      _showErrorDialog('请输入反馈内容');
      return;
    }
    
    // 这里可以实现真实的反馈提交逻辑
    _logger.i('用户反馈: $feedback');
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('感谢您的反馈，我们会认真处理！'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // 显示错误对话框
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('提示'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}