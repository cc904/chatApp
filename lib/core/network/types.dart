/// Socket.IO事件枚举
enum SocketEvent {
  // 连接相关
  connect,
  disconnect,
  connecting,
  connectError,
  reconnect,
  reconnectAttempt,

  // 自定义事件
  userOnline,
  userOffline,
  newMessage,
  messageDelivered,
  messageRead,
  typing,
  stopTyping,

  // 认证相关事件
  authResponse,
  authError,
}

/// 数据编码方式
enum DataEncoding {
  json, // 传统JSON编码
  protobuf, // Protobuf二进制编码
  base64, // Base64编码的Protobuf (兼容性更好)
} 