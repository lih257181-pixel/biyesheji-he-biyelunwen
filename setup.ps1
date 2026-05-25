$GIT_REPO = "https://github.com/lih257181-pixel/biyesheji-he-biyelunwen.git"
$DIR_NAME = "cloudthink"
$SITE_PORT = 8080

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "   云创科技企业网站 - 一键Docker部署" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

if (-not (Test-Path "docker-compose.yml")) {
    Write-Host "[*] docker-compose.yml 未在当前目录找到" -ForegroundColor Yellow
    if (Get-Command git -ErrorAction SilentlyContinue) {
        Write-Host "[*] 正在克隆仓库..." -ForegroundColor Yellow
        git clone $GIT_REPO $DIR_NAME
        Set-Location $DIR_NAME
    } else {
        Write-Host "[!] 正在下载项目压缩包..." -ForegroundColor Yellow
        $zipUrl = "https://github.com/lih257181-pixel/biyesheji-he-biyelunwen/archive/refs/heads/master.zip"
        $zipFile = "$env:TEMP\cloudthink.zip"
        Invoke-WebRequest -Uri $zipUrl -UseBasicParsing -OutFile $zipFile
        Expand-Archive -Path $zipFile -DestinationPath "$env:TEMP\cloudthink_extract" -Force
        Set-Location "$env:TEMP\cloudthink_extract\biyesheji-he-biyelunwen-master"
        Remove-Item $zipFile -Force
    }
}

Write-Host "[1/3] 检测 Docker Desktop..." -ForegroundColor Green
$dockerExists = Get-Command docker -ErrorAction SilentlyContinue
if (-not $dockerExists) {
    Write-Host "[*] 未检测到 Docker Desktop，正在下载安装程序..." -ForegroundColor Yellow
    $installerUrl = "https://desktop.docker.com/win/stable/amd64/Docker%20Desktop%20Installer.exe"
    $installer = "$env:TEMP\DockerDesktopInstaller.exe"
    Invoke-WebRequest -Uri $installerUrl -UseBasicParsing -OutFile $installer
    Write-Host "[*] 正在安装 Docker Desktop（安装完成后可能需要重启）..." -ForegroundColor Yellow
    Start-Process -FilePath $installer -ArgumentList "install","--accept-license","--quiet" -Wait -NoNewWindow
    Write-Host "[*] 等待 Docker Desktop 启动..." -ForegroundColor Yellow
    Start-Sleep -Seconds 30
}

Write-Host "[2/3] 等待 Docker 就绪..." -ForegroundColor Green
do {
    docker info > $null 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "     正在等待 Docker 引擎启动..." -ForegroundColor Gray
        Start-Sleep -Seconds 5
    }
} while ($LASTEXITCODE -ne 0)
Write-Host "[*] Docker 就绪" -ForegroundColor Green

Write-Host "[3/3] 构建并启动容器..." -ForegroundColor Green
docker compose up -d --build

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "   部署完成！" -ForegroundColor Green
Write-Host ""
Write-Host "   前台访问：http://localhost:$SITE_PORT/" -ForegroundColor White
Write-Host "   后台访问：http://localhost:$SITE_PORT/admin/" -ForegroundColor White
Write-Host "   管理员账号：admin  /  admin123" -ForegroundColor White
Write-Host ""
Write-Host "   停止服务：docker compose down" -ForegroundColor Gray
Write-Host "============================================" -ForegroundColor Cyan

Start-Process "http://localhost:$SITE_PORT/"
