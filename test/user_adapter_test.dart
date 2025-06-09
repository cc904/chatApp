import 'package:flutter_test/flutter_test.dart';
import 'package:cc/core/adapters/user_adapter.dart';
import 'package:cc/core/database/models/current_user.dart';
import 'package:cc/core/database/models/user.dart';
import 'package:cc/core/proto/generated/user.pb.dart' as proto;
import 'package:fixnum/fixnum.dart';

void main() {
  group('UserAdapter Tests', () {
    test('fromCurrentUserProto should convert proto to CurrentUser correctly',
        () {
      // Arrange
      final protoUser = proto.CurrentUserProto(
        userId: 'user123',
        token: 'token123',
        name: 'Test User',
        avatar: 'https://example.com/avatar.jpg',
        phone: '1234567890',
        email: 'test@example.com',
        status: 'online',
        tokenExpireTime: Int64(1640995200000), // 2022-01-01 00:00:00
        lastLoginTime: Int64(1640995200000),
      );

      // Act
      final currentUser = UserAdapter.fromCurrentUserProto(protoUser);

      // Assert
      expect(currentUser.userId, equals('user123'));
      expect(currentUser.token, equals('token123'));
      expect(currentUser.name, equals('Test User'));
      expect(currentUser.avatar, equals('https://example.com/avatar.jpg'));
      expect(currentUser.phone, equals('1234567890'));
      expect(currentUser.email, equals('test@example.com'));
      expect(currentUser.status, equals('online'));
      expect(currentUser.tokenExpireTime, isNotNull);
      expect(currentUser.lastLoginTime, isNotNull);
    });

    test('fromUserProto should convert proto to User correctly', () {
      // Arrange
      final protoUser = proto.UserProto(
        userId: 'user456',
        name: 'Another User',
        avatar: 'https://example.com/avatar2.jpg',
        phone: '0987654321',
        email: 'another@example.com',
        status: 'offline',
        lastActiveTime: Int64(1640995200000),
      );

      // Act
      final user = UserAdapter.fromUserProto(protoUser);

      // Assert
      expect(user.userId, equals('user456'));
      expect(user.name, equals('Another User'));
      expect(user.avatar, equals('https://example.com/avatar2.jpg'));
      expect(user.phone, equals('0987654321'));
      expect(user.email, equals('another@example.com'));
      expect(user.status, equals('offline'));
      expect(user.lastActiveTime, isNotNull);
    });

    test('extractToken should return correct token', () {
      // Arrange
      final protoUser = proto.CurrentUserProto(
        userId: 'user123',
        token: 'secret_token_123',
        name: 'Test User',
      );

      // Act
      final token = UserAdapter.extractToken(protoUser);

      // Assert
      expect(token, equals('secret_token_123'));
    });

    test('extractTokenFromCurrentUser should return correct token', () {
      // Arrange
      final currentUser = CurrentUser()
        ..userId = 'user123'
        ..token = 'secret_token_456'
        ..name = 'Test User';

      // Act
      final token = UserAdapter.extractTokenFromCurrentUser(currentUser);

      // Assert
      expect(token, equals('secret_token_456'));
    });

    test('toUserProto should convert User to proto correctly', () {
      // Arrange
      final user = User()
        ..userId = 'user789'
        ..name = 'Proto User'
        ..avatar = 'https://example.com/avatar3.jpg'
        ..phone = '1111111111'
        ..email = 'proto@example.com'
        ..status = 'away'
        ..lastActiveTime = DateTime.fromMillisecondsSinceEpoch(1640995200000);

      // Act
      final protoUser = UserAdapter.toUserProto(user);

      // Assert
      expect(protoUser.userId, equals('user789'));
      expect(protoUser.name, equals('Proto User'));
      expect(protoUser.avatar, equals('https://example.com/avatar3.jpg'));
      expect(protoUser.phone, equals('1111111111'));
      expect(protoUser.email, equals('proto@example.com'));
      expect(protoUser.status, equals('away'));
      expect(protoUser.lastActiveTime.toInt(), equals(1640995200000));
    });

    test('toCurrentUserProto should convert CurrentUser to proto correctly',
        () {
      // Arrange
      final currentUser = CurrentUser()
        ..userId = 'user999'
        ..token = 'token999'
        ..name = 'Current User'
        ..avatar = 'https://example.com/avatar4.jpg'
        ..phone = '2222222222'
        ..email = 'current@example.com'
        ..status = 'online'
        ..tokenExpireTime = DateTime.fromMillisecondsSinceEpoch(1640995200000)
        ..lastLoginTime = DateTime.fromMillisecondsSinceEpoch(1640995200000);

      // Act
      final protoUser = UserAdapter.toCurrentUserProto(currentUser);

      // Assert
      expect(protoUser.userId, equals('user999'));
      expect(protoUser.token, equals('token999'));
      expect(protoUser.name, equals('Current User'));
      expect(protoUser.avatar, equals('https://example.com/avatar4.jpg'));
      expect(protoUser.phone, equals('2222222222'));
      expect(protoUser.email, equals('current@example.com'));
      expect(protoUser.status, equals('online'));
      expect(protoUser.tokenExpireTime.toInt(), equals(1640995200000));
      expect(protoUser.lastLoginTime.toInt(), equals(1640995200000));
    });

    test('batch conversion should work correctly', () {
      // Arrange
      final protoUsers = [
        proto.UserProto(userId: 'user1', name: 'User 1'),
        proto.UserProto(userId: 'user2', name: 'User 2'),
        proto.UserProto(userId: 'user3', name: 'User 3'),
      ];

      // Act
      final users = UserAdapter.fromUserProtoList(protoUsers);
      final backToProto = UserAdapter.toUserProtoList(users);

      // Assert
      expect(users.length, equals(3));
      expect(users[0].userId, equals('user1'));
      expect(users[1].userId, equals('user2'));
      expect(users[2].userId, equals('user3'));

      expect(backToProto.length, equals(3));
      expect(backToProto[0].userId, equals('user1'));
      expect(backToProto[1].userId, equals('user2'));
      expect(backToProto[2].userId, equals('user3'));
    });

    test('should handle optional fields correctly', () {
      // Arrange - proto with minimal fields
      final protoUser = proto.CurrentUserProto(
        userId: 'user_minimal',
        token: 'token_minimal',
        name: 'Minimal User',
      );

      // Act
      final currentUser = UserAdapter.fromCurrentUserProto(protoUser);

      // Assert
      expect(currentUser.userId, equals('user_minimal'));
      expect(currentUser.token, equals('token_minimal'));
      expect(currentUser.name, equals('Minimal User'));
      expect(currentUser.avatar, anyOf(isNull, equals('')));
      expect(currentUser.phone, anyOf(isNull, equals('')));
      expect(currentUser.email, anyOf(isNull, equals('')));
      expect(currentUser.status, anyOf(isNull, equals('')));
      expect(currentUser.tokenExpireTime, isNull);
      expect(currentUser.lastLoginTime, isNull);
    });
  });
}
