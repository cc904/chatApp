import 'package:flutter/material.dart';
import 'package:cc/core/services/avatar_cache_service.dart';
import 'dart:io';

/// 通用用户头像组件
///
/// 支持网络图片和本地图片，包含错误处理和加载状态
/// 当图片加载失败或不存在时，显示用户名首字母
///
/// 实现"先保存到本地再使用"的设计原则：
/// - 网络头像会自动下载并缓存到本地
/// - 优先使用本地缓存文件
/// - 支持离线显示已缓存的头像
class UserAvatar extends StatefulWidget {
  /// 头像URL，可以是网络URL或本地文件路径
  final String? avatarUrl;

  /// 用户名，用于生成首字母头像
  final String name;

  /// 头像半径
  final double radius;

  /// 背景颜色，用于首字母头像
  final Color? backgroundColor;

  /// 是否显示边框
  final bool showBorder;

  /// 边框颜色
  final Color borderColor;

  /// 边框宽度
  final double borderWidth;

  const UserAvatar({
    super.key,
    this.avatarUrl,
    required this.name,
    this.radius = 20,
    this.backgroundColor,
    this.showBorder = false,
    this.borderColor = Colors.white,
    this.borderWidth = 2,
  });

  @override
  State<UserAvatar> createState() => _UserAvatarState();
}

class _UserAvatarState extends State<UserAvatar> {
  final AvatarCacheService _avatarCache = AvatarCacheService();

  // 头像加载状态
  bool _isLoading = false;
  bool _hasError = false;
  String? _localAvatarPath;

  @override
  void initState() {
    super.initState();
    _loadAvatar();
  }

  @override
  void didUpdateWidget(UserAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 如果头像URL发生变化，重新加载
    if (oldWidget.avatarUrl != widget.avatarUrl) {
      _loadAvatar();
    }
  }

  /// 加载头像
  void _loadAvatar() async {
    if (widget.avatarUrl == null || widget.avatarUrl!.isEmpty) {
      // 没有头像URL，直接显示首字母头像
      setState(() {
        _isLoading = false;
        _hasError = false;
        _localAvatarPath = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _hasError = false;
      _localAvatarPath = null;
    });

    try {
      String? localPath;

      // 判断是否为网络URL
      if (widget.avatarUrl!.startsWith('http://') ||
          widget.avatarUrl!.startsWith('https://')) {
        // 网络头像 - 使用缓存服务下载到本地
        localPath = await _avatarCache.getAvatar(widget.avatarUrl!);
      } else if (widget.avatarUrl!.startsWith('file://')) {
        // file:// 协议的本地文件
        final filePath = widget.avatarUrl!.substring(7);
        final file = File(filePath);
        if (file.existsSync()) {
          localPath = filePath;
        }
      } else {
        // 直接的文件路径
        final file = File(widget.avatarUrl!);
        if (file.existsSync()) {
          localPath = widget.avatarUrl!;
        }
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = localPath == null;
          _localAvatarPath = localPath;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _localAvatarPath = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 根据名字生成随机颜色（保持一致性）
    Color getColorFromName(String name) {
      if (name.isEmpty) return Colors.blueGrey;

      // 使用名字的哈希值生成颜色，这样同一个名字总是得到相同的颜色
      final int hash = name.hashCode;

      // 预定义一组漂亮的背景颜色
      final List<Color> colors = [
        Colors.blue[400]!,
        Colors.green[400]!,
        Colors.purple[400]!,
        Colors.orange[400]!,
        Colors.teal[400]!,
        Colors.pink[400]!,
        Colors.indigo[400]!,
        Colors.cyan[400]!,
        Colors.deepOrange[400]!,
        Colors.deepPurple[400]!,
      ];

      // 使用哈希值选择颜色
      return colors[hash.abs() % colors.length];
    }

    final nameColor = widget.backgroundColor ?? getColorFromName(widget.name);
    final hasValidAvatar = _localAvatarPath != null && !_hasError;

    // 获取要显示的文本内容
    String displayText = '?';
    if (widget.name.isNotEmpty) {
      // 判断是否为中文名称(简单判断：如果不包含英文字母和数字，则视为中文)
      bool isChinese = !RegExp(r'[a-zA-Z0-9]').hasMatch(widget.name);

      if (isChinese) {
        switch (widget.name.length) {
          case 2: // 两个字的中文名，显示全名
            displayText = widget.name;
            break;
          case 3: // 三个字的中文名，显示后两个字
            displayText = widget.name.substring(1);
            break;
          default: // 其他情况，只显示第一个字
            displayText = widget.name[0];
        }
      } else {
        // 非中文名称，显示第一个字母并大写
        displayText = widget.name[0].toUpperCase();
      }
    }

    // 创建首字母/姓名文本的样式
    final textStyle = TextStyle(
      color: Colors.white,
      fontSize:
          displayText.length > 1 ? widget.radius * 0.5 : widget.radius * 0.7,
      fontWeight: FontWeight.bold,
      letterSpacing: -0.5, // 减小字母间距，使文字更紧凑
    );

    // 创建头像组件
    Widget avatar;

    if (!hasValidAvatar || _isLoading) {
      // 如果没有有效的头像或正在加载，显示首字母头像
      avatar = Container(
        width: widget.radius * 2,
        height: widget.radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              nameColor.withAlpha(255), // 完全不透明
              nameColor.withAlpha(190), // 稍微暗一些
            ],
          ),
          boxShadow: [
            // 内部高光 - 顶部边缘更亮，增加立体感
            BoxShadow(
              color: Colors.white.withAlpha(50),
              blurRadius: 5,
              spreadRadius: -2,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // 首字母文本
            Center(
              child: Text(
                displayText,
                style: textStyle,
                textAlign: TextAlign.center,
              ),
            ),
            // 加载指示器
            if (_isLoading)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withAlpha(76),
                  ),
                  child: Center(
                    child: SizedBox(
                      width: widget.radius * 0.6,
                      height: widget.radius * 0.6,
                      child: CircularProgressIndicator(
                        strokeWidth: widget.radius * 0.1,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    } else {
      // 如果有有效的本地头像文件，使用FileImage
      avatar = CircleAvatar(
        radius: widget.radius,
        backgroundColor: nameColor,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.radius),
          child: Image.file(
            File(_localAvatarPath!),
            fit: BoxFit.cover,
            width: widget.radius * 2,
            height: widget.radius * 2,
            errorBuilder: (context, error, stackTrace) {
              // 如果本地文件加载失败，回退到首字母头像
              return Container(
                width: widget.radius * 2,
                height: widget.radius * 2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      nameColor.withAlpha(255), // 完全不透明
                      nameColor.withAlpha(190), // 稍微暗一些
                    ],
                  ),
                ),
                child: Center(
                  child: Text(
                    displayText,
                    style: textStyle,
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
          ),
        ),
      );
    }

    // 如果需要显示边框，添加边框
    if (widget.showBorder) {
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: widget.borderColor,
            width: widget.borderWidth,
          ),
        ),
        child: avatar,
      );
    }

    return avatar;
  }
}
