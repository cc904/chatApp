#!/usr/bin/env dart

import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// 清理数据库脚本
/// 
/// 删除所有现有的数据库文件，强制应用重新创建带有新结构的数据库
/// 这样可以解决数据库结构变更导致的兼容性问题
void main() async {
  try {
    print('🗂️  开始清理数据库文件...');
    
    // 获取应用文档目录
    final appDocDir = await getApplicationDocumentsDirectory();
    print('📁 应用文档目录: ${appDocDir.path}');
    
    // 查找所有数据库文件
    final driftFiles = await appDocDir
        .list()
        .where((entity) =>
            entity.path.endsWith('.db') ||
            entity.path.endsWith('.db-wal') ||
            entity.path.endsWith('.db-shm'))
        .toList();
    
    if (driftFiles.isEmpty) {
      print('✅ 没有找到数据库文件，可能已经是干净状态');
      return;
    }
    
    print('🔍 找到 ${driftFiles.length} 个数据库文件:');
    for (final file in driftFiles) {
      print('   - ${file.path}');
    }
    
    // 删除数据库文件
    int deletedCount = 0;
    for (final file in driftFiles) {
      try {
        await file.delete();
        print('🗑️  已删除: ${file.path}');
        deletedCount++;
      } catch (e) {
        print('❌ 删除失败: ${file.path} - $e');
      }
    }
    
    // 删除媒体文件夹
    final mediaDir = Directory('${appDocDir.path}/media');
    if (await mediaDir.exists()) {
      try {
        await mediaDir.delete(recursive: true);
        print('🗑️  已删除媒体文件夹: ${mediaDir.path}');
      } catch (e) {
        print('❌ 删除媒体文件夹失败: $e');
      }
    }
    
    print('🎉 数据库清理完成！');
    print('📊 统计: 删除了 $deletedCount 个数据库文件');
    print('💡 下次启动应用时，将自动创建包含 role_id 字段的新数据库');
    
  } catch (e) {
    print('❌ 清理数据库时发生错误: $e');
    exit(1);
  }
}