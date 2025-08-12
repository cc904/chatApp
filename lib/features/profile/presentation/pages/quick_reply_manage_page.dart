// ignore_for_file: unused_import
import 'dart:io';
import 'package:fixnum/fixnum.dart' as fixnum;

import 'package:cc/core/proto/generated/quick_reply.pb.dart' as qrpb;
import 'package:cc/core/database/drift_database.dart' show AppDatabase;
import 'package:cc/core/services/file_upload_service.dart';
import 'package:cc/core/services/log_service.dart';
import 'package:cc/core/database/drift_database.dart';
import 'package:cc/features/chat/data/repositories/quick_reply_repository.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:cc/core/constants/app_config.dart';

class QuickReplyManagePage extends StatefulWidget {
  const QuickReplyManagePage({super.key});

  @override
  State<QuickReplyManagePage> createState() => _QuickReplyManagePageState();
}

class _QuickReplyManagePageState extends State<QuickReplyManagePage> {
  final _repo = QuickReplyRepository();
  final _logger = LogService.instance;

  bool _loading = false;
  List<QuickReply> _items = [];
  static const List<String> _types = ['text', 'image', 'video', 'voice', 'file'];

  Future<void> _editItem(QuickReply it) async {
    // 点击编辑日志（DB行）
    _logger.d('Manage QuickReply edit clicked (DB)', extra: {
      'id': it.id,
      'userId': it.userId,
      'name': it.name,
      'content': it.content,
      'category': it.category,
      'mediaType': it.mediaType,
      'mediaUrl': it.mediaUrl,
      'thumbUrl': it.thumbUrl,
      'caption': it.caption,
      'width': it.width,
      'height': it.height,
      'duration': null,
      'fileSizeKb': it.fileSizeKb,
      'fileName': it.fileName,
      'mimeType': it.mimeType,
      'fsId': it.fsId,
    });
    // 使用 PB 详情补齐，修复“分类等信息没有正确加载”
    final pb = _repo.getPbById(it.id);
    if (pb != null) {
      _logger.d('Manage QuickReply edit PB cache', extra: {
        'id': pb.id.toInt(),
        'name': pb.hasName() ? pb.name : null,
        'content': pb.hasContent() ? pb.content : null,
        'category': pb.hasCategory() ? pb.category : null,
        'mediaType': pb.hasMediaType() ? pb.mediaType : null,
        'mediaUrl': pb.hasMediaUrl() ? pb.mediaUrl : null,
        'thumbUrl': pb.hasThumbUrl() ? pb.thumbUrl : null,
        'caption': pb.hasCaption() ? pb.caption : null,
        'width': pb.hasWidth() ? pb.width : null,
        'height': pb.hasHeight() ? pb.height : null,
        'duration': pb.hasDuration() ? pb.duration : null,
        'fileSizeKb': pb.hasFileSizeKb() ? pb.fileSizeKb : null,
        'fileName': pb.hasFileName() ? pb.fileName : null,
        'mimeType': pb.hasMimeType() ? pb.mimeType : null,
        'fsId': pb.hasFsId() ? pb.fsId : null,
      });
    }
    final effectiveType = (pb != null && pb.hasMediaType() && pb.mediaType.isNotEmpty)
        ? pb.mediaType
        : (it.mediaType ?? 'text');
    final normalizedType = effectiveType.toLowerCase().trim();
    final isText = (normalizedType == 'text');
    final nameController = TextEditingController(
        text: (pb != null && pb.hasName() && pb.name.isNotEmpty) ? pb.name : (it.name ?? ''));
    final categoryController = TextEditingController(
        text: (pb != null && pb.hasCategory() && pb.category.isNotEmpty) ? pb.category : (it.category ?? ''));
    final contentController = TextEditingController(
        text: isText
            ? ((pb != null && pb.hasContent() && pb.content.isNotEmpty) ? pb.content : it.content)
            : '');
    final captionController = TextEditingController(
        text: isText
            ? ''
            : ((pb != null && pb.hasCaption() && pb.caption.isNotEmpty) ? pb.caption : (it.caption ?? '')));

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('编辑快捷回复(私有)'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.grey.shade100,
                    child: Icon(_typeIcon(normalizedType), size: 16, color: Colors.grey.shade700),
                  ),
                  const SizedBox(width: 8),
                  Text(_typeZh(normalizedType), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                ],
              ),
              const SizedBox(height: 8),
              if (!isText && normalizedType == 'image') ...[
                Builder(builder: (context) {
                  final rawMediaUrl = (pb != null && pb.hasMediaUrl() && pb.mediaUrl.isNotEmpty)
                      ? pb.mediaUrl
                      : (it.mediaUrl ?? '');
                  final rawThumbUrl = (pb != null && pb.hasThumbUrl() && pb.thumbUrl.isNotEmpty)
                      ? pb.thumbUrl
                      : (it.thumbUrl ?? '');
                  final previewUrl = _ensureAbsoluteUrl(rawThumbUrl.isNotEmpty ? rawThumbUrl : rawMediaUrl);
                  if (previewUrl.isEmpty) return const SizedBox.shrink();
                  return Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          previewUrl,
                          height: 160,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(
                            height: 160,
                            color: Colors.grey.shade200,
                            alignment: Alignment.center,
                            child: const Icon(Icons.broken_image, size: 32, color: Colors.grey),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  );
                }),
              ],
              TextField(controller: nameController, decoration: const InputDecoration(labelText: '名称')), 
              TextField(controller: categoryController, decoration: const InputDecoration(labelText: '分类')), 
              if (isText)
                TextField(controller: contentController, decoration: const InputDecoration(labelText: '内容'))
              else
                TextField(controller: captionController, decoration: const InputDecoration(labelText: '消息')), 
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('保存')),
        ],
      ),
    );
    if (ok != true) return;

    try {
      final req = qrpb.UpdateQuickReplyRequest()
        ..id = fixnum.Int64(it.id)
        ..category = categoryController.text.trim()
        ..name = nameController.text.trim();
      if (isText) {
        req
          ..mediaType = 'text'
          ..content = contentController.text.trim();
      } else {
        // 媒体类默认不改 mediaUrl，仅允许改说明
        req
          ..mediaType = effectiveType
          ..caption = captionController.text.trim();
      }
      await _repo.updateQuickReply(req);
      await _refresh();
    } catch (e) {
      _logger.e('更新失败', error: e);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('更新失败: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    try {
      final items = await _repo.forceRefresh();
      final currentUserId = AppDatabase.instance.currentUserId;
      final ownPrivate = items
          .where((e) => (e.userId != null && e.userId == currentUserId))
          .toList();
      setState(() => _items = ownPrivate);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  IconData _typeIcon(String? t) {
    switch ((t ?? 'text').toLowerCase()) {
      case 'image':
        return Icons.image_outlined;
      case 'video':
        return Icons.videocam_outlined;
      case 'voice':
        return Icons.mic_none;
      case 'file':
        return Icons.insert_drive_file_outlined;
      default:
        return Icons.text_snippet_outlined;
    }
  }

  String _typeZh(String? t) {
    switch ((t ?? 'text').toLowerCase()) {
      case 'image':
        return '图片';
      case 'video':
        return '视频';
      case 'voice':
        return '语音';
      case 'file':
        return '文件';
      default:
        return '文本';
    }
  }

  String _ensureAbsoluteUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    final base = AppConfig().fileServerUrl;
    if (base.isEmpty) return url;
    return Uri.parse(base).resolve(url).toString();
  }

  Future<void> _openCreateDialog() async {
    String selectedType = 'text';
    final nameController = TextEditingController();
    final categoryController = TextEditingController(text: '默认');
    final contentController = TextEditingController();
    final captionController = TextEditingController();
    Map<String, dynamic>? uploaded; // from FileUploadService
    bool uploading = false;

    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Row(
            children: [
              const Text('新建快捷回复'),
              const Spacer(),
              DropdownButton<String>(
                value: selectedType,
                underline: const SizedBox.shrink(),
                items: _types
                    .map((t) => DropdownMenuItem(
                          value: t,
                          child: Row(
                            children: [Icon(_typeIcon(t), size: 18), const SizedBox(width: 6), Text(_typeZh(t))],
                          ),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => selectedType = v ?? 'text'),
              ),
            ],
          ),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameController, decoration: const InputDecoration(labelText: '名称(必填)')),
                  const SizedBox(height: 8),
                  TextField(controller: categoryController, decoration: const InputDecoration(labelText: '分类(可选)')),
                  const SizedBox(height: 12),
                  if (selectedType == 'text') ...[
                    TextField(controller: contentController, maxLines: 4, decoration: const InputDecoration(labelText: '内容(必填)')),
                  ] else ...[
                  TextField(controller: captionController, maxLines: 3, decoration: const InputDecoration(labelText: '消息(可选)')),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: uploading
                              ? null
                              : () async {
                                  final result = await FilePicker.platform.pickFiles(type: FileType.any);
                                  if (result == null || result.files.isEmpty) return;
                                  final filePath = result.files.single.path;
                                  if (filePath == null) return;
                                  setState(() => uploading = true);
                                  try {
                                    final meta = await FileUploadService.instance
                                        .uploadForQuickReply(filePath: filePath, type: selectedType);
                                    uploaded = {
                                      'mediaUrl': _ensureAbsoluteUrl(meta.mediaUrl),
                                      'mimeType': meta.mimeType,
                                      'fileName': meta.fileName,
                                      'fileSizeKb': meta.fileSizeKb,
                                      'fsId': meta.fsId,
                                      'thumbUrl': _ensureAbsoluteUrl(meta.thumbUrl),
                                      'width': meta.width,
                                      'height': meta.height,
                                      'duration': meta.duration,
                                    };
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('上传失败: $e')));
                                  } finally {
                                    setState(() => uploading = false);
                                  }
                                },
                          icon: uploading
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.upload_outlined),
                          label: Text(uploading ? '上传中...' : '选择并上传'),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            (uploaded != null)
                                ? ((uploaded!['fileName'] as String?) ?? (uploaded!['mediaUrl'] as String? ?? '已上传'))
                                : '未选择文件',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (selectedType == 'image' && uploaded != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          _ensureAbsoluteUrl((uploaded!['thumbUrl'] as String?) ?? (uploaded!['mediaUrl'] as String?)),
                          height: 160,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(
                            height: 160,
                            color: Colors.grey.shade200,
                            alignment: Alignment.center,
                            child: const Icon(Icons.broken_image, size: 32, color: Colors.grey),
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final category = categoryController.text.trim();
                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('名称不能为空')));
                  return;
                }
                if (selectedType == 'text') {
                  final content = contentController.text.trim();
                  if (content.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('内容不能为空')));
                    return;
                  }
                  final req = qrpb.CreateQuickReplyRequest()
                    ..mediaType = 'text'
                    ..content = content
                    ..category = category
                    ..name = name
                    ..orderIndex = _items.length
                    ..isEnabled = true;
                  final ok = await _repo.createQuickReply(req);
                  if (!ok) return;
                } else {
                  if (uploaded == null || (uploaded!['mediaUrl'] as String?)?.isNotEmpty != true) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请先选择并上传文件')));
                    return;
                  }
                  final req = qrpb.CreateQuickReplyRequest()
                    ..mediaType = selectedType
                    ..mediaUrl = _ensureAbsoluteUrl(uploaded!['mediaUrl'] as String)
                    ..mimeType = (uploaded!['mimeType'] as String?) ?? ''
                    ..fileName = (uploaded!['fileName'] as String?) ?? ''
                    ..fileSizeKb = (uploaded!['fileSizeKb'] as double?) ?? 0
                    ..fsId = (uploaded!['fsId'] as String?) ?? ''
                    ..thumbUrl = _ensureAbsoluteUrl((uploaded!['thumbUrl'] as String?) ?? '')
                    ..width = (uploaded!['width'] as int?) ?? 0
                    ..height = (uploaded!['height'] as int?) ?? 0
                    ..duration = (uploaded!['duration'] as int?) ?? 0
                    ..name = name
                    ..caption = captionController.text.trim()
                    ..category = category
                    ..isEnabled = true
                    ..orderIndex = _items.length;
                  final ok = await _repo.createQuickReply(req);
                  if (!ok) return;
                }
                if (mounted) Navigator.pop(ctx, true);
              },
              child: const Text('确定'),
            )
          ],
        ),
      ),
    );
    if (ok == true) {
      // 仅保留一次延迟刷新，避免立即刷新导致的闪烁
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _refresh();
      });
    }
  }

  Future<void> _deleteItem(QuickReply item) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('将删除: ${item.content}'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('删除')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _repo.deleteQuickReply(qrpb.DeleteQuickReplyRequest()..id = fixnum.Int64(item.id));
      // 仅做一次延迟刷新，避免立即刷新导致闪烁/数据未落库
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _refresh();
      });
    } catch (e) {
      _logger.e('删除快捷回复失败', error: e);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('删除失败: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('快捷回复管理'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refresh),
          const SizedBox(width: 4),
          ElevatedButton.icon(
            onPressed: _openCreateDialog,
            icon: const Icon(Icons.add),
            label: const Text('新建'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              itemCount: _items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              padding: const EdgeInsets.all(12),
              itemBuilder: (context, index) {
                final it = _items[index];
                final currentUserId = AppDatabase.instance.currentUserId;
                final isOwnPrivate = (it.userId != null && it.userId == currentUserId);
                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.grey.shade100,
                          child: Icon(_typeIcon(it.mediaType), size: 18, color: Colors.grey.shade700),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                it.name ?? it.content,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(it.category ?? '默认', style: TextStyle(fontSize: 12, color: Colors.blue.shade700)),
                                  ),
                                  const SizedBox(width: 8),
                                  Text('${_typeZh(it.mediaType)} • #${it.id}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (isOwnPrivate) ...[
                          IconButton(
                            tooltip: '编辑',
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () {
                              _logger.d('Manage QuickReply edit button pressed', extra: {
                                'id': it.id,
                                'mediaType': it.mediaType,
                                'name': it.name,
                                'category': it.category,
                              });
                              _editItem(it);
                            },
                          ),
                          IconButton(
                            tooltip: '删除',
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _deleteItem(it),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}


