#!/usr/bin/env node

import { createAgent } from '@shipany/open-agent-sdk'
import readline from 'readline'
import chalk from 'chalk'
import ora from 'ora'
import { SessionManager } from './session-manager.js'

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
})

const sessionManager = new SessionManager()
let currentSessionId = null
let conversationHistory = []

// Linux 系统操作的 System Prompt
const LINUX_SYSTEM_PROMPT = `你是一个专业的 Linux 系统管理助手。你可以帮助用户：

1. **系统信息查询**
   - 查看系统状态：top, htop, ps aux, free -h
   - 查看磁盘使用：df -h, du -sh
   - 查看网络：ifconfig, netstat, ss
   - 查看日志：tail -f /var/log/*.log, journalctl

2. **文件操作**
   - 读取文件内容：cat, less, head, tail
   - 编辑文件：使用 Edit 工具（精确修改）
   - 查找文件：find, locate
   - 搜索文件内容：grep, rg

3. **系统管理**
   - 服务管理：systemctl, service
   - 用户管理：useradd, usermod
   - 权限管理：chmod, chown
   - 进程管理：kill, pkill

4. **软件包管理**
   - Debian/Ubuntu: apt, apt-get
   - CentOS/RHEL: yum, dnf
   - Arch: pacman

**重要限制：**
- ❌ 禁止执行危险命令：rm -rf /, dd, mkfs, :(){ :|:& };:
- ❌ 禁止删除系统关键文件
- ⚠️ 执行删除操作前必须确认路径
- ⚠️ 修改系统配置前建议先备份

**工作方式：**
- 用户用自然语言描述需求
- 你使用 Bash 工具执行相应的 Linux 命令
- 执行前说明即将执行的命令
- 执行后解释结果
- 如果命令可能影响系统，先询问用户确认

保持简洁，直接执行任务。`

// 创建 Agent（会动态更新）
function createAgentInstance() {
  // 检查 API Key
  const apiKey = process.env.ANTHROPIC_API_KEY
  if (!apiKey) {
    console.log(chalk.yellow('\n⚠️  警告: 未设置 ANTHROPIC_API_KEY'))
    console.log(chalk.gray('请设置环境变量: export ANTHROPIC_API_KEY=sk-ant-xxx'))
  }

  return createAgent({
    model: 'claude-sonnet-4-6',
    systemPrompt: LINUX_SYSTEM_PROMPT,
    permissionMode: 'acceptEdits',
    allowedTools: ['Read', 'Edit', 'Bash', 'Glob', 'Grep', 'Write'],
    // 添加超时设置
    apiKey: apiKey,
    hooks: {
      PreToolUse: async (toolName, input) => {
        if (toolName === 'Bash') {
          console.log(chalk.yellow('\n▶ 执行命令:'), chalk.cyan(input.command))
        }
      },
      PostToolUse: async (toolName, input, result) => {
        if (toolName === 'Bash' && result.data) {
          const output = result.data.trim()
          if (output) {
            console.log(chalk.gray('输出:'), output.substring(0, 500))
          }
        }
      }
    }
  })
}

let agent = createAgentInstance()

// 显示帮助信息
function showHelp() {
  console.log(chalk.cyan('\n📖 可用命令:\n'))
  console.log('  自然语言输入          - 执行 Linux 命令或提问题')
  console.log('  /sessions             - 查看所有会话')
  console.log('  /load <id>            - 加载指定会话')
  console.log('  /new                  - 创建新会话')
  console.log('  /save                 - 保存当前会话')
  console.log('  /export <id> [format] - 导出会话 (markdown/json)')
  console.log('  /delete <id>          - 删除会话')
  console.log('  /history              - 查看当前会话历史')
  console.log('  /clear                - 清空当前会话')
  console.log('  /help                 - 显示帮助')
  console.log('  /exit 或 exit         - 退出程序\n')
}

