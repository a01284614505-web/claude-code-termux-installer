# Claude Code for Termux - 技术详解

## 🔍 深入理解

### 1. 问题的本质

#### 官方 Claude Code 的编译目标

```c
// 官方二进制期望的环境
- glibc (GNU C Library)
- 动态链接器: /lib/ld-linux-aarch64.so.1
- 依赖库: libpthread.so.0, libc.so.6 等
```

#### Android/Termux 的实际环境

```c
// Android 实际提供的环境
- Bionic libc (Android's C library)
- 动态链接器: /system/bin/linker64
- 库结构完全不同
```

#### 冲突结果

```bash
$ ./claude
bash: ./claude: cannot execute: required file not found
```

虽然文件存在，但系统找不到它需要的 `/lib/ld-linux-aarch64.so.1`。

---

### 2. glibc-runner 的工作原理

#### 目录结构

```
/data/data/com.termux/files/usr/
├── glibc/
│   ├── bin/
│   │   └── grun          # 启动器
│   ├── lib/
│   │   ├── ld-linux-aarch64.so.1  # glibc 动态链接器
│   │   ├── libc.so.6              # glibc C 库
│   │   ├── libpthread.so.0        # 线程库
│   │   └── ...
```

#### grun 做了什么

```bash
# 伪代码
grun 二进制程序 参数...
↓
1. 设置 LD_LIBRARY_PATH 指向 glibc 库目录
2. 设置正确的动态链接器
3. exec 启动目标程序
```

实际上相当于：

```bash
LD_LIBRARY_PATH=/usr/glibc/lib \
/usr/glibc/lib/ld-linux-aarch64.so.1 \
目标程序 参数...
```

---

### 3. 为什么需要两个 npm 包

#### 第一个包: @anthropic-ai/claude-code

```javascript
// package.json 的简化版本
{
  "name": "@anthropic-ai/claude-code",
  "bin": {
    "claude": "dist/index.js"
  },
  "optionalDependencies": {
    "@anthropic-ai/claude-code-linux-arm64": "2.1.233",
    "@anthropic-ai/claude-code-darwin-arm64": "2.1.233",
    // ... 其他平台
  }
}
```

- 包含 CLI 逻辑、UI、配置管理
- 是一个 Node.js 包（JavaScript）
- 会根据 `process.platform` 选择对应的二进制

#### 第二个包: @anthropic-ai/claude-code-linux-arm64

```
@anthropic-ai/claude-code-linux-arm64/
└── claude          # 原生 ELF 二进制文件（~200MB）
```

- 这是真正干活的程序
- 用 Bun 编译的 TypeScript（打包成单个二进制）
- 包含了整个运行时

#### 为什么要 --force

```bash
npm install -g @anthropic-ai/claude-code-linux-arm64
# 会检查: process.platform === 'linux' ?
# Android 返回: 'android' ❌
# 安装失败！

npm install -g --force @anthropic-ai/claude-code-linux-arm64
# --force 跳过平台检查 ✅
```

---

### 4. 启动脚本的关键

#### 我们的包装脚本

```bash
#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

prefix_dir="/data/data/com.termux/files/usr"
binary="$prefix_dir/lib/node_modules/@anthropic-ai/claude-code-linux-arm64/claude"

# 加载私有环境变量
if [ -f "$HOME/.config/claude-code/credentials.env" ]; then
  set -a
  . "$HOME/.config/claude-code/credentials.env"
  set +a
fi

# 🔑 关键: 用 grun 启动
exec "$prefix_dir/bin/grun" "$binary" "$@"
```

#### 如果不用 grun 会怎样

```bash
# 直接运行
exec "$binary" "$@"
# ❌ cannot execute: required file not found

# 用 node 运行
node "$binary" "$@"
# ❌ 这是二进制文件，不是 JS

# 用 patchelf 修改二进制
patchelf --set-interpreter /system/bin/linker64 "$binary"
# ❌ Bionic 和 glibc 的 API 不兼容
```

