import 'package:flutter_test/flutter_test.dart';
import 'package:cc/core/constants/app_config.dart';

void main() {
  group('AppConfig 多域名后备机制测试', () {
    late AppConfig appConfig;

    setUp(() {
      appConfig = AppConfig();
    });

    test('应该有默认的服务器列表', () {
      expect(appConfig.allServerUrls.length, equals(4));
      expect(appConfig.allServerUrls[0], equals('http://d2.orb.local:3000'));
      expect(appConfig.allServerUrls[1], equals('http://127.0.0.1:3000'));
      expect(appConfig.allServerUrls[2], equals('http://192.168.1.100:3000'));
      expect(appConfig.allServerUrls[3],
          equals('https://backup.example.com:3000'));
    });

    test('应该默认使用第一个服务器', () {
      expect(appConfig.serverUrl, equals('http://d2.orb.local:3000'));
      expect(appConfig.currentServerIndex, equals(0));
      expect(appConfig.currentServerName, equals('内网主服务器'));
    });

    test('应该能切换到下一个服务器', () {
      expect(appConfig.hasNextServer(), isTrue);
      expect(appConfig.switchToNextServer(), isTrue);

      expect(appConfig.serverUrl, equals('http://127.0.0.1:3000'));
      expect(appConfig.currentServerIndex, equals(1));
      expect(appConfig.currentServerName, equals('本地开发服务器'));
    });

    test('应该能通过URL设置服务器', () {
      appConfig.setServerUrl('http://192.168.1.100:3000');

      expect(appConfig.serverUrl, equals('http://192.168.1.100:3000'));
      expect(appConfig.currentServerIndex, equals(2));
      expect(appConfig.currentServerName, equals('内网IP服务器'));
    });

    test('设置不存在的URL不应该改变当前服务器', () {
      final originalUrl = appConfig.serverUrl;
      final originalIndex = appConfig.currentServerIndex;

      appConfig.setServerUrl('http://unknown.server:3000');

      expect(appConfig.serverUrl, equals(originalUrl));
      expect(appConfig.currentServerIndex, equals(originalIndex));
    });

    test('在最后一个服务器时切换应该重置到第一个', () {
      // 先切换到最后一个服务器
      appConfig.setServerUrl('https://backup.example.com:3000');
      expect(appConfig.currentServerIndex, equals(3));
      expect(appConfig.hasNextServer(), isFalse);

      // 切换应该回到第一个服务器
      expect(appConfig.switchToNextServer(), isFalse);
      expect(appConfig.currentServerIndex, equals(0));
      expect(appConfig.serverUrl, equals('http://d2.orb.local:3000'));
    });

    test('应该能重置到第一个服务器', () {
      // 先切换到其他服务器
      appConfig.switchToNextServer();
      appConfig.switchToNextServer();
      expect(appConfig.currentServerIndex, equals(2));

      // 重置到第一个
      appConfig.resetToFirstServer();
      expect(appConfig.currentServerIndex, equals(0));
      expect(appConfig.serverUrl, equals('http://d2.orb.local:3000'));
    });

    test('应该提供正确的服务器显示信息', () {
      final displayInfo = appConfig.serverDisplayInfo;

      expect(displayInfo.length, equals(4));
      expect(displayInfo[0]['name'], equals('内网主服务器'));
      expect(displayInfo[0]['url'], equals('http://d2.orb.local:3000'));
      expect(displayInfo[1]['name'], equals('本地开发服务器'));
      expect(displayInfo[1]['url'], equals('http://127.0.0.1:3000'));
    });

    test('故障转移场景模拟', () {
      // 模拟连接失败，需要切换服务器的场景
      expect(appConfig.serverUrl, equals('http://d2.orb.local:3000'));

      // 第一次失败，切换到第二个服务器
      if (appConfig.hasNextServer()) {
        appConfig.switchToNextServer();
        expect(appConfig.serverUrl, equals('http://127.0.0.1:3000'));
        expect(appConfig.currentServerName, equals('本地开发服务器'));
      }

      // 第二次失败，切换到第三个服务器
      if (appConfig.hasNextServer()) {
        appConfig.switchToNextServer();
        expect(appConfig.serverUrl, equals('http://192.168.1.100:3000'));
        expect(appConfig.currentServerName, equals('内网IP服务器'));
      }

      // 第三次失败，切换到第四个服务器
      if (appConfig.hasNextServer()) {
        appConfig.switchToNextServer();
        expect(appConfig.serverUrl, equals('https://backup.example.com:3000'));
        expect(appConfig.currentServerName, equals('云端备用服务器'));
      }

      // 所有服务器都尝试过了，重置到第一个
      expect(appConfig.hasNextServer(), isFalse);
      appConfig.switchToNextServer();
      expect(appConfig.serverUrl, equals('http://d2.orb.local:3000'));
    });
  });
}
