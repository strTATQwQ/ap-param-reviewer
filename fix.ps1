Write-Host "--- Starting Deep Reset & Build Verification ---" -ForegroundColor Cyan

# 1. 环境彻底清理
if (Test-Path "dist") { Remove-Item -Recurse -Force dist }
if (Test-Path "package-lock.json") { Remove-Item -Force package-lock.json }

# 2. 修正 index.html (确保它是 Vite 标准格式)
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
[System.IO.File]::WriteAllText("index.html", $htmlContent)

# 3. 强制执行构建 (使用物理路径，绕过所有环境变量问题)
Write-Host "🏗️ Executing Vite Build..." -ForegroundColor Yellow
npm install
node node_modules/vite/bin/vite.js build

# 4. 【关键步骤】检查构建产物
if (Test-Path "dist/assets") {
    $jsFiles = Get-ChildItem -Path "dist/assets" -Filter "*.js"
    if ($jsFiles) {
        Write-Host "✅ Found compiled JavaScript: $($jsFiles[0].Name)" -ForegroundColor Green
    } else {
        Write-Host "❌ ERROR: Build finished but NO JavaScript files were created in dist/assets!" -ForegroundColor Red
        Write-Host "Stopping deployment to prevent broken upload." -ForegroundColor Red
        exit
    }
} else {
    Write-Host "❌ ERROR: 'dist' folder was not created!" -ForegroundColor Red
    exit
}

# 5. 部署 (添加 .nojekyll)
New-Item -Path "dist\.nojekyll" -ItemType File -Force | Out-Null
Write-Host "🚀 Deploying verified assets to gh-pages..." -ForegroundColor Green
npx gh-pages -d dist -f

# 6. 推送源码
git add .
git commit -m "fix: verified production build with js assets"
git push origin main -f

Write-Host "------------------------------------------------" -ForegroundColor Green
Write-Host "SUCCESS! If the site is still white, check if your API key is restricted." -ForegroundColor Cyan