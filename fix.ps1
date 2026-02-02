Write-Host "--- Starting Emergency Path Stitching ---" -ForegroundColor Cyan

# 1. 清理并构建
if (Test-Path "dist") { Remove-Item -Recurse -Force dist }
Write-Host "🏗️ Executing Vite Build..." -ForegroundColor Yellow
npx vite build

# 2. 核心补丁：手动修正 dist/index.html 中的路径引用
if (Test-Path "dist/index.html") {
    $distHtml = Get-Content "dist/index.html" -Raw
    
    # 查找 dist/assets 目录下生成的真实 JS 文件名
    $jsFile = Get-ChildItem "dist/assets/*.js" | Select-Object -First 1
    
    if ($jsFile) {
        $jsName = $jsFile.Name
        Write-Host "Found compiled JS: $jsName" -ForegroundColor Green
        
        # 定义要替换的目标和结果（使用单引号包裹含双引号的字符串）
        $oldTag = '<script type="module" src="/src/main.tsx"></script>'
        $newTag = '<script type="module" src="/ap-param-reviewer/assets/' + $jsName + '"></script>'
        
        # 执行替换
        $distHtml = $distHtml.Replace($oldTag, $newTag)
        
        # 写回文件
        [System.IO.File]::WriteAllText((Resolve-Path "dist/index.html"), $distHtml)
        Write-Host "✅ Successfully stitched $jsName into index.html" -ForegroundColor Green
    } else {
        Write-Host "❌ Error: No JS file found in dist/assets!" -ForegroundColor Red
        exit
    }
}

# 3. 部署
if (Test-Path "dist") {
    # 解决 GitHub Pages 过滤问题
    New-Item -Path "dist\.nojekyll" -ItemType File -Force | Out-Null
    
    Write-Host "🚀 Deploying to GitHub..." -ForegroundColor Cyan
    npx gh-pages -d dist -f
    
    # 同步源码
    git add .
    git commit -m "fix: emergency path stitching for production"
    git push origin main -f
}

Write-Host "------------------------------------------------" -ForegroundColor Green
Write-Host "Deployment Complete! Please refresh in 1 minute." -ForegroundColor Green