import 'package:flutter_test/flutter_test.dart';
import 'package:cc/core/services/token_refresh_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TokenRefreshService', () {
    late TokenRefreshService service;

    setUp(() {
      service = TokenRefreshService.instance;
    });

    tearDown(() {
      service.stopAutoRefresh();
    });

    group('基础功能测试', () {
      test('应该是单例模式', () {
        final service1 = TokenRefreshService.instance;
        final service2 = TokenRefreshService.instance;
        expect(service1, equals(service2));
      });

      test('应该能启动和停止自动刷新', () {
        expect(() => service.startAutoRefresh(), returnsNormally);
        expect(() => service.stopAutoRefresh(), returnsNormally);
      });

      test('应该能安全释放资源', () {
        expect(() => service.dispose(), returnsNormally);
      });
    });

    group('公共方法测试', () {
      test('needsRefresh方法应该返回布尔值', () async {
        final result = await service.needsRefresh();
        expect(result, isA<bool>());
      });

      test('getTokenRemainingTime方法应该返回Duration或null', () async {
        final result = await service.getTokenRemainingTime();
        expect(result, isA<Duration?>());
      });

      test('manualRefreshToken方法应该返回布尔值', () async {
        final result = await service.manualRefreshToken();
        expect(result, isA<bool>());
      });
    });

    group('边界条件测试', () {
      test('多次启动自动刷新应该安全', () {
        expect(() {
          service.startAutoRefresh();
          service.startAutoRefresh();
          service.startAutoRefresh();
        }, returnsNormally);
      });

      test('多次停止自动刷新应该安全', () {
        expect(() {
          service.stopAutoRefresh();
          service.stopAutoRefresh();
          service.stopAutoRefresh();
        }, returnsNormally);
      });

      test('停止后再启动应该正常工作', () {
        expect(() {
          service.startAutoRefresh();
          service.stopAutoRefresh();
          service.startAutoRefresh();
          service.stopAutoRefresh();
        }, returnsNormally);
      });
    });
  });

  group('Token刷新集成测试', () {
    test('服务初始化应该成功', () {
      final service = TokenRefreshService.instance;
      expect(service, isNotNull);
      expect(service, isA<TokenRefreshService>());
    });

    test('所有公共方法应该可以安全调用', () async {
      final service = TokenRefreshService.instance;
      
      // 测试所有公共方法都不会抛出异常
      expect(() async => await service.needsRefresh(), returnsNormally);
      expect(() async => await service.getTokenRemainingTime(), returnsNormally);
      expect(() async => await service.manualRefreshToken(), returnsNormally);
      expect(() => service.startAutoRefresh(), returnsNormally);
      expect(() => service.stopAutoRefresh(), returnsNormally);
      expect(() => service.dispose(), returnsNormally);
    });
  });

  group('错误处理测试', () {
    test('在无Token状态下手动刷新应该返回false', () async {
      final service = TokenRefreshService.instance;
      final result = await service.manualRefreshToken();
      expect(result, false);
    });

    test('在无Token过期时间状态下检查刷新需求应该返回false', () async {
      final service = TokenRefreshService.instance;
      final needsRefresh = await service.needsRefresh();
      expect(needsRefresh, false);
    });
  });
}
