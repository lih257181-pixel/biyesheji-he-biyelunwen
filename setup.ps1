$port = 8080
$workDir = "$env:TEMP\cloudthink_site"
$phpDir = "$workDir\runtime\php"
$dbDir = "$workDir\runtime\mariadb"
$dataDir = "$dbDir\data"
$wwwDir = "$workDir\www"

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  云创科技企业网站 - 一键启动" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# 清理上次残留进程
Get-Process -Name "php*" -ErrorAction SilentlyContinue | Stop-Process -Force
Get-Process -Name "mariadbd*","mysqld*" -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 1

if ((Test-Path "$phpDir\php.exe") -and (Test-Path "$dbDir\bin\mariadbd.exe")) {
    Write-Host "[1/3] 运行环境已就绪" -ForegroundColor Green
} else {
    Write-Host "[1/3] 首次运行，下载依赖（约 80MB）..." -ForegroundColor Green
    
    Remove-Item -Path $workDir -Recurse -Force -ErrorAction SilentlyContinue
    New-Item -Path $workDir -ItemType Directory -Force | Out-Null

    Write-Host "  下载 PHP..." -ForegroundColor Yellow
    $phpZip = "$env:TEMP\php_dl.zip"
    Invoke-WebRequest -Uri "https://windows.php.net/downloads/releases/php-8.1.29-nts-Win32-vs16-x64.zip" -UseBasicParsing -OutFile $phpZip
    Expand-Archive -Path $phpZip -DestinationPath $phpDir -Force
    Remove-Item $phpZip -Force

    Write-Host "  下载 MariaDB..." -ForegroundColor Yellow
    $dbZip = "$env:TEMP\mdb_dl.zip"
    Invoke-WebRequest -Uri "https://archive.mariadb.org/mariadb-10.11.8/winx64-packages/mariadb-10.11.8-winx64.zip" -UseBasicParsing -OutFile $dbZip
    Expand-Archive -Path $dbZip -DestinationPath "$workDir\runtime" -Force
    Remove-Item $dbZip -Force

    # 移动 MariaDB 文件到正确位置
    $mdbSub = Get-ChildItem -Path "$workDir\runtime" -Directory | Where-Object { $_.Name -like "mariadb*" } | Select-Object -First 1
    if ($mdbSub) {
        Move-Item -Path "$($mdbSub.FullName)\*" -Destination $dbDir -Force -ErrorAction SilentlyContinue
        Remove-Item -Path $mdbSub.FullName -Recurse -Force -ErrorAction SilentlyContinue
    }

    Write-Host "  下载网站代码..." -ForegroundColor Yellow
    $siteZip = "$env:TEMP\site_dl.zip"
    Invoke-WebRequest -Uri "https://github.com/lih257181-pixel/biyesheji-he-biyelunwen/archive/refs/heads/master.zip" -UseBasicParsing -OutFile $siteZip
    Expand-Archive -Path $siteZip -DestinationPath "$workDir\site_tmp" -Force
    $siteSrc = Get-ChildItem -Path "$workDir\site_tmp" -Directory | Select-Object -First 1 -ExpandProperty FullName
    Move-Item -Path "$($siteSrc)\*" -Destination $wwwDir -Force
    Remove-Item $siteZip -Force
    Remove-Item "$workDir\site_tmp" -Recurse -Force

    # 配置 php.ini 启用 mysqli
    $iniFile = "$phpDir\php.ini"
    if (Test-Path "$phpDir\php.ini-development") {
        Copy-Item "$phpDir\php.ini-development" $iniFile
    }
    if (Test-Path $iniFile) {
        $ini = Get-Content $iniFile
        $ini = $ini -replace ';extension_dir = "ext"', 'extension_dir = "ext"'
        $ini = $ini -replace ';extension=mysqli', 'extension=mysqli'
        $ini = $ini -replace ';extension=mbstring', 'extension=mbstring'
        $ini = $ini -replace ';extension=openssl', 'extension=openssl'
        $ini = $ini -replace ';extension_dir=ext', 'extension_dir=ext'
        Set-Content -Path $iniFile -Value $ini
    }

    Write-Host "  下载完成" -ForegroundColor Green
}

