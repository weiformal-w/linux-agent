# 基于修复后的 SDK 创建新应用指南

## 🚀 快速开始

### 方法 1: 使用当前项目作为模板

1. **复制当前项目作为新项目**
```bash
# 在当前项目目录下
cp -r . ../my-new-agent
cd ../my-new-agent
```

2. **修改 package.json**
```json
{
  "name": "my-new-agent",
  "description": "我的新 Agent 应用",
  "bin": {
    "my-agent": "./cli.js"
  }
}
```

3. **修改 cli.js**
```javascript
// 修改你的 system prompt 和功能
import { createAgent } from '@shipany/open-agent-sdk'

const MY_SYSTEM_PROMPT = `你是一个...`  // 你的定制化 prompt

const agent = createAgent({
  model: 'claude-sonnet-4-6',
  systemPrompt: MY_SYSTEM_PROMPT,
  // 其他配置...
})
```

### 方法 2: 创建独立项目但使用修复的 SDK

1. **创建新项目**
```bash
mkdir my-new-agent
cd my-new-agent
npm init -y
```

2. **创建 package.json**
```json
{
  "name": "my-new-agent",
  "version": "1.0.0",
  "type": "module",
  "main": "index.js",
  "bin": {
    "my-agent": "./cli.js"
  },
  "scripts": {
    "start": "node --no-experimental-strip-types cli.js"
  },
  "dependencies": {
    "@shipany/open-agent-sdk": "^0.1.0",
    "chalk": "^5.3.0"
  }
}
```

3. **复制修复的 SDK 文件**
```bash
# 从当前项目复制修复的 node_modules
mkdir -p node_modules/@shipany
cp -r ../linux-agent/node_modules/@shipany/open-agent-sdk ./node_modules/@shipany/
```

4. **创建 .npmrc**
```
ignore-scripts=true
```

## 🔧 关键修复说明

如果你的新项目需要重新应用修复，需要修改以下文件：

### 1. 修复 .d.ts 导入问题
```bash
# 在 node_modules/@shipany/open-agent-sdk/dist/ink/components/ 目录下
sed -i "s/import '..\/global.d.ts';/\/\/ import '..\/global.d.ts';/" Box.js ScrollBox.js
```

### 2. 修复 Bun.semver 问题
编辑 `node_modules/@shipany/open-agent-sdk/dist/setup-globals.js`，添加 semver 支持（参考当前修复）

## 📦 推荐项目结构

```
my-new-agent/
├── package.json
├── .npmrc
├── cli.js              # 主入口
├── session-manager.js  # 会话管理（可选）
├── prompts/
│   └── system.js       # System prompts
└── tools/              # 自定义工具（可选）
```

## ⚠️ 重要提醒

1. **始终使用 `--no-experimental-strip-types` 标志**
2. **保留 `.npmrc` 中的 `ignore-scripts=true`**
3. **复制修复后的 SDK 文件到新项目**

## 🎯 下一步

- 修改 cli.js 中的 system prompt 定制你的 Agent
- 添加自定义的工具和功能
- 配置允许的工具列表
- 设置 hooks 自定义行为