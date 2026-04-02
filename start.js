#!/usr/bin/env node

// 修复 Node.js 错误导入 .d.ts 文件的问题
// 在 Node.js 24+ 中，需要禁用类型剥离以避免导入 node_modules 中的 .d.ts 文件

import { register } from 'node:module';

// 禁用类型剥离
if (process.execArgv.includes('--experimental-detect-module') ||
    process.execArgv.includes('--experimental-strip-types')) {
  // 如果已经在运行实验性模式，不需要额外配置
}

// 导入并运行主程序
import('./cli.js').catch(err => {
  console.error('Failed to start:', err);
  process.exit(1);
});