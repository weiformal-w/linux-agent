#!/bin/bash

echo "🔧 Linux Agent 安装脚本"
echo "======================"

# 1. 设置 npm 配置
echo "📝 配置 npm..."
echo "ignore-scripts=false" > .npmrc

# 2. 安装依赖
echo "📦 安装依赖..."
npm install

# 3. 修复 SDK
echo "🔧 修复 SDK..."
node fix-sdk.js

# 4. 验证修复
echo "🧪 验证修复..."
if node -e "import('@shipany/open-agent-sdk').then(() => console.log('✅ SDK 修复成功！'))" 2>/dev/null; then
    echo "✨ 安装完成！"
    echo ""
    echo "🚀 启动应用:"
    echo "   npm start"
else
    echo "❌ SDK 修复失败，请手动运行: node fix-sdk.js"
    exit 1
fi