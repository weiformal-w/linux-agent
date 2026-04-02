@echo off
REM 智能启动脚本 - 自动检测 Node.js 版本并使用合适的启动参数

echo 🤖 Linux Agent 智能启动
echo =======================

REM 检测 Node.js 版本
for /f "tokens=1 delims=v" %%i in ('node --version') do set NODE_VERSION=%%i
echo 📌 检测到 Node.js 版本: v%NODE_VERSION%

REM 提取主版本号
for /f "tokens=1 delims=." %%i in ("%NODE_VERSION%") do set MAJOR_VERSION=%%i

REM 根据版本选择启动命令
if "%MAJOR_VERSION%"=="18" goto V18
if "%MAJOR_VERSION%"=="19" goto V18
if "%MAJOR_VERSION%"=="20" goto V18
if "%MAJOR_VERSION%"=="22" goto V22
if "%MAJOR_VERSION%"=="23" goto V22
if "%MAJOR_VERSION%"=="24" goto V22
if "%MAJOR_VERSION%"=="25" goto V22

:V18
echo ✅ 使用 Node.js v18-v20 兼容模式
echo.
node cli.js %*
goto END

:V22
echo ✅ 使用 Node.js v22+ 兼容模式
echo.
node --no-experimental-strip-types cli.js %*
goto END

:END