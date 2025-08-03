#!/usr/bin/env python3
"""
更新字符映射表以匹配新生成的字体文件
"""

import json
from pathlib import Path

def generate_char_mapping():
    """从manifest生成字符映射表"""
    script_dir = Path(__file__).parent
    manifest_file = script_dir.parent / "web" / "fonts" / "pregenerated" / "manifest.json"
    
    if not manifest_file.exists():
        print(f"未找到manifest文件: {manifest_file}")
        return None
    
    with open(manifest_file, 'r', encoding='utf-8') as f:
        manifest = json.load(f)
    
    # 创建字符到文件的映射
    char_to_file = {}
    
    for file_info in manifest["files"]:
        filename = file_info["filename"]
        chars = file_info["chars"]
        
        for char in chars:
            char_to_file[char] = filename
    
    return char_to_file, manifest

def update_js_file(char_to_file, manifest):
    """更新JavaScript字符映射文件"""
    script_dir = Path(__file__).parent
    js_file = script_dir.parent / "web" / "pregenerated-fonts.js"
    
    # 构建JavaScript内容
    js_content = f'''// 预生成字体字符映射表
// 自动生成，请勿手动编辑
// 生成时间: 2025-07-31T23:52:00.000Z
// 基于字体: {manifest.get("font_family", "PreGeneratedCJK")}
// 字体格式: {manifest.get("format", "woff2")}
// 总字符数: {manifest.get("total_chars", 0)}

class PreGeneratedFonts {{
  constructor() {{
    this.baseUrl = '/fonts/pregenerated/';
    this.fontFamily = '{manifest.get("font_family", "PreGeneratedCJK")}';
    this.loadedFiles = new Set();
    this.loadingPromises = new Map();
    
    // 字符到文件映射表
    this.charToFile = new Map([
'''
    
    # 添加字符映射
    for char, filename in sorted(char_to_file.items()):
        # 转义特殊字符
        escaped_char = char.replace('\\', '\\\\').replace('"', '\\"').replace('\n', '\\n').replace('\r', '\\r')
        js_content += f'      ["{escaped_char}", "{filename}"],\n'
    
    js_content += '''    ]);
  }

  // 获取字符对应的字体文件
  getFileForChar(char) {
    return this.charToFile.get(char);
  }

  // 预加载指定字符的字体文件
  async preloadChars(chars) {
    const filesToLoad = new Set();
    
    // 收集需要加载的文件
    for (const char of chars) {
      const filename = this.getFileForChar(char);
      if (filename && !this.loadedFiles.has(filename)) {
        filesToLoad.add(filename);
      }
    }
    
    // 并行加载字体文件
    const loadPromises = Array.from(filesToLoad).map(filename => 
      this.loadFontFile(filename)
    );
    
    await Promise.all(loadPromises);
  }

  // 加载单个字体文件
  async loadFontFile(filename) {
    if (this.loadedFiles.has(filename)) {
      return; // 已加载
    }
    
    if (this.loadingPromises.has(filename)) {
      return this.loadingPromises.get(filename); // 正在加载
    }
    
    const loadPromise = this._doLoadFont(filename);
    this.loadingPromises.set(filename, loadPromise);
    
    try {
      await loadPromise;
      this.loadedFiles.add(filename);
      console.log(`字体文件加载完成: ${filename}`);
    } catch (error) {
      console.error(`字体文件加载失败: ${filename}`, error);
    } finally {
      this.loadingPromises.delete(filename);
    }
  }

  // 实际加载字体文件
  async _doLoadFont(filename) {
    const url = this.baseUrl + filename;
    
    try {
      const response = await fetch(url);
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      }
      
      const fontData = await response.arrayBuffer();
      const fontFace = new FontFace(this.fontFamily, fontData);
      
      await fontFace.load();
      document.fonts.add(fontFace);
      
      return fontFace;
    } catch (error) {
      throw new Error(`加载字体文件失败 ${filename}: ${error.message}`);
    }
  }

  // 预加载常用字符的字体
  async preloadCommonChars() {
    // 获取前100个最常用的字符
    const commonChars = Array.from(this.charToFile.keys()).slice(0, 100);
    await this.preloadChars(commonChars);
  }

  // 获取统计信息
  getStats() {
    return {
      totalChars: this.charToFile.size,
      loadedFiles: this.loadedFiles.size,
      loadingFiles: this.loadingPromises.size
    };
  }
}}

// 创建全局实例
window.preGeneratedFonts = new PreGeneratedFonts();

// 页面加载完成后预加载常用字符
document.addEventListener('DOMContentLoaded', async () => {
  try {
    console.log('开始预加载常用字符字体...');
    await window.preGeneratedFonts.preloadCommonChars();
    console.log('常用字符字体预加载完成');
  } catch (error) {
    console.error('字体预加载失败:', error);
  }
});
'''
    
    with open(js_file, 'w', encoding='utf-8') as f:
        f.write(js_content)
    
    print(f"JavaScript文件已更新: {js_file}")
    print(f"映射了 {len(char_to_file)} 个字符")

def update_css_file(manifest):
    """更新CSS文件启用字体加载"""
    script_dir = Path(__file__).parent
    css_file = script_dir.parent / "web" / "pregenerated-fonts.css"
    
    css_content = f'''/* 预生成字体CSS */
/* 自动生成，请勿手动编辑 */
/* 生成时间: 2025-07-31T23:52:00.000Z */
/* 基于字体: {manifest.get("font_family", "PreGeneratedCJK")} */
/* 总字符数: {manifest.get("total_chars", 0)} */

/* 预生成字体定义 */
@font-face {{
  font-family: '{manifest.get("font_family", "PreGeneratedCJK")}';
  font-style: normal;
  font-weight: 400;
  font-display: swap;
  src: local(''),
       url('/fonts/pregenerated/slice_001.woff2') format('woff2');
  unicode-range: U+0020-007F, U+4E00-9FFF; /* ASCII + CJK */
}}

/* 字体应用类 */
.pregenerated-font {{
  font-family: '{manifest.get("font_family", "PreGeneratedCJK")}', 
               'PingFang SC', 'Hiragino Sans GB', 
               'Microsoft YaHei', 'Source Han Sans SC', 'Noto Sans CJK SC', 
               system-ui, sans-serif !important;
}}

/* 全局字体应用 */
body, html {{
  font-family: '{manifest.get("font_family", "PreGeneratedCJK")}',
               'PingFang SC', 'Hiragino Sans GB',
               'Microsoft YaHei', 'Source Han Sans SC', 'Noto Sans CJK SC',
               system-ui, sans-serif !important;
}}

/* Flutter应用字体 */
flt-glass-pane * {{
  font-family: '{manifest.get("font_family", "PreGeneratedCJK")}',
               'PingFang SC', 'Hiragino Sans GB',
               'Microsoft YaHei', 'Source Han Sans SC', 'Noto Sans CJK SC',
               system-ui, sans-serif !important;
}}
'''
    
    with open(css_file, 'w', encoding='utf-8') as f:
        f.write(css_content)
    
    print(f"CSS文件已更新: {css_file}")

def main():
    """主函数"""
    print("更新字符映射表...")
    
    char_to_file, manifest = generate_char_mapping()
    if not char_to_file:
        return
    
    update_js_file(char_to_file, manifest)
    update_css_file(manifest)
    
    print(f"映射更新完成! 总计 {len(char_to_file)} 个字符映射到 {len(manifest['files'])} 个字体文件")

if __name__ == "__main__":
    main()