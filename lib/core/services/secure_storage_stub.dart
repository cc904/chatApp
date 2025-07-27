/// 安全存储服务存根实现
/// 
/// 用于不支持的平台

/// 检查是否应该使用fallback模式
bool shouldUseFallback() {
  throw UnsupportedError('此平台不支持安全存储功能');
}

/// 检查是否有有效的代码签名
bool hasValidCodeSigning() {
  throw UnsupportedError('此平台不支持代码签名检查');
}

/// 获取平台名称用于日志
String getPlatformName() {
  throw UnsupportedError('此平台不支持平台名称获取');
}