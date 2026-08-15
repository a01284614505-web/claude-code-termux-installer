# Claude Code for Termux 安装包

一键安装脚本，让 Claude Code 在 Android/Termux 上运行。

## ✨ 特性

- ✅ 使用官方 Claude Code 二进制
- ✅ 通过 glibc-runner 兼容 Android 环境
- ✅ 支持官方 API 和第三方 API 端点
- ✅ 全自动安装，无需手动配置
- ✅ 适用于所有 ARM64 Android 设备

## 📋 系统要求

- **设备**: ARM64 (aarch64) 架构的 Android 设备
- **系统**: Android 7+ 
- **应用**: Termux (从 F-Droid 或 GitHub 安装)
- **存储**: 至少 500MB 可用空间
- **网络**: 需要网络连接下载依赖

## 🚀 快速安装

### 第一步：获取安装包

从群文件或分享链接下载 `claude-code-termux-installer.zip`

### 第二步：解压安装包

在 Termux 中运行：

```bash
# 进入下载目录
cd ~/storage/downloads

# 解压（如果已经解压请跳过）
unzip claude-code-termux-installer*.zip

# 进入目录
cd claude-code-termux-installer
```

### 第三步：运行安装

```bash
bash install.sh
```

安装过程需要 5-10 分钟，请耐心等待。

## 📖 安装后配置

### 选项 A: 使用群里的共享 API

1. 创建配置文件：
```bash
nano ~/.config/claude-code/credentials.env
```

2. 填入群里公布的配置：
```bash
ANTHROPIC_AUTH_TOKEN='群里的密钥'
ANTHROPIC_BASE_URL='https://sui-xiang.com'
```

3. 保存并退出：`Ctrl+X` → `Y` → `Enter`

4. 设置权限：
```bash
chmod 600 ~/.config/claude-code/credentials.env
```

### 选项 B: 使用官方 Anthropic API

```bash
# 重新加载环境
source ~/.bashrc

# 登录官方账号
claude login
```

### 第四步：启动使用

```bash
# 重新加载环境变量
source ~/.bashrc

# 启动 Claude Code
claude
```

## 📚 查看文档

安装包中包含详细文档：

```bash
# 快速上手指南（5分钟学会）
cat QUICKSTART.md

# 常见问题解答
cat FAQ.md

# 技术详解
cat TECHNICAL.md

# 分享指南
cat SHARING.md
```

**提示**: 在手机上用文本查看器（如 MT 管理器、QuickEdit）打开 `.md` 文件查看效果更好。

## 🔧 技术原理

### 为什么需要这个脚本？

Anthropic 的官方 Claude Code 二进制是为标准 Linux (glibc) 编译的，但 Android/Termux 使用不兼容的 Bionic libc。

### 解决方案

```
Android/Termux (Bionic libc)
    ↓
glibc-runner (提供 glibc 兼容层)
    ↓
官方 Linux ARM64 Claude Code 二进制
    ↓
成功运行！
```

### 核心技术栈

1. **glibc-runner**: Termux 社区提供的 glibc 兼容层
2. **grun**: 启动器，正确设置 glibc 环境
3. **官方二进制**: 使用 `--force` 强制安装 linux-arm64 包

## 📂 安装包内容

```
claude-code-termux-installer/
├── install.sh              # 主安装脚本（全自动）
├── README.md              # 本文件
├── QUICKSTART.md          # 快速上手指南
├── FAQ.md                 # 常见问题解答
├── TECHNICAL.md           # 技术详解
├── SHARING.md             # 分享指南
├── CHANGELOG.md           # 版本历史
├── 如何查看文档.txt       # 文档查看说明
└── examples/
    ├── credentials.env.example    # 配置示例
    └── settings.json.example      # 模型映射示例
```

## 🐛 常见问题

### 安装失败怎么办？

1. 确保 Termux 是最新版本：
```bash
pkg update && pkg upgrade
```

2. 检查存储空间：
```bash
df -h $HOME
```

3. 查看 FAQ.md 获取详细故障排除

### Claude Code 启动失败？

```bash
# 检查安装是否完整
which grun
which claude

# 查看详细错误
claude --version
```

### 如何更新 Claude Code？

重新运行安装脚本即可：

```bash
cd claude-code-termux-installer
bash install.sh
```

## 🙏 致谢

- Anthropic - Claude Code 官方
- Termux 社区 - glibc-runner 项目
- 社区贡献者 - 分享安装方法

## 📜 许可证

本安装脚本采用 MIT 许可证。

Claude Code 本身受 Anthropic 许可证约束。

## 🔗 相关链接

- [Termux 官网](https://termux.dev/)
- [Termux F-Droid 下载](https://f-droid.org/packages/com.termux/)
- [glibc-packages](https://github.com/termux-pacman/glibc-packages)

## ⚠️ 免责声明

本脚本基于社区方法整理，非官方支持。使用风险自负。

建议在测试环境中先验证，再用于生产环境。

---

**安装遇到问题？** 查看 `FAQ.md` 或在群里询问！
