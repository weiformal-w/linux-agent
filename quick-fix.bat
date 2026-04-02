@echo off
REM 快速修复脚本 - 在安装后立即运行

echo 🔧 快速修复 SDK 问题...
echo.

REM 直接修复 .d.ts 导入问题
echo 📝 修复 Box.js...
powershell -Command "(Get-Content 'node_modules\@shipany\open-agent-sdk\dist\ink\components\Box.js') | Where-Object { $_ -notlike '*\.d\.ts*' } | Set-Content 'node_modules\@shipany\open-agent-sdk\dist\ink\components\Box.js'"

echo 📝 修复 ScrollBox.js...
powershell -Command "(Get-Content 'node_modules\@shipany\open-agent-sdk\dist\ink\components\ScrollBox.js') | Where-Object { $_ -notlike '*\.d\.ts*' } | Set-Content 'node_modules\@shipany\open-agent-sdk\dist\ink\components\ScrollBox.js'"

echo.
echo ✅ 修复完成！现在可以运行: npm start
echo.
pause