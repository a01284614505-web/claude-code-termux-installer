#!/usr/bin/env bash

# Claude Code installer for Termux.
# It is self-contained so it can be executed with:
#   curl -fsSL https://raw.githubusercontent.com/galiandan/claude-code-termux-installer/main/install.sh | bash

set -Eeuo pipefail

CLAUDE_VERSION="${CLAUDE_VERSION:-2.1.233}"
CLAUDE_PACKAGE="@anthropic-ai/claude-code"
PLATFORM_PACKAGE="@anthropic-ai/claude-code-linux-arm64"
PREFIX_DIR="${PREFIX:-/data/data/com.termux/files/usr}"
BIN_DIR="${HOME}/.local/bin"
CONFIG_DIR="${HOME}/.config/claude-code"
LAUNCHER="${BIN_DIR}/claude"

if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
    RED=$'\033[0;31m'
    GREEN=$'\033[0;32m'
    YELLOW=$'\033[1;33m'
    BLUE=$'\033[0;34m'
    NC=$'\033[0m'
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    NC=''
fi

print_header() {
    printf '%s\n' "${BLUE}============================================================${NC}"
    printf '%s\n' "${BLUE}$1${NC}"
    printf '%s\n' "${BLUE}============================================================${NC}"
}

print_step() {
    printf '%s %s\n' "${GREEN}[OK]${NC}" "$1"
}

print_info() {
    printf '%s %s\n' "${YELLOW}[INFO]${NC}" "$1"
}

die() {
    printf '%s %s\n' "${RED}[ERROR]${NC}" "$1" >&2
    exit 1
}

usage() {
    cat <<'EOF'
Claude Code installer for Termux (Android/aarch64)

Usage:
  bash install.sh
  curl -fsSL https://raw.githubusercontent.com/galiandan/claude-code-termux-installer/main/install.sh | bash

Environment variables:
  CLAUDE_VERSION  Claude Code version to install (default: 2.1.233)
  NO_COLOR        Disable colored output when set to any value
EOF
}

require_command() {
    command -v "$1" >/dev/null 2>&1 || die "缺少命令: $1"
}

check_termux() {
    local architecture
    architecture="$(uname -m)"

    [[ "${PREFIX:-}" == */com.termux/files/usr || -d /data/data/com.termux/files/usr ]] || \
        die "此安装器仅支持 Android/Termux，请在 Termux 中运行。"
    [[ "${architecture}" == "aarch64" ]] || \
        die "此安装器仅支持 aarch64，当前架构为: ${architecture}"
    require_command pkg
    print_step "Termux 环境检查通过: ${architecture}"
}

install_dependencies() {
    print_header "安装 Termux 依赖"

    print_info "正在更新 Termux 软件源..."
    pkg update -y
    pkg install -y nodejs-lts ripgrep

    if ! dpkg-query -W -f='${Status}' glibc-repo 2>/dev/null | grep -q 'install ok installed'; then
        print_info "正在安装 glibc 软件源..."
        pkg install -y glibc-repo
        pkg update -y
    fi

    if ! command -v grun >/dev/null 2>&1; then
        print_info "正在安装 glibc-runner..."
        pkg install -y glibc-runner
    fi

    require_command node
    require_command npm
    require_command grun
    print_step "依赖安装完成: $(node --version)"
}

install_claude() {
    local package_root binary

    print_header "安装 Claude Code v${CLAUDE_VERSION}"
    mkdir -p "${BIN_DIR}"

    print_info "安装主包..."
    npm install --global "${CLAUDE_PACKAGE}@${CLAUDE_VERSION}"

    print_info "安装 Linux ARM64 二进制..."
    npm install --global --force "${PLATFORM_PACKAGE}@${CLAUDE_VERSION}"

    package_root="$(npm root --global)"
    binary="${package_root}/${PLATFORM_PACKAGE}/claude"
    [[ -x "${binary}" ]] || die "未找到 Claude Code 二进制文件: ${binary}"

    printf '%s\n' "${binary}" > "${BIN_DIR}/.claude-binary-path"
    print_step "Claude Code 安装完成"
}

create_launcher() {
    local binary
    binary="$(<"${BIN_DIR}/.claude-binary-path")"

    print_header "创建启动命令"
    cat > "${LAUNCHER}" <<EOF
#!/usr/bin/env bash
set -Eeuo pipefail

binary='${binary}'
runner='${PREFIX_DIR}/bin/grun'
credentials_file="\${HOME}/.config/claude-code/credentials.env"

if [[ -f "\${credentials_file}" ]]; then
    set -a
    # credentials.env follows shell KEY=value syntax.
    # shellcheck disable=SC1090
    source "\${credentials_file}"
    set +a
fi

if [[ ! -x "\${binary}" ]]; then
    printf '%s\\n' "Claude Code binary not found: \${binary}" >&2
    exit 1
fi

exec "\${runner}" "\${binary}" "\$@"
EOF
    chmod 755 "${LAUNCHER}"
    rm -f "${BIN_DIR}/.claude-binary-path"
    print_step "启动命令已创建: ${LAUNCHER}"
}

setup_environment() {
    local path_line='export PATH="$HOME/.local/bin:$PATH"'

    print_header "配置 PATH 和凭证目录"
    touch "${HOME}/.bashrc"
    if ! grep -Fqx "${path_line}" "${HOME}/.bashrc" 2>/dev/null; then
        printf '\n%s\n' "${path_line}" >> "${HOME}/.bashrc"
    fi
    export PATH="${BIN_DIR}:${PATH}"

    mkdir -p "${CONFIG_DIR}"
    chmod 700 "${CONFIG_DIR}"
    if [[ ! -f "${CONFIG_DIR}/README.txt" ]]; then
        cat > "${CONFIG_DIR}/README.txt" <<'EOF'
Claude Code 配置说明
===================

使用第三方 API 时，创建 credentials.env：

推荐运行配置脚本：
  curl -fsSL https://raw.githubusercontent.com/galiandan/claude-code-termux-installer/main/configure.sh | bash

也可以手动创建文件：
  ANTHROPIC_AUTH_TOKEN='你的-API-KEY'
  ANTHROPIC_BASE_URL='https://你的端点.com'

然后执行：
  chmod 600 ~/.config/claude-code/credentials.env

使用官方 API 时，执行：
  claude login
EOF
        chmod 600 "${CONFIG_DIR}/README.txt"
    fi
    print_step "配置目录已准备: ${CONFIG_DIR}"
}

verify_installation() {
    local version_output
    print_header "验证安装"
    version_output="$(${LAUNCHER} --version 2>&1)" || die "Claude Code 启动验证失败: ${version_output}"
    print_step "Claude Code 安装成功: ${version_output}"
}

print_usage() {
    print_header "安装完成"
    cat <<'EOF'
重新打开一个 Termux 窗口，或先执行：
  source ~/.bashrc

使用官方 API：
  claude login

使用第三方 API：
  curl -fsSL https://raw.githubusercontent.com/galiandan/claude-code-termux-installer/main/configure.sh | bash

启动 Claude Code：
  claude
EOF
}

main() {
    case "${1:-}" in
        -h|--help)
            usage
            return 0
            ;;
        --version)
            printf '%s\n' "${CLAUDE_VERSION}"
            return 0
            ;;
        '')
            ;;
        *)
            usage >&2
            die "未知参数: $1"
            ;;
    esac

    print_header "Claude Code for Termux 自动安装程序"
    print_info "目标版本: ${CLAUDE_VERSION}"
    check_termux
    install_dependencies
    install_claude
    create_launcher
    setup_environment
    verify_installation
    print_usage
}

main "$@"
