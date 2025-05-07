/// 生成的protobuf文件
/// 临时创建的占位文件
///
/// Generated from protobuf message
///
class AuthResponse {
  bool success = false;
  String message = '';
  String userId = '';
  String token = '';
  int timestamp = 0;

  bool hasUserId() {
    return userId.isNotEmpty;
  }

  bool hasToken() {
    return token.isNotEmpty;
  }
}

class AuthRequest {
  AuthOperationType operationType = AuthOperationType.login;
  String phoneNumber = '';
  String password = '';
  String verificationCode = '';
  String nickname = '';
  String purpose = '';
  bool isQuickLogin = false;
}

enum AuthOperationType { login, register, resetPassword, sendCode }
