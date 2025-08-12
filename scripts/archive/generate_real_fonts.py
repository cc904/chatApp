#!/usr/bin/env python3
"""
真实字体子集生成工具
使用fonttools生成真实的WOFF2字体文件
"""

import os
import json
import sys
from pathlib import Path
from fontTools import subset
from fontTools.ttLib import TTFont

def load_extracted_characters():
    """加载提取的字符数据"""
    script_dir = Path(__file__).parent
    char_file = script_dir / "extracted_characters.json"
    
    if not char_file.exists():
        print(f"未找到字符文件: {char_file}")
        return []
    
    with open(char_file, 'r', encoding='utf-8') as f:
        data = json.load(f)
        return data.get('all_chars', [])

def find_system_font():
    """查找可用的系统中文字体"""
    font_paths = [
        "/System/Library/Fonts/PingFang.ttc",
        "/System/Library/Fonts/Hiragino Sans GB.ttc",
        "/System/Library/Fonts/STHeiti Light.ttc",
        "/System/Library/Fonts/STHeiti Medium.ttc"
    ]
    
    for font_path in font_paths:
        if os.path.exists(font_path):
            print(f"找到字体: {font_path}")
            return font_path
    
    print("未找到可用的系统字体")
    return None

def create_font_subset(font_path, characters, output_path):
    """创建字体子集"""
    try:
        # 创建子集选项
        options = subset.Options()
        options.flavor = 'woff2'  # 输出WOFF2格式
        options.with_zopfli = True  # 使用zopfli压缩
        options.desubroutinize = True  # 优化子例程
        options.layout_features = ['*']  # 保留所有布局特性
        
        # 加载字体
        font = TTFont(font_path, fontNumber=0)  # 对于.ttc文件，使用第一个字体
        
        # 创建字符集合
        char_set = set(characters)
        
        # 创建子集器
        subsetter = subset.Subsetter(options=options)
        subsetter.populate(unicodes=[ord(c) for c in char_set])
        
        # 执行子集化
        subsetter.subset(font)
        
        # 保存到WOFF2文件
        font.flavor = 'woff2'
        font.save(output_path)
        
        print(f"成功生成字体子集: {output_path}")
        print(f"包含字符数: {len(char_set)}")
        
        return True
        
    except Exception as e:
        print(f"生成字体子集失败: {e}")
        return False

def main():
    """主函数"""
    print("开始生成真实的WOFF2字体文件...")
    
    # 加载字符数据
    all_chars = load_extracted_characters()
    if not all_chars:
        print("未找到字符数据，请先运行 extract_characters.dart")
        return
    
    print(f"共提取到 {len(all_chars)} 个字符")
    
    # 查找系统字体
    font_path = find_system_font()
    if not font_path:
        return
    
    # 创建输出目录
    output_dir = Path(__file__).parent.parent / "web" / "fonts" / "pregenerated"
    output_dir.mkdir(parents=True, exist_ok=True)
    
    # 分割字符到多个文件
    chars_per_file = 100
    total_files = (len(all_chars) + chars_per_file - 1) // chars_per_file
    
    print(f"将生成 {total_files} 个字体文件")
    
    # 生成字体文件
    success_count = 0
    for i in range(total_files):
        start_idx = i * chars_per_file
        end_idx = min(start_idx + chars_per_file, len(all_chars))
        chars_slice = all_chars[start_idx:end_idx]
        
        if not chars_slice:
            continue
            
        output_file = output_dir / f"slice_{i+1:03d}.woff2"
        print(f"生成第 {i+1}/{total_files} 个文件...")
        
        if create_font_subset(font_path, chars_slice, str(output_file)):
            success_count += 1
        
    print(f"\n生成完成! 成功: {success_count}/{total_files}")
    
    # 更新manifest文件
    update_manifest(output_dir, all_chars, chars_per_file)

def update_manifest(output_dir, all_chars, chars_per_file):
    """更新字体清单文件"""
    manifest = {
        "version": "1.0.0",
        "generated_at": "2025-07-31T23:30:00.000Z",
        "font_family": "PreGeneratedCJK",
        "format": "woff2",
        "chars_per_file": chars_per_file,
        "total_chars": len(all_chars),
        "files": []
    }
    
    total_files = (len(all_chars) + chars_per_file - 1) // chars_per_file
    
    for i in range(total_files):
        start_idx = i * chars_per_file
        end_idx = min(start_idx + chars_per_file, len(all_chars))
        chars_slice = all_chars[start_idx:end_idx]
        
        file_info = {
            "filename": f"slice_{i+1:03d}.woff2",
            "chars": chars_slice,
            "char_count": len(chars_slice)
        }
        manifest["files"].append(file_info)
    
    manifest_file = output_dir / "manifest.json"
    with open(manifest_file, 'w', encoding='utf-8') as f:
        json.dump(manifest, f, ensure_ascii=False, indent=2)
    
    print(f"更新清单文件: {manifest_file}")

if __name__ == "__main__":
    main()