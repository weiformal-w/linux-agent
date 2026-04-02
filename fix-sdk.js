#!/usr/bin/env node

/**
 * 彻底修复 SDK 的 .d.ts 导入问题
 * 直接删除包含 .d.ts 的行，而不是注释
 */

import fs from 'fs';
import path from 'path';
import { execSync } from 'child_process';

console.log('🔧 开始修复 SDK .d.ts 导入问题...\n');

const filesToFix = [
  'node_modules/@shipany/open-agent-sdk/dist/ink/components/Box.js',
  'node_modules/@shipany/open-agent-sdk/dist/ink/components/ScrollBox.js'
];

let fixedCount = 0;

filesToFix.forEach(filePath => {
  const fullPath = path.join(process.cwd(), filePath);

  if (!fs.existsSync(fullPath)) {
    console.log(`⚠️  文件不存在: ${filePath}`);
    return;
  }

  console.log(`📝 处理文件: ${filePath}`);

  try {
    let content = fs.readFileSync(fullPath, 'utf8');
    const originalContent = content;

    // 删除包含 .d.ts 导入的行
    const lines = content.split('\n');
    const filteredLines = lines.filter(line => {
      // 删除包含 .d.ts 导入的行（包括被注释的）
      return !line.includes('.d.ts') && !line.includes('global.d.ts');
    });

    content = filteredLines.join('\n');

    if (content !== originalContent) {
      fs.writeFileSync(fullPath, content, 'utf8');
      console.log(`✅ 已修复: ${filePath}`);
      fixedCount++;
    } else {
      console.log(`ℹ️  无需修复: ${filePath}`);
    }
  } catch (error) {
    console.error(`❌ 修复失败 ${filePath}:`, error.message);
  }
});

console.log(`\n✨ 修复完成！共修复了 ${fixedCount} 个文件。`);

// 验证修复
console.log('\n🧪 验证修复结果...');

try {
  execSync('node -e "import(\'@shipany/open-agent-sdk\').then(() => console.log(\'✅ SDK 导入成功！\'))"', {
    stdio: 'inherit',
    timeout: 10000
  });
  console.log('\n🎉 SDK 修复验证成功！');
} catch (error) {
  console.error('\n❌ SDK 验证失败，请检查错误信息。');
  process.exit(1);
}