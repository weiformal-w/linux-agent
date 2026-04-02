#!/bin/bash

echo "🔧 快速修复 SDK 问题..."
echo ""

# 直接修复 .d.ts 导入问题
echo "📝 修复 Box.js..."
sed -i '/\.d\.ts/d' node_modules/@shipany/open-agent-sdk/dist/ink/components/Box.js

echo "📝 修复 ScrollBox.js..."
sed -i '/\.d\.ts/d' node_modules/@shipany/open-agent-sdk/dist/ink/components/ScrollBox.js

echo ""
echo "✅ 修复完成！现在可以运行: npm start"
echo ""