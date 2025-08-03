#!/usr/bin/env python3
"""
HTTPS服务器脚本 - 解决Safari SSL问题
为Flutter Web应用提供HTTPS服务，避免混合内容错误
"""

import http.server
import ssl
import socketserver
import os
import sys
from pathlib import Path

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

def start_https_server(port=8443, directory=None):
    """启动HTTPS服务器"""
    
    if directory:
        os.chdir(directory)
        print(f"📁 切换到目录: {directory}")
    
    # 创建证书
    if not create_self_signed_cert():
        print("❌ 无法创建证书，退出")
        return
    
    # 创建HTTP处理器
    handler = http.server.SimpleHTTPRequestHandler
    
    # 创建服务器
    with socketserver.TCPServer(("", port), handler) as httpd:
        print(f"🚀 启动HTTPS服务器在端口 {port}")
        print(f"📂 服务目录: {os.getcwd()}")
        
        # 配置SSL
        context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
        context.load_cert_chain('server.crt', 'server.key')
        httpd.socket = context.wrap_socket(httpd.socket, server_side=True)
        
        print(f"🌐 访问地址: https://localhost:{port}")
        print("⚠️  浏览器会显示安全警告，请点击'高级'然后'继续访问'")
        print("🛑 按 Ctrl+C 停止服务器")
        
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\n🛑 服务器已停止")

if __name__ == "__main__":
    # 默认参数
    port = 8443
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
    
    start_https_server(port, directory)