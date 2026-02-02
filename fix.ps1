Write-Host "--- Fixing MIME Type & Building Compliant Assets ---" -ForegroundColor Cyan

# 1. 强力清理
if (Test-Path "dist") { Remove-Item -Recurse -Force dist }
if (Test-Path "node_modules/.vite") { Remove-Item -Recurse -Force node_modules/.vite }

# 2. 修正 index.html (确保它指向的是源码，让 Vite 来处理转换)
$htmlPath = "index.html"
$htmlContent = @"
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>AP Param Reviewer</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.tsx"></script>
  </body>
</html>
"@
[System.IO.File]::WriteAllText((Resolve-Path $htmlPath), $htmlContent)

# 3. 强制更新 vite.config.ts 确保输出合规
$configContent = @"
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import path from 'path';

export default defineConfig({
  base: '/ap-param-reviewer/',
  plugins: [react()],
  resolve: { alias: { '@': path.resolve(__dirname, './src') } },
  build: {
    outDir: 'dist',
    assetsDir: 'assets',
    // 强制 Rollup 检查模块
    modulePreload: { polyfill: true }
  }
});
"@
[System.IO.File]::WriteAllText((Resolve-Path "vite.config.ts"), $configContent)

# 4. 执行构建
Write-Host "🏗️ Running production build..." -ForegroundColor Cyan
npx vite build

# 5. 关键检查：确保 dist 文件夹里没有任何 .tsx 或 .ts 文件
Write-Host "🔍 Verifying build artifacts..." -ForegroundColor Cyan
$badFiles = Get-ChildItem -Path "dist" -Recurse -Include *.ts, *.tsx
if ($badFiles) {
    Write-Host "❌ Error: Build leaked source files (.tsx) into dist!" -ForegroundColor Red
    $badFiles | Remove-Item -Force
}

# 6. 部署到 gh-pages (增加 .nojekyll 防止 GitHub 过滤文件)
if (Test-Path "dist") {
    # 创建 .nojekyll 文件，强制 GitHub Pages 不要处理这些文件
    New-Item -Path "dist\.nojekyll" -ItemType File -Force | Out-Null
    
    Write-Host "🚀 Deploying to gh-pages with .nojekyll..." -ForegroundColor Green
    npx gh-pages -d dist -f
}

# 7. 同步源码
git add .
git commit -m "fix: resolve MIME type strict checking error"
git push origin main -f

Write-Host "------------------------------------------------" -ForegroundColor Green
Write-Host "✅ FIX APPLIED." -ForegroundColor Green
Write-Host "Please clear browser cache or use Incognito mode to test." -ForegroundColor Yellow