// 显示会话列表
async function showSessions() {
  const sessions = await sessionManager.listSessions()
  if (sessions.length === 0) {
    console.log(chalk.yellow('\n📭 暂无会话记录\n'))
    return
  }

  console.log(chalk.cyan('\n📚 会话列表:\n'))
  sessions.forEach((s, i) => {
    const current = s.id === currentSessionId ? chalk.green(' [当前]') : ''
    console.log(`  ${chalk.gray(i + 1)}. ${chalk.white(s.title)}${current}`)
    console.log(`     ID: ${chalk.gray(s.id)}`)
    console.log(`     消息数: ${chalk.gray(s.messageCount)} | 修改: ${chalk.gray(s.modified.toLocaleString())}`)
    console.log()
  })
}

// 加载会话
async function loadSession(sessionId) {
  const session = await sessionManager.loadSession(sessionId)
  if (!session) {
    console.log(chalk.red('\n❌ 会话不存在\n'))
    return
  }

  currentSessionId = sessionId
  conversationHistory = session.messages || []

  // 重建 Agent 并恢复上下文
  agent = createAgentInstance()
  console.log(chalk.cyan(`\n✓ 已加载会话: ${session.title}`))
  console.log(chalk.gray(`  消息数: ${conversationHistory.length}\n`))
}

// 保存会话
async function saveSession() {
  if (conversationHistory.length === 0) {
    console.log(chalk.yellow('\n⚠️ 当前会话为空，无需保存\n'))
    return
  }

  const sessionId = currentSessionId || `session-${Date.now()}`
  await sessionManager.saveSession(sessionId, conversationHistory)
  currentSessionId = sessionId
  console.log(chalk.cyan(`\n✓ 会话已保存: ${sessionId}\n`))
}

// 导出会话
async function exportSession(sessionId, format = 'markdown') {
  try {
    const content = await sessionManager.exportSession(sessionId, format)
    const filename = `${sessionId}.${format === 'json' ? 'json' : 'md'}`
    await import('fs/promises').then(fs => fs.writeFile(filename, content))
    console.log(chalk.cyan(`\n✓ 已导出到: ${filename}\n`))
  } catch (err) {
    console.log(chalk.red(`\n❌ 导出失败: ${err.message}\n`))
  }
}

// 删除会话
async function deleteSession(sessionId) {
  const success = await sessionManager.deleteSession(sessionId)
  if (success) {
    if (currentSessionId === sessionId) {
      currentSessionId = null
      conversationHistory = []
    }
    console.log(chalk.cyan(`\n✓ 已删除会话: ${sessionId}\n`))
  } else {
    console.log(chalk.red('\n❌ 删除失败\n'))
  }
}

// 显示当前会话历史
function showHistory() {
  if (conversationHistory.length === 0) {
    console.log(chalk.yellow('\n📭 当前会话为空\n'))
    return
  }

  console.log(chalk.cyan('\n📜 当前会话历史:\n'))
  conversationHistory.forEach((msg, i) => {
    const role = msg.role === 'user' ? chalk.green('👤 用户') : chalk.blue('🤖 Agent')
    console.log(`  ${chalk.gray(i + 1)}. ${role}`)
    if (typeof msg.content === 'string') {
      console.log(`     ${msg.content.substring(0, 50)}...`)
    }
  })
  console.log()
}

