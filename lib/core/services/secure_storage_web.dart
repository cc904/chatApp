/// 安全存储服务Web平台实现
/// 
/// Web平台下使用SharedPreferences作为存储方案
/// 注意：Web平台下无法使用真正的安全存储，数据存储在浏览器本地存储中

/// 检查是否应该使用fallback模式
bool shouldUseFallback() {
  // Web平台总是使用SharedPreferences
  return true;
}

/// 检查是否有有效的代码签名
bool hasValidCodeSigning() {
  // Web平台不需要代码签名
  return false;
}

/// 获取平台名称用于日志
String getPlatformName() {
  return 'Web';
}