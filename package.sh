#!/data/data/com.termux/files/usr/bin/bash

# 打包脚本
# 用于创建可分享的压缩包

echo "================================"
echo "Claude Code Termux 安装包打包工具"
echo "================================"
echo ""

cd ~

# 检查目录是否存在
if [ ! -d "claude-code-termux-installer" ]; then
    echo "❌ 错误: claude-code-termux-installer 目录不存在"
    exit 1
fi

# 创建日期标记
DATE=$(date +%Y%m%d)
PACKAGE_NAME="claude-code-termux-installer-v1.0.0-${DATE}"

echo "📦 正在打包..."
echo ""

# 创建 tar.gz 压缩包
echo "创建 tar.gz 格式..."
tar -czf "${PACKAGE_NAME}.tar.gz" claude-code-termux-installer/
echo "✅ ${PACKAGE_NAME}.tar.gz"

# 创建 zip 压缩包（更通用）
echo "创建 zip 格式..."
zip -r -q "${PACKAGE_NAME}.zip" claude-code-termux-installer/
echo "✅ ${PACKAGE_NAME}.zip"

echo ""
echo "================================"
echo "打包完成！"
echo "================================"
echo ""

# 显示文件信息
echo "📊 文件信息:"
ls -lh "${PACKAGE_NAME}".* | awk '{print "  " $9 " - " $5}'
echo ""

echo "📁 文件位置:"
echo "  $(pwd)/${PACKAGE_NAME}.tar.gz"
echo "  $(pwd)/${PACKAGE_NAME}.zip"
echo ""

echo "💡 分享建议:"
echo "  - tar.gz 适合 Linux/Mac 用户"
echo "  - zip 适合 Windows 用户和微信/QQ 传输"
echo ""

echo "⚠️  分享前检查:"
echo "  - 不要包含你的 credentials.env"
echo "  - 不要包含 ~/.claude/ 目录"
echo "  - 确保没有个人敏感信息"
echo ""

echo "📤 可以分享了！"
