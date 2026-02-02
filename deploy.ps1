Write-Host "--- Found Vite at physical path. Executing build... ---" -ForegroundColor Green

# 1. 确保其他依赖完整
npm install

# 2. 使用物理路径强制执行构建
# 既然刚才 Get-ChildItem 找到了，我们就直接用它
$VITE_PATH = "node_modules/vite/bin/vite.js"
node $VITE_PATH build

# 3. 检查构建结果并部署
if (Test-Path "dist") {
    Write-Host "Build success! Deploying to GitHub Pages..." -ForegroundColor Green
    # 同样使用 npx 运行 gh-pages 避免路径问题
    npx gh-pages -d dist
} else {
    Write-Host "Build failed. Dist folder not created." -ForegroundColor Red
    exit
}

# 4. 同步代码到 GitHub (使用 SSH 别名)
Write-Host "Syncing source code via SSH..." -ForegroundColor Cyan

# 检查 SSH 连通性 (第一次可能需要手动输入 yes)
# ssh -T github-new 

git add .
git commit -m "deploy: verified build with physical path"
git push origin main -f

Write-Host "------------------------------------------------" -ForegroundColor Green
Write-Host "SUCCESS! Check: https://strTATQwQ.github.io/ap-param-reviewer/" -ForegroundColor Green