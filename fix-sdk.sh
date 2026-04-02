#!/bin/bash

# 彻底修复 SDK 的 .d.ts 导入问题
# 直接删除包含 .d.ts 的行

echo "🔧 开始修复 SDK .d.ts 导入问题..."
echo ""

FILES=(
  "node_modules/@shipany/open-agent-sdk/dist/ink/components/Box.js"
  "node_modules/@shipany/open-agent-sdk/dist/ink/components/ScrollBox.js"
)

FIXED_COUNT=0

for FILE in "${FILES[@]}"; do
  if [ ! -f "$FILE" ]; then
    echo "⚠️  文件不存在: $FILE"
    continue
  fi

  echo "📝 处理文件: $FILE"

  # 删除包含 .d.ts 的行
  sed -i '/\.d\.ts/d' "$FILE"

  if [ $? -eq 0 ]; then
    echo "✅ 已修复: $FILE"
    ((FIXED_COUNT++))
  else
    echo "❌ 修复失败: $FILE"
  fi
done

echo ""
echo "✨ 修复完成！共修复了 $FIXED_COUNT 个文件。"
echo ""
echo "🧪 验证修复结果..."

if node -e "import('@shipany/open-agent-sdk').then(() => console.log('✅ SDK 导入成功！'))" 2>/dev/null; then
  echo ""
  echo "🎉 SDK 修复验证成功！"
else
  echo ""
  echo "❌ SDK 验证失败，请检查错误信息。"
  exit 1
fi