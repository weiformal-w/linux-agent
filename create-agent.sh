#!/bin/bash
# 创建新 Agent 项目的脚本

set -e

if [ -z "$1" ]; then
  echo "用法: ./create-agent.sh <新项目名称>"
  echo "示例: ./create-agent.sh my-coding-agent"
  exit 1
fi

PROJECT_NAME=$1
PROJECT_DIR="../$PROJECT_NAME"

echo "🚀 创建新 Agent 项目: $PROJECT_NAME"

# 1. 创建项目目录
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

# 2. 初始化 npm
npm init -y

# 3. 创建 .npmrc
cat > .npmrc << 'EOF'
ignore-scripts=true
EOF

# 4. 创建 package.json
cat > package.json << EOF
{
  "name": "$PROJECT_NAME",
  "version": "1.0.0",
  "description": "AI Agent powered by @shipany/open-agent-sdk",
  "type": "module",
  "main": "index.js",
  "bin": {
    "$PROJECT_NAME": "./cli.js"
  },
  "scripts": {
    "start": "node --no-experimental-strip-types cli.js",
    "dev": "node --no-experimental-strip-types --watch cli.js",
    "postinstall": "echo 'Skipping postinstall script for @shipany/open-agent-sdk'"
  },
  "dependencies": {
    "@shipany/open-agent-sdk": "^0.1.0",
    "chalk": "^5.3.0",
    "ora": "^8.0.1",
    "inquirer": "^9.2.12"
  },
  "keywords": ["agent", "ai", "cli"],
  "author": "",
  "license": "MIT"
}
EOF

# 5. 安装依赖
echo "📦 安装依赖..."
npm install --silent

# 6. 复制修复的 SDK 文件
echo "🔧 应用 SDK 修复..."
SOURCE_SDK="../linux-agent/node_modules/@shipany/open-agent-sdk"
TARGET_SDK="./node_modules/@shipany/open-agent-sdk"

if [ -d "$SOURCE_SDK" ]; then
  mkdir -p "$(dirname "$TARGET_SDK")"
  cp -r "$SOURCE_SDK" "$TARGET_SDK"

  # 修复 .d.ts 导入问题
  sed -i "s/import '..\/global.d.ts';/\/\/ import '..\/global.d.ts';/" \
    "$TARGET_SDK/dist/ink/components/Box.js" \
    "$TARGET_SDK/dist/ink/components/ScrollBox.js"

  echo "✅ SDK 修复已应用"
else
  echo "⚠️  警告: 无法找到修复的 SDK，将使用 npm 版本（可能有 bug）"
fi

# 7. 创建基础 cli.js 模板
cat > cli.js << 'EOF'
#!/usr/bin/env node

import { createAgent } from '@shipany/open-agent-sdk'
import readline from 'readline'
import chalk from 'chalk'

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
})

// 自定义你的 System Prompt
const SYSTEM_PROMPT = `你是一个有帮助的 AI 助手。
你可以帮助用户完成各种任务。

根据你的需求定制这个 prompt。`

// 创建 Agent
const agent = createAgent({
  model: 'claude-sonnet-4-6',
  systemPrompt: SYSTEM_PROMPT,
  permissionMode: 'acceptEdits',
  allowedTools: ['Read', 'Edit', 'Bash', 'Glob', 'Grep', 'Write'],
  hooks: {
    PreToolUse: async (toolName, input) => {
      if (toolName === 'Bash') {
        console.log(chalk.yellow('▶ 执行命令:'), chalk.cyan(input.command))
      }
    }
  }
})

async function main() {
  console.log(chalk.cyan('\n🤖 AI Agent 已启动'))
  console.log(chalk.gray('━━━━━━━━━━━━━━━━━━━━━━'))
  console.log(chalk.gray('输入 "exit" 退出\n'))

  while (true) {
    const prompt = await new Promise((resolve) => {
      rl.question(chalk.green('❯ '), resolve)
    })

    if (!prompt.trim()) continue

    if (prompt.toLowerCase() === 'exit') {
      console.log(chalk.yellow('\n👋 再见！\n'))
      rl.close()
      break
    }

    try {
      const result = await agent.prompt(prompt)
      if (result.text) {
        console.log(chalk.white('\n📝'), result.text)
      }

      if (result.usage) {
        const tokens = result.usage.input_tokens + result.usage.output_tokens
        console.log(chalk.gray(`\n💰 Tokens: ${tokens}`))
      }
    } catch (error) {
      console.error(chalk.red('\n❌ 错误:'), error.message)
    }

    console.log()
  }
}

main().catch(console.error)
EOF

# 8. 创建 README
cat > README.md << EOF
# $PROJECT_NAME

AI Agent powered by @shipany/open-agent-sdk.

## 安装

\`\`\`bash
npm install
\`\`\`

## 使用

\`\`\`bash
npm start
\`\`\`

## 定制

编辑 \`cli.js\` 中的 \`SYSTEM_PROMPT\` 来定制你的 Agent 行为。

## 可用命令

- \`npm start\` - 启动 Agent
- \`npm run dev\` - 开发模式（如果支持）

## 注意事项

此项目使用了修复后的 @shipany/open-agent-sdk，解决了以下问题：
- .d.ts 文件导入错误
- Bun.semver 兼容性问题
EOF

# 9. 设置执行权限
chmod +x cli.js

echo ""
echo "✨ 项目创建完成！"
echo ""
echo "📁 项目位置: $PROJECT_DIR"
echo "🚀 启动命令:"
echo "   cd $PROJECT_DIR"
echo "   npm start"
echo ""
echo "🔧 下一步:"
echo "   1. 编辑 cli.js 中的 SYSTEM_PROMPT 定制你的 Agent"
echo "   2. 根据需要添加自定义工具和功能"
echo ""