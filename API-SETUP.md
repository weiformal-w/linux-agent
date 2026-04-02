# 🔑 API Key 设置和连接问题解决

## ⚡ 快速设置

### 1. 获取 API Key

1. 访问 [Anthropic Console](https://console.anthropic.com/)
2. 登录或注册账号
3. 进入 "API Keys" 页面
4. 点击 "Create Key" 创建新的 API Key
5. 复制生成的 key（格式：`sk-ant-xxx`）

### 2. 设置环境变量

**Linux/Mac:**
```bash
# 临时设置（当前终端有效）
export ANTHROPIC_API_KEY=sk-ant-your-key-here

# 永久设置（添加到 ~/.bashrc 或 ~/.zshrc）
echo 'export ANTHROPIC_API_KEY=sk-ant-your-key-here' >> ~/.bashrc
source ~/.bashrc
```

**Windows (PowerShell):**
```powershell
# 临时设置
$env:ANTHROPIC_API_KEY="sk-ant-your-key-here"

# 永久设置
[System.Environment]::SetEnvironmentVariable('ANTHROPIC_API_KEY', 'sk-ant-your-key-here', 'User')
```

**Windows (CMD):**
```cmd
# 临时设置
set ANTHROPIC_API_KEY=sk-ant-your-key-here
```

### 3. 验证设置

```bash
# 检查环境变量
echo $ANTHROPIC_API_KEY  # Linux/Mac
echo %ANTHROPIC_API_KEY% # Windows

# 运行诊断工具
node diagnose-api.js

# 测试连接
npm start
```

## 🌍 中国大陆用户

如果遇到连接问题，可能需要使用代理：

### 设置代理

**Linux/Mac:**
```bash
export HTTPS_PROXY=http://127.0.0.1:7890
export HTTP_PROXY=http://127.0.0.1:7890
```

**Windows:**
```powershell
$env:HTTPS_PROXY="http://127.0.0.1:7890"
$env:HTTP_PROXY="http://127.0.0.1:7890"
```

### 推荐的代理工具

- [Clash](https://github.com/Dreamacro/clash)
- [V2RayN](https://github.com/2dust/v2rayN)
- [Shadowsocks](https://shadowsocks.org/)

## 🔍 诊断工具

### 运行完整诊断
```bash
node diagnose-api.js
```

这个工具会检查：
- ✅ API Key 是否设置
- ✅ API Key 格式是否正确
- ✅ 网络连接状态
- ✅ DNS 解析
- ✅ API 连接测试
- ✅ 代理设置检查

## ⚠️ 常见问题

### 问题 1: 一直转圈，没有响应

**原因:**
- 网络连接问题
- API 服务暂时不可用
- 需要代理

**解决方案:**
```bash
# 1. 检查网络连接
ping api.anthropic.com

# 2. 运行诊断
node diagnose-api.js

# 3. 如果在中国大陆，设置代理
export HTTPS_PROXY=http://127.0.0.1:7890
```

### 问题 2: API Key 错误

**错误信息:** `Unauthorized` 或 `Invalid API Key`

**解决方案:**
1. 检查 API Key 是否正确复制
2. 确认 API Key 没有过期
3. 访问控制台重新生成 Key

### 问题 3: 超时错误

**错误信息:** `请求超时 (30秒)`

**解决方案:**
```bash
# 1. 检查网络连接
curl -I https://api.anthropic.com

# 2. 设置代理（如果需要）
export HTTPS_PROXY=http://127.0.0.1:7890

# 3. 尝试使用更简单的模型
# 编辑 cli.js，将 model 改为 'claude-3-haiku-20240307'
```

### 问题 4: 连接被拒绝

**错误信息:** `Connection refused` 或 `ECONNREFUSED`

**解决方案:**
1. 检查防火墙设置
2. 确认代理软件正在运行
3. 尝试关闭代理（如果不在中国大陆）

## 🚀 测试连接

### 简单测试
```bash
curl https://api.anthropic.com/v1/messages \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "content-type: application/json" \
  -H "anthropic-version: 2023-06-01" \
  -d '{
    "model": "claude-3-haiku-20240307",
    "max_tokens": 10,
    "messages": [{"role": "user", "content": "Hi"}]
  }'
```

### 使用项目测试
```bash
npm start
# 然后输入: 你好
```

## 📝 环境变量文件

创建 `.env` 文件（可选）：

```bash
# .env
ANTHROPIC_API_KEY=sk-ant-your-key-here
HTTPS_PROXY=http://127.0.0.1:7890  # 可选
```

然后在启动时加载：
```bash
# 安装 dotenv
npm install dotenv

# 修改 cli.js 顶部添加
import dotenv from 'dotenv'
dotenv.config()
```

## 🎯 最佳实践

1. **保护 API Key**: 不要将 API Key 提交到 Git
2. **定期轮换**: 定期更换 API Key
3. **监控使用**: 在控制台监控 API 使用量
4. **设置限制**: 在控制台设置使用限制

## 🆘 仍需要帮助？

1. 运行诊断工具：`node diagnose-api.js`
2. 查看 [Anthropic API 文档](https://docs.anthropic.com/)
3. 检查 [API 状态页面](https://status.anthropic.com/)
4. 提交 Issue 到 GitHub 仓库