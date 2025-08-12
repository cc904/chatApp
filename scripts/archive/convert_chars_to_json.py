#!/usr/bin/env python3
"""
将字符文件转换为JSON格式
"""

import json
import re
from pathlib import Path

def extract_chars_from_file(file_path):
    """从文件中提取字符"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # 移除注释行和空行
        lines = [line.strip() for line in content.split('\n') 
                if line.strip() and not line.strip().startswith('//')]
        
        # 合并所有行
        text = ''.join(lines)
        
        # 提取所有有效字符（去除控制字符和无效字符）
        chars = set()
        for char in text:
            # 只保留可显示的字符，排除控制字符
            if ord(char) >= 32 and ord(char) != 127:  # 可打印ASCII和Unicode字符
                # 排除明显的乱码字符
                if ord(char) < 0xFFFE:  # 排除Unicode私用区和特殊字符
                    chars.add(char)
        
        # 转换为列表并排序
        char_list = sorted(list(chars))
        
        # 移除明显的乱码和特殊字符
        filtered_chars = []
        for char in char_list:
            # 保留基本的ASCII、中日韩文字、常用符号
            code = ord(char)
            if (32 <= code <= 126 or  # 基本ASCII
                0x4E00 <= code <= 0x9FFF or  # CJK统一汉字
                0x3400 <= code <= 0x4DBF or  # CJK扩展A
                0x3000 <= code <= 0x303F or  # CJK符号和标点
                0xFF00 <= code <= 0xFFEF or  # 全角ASCII
                code in [0x2022, 0x2014, 0x2013, 0x2019, 0x201C, 0x201D]):  # 常用标点
                filtered_chars.append(char)
        
        return filtered_chars
        
    except Exception as e:
        print(f"读取文件失败: {e}")
        return []

def main():
    """主函数"""
    script_dir = Path(__file__).parent
    char_file = script_dir.parent / "font-subset-server" / "character-sets" / "all_chars.txt"
    
    if not char_file.exists():
        print(f"字符文件不存在: {char_file}")
        return
    
    print("提取字符...")
    chars = extract_chars_from_file(char_file)
    
    if not chars:
        print("未提取到有效字符")
        return
    
    print(f"提取到 {len(chars)} 个有效字符")
    
    # 创建JSON数据
    data = {
        "version": "1.0.0",
        "generated_at": "2025-07-31T23:30:00.000Z",
        "total_chars": len(chars),
        "all_chars": chars
    }
    
    # 保存JSON文件
    output_file = script_dir / "extracted_characters.json"
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    
    print(f"JSON文件已保存: {output_file}")
    
    # 显示一些示例字符
    print(f"示例字符: {''.join(chars[:50])}")

if __name__ == "__main__":
    main()