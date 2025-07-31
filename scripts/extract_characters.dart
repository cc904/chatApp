#!/usr/bin/env dart

import 'dart:io';
import 'dart:convert';

/// 字符提取工具
/// 用于分析Flutter项目中使用的所有字符，生成字体预加载列表
class CharacterExtractor {
  // 中文字符范围
  static final RegExp _chineseRegex = RegExp(r'[\u4e00-\u9fff\u3400-\u4dbf\uf900-\ufaff]');
  
  // 标点符号和特殊字符
  static final RegExp _punctuationRegex = RegExp(r'[\u3000-\u303f\uff00-\uffef]');
  
  // 需要扫描的文件类型
  static final List<String> _fileExtensions = ['.dart', '.json', '.yaml', '.yml'];
  
  // 排除的目录
  static final List<String> _excludeDirs = [
    '.git', '.dart_tool', 'build', '.vscode', 'node_modules',
    'macos', 'windows', 'linux', 'ios', 'android'
  ];

  final Set<String> _allChars = <String>{};
  final Set<String> _chineseChars = <String>{};
  final Set<String> _punctuationChars = <String>{};
  
  // 公共访问器
  Set<String> get allChars => Set.from(_allChars);
  Set<String> get chineseChars => Set.from(_chineseChars);
  Set<String> get punctuationChars => Set.from(_punctuationChars);
  
  /// 扫描项目目录
  Future<void> scanDirectory(String path) async {
    final dir = Directory(path);
    if (!await dir.exists()) {
      print('❌ 目录不存在: $path');
      return;
    }

    print('🔍 开始扫描项目目录: $path');
    await _scanDirectoryRecursive(dir);
    
    print('\n📊 扫描统计:');
    print('   总字符数: ${_allChars.length}');
    print('   中文字符: ${_chineseChars.length}');
    print('   标点符号: ${_punctuationChars.length}');
  }

  /// 递归扫描目录
  Future<void> _scanDirectoryRecursive(Directory dir) async {
    try {
      await for (final entity in dir.list()) {
        if (entity is Directory) {
          final dirName = entity.path.split('/').last;
          if (!_excludeDirs.contains(dirName)) {
            await _scanDirectoryRecursive(entity);
          }
        } else if (entity is File) {
          if (_shouldScanFile(entity.path)) {
            await _scanFile(entity);
          }
        }
      }
    } catch (e) {
      print('⚠️ 扫描目录错误: ${dir.path} - $e');
    }
  }

  /// 判断是否应该扫描文件
  bool _shouldScanFile(String filePath) {
    return _fileExtensions.any((ext) => filePath.endsWith(ext));
  }

  /// 扫描单个文件
  Future<void> _scanFile(File file) async {
    try {
      final content = await file.readAsString(encoding: utf8);
      _extractCharsFromText(content);
      
      // 显示进度
      if (_allChars.length % 100 == 0) {
        stdout.write('\r   扫描进度: ${_allChars.length} 字符');
      }
    } catch (e) {
      // 忽略二进制文件或编码错误
    }
  }

