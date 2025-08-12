#!/usr/bin/env python3
"""
HTTPS字体文件服务器
提供预生成的WOFF2字体文件，支持HTTPS以避免混合内容错误
"""

import os
import http.server
import ssl
import socketserver
from pathlib import Path
import subprocess

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

def create_self_signed_cert():
    """创建自签名证书"""
    try:
        # 检查是否已存在证书
        if os.path.exists('font_server.crt') and os.path.exists('font_server.key'):
            print("✅ 发现现有字体服务器证书文件")
            return True
            
        print("🔐 创建字体服务器自签名证书...")
        
        # 创建自签名证书
        cmd = [
            'openssl', 'req', '-x509', '-newkey', 'rsa:4096', 
            '-keyout', 'font_server.key', '-out', 'font_server.crt', 
            '-days', '365', '-nodes', '-subj', 
            '/C=US/ST=State/L=City/O=Organization/CN=localhost'
        ]
        
        result = subprocess.run(cmd, capture_output=True, text=True)
        
        if result.returncode == 0:
            print("✅ 字体服务器证书创建成功")
            return True
        else:
            print(f"❌ 字体服务器证书创建失败: {result.stderr}")
            return False
            
    except Exception as e:
        print(f"❌ 字体服务器证书创建异常: {e}")
        return False

def main():
    PORT = 7443  # HTTPS字体专用端口
    
    # 创建证书
    if not create_self_signed_cert():
        print("❌ 无法创建证书，退出")
        return
    
    # 创建服务器
    with socketserver.TCPServer(("", PORT), FontHandler) as httpd:
        print(f"🚀 HTTPS字体服务器启动在端口 {PORT}")
        print(f"📂 字体文件路径: https://localhost:{PORT}/fonts/pregenerated/")
        
        # 配置SSL
        context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
        context.load_cert_chain('font_server.crt', 'font_server.key')
        httpd.socket = context.wrap_socket(httpd.socket, server_side=True)
        
        print("⚠️  浏览器会显示安全警告，请点击'高级'然后'继续访问'")
        print("🛑 按 Ctrl+C 停止服务器")
        
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\n🛑 字体服务器已停止")

if __name__ == "__main__":
    main()