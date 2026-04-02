@echo off
REM Node.js v18.20.3 兼容性测试脚本

echo 🔍 Node.js v18.20.3 兼容性测试
echo ================================

REM 检查当前 Node 版本
for /f "tokens=*" %%i in ('node --version') do set CURRENT_NODE=%%i
echo 📌 当前 Node 版本: %CURRENT_NODE%

REM 检查 .d.ts 文件问题
echo.
echo 🔍 检查 .d.ts 文件导入问题...

findstr /S /M "import.*\.d\.ts" node_modules\@shipany\open-agent-sdk\dist\ink\components\*.js >nul 2>&1
if %errorlevel% equ 0 (
    echo ❌ 发现 .d.ts 导入问题！需要应用修复
    echo.
    echo 🔧 应用修复...

    REM 修复 Box.js
    if exist "node_modules\@shipany\open-agent-sdk\dist\ink\components\Box.js" (
        powershell -Command "(Get-Content 'node_modules\@shipany\open-agent-sdk\dist\ink\components\Box.js') -replace \"import '\.\./global\.d\.ts';\", '// import ''../global.d.ts''' | Set-Content 'node_modules\@shipany\open-agent-sdk\dist\ink\components\Box.js'"
        echo ✅ 已修复 Box.js
    )

    REM 修复 ScrollBox.js
    if exist "node_modules\@shipany\open-agent-sdk\dist\ink\components\ScrollBox.js" (
        powershell -Command "(Get-Content 'node_modules\@shipany\open-agent-sdk\dist\ink\components\ScrollBox.js') -replace \"import '\.\./global\.d\.ts';\", '// import ''../global.d.ts''' | Set-Content 'node_modules\@shipany\open-agent-sdk\dist\ink\components\ScrollBox.js'"
        echo ✅ 已修复 ScrollBox.js
    )

    echo 🔄 重新测试 SDK 导入...
    node -e "import('@shipany/open-agent-sdk').then(() => console.log('✅ SDK 修复后导入成功'))" 2>nul
    if %errorlevel% equ 0 (
        echo ✅ SDK 修复成功！
    ) else (
        echo ❌ SDK 修复后仍然失败
        exit /b 1
    )
) else (
    echo ✅ 没有发现 .d.ts 导入问题
)

REM 测试 SDK 导入
echo.
echo 🧪 测试 SDK 导入...
node -e "import('@shipany/open-agent-sdk').then(() => console.log('✅ SDK 导入成功'))" 2>nul
if %errorlevel% equ 0 (
    echo ✅ SDK 在当前 Node 版本中工作正常
) else (
    echo ❌ SDK 导入失败
    exit /b 1
)

REM 测试程序启动
echo.
echo 🚀 测试程序启动...
timeout /t 3 >nul
start /B npm start

echo.
echo ✨ Node.js v18.20.3 兼容性测试完成！
echo.
echo 📋 兼容性说明:
echo   ✅ Node.js v18.x - 完全兼容（不需要 --no-experimental-strip-types）
echo   ✅ Node.js v22.x - 需要 --no-experimental-strip-types 标志
echo.
echo 🚀 启动命令:
echo   Node.js v18: npm run start:v18
echo   Node.js v22: npm run start:v22
echo   自动检测:   npm start