#!/usr/bin/env node

/**
 * API 连接诊断工具
 * 帮助排查 Anthropic API 连接问题
 */

import chalk from 'chalk';
import { execSync } from 'child_process';

console.log(chalk.cyan('\n🔍 Anthropic API 连接诊断工具'));
console.log(chalk.gray('═'.repeat(50)));

// 1. 检查环境变量
console.log(chalk.yellow('\n📋 检查 1: 环境变量'));
const apiKey = process.env.ANTHROPIC_API_KEY;

if (!apiKey) {
  console.log(chalk.red('❌ 未找到 ANTHROPIC_API_KEY 环境变量'));
  console.log(chalk.gray('   请设置: export ANTHROPIC_API_KEY=sk-ant-xxx'));
} else if (apiKey.startsWith('sk-ant-')) {
  console.log(chalk.green('✅ ANTHROPIC_API_KEY 已设置'));
  console.log(chalk.gray(`   Key: ${apiKey.substring(0, 10)}...${apiKey.substring(apiKey.length - 4)}`));
} else {
  console.log(chalk.red('❌ API Key 格式不正确'));
  console.log(chalk.gray('   应该以 sk-ant- 开头'));
}

// 2. 检查网络连接
console.log(chalk.yellow('\n📋 检查 2: 网络连接'));
try {
  execSync('ping -c 1 api.anthropic.com', { stdio: 'pipe', timeout: 5000 });
  console.log(chalk.green('✅ 可以连接到 api.anthropic.com'));
} catch (error) {
  console.log(chalk.red('❌ 无法连接到 api.anthropic.com'));
  console.log(chalk.gray('   请检查网络连接或防火墙设置'));
}

// 3. 检查 DNS 解析
console.log(chalk.yellow('\n📋 检查 3: DNS 解析'));
try {
  execSync('nslookup api.anthropic.com', { stdio: 'pipe', timeout: 5000 });
  console.log(chalk.green('✅ DNS 解析正常'));
} catch (error) {
  console.log(chalk.red('❌ DNS 解析失败'));
  console.log(chalk.gray('   请检查 DNS 设置'));
}

// 4. 测试 API 连接
console.log(chalk.yellow('\n📋 检查 4: API 连接测试'));
if (apiKey && apiKey.startsWith('sk-ant-')) {
  try {
    const testResponse = await fetch('https://api.anthropic.com/v1/messages', {
      method: 'POST',
      headers: {
        'x-api-key': apiKey,
        'content-type': 'application/json',
        'anthropic-version': '2023-06-01'
      },
      body: JSON.stringify({
        model: 'claude-3-haiku-20240307',
        max_tokens: 10,
        messages: [{ role: 'user', content: 'Hi' }]
      }),
      signal: AbortSignal.timeout(10000) // 10 秒超时
    });

    if (testResponse.ok) {
      console.log(chalk.green('✅ API 连接成功！'));
    } else {
      console.log(chalk.red(`❌ API 返回错误: ${testResponse.status}`));
      const errorText = await testResponse.text();
      console.log(chalk.gray(`   ${errorText.substring(0, 200)}`));
    }
  } catch (error) {
    if (error.name === 'AbortError') {
      console.log(chalk.red('❌ API 请求超时'));
      console.log(chalk.gray('   可能是网络问题或需要代理'));
    } else {
      console.log(chalk.red(`❌ 连接失败: ${error.message}`));
    }
  }
} else {
  console.log(chalk.gray('⏭️  跳过 API 测试（没有有效的 API Key）'));
}

// 5. 检查代理设置
console.log(chalk.yellow('\n📋 检查 5: 代理设置'));
const httpProxy = process.env.HTTP_PROXY || process.env.http_proxy;
const httpsProxy = process.env.HTTPS_PROXY || process.env.https_proxy;

if (httpProxy || httpsProxy) {
  console.log(chalk.yellow('⚠️  检测到代理设置:'));
  if (httpProxy) console.log(chalk.gray(`   HTTP_PROXY: ${httpProxy}`));
  if (httpsProxy) console.log(chalk.gray(`   HTTPS_PROXY: ${httpsProxy}`));
  console.log(chalk.gray('   如果不需要代理，请取消设置'));
} else {
  console.log(chalk.green('✅ 没有代理设置'));
}

// 6. 给出解决方案
console.log(chalk.cyan('\n💡 常见解决方案:'));

console.log(chalk.white('\n1. 设置 API Key:'));
console.log(chalk.gray('   export ANTHROPIC_API_KEY=sk-ant-xxx'));

console.log(chalk.white('\n2. 如果在中国大陆，可能需要代理:'));
console.log(chalk.gray('   export HTTPS_PROXY=http://127.0.0.1:7890'));

console.log(chalk.white('\n3. 检查 API Key 是否有效:'));
console.log(chalk.gray('   访问 https://console.anthropic.com/settings/keys'));

console.log(chalk.white('\n4. 尝试使用更简单的模型测试:'));
console.log(chalk.gray('   修改 cli.js 中的 model 为 claude-3-haiku-20240307'));

console.log(chalk.cyan('\n' + '═'.repeat(50)));
console.log(chalk.cyan('诊断完成！\n'));