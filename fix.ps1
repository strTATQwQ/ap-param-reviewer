Write-Host "--- Starting Project Optimization & Document Split ---" -ForegroundColor Cyan

# 1. 处理 README 文件 (分离中英文)
Write-Host "📄 Reorganizing Documentation..." -ForegroundColor Cyan
# 将现有的 README 内容存为中文版
if (Test-Path "README.md") {
    $currentContent = Get-Content "README.md" -Raw
    [System.IO.File]::WriteAllText((Resolve-Path "README_zh.md"), $currentContent, [System.Text.Encoding]::UTF8)
}

# 写入新的英文 README.md
$enReadme = @"
# 🛸 AP Param Reviewer

[![Live Demo](https://img.shields.io/badge/demo-online-green.svg)](https://strTATQwQ.github.io/ap-param-reviewer/)

AI-powered ArduPilot parameter analysis tool. Get deep insights into your .param files using Google Gemini.

## ✨ Features
- 🤖 **AI Review**: Identify risks and optimization points.
- 🔍 **Smart Explanation**: Translate cryptic AP parameters into plain English.
- 🔑 **Client-Side Security**: API Key is stored only in your browser's memory.
- 🌐 **I18n**: Support for both English and Chinese.

## 🚀 Quick Start
1. Get a Gemini API Key from [Google AI Studio](https://aistudio.google.com/app/api-keys).
2. Paste the Key into the input box at the **top right corner** of the webpage.
3. Paste your parameters and click "Generate Review".

---
[中文文档 (Chinese README)](./README_zh.md)
"@
[System.IO.File]::WriteAllText((Resolve-Path "README.md"), $enReadme, [System.Text.Encoding]::UTF8)

# 2. 全局 UI 放大 10%
Write-Host "🎨 Scaling UI by 10%..." -ForegroundColor Cyan
$indexCssPath = "src/index.css"
if (Test-Path $indexCssPath) {
    # 注入 zoom 样式，适配现代浏览器
    $cssExtra = "`n`nbody { zoom: 1.1; -moz-transform: scale(1.1); -moz-transform-origin: 0 0; }"
    Add-Content -Path $indexCssPath -Value $cssExtra
}

# 3. 修复 App.tsx 中的逻辑错误
Write-Host "🔧 Patching App.tsx (Logic Fixes)..." -ForegroundColor Cyan
$appPath = "src/App.tsx"
if (Test-Path $appPath) {
    $content = Get-Content $appPath -Raw
    
    # 修正文件开头的 API_BASE 错误 (原代码有重复嵌套的 $() 符号)
    $oldBase = 'const API_BASE = import.meta.env.DEV \? \$\(import.meta.env.DEV \? ''https://generativelanguage.googleapis.com'' : ''https://generativelanguage.googleapis.com''\) : ''https://generativelanguage.googleapis.com'';'
    $newBase = "const API_BASE = 'https://generativelanguage.googleapis.com';"
    $content = $content -replace $oldBase, $newBase
    
    # 确保默认语言为英文 ('en')
    $content = $content -replace 'const \[lang, setLang\] = useState\("zh"\);', 'const [lang, setLang] = useState("en");'
    $content = $content -replace "const \[lang, setLang\] = useState\('zh'\);", "const [lang, setLang] = useState('en');"

    [System.IO.File]::WriteAllText((Resolve-Path $appPath), $content, (New-Object System.Text.UTF8Encoding($false)))
}

# 4. 构建并推送
Write-Host "🏗️ Rebuilding and Deploying..." -ForegroundColor Yellow
npx vite build
npx gh-pages -d dist -f

# 5. 推送源码
git add .
git commit -m "feat: default to EN, split README, scale UI 1.1x, fix API_BASE"
git push origin main -f

Write-Host "------------------------------------------------" -ForegroundColor Green
Write-Host "✅ Optimization Complete!" -ForegroundColor Green
Write-Host "Your page is now English by default and scaled 1.1x." -ForegroundColor Cyan