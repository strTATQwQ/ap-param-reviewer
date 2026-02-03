Write-Host "--- Temporarily Removing ArduPilot Wiki Buttons ---" -ForegroundColor Cyan

$appPath = "src/App.tsx"
if (Test-Path $appPath) {
    Write-Host "🔧 Patching App.tsx..." -ForegroundColor Cyan
    $content = Get-Content $appPath -Raw -Encoding UTF8
    
    # 定位 Wiki 链接代码段并进行注释
    # 原始代码片段: <a href={getWikiUrl(p.key)} ... ><ExternalLink size={12}/></a>
    $oldLink = '<a href={getWikiUrl(p.key)} target="_blank" rel="noreferrer" className="text-slate-600 hover:text-blue-400 transition-colors"><ExternalLink size={12}/></a>'
    $newLink = '{/* ' + $oldLink + ' */}'
    
    if ($content.Contains($oldLink)) {
        $newContent = $content.Replace($oldLink, $newLink)
        [System.IO.File]::WriteAllText((Resolve-Path $appPath), $newContent, (New-Object System.Text.UTF8Encoding($false)))
        Write-Host "✅ Wiki link buttons have been commented out." -ForegroundColor Green
    } else {
        Write-Host "⚠️ Could not find the Wiki link code. It may already be hidden." -ForegroundColor Yellow
    }
}

# 重新构建并发布到 GitHub Pages
Write-Host "🏗️ Rebuilding and Deploying..." -ForegroundColor Yellow
npx vite build
npx gh-pages -d dist -f

# 推送源码
git add .
git commit -m "chore: temporarily hide wiki links"
git push origin main -f

Write-Host "------------------------------------------------" -ForegroundColor Green
Write-Host "Done! The Wiki buttons are now hidden from the UI." -ForegroundColor Green