import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/database/models/quick_reply.dart';
import '../cubit/quick_reply_cubit.dart';

/// 快捷回复面板
class QuickReplyPanel extends StatelessWidget {
  final Function(String) onQuickReply;
  final bool isVisible;

  const QuickReplyPanel({
    super.key,
    required this.onQuickReply,
    required this.isVisible,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    return BlocBuilder<QuickReplyCubit, QuickReplyState>(
      builder: (context, state) {
        if (state.quickReplies.isEmpty) {
          return _buildEmptyState(context);
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(context),
              _buildQuickReplyList(context, state.quickReplies),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.flash_on,
            size: 18,
            color: Colors.blue.shade700,
          ),
          const SizedBox(width: 6),
          Text(
            '快捷回复',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.blue.shade700,
            ),
          ),
          const SizedBox(width: 8),
          // 显示同步状态
          BlocBuilder<QuickReplyCubit, QuickReplyState>(
            builder: (context, state) {
              if (state.isLoading) {
                return SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade700),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          const Spacer(),
          // 刷新按钮
          GestureDetector(
            onTap: () {
              context.read<QuickReplyCubit>().refreshFromServer();
            },
            child: Icon(
              Icons.refresh,
              size: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(width: 8),
          // 设置按钮
          GestureDetector(
            onTap: () {
              // TODO: 打开快捷回复管理页面
            },
            child: Icon(
              Icons.settings,
              size: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickReplyList(BuildContext context, List<QuickReply> replies) {
    // 按分类分组
    final groupedReplies = <String, List<QuickReply>>{};
    for (final reply in replies) {
      groupedReplies.putIfAbsent(reply.category, () => []).add(reply);
    }

    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: groupedReplies.entries.map((entry) {
          return _buildCategorySection(context, entry.key, entry.value);
        }).toList(),
      ),
    );
  }

  Widget _buildCategorySection(BuildContext context, String category, List<QuickReply> replies) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (category.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              category,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: replies.map((reply) {
            return _buildQuickReplyChip(context, reply);
          }).toList(),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildQuickReplyChip(BuildContext context, QuickReply reply) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _handleQuickReply(context, reply),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getCategoryColor(reply.category).withAlpha(40),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _getCategoryColor(reply.category).withAlpha(100),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  reply.content,
                  style: TextStyle(
                    fontSize: 14,
                    color: _getCategoryColor(reply.category),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.flash_off,
              size: 32,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 8),
            Text(
              '暂无快捷回复',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () {
                // TODO: 打开快捷回复管理页面
              },
              child: Text(
                '点击设置常用回复',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue.shade600,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleQuickReply(BuildContext context, QuickReply reply) {
    // 记录使用次数
    context.read<QuickReplyCubit>().markReplyAsUsed(reply.id);
    
    // 回调填入文本到输入框（不直接发送）
    onQuickReply(reply.content);
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case '问候':
        return Colors.green;
      case '道歉':
        return Colors.orange;
      case '解决方案':
        return Colors.blue;
      case '信息提供':
        return Colors.purple;
      case '结束语':
        return Colors.grey;
      default:
        return Colors.indigo;
    }
  }
}