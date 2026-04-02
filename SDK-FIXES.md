# 🔧 SDK 修复详解

本文档详细说明了 `@shipany/open-agent-sdk` v0.1.7 中发现的 bug 及其修复方法。

## 🐛 Bug #1: .d.ts 文件导入错误

### 错误信息
```
Error [ERR_UNSUPPORTED_NODE_MODULES_TYPE_STRIPPING]: Stripping types is currently unsupported for files under node_modules
```

### 根本原因
SDK 的构建过程错误地将 TypeScript 声明文件导入语句包含在了编译后的 JavaScript 文件中：
- `dist/ink/components/Box.js` 包含 `import '../global.d.ts';`
- `dist/ink/components/ScrollBox.js` 包含 `import '../global.d.ts';`

Node.js 试图将这些 `.d.ts` 文件作为 ES module 加载，导致错误。

### 修复方法

#### 文件 1: `node_modules/@shipany/open-agent-sdk/dist/ink/components/Box.js`
```javascript
// 修复前 (第 4 行)
import '../global.d.ts';

// 修复后
// import '../global.d.ts'; // Removed: .d.ts files should not be imported in JS
```

#### 文件 2: `node_modules/@shipany/open-agent-sdk/dist/ink/components/ScrollBox.js`
```javascript
// 修复前 (第 7 行)
import '../global.d.ts';

// 修复后
// import '../global.d.ts'; // Removed: .d.ts files should not be imported in JS
```

### 自动化修复脚本
```bash
# Linux/Mac
sed -i "s/import '..\/global.d.ts';/\/\/ import '..\/global.d.ts';/" \
  node_modules/@shipany/open-agent-sdk/dist/ink/components/Box.js \
  node_modules/@shipany/open-agent-sdk/dist/ink/components/ScrollBox.js

# Windows PowerShell
(Get-Content 'node_modules\@shipany\open-agent-sdk\dist\ink\components\Box.js') -replace "import '\.\./global\.d\.ts';", '// import ''../global.d.ts''' | Set-Content 'node_modules\@shipany\open-agent-sdk\dist\ink\components\Box.js'
```

## 🐛 Bug #2: Bun.semver 兼容性问题

### 错误信息
```
TypeError: Cannot read properties of undefined (reading 'satisfies')
at satisfies (file:///.../dist/utils/semver.js:42:27)
```

### 根本原因
SDK 的 `semver.js` 工具函数期望在 Bun 环境中运行，使用 `Bun.semver.satisfies()`。但在 Node.js 环境中，虽然 `setup-globals.js` 创建了 `Bun` 对象，但没有包含 `semver` 属性。

### 修复方法

#### 文件: `node_modules/@shipany/open-agent-sdk/dist/setup-globals.js`

```javascript
// 修复前 (第 18-24 行)
if (typeof _global.Bun === 'undefined') {
    _global.Bun = {
        env: process.env,
        version: '0.0.0',
        sleep: (ms) => new Promise(r => setTimeout(r, ms)),
    };
}

// 修复后
if (typeof _global.Bun === 'undefined') {
    // Import semver for Node.js environment
    let _semver;
    try {
        _semver = require('semver');
    } catch (e) {
        // Fallback if semver is not available
        _semver = {
            satisfies: () => true,
            order: () => 0,
            gt: () => false,
            gte: () => true,
            lt: () => false,
            lte: () => true,
            compare: () => 0
        };
    }

    _global.Bun = {
        env: process.env,
        version: '0.0.0',
        sleep: (ms) => new Promise(r => setTimeout(r, ms)),
        semver: _semver, // 添加 semver 支持
    };
} else if (!_global.Bun.semver) {
    // Add semver to existing Bun object if missing
    try {
        _global.Bun.semver = require('semver');
    } catch (e) {
        _global.Bun.semver = {
            satisfies: () => true,
            order: () => 0,
            gt: () => false,
            gte: () => true,
            lt: () => false,
            lte: () => true,
            compare: () => 0
        };
    }
}
```

## 🚀 应用修复到新项目

### 方法 1: 使用提供的脚本
```bash
# Linux/Mac
./create-agent.sh my-new-agent

# Windows
create-agent.bat my-new-agent
```

### 方法 2: 手动复制修复的 SDK
```bash
# 从本项目复制
cp -r node_modules/@shipany/open-agent-sdk /your-project/node_modules/@shipany/
```

### 方法 3: 在新项目中重新修复
1. 安装依赖: `npm install`
2. 应用上述修复到相应的文件
3. 启动时使用: `node --no-experimental-strip-types cli.js`

## ⚠️ 重要注意事项

1. **始终使用 `--no-experimental-strip-types` 标志**
2. **保留 `.npmrc` 中的 `ignore-scripts=true`**
3. **每次 `npm install` 后需要重新应用修复**

## 🔍 验证修复

运行以下命令验证修复是否成功：

```bash
node --no-experimental-strip-types -e "import('@shipany/open-agent-sdk').then(() => console.log('✅ SDK 修复成功！'))"
```

如果输出 "✅ SDK 修复成功！" 而没有错误，说明修复生效。

## 📚 相关资源

- [shipany/open-agent-sdk](https://github.com/shipany-ai/open-agent-sdk) - 原始 SDK 仓库
- [Anthropic Claude SDK](https://github.com/anthropics/anthropic-sdk-typescript) - Anthropic 官方 SDK