  /// 从文本中提取字符
  void _extractCharsFromText(String text) {
    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      
      // 跳过控制字符
      if (char.codeUnitAt(0) < 32 && char != '\n' && char != '\r' && char != '\t') {
        continue;
      }
      
      _allChars.add(char);
      
      // 分类字符
      if (_chineseRegex.hasMatch(char)) {
        _chineseChars.add(char);
      } else if (_punctuationRegex.hasMatch(char)) {
        _punctuationChars.add(char);
      }
    }
  }

  /// 生成字符集文件
  Future<void> generateCharacterSets(String outputDir) async {
    final outDir = Directory(outputDir);
    if (!await outDir.exists()) {
      await outDir.create(recursive: true);
    }

    // 生成完整字符集
    await _generateCharSet(
      '$outputDir/all_chars.txt',
      _allChars.toList()..sort(),
      '完整字符集'
    );

    // 生成中文字符集
    await _generateCharSet(
      '$outputDir/chinese_chars.txt',
      _chineseChars.toList()..sort(),
      '中文字符集'
    );

    // 生成标点符号集
    await _generateCharSet(
      '$outputDir/punctuation_chars.txt',
      _punctuationChars.toList()..sort(),
      '标点符号集'
    );

    // 生成按频率排序的字符集
    await _generateFrequencyBasedSets(outputDir);
    
    // 生成JavaScript格式的字符集
    await _generateJavaScriptConstants(outputDir);
    
    print('\n✅ 字符集文件已生成到: $outputDir');
  }

  /// 生成字符集文件
  Future<void> _generateCharSet(String filePath, List<String> chars, String description) async {
    final file = File(filePath);
    final buffer = StringBuffer();
    
    buffer.writeln('// $description');
    buffer.writeln('// 总计: ${chars.length} 个字符');
    buffer.writeln('// 生成时间: ${DateTime.now().toIso8601String()}');
    buffer.writeln();
    
    // 每行50个字符
    for (int i = 0; i < chars.length; i += 50) {
      final end = (i + 50 < chars.length) ? i + 50 : chars.length;
      buffer.writeln(chars.sublist(i, end).join(''));
    }
    
    await file.writeAsString(buffer.toString());
    print('   生成: ${file.path} (${chars.length} 字符)');
  }

  /// 生成按频率分级的字符集
  Future<void> _generateFrequencyBasedSets(String outputDir) async {
    // 常用字符（前1000个最常用的中文字符）
    const commonChars = '的一是在不了有和人这中大为上个国我以要他时来用们生到作地于出就分对成会可主发年动同工也能下过子说产种面而方后多定行学法所民得经十三之进着等部度家电力里如水化高自二理起小物现实加量都两体制机当使点从业本去把性好应开它合还因由其些然前外天政四日那社义事平形相全表间样与关各重新线内数正心反你明看原又么利比或但质气第向道命此变条只没结解问意建月公无系军很情者最立代想已通并提直题党程展五果料象员革位入常文总次品式活设及管特件长求老头基资边流路级少图山统接知较将组见计别她手角期根论运农指几九区强放决西被干做必战先回则任取据处队南给色光门即保治北造百规热领七海口东导器压志世金增争济阶油思术极交受联什认六共权收证改清己美再采转更单风切打白教速花带安场身车例真务具万每目至达走积示议声报斗完类八离华名确才科张信马节话米整空元况今集温传土许步群广石记需段研界拉林律叫且究观越织装影算低持音众书布复容儿须际商非验连断深难近矿千周委素技备半办青省列习响约支般史感劳便团往酸历市克何除消构府称太准精值号率族维划选标写存候毛亲快效斯院查江型眼王按格养易置派层片始却专状育厂京识适属圆包火住调满县局照参红细引听该铁价严龙飞';
    
    final commonSet = <String>{};
    for (final char in commonChars.split('')) {
      if (_chineseChars.contains(char)) {
        commonSet.add(char);
      }
    }
    
    await _generateCharSet(
      '$outputDir/common_chars.txt',
      commonSet.toList()..sort(),
      '常用字符集 (高频)'
    );

    // 次常用字符（项目中使用但不在常用字符中的）
    final lessCommonChars = _chineseChars.difference(commonSet).toList()..sort();
    await _generateCharSet(
      '$outputDir/less_common_chars.txt',
      lessCommonChars,
      '次常用字符集 (中频)'
    );
  }

  /// 生成JavaScript格式的常量
  Future<void> _generateJavaScriptConstants(String outputDir) async {
    final file = File('$outputDir/character_sets.js');
    final buffer = StringBuffer();
    
    buffer.writeln('/**');
    buffer.writeln(' * 项目字符集常量');
    buffer.writeln(' * 自动生成，请勿手动编辑');
    buffer.writeln(' * 生成时间: ${DateTime.now().toIso8601String()}');
    buffer.writeln(' */');
    buffer.writeln();
    
    // 导出字符集
    buffer.writeln('export const CHARACTER_SETS = {');
    buffer.writeln('  // 总字符数: ${_allChars.length}');
    buffer.writeln('  ALL_CHARS: "${_escapeForJS(_allChars.join())}",');
    buffer.writeln();
    buffer.writeln('  // 中文字符数: ${_chineseChars.length}');
    buffer.writeln('  CHINESE_CHARS: "${_escapeForJS(_chineseChars.join())}",');
    buffer.writeln();
    buffer.writeln('  // 标点符号数: ${_punctuationChars.length}');
    buffer.writeln('  PUNCTUATION_CHARS: "${_escapeForJS(_punctuationChars.join())}",');
    buffer.writeln();
    
    // 常用字符
    const commonChars = '的一是在不了有和人这中大为上个国我以要他时来用们生到作地于出就分对成会可主发年动同工也能下过子说产种面而方后多定行学法所民得经十三之进着等部度家电力里如水化高自二理起小物现实加量都两体制机当使点从业本去把性好应开它合还因由其些然前外天政四日那社义事平形相全表间样与关各重新线内数正心反你明看原又么利比或但质气第向道命此变条只没结解问意建月公无系军很情者最立代想已通并提直题党程展五果料象员革位入常文总次品式活设及管特件长求老头基资边流路级少图山统接知较将组见计别她手角期根论运农指几九区强放决西被干做必战先回则任取据处队南给色光门即保治北造百规热领七海口东导器压志世金增争济阶油思术极交受联什认六共权收证改清己美再采转更单风切打白教速花带安场身车例真务具万每目至达走积示议声报斗完类八离华名确才科张信马节话米整空元况今集温传土许步群广石记需段研界拉林律叫且究观越织装影算低持音众书布复容儿须际商非验连断深难近矿千周委素技备半办青省列习响约支般史感劳便团往酸历市克何除消构府称太准精值号率族维划选标写存候毛亲快效斯院查江型眼王按格养易置派层片始却专状育厂京识适属圆包火住调满县局照参红细引听该铁价严龙飞';
    buffer.writeln('  // 常用字符 (基于频率统计)');
    buffer.writeln('  COMMON_CHARS: "$commonChars",');
    buffer.writeln('};');
    
    await file.writeAsString(buffer.toString());
    print('   生成: ${file.path}');
  }

  /// JavaScript字符串转义
  String _escapeForJS(String str) {
    return str
        .replaceAll('\\', '\\\\')
        .replaceAll('"', '\\"')
        .replaceAll('\n', '\\n')
        .replaceAll('\r', '\\r')
        .replaceAll('\t', '\\t');
  }

  /// 生成统计报告
  Future<void> generateReport(String outputPath) async {
    final file = File(outputPath);
    final buffer = StringBuffer();
    
    buffer.writeln('# 字符使用统计报告');
    buffer.writeln();
    buffer.writeln('生成时间: ${DateTime.now().toIso8601String()}');
    buffer.writeln();
    
    buffer.writeln('## 总体统计');
    buffer.writeln('- 总字符数: ${_allChars.length}');
    buffer.writeln('- 中文字符: ${_chineseChars.length}');
    buffer.writeln('- 标点符号: ${_punctuationChars.length}');
    buffer.writeln('- 其他字符: ${_allChars.length - _chineseChars.length - _punctuationChars.length}');
    buffer.writeln();
    
    buffer.writeln('## 字符分布');
    final charGroups = <String, int>{};
    for (final char in _allChars) {
      final code = char.codeUnitAt(0);
      String group;
      if (code < 128) {
        group = 'ASCII';
      } else if (code >= 0x4e00 && code <= 0x9fff) {
        group = 'CJK基本汉字';
      } else if (code >= 0x3400 && code <= 0x4dbf) {
        group = 'CJK扩展A';
      } else if (code >= 0xff00 && code <= 0xffef) {
        group = '全角字符';
      } else {
        group = '其他Unicode';
      }
      charGroups[group] = (charGroups[group] ?? 0) + 1;
    }
    
    for (final entry in charGroups.entries) {
      buffer.writeln('- ${entry.key}: ${entry.value}');
    }
    
    await file.writeAsString(buffer.toString());
    print('   生成: ${file.path}');
  }
}

/// 主函数
Future<void> main(List<String> args) async {
  print('🚀 Flutter项目字符提取工具');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  
  final projectPath = args.isNotEmpty ? args[0] : '.';
  final outputDir = args.length > 1 ? args[1] : './font-subset-server/character-sets';
  
  final extractor = CharacterExtractor();
  
  // 扫描项目
  await extractor.scanDirectory(projectPath);
  
  // 生成字符集文件
  await extractor.generateCharacterSets(outputDir);
  
  // 生成统计报告
  await extractor.generateReport('$outputDir/character_report.md');
  
  print('\n🎉 字符提取完成！');
  print('   输出目录: $outputDir');
  print('   使用方法: dart run scripts/extract_characters.dart [项目路径] [输出目录]');
}