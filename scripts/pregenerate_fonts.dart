#!/usr/bin/env dart

import 'dart:io';
import 'dart:convert';
import 'extract_characters.dart';

/// 预生成字体切片工具
/// 提取程序中的字符并生成对应的字体文件
class FontPreGenerator {
  final String outputDir;
  final String webOutputDir;
  
  FontPreGenerator({
    required this.outputDir,
    required this.webOutputDir,
  });

  /// 预生成所有字体切片
  Future<void> generateFontSlices() async {
    print('🚀 开始预生成字体切片...');
    
    // 1. 提取项目字符
    final extractor = CharacterExtractor();
    await extractor.scanDirectory('.');
    
    final chineseChars = extractor.chineseChars;
    final allChars = extractor.allChars;
    
    print('📊 字符统计:');
    print('   中文字符: ${chineseChars.length} 个');
    print('   总字符数: ${allChars.length} 个');
    
    // 2. 生成字体切片文件
    await _generateFontSliceFiles(chineseChars, allChars);
    
    // 3. 生成Web字体清单
    await _generateWebFontManifest(chineseChars);
    
    // 4. 生成CSS文件
    await _generateFontCSS();
    
    print('✅ 字体切片预生成完成！');
  }

  /// 生成字体切片文件（模拟）
  Future<void> _generateFontSliceFiles(Set<String> chineseChars, Set<String> allChars) async {
    final fontDir = Directory('$webOutputDir/fonts/pregenerated');
    if (!await fontDir.exists()) {
      await fontDir.create(recursive: true);
    }

    // 按字符数量分组，避免单个文件过大
    const charsPerFile = 100;
    final chineseCharsList = chineseChars.toList();
    
    final files = <Map<String, dynamic>>[];
    
    for (int i = 0; i < chineseCharsList.length; i += charsPerFile) {
      final end = (i + charsPerFile < chineseCharsList.length) 
          ? i + charsPerFile 
          : chineseCharsList.length;
      
      final batch = chineseCharsList.sublist(i, end);
      final batchText = batch.join();
      final fileName = 'slice_${(i ~/ charsPerFile + 1).toString().padLeft(3, '0')}.woff2';
      
      // 模拟生成字体文件（实际项目中需要使用真实的字体切片工具）
      final fontFile = File('${fontDir.path}/$fileName');
      await fontFile.writeAsBytes(_generateMockFontData(batchText));
      
      files.add({
        'file': fileName,
        'chars': batchText,
        'count': batch.length,
        'size': await fontFile.length(),
      });
      
      print('   生成: $fileName (${batch.length} 字符)');
    }

    // 生成字体清单
    final manifestFile = File('${fontDir.path}/manifest.json');
    await manifestFile.writeAsString(jsonEncode({
      'version': '1.0.0',
      'generated': DateTime.now().toIso8601String(),
      'totalChars': chineseChars.length,
      'totalFiles': files.length,
      'files': files,
    }));

    print('   生成清单: manifest.json (${files.length} 个文件)');
  }

  /// 生成Web字体清单文件
  Future<void> _generateWebFontManifest(Set<String> chineseChars) async {
    final manifestContent = '''
/**
 * 预生成字体清单
 * 自动生成，请勿手动编辑
 * 生成时间: ${DateTime.now().toIso8601String()}
 */

window.PREGENERATED_FONTS = {
  // 字符总数
  totalChars: ${chineseChars.length},
  
  // 字符映射到文件
  charToFile: new Map([
${_generateCharToFileMapping(chineseChars)}
  ]),
  
  // 获取字符对应的字体文件
  getFileForChar: function(char) {
    return this.charToFile.get(char);
  },
  
  // 获取文本需要的所有字体文件
  getFilesForText: function(text) {
    const files = new Set();
    for (const char of text) {
      const file = this.getFileForChar(char);
      if (file) {
        files.add(file);
      }
    }
    return Array.from(files);
  },
  
  // 预加载指定文件
  preloadFiles: async function(fileNames) {
    const promises = fileNames.map(fileName => {
      return new Promise((resolve, reject) => {
        const link = document.createElement('link');
        link.rel = 'preload';
        link.as = 'font';
        link.type = 'font/woff2';
        link.crossOrigin = 'anonymous';
        link.href = `/fonts/pregenerated/\${fileName}`;
        link.onload = resolve;
        link.onerror = reject;
        document.head.appendChild(link);
      });
    });
    
    return Promise.all(promises);
  }
};

// 自动预加载常用字符的字体
document.addEventListener('DOMContentLoaded', function() {
  const commonChars = '的一是在不了有和人这中大为上个国我以要他时来用们生到作地于出就分对成会可主发年动同工也能下过子说产种面而方后多定行学法所民得经十三';
  const commonFiles = window.PREGENERATED_FONTS.getFilesForText(commonChars);
  
  if (commonFiles.length > 0) {
    console.log('🎯 预加载常用字符字体:', commonFiles.length, '个文件');
    window.PREGENERATED_FONTS.preloadFiles(commonFiles);
  }
});
''';

    final manifestFile = File('$webOutputDir/pregenerated-fonts.js');
    await manifestFile.writeAsString(manifestContent);
    
    print('   生成Web清单: pregenerated-fonts.js');
  }