---

### 5. 环境变量的妙用

#### credentials.env 的加载逻辑

```bash
set -a                    # 自动导出所有变量
. "$file"                 # source 文件
set +a                    # 关闭自动导出
```

等效于：

```bash
export ANTHROPIC_AUTH_TOKEN='...'
export ANTHROPIC_BASE_URL='...'
```

#### 为什么放在 ~/.config/claude-code/

- 遵循 XDG 标准
- 与 Claude Code 的配置目录分离
- 私有凭证不会被 Claude Code 自动读取（安全）

---

### 6. 完整的执行流程

```
用户输入: claude --version
    ↓
bash 找到: ~/.local/bin/claude (我们的脚本)
    ↓
脚本加载: credentials.env (如果存在)
    ↓
脚本调用: grun /path/to/claude --version
    ↓
grun 设置: glibc 环境
    ↓
grun 执行: /usr/glibc/lib/ld-linux-aarch64.so.1 /path/to/claude --version
    ↓
Claude Code 启动 (在 glibc 环境中)
    ↓
读取环境变量: ANTHROPIC_AUTH_TOKEN, ANTHROPIC_BASE_URL
    ↓
连接 API: 使用配置的端点
    ↓
显示版本: 2.1.233 (Claude Code)
```

---

### 7. 与其他方案的对比

#### 方案对比表

| 方案 | 技术 | 优点 | 缺点 |
|-----|------|------|------|
| **本方案 (glibc-runner)** | glibc 兼容层 | 官方二进制、性能好 | 需要 glibc-runner |
| proot-distro | 系统调用拦截 | 完全兼容 | 性能损失 30-50% |
| 固定 2.1.112 | JavaScript 版本 | 简单 | 版本老旧 |
| Termux 原生编译 | 从源码编译 | 完美适配 | 需要自己维护 |

---

### 8. 潜在问题和限制

#### 已知问题

1. **Android 版本限制**
   - Android 10 及以下可能有 seccomp 过滤器问题
   - 某些系统调用被阻止

2. **存储空间**
   - glibc-runner: ~100MB
   - Claude Code: ~200MB
   - 总计: ~400MB

3. **更新维护**
   - 需要手动更新版本号
   - glibc-runner 停止维护会影响使用

#### 未来展望

- Anthropic 可能发布官方 Android 版本
- 或者提供静态编译版本（musl）
- 社区可能开发 Termux 原生构建

---

### 9. 调试技巧

#### 检查 glibc 环境

```bash
# 查看 grun 位置
which grun

# 查看 glibc 库
ls -la /data/data/com.termux/files/usr/glibc/lib/

# 测试 grun
grun /bin/true && echo "grun 工作正常"
```

#### 测试二进制

```bash
# 查看二进制信息
file $(which claude)

# 查看依赖库
grun ldd $(npm root -g)/@anthropic-ai/claude-code-linux-arm64/claude
```

#### 调试启动

```bash
# 启用调试输出
bash -x ~/.local/bin/claude --version
```

---

## 📚 参考资料

- [Termux glibc-packages](https://github.com/termux-pacman/glibc-packages)
- [ELF 格式规范](https://en.wikipedia.org/wiki/Executable_and_Linkable_Format)
- [Android Bionic](https://android.googlesource.com/platform/bionic/)
- [glibc 文档](https://www.gnu.org/software/libc/)

---

## 🤓 进阶实验

想深入理解？试试这些：

```bash
# 1. 查看 Claude Code 的依赖
grun ldd $(npm root -g)/@anthropic-ai/claude-code-linux-arm64/claude

# 2. 对比 Bionic 和 glibc
ldd /system/bin/ls  # Bionic
grun ldd /usr/bin/env  # glibc

# 3. 追踪系统调用
strace -e trace=execve claude --version
```
