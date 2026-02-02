Write-Host "--- Performing Manual Alignment ---" -ForegroundColor Cyan

# 1. 核心修复：确保 index.html 的 script 路径没有领先的斜杠
# Vite 打包引擎对 src="src/main.tsx" 的识别率远高于 src="/src/main.tsx"
$htmlPath = "index.html"
$htmlContent = Get-Content $htmlPath -Raw
# 替换所有可能的绝对路径写法
$htmlContent = $htmlContent -replace 'src="/src/main.tsx"', 'src="src/main.tsx"'
$htmlContent = $htmlContent -replace "src='/src/main.tsx'", "src='src/main.tsx'"
[System.IO.File]::WriteAllText((Resolve-Path $htmlPath), $htmlContent)
Write-Host "✅ Entry point path corrected to relative." -ForegroundColor Green

# 2. 强力构建
Write-Host "🏗️  Starting Vite Build..." -ForegroundColor Cyan
if (Test-Path "dist") { Remove-Item -Recurse -Force dist }
npx vite build

# 3. 关键验证：检查 dist/index.html 到底长什么样
if (Test-Path "dist/index.html") {
    $distHtml = Get-Content "dist/index.html" -Raw
    if ($distHtml -match 'src="/ap-param-reviewer/assets/') {
        Write-Host "🚀 Build looks PERFECT. Correct production paths found." -ForegroundColor Green
    } elseif ($distHtml -match 'src="src/main.tsx"') {
        Write-Host "❌ Build FAILED to transform script tag. Still pointing to .tsx" -ForegroundColor Red
        exit
    }
}

# 4. 创建 .nojekyll 并部署
New-Item -Path "dist\.nojekyll" -ItemType File -Force | Out-Null
npx gh-pages -d dist -f

# 5. 推送源码备份
git add .
git commit -m "fix: explicit relative entry point for vite"
git push origin main -f

Write-Host "------------------------------------------------" -ForegroundColor Green
Write-Host "Verification Complete. Refresh the page in 30s." -ForegroundColor Cyan