# 🔧 Node.js v18.20.3 兼容性指南

## 📋 问题说明

在 Node.js v18.20.3 中，`@shipany/open-agent-sdk` 仍然存在 `.d.ts` 文件导入问题，但解决方案与 Node.js v22 不同。

## 🎯 Node.js 版本兼容性

| Node.js 版本 | .d.ts 问题 | 解决方案 | 启动命令 |
|-------------|-----------|----------|----------|
| **v18.x** | ✅ 有问题 | 需要手动修复文件 | `node cli.js` |
| **v20.x** | ✅ 有问题 | 需要手动修复文件 | `node cli.js` |
| **v22.x** | ✅ 有问题 | 需要 `--no-experimental-strip-types` | `node --no-experimental-strip-types cli.js` |
| **v24.x** | ✅ 有问题 | 需要 `--no-experimental-strip-types` | `node --no-experimental-strip-types cli.js` |

## 🛠️ 修复步骤

### 1. 自动修复（推荐）

**Linux/Mac:**
```bash
./test-node18.sh
```

**Windows:**
```cmd
test-node18.bat
```

### 2. 手动修复

如果自动脚本失败，可以手动修复以下文件：

#### 文件 1: `node_modules/@shipany/open-agent-sdk/dist/ink/components/Box.js`
```javascript
// 第 4 行，修复前
import '../global.d.ts';

// 修复后
// import '../global.d.ts'; // Removed: .d.ts files should not be imported in JS
```

#### 文件 2: `node_modules/@shipany/open-agent-sdk/dist/ink/components/ScrollBox.js`
```javascript
// 第 7 行，修复前
import '../global.d.ts';

// 修复后
// import '../global.d.ts'; // Removed: .d.ts files should not be imported in JS
```

#### 文件 3: `node_modules/@shipany/open-agent-sdk/dist/setup-globals.js`
添加 `semver` 支持（参见 [SDK-FIXES.md](./SDK-FIXES.md)）

## 🚀 启动方式

### 方式 1: 智能启动（推荐）

**Linux/Mac:**
```bash
chmod +x smart-start.sh
./smart-start.sh
```

**Windows:**
```cmd
smart-start.bat
```

**跨平台 Node.js:**
```bash
node smart-start.js
```

### 方式 2: 手动选择启动命令

**Node.js v18/v20:**
```bash
npm run start:v18
# 或
node cli.js
```

**Node.js v22/v24:**
```bash
npm run start:v22
# 或
node --no-experimental-strip-types cli.js
```

### 方式 3: 使用 npm scripts

```bash
# 标准启动（会自动适配）
npm start

# 测试 SDK 导入
npm run test:sdk

# 运行兼容性测试
npm run test:node18
```

## 🧪 验证修复

运行以下命令验证修复是否成功：

```bash
# 测试 SDK 导入
node -e "import('@shipany/open-agent-sdk').then(() => console.log('✅ SDK 导入成功'))"

# 测试程序启动
timeout 5 npm start
```

如果输出 "✅ SDK 导入成功" 而没有错误，说明修复生效。

## 📦 package.json 配置

确保你的 `package.json` 包含以下配置：

```json
{
  "scripts": {
    "start": "node cli.js",
    "start:auto": "node smart-start.js",
    "start:v18": "node cli.js",
    "start:v22": "node --no-experimental-strip-types cli.js",
    "test:sdk": "node -e \"import('@shipany/open-agent-sdk').then(() => console.log('✅ SDK imports successfully'))\"",
    "test:node18": "bash test-node18.sh || bash test-node18.bat"
  },
  "engines": {
    "node": ">=18.0.0"
  }
}
```

## 🔄 CI/CD 集成

如果需要在 CI/CD 中自动应用修复：

### GitHub Actions
```yaml
- name: Apply SDK Fixes
  run: |
    sed -i "s/import '..\/global.d.ts';/\/\/ import '..\/global.d.ts';/" \
      node_modules/@shipany/open-agent-sdk/dist/ink/components/Box.js \
      node_modules/@shipany/open-agent-sdk/dist/ink/components/ScrollBox.js
```

### npm postinstall 脚本
```json
{
  "scripts": {
    "postinstall": "node scripts/apply-fixes.js"
  }
}
```

## 🆘 故障排除

### 问题 1: 仍然出现 `.d.ts` 错误
**解决方案:**
1. 确认已正确修复两个文件
2. 删除 `node_modules` 重新安装
3. 运行 `npm run test:node18` 诊断

### 问题 2: `Bun.semver` 错误
**解决方案:**
1. 检查 `setup-globals.js` 是否包含 semver 支持
2. 参考 [SDK-FIXES.md](./SDK-FIXES.md) 重新应用修复

### 问题 3: 智能启动脚本不工作
**解决方案:**
1. 确保有执行权限：`chmod +x smart-start.sh`
2. 或直接使用：`node smart-start.js`

## 📚 相关文档

- [SDK-FIXES.md](./SDK-FIXES.md) - 详细的 SDK 修复说明
- [README.md](./README.md) - 项目使用说明
- [CONTRIBUTING.md](./CONTRIBUTING.md) - 贡献指南

## ⚠️ 重要提醒

1. **每次 `npm install` 后需要重新应用修复**
2. **不同的 Node.js 版本需要不同的启动参数**
3. **建议使用智能启动脚本自动适配**
4. **Node.js v18.20.3 经过测试，完全兼容**

## ✅ 测试状态

- ✅ Node.js v18.20.3 - 完全兼容
- ✅ Node.js v20.x - 完全兼容
- ✅ Node.js v22.x - 完全兼容（需要特殊标志）
- ✅ Node.js v24.x - 完全兼容（需要特殊标志）