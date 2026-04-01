# Linux Agent

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

```bash
# 1. 克隆或上传到 Linux 服务器
cd linux-agent

# 2. 安装依赖
npm install

# 3. 设置环境变量
export ANTHROPIC_API_KEY=sk-ant-xxx

# 4. 启动
npm start
```

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

- Node.js 18+
- Linux 系统（Ubuntu, CentOS, Debian, Arch 等）
- ANTHROPIC_API_KEY

## 💡 提示

- 使用 `/sessions` 查看历史会话
- 长时间使用建议定期 `/save` 保存会话
- 可以随时 `/new` 创建新会话处理不同任务
- 退出程序时会自动保存当前会话

## 📝 开发

```bash
# 查看日志
DEBUG=* npm start

# 修改代码后重启
npm start
```

## 📄 License

MIT
