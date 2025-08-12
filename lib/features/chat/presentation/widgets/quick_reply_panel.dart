import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cc/core/database/drift_database.dart';
import '../cubit/chat_cubit.dart';
import 'package:cc/features/profile/presentation/pages/quick_reply_manage_page.dart';
import '../cubit/chat_state.dart';
import 'package:cc/core/proto/generated/quick_reply.pb.dart' as qrpb;
import 'package:cc/core/l10n/app_localizations.dart';
import 'package:cc/core/services/log_service.dart';

/// 快捷回复面板
class QuickReplyPanel extends StatelessWidget {
  final Function(String) onQuickReply;
  final VoidCallback? onRequestClose;
  final bool isVisible;

  const QuickReplyPanel({
    super.key,
    required this.onQuickReply,
    this.onRequestClose,
    required this.isVisible,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        final quickReplies = state.quickReplies ?? [];
        if (quickReplies.isEmpty) {
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
                _buildEmptyState(context),
              ],
            ),
          );
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
              _buildQuickReplyList(context, quickReplies),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
          BlocBuilder<ChatCubit, ChatState>(
            builder: (context, state) {
              if (state.isQuickReplyLoading) {
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
          // 刷新按钮（增大点击热区与间距）
          IconButton(
            onPressed: () {
              context.read<ChatCubit>().refreshQuickReplies();
            },
            tooltip: '刷新',
            icon: Icon(
              Icons.refresh,
              color: Colors.grey.shade600,
            ),
            iconSize: 20,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            visualDensity: VisualDensity(horizontal: -2, vertical: -2),
          ),
          const SizedBox(width: 8),
          // 设置按钮（增大点击热区与间距）
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const QuickReplyManagePage()),
              );
            },
            tooltip: '设置',
            icon: Icon(
              Icons.settings,
              color: Colors.grey.shade600,
            ),
            iconSize: 20,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            visualDensity: VisualDensity(horizontal: -2, vertical: -2),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickReplyList(BuildContext context, List<QuickReply> replies) {
    // 按分类分组
    final groupedReplies = <String, List<QuickReply>>{};
    for (final reply in replies) {
      final category = reply.category ?? '默认';
      groupedReplies.putIfAbsent(category, () => []).add(reply);
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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (category.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Center(
              child: Text(
                category,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
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
    final repo = context.read<ChatCubit>().quickReplyRepository;
    final pb = repo.getPbById(reply.id);
    final localMediaType = reply.mediaType; // DB 持久化的媒体类型（v7 新增）
    final mediaType = (pb != null && pb.hasMediaType() && pb.mediaType.isNotEmpty)
        ? pb.mediaType
        : (localMediaType ?? 'text');
    final isImage = mediaType == 'image' && ((pb?.hasMediaUrl() == true) || (pb == null));
    final isPublic = (reply.userId == null || reply.userId!.isEmpty);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _handleQuickReply(context, reply),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isPublic
                ? Colors.orange.withAlpha(36) // 公有项背景色更醒目
                : _getCategoryColor(reply.category ?? '默认').withAlpha(40),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isPublic
                  ? Colors.orange.withAlpha(150)
                  : _getCategoryColor(reply.category ?? '默认').withAlpha(100),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  // 优先显示本地缓存的名称，其次PB中的名称，最后回退到content
                  (reply.name != null && reply.name!.isNotEmpty)
                      ? reply.name!
                      : ((pb?.hasName() == true && pb!.name.isNotEmpty)
                          ? pb.name
                          : reply.content),
                  style: TextStyle(
                    fontSize: 14,
                    color: isPublic
                        ? Colors.orange.shade800
                        : _getCategoryColor(reply.category ?? '默认'),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isImage) ...[
                const SizedBox(width: 6),
                Icon(
                  Icons.image_outlined,
                  size: 16,
                  color: isPublic
                      ? Colors.orange.shade700
                      : _getCategoryColor(reply.category ?? '默认'),
                ),
              ],
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
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const QuickReplyManagePage()),
                );
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

  Future<void> _handleQuickReply(BuildContext context, QuickReply reply) async {
    final chatCubit = context.read<ChatCubit>();
    final repo = chatCubit.quickReplyRepository;
    qrpb.QuickReply? pb = repo.getPbById(reply.id);

    // 记录使用次数
    chatCubit.markQuickReplyAsUsed(reply.id);

    // 打印内容（名称/文本/媒体信息）
    LogService.instance.d('QuickReply tapped', extra: {
      'id': reply.id,
      'name': (pb?.hasName() == true && pb!.name.isNotEmpty) ? pb.name : null,
      'content': reply.content,
      'category': reply.category,
      'mediaType': pb?.mediaType,
      'mediaUrl': pb?.mediaUrl,
      'caption': pb?.caption,
    });

    // 若本地未命中PB缓存，尝试强制刷新一次以获取媒体字段
    if (pb == null) {
      await chatCubit.refreshQuickReplies();
      pb = repo.getPbById(reply.id);
    }

    // 判断媒体类型：若是图片类型且有URL，则弹出带已加载图片与说明输入框的发送界面
    if (pb != null && pb.hasMediaType() && pb.mediaType == 'image' && pb.hasMediaUrl() && pb.mediaUrl.isNotEmpty) {
      // 立即关闭面板，防止底部判断被干扰
      if (onRequestClose != null) {
        onRequestClose!();
      }
      _showQuickReplyImagePreview(context, chatCubit, pb);
      return;
    }

    // 其他类型：默认回填文本
    onQuickReply(reply.content);
  }

  void _showQuickReplyImagePreview(BuildContext context, ChatCubit chatCubit, qrpb.QuickReply pb) {
    final localizations = AppLocalizations.of(context);
    final String initialCaption = (pb.hasCaption() && pb.caption.trim().isNotEmpty)
        ? pb.caption
        : ((pb.hasContent() && pb.content.trim().isNotEmpty) ? pb.content : '');
    final TextEditingController captionController = TextEditingController(text: initialCaption);

    showDialog(
      context: context,
      builder: (ctx) {
        const double dialogRadius = 12.0;
        int? naturalWidth;
        int? naturalHeight;
        bool addedListener = false;

        return StatefulBuilder(builder: (ctx, setState) {
          // 解析图片原始尺寸，用于发送时写入width/height，避免消息显示二次布局抖动
          if (!addedListener && pb.hasMediaUrl() && pb.mediaUrl.isNotEmpty) {
            addedListener = true;
            final provider = NetworkImage(pb.mediaUrl);
            final stream = provider.resolve(ImageConfiguration.empty);
            ImageStreamListener? listener;
            listener = ImageStreamListener((ImageInfo info, bool sync) {
              naturalWidth = info.image.width;
              naturalHeight = info.image.height;
              // 一次即可，无需反复setState；若需要可解注释
              // setState(() {});
              stream.removeListener(listener!);
            }, onError: (error, stack) {
              try {
                stream.removeListener(listener!);
              } catch (_) {}
            });
            stream.addListener(listener);
          }

          return Dialog(
            insetPadding: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(dialogRadius),
            ),
            child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.8,
              maxWidth: MediaQuery.of(ctx).size.width * 0.9,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 图片预览（对齐图片消息样式：上圆角、下直角，按元数据宽高比显示）
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final double aspectRatio = (pb.hasWidth() && pb.hasHeight() && pb.height > 0)
                            ? (pb.width / pb.height)
                            : 4 / 3;
                        final double maxW = constraints.maxWidth;
                        final double maxH = constraints.maxHeight;
                        final double minW = maxW.clamp(120.0, double.infinity);
                        final double minH = (minW / aspectRatio).clamp(80.0, maxH);
                        return ConstrainedBox(
                          constraints: BoxConstraints(minWidth: minW, minHeight: minH),
                          child: AspectRatio(
                            aspectRatio: aspectRatio,
                            child: ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(dialogRadius),
                                topRight: Radius.circular(dialogRadius),
                                bottomLeft: Radius.circular(0.0),
                                bottomRight: Radius.circular(0.0),
                              ),
                              child: Image.network(
                                pb.mediaUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[200],
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.broken_image, size: 48, color: Colors.grey),
                                          const SizedBox(height: 8),
                                          Text(localizations.imageLoadFailed, style: const TextStyle(color: Colors.grey)),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // 说明输入（贴近消息 caption 区块的感觉）
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: captionController,
                    decoration: InputDecoration(
                      hintText: localizations.addImageCaption,
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    minLines: 1,
                    maxLines: 6,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    maxLength: 200,
                  ),
                ),

                // 操作按钮（底部，仅保留取消/发送按钮）
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: Text(localizations.cancel),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            Navigator.of(ctx).pop();
                            await chatCubit.sendImageFromUrl(
                              mediaUrl: pb.mediaUrl,
                              fileName: pb.fileName,
                              width: pb.hasWidth()
                                  ? pb.width
                                  : ((naturalWidth ?? 0) > 0 ? naturalWidth : null),
                              height: pb.hasHeight()
                                  ? pb.height
                                  : ((naturalHeight ?? 0) > 0 ? naturalHeight : null),
                              fileSize: pb.hasFileSizeKb() ? (pb.fileSizeKb * 1024) : null,
                              mimeType: pb.mimeType,
                              caption: captionController.text.trim().isEmpty ? null : captionController.text.trim(),
                              thumbUrl: pb.thumbUrl,
                              fsId: pb.fsId,
                            );
                          },
                          child: Text(localizations.send),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
        });
      },
    );
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