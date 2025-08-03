#!/usr/bin/env python3
"""
集成HTTPS服务器 - 同时提供Flutter Web应用和字体服务
解决Safari SSL问题，避免混合内容错误
"""

import http.server
import ssl
import socketserver
import os
import sys
import json
import urllib.parse
from pathlib import Path

class IntegratedHTTPSHandler(http.server.SimpleHTTPRequestHandler):
    """集成的HTTPS请求处理器，支持字体服务"""
    
    def __init__(self, *args, **kwargs):
        # 设置字体目录 - 使用当前工作目录下的fonts目录
        self.font_base_path = Path.cwd() / "fonts"
        super().__init__(*args, **kwargs)
    
    def do_GET(self):
        """处理GET请求"""
        parsed_path = urllib.parse.urlparse(self.path)
        path = parsed_path.path
        
        # 处理字体服务请求 - 支持 /fonts/ 和 fonts/ 两种路径
        if path.startswith('/fonts/') or path.startswith('fonts/'):
            self.handle_font_request(path)
        # 处理CORS预检请求
        elif path.startswith('/api/'):
            self.handle_api_request(path)
        else:
            # 默认静态文件服务
            super().do_GET()
    
    def handle_font_request(self, path):
        """处理字体文件请求"""
        try:
            # 移除 fonts/ 或 /fonts/ 前缀
            if path.startswith('/fonts/'):
                font_path = path[7:]  # 移除 '/fonts/'
            elif path.startswith('fonts/'):
                font_path = path[6:]  # 移除 'fonts/'
            else:
                font_path = path
            
            # 构建完整的字体文件路径
            full_path = self.font_base_path / font_path
            
            # 检查文件是否存在
            if not full_path.exists() or not full_path.is_file():
                self.send_error(404, f"Font file not found: {font_path}")
                return
            
            # 确定MIME类型
            mime_type = self.get_font_mime_type(full_path.suffix)
            
            # 发送响应头
            self.send_response(200)
            self.send_header('Content-Type', mime_type)
            self.send_header('Access-Control-Allow-Origin', '*')
            self.send_header('Access-Control-Allow-Methods', 'GET, OPTIONS')
            self.send_header('Access-Control-Allow-Headers', 'Content-Type')
            self.send_header('Cache-Control', 'public, max-age=31536000')  # 1年缓存
            self.end_headers()
            
            # 发送文件内容
            with open(full_path, 'rb') as f:
                self.wfile.write(f.read())
                
            print(f"✅ 字体文件服务: {font_path}")
            
        except Exception as e:
            print(f"❌ 字体文件服务错误: {e}")
            self.send_error(500, f"Internal server error: {str(e)}")
    
    def handle_api_request(self, path):
        """处理API请求"""
        # 简单的API响应示例
        self.send_response(200)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Access-Control-Allow-Origin', '*')
        self.end_headers()
        
        response = {"status": "ok", "message": "API endpoint"}
        self.wfile.write(json.dumps(response).encode())
    
    def get_font_mime_type(self, extension):
        """获取字体文件的MIME类型"""
        mime_types = {
            '.woff': 'font/woff',
            '.woff2': 'font/woff2',
            '.ttf': 'font/ttf',
            '.otf': 'font/otf',
            '.eot': 'application/vnd.ms-fontobject',
            '.svg': 'image/svg+xml'
        }
        return mime_types.get(extension.lower(), 'application/octet-stream')
    
    def do_OPTIONS(self):
        """处理CORS预检请求"""
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.end_headers()

def create_self_signed_cert():
    """创建自签名证书"""
    try:
        import subprocess
        
        # 检查是否已存在证书
        if os.path.exists('server.crt') and os.path.exists('server.key'):
            print("✅ 发现现有证书文件")
            return True
            
        print("🔐 创建自签名证书...")
        
        # 创建自签名证书
        cmd = [
            'openssl', 'req', '-x509', '-newkey', 'rsa:4096', 
            '-keyout', 'server.key', '-out', 'server.crt', 
            '-days', '365', '-nodes', '-subj', 
            '/C=US/ST=State/L=City/O=Organization/CN=localhost'
        ]
        
        result = subprocess.run(cmd, capture_output=True, text=True)
        
        if result.returncode == 0:
            print("✅ 证书创建成功")
            return True
        else:
            print(f"❌ 证书创建失败: {result.stderr}")
            return False
            
    except Exception as e:
        print(f"❌ 证书创建异常: {e}")
        return False

def start_integrated_server(port=8447, directory=None):
    """启动集成HTTPS服务器"""
    
    if directory:
        os.chdir(directory)
        print(f"📁 切换到目录: {directory}")
    
    # 创建证书
    if not create_self_signed_cert():
        print("❌ 无法创建证书，退出")
        return
    
    # 创建服务器
    with socketserver.TCPServer(("", port), IntegratedHTTPSHandler) as httpd:
        print(f"🚀 启动集成HTTPS服务器在端口 {port}")
        print(f"📂 服务目录: {os.getcwd()}")
        print(f"🔤 字体服务路径: /fonts/")
        
        # 配置SSL
        context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
        context.load_cert_chain('server.crt', 'server.key')
        httpd.socket = context.wrap_socket(httpd.socket, server_side=True)
        
        print(f"🌐 访问地址: https://localhost:{port}")
        print(f"🔤 字体服务: https://localhost:{port}/fonts/")
        print("⚠️  浏览器会显示安全警告，请点击'高级'然后'继续访问'")
        print("🛑 按 Ctrl+C 停止服务器")
        
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\n🛑 服务器已停止")

if __name__ == "__main__":
    # 默认参数
    port = 8447
    directory = None
    
    # 解析命令行参数
    if len(sys.argv) > 1:
        try:
            port = int(sys.argv[1])
        except ValueError:
            directory = sys.argv[1]
            
    if len(sys.argv) > 2:
        try:
            port = int(sys.argv[2])
        except ValueError:
            pass
    
    start_integrated_server(port, directory)