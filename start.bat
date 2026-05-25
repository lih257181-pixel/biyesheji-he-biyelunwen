@echo off
chcp 65001 >nul
title 云创科技企业网站 - 一键部署

echo ============================================
echo    云创科技企业网站 - 一键部署脚本
echo    适用于 Windows (无需Docker/Git)
echo ============================================
echo.
echo 本脚本将自动检测并启动：
echo   1. PHP 内置开发服务器
echo   2. MySQL / MariaDB 数据库
echo.

:: 获取当前目录
set "ROOT=%~dp0"
set "ROOT=%ROOT:~0,-1%"

:: 检查 PHP
echo [1/3] 检测 PHP 环境...
where php >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo   未检测到 PHP，正在下载便携版 PHP...
    if not exist "%ROOT%\tools\php" mkdir "%ROOT%\tools\php"
    powershell -Command "Invoke-WebRequest -Uri 'https://windows.php.net/downloads/releases/php-8.1.29-Win32-vs16-x64.zip' -OutFile '%ROOT%\tools\php.zip'"
    powershell -Command "Expand-Archive -Path '%ROOT%\tools\php.zip' -DestinationPath '%ROOT%\tools\php' -Force"
    del "%ROOT%\tools\php.zip"
    echo   PHP 下载完成
)
set "PHP_PATH=%ROOT%\tools\php\php.exe"
if not exist "%PHP_PATH%" (
    where php >nul 2>&1
    if %ERRORLEVEL% EQU 0 (
        set "PHP_PATH=php"
    ) else (
        echo   错误：找不到 PHP，请手动安装 https://windows.php.net/download/
        pause
        exit /b 1
    )
)
echo   PHP 就绪：%PHP_PATH%

:: 检查 MySQL
echo [2/3] 检测 MySQL 环境...
where mysql >nul 2>&1
set "MYSQL_EXISTS=%ERRORLEVEL%"

where mariadb >nul 2>&1
set "MARIADB_EXISTS=%ERRORLEVEL%"

if %MYSQL_EXISTS% NEQ 0 if %MARIADB_EXISTS% NEQ 0 (
    echo   未检测到 MySQL，正在下载便携版 MariaDB...
    if not exist "%ROOT%\tools\mariadb" mkdir "%ROOT%\tools\mariadb"
    powershell -Command "Invoke-WebRequest -Uri 'https://archive.mariadb.org/mariadb-10.11.8/winx64-packages/mariadb-10.11.8-winx64.zip' -OutFile '%ROOT%\tools\mariadb.zip'"
    powershell -Command "Expand-Archive -Path '%ROOT%\tools\mariadb.zip' -DestinationPath '%ROOT%\tools\mariadb' -Force"
    del "%ROOT%\tools\mariadb.zip"
    :: 移动文件到正确位置
    for /d %%i in ("%ROOT%\tools\mariadb\*") do (
        if exist "%%i\bin\mysqld.exe" (
            move "%%i\*" "%ROOT%\tools\mariadb\" >nul
        )
    )
    echo   MariaDB 下载完成
)

set "MYSQL_PATH=%ROOT%\tools\mariadb\bin\mysql.exe"
if not exist "%MYSQL_PATH%" (
    where mysql >nul 2>&1
    if %ERRORLEVEL% EQU 0 (
        set "MYSQL_PATH=mysql"
        set "MYSQLADMIN_PATH=mysqladmin"
    ) else (
        echo   错误：找不到 MySQL，跳过数据库初始化
        echo   请确保已安装 MySQL 并手动导入 cloudthink.sql
        pause
        exit /b 1
    )
) else (
    set "MYSQLADMIN_PATH=%ROOT%\tools\mariadb\bin\mysqladmin.exe"
)
echo   MySQL 就绪

:: 初始化数据库
echo [3/3] 初始化数据库...
:: 先尝试连接已有数据库 - 用root无密码或123456
"%MYSQL_PATH%" -u root -p123456 -e "CREATE DATABASE IF NOT EXISTS cloudthink DEFAULT CHARSET utf8;" 2>nul
if %ERRORLEVEL% NEQ 0 (
    "%MYSQL_PATH%" -u root -p -e "CREATE DATABASE IF NOT EXISTS cloudthink DEFAULT CHARSET utf8;" 2>nul
    if %ERRORLEVEL% NEQ 0 (
        "%MYSQL_PATH%" -u root -e "CREATE DATABASE IF NOT EXISTS cloudthink DEFAULT CHARSET utf8;" 2>nul
    )
)

:: 导入 SQL
"%MYSQL_PATH%" -u root -p123456 cloudthink < "%ROOT%\cloudthink.sql" 2>nul
if %ERRORLEVEL% NEQ 0 (
    "%MYSQL_PATH%" -u root cloudthink < "%ROOT%\cloudthink.sql" 2>nul
)
"%MYSQL_PATH%" -u root -p123456 cloudthink < "%ROOT%\sample_data.sql" 2>nul
if %ERRORLEVEL% NEQ 0 (
    "%MYSQL_PATH%" -u root cloudthink < "%ROOT%\sample_data.sql" 2>nul
)
echo   数据库初始化完成

:: 启动 PHP 内置服务器
echo.
echo ============================================
echo    部署完成！
echo.
echo    前台访问：http://localhost:8080/
echo    后台访问：http://localhost:8080/admin/
echo    管理员账号：admin  /  admin123
echo.
echo    按 Ctrl+C 停止服务
echo ============================================
echo.

cd /d "%ROOT%"
"%PHP_PATH%" -S 0.0.0.0:8080 -t "%ROOT%"

pause
