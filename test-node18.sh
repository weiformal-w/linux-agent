#!/bin/bash
# Node.js v18.20.3 兼容性测试脚本

echo "🔍 Node.js v18.20.3 兼容性测试"
echo "================================="

# 检查当前 Node 版本
CURRENT_NODE=$(node --version)
echo "📌 当前 Node 版本: $CURRENT_NODE"

# 检查 package.json
echo ""
echo "📦 检查 package.json 配置..."
if grep -q "node --no-experimental-strip-types" package.json; then
    echo "⚠️  警告: package.json 包含 v22 特定的 --no-experimental-strip-types 标志"
    echo "   这在 Node.js v18 中不需要，v18 没有类型剥离功能"
fi

# 测试 SDK 导入
echo ""
echo "🧪 测试 SDK 导入..."
if node -e "import('@shipany/open-agent-sdk').then(() => console.log('✅ SDK 导入成功'))" 2>/dev/null; then
    echo "✅ SDK 在当前 Node 版本中工作正常"
else
    echo "❌ SDK 导入失败"
    exit 1
fi

# 检查 .d.ts 文件问题
echo ""
echo "🔍 检查 .d.ts 文件导入问题..."
if grep -r "import.*\.d\.ts" node_modules/@shipany/open-agent-sdk/dist/ink/components/*.js 2>/dev/null; then
    echo "❌ 发现 .d.ts 导入问题！需要应用修复"
    echo ""
    echo "🔧 应用修复..."

    # 修复 Box.js
    if [ -f "node_modules/@shipany/open-agent-sdk/dist/ink/components/Box.js" ]; then
        sed -i.bak "s/import '..\/global\.d\.ts';/\/\/ import '..\/global.d.ts';/" node_modules/@shipany/open-agent-sdk/dist/ink/components/Box.js
        echo "✅ 已修复 Box.js"
    fi

    # 修复 ScrollBox.js
    if [ -f "node_modules/@shipany/open-agent-sdk/dist/ink/components/ScrollBox.js" ]; then
        sed -i.bak "s/import '..\/global\.d\.ts';/\/\/ import '..\/global.d.ts';/" node_modules/@shipany/open-agent-sdk/dist/ink/components/ScrollBox.js
        echo "✅ 已修复 ScrollBox.js"
    fi

    echo "🔄 重新测试 SDK 导入..."
    if node -e "import('@shipany/open-agent-sdk').then(() => console.log('✅ SDK 修复后导入成功'))" 2>/dev/null; then
        echo "✅ SDK 修复成功！"
    else
        echo "❌ SDK 修复后仍然失败"
        exit 1
    fi
else
    echo "✅ 没有发现 .d.ts 导入问题"
fi

# 测试程序启动
echo ""
echo "🚀 测试程序启动..."
timeout 3 npm start 2>&1 | head -10 || true

echo ""
echo "✨ Node.js v18.20.3 兼容性测试完成！"
echo ""
echo "📋 兼容性说明:"
echo "  ✅ Node.js v18.x - 完全兼容（不需要 --no-experimental-strip-types）"
echo "  ✅ Node.js v22.x - 需要 --no-experimental-strip-types 标志"
echo ""
echo "🚀 启动命令:"
echo "  Node.js v18: npm run start:v18"
echo "  Node.js v22: npm run start:v22"
echo "  自动检测:   npm start"