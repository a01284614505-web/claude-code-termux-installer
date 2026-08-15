# 常见问题 FAQ

## 🤔 安装相关

### Q: 我的设备是 ARM32 (armv7l) 可以用吗？

**A**: 不可以。Claude Code 只提供 ARM64 (aarch64) 版本。

检查方法：
```bash
uname -m
# 必须输出: aarch64
```

如果是 `armv7l` 或 `armv8l`，你的设备不支持。

---

### Q: 为什么安装这么慢？

**A**: 需要下载以下内容：
- glibc-runner (~100MB)
- Claude Code 二进制 (~200MB)
- Node.js 及依赖

**加速方法**：
```bash
# 使用镜像源（如果在中国）
# 编辑 /data/data/com.termux/files/usr/etc/apt/sources.list
```

---

### Q: pkg install glibc-repo 失败怎么办？

**A**: 常见原因：

1. **软件源未更新**
```bash
pkg update
pkg upgrade
```

2. **网络问题**
```bash
# 测试网络
ping -c 3 packages.termux.dev
```

3. **Termux 版本太旧**
   - 从 F-Droid 或 GitHub 重新安装 Termux

---

### Q: npm install 报错 EACCES 怎么办？

**A**: 不要用 sudo！Termux 不需要 root。

```bash
# 错误示例
sudo npm install -g ...  # ❌

# 正确示例
npm install -g ...  # ✅
```

---

## 🚀 使用相关

### Q: 如何切换模型？

**A**: 使用 `/model` 命令：

```bash
claude
> /model fable   # 切换到 fable
> /model sonnet  # 切换到 sonnet
> /model         # 查看当前模型
```

---

### Q: 如何更新 Claude Code？

**A**: 重新运行安装脚本：

```bash
cd claude-code-termux-installer
bash install.sh
```

或手动更新：

```bash
npm install -g @anthropic-ai/claude-code@latest
npm install -g --force @anthropic-ai/claude-code-linux-arm64@latest
```

---

### Q: 配置文件在哪里？

**A**: 
- **启动脚本**: `~/.local/bin/claude`
- **凭证配置**: `~/.config/claude-code/credentials.env`
- **Claude 设置**: `~/.claude/settings.json`
- **会话历史**: `~/.claude/history/`

---

### Q: 如何使用第三方 API？

**A**: 创建 credentials.env：

```bash
nano ~/.config/claude-code/credentials.env
```

填入：
```bash
ANTHROPIC_AUTH_TOKEN='sk-your-key'
ANTHROPIC_BASE_URL='https://your-endpoint.com'
```

⚠️ **注意**: BASE_URL 不要加 `/v1/messages`，Claude Code 会自动添加。

---

### Q: 如何查看 API 使用情况？

**A**: 取决于你的 API 提供商。

官方 API:
```bash
# 查看 ~/.claude/logs/ 中的日志
tail -f ~/.claude/logs/latest.log
```

第三方 API: 询问你的 API 提供商。

---

## 🐛 故障排除

### Q: 启动报错 "cannot execute: required file not found"

**A**: grun 未正确工作。

检查：
```bash
# 1. 确认 grun 已安装
which grun

# 2. 确认启动脚本使用了 grun
cat ~/.local/bin/claude | grep grun

# 3. 手动测试
grun $(npm root -g)/@anthropic-ai/claude-code-linux-arm64/claude --version
```

---

### Q: 启动卡住不动

**A**: 可能是网络问题或 API 配置错误。

检查：
```bash
# 1. 查看是否有网络
curl -I https://api.anthropic.com

# 2. 检查凭证文件
cat ~/.config/claude-code/credentials.env

# 3. 查看日志
tail -f ~/.claude/logs/latest.log
```

---

### Q: 报错 "Invalid API key"

**A**: API 密钥配置错误。

检查：
```bash
# 查看当前配置
cat ~/.config/claude-code/credentials.env

# 确保格式正确
ANTHROPIC_AUTH_TOKEN='sk-...'  # 有引号
ANTHROPIC_BASE_URL='https://...'  # 有引号，无尾部斜杠
```

---

### Q: 模型映射不生效

**A**: 检查 settings.json：

