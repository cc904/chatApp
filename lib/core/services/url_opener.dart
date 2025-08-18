import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// 统一的 URL 打开服务
///
/// - 普通 http/https 链接：默认使用内置浏览器（iOS=SFSafariVC / Android=Custom Tabs）
/// - 下载链接或非 http/https：使用外置浏览器/对应应用
class UrlOpener {
  /// 打开链接
  ///
  /// - [preferInApp]: 优先内置浏览器（仅 http/https 生效）
  /// - [isDownload]: 明确标记为下载链接，强制外置打开
  static Future<bool> open(
    String url, {
    bool preferInApp = true,
    bool isDownload = false,
  }) async {
    try {
      final uri = Uri.parse(url);

      // 非 http/https 统一交给系统处理
      final isHttp = uri.scheme == 'http' || uri.scheme == 'https';
      final isMobile = defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android;
      final isDesktop = defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux;

      final shouldUseInApp = isHttp && !isDownload && preferInApp && isMobile;

      final LaunchMode mode;
      if (kIsWeb) {
        // Web 平台不支持内置浏览器，交由浏览器处理（新标签/同标签由浏览器策略决定）
        mode = LaunchMode.platformDefault;
      } else if (isDesktop) {
        // 桌面平台统一外置
        mode = LaunchMode.externalApplication;
      } else {
        mode = shouldUseInApp
            ? LaunchMode.inAppBrowserView
            : LaunchMode.externalApplication;
      }

      if (await canLaunchUrl(uri)) {
        try {
          await launchUrl(
            uri,
            mode: mode,
            webViewConfiguration: const WebViewConfiguration(
              enableJavaScript: false,
            ),
          );
          return true;
        } catch (_) {
          // 如果内置失败，尝试回退到外置
          if (shouldUseInApp || kIsWeb) {
            try {
              await launchUrl(
                uri,
                mode: LaunchMode.externalApplication,
              );
              return true;
            } catch (_) {}
          }
        }
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// 明确使用内置浏览器（失败自动回退外置）
  static Future<bool> openInApp(String url) {
    return open(url, preferInApp: true, isDownload: false);
  }

  /// 明确使用外置浏览器
  static Future<bool> openExternal(String url) {
    return open(url, preferInApp: false);
  }
}


