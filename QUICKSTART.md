# 快速开始指南

## 📱 第一次使用？跟着做：

### 1. 安装

推荐直接运行远程安装脚本：

```bash
curl -fsSL https://raw.githubusercontent.com/galiandan/claude-code-termux-installer/main/install.sh | bash
```

如果希望先检查脚本内容：

```bash
curl -fsSL https://raw.githubusercontent.com/galiandan/claude-code-termux-installer/main/install.sh -o install.sh
less install.sh
bash install.sh
```

也可以下载项目压缩包后进入目录运行 `bash install.sh`。

安装需要 5-10 分钟，耐心等待。使用本地脚本时运行 `bash install.sh`。

### 2. 配置 API

#### 如果你有第三方 API（比如群友提供的）：

```bash
# 复制示例配置
cp examples/credentials.env.example ~/.config/claude-code/credentials.env

# 编辑配置文件
nano ~/.config/claude-code/credentials.env
```

修改这两行：
```bash
ANTHROPIC_AUTH_TOKEN='sk-粘贴你的密钥'
ANTHROPIC_BASE_URL='https://粘贴API地址'
```

保存：`Ctrl+X` → `Y` → `Enter`

设置权限：
```bash
chmod 600 ~/.config/claude-code/credentials.env
```

#### 如果你用官方 API：

```bash
claude login
# 会打开浏览器，用你的 Anthropic 账号登录
```

### 3. 启动

```bash
source ~/.bashrc
claude
```

第一次启动会让你选主题，推荐选 `Dark mode`。

### 4. 配置模型（可选）

如果你的 API 支持 fable、opus-5 等模型：

```bash
# 复制示例配置
cp examples/settings.json.example ~/.claude/settings.json

# 重启 Claude Code
claude
```

---

## 🎯 常用命令

```bash
# 启动 Claude Code
claude

# 查看版本
claude --version

# 查看帮助
claude --help

# 在会话中
/model          # 查看/切换模型
/help           # 查看所有命令
/exit           # 退出
```

---

## 🆘 遇到问题？

### 问题 1: 报错 "command not found: claude"

```bash
source ~/.bashrc
```

### 问题 2: 启动卡住不动

```bash
# 检查网络
curl -I https://你的API端点

# 检查配置
cat ~/.config/claude-code/credentials.env
```

### 问题 3: "Invalid API key"

你的密钥配置错误，重新检查 `credentials.env`。

### 问题 4: 其他问题

查看 `FAQ.md` 或联系提供安装包的人。

---

## ✅ 验证安装成功

运行这个命令，如果看到版本号就成功了：

```bash
claude --version
# 应该显示: 2.1.233 (Claude Code)
```

---

## 🎉 开始使用！

```bash
claude
> 你好！帮我写一个 Python 脚本...
```

享受 AI 编程助手吧！
