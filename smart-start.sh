#!/bin/bash
# 智能启动脚本 - 自动检测 Node.js 版本并使用合适的启动参数

echo "🤖 Linux Agent 智能启动"
echo "======================="

# 检测 Node.js 版本
NODE_VERSION=$(node --version)
echo "📌 检测到 Node.js 版本: $NODE_VERSION"

# 提取主版本号
MAJOR_VERSION=$(echo $NODE_VERSION | cut -d'.' -f1 | sed 's/v//')

# 根据版本选择启动命令
case $MAJOR_VERSION in
    18|19|20)
        echo "✅ 使用 Node.js v18-v20 兼容模式"
        echo ""
        exec node cli.js "$@"
        ;;
    22|23|24|*)
        echo "✅ 使用 Node.js v22+ 兼容模式"
        echo ""
        exec node --no-experimental-strip-types cli.js "$@"
        ;;
    *)
        echo "⚠️  未知的 Node.js 版本，尝试默认模式"
        echo ""
        exec node cli.js "$@"
        ;;
esac