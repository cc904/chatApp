#!/usr/bin/env python3
"""
修复JavaScript语法错误
重新生成正确的字符映射文件
"""

import json
from pathlib import Path

def load_manifest():
    """加载字体清单"""
    script_dir = Path(__file__).parent
    manifest_file = script_dir.parent / "web" / "fonts" / "pregenerated" / "manifest.json"
    
    with open(manifest_file, 'r', encoding='utf-8') as f:
        return json.load(f)

def generate_fixed_js(manifest):
    """生成修复后的JavaScript文件"""
    
    # 创建字符到文件的映射
    char_to_file = {}
    for file_info in manifest["files"]:
        filename = file_info["filename"]
        chars = file_info["chars"]
        for char in chars:
            char_to_file[char] = filename
    
    js_content = f'''// 预生成字体字符映射表
// 自动生成，请勿手动编辑
// 修复语法错误版本
// 生成时间: 2025-07-31T23:59:00.000Z

class PreGeneratedFonts {{
  constructor() {{
    this.baseUrl = 'http://localhost:7001/fonts/pregenerated/';
    this.fontFamily = 'PreGeneratedCJK';
    this.loadedFiles = new Set();
    this.loadingPromises = new Map();
    
    // 字符到文件映射表
    this.charToFile = new Map([
'''
    
    # 添加字符映射，确保正确转义
    char_entries = []
    for char, filename in sorted(char_to_file.items()):
        # 转义特殊字符
        if char == '"':
            escaped_char = '\\"'
        elif char == '\\':
            escaped_char = '\\\\'
        elif char == '\n':
            escaped_char = '\\n'
        elif char == '\r':
            escaped_char = '\\r'
        elif char == '\t':
            escaped_char = '\\t'
        else:
            escaped_char = char
        
        char_entries.append(f'      ["{escaped_char}", "{filename}"]')
    
    js_content += ',\n'.join(char_entries)
    
    js_content += '''
    ]);
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
}

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
    
    return js_content

def main():
    """主函数"""
    print("修复JavaScript语法错误...")
    
    manifest = load_manifest()
    js_content = generate_fixed_js(manifest)
    
    # 保存修复后的文件
    script_dir = Path(__file__).parent
    js_file = script_dir.parent / "web" / "pregenerated-fonts.js"
    
    with open(js_file, 'w', encoding='utf-8') as f:
        f.write(js_content)
    
    print(f"JavaScript文件已修复: {js_file}")
    
    # 验证语法
    import subprocess
    try:
        subprocess.run(['node', '-c', str(js_file)], check=True, capture_output=True)
        print("✅ JavaScript语法验证通过")
    except subprocess.CalledProcessError as e:
        print(f"❌ 语法验证失败: {e.stderr.decode()}")

if __name__ == "__main__":
    main()