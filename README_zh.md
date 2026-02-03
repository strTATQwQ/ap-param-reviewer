# 🛸 Ardupilot Param Reviewer

**Ardupilot Param Reviewer** 是一款专为 ArduPilot 无人机开发者设计的 AI 辅助调参工具。它利用 Google Gemini 的强大分析能力，为复杂的 `.param` 配置文件提供深度解读、风险评估和优化建议。

## ✨ 核心功能

- 🤖 **AI 深度审查**：自动识别参数配置中的潜在风险、冗余项和优化点。
- 🔍 **参数智能解释**：将晦涩的 ArduPilot 简写参数转换为易懂的中文解释。
- ⚡ **即用型设计**：无需安装，支持直接粘贴参数内容，即时生成评论报告。
- 🔑 **端侧安全**：API Key 仅存储在用户浏览器本地，不会上传至服务器。

------

## 🚀 快速开始

### 在线体验

直接点击访问：https://strTATQwQ.github.io/ap-param-reviewer/

### 如何使用 AI 功能

为了启用 AI 分析功能，你需要配置自己的 **Gemini API Key**：

1. **获取 API Key**:
   - 访问 [Google AI Studio](https://aistudio.google.com/app/api-keys)。
   - 点击 **"Create API key"** 并复制生成的密钥 (以 `AIza...` 开头)。
2. **在网页中填写**:
   - 打开 [本项目网页](https://strTATQwQ.github.io/ap-param-reviewer/)。
   - 在网页**右上角**的输入框中，直接粘贴你刚才申请的 API Key。
3. **开始分析**:
   - 将你的 ArduPilot 参数内容粘贴进输入框，点击分析即可。

**注意：为了防止过度燃烧token，目前param文件行数限制为2000行**

------

## 🛠️ 技术栈

- **前端框架**: React 18 (TypeScript)
- **构建工具**: Vite
- **UI 组件**: Tailwind CSS / Lucide React 

------

## 📦 开发与构建

如果你想在本地运行或二次开发：

1. **克隆仓库**:

   Bash

   ```
   git clone https://github.com/strTATQwQ/ap-param-reviewer.git
   cd ap-param-reviewer
   ```

2. **安装依赖**:

   Bash

   ```
   npm install
   ```

3. **本地启动**:

   Bash

   ```
   npm run dev
   ```

4. **构建部署**:

   Bash

   ```
   npm run build
   # 部署到 GitHub Pages
   npm run deploy
   ```

## 🛡️ 开源协议

基于 [MIT License](https://www.google.com/search?q=LICENSE) 开源。

------

*Created with ❤️ by [strTATQwQ](https://www.google.com/search?q=https://github.com/strTATQwQ)*
