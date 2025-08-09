import 'package:flutter/material.dart';
import 'package:cc/core/services/avatar_cache_service.dart';
import 'package:cc/core/utils/user_display_utils.dart';
import 'package:cc/core/enums/vip_level.dart';
import 'package:cc/core/widgets/vip_badge.dart';
import 'dart:io';
import 'package:cc/core/services/file_server_config_service.dart';
import 'package:cc/core/services/avatar_url_builder.dart';
import 'package:cc/core/services/log_service.dart';

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

  /// 当 avatarUrl 为 nanoId 时需要提供 userId 以构建完整URL
  final String? userId;

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

  /// 用户角色ID，用于显示VIP标志
  final int? roleId;

  /// VIP标志类型
  final VipBadgeType vipBadgeType;

  /// 是否显示VIP标志
  final bool showVipBadge;

  /// VIP标志位置
  final VipBadgePosition vipBadgePosition;

  /// 是否优先使用缩略图（当 avatarUrl 为 nanoId 时生效）
  final bool useThumbnail;

  const UserAvatar({
    super.key,
    this.avatarUrl,
    this.userId,
    required this.name,
    this.radius = 20,
    this.backgroundColor,
    this.showBorder = false,
    this.borderColor = Colors.white,
    this.borderWidth = 2,
    this.roleId,
    this.vipBadgeType = VipBadgeType.crown,
    this.showVipBadge = true,
    this.vipBadgePosition = VipBadgePosition.topRight,
    this.useThumbnail = true,
  });

  @override
  State<UserAvatar> createState() => _UserAvatarState();
}

