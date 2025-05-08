/// 数据编码方式枚举（已废弃，请使用CommunicationService中的DataEncoding）
@Deprecated('Use DataEncoding from CommunicationService instead')
enum LegacyDataEncoding {
  /// JSON编码
  json,

  /// Protocol Buffers编码
  protobuf,

  /// Base64编码的Protocol Buffers
  base64,
}

/// 连接状态枚举
enum ConnectionStatus {
  /// 未连接
  disconnected,

  /// 正在连接
  connecting,

  /// 已连接
  connected,

  /// 连接错误
  error,
}

/// 身份验证状态枚举
enum AuthStatus {
  /// 未认证
  unauthenticated,

  /// 认证中
  authenticating,

  /// 已认证
  authenticated,

  /// 认证失败
  failed,
}

/// Socket服务事件枚举
enum SocketEvent {
  connect,
  disconnect,
  connectError,
  userOnline,
  userOffline,
  newMessage,
  messageDelivered,
  messageRead,
  typing,
  stopTyping,
  contactsSynced,
}
