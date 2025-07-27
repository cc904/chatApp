import 'dart:io';

/// 安全存储服务IO平台实现
/// 
/// 支持iOS、Android、macOS、Windows、Linux等平台

/// 检查是否应该使用fallback模式
bool shouldUseFallback() {
  // 在macOS开发环境下，如果没有有效签名，使用fallback
  return Platform.isMacOS && !hasValidCodeSigning();
}

/// 检查是否有有效的代码签名（简单检测）
bool hasValidCodeSigning() {
  // 在开发环境下假设没有有效签名
  return false; // 可以根据实际情况调整
}

/// 获取平台名称用于日志
String getPlatformName() {
  if (Platform.isIOS) return 'iOS';
  if (Platform.isAndroid) return 'Android';
  if (Platform.isMacOS) return 'macOS';
  if (Platform.isWindows) return 'Windows';
  if (Platform.isLinux) return 'Linux';
  return 'Unknown';
}