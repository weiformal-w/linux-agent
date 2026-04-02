@echo off
REM 彻底修复 SDK 的 .d.ts 导入问题
REM 直接删除包含 .d.ts 的行

echo 🔧 开始修复 SDK .d.ts 导入问题...
echo.

set FILES=node_modules\@shipany\open-agent-sdk\dist\ink\components\Box.js node_modules\@shipany\open-agent-sdk\dist\ink\components\ScrollBox.js

set FIXED_COUNT=0

for %%F in (%FILES%) do (
    if not exist "%%F" (
        echo ⚠️  文件不存在: %%F
        goto :nextfile
    )

    echo 📝 处理文件: %%F

    REM 使用 PowerShell 删除包含 .d.ts 的行
    powershell -Command "(Get-Content '%%F') | Where-Object { $_ -notlike '*\.d\.ts*' -and $_ -notlike '*global.d.ts*' } | Set-Content '%%F'"

    if %errorlevel% equ 0 (
        echo ✅ 已修复: %%F
        set /a FIXED_COUNT+=1
    ) else (
        echo ❌ 修复失败: %%F
    )

    :nextfile
)

echo.
echo ✨ 修复完成！共修复了 %FIXED_COUNT% 个文件。
echo.
echo 🧪 验证修复结果...

node -e "import('@shipany/open-agent-sdk').then(() => console.log('✅ SDK 导入成功！'))" 2>nul
if %errorlevel% equ 0 (
    echo.
    echo 🎉 SDK 修复验证成功！
) else (
    echo.
    echo ❌ SDK 验证失败，请检查错误信息。
    exit /b 1
)