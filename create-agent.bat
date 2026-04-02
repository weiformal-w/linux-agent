@echo off
setlocal enabledelayedexpansion

if "%1"=="" (
    echo 用法: create-agent.bat ^<新项目名称^>
    echo 示例: create-agent.bat my-coding-agent
    exit /b 1
)

set PROJECT_NAME=%1
set PROJECT_DIR=..\%PROJECT_NAME%

echo 🚀 创建新 Agent 项目: %PROJECT_NAME%

:: 创建项目目录
if not exist "%PROJECT_DIR%" mkdir "%PROJECT_DIR%"
cd /d "%PROJECT_DIR%"

:: 初始化 npm
echo 📦 初始化项目...
npm init -y

:: 创建 .npmrc
echo ignore-scripts=true > .npmrc

:: 创建 package.json
(
echo {
echo   "name": "%PROJECT_NAME%",
echo   "version": "1.0.0",
echo   "description": "AI Agent powered by @shipany/open-agent-sdk",
echo   "type": "module",
echo   "main": "index.js",
echo   "bin": {
echo     "%PROJECT_NAME%": "./cli.js"
echo   },
echo   "scripts": {
echo     "start": "node --no-experimental-strip-types cli.js",
echo     "postinstall": "echo 'Skipping postinstall script for @shipany/open-agent-sdk'"
echo   },
echo   "dependencies": {
echo     "@shipany/open-agent-sdk": "^0.1.0",
echo     "chalk": "^5.3.0",
echo     "ora": "^8.0.1",
echo     "inquirer": "^9.2.12"
echo   },
echo   "keywords": ["agent", "ai", "cli"],
echo   "author": "",
echo   "license": "MIT"
echo }
) > package.json

:: 安装依赖
echo 📦 安装依赖...
call npm install --silent

:: 应用 SDK 修复
echo 🔧 应用 SDK 修复...
set SOURCE_SDK=..\linux-agent\node_modules\@shipany\open-agent-sdk
set TARGET_SDK=.\node_modules\@shipany\open-agent-sdk

if exist "%SOURCE_SDK%" (
    xcopy /E /I /Y "%SOURCE_SDK%" "%TARGET_SDK%" >nul

    :: 修复 .d.ts 导入问题
    powershell -Command "(Get-Content '%TARGET_SDK%\dist\ink\components\Box.js') -replace \"import '\.\./global\.d\.ts';\", '// import '\''../global.d.ts'\'';' | Set-Content '%TARGET_SDK%\dist\ink\components\Box.js'"
    powershell -Command "(Get-Content '%TARGET_SDK%\dist\ink\components\ScrollBox.js') -replace \"import '\.\./global\.d\.ts';\", '// import '\''../global.d.ts'\'';' | Set-Content '%TARGET_SDK%\dist\ink\components\ScrollBox.js'"

    echo ✅ SDK 修复已应用
) else (
    echo ⚠️  警告: 无法找到修复的 SDK，将使用 npm 版本（可能有 bug）
)

:: 创建基础 cli.js 模板
(
echo #!\/usr\/bin\/env node
echo.
echo import { createAgent } from '@shipany/open-agent-sdk'
echo import readline from 'readline'
echo import chalk from 'chalk'
echo.
echo const rl = readline.createInterface^({
echo   input: process.stdin,
echo   output: process.stdout
echo }^)
echo.
echo // 自定义你的 System Prompt
echo const SYSTEM_PROMPT = `你是一个有帮助的 AI 助手。
echo 你可以帮助用户完成各种任务。
echo.
echo 根据你的需求定制这个 prompt。`
echo.
echo // 创建 Agent
echo const agent = createAgent^({
echo   model: 'claude-sonnet-4-6',
echo   systemPrompt: SYSTEM_PROMPT,
echo   permissionMode: 'acceptEdits',
echo   allowedTools: ['Read', 'Edit', 'Bash', 'Glob', 'Grep', 'Write'],
echo   hooks: {
echo     PreToolUse: async ^(toolName, input^) =^> {
echo       if ^(toolName === 'Bash'^) {
echo         console.log^(chalk.yellow^('▶ 执行命令:'^), chalk.cyan^(input.command^)^)
echo       }
echo     }
echo   }
echo }^)
echo.
echo async function main^(^) {
echo   console.log^(chalk.cyan^('\n🤖 AI Agent 已启动'^)^)
echo   console.log^(chalk.gray^('━━━━━━━━━━━━━━━━━━━━━━'^)^)
echo   console.log^(chalk.gray^('输入 "exit" 退出\n'^)^)
echo.
echo   while ^(true^) {
echo     const prompt = await new Promise^(^(resolve^) =^> {
echo       rl.question^(chalk.green^('❯ '^), resolve^)
echo     }^)
echo.
echo     if ^(!prompt.trim^(^)^) continue
echo.
echo     if ^(prompt.toLowerCase^(^) === 'exit'^) {
echo       console.log^(chalk.yellow^('\n👋 再见！\n'^)^)
echo       rl.close^(^)
echo       break
echo     }
echo.
echo     try {
echo       const result = await agent.prompt^(prompt^)
echo       if ^(result.text^) {
echo         console.log^(chalk.white^('\n📝'^), result.text^)
echo       }
echo.
echo       if ^(result.usage^) {
echo         const tokens = result.usage.input_tokens + result.usage.output_tokens
echo         console.log^(chalk.gray^(`\n💰 Tokens: ${tokens}`^)^)
echo       }
echo     } catch ^(error^) {
echo       console.error^(chalk.red^('\n❌ 错误:'^), error.message^)
echo     }
echo.
echo     console.log^(^)
echo   }
echo }
echo.
echo main^(^).catch^(console.error^)
) > cli.js

echo.
echo ✨ 项目创建完成！
echo.
echo 📁 项目位置: %PROJECT_DIR%
echo 🚀 启动命令:
echo    cd %PROJECT_DIR%
echo    npm start
echo.
echo 🔧 下一步:
echo    1. 编辑 cli.js 中的 SYSTEM_PROMPT 定制你的 Agent
echo    2. 根据需要添加自定义工具和功能
echo.

endlocal