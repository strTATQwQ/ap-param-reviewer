# 🛸 AP Param Reviewer

**AP Param Reviewer** is an AI-assisted parameter tuning tool designed specifically for **ArduPilot** drone developers. Powered by **Google Gemini’s** advanced analytical capabilities, it provides in-depth interpretation, risk assessment, and optimization suggestions for complex `.param` configuration files. 

## ✨ Core Features

- 🤖 **AI Deep Review**: Automatically identifies potential risks, redundant parameters, and optimization opportunities in parameter configurations.
- 🔍 **Intelligent Parameter Explanation**: Translates obscure ArduPilot parameter abbreviations into clear and easy-to-understand explanations.
- ⚡ **Ready-to-Use Design**: No installation required—simply paste your parameters and instantly generate a review report.
- 🔑 **Client-Side Security**: The API Key is stored only in the user’s browser and is never uploaded to any server.

------

## 🚀 Quick Start

### Online Demo

Click to access directly:
 https://strTATQwQ.github.io/ap-param-reviewer/

### How to Use AI Features

To enable AI analysis, you need to configure your own **Gemini API Key**:

1. **Obtain an API Key**:
   - Visit [Google AI Studio](https://aistudio.google.com/app/api-keys).
   - Click **“Create API key”** and copy the generated key (starts with `AIza...`).
2. **Enter It on the Website**:
   - Open the [project website](https://strTATQwQ.github.io/ap-param-reviewer/).
   - Paste your API Key into the input box at the **top-right corner** of the page.
3. **Start Analyzing**:
   - Paste your ArduPilot parameter content into the input area and click analyze.

**Note: To prevent excessive token usage, param files are currently limited to 2000 lines.**

------

## 🛠️ Tech Stack

- **Frontend Framework**: React 18 (TypeScript)
- **Build Tool**: Vite
- **UI Components**: Tailwind CSS / Lucide React

------

## 📦 Development & Build

If you want to run the project locally or perform secondary development:

1. **Clone the Repository**:

   ```
   git clone https://github.com/strTATQwQ/ap-param-reviewer.git
   cd ap-param-reviewer
   ```

2. **Install Dependencies**:

   ```
   npm install
   ```

3. **Run Locally**:

   ```
   npm run dev
   ```

4. **Build & Deploy**:

   ```
   npm run build
   # Deploy to GitHub Pages
   npm run deploy
   ```

------

## 🛡️ License

Released under the [MIT License](https://www.google.com/search?q=LICENSE).

------

*Created with ❤️ by [strTATQwQ](https://www.google.com/search?q=https://github.com/strTATQwQ)*