#!/usr/bin/env python3
"""
简单HTTP服务器 - 用于测试Safari兼容性
避免HTTPS证书问题
"""

import http.server
import socketserver
import os
import sys
from pathlib import Path

class SimpleHTTPHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=os.getcwd(), **kwargs)
    
    def end_headers(self):
        # 添加CORS头
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', '*')
        # 添加缓存控制
        self.send_header('Cache-Control', 'no-cache, no-store, must-revalidate')
        super().end_headers()
    
    def log_message(self, format, *args):
        print(f"📝 {self.address_string()} - {format % args}")

def start_server(port, directory):
    """启动HTTP服务器"""
    # 切换到指定目录
    if directory:
        target_dir = Path(directory).resolve()
        if target_dir.exists():
            os.chdir(target_dir)
            print(f"📁 切换到目录: {target_dir}")
        else:
            print(f"❌ 目录不存在: {target_dir}")
            return
    
    try:
        with socketserver.TCPServer(("", port), SimpleHTTPHandler) as httpd:
            print(f"🚀 启动HTTP服务器在端口 {port}")
            print(f"📂 服务目录: {os.getcwd()}")
            print(f"🌐 访问地址: http://localhost:{port}")
            print(f"🛑 按 Ctrl+C 停止服务器")
            httpd.serve_forever()
    except KeyboardInterrupt:
        print("\n🛑 服务器已停止")
    except OSError as e:
        if e.errno == 48:  # Address already in use
            print(f"❌ 端口 {port} 已被占用，请使用其他端口")
        else:
            print(f"❌ 启动服务器失败: {e}")

if __name__ == "__main__":
    port = int(sys.argv[2]) if len(sys.argv) > 2 else 8080
    directory = sys.argv[1] if len(sys.argv) > 1 else None
    
    start_server(port, directory)