```bash
# 查看当前配置
cat ~/.claude/settings.json

# 应该包含
{
  "env": {
    "ANTHROPIC_DEFAULT_FABLE_MODEL": "claude-fable-5",
    ...
  }
}
```

重启 Claude Code 后生效。

---

### Q: 提示 "模型不存在"

**A**: 你的 API 端点可能不支持该模型。

检查：
1. 询问 API 提供商支持哪些模型
2. 修改 `~/.claude/settings.json` 中的映射
3. 使用 API 端点实际支持的模型名

---

## 💾 性能相关

### Q: Claude Code 占用多少存储空间？

**A**: 
- glibc-runner: ~100MB
- Claude Code: ~200MB
- Node.js: ~50MB
- 历史记录: 随使用增长

**总计**: ~400MB + 使用数据

---

### Q: 运行速度如何？

**A**: 
- 启动时间: 2-5 秒
- 响应速度: 取决于 API 延迟
- 性能损失: glibc-runner 几乎无损失（<5%）

比 proot-distro 快很多！

---

### Q: 耗电如何？

**A**: 
- 待机: 极低
- 活动使用: 中等（主要是网络和 CPU）
- 建议插电使用长会话

---

## 🔒 安全相关

### Q: credentials.env 安全吗？

**A**: 
- ✅ 存储在你的设备上，其他应用无法访问
- ✅ 脚本设置了 `chmod 600`（只有你能读）
- ⚠️ 但如果设备被 root，可能被读取

**最佳实践**:
1. 不要分享你的 credentials.env
2. 定期更换 API 密钥
3. 不要在截图中暴露

---

### Q: 第三方 API 可信吗？

**A**: **取决于提供商**。

使用前考虑：
- 提供商的声誉如何？
- 他们会记录你的对话吗？
- 价格合理吗？

**官方 API** 最安全，但可能更贵或需要科学上网。

---

## 🌐 网络相关

### Q: 需要科学上网吗？

**A**: 
- **官方 API**: 在某些地区需要
- **第三方 API**: 取决于端点位置

测试：
```bash
curl -I https://api.anthropic.com
# 如果超时，你可能需要代理
```

---

### Q: 如何设置代理？

**A**: 

```bash
# 在启动脚本中添加
export HTTP_PROXY=http://your-proxy:port
export HTTPS_PROXY=http://your-proxy:port

# 或在 credentials.env 中添加
HTTP_PROXY='http://your-proxy:port'
HTTPS_PROXY='http://your-proxy:port'
```

---

## 🔄 与其他方案对比

### Q: 为什么不用 proot-distro？

**A**: 可以用，但：
- proot 性能损失 30-50%
- 占用更多空间 (~2GB)
- 启动更慢

**glibc-runner** 更轻量、更快。

---

### Q: 为什么不固定在 2.1.112？

**A**: 可以，但：
- 版本太老（2026年4月）
- 缺少新功能
- 没有安全更新

**本方案**用最新版本。

---

### Q: 为什么不用官方安装器？

**A**: 官方安装器不支持 Android：
```bash
curl -fsSL https://claude.ai/install.sh | bash
# ❌ cannot execute: required file not found
```

**本方案**解决了这个问题。

---

## 📱 设备相关

### Q: 哪些设备测试过？

**A**: 社区报告：
- ✅ Pixel 6/7/8/9 系列
- ✅ 小米 11/12/13 系列
- ✅ 三星 Galaxy S20+
- ✅ 一加 9/10 系列

理论上所有 ARM64 Android 设备都可以。

---

### Q: Android 版本有要求吗？

**A**: 
- **推荐**: Android 11+
- **最低**: Android 7
- **已知问题**: Android 10 及以下可能有 seccomp 限制

---

## 🆘 获取帮助

### Q: 还是不行怎么办？

**A**: 

1. **查看日志**
```bash
tail -50 ~/.claude/logs/latest.log
```

2. **收集信息**
```bash
uname -a
claude --version
which grun
cat ~/.config/claude-code/credentials.env  # 隐藏密钥
```

3. **寻求帮助**
   - GitHub Issues
   - Termux 社区
   - Claude 相关论坛

---

还有问题？欢迎提 Issue！
