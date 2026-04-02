# 🔧 SDK 修复 - 最简单的方法

## 问题的根源

**是的，就是删除 `.d.ts` 导入这么简单！**

`@shipany/open-agent-sdk` 在编译后的 JavaScript 文件中错误地包含了 TypeScript 声明文件的导入：

```javascript
// ❌ 错误的代码
import '../global.d.ts';
```

这会导致 Node.js 报错，因为它试图将 `.d.ts` 文件作为 JavaScript 模块加载。

## ✅ 修复方法

### 方法 1: 自动修复（推荐）

```bash
# 使用提供的修复脚本
npm run fix-sdk
```

### 方法 2: 手动修复

编辑这两个文件，删除包含 `.d.ts` 的行：

1. `node_modules/@shipany/open-agent-sdk/dist/ink/components/Box.js`
2. `node_modules/@shipany/open-agent-sdk/dist/ink/components/ScrollBox.js`

### 方法 3: 使用 postinstall 自动修复

项目已经配置了 `postinstall` 脚本，每次 `npm install` 后会自动运行修复。

## 🧪 验证修复

```bash
# 测试 SDK 导入
npm run test:sdk

# 如果看到 "✅ SDK imports successfully!" 说明修复成功
```

## 🚀 启动应用

```bash
# 直接启动
npm start
```

## 📦 在其他项目中使用

如果你想在其他项目中使用修复后的 SDK：

1. **复制修复脚本** - 将 `fix-sdk.js` 复制到项目根目录
2. **配置 postinstall** - 在 package.json 中添加：
   ```json
   {
     "scripts": {
       "postinstall": "node fix-sdk.js"
     }
   }
   ```
3. **正常使用** - 每次 `npm install` 会自动修复

## 🎯 总结

**问题**: SDK 编译错误，在 JS 文件中包含了 `.d.ts` 导入
**解决**: 删除这些导入行
**工具**: 提供了自动化脚本 `fix-sdk.js`
**效果**: SDK 在所有 Node.js 版本中都能正常工作

就这么简单！🎉