  /// 生成字符到文件的映射
  String _generateCharToFileMapping(Set<String> chineseChars) {
    final chineseCharsList = chineseChars.toList();
    const charsPerFile = 100;
    final lines = <String>[];
    
    for (int i = 0; i < chineseCharsList.length; i += charsPerFile) {
      final end = (i + charsPerFile < chineseCharsList.length) 
          ? i + charsPerFile 
          : chineseCharsList.length;
      
      final batch = chineseCharsList.sublist(i, end);
      final fileName = 'slice_${(i ~/ charsPerFile + 1).toString().padLeft(3, '0')}.woff2';
      
      for (final char in batch) {
        lines.add('    ["$char", "$fileName"]');
      }
    }
    
    return lines.join(',\n');
  }

  /// 生成字体CSS
  Future<void> _generateFontCSS() async {
    final cssContent = '''
/* 预生成字体CSS */
/* 自动生成，请勿手动编辑 */
/* 生成时间: ${DateTime.now().toIso8601String()} */

@font-face {
  font-family: 'PreGeneratedCJK';
  font-style: normal;
  font-weight: 400;
  font-display: swap;
  src: local(''),
       url('/fonts/pregenerated/slice_001.woff2') format('woff2');
  unicode-range: U+4E00-9FFF; /* CJK统一汉字 */
}

/* 动态字体应用 */
.pregenerated-font {
  font-family: 'PreGeneratedCJK', 'PingFang SC', 'Hiragino Sans GB', 
               'Microsoft YaHei', 'Source Han Sans SC', 'Noto Sans CJK SC', 
               system-ui, sans-serif !important;
}

/* 全局应用预生成字体 */
body, html, * {
  font-family: 'PreGeneratedCJK', 'PingFang SC', 'Hiragino Sans GB',
               'Microsoft YaHei', 'Source Han Sans SC', 'Noto Sans CJK SC',
               system-ui, sans-serif !important;
}
''';

    final cssFile = File('$webOutputDir/pregenerated-fonts.css');
    await cssFile.writeAsString(cssContent);
    
    print('   生成CSS: pregenerated-fonts.css');
  }

  /// 生成模拟字体数据
  List<int> _generateMockFontData(String chars) {
    // 这里应该使用真实的字体切片工具（如fonttools, pyftsubset等）
    // 现在只是生成模拟数据
    final mockData = 'WOFF2_FONT_DATA_FOR_CHARS:$chars';
    return utf8.encode(mockData);
  }
}

// 使用CharacterExtractor的公共访问器

/// 主函数
Future<void> main(List<String> args) async {
  print('🎯 Flutter Web预生成字体工具');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  
  final outputDir = args.isNotEmpty ? args[0] : './font-subset-server/character-sets';
  final webOutputDir = args.length > 1 ? args[1] : './web';
  
  final generator = FontPreGenerator(
    outputDir: outputDir,
    webOutputDir: webOutputDir,
  );
  
  await generator.generateFontSlices();
  
  print('\n📋 使用方法:');
  print('   1. 在HTML中引入: <script src="pregenerated-fonts.js"></script>');
  print('   2. 在HTML中引入: <link rel="stylesheet" href="pregenerated-fonts.css">');
  print('   3. 字体会自动预加载和应用');
  print('\n🔄 建议在代码更新后重新运行此工具');
}