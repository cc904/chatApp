#!/bin/bash

# 域名加密脚本
# 将login_domains.json的完整配置加密到assets/encrypted_domains.dat
# 应用运行时根据Debug/Release模式自动选择对应环境

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_info() {
    echo -e "${CYAN}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_header() {
    echo -e "${PURPLE}=== $1 ===${NC}"
}

# 显示配置信息
show_config_info() {
    print_info "读取域名配置..."
    if command -v jq >/dev/null 2>&1; then
        local dev_domains
        local prod_domains
        dev_domains=$(jq -r '.development[]' login_domains.json 2>/dev/null || echo "无法读取")
        prod_domains=$(jq -r '.production[]' login_domains.json 2>/dev/null || echo "无法读取")
        
        echo -e "${WHITE}📋 完整配置将被加密:${NC}"
        echo -e "   🌐 Development: $dev_domains"
        echo -e "   🔒 Production:  $prod_domains"
        echo -e "${CYAN}💡 应用运行时将根据Debug/Release模式自动选择对应环境${NC}"
    else
        print_warning "未安装jq，无法预览配置内容"
        print_info "将加密完整的development和production配置"
    fi
}

# 主函数
main() {
    print_header "Flutter域名加密工具"
    
    # 检查是否在项目根目录
    if [[ ! -f "pubspec.yaml" ]]; then
        print_error "请在Flutter项目根目录下运行此脚本"
        exit 1
    fi
    
    # 检查依赖文件
    if [[ ! -f "login_domains.json" ]]; then
        print_error "找不到login_domains.json文件"
        exit 1
    fi
    
    if [[ ! -f "scripts/auto_encrypt_domains.dart" ]]; then
        print_error "找不到加密脚本: scripts/auto_encrypt_domains.dart"
        exit 1
    fi
    
    print_info "当前时间: $(date '+%Y-%m-%d %H:%M:%S')"
    
    # 显示配置信息
    show_config_info
    
    # 确保assets目录存在
    if [[ ! -d "assets" ]]; then
        mkdir -p assets
        print_success "创建assets目录"
    fi
    
    # 运行Dart加密脚本
    print_info "运行加密脚本..."
    if dart scripts/auto_encrypt_domains.dart; then
        print_success "域名加密完成！"
        
        # 显示输出文件信息
        if [[ -f "assets/encrypted_domains.dat" ]]; then
            local file_size
            file_size=$(wc -c < assets/encrypted_domains.dat)
            print_info "输出文件: assets/encrypted_domains.dat (${file_size} 字节)"
            
            # 显示文件的前几个字符（Base64开头）
            local preview
            preview=$(head -c 50 assets/encrypted_domains.dat)
            print_info "文件预览: ${preview}..."
        fi
        
        # 提示信息
        echo ""
        echo -e "${WHITE}💡 应用运行机制:${NC}"
        echo "   - Debug模式: 自动使用development环境域名"
        echo "   - Release模式: 自动使用production环境域名"
        echo ""
        echo -e "${GREEN}🚀 现在可以运行应用，它将根据构建模式自动选择对应环境的域名配置${NC}"
        
    else
        print_error "加密失败"
        exit 1
    fi
}

# 运行主函数
main