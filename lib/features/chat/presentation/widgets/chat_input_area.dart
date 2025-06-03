import 'package:flutter/material.dart';

/// 聊天输入区域组件
class ChatInputArea extends StatefulWidget {
  final TextEditingController messageController;
  final FocusNode focusNode;
  final VoidCallback onSendMessage;
  final VoidCallback? onAttachFile;
  final bool isEnabled;

  const ChatInputArea({
    super.key,
    required this.messageController,
    required this.focusNode,
    required this.onSendMessage,
    this.onAttachFile,
    this.isEnabled = true,
  });

  @override
  State<ChatInputArea> createState() => _ChatInputAreaState();
}

class _ChatInputAreaState extends State<ChatInputArea> {
  bool _isMultiline = false;

  @override
  void initState() {
    super.initState();
    widget.messageController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.messageController.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final text = widget.messageController.text;
    final hasNewLine = text.contains('\n');

    if (hasNewLine != _isMultiline) {
      setState(() {
        _isMultiline = hasNewLine;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // 附件按钮
            _buildAttachButton(),

            const SizedBox(width: 4.0),

            // 输入框
            Expanded(child: _buildInputField()),

            const SizedBox(width: 4.0),

            // 发送按钮
            _buildSendButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachButton() {
    return Container(
      margin: const EdgeInsets.only(bottom: 4.0),
      child: IconButton(
        icon: const Icon(Icons.attach_file),
        color: widget.isEnabled ? Colors.grey.shade600 : Colors.grey.shade400,
        onPressed: widget.isEnabled ? widget.onAttachFile : null,
        tooltip: '附件',
      ),
    );
  }

  Widget _buildInputField() {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 40.0,
        maxHeight: 120.0,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: widget.isEnabled ? Colors.grey.shade100 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: TextField(
        controller: widget.messageController,
        focusNode: widget.focusNode,
        enabled: widget.isEnabled,
        maxLines: null,
        minLines: 1,
        keyboardType: TextInputType.multiline,
        textInputAction: TextInputAction.newline,
        decoration: InputDecoration(
          hintText: widget.isEnabled ? 'Message' : '连接中...',
          hintStyle: TextStyle(
            color:
                widget.isEnabled ? Colors.grey.shade600 : Colors.grey.shade400,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          isDense: true,
        ),
        style: TextStyle(
          fontSize: 16.0,
          color: widget.isEnabled ? Colors.black87 : Colors.grey.shade500,
        ),
        onSubmitted: widget.isEnabled ? (_) => _handleSend() : null,
      ),
    );
  }

  Widget _buildSendButton() {
    final hasText = widget.messageController.text.trim().isNotEmpty;
    final canSend = widget.isEnabled && hasText;

    return Container(
      margin: const EdgeInsets.only(bottom: 4.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 40.0,
        height: 40.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: canSend ? Colors.green : Colors.grey.shade300,
        ),
        child: IconButton(
          icon: Icon(
            Icons.send,
            size: 20.0,
            color: canSend ? Colors.white : Colors.grey.shade500,
          ),
          onPressed: canSend ? _handleSend : null,
          tooltip: '发送',
        ),
      ),
    );
  }

  void _handleSend() {
    if (widget.messageController.text.trim().isNotEmpty && widget.isEnabled) {
      widget.onSendMessage();
    }
  }
}

/// 附件选择底部弹出组件
class ChatAttachmentOptions extends StatelessWidget {
  final VoidCallback? onSelectImage;
  final VoidCallback? onSelectVideo;
  final VoidCallback? onSelectFile;
  final VoidCallback? onSelectVoice;

  const ChatAttachmentOptions({
    super.key,
    this.onSelectImage,
    this.onSelectVideo,
    this.onSelectFile,
    this.onSelectVoice,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 拖拽指示器
            Container(
              width: 40.0,
              height: 4.0,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.0),
              ),
            ),

            const SizedBox(height: 16.0),

            // 标题
            const Text(
              '选择附件类型',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 20.0),

            // 选项网格
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 4,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              children: [
                _buildOptionItem(
                  icon: Icons.photo,
                  label: '图片',
                  color: Colors.blue,
                  onTap: onSelectImage,
                ),
                _buildOptionItem(
                  icon: Icons.videocam,
                  label: '视频',
                  color: Colors.red,
                  onTap: onSelectVideo,
                ),
                _buildOptionItem(
                  icon: Icons.insert_drive_file,
                  label: '文件',
                  color: Colors.orange,
                  onTap: onSelectFile,
                ),
                _buildOptionItem(
                  icon: Icons.mic,
                  label: '语音',
                  color: Colors.green,
                  onTap: onSelectVoice,
                ),
              ],
            ),

            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56.0,
            height: 56.0,
            decoration: BoxDecoration(
              color: color.withAlpha(51),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 28.0,
              color: color,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.0,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  /// 显示附件选择弹窗
  static Future<void> show(
    BuildContext context, {
    VoidCallback? onSelectImage,
    VoidCallback? onSelectVideo,
    VoidCallback? onSelectFile,
    VoidCallback? onSelectVoice,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ChatAttachmentOptions(
        onSelectImage: onSelectImage,
        onSelectVideo: onSelectVideo,
        onSelectFile: onSelectFile,
        onSelectVoice: onSelectVoice,
      ),
    );
  }
}
