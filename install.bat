@echo off
echo 🔧 Linux Agent 安装脚本
echo ======================

REM 1. 设置 npm 配置
echo 📝 配置 npm...
echo ignore-scripts=false > .npmrc

REM 2. 安装依赖
echo 📦 安装依赖...
call npm install

REM 3. 修复 SDK
echo 🔧 修复 SDK...
node fix-sdk.js

REM 4. 验证修复
echo 🧪 验证修复...
node -e "import('@shipany/open-agent-sdk').then(() =^> console.log('✅ SDK 修复成功！'))" 2>nul
if %errorlevel% equ 0 (
    echo ✨ 安装完成！
    echo.
    echo 🚀 启动应用:
    echo    npm start
) else (
    echo ❌ SDK 修复失败，请手动运行: node fix-sdk.js
    exit /b 1
)