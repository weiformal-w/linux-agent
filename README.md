# 🤖 Linux Agent

> Natural language interface for Linux system operations powered by Claude AI

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Node Version](https://img.shields.io/badge/node-%3E=18.0.0-brightgreen)](https://nodejs.org)
[![SDK](https://img.shields.io/badge/sdk-@shipany/open--agent--sdk-blue)](https://github.com/shipany-ai/open-agent-sdk)

用自然语言操作 Linux 系统的 AI Agent，支持完整的会话管理功能。

## ✨ 功能特性

### 核心功能
- ✅ **自然语言交互** - 用中文描述任务，自动执行 Linux 命令
- ✅ **智能命令执行** - 自动选择合适的命令和参数
- ✅ **安全限制** - 禁止危险操作，保护系统安全
- ✅ **实时反馈** - 显示执行的命令和输出结果
- ✅ **文件操作** - 支持读取、编辑、搜索文件

### 会话管理
- ✅ **多会话支持** - 创建和管理多个独立会话
- ✅ **会话持久化** - 自动保存对话历史到 `~/.linux-agent/sessions/`
- ✅ **会话恢复** - 随时加载历史会话继续对话
- ✅ **导出功能** - 导出会话为 Markdown 或 JSON 格式
- ✅ **自动保存** - 每 5 轮对话自动保存

## 📦 安装

### ⚠️ 重要：SDK 需要修复

此项目依赖的 `@shipany/open-agent-sdk` 有编译问题，需要修复后才能使用。

### 方法 1: 使用自动安装脚本（推荐）

**Linux/Mac:**
```bash
git clone https://github.com/weiformal-w/linux-agent.git
cd linux-agent
chmod +x install.sh
./install.sh
```

**Windows:**
```cmd
git clone https://github.com/weiformal-w/linux-agent.git
cd linux-agent
install.bat
```

### 方法 2: 手动安装

```bash
# 1. 克隆仓库
git clone https://github.com/weiformal-w/linux-agent.git
cd linux-agent

# 2. 临时修改 .npmrc 允许脚本运行
echo "ignore-scripts=false" > .npmrc

# 3. 安装依赖
npm install

# 4. 运行修复脚本
node fix-sdk.js

# 5. 验证修复
npm run test:sdk

# 6. 启动
npm start
```

### 📝 修复说明

如果启动时遇到 `.d.ts` 导入错误，运行：

```bash
node fix-sdk.js
```

详细修复说明请查看 [FIX-GUIDE.md](./FIX-GUIDE.md)

## 🚀 使用指南

### 基础使用

```
❯ 查看系统内存使用情况
▶ 执行命令: free -h
输出: total used free shared buff/cache available
Mem: 7.6G 3.2G 2.1G 234M 2.3G 4.1G

📝 系统总内存为 7.6GB，已使用 3.2GB，剩余 2.1GB 可用

❯ 查看 /var/log 下最大的文件
▶ 执行命令: du -sh /var/log/* | sort -rh | head -5
...
```

### 会话管理命令

| 命令 | 说明 |
|------|------|
| `/sessions` | 查看所有历史会话 |
| `/load <id>` | 加载指定会话继续对话 |
| `/new` | 创建新会话 |
| `/save` | 保存当前会话 |
| `/export <id> [format]` | 导出会话（默认 markdown，可选 json） |
| `/delete <id>` | 删除会话 |
| `/history` | 查看当前会话历史 |
| `/clear` | 清空当前会话 |
| `/help` | 显示帮助信息 |
| `exit` 或 `/exit` | 退出程序 |

### 使用场景示例

```
# 系统监控
❯ 检查系统负载和内存使用
❯ 查看占用 CPU 最高的进程
❯ 检查磁盘空间使用情况

# 日志分析
❯ 查找 /var/log 中最近的错误日志
❯ 统计 nginx 访问日志中的 IP 排名
❯ 监控系统日志中的失败登录

# 文件操作
❯ 查找所有大于 100MB 的文件
❯ 搜索包含 "TODO" 的代码文件
❯ 批量重命名当前目录的文件

# 服务管理
❯ 重启 nginx 服务
❯ 查看 docker 容器状态
❯ 检查 MySQL 服务是否运行

# 自动化任务
❯ 创建定时任务备份数据库
❯ 清理 30 天前的日志文件
❯ 监控进程并自动重启
```

## 📁 文件结构

```
linux-agent/
├── cli.js                 # 主程序入口
├── session-manager.js     # 会话管理模块
├── package.json          # 依赖配置
└── README.md             # 使用文档

~/.linux-agent/
└── sessions/             # 会话存储目录
    ├── session-xxx.json
    └── session-yyy.json
```

## 🔒 安全机制

- ❌ 禁止执行危险命令（`rm -rf /`, `dd`, `mkfs` 等）
- ❌ 禁止删除系统关键文件
- ⚠️ 修改系统配置前会提示备份
- ⚠️ 删除操作需要路径确认
- ✅ 只能访问允许的工具（Read, Edit, Bash, Glob, Grep, Write）

## 📊 会话导出

```bash
# 导出为 Markdown（默认）
/export session-123

# 导出为 JSON
/export session-123 json

# 导出的文件会保存在当前目录
```

## 🛠️ 系统要求

- Node.js >= 18.0.0 (推荐 v18.20.3+)
- Linux 系统（Ubuntu, CentOS, Debian, Arch 等）
- ANTHROPIC_API_KEY

### Node.js 版本兼容性

| Node.js 版本 | 兼容性 | 启动命令 |
|-------------|-------|----------|
| v18.x - v20.x | ✅ 完全兼容 | `npm start` |
| v22.x - v24.x | ✅ 完全兼容 | `npm start` (自动适配) |

项目会自动检测你的 Node.js 版本并使用合适的启动参数。

- Node.js 18+
- Linux 系统（Ubuntu, CentOS, Debian, Arch 等）
- ANTHROPIC_API_KEY

## 💡 提示

- 使用 `/sessions` 查看历史会话
- 长时间使用建议定期 `/save` 保存会话
- 可以随时 `/new` 创建新会话处理不同任务
- 退出程序时会自动保存当前会话

## 🔧 SDK 修复说明

本项目修复了 `@shipany/open-agent-sdk` v0.1.7 的两个关键 bug：

### 🐛 Bug 1: .d.ts 文件导入错误
**问题**: SDK 错误地将 TypeScript 声明文件作为 ES module 导入
```
Error: ERR_UNSUPPORTED_NODE_MODULES_TYPE_STRIPPING
```

**修复**: 移除了 `Box.js` 和 `ScrollBox.js` 中对 `global.d.ts` 的错误导入
```javascript
// 修复前
import '../global.d.ts';

// 修复后
// import '../global.d.ts'; // Removed: .d.ts files should not be imported in JS
```

### 🐛 Bug 2: Bun.semver 兼容性问题
**问题**: Node.js 环境中缺少 `Bun.semver` 导致运行时错误
```
TypeError: Cannot read properties of undefined (reading 'satisfies')
```

**修复**: 在 `setup-globals.js` 中为 Node.js 环境添加了 semver 支持
```javascript
// 添加了 semver fallback 机制
if (typeof _global.Bun === 'undefined') {
    let _semver = require('semver');
    _global.Bun = {
        env: process.env,
        version: '0.0.0',
        sleep: (ms) => new Promise(r => setTimeout(r, ms)),
        semver: _semver, // 添加 semver 支持
    };
}
```

### 🔨 如何在其他项目中使用修复后的 SDK

#### 方法 1: 复制修复的文件
```bash
# 从本项目复制修复的 SDK
cp -r node_modules/@shipany/open-agent-sdk /your-project/node_modules/@shipany/
```

#### 方法 2: 使用自动脚本
```bash
# Linux/Mac
./create-agent.sh my-new-agent

# Windows
create-agent.bat my-new-agent
```

脚本会自动：
1. 创建项目结构
2. 安装依赖
3. 应用 SDK 修复
4. 生成基础模板

#### 方法 3: 手动修复
在你的项目中找到以下文件并应用相同的修复：
- `node_modules/@shipany/open-agent-sdk/dist/ink/components/Box.js`
- `node_modules/@shipany/open-agent-sdk/dist/ink/components/ScrollBox.js`
- `node_modules/@shipany/open-agent-sdk/dist/setup-globals.js`

## 🐛 Node.js v18.20.3 兼容性

如果你使用 Node.js v18.20.3，可能会遇到 `.d.ts` 文件导入问题。我们已经提供了自动修复工具：

```bash
# 运行兼容性测试和修复
npm run test:node18

# 或手动运行测试脚本
bash test-node18.sh    # Linux/Mac
test-node18.bat        # Windows
```

详细说明请查看 [NODE18-COMPATIBILITY.md](./NODE18-COMPATIBILITY.md)

## 📝 开发

### 基础开发

```bash
# 查看日志
DEBUG=* npm start

# 修改代码后重启
npm start
```

### 调用 Linux Agent 的 API

如果你想在自己的代码中调用 Linux Agent：

```javascript
import { createAgent } from '@shipany/open-agent-sdk'

// 创建 Agent 实例
const agent = createAgent({
  model: 'claude-sonnet-4-6',
  systemPrompt: '你是一个 Linux 系统管理助手',
  permissionMode: 'acceptEdits',
  allowedTools: ['Read', 'Edit', 'Bash', 'Glob', 'Grep', 'Write']
})

// 发送查询
const result = await agent.prompt('查看系统内存使用')
console.log(result.text)

// 使用特定工具
const toolResult = await agent.prompt('用 Bash 工具执行 ls -la')
```

### 自定义 System Prompt

编辑 `cli.js` 中的 `LINUX_SYSTEM_PROMPT` 来定制 Agent 的行为：

```javascript
const LINUX_SYSTEM_PROMPT = `你是一个专业的 Linux 系统管理助手。
// 定制你的 prompt
`
```

### 添加自定义工具

```javascript
const agent = createAgent({
  // ... 其他配置
  allowedTools: [
    'Read', 'Edit', 'Bash', 'Glob', 'Grep', 'Write',
    // 添加自定义工具
  ]
})
```

### 项目结构

```
linux-agent/
├── cli.js                 # 主程序入口
├── session-manager.js     # 会话管理模块
├── package.json          # 依赖配置
├── .npmrc                # npm 配置 (ignore-scripts=true)
├── create-agent.sh      # 创建新项目的脚本 (Linux/Mac)
├── create-agent.bat     # 创建新项目的脚本 (Windows)
├── create-new-app.md    # 详细创建指南
└── README.md            # 项目说明
```

## 🌟 使用场景

### 系统运维
- 自动化系统监控和告警
- 批量服务器配置管理
- 日志分析和错误排查

### 开发辅助
- 代码重构和格式化
- 自动化测试和部署
- 项目文档生成

### 学习工具
- Linux 命令学习和实践
- 系统管理最佳实践
- 脚本自动化示例

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

## 🙏 致谢

- [@shipany/open-agent-sdk](https://github.com/shipany-ai/open-agent-sdk) - 提供强大的 Agent SDK
- [Anthropic Claude](https://www.anthropic.com) - 提供 AI 能力

## 📮 联系方式

- 作者: weiformal-w
- GitHub: [@weiformal-w](https://github.com/weiformal-w)

---

⭐ 如果这个项目对你有帮助，请给个 Star！

```bash
# 查看日志
DEBUG=* npm start

# 修改代码后重启
npm start
```

## 📄 License

MIT
