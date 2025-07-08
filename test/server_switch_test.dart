import 'package:flutter_test/flutter_test.dart';
import 'package:cc/core/constants/app_config.dart';
import 'package:cc/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:cc/core/services/enhanced_api_service.dart';
import 'package:cc/core/services/enhanced_token_manager.dart';

void main() {
  group('服务器切换功能测试', () {
    setUpAll(() {
      // 初始化Flutter绑定
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    test('AppConfig服务器切换应该持久化保存', () async {
      final appConfig = AppConfig();
      await appConfig.init();

      // 初始状态应该是第一个服务器
      expect(appConfig.currentServerIndex, equals(0));
      expect(appConfig.serverUrl, equals('http://47.121.28.95:7003'));

      // 切换到第二个服务器
      await appConfig.setServerIndex(1);
      expect(appConfig.currentServerIndex, equals(1));
      expect(appConfig.serverUrl, equals('http://d2.orb.local:3000'));

      // 切换回第一个服务器
      await appConfig.setServerIndex(0);
      expect(appConfig.currentServerIndex, equals(0));
      expect(appConfig.serverUrl, equals('http://47.121.28.95:7003'));
    });

    test('AuthRepository应该在服务器URL变更时重新创建实例', () async {
      final appConfig = AppConfig();
      await appConfig.init();

      // 获取第一个服务器的实例
      final repo1 =
          AuthRepositoryImpl.getInstance(serverUrl: appConfig.serverUrl);

      // 切换服务器
      await appConfig.setServerIndex(1);

      // 获取第二个服务器的实例
      final repo2 =
          AuthRepositoryImpl.getInstance(serverUrl: appConfig.serverUrl);

      // 应该是不同的实例（因为URL不同）
      expect(identical(repo1, repo2), isFalse);
    });

    test('EnhancedApiService应该能够更新baseUrl', () {
      final apiService = EnhancedApiService.instance;

      // 设置第一个服务器URL
      apiService.setBaseUrl('http://47.121.28.95:7003');
      expect(
          apiService.dio.options.baseUrl, equals('http://47.121.28.95:7003'));

      // 切换到第二个服务器URL
      apiService.setBaseUrl('http://d2.orb.local:3000');
      expect(
          apiService.dio.options.baseUrl, equals('http://d2.orb.local:3000'));
    });

    test('EnhancedTokenManager应该能够更新baseUrl', () {
      final tokenManager = EnhancedTokenManager.instance;

      // 更新TokenManager的baseUrl
      tokenManager.updateBaseUrl('http://47.121.28.95:7003');
      // 注意：我们无法直接访问私有的_dio实例来验证，但至少确保方法不会抛出异常

      tokenManager.updateBaseUrl('http://d2.orb.local:3000');
      // 同样，确保方法调用成功
    });

    test('完整的服务器切换流程', () async {
      final appConfig = AppConfig();
      await appConfig.init();

      // 初始状态
      expect(appConfig.serverUrl, equals('http://47.121.28.95:7003'));

      // 获取初始的AuthRepository实例
      final initialRepo =
          AuthRepositoryImpl.getInstance(serverUrl: appConfig.serverUrl);

      // 切换服务器
      await appConfig.setServerIndex(1);
      expect(appConfig.serverUrl, equals('http://d2.orb.local:3000'));

      // 获取新的AuthRepository实例（应该使用新的URL）
      final newRepo =
          AuthRepositoryImpl.getInstance(serverUrl: appConfig.serverUrl);

      // 验证实例已更新
      expect(identical(initialRepo, newRepo), isFalse);

      // 验证API服务也应该更新baseUrl
      final apiService = EnhancedApiService.instance;
      apiService.setBaseUrl(appConfig.serverUrl);
      expect(
          apiService.dio.options.baseUrl, equals('http://d2.orb.local:3000'));
    });
  });
}