Write-Host "[2/3] 初始化数据库..." -ForegroundColor Green
if (-not (Test-Path "$dataDir\mysql")) {
    Write-Host "  首次初始化数据库..." -ForegroundColor Yellow
    $initProcess = Start-Process -FilePath "$dbDir\bin\mariadbd.exe" -ArgumentList "--initialize-insecure --datadir=`"$dataDir`"" -NoNewWindow -PassThru -Wait
    Start-Sleep -Seconds 2
}

# 停止可能残留的进程
Get-Process -Name "mariadbd*","mysqld*" -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 1

# 启动 MariaDB
Write-Host "  启动数据库..." -ForegroundColor Yellow
$logFile = "$dataDir\error.log"
$dbProcess = Start-Process -FilePath "$dbDir\bin\mariadbd.exe" -ArgumentList "--datadir=`"$dataDir`"","--port=3307","--skip-grant-tables","--log-error=`"$logFile`"" -NoNewWindow -PassThru

# 等待数据库就绪
$maxWait = 15
for ($i = 0; $i -lt $maxWait; $i++) {
    Start-Sleep -Seconds 1
    try {
        $test = & "$dbDir\bin\mysql.exe" -u root --port=3307 --protocol=tcp -e "SELECT 1" 2>$null
        if ($LASTEXITCODE -eq 0) { break }
    } catch {}
}

# 创建数据库和导入数据
& "$dbDir\bin\mysql.exe" -u root --port=3307 --protocol=tcp -e "CREATE DATABASE IF NOT EXISTS cloudthink DEFAULT CHARSET utf8;"
Get-Content "$wwwDir\cloudthink.sql" | & "$dbDir\bin\mysql.exe" -u root --port=3307 --protocol=tcp cloudthink 2>$null
Get-Content "$wwwDir\sample_data.sql" | & "$dbDir\bin\mysql.exe" -u root --port=3307 --protocol=tcp cloudthink 2>$null

Write-Host "  数据库就绪" -ForegroundColor Green

# 修改 db.php 连接配置（端口 3307，密码空）
$dbFile = "$wwwDir\db.php"
$dbContent = @"
<?php
`$db_host = '127.0.0.1';
`$db_port = 3307;
`$db_user = 'root';
`$db_pass = '';
`$db_name = 'cloudthink';
`$conn = mysqli_connect(`$db_host, `$db_user, `$db_pass, `$db_name, `$db_port);
if (!`$conn) die('数据库连接失败:' . mysqli_connect_error());
mysqli_query(`$conn, 'set names utf8');
session_start();
"@
Set-Content -Path $dbFile -Value $dbContent

$adminDbFile = "$wwwDir\admin\db.php"
$adminDbContent = @"
<?php
`$db_host = '127.0.0.1';
`$db_port = 3307;
`$db_user = 'root';
`$db_pass = '';
`$db_name = 'cloudthink';
`$conn = mysqli_connect(`$db_host, `$db_user, `$db_pass, `$db_name, `$db_port);
if (!`$conn) die('数据库连接失败！');
mysqli_query(`$conn, 'set names utf8');
session_start();
if (!isset(`$_SESSION['admin'])) {
    echo "<script>alert('请先登录！');window.location.href='index.php';</script>";
    exit;
}
"@
Set-Content -Path $adminDbFile -Value $adminDbContent

# 启动 PHP 服务器
Write-Host "[3/3] 启动网站..." -ForegroundColor Green
$phpPath = "$phpDir\php.exe"
$url = "http://localhost:$port"

# 杀掉旧 PHP 进程
Get-Process -Name "php*" -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 1

# 启动 PHP 内置服务器
$startCmd = "start /B `"$phpPath`" -S 0.0.0.0:$port -t `"$wwwDir`""
Start-Process -FilePath "cmd.exe" -ArgumentList "/c $startCmd" -NoNewWindow -WindowStyle Hidden
Start-Sleep -Seconds 2

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  网站已启动！" -ForegroundColor Green
Write-Host "  前台: $url/" -ForegroundColor White
Write-Host "  后台: $url/admin/" -ForegroundColor White
Write-Host "  管理员: admin / admin123" -ForegroundColor White
Write-Host ""
Write-Host "  按任意键停止服务" -ForegroundColor Gray
Write-Host "============================================" -ForegroundColor Cyan

Start-Process $url

# 保持窗口打开
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# 停止服务
Get-Process -Name "php*" -ErrorAction SilentlyContinue | Stop-Process -Force
Get-Process -Name "mariadbd*","mysqld*" -ErrorAction SilentlyContinue | Stop-Process -Force