// 处理命令
async function handleCommand(input) {
  const parts = input.trim().split(/\s+/)
  const cmd = parts[0].toLowerCase()
  const args = parts.slice(1)

  switch (cmd) {
    case '/sessions':
      await showSessions()
      break
    case '/load':
      if (!args[0]) {
        console.log(chalk.red('\n❌ 请指定会话 ID\n'))
      } else {
        await loadSession(args[0])
      }
      break
    case '/new':
      currentSessionId = null
      conversationHistory = []
      agent = createAgentInstance()
      console.log(chalk.cyan('\n✓ 已创建新会话\n'))
      break
    case '/save':
      await saveSession()
      break
    case '/export':
      if (!args[0]) {
        console.log(chalk.red('\n❌ 请指定会话 ID\n'))
      } else {
        await exportSession(args[0], args[1] || 'markdown')
      }
      break
    case '/delete':
      if (!args[0]) {
        console.log(chalk.red('\n❌ 请指定会话 ID\n'))
      } else {
        await deleteSession(args[0])
      }
      break
    case '/history':
      showHistory()
      break
    case '/clear':
      currentSessionId = null
      conversationHistory = []
      agent = createAgentInstance()
      console.log(chalk.cyan('\n✓ 已清空当前会话\n'))
      break
    case '/help':
      showHelp()
      break
    case '/exit':
    case 'exit':
      // 自动保存当前会话
      if (conversationHistory.length > 0) {
        await saveSession()
      }
      console.log(chalk.yellow('\n👋 再见！\n'))
      return false
    default:
      console.log(chalk.red('\n❌ 未知命令，输入 /help 查看帮助\n'))
  }

  return true
}

async function main() {
  console.log(chalk.cyan('\n🤖 Linux Agent 已启动'))
  console.log(chalk.gray('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'))
  console.log(chalk.gray('输入 /help 查看所有命令\n'))

  // 尝试恢复上次的会话
  const sessions = await sessionManager.listSessions()
  if (sessions.length > 0) {
    console.log(chalk.gray(`💡 发现 ${sessions.length} 个历史会话，使用 /sessions 查看\n`))
  }

  let shouldExit = false

  while (!shouldExit) {
    const prompt = await new Promise((resolve) => {
      const prefix = currentSessionId ? chalk.gray(`[${currentSessionId.substring(0, 8)}] `) : ''
      rl.question(prefix + chalk.green('❯ '), resolve)
    })

    if (!prompt.trim()) continue

    // 处理命令
    if (prompt.startsWith('/')) {
      const shouldContinue = await handleCommand(prompt)
      if (!shouldContinue) {
        shouldExit = true
        break
      }
      continue
    }

    if (prompt.toLowerCase() === 'exit') {
      shouldExit = true
      break
    }

    const spinner = ora('思考中...').start()

    try {
      // 添加超时保护
      const timeoutPromise = new Promise((_, reject) =>
        setTimeout(() => reject(new Error('请求超时 (30秒)')), 30000)
      )

      const result = await Promise.race([
        agent.prompt(prompt),
        timeoutPromise
      ])

      spinner.stop()

      // 显示 Agent 的回复
      if (result.text) {
        console.log(chalk.white('\n📝'), result.text)
      }

      // 保存到会话历史
      conversationHistory.push(
        { role: 'user', content: prompt },
        { role: 'assistant', content: result.text || '' }
      )

      // 显示 token 使用情况
      if (result.usage) {
        const tokens = result.usage.input_tokens + result.usage.output_tokens
        console.log(chalk.gray(`\n💰 Tokens: ${tokens}`))
      }

      // 自动保存会话（每 5 轮对话）
      if (conversationHistory.length % 10 === 0 && conversationHistory.length > 0) {
        await saveSession()
      }
    } catch (error) {
      spinner.stop()

      // 详细的错误处理
      if (error.message.includes('超时')) {
        console.error(chalk.red('\n⏱️  请求超时'))
        console.error(chalk.gray('可能原因:'))
        console.error(chalk.gray('1. 网络连接问题'))
        console.error(chalk.gray('2. API 服务暂时不可用'))
        console.error(chalk.gray('3. 需要代理（如果在中国大陆）'))
        console.error(chalk.gray('\n建议运行: node diagnose-api.js'))
      } else if (error.message.includes('API')) {
        console.error(chalk.red('\n🔑 API 错误:'), error.message)
        console.error(chalk.gray('请检查 ANTHROPIC_API_KEY 是否正确'))
      } else {
        console.error(chalk.red('\n❌ 错误:'), error.message)
      }

      // 显示完整错误用于调试
      if (process.env.DEBUG) {
        console.error(chalk.gray('\n详细信息:'), error)
      }
    }

    console.log()
  }

  // 确保 readline 被正确关闭
  rl.close()
}

main().catch(console.error)
