Write-Host "--- Starting Ultimate Path Fix & Deployment ---" -ForegroundColor Cyan

# 1. 修正 index.html (关键：将绝对路径改为相对路径，以便 Vite 识别)
$htmlPath = "index.html"
if (Test-Path $htmlPath) {
    Write-Host "🔧 Fixing index.html entry point..." -ForegroundColor Cyan
    $html = Get-Content $htmlPath -Raw
    # 将 src="/src/main.tsx" 替换为 src="src/main.tsx"
    $html = $html -replace 'src="/src/main.tsx"', 'src="src/main.tsx"'
    $html = $html -replace "src='/src/main.tsx'", "src='src/main.tsx'"
    [System.IO.File]::WriteAllText((Resolve-Path $htmlPath), $html)
}

# 2. 强制同步 vite.config.ts 确保 base 路径正确
Write-Host "🔧 Syncing vite.config.ts base path..." -ForegroundColor Cyan
$configPath = "vite.config.ts"
$configContent = @"
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
[System.IO.File]::WriteAllText((Resolve-Path $configPath), $configContent)

# 3. 清理并执行生产构建
Write-Host "🏗️  Running Production Build..." -ForegroundColor Cyan
if (Test-Path "dist") { Remove-Item -Recurse -Force dist }
npx vite build

# 4. 构建后二次检查 (验证 dist/index.html 里的路径是否已加上前缀)
if (Test-Path "dist/index.html") {
    $distHtml = Get-Content "dist/index.html" -Raw
    if ($distHtml -match "/ap-param-reviewer/assets/") {
        Write-Host "✅ Build verification PASSED: Assets are prefixed." -ForegroundColor Green
    } else {
        Write-Host "⚠️ Build verification FAILED: Paths might still be broken." -ForegroundColor Yellow
    }
}

# 5. 部署到 GitHub Pages 分支
Write-Host "🚀 Deploying static files to gh-pages..." -ForegroundColor Green
npx gh-pages -d dist -f

# 6. 同步源码到主分支 (SSH)
Write-Host "📦 Pushing source code to main..." -ForegroundColor Cyan
git add .
git commit -m "fix: resolve 404 entry point and asset paths"
git push origin main -f

Write-Host "------------------------------------------------" -ForegroundColor Green
Write-Host "SUCCESS! Deployment finished." -ForegroundColor Green
Write-Host "👉 URL: https://strTATQwQ.github.io/ap-param-reviewer/" -ForegroundColor Green
Write-Host "Note: It may take 30-60 seconds for GitHub to update." -ForegroundColor Yellow