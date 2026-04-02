#!/usr/bin/env node

/**
 * 智能启动器 - 自动检测 Node.js 版本并使用合适的启动参数
 * 解决 Node.js v18 和 v22 之间的兼容性问题
 */

const { exec } = require('child_process');
const path = require('path');

console.log('🤖 Linux Agent 智能启动');
console.log('=======================\n');

// 获取 Node.js 版本
const nodeVersion = process.version;
console.log(`📌 检测到 Node.js 版本: ${nodeVersion}`);

// 提取主版本号
const majorVersion = parseInt(nodeVersion.slice(1).split('.')[0]);

let command;
let args = ['cli.js', ...process.argv.slice(2)];

// 根据版本选择启动命令
switch (majorVersion) {
    case 18:
    case 19:
    case 20:
        console.log('✅ 使用 Node.js v18-v20 兼容模式');
        command = 'node';
        break;
    case 22:
    case 23:
    case 24:
    case 25:
        console.log('✅ 使用 Node.js v22+ 兼容模式');
        command = 'node';
        args = ['--no-experimental-strip-types', 'cli.js', ...process.argv.slice(2)];
        break;
    default:
        console.log('⚠️  未知的 Node.js 版本，尝试默认模式');
        command = 'node';
        break;
}

console.log('');

// 启动程序
const spawn = require('child_process').spawn;
const child = spawn(command, args, {
    stdio: 'inherit',
    cwd: process.cwd()
});

child.on('error', (err) => {
    console.error('❌ 启动失败:', err.message);
    process.exit(1);
});

child.on('exit', (code) => {
    process.exit(code || 0);
});