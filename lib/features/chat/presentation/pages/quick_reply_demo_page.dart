import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/quick_reply_panel.dart';
import '../cubit/quick_reply_cubit.dart';
import '../../data/repositories/quick_reply_repository.dart';

/// 快捷回复功能演示页面
class QuickReplyDemoPage extends StatefulWidget {
  const QuickReplyDemoPage({super.key});

  @override
  State<QuickReplyDemoPage> createState() => _QuickReplyDemoPageState();
}

class _QuickReplyDemoPageState extends State<QuickReplyDemoPage> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _showQuickReplyPanel = false;
  final List<String> _messages = [];

  @override
  void initState() {
    super.initState();
    // 从服务器同步快捷回复数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuickReplyCubit>().initializeQuickReplies();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _messages.add('客服: $text');
        _textController.clear();
        _showQuickReplyPanel = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => QuickReplyCubit(QuickReplyRepository()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('快捷回复功能演示'),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
        ),
        body: Column(
          children: [
            // 消息列表
            Expanded(
              child: Container(
                color: Colors.grey.shade50,
                child: _messages.isEmpty
                    ? const Center(
                        child: Text(
                          '点击快捷回复按钮试试客服回复功能',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Text(
                              _messages[index],
                              style: const TextStyle(fontSize: 16),
                            ),
                          );
                        },
                      ),
              ),
            ),
            // 输入区域
            Column(
              children: [
                // 快捷回复面板
                QuickReplyPanel(
                  isVisible: _showQuickReplyPanel,
                  onQuickReply: (content) {
                    // 填入输入框，不自动发送
                    _textController.text = content;
                    setState(() {
                      _showQuickReplyPanel = false;
                    });
                    // 获取焦点，用户可以编辑后手动发送
                    _focusNode.requestFocus();
                    _textController.selection = TextSelection.fromPosition(
                      TextPosition(offset: _textController.text.length),
                    );
                  },
                ),
                // 输入栏
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: SafeArea(
                    child: Row(
                      children: [
                        // 文本输入框
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: TextField(
                              controller: _textController,
                              focusNode: _focusNode,
                              maxLines: 3,
                              minLines: 1,
                              decoration: const InputDecoration(
                                hintText: '输入消息...',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              ),
                              onTap: () {
                                setState(() {
                                  _showQuickReplyPanel = false;
                                });
                              },
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 8),
                        
                        // 快捷回复按钮
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _showQuickReplyPanel = !_showQuickReplyPanel;
                              if (_showQuickReplyPanel) {
                                _focusNode.unfocus();
                              }
                            });
                          },
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: _showQuickReplyPanel 
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Icon(
                              Icons.flash_on,
                              color: _showQuickReplyPanel 
                                  ? Colors.white 
                                  : Colors.grey.shade600,
                              size: 20,
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 8),
                        
                        // 发送按钮
                        GestureDetector(
                          onTap: _sendMessage,
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Icon(
                              Icons.send,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

