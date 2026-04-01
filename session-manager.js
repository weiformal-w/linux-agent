import fs from 'fs/promises'
import path from 'path'
import os from 'os'
import chalk from 'chalk'

const SESSION_DIR = path.join(os.homedir(), '.linux-agent', 'sessions')

export class SessionManager {
  async ensureSessionDir() {
    try {
      await fs.mkdir(SESSION_DIR, { recursive: true })
    } catch (err) {
      console.error('无法创建会话目录:', err.message)
    }
  }

  async listSessions() {
    await this.ensureSessionDir()
    try {
      const files = await fs.readdir(SESSION_DIR)
      const sessions = []

      for (const file of files) {
        if (file.endsWith('.json')) {
          const filePath = path.join(SESSION_DIR, file)
          const stats = await fs.stat(filePath)
          const content = JSON.parse(await fs.readFile(filePath, 'utf-8'))
          sessions.push({
            id: file.replace('.json', ''),
            created: new Date(content.created),
            modified: new Date(stats.mtime),
            messageCount: content.messages?.length || 0,
            title: content.title || '未命名会话'
          })
        }
      }

      return sessions.sort((a, b) => b.modified - a.modified)
    } catch (err) {
      return []
    }
  }

  async saveSession(sessionId, messages, title = null) {
    await this.ensureSessionDir()
    const sessionPath = path.join(SESSION_DIR, `${sessionId}.json`)

    const sessionData = {
      id: sessionId,
      created: Date.now(),
      messages,
      title: title || this.generateTitle(messages)
    }

    await fs.writeFile(sessionPath, JSON.stringify(sessionData, null, 2))
    return sessionPath
  }

  async loadSession(sessionId) {
    const sessionPath = path.join(SESSION_DIR, `${sessionId}.json`)
    try {
      const content = await fs.readFile(sessionPath, 'utf-8')
      return JSON.parse(content)
    } catch (err) {
      return null
    }
  }

  async deleteSession(sessionId) {
    const sessionPath = path.join(SESSION_DIR, `${sessionId}.json`)
    try {
      await fs.unlink(sessionPath)
      return true
    } catch (err) {
      return false
    }
  }

  generateTitle(messages) {
    // 从第一条用户消息提取标题
    const firstUserMessage = messages.find(m => m.role === 'user')
    if (firstUserMessage && firstUserMessage.content) {
      const text = typeof firstUserMessage.content === 'string'
        ? firstUserMessage.content
        : firstUserMessage.content.map(c => c.text).join(' ')
      return text.substring(0, 30) + (text.length > 30 ? '...' : '')
    }
    return '未命名会话'
  }

  async exportSession(sessionId, format = 'markdown') {
    const session = await this.loadSession(sessionId)
    if (!session) throw new Error('会话不存在')

    if (format === 'markdown') {
      let output = `# ${session.title}\n\n`
      output += `**创建时间**: ${new Date(session.created).toLocaleString()}\n\n`
      output += `---\n\n`

      for (const msg of session.messages) {
        const role = msg.role === 'user' ? '👤 用户' : '🤖 Agent'
        output += `## ${role}\n\n`

        if (typeof msg.content === 'string') {
          output += `${msg.content}\n\n`
        } else if (Array.isArray(msg.content)) {
          for (const block of msg.content) {
            if (block.type === 'text') {
              output += `${block.text}\n\n`
            } else if (block.type === 'tool_use') {
              output += `**工具**: ${block.name}\n`
              output += `\`\`\`\n${JSON.stringify(block.input, null, 2)}\n\`\`\`\n\n`
            } else if (block.type === 'tool_result') {
              output += `**结果**:\n\`\`\`\n${block.content}\n\`\`\`\n\n`
            }
          }
        }
      }

      return output
    } else if (format === 'json') {
      return JSON.stringify(session, null, 2)
    }
  }
}
