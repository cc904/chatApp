import 'package:flutter_test/flutter_test.dart';
import 'package:cc/core/constants/app_config.dart';

void main() {
  group('AppConfig 多域名后备机制测试', () {
    late AppConfig appConfig;

    setUpAll(() {
      // 初始化Flutter绑定
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    setUp(() {
      appConfig = AppConfig();
    });

    test('应该有默认的服务器列表', () {
      expect(appConfig.allServerUrls.length, equals(2));
      expect(appConfig.allServerUrls[0], equals('http://47.121.28.95:7003'));
      expect(appConfig.allServerUrls[1], equals('http://d2.orb.local:3000'));
    });

    test('应该默认使用第一个服务器', () async {
      await appConfig.init();
      expect(appConfig.serverUrl, equals('http://47.121.28.95:7003'));
      expect(appConfig.currentServerIndex, equals(0));
      expect(appConfig.currentServerName, equals('云端服务器'));
    });

    test('应该能切换到下一个服务器', () async {
      await appConfig.init();
      expect(appConfig.hasNextServer(), isTrue);
      final result = await appConfig.switchToNextServer();
      expect(result, isTrue);

      expect(appConfig.serverUrl, equals('http://d2.orb.local:3000'));
      expect(appConfig.currentServerIndex, equals(1));
      expect(appConfig.currentServerName, equals('本地服务器'));
    });

    test('应该能通过URL设置服务器', () async {
      await appConfig.init();
      await appConfig.setServerUrl('http://d2.orb.local:3000');

      expect(appConfig.serverUrl, equals('http://d2.orb.local:3000'));
      expect(appConfig.currentServerIndex, equals(1));
      expect(appConfig.currentServerName, equals('本地服务器'));
    });

    test('设置不存在的URL不应该改变当前服务器', () async {
      await appConfig.init();
      final originalUrl = appConfig.serverUrl;
      final originalIndex = appConfig.currentServerIndex;

      await appConfig.setServerUrl('http://unknown.server:3000');

      expect(appConfig.serverUrl, equals(originalUrl));
      expect(appConfig.currentServerIndex, equals(originalIndex));
    });

    test('在最后一个服务器时切换应该重置到第一个', () async {
      await appConfig.init();
      // 先切换到最后一个服务器
      await appConfig.setServerUrl('http://d2.orb.local:3000');
      expect(appConfig.currentServerIndex, equals(1));
      expect(appConfig.hasNextServer(), isFalse);

      // 切换应该回到第一个服务器
      final result = await appConfig.switchToNextServer();
      expect(result, isFalse);
      expect(appConfig.currentServerIndex, equals(0));
      expect(appConfig.serverUrl, equals('http://47.121.28.95:7003'));
    });

    test('应该能重置到第一个服务器', () async {
      await appConfig.init();
      // 先切换到其他服务器
      await appConfig.switchToNextServer();
      expect(appConfig.currentServerIndex, equals(1));

      // 重置到第一个
      await appConfig.resetToFirstServer();
      expect(appConfig.currentServerIndex, equals(0));
      expect(appConfig.serverUrl, equals('http://47.121.28.95:7003'));
    });

    test('应该提供正确的服务器显示信息', () async {
      await appConfig.init();
      final displayInfo = appConfig.serverDisplayInfo;

      expect(displayInfo.length, equals(2));
      expect(displayInfo[0]['name'], equals('云端服务器'));
      expect(displayInfo[0]['url'], equals('http://47.121.28.95:7003'));
      expect(displayInfo[1]['name'], equals('本地服务器'));
      expect(displayInfo[1]['url'], equals('http://d2.orb.local:3000'));
    });

    test('故障转移场景模拟', () async {
      await appConfig.init();
      // 模拟连接失败，需要切换服务器的场景
      expect(appConfig.serverUrl, equals('http://47.121.28.95:7003'));

      // 第一次失败，切换到第二个服务器
      if (appConfig.hasNextServer()) {
        await appConfig.switchToNextServer();
        expect(appConfig.serverUrl, equals('http://d2.orb.local:3000'));
        expect(appConfig.currentServerName, equals('本地服务器'));
      }

      // 所有服务器都尝试过了，重置到第一个
      expect(appConfig.hasNextServer(), isFalse);
      await appConfig.switchToNextServer();
      expect(appConfig.serverUrl, equals('http://47.121.28.95:7003'));
    });
  });
}