class _UserAvatarState extends State<UserAvatar> {
  final AvatarCacheService _avatarCache = AvatarCacheService();
  final LogService _logger = LogService.instance;

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
    if (oldWidget.avatarUrl != widget.avatarUrl ||
        oldWidget.userId != widget.userId ||
        oldWidget.useThumbnail != widget.useThumbnail) {
      _logger.i('🌀 UserAvatar 参数变更，准备重新加载', extra: {
        'name': widget.name,
        'avatarUrl_old': oldWidget.avatarUrl,
        'avatarUrl_new': widget.avatarUrl,
        'userId_old': oldWidget.userId,
        'userId_new': widget.userId,
        'useThumbnail_old': oldWidget.useThumbnail,
        'useThumbnail_new': widget.useThumbnail,
      });
      _loadAvatar();
    }
  }

  /// 加载头像
  void _loadAvatar() async {
    _logger.i('🎯 UserAvatar 开始加载', extra: {
      'name': widget.name,
      'avatarUrl': widget.avatarUrl,
      'userId': widget.userId,
      'useThumbnail': widget.useThumbnail,
    });
    if (widget.avatarUrl == null || widget.avatarUrl!.isEmpty) {
      // 没有头像URL，直接显示首字母头像
      _logger.w('⚠️ avatarUrl 为空，使用首字母头像', extra: {
        'name': widget.name,
      });
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

      String? resolvedUrl = widget.avatarUrl;

      // 如果不是http(s)且不是本地文件协议，视为nanoId，且提供了userId时组装URL
      final isHttp = widget.avatarUrl!.startsWith('http://') || widget.avatarUrl!.startsWith('https://');
      final isFileProtocol = widget.avatarUrl!.startsWith('file://');
      _logger.d('🔎 URL 类型检测', extra: {
        'isHttp': isHttp,
        'isFileProtocol': isFileProtocol,
      });

      if (!isHttp && !isFileProtocol && widget.userId != null && widget.userId!.isNotEmpty) {
        final baseUrl = await FileServerConfigService.instance.getDefaultFileServerUrl();
        _logger.d('🧩 使用 nanoId 构建头像URL', extra: {
          'baseUrl': baseUrl,
          'userId': widget.userId,
        });
        if (baseUrl != null && baseUrl.isNotEmpty) {
          final builder = AvatarUrlBuilder(baseUrl);
          resolvedUrl = widget.useThumbnail
              ? builder.thumb(widget.userId!, widget.avatarUrl!)
              : builder.original(widget.userId!, widget.avatarUrl!);
          _logger.i('✅ 构建完成 resolvedUrl', extra: {
            'resolvedUrl': resolvedUrl,
          });
        }
      } else if (!isHttp && !isFileProtocol) {
        _logger.w('⚠️ avatarUrl 为 nanoId 但缺少 userId，无法构建URL');
      }

      // 统一强制使用拼接后的URL：如果是http/https但不属于文件服务器域名，则忽略
      if (isHttp) {
        final allowedBase = await FileServerConfigService.instance.getDefaultFileServerUrl();
        final isInternal = allowedBase != null && allowedBase.isNotEmpty
            ? (widget.avatarUrl?.startsWith(allowedBase) ?? false)
            : true; // 未配置base时放过
        if (!isInternal) {
          _logger.w('⛔️ 外部原始URL被忽略，要求使用nanoId并拼接', extra: {
            'avatarUrl': widget.avatarUrl,
            'allowedBase': allowedBase,
          });
          // 若此前未能构建 resolvedUrl，则保留为空，后续走首字母
        }
      }

      // 判断是否为网络URL（仅允许文件服务器域名）
      if (resolvedUrl != null && (resolvedUrl.startsWith('http://') || resolvedUrl.startsWith('https://'))) {
        final allowedBase = await FileServerConfigService.instance.getDefaultFileServerUrl();
        final isInternal = allowedBase != null && allowedBase.isNotEmpty
            ? resolvedUrl.startsWith(allowedBase)
            : true; // 若未配置base，默认允许

        if (!isInternal) {
          _logger.w('⛔️ 外部头像URL被忽略，仅使用文件服务器拼接的URL', extra: {
            'resolvedUrl': resolvedUrl,
            'allowedBase': allowedBase,
          });
        } else {
          // 网络头像 - 使用缓存服务下载到本地
          _logger.d('⬇️ 下载网络头像并缓存', extra: {
            'resolvedUrl': resolvedUrl,
          });
          localPath = await _avatarCache.getAvatar(resolvedUrl);
          _logger.i(localPath != null ? '📦 缓存获取成功' : '❌ 缓存获取失败', extra: {
            'localPath': localPath,
          });
        }
      } else if (isFileProtocol) {
        // file:// 协议的本地文件
        final filePath = widget.avatarUrl!.substring(7);
        final file = File(filePath);
        final exists = file.existsSync();
        _logger.d('📁 file:// 本地文件检测', extra: {
          'filePath': filePath,
          'exists': exists,
        });
        if (exists) {
          localPath = filePath;
        }
      } else {
        // 直接的文件路径
        final file = File(widget.avatarUrl!);
        final exists = file.existsSync();
        _logger.d('📄 直接本地路径检测', extra: {
          'filePath': widget.avatarUrl,
          'exists': exists,
        });
        if (exists) {
          localPath = widget.avatarUrl!;
        }
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = localPath == null;
          _localAvatarPath = localPath;
        });
        _logger.i('🧪 UserAvatar 加载完成', extra: {
          'hasError': _hasError,
          'localAvatarPath': _localAvatarPath,
        });
      }
    } catch (error) {
      _logger.e('💥 UserAvatar 加载异常', error: error, stackTrace: StackTrace.current);
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
    // 使用全局统一的颜色生成方法
    final nameColor = widget.backgroundColor ?? UserDisplayUtils.generateUserColor(widget.name);
    final hasValidAvatar = _localAvatarPath != null && !_hasError;

    // 使用全局统一的首字母生成方法
    final displayText = UserDisplayUtils.getInitials(widget.name);

    // 创建首字母/姓名文本的样式
    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: displayText.length > 1 ? widget.radius * 0.5 : widget.radius * 0.7,
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
      avatar = Container(
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

    // 如果需要显示VIP标志，添加VIP标志
    if (widget.showVipBadge && widget.roleId != null) {
      final vipLevel = VipLevel.fromRoleId(widget.roleId);

      if (vipLevel.isVip || vipLevel.isGuest) {
        // 根据角色ID自动选择合适的标识类型
        VipBadgeType badgeType;
        if (vipLevel.isGuest) {
          badgeType = VipBadgeType.guest; // 游客使用游客图标
        } else if (vipLevel.isCustomerService) {
          badgeType = VipBadgeType.customerServiceHeadset; // 客服使用耳机图标
        } else {
          badgeType = VipBadgeType.crown; // VIP使用皇冠图标
        }
        return _buildAvatarWithVipBadge(avatar, vipLevel, badgeType);
      }
    }

    return avatar;
  }

  /// 构建带VIP标志的头像
  Widget _buildAvatarWithVipBadge(Widget avatar, VipLevel vipLevel, VipBadgeType badgeType) {
    final badgeSize = widget.radius * 0.6; // VIP标志大小为头像的60%
    final offset = badgeSize * 0.2; // 标志与头像边缘的距离

    return Stack(
      clipBehavior: Clip.none,
      children: [
        avatar,
        _buildPositionedVipBadge(vipLevel, badgeType, badgeSize, offset),
      ],
    );
  }

  /// 构建定位的VIP标志
  Widget _buildPositionedVipBadge(VipLevel vipLevel, VipBadgeType badgeType, double badgeSize, double offset) {
    switch (widget.vipBadgePosition) {
      case VipBadgePosition.topRight:
        return Positioned(
          top: -offset,
          right: -offset,
          child: VipBadge(
            vipLevel: vipLevel,
            badgeType: badgeType,
            size: badgeSize,
            showBackground: true,
          ),
        );
      case VipBadgePosition.topLeft:
        return Positioned(
          top: -offset,
          left: -offset,
          child: VipBadge(
            vipLevel: vipLevel,
            badgeType: badgeType,
            size: badgeSize,
            showBackground: true,
          ),
        );
      case VipBadgePosition.bottomRight:
        return Positioned(
          bottom: -offset,
          right: -offset,
          child: VipBadge(
            vipLevel: vipLevel,
            badgeType: badgeType,
            size: badgeSize,
            showBackground: true,
          ),
        );
      case VipBadgePosition.bottomLeft:
        return Positioned(
          bottom: -offset,
          left: -offset,
          child: VipBadge(
            vipLevel: vipLevel,
            badgeType: badgeType,
            size: badgeSize,
            showBackground: true,
          ),
        );
    }
  }
}
