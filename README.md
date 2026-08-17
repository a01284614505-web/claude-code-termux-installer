# Claude Code for Termux 安装器

这个项目提供两个可通过 `curl | bash` 直接运行的 Bash 脚本，用于在 Android/Termux 上安装 Claude Code 并配置自定义 API。

## 开始使用

请在 Termux 中严格按以下顺序执行。

### 第一步：安装 Claude Code

复制并运行安装脚本：

```bash
curl -fsSL https://raw.githubusercontent.com/galiandan/claude-code-termux-installer/main/install.sh | bash
```

脚本会自动安装 Node.js、npm、ripgrep、glibc-runner 和 Claude Code。安装过程需要几分钟，请不要关闭 Termux。

### 第二步：配置自定义 API

安装完成后，运行配置脚本：

```bash
curl -fsSL https://raw.githubusercontent.com/galiandan/claude-code-termux-installer/main/configure.sh | bash
```

脚本会依次询问：

1. `API Base URL`：填写 API 基础地址，例如 `https://api.example.com`，不要填写 `/v1/messages`。
2. `API Key`：输入 API 密钥，输入时会显示。

配置将保存到 `~/.config/claude-code/credentials.env`，权限自动设置为 `600`。如果已有配置，覆盖前会自动备份。

### 第三步：启动 Claude Code

配置完成后运行：

```bash
source ~/.bashrc
claude --version
claude
```

如果使用官方 Anthropic API，可以跳过第二步，直接运行 `claude login`。

两个脚本也支持先下载、检查后执行：

```bash
curl -fsSL https://raw.githubusercontent.com/galiandan/claude-code-termux-installer/main/install.sh -o install.sh
less install.sh
bash install.sh

curl -fsSL https://raw.githubusercontent.com/galiandan/claude-code-termux-installer/main/configure.sh -o configure.sh
less configure.sh
bash configure.sh
```

## 系统要求

- Android 设备，`aarch64` / ARM64 架构
- 从 [F-Droid](https://f-droid.org/packages/com.termux/) 或 [Termux GitHub Releases](https://github.com/termux/termux-app/releases) 安装的 Termux
- 至少约 500 MB 可用空间
- 安装过程需要网络连接

本项目只支持 Android/Termux，不支持普通 Linux、iOS 或其他架构。

## 安装过程做什么

安装脚本会自动完成以下操作：

1. 更新 Termux 软件源。
2. 安装 Node.js LTS、npm 和 ripgrep。
3. 安装 `glibc-repo` 和 `glibc-runner`。
4. 安装 Claude Code 主包及 Linux ARM64 原生二进制。
5. 创建 `~/.local/bin/claude` 启动命令。
6. 将 `~/.local/bin` 加入 `~/.bashrc`。
7. 创建 `~/.config/claude-code` 配置目录。

Termux 使用 Android 的 Bionic libc，而 Claude Code 原生二进制面向 Linux glibc。启动命令会通过 `glibc-runner` 运行该二进制。

## 配置说明

### 使用官方 Anthropic API

```bash
claude login
```

### 使用第三方 API

如果不使用配置脚本，也可以手动创建配置文件：

```bash
mkdir -p ~/.config/claude-code
nano ~/.config/claude-code/credentials.env

ANTHROPIC_AUTH_TOKEN='你的-API-KEY'
ANTHROPIC_BASE_URL='https://你的端点.com'

chmod 600 ~/.config/claude-code/credentials.env
```

Base URL 填写 API 基础地址即可，不要填写 `/v1/messages`。不要把 API Key 提交到 Git 或公开分享。

启动：

```bash
claude
```

启动脚本会在每次运行时加载 `~/.config/claude-code/credentials.env`。安装器不会覆盖已有的凭证文件或配置说明。

## 版本与参数

默认安装版本为 `2.1.233`。可以通过环境变量指定版本：

```bash
curl -fsSL https://raw.githubusercontent.com/galiandan/claude-code-termux-installer/main/install.sh | CLAUDE_VERSION=2.1.233 bash
```

查看帮助：

```bash
curl -fsSL https://raw.githubusercontent.com/galiandan/claude-code-termux-installer/main/install.sh | bash -s -- --help
```

下载后也可以运行：

```bash
bash install.sh --help
```

## 常用命令

```bash
claude                  # 启动 Claude Code
claude --version        # 查看版本
claude --help           # 查看帮助
```

如果提示 `command not found: claude`，重新加载 PATH：

```bash
source ~/.bashrc
```

## 更新

重新执行安装命令即可更新 Claude Code：

```bash
curl -fsSL https://raw.githubusercontent.com/galiandan/claude-code-termux-installer/main/install.sh | bash
```

安装器会更新 npm 包，并重新生成 `~/.local/bin/claude` 启动命令；已有的 `credentials.env` 不会被覆盖。

## 无法使用 curl 时

可以下载项目 zip 压缩包，在 Termux 中解压后运行：

```bash
bash install.sh
```

安装脚本只使用自身内容，不依赖 `examples/` 或其他文档文件，因此 zip 安装和 curl 安装使用的是同一套流程。

配置脚本也可以下载后执行：

```bash
curl -fsSL https://raw.githubusercontent.com/galiandan/claude-code-termux-installer/main/configure.sh -o configure.sh
bash configure.sh
```

## 文档

- [QUICKSTART.md](QUICKSTART.md)：快速上手
- [FAQ.md](FAQ.md)：常见问题
- [TECHNICAL.md](TECHNICAL.md)：技术原理和调试
- [CHANGELOG.md](CHANGELOG.md)：版本历史

## 安全提示

`curl | bash` 会立即执行远程脚本。只从你信任的地址运行，并在生产环境使用前审阅脚本内容。需要可审计安装时，请固定到已审核的 Git 提交地址，或使用“先下载再执行”的方式。

本项目是社区维护的安装器，不代表 Anthropic 官方支持。Claude Code 本身受 Anthropic 的许可条款约束。

## 许可证

本安装脚本采用 MIT 许可证。
