#!/usr/bin/env python3
"""
简单的字体文件HTTP服务器
提供预生成的WOFF2字体文件
"""

import os
import http.server
import socketserver
from pathlib import Path

class FontHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=str(Path(__file__).parent.parent / "web"), **kwargs)
    
    def end_headers(self):
        # 添加CORS头
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        
        # 字体文件缓存头
        if self.path.endswith('.woff2'):
            self.send_header('Content-Type', 'font/woff2')
            self.send_header('Cache-Control', 'public, max-age=31536000')  # 1年缓存
        
        super().end_headers()
    
    def do_OPTIONS(self):
        self.send_response(200)
        self.end_headers()

def main():
    PORT = 7001  # 字体专用端口
    
    with socketserver.TCPServer(("", PORT), FontHandler) as httpd:
        print(f"字体服务器启动在端口 {PORT}")
        print(f"字体文件路径: http://localhost:{PORT}/fonts/pregenerated/")
        
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\n服务器已停止")

if __name__ == "__main__":
    main()