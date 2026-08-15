#!/data/data/com.termux/files/usr/bin/bash

# ============================================================
# Claude Code for Termux 安装脚本
# 版本: 1.0.0
# 作者: 基于社区方法整理
# 适用: Termux on Android (ARM64)
# ============================================================

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 版本配置
CLAUDE_VERSION="2.1.233"

# 打印函数
print_header() {
    echo -e "${BLUE}"
    echo "============================================================"
    echo "$1"
    echo "============================================================"
    echo -e "${NC}"
}

print_step() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_info() {
    echo -e "${YELLOW}[i]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

# 检查架构
check_architecture() {
    ARCH=$(uname -m)
    if [ "$ARCH" != "aarch64" ]; then
        print_error "不支持的架构: $ARCH"
        print_error "此脚本仅支持 ARM64 (aarch64) 设备"
        exit 1
    fi
    print_step "架构检查通过: $ARCH"
}

# 步骤1: 安装依赖
install_dependencies() {
    print_header "步骤 1/5: 安装依赖"
    
    print_info "更新软件源..."
    pkg update -y > /dev/null 2>&1
    
    if ! command -v node &> /dev/null; then
        print_info "安装 Node.js LTS..."
        pkg install nodejs-lts -y
    else
        print_step "Node.js 已安装: $(node -v)"
    fi

    if ! command -v rg &> /dev/null; then
        print_info "安装 ripgrep..."
        pkg install ripgrep -y
    else
        print_step "ripgrep 已安装"
    fi

    if ! dpkg -l | grep -q glibc-repo; then
        print_info "安装 glibc-repo..."
        pkg install glibc-repo -y
        print_info "更新软件源..."
        pkg update -y > /dev/null 2>&1
    else
        print_step "glibc-repo 已安装"
    fi

    if ! command -v grun &> /dev/null; then
        print_info "安装 glibc-runner（核心组件）..."
        pkg install glibc-runner -y
    else
        print_step "glibc-runner 已安装"
    fi
    
    print_step "所有依赖安装完成"
    echo ""
}

# 步骤2: 安装 Claude Code
install_claude() {
    print_header "步骤 2/5: 安装 Claude Code v${CLAUDE_VERSION}"
    
    print_info "安装主包..."
    npm install -g @anthropic-ai/claude-code@${CLAUDE_VERSION}
    
    print_info "安装 Linux ARM64 二进制（使用 --force 跳过平台检查）..."
    npm install -g --force @anthropic-ai/claude-code-linux-arm64@${CLAUDE_VERSION}
    
    print_step "Claude Code 安装完成"
    echo ""
}

# 步骤3: 创建启动脚本
create_launcher() {
    print_header "步骤 3/5: 创建启动脚本"
    
    mkdir -p ~/.local/bin
    
    cat > ~/.local/bin/claude << 'LAUNCHER_EOF'
#!/data/data/com.termux/files/usr/bin/bash

set -euo pipefail

# 路径配置
prefix_dir="/data/data/com.termux/files/usr"
binary="$prefix_dir/lib/node_modules/@anthropic-ai/claude-code-linux-arm64/claude"

# 加载私有环境变量（如果存在）
if [ -f "$HOME/.config/claude-code/credentials.env" ]; then
  set -a
  . "$HOME/.config/claude-code/credentials.env"
  set +a
fi

# 使用 grun 启动（glibc 兼容层）
exec "$prefix_dir/bin/grun" "$binary" "$@"
LAUNCHER_EOF

    chmod +x ~/.local/bin/claude
    print_step "启动脚本创建完成: ~/.local/bin/claude"
    echo ""
}

# 步骤4: 配置环境
setup_environment() {
    print_header "步骤 4/5: 配置环境"
    
    # 添加到 PATH
    if ! grep -q '.local/bin' ~/.bashrc 2>/dev/null; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
        print_step "已将 ~/.local/bin 添加到 PATH"
    else
        print_step "PATH 已配置"
    fi
    
    # 加载新的 PATH
    export PATH="$HOME/.local/bin:$PATH"
    
    echo ""
}

# 步骤5: 创建配置模板
create_config_template() {
    print_header "步骤 5/5: 创建配置模板"
    
    mkdir -p ~/.config/claude-code
    
    # 创建配置说明文件
    cat > ~/.config/claude-code/README.txt << 'README_EOF'
Claude Code 配置说明
===================

如果你使用第三方 API 端点，需要创建 credentials.env 文件。

1. 创建文件：
   nano ~/.config/claude-code/credentials.env

2. 填入以下内容：
   ANTHROPIC_AUTH_TOKEN='你的-API-KEY'
   ANTHROPIC_BASE_URL='https://你的端点.com'

3. 设置权限：
   chmod 600 ~/.config/claude-code/credentials.env

如果使用官方 API，运行：
   claude login
README_EOF
    
    chmod 700 ~/.config/claude-code
    print_step "配置目录创建完成: ~/.config/claude-code"
    print_step "配置说明: ~/.config/claude-code/README.txt"
    echo ""
}

# 验证安装
verify_installation() {
    print_header "验证安装"
    
    if command -v claude &> /dev/null; then
        VERSION=$(claude --version 2>&1 || echo "无法获取版本")
        print_step "Claude Code 已成功安装！"
        print_info "版本: $VERSION"
    else
        print_error "安装验证失败"
        exit 1
    fi
    
    echo ""
}

# 打印使用说明
print_usage() {
    print_header "安装完成！"
    
    echo -e "${GREEN}下一步操作：${NC}"
    echo ""
    echo "1. 重新加载环境变量："
    echo "   ${YELLOW}source ~/.bashrc${NC}"
    echo ""
    echo "2. 配置 API（二选一）："
    echo ""
    echo "   ${BLUE}选项 A: 使用官方 API${NC}"
    echo "   ${YELLOW}claude login${NC}"
    echo ""
    echo "   ${BLUE}选项 B: 使用第三方 API${NC}"
    echo "   ${YELLOW}nano ~/.config/claude-code/credentials.env${NC}"
    echo "   填入："
    echo "   ${YELLOW}ANTHROPIC_AUTH_TOKEN='你的-KEY'${NC}"
    echo "   ${YELLOW}ANTHROPIC_BASE_URL='https://你的端点.com'${NC}"
    echo "   保存后运行："
    echo "   ${YELLOW}chmod 600 ~/.config/claude-code/credentials.env${NC}"
    echo ""
    echo "3. 启动 Claude Code："
    echo "   ${YELLOW}claude${NC}"
    echo ""
    echo -e "${GREEN}需要帮助？${NC}"
    echo "查看配置说明: ${YELLOW}cat ~/.config/claude-code/README.txt${NC}"
    echo ""
    
    print_info "提示: 第一次启动会让你选择主题，推荐选择 'Dark mode'"
    echo ""
}

# 主函数
main() {
    print_header "Claude Code for Termux 自动安装程序"
    
    print_info "本脚本将安装 Claude Code v${CLAUDE_VERSION}"
    print_info "使用 glibc-runner 兼容 Android 环境"
    echo ""
    
    # 执行安装步骤
    check_architecture
    install_dependencies
    install_claude
    create_launcher
    setup_environment
    create_config_template
    verify_installation
    print_usage
}

# 运行主函数
main
