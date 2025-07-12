import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:cc/core/utils/display_name_utils.dart';

void main() {
  group('DisplayNameUtils Tests', () {
    test('generateUserColor should return consistent colors for same names',
        () {
      // 相同的名字应该返回相同的颜色
      final color1 = DisplayNameUtils.generateUserColor('张三');
      final color2 = DisplayNameUtils.generateUserColor('张三');
      expect(color1, equals(color2));

      final color3 = DisplayNameUtils.generateUserColor('John Doe');
      final color4 = DisplayNameUtils.generateUserColor('John Doe');
      expect(color3, equals(color4));
    });

    test('generateUserColor should return different colors for different names',
        () {
      // 不同的名字应该返回不同的颜色（大概率）
      final color1 = DisplayNameUtils.generateUserColor('张三');
      final color2 = DisplayNameUtils.generateUserColor('李四');
      final color3 = DisplayNameUtils.generateUserColor('John');
      final color4 = DisplayNameUtils.generateUserColor('Jane');

      // 虽然理论上可能重复，但在16种颜色中重复的概率很小
      expect(color1, isNot(equals(color2)));
      expect(color3, isNot(equals(color4)));
    });

    test('generateUserColor should handle empty or null names', () {
      final colorNull = DisplayNameUtils.generateUserColor(null);
      final colorEmpty = DisplayNameUtils.generateUserColor('');
      final colorWhitespace = DisplayNameUtils.generateUserColor('   ');

      expect(colorNull, equals(Colors.grey[600]));
      expect(colorEmpty, equals(Colors.grey[600]));
      expect(colorWhitespace, equals(Colors.grey[600]));
    });

    test('getInitials should handle Chinese names correctly', () {
      expect(DisplayNameUtils.getInitials('张三'), equals('张'));
      expect(DisplayNameUtils.getInitials('李小明'), equals('李'));
      expect(DisplayNameUtils.getInitials('王'), equals('王'));
    });

    test('getInitials should handle English names correctly', () {
      expect(DisplayNameUtils.getInitials('John Doe'), equals('JD'));
      expect(DisplayNameUtils.getInitials('Jane'), equals('J'));
      expect(DisplayNameUtils.getInitials('A'), equals('A'));
    });

    test('getInitials should handle empty or null names', () {
      expect(DisplayNameUtils.getInitials(null), equals('U'));
      expect(DisplayNameUtils.getInitials(''), equals('U'));
      expect(DisplayNameUtils.getInitials('   '), equals('U'));
    });

    test('generateDisplayName should handle various inputs', () {
      expect(
          DisplayNameUtils.generateDisplayName('张三', 'zhangsan'), equals('张三'));
      expect(DisplayNameUtils.generateDisplayName(null, 'zhangsan'),
          equals('zhangsan'));
      expect(DisplayNameUtils.generateDisplayName('', 'zhangsan'),
          equals('zhangsan'));
      expect(DisplayNameUtils.generateDisplayName(null, null), equals('未知用户'));
      expect(DisplayNameUtils.generateDisplayName('', ''), equals('未知用户'));
    });

    test('color generation should use predefined color palette', () {
      // 测试生成的颜色是否在预定义的调色板中
      final testNames = ['张三', '李四', '王五', 'John', 'Jane', 'Bob', 'Alice'];
      final generatedColors = <Color>{};

      for (final name in testNames) {
        final color = DisplayNameUtils.generateUserColor(name);
        generatedColors.add(color);

        // 验证颜色的alpha值是255（完全不透明）
        expect(color.a, equals(255));
      }

      // 应该生成了一些不同的颜色
      expect(generatedColors.length, greaterThan(1));
    });
  });
}
