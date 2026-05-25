$port = 8080
$workDir = "$env:TEMP\cloudthink_site"
$phpDir = "$workDir\runtime\php"
$dbDir = "$workDir\runtime\mariadb"
$dataDir = "$dbDir\data"

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  云创科技企业网站 - 一键启动" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# 清理上次残留进程
Get-Process -Name "php*" -ErrorAction SilentlyContinue | Stop-Process -Force
Get-Process -Name "mariadbd*","mysqld*" -ErrorAction SilentlyContinue | Stop-Process -Force

if (Test-Path $workDir) {
    Write-Host "[1/3] 检测到已下载的文件" -ForegroundColor Green
} else {
    Write-Host "[1/3] 正在下载运行环境（首次约 80MB）..." -ForegroundColor Green
    
    # 下载 PHP
    Write-Host "  下载 PHP..." -ForegroundColor Yellow
    $phpUrl = "https://windows.php.net/downloads/releases/php-8.1.29-nts-Win32-vs16-x64.zip"
    $phpZip = "$env:TEMP\php_dl.zip"
    Invoke-WebRequest -Uri $phpUrl -UseBasicParsing -OutFile $phpZip -ErrorAction Stop
    
    # 下载 MariaDB
    Write-Host "  下载 MariaDB..." -ForegroundColor Yellow
    $dbUrl = "https://archive.mariadb.org/mariadb-10.11.8/winx64-packages/mariadb-10.11.8-winx64.zip"
    $dbZip = "$env:TEMP\mdb_dl.zip"
    Invoke-WebRequest -Uri $dbUrl -UseBasicParsing -OutFile $dbZip -ErrorAction Stop
    
    # 下载网站代码
    Write-Host "  下载网站代码..." -ForegroundColor Yellow
    $siteUrl = "https://github.com/lih257181-pixel/biyesheji-he-biyelunwen/archive/refs/heads/master.zip"
    $siteZip = "$env:TEMP\site_dl.zip"
    Invoke-WebRequest -Uri $siteUrl -UseBasicParsing -OutFile $siteZip -ErrorAction Stop
    
    # 解压
    Write-Host "  正在解压..." -ForegroundColor Yellow
    New-Item -Path $workDir -ItemType Directory -Force | Out-Null
    
    Expand-Archive -Path $phpZip -DestinationPath $phpDir -Force
    Expand-Archive -Path $dbZip -DestinationPath "$workDir\runtime" -Force
    # MariaDB 解压在子目录，移动到正确位置
    $mdbSub = Get-ChildItem -Path "$workDir\runtime" -Directory | Where-Object { $_.Name -like "mariadb*" } | Select-Object -First 1
    if ($mdbSub) {
        Move-Item -Path "$($mdbSub.FullName)\*" -Destination $dbDir -Force
        Remove-Item -Path $mdbSub.FullName -Recurse -Force
    }
    
    Expand-Archive -Path $siteZip -DestinationPath "$workDir\site_tmp" -Force
    $siteSrc = Get-ChildItem -Path "$workDir\site_tmp" -Directory | Select-Object -First 1 -ExpandProperty FullName
    Move-Item -Path "$($siteSrc)\*" -Destination "$workDir\www" -Force
    
    # 清理压缩包
    Remove-Item -Path $phpZip, $dbZip, $siteZip -Force
    Remove-Item -Path "$workDir\site_tmp" -Recurse -Force
    
    # 配置 PHP 启用 mysqli
    $iniFile = "$phpDir\php.ini"
    if (Test-Path "$phpDir\php.ini-development") {
        Copy-Item "$phpDir\php.ini-development" $iniFile
    } else {
        New-Item -Path $iniFile -ItemType File -Force | Out-Null
    }
    $ini = Get-Content $iniFile
    $ini = $ini -replace ";extension_dir = ""ext""", 'extension_dir = "ext"'
    $ini = $ini -replace ";extension=mysqli", "extension=mysqli"
    $ini = $ini -replace ";extension=mbstring", "extension=mbstring"
    $ini = $ini -replace ";extension=openssl", "extension=openssl"
    $ini = $ini -replace ";extension=pdo_mysql", "extension=pdo_mysql"
    Set-Content -Path $iniFile -Value $ini
    
    Write-Host "  下载完成" -ForegroundColor Green
}

# 初始化数据库
Write-Host "[2/3] 初始化数据库..." -ForegroundColor Green
if (-not (Test-Path "$dataDir\mysql")) {
    $installCmd = "`"$dbDir\bin\mariadbd-install.exe`" --datadir `"$dataDir`" --service=CloudThinkDB --password=123456"
    & "$dbDir\bin\mariadbd.exe" --initialize-insecure --datadir="$dataDir" 2>&1 | Out-Null
}
# 启动 MariaDB
$dbProc = Start-Process -FilePath "$dbDir\bin\mariadbd.exe" -ArgumentList "--datadir=`"$dataDir`" --port=3307 --socket=MySQL --skip-grant-tables" -NoNewWindow -PassThru
Start-Sleep -Seconds 3

# 创建数据库和导入数据
& "$dbDir\bin\mysql.exe" -u root --port=3307 --protocol=tcp -e "CREATE DATABASE IF NOT EXISTS cloudthink DEFAULT CHARSET utf8;" 2>$null
$sqlFiles = @("cloudthink.sql", "sample_data.sql")
$wwwDir = "$workDir\www"
foreach ($sqlFile in $sqlFiles) {
    $sqlPath = "$wwwDir\$sqlFile"
    if (Test-Path $sqlPath) {
        & "$dbDir\bin\mysql.exe" -u root --port=3307 --protocol=tcp cloudthink < $sqlPath 2>$null
    }
}
# 设置 root 密码
& "$dbDir\bin\mysql.exe" -u root --port=3307 --protocol=tcp -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '123456'; FLUSH PRIVILEGES;" 2>$null

# 修改 db.php 连接端口
$dbFile = "$wwwDir\db.php"
$dbContent = Get-Content $dbFile -Raw
$dbContent = $dbContent -replace '127\.0\.0\.1["'"'"']\s*\)', '127.0.0.1", 3307)'
$dbContent = $dbContent -replace '\$db_pass\s*=\s*getenv\(''MYSQL_PASS''\).*?;', '$db_pass = getenv("MYSQL_PASS") ?: "123456";'
Set-Content -Path $dbFile -Value $dbContent

Write-Host "  数据库就绪" -ForegroundColor Green

# 启动 PHP
Write-Host "[3/3] 启动网站..." -ForegroundColor Green
$url = "http://localhost:$port"
$phpPath = "$phpDir\php.exe"

# 用 cmd 启动 PHP 服务器，避免 PowerShell 占用
$startCmd = "start /B `"$phpPath`" -S 0.0.0.0:$port -t `"$wwwDir`""
Start-Process -FilePath "cmd.exe" -ArgumentList "/c $startCmd" -NoNewWindow

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  网站已启动！" -ForegroundColor Green
Write-Host "  前台: $url/" -ForegroundColor White
Write-Host "  后台: $url/admin/" -ForegroundColor White
Write-Host "  管理员: admin / admin123" -ForegroundColor White
Write-Host ""
Write-Host "  关闭此窗口即可停止服务" -ForegroundColor Gray
Write-Host "============================================" -ForegroundColor Cyan

Start-Process $url

# 保持窗口
Write-Host ""
Write-Host "  按任意键停止服务..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
