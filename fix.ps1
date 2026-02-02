Write-Host "--- Adapting Config for Production & Deploying ---" -ForegroundColor Cyan

# 1. 确保在正确的根目录
if (-not (Test-Path "package.json")) {
    Write-Host "❌ Error: package.json not found! Please run in the project root." -ForegroundColor Red
    exit
}

# 2. 自动修正 vite.config.ts (添加 base 路径，移除 Node 专用代理库防止打包错误)
Write-Host "🔧 Updating vite.config.ts..." -ForegroundColor Cyan
$viteConfig = @"
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import path from 'path';

export default defineConfig({
  base: '/ap-param-reviewer/',
  plugins: [react()],
  resolve: { alias: { '@': path.resolve(__dirname, './src') } },
  server: {
    proxy: {
      '/google-api': {
        target: 'https://generativelanguage.googleapis.com',
        changeOrigin: true,
        rewrite: (p) => p.replace(/^\/google-api/, '')
      }
    }
  }
});
"@
[System.IO.File]::WriteAllText("vite.config.ts", $viteConfig)

# 3. 自动修正 App.tsx 里的 API 请求逻辑
# 将 '/google-api/' 替换为生产环境可用的完整 URL
$appPath = "src/App.tsx"
if (Test-Path $appPath) {
    Write-Host "🔧 Patching App.tsx API endpoints..." -ForegroundColor Cyan
    $content = Get-Content $appPath -Raw -Encoding UTF8
    
    # 逻辑：如果是在线上环境，直接请求 Google API
    $apiLogic = "import.meta.env.DEV ? '/google-api' : 'https://generativelanguage.googleapis.com'"
    
    # 简单替换：将字符串 '/google-api' 替换为变量引用
    # 注意：这里假设你的代码里是用 fetch('/google-api/...') 这种形式
    if ($content -match "'/google-api'") {
        $content = $content -replace "'/google-api'", "`$($apiLogic)"
    } elseif ($content -match '"/google-api"') {
        $content = $content -replace '"/google-api"', "`$($apiLogic)"
    }
    
    $Utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText((Resolve-Path $appPath), $content, $Utf8NoBom)
}

# 4. 执行构建
Write-Host "🏗️  Building production assets..." -ForegroundColor Cyan
# 尝试使用 npx 调用，避免路径问题
npx vite build

# 5. 部署到 GitHub Pages
if (Test-Path "dist") {
    Write-Host "🚀 Build successful! Deploying to gh-pages..." -ForegroundColor Green
    npx gh-pages -d dist -f
    
    # 6. 同步源码到 main 分支
    Write-Host "📦 Syncing source code..." -ForegroundColor Cyan
    git add .
    git commit -m "chore: production build with fixed api paths"
    git push origin main -f
    
    Write-Host "------------------------------------------------" -ForegroundColor Green
    Write-Host "✅ DEPLOYMENT COMPLETE!" -ForegroundColor Green
    Write-Host "URL: https://strTATQwQ.github.io/ap-param-reviewer/" -ForegroundColor Cyan
} else {
    Write-Host "❌ Build failed. Dist folder not found." -ForegroundColor Red
}