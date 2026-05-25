@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

title 云创科技企业网站 - 一键启动
echo ============================================
echo    云创科技企业网站 - 一键启动
echo ============================================
echo.

set "WORK_DIR=%TEMP%\cloudthink_site"
set "PHP_DIR=%WORK_DIR%\runtime\php"
set "DB_DIR=%WORK_DIR%\runtime\mariadb"
set "DATA_DIR=%DB_DIR%\data"
set "WWW_DIR=%WORK_DIR%\www"
set "PORT=8080"

:: 清理残留进程
taskkill /f /im php.exe >nul 2>nul
taskkill /f /im mariadbd.exe >nul 2>nul
taskkill /f /im mysqld.exe >nul 2>nul
ping 127.0.0.1 -n 2 >nul

:: 检测是否已有缓存
if exist "%PHP_DIR%\php.exe" if exist "%DB_DIR%\bin\mariadbd.exe" (
    echo [1/3] 运行环境已就绪
    goto init_db
)

echo [1/3] 首次运行，正在下载依赖（约 80MB）...
echo.

:: 清理旧文件
if exist "%WORK_DIR%" rmdir /s /q "%WORK_DIR%"
mkdir "%WORK_DIR%\runtime" 2>nul

:: 下载 PHP
echo   下载 PHP...
powershell -Command "Invoke-WebRequest -Uri 'https://windows.php.net/downloads/releases/php-8.1.29-nts-Win32-vs16-x64.zip' -UseBasicParsing -OutFile '%TEMP%\php.zip'"
if not exist "%TEMP%\php.zip" (
    echo   下载 PHP 失败，请检查网络连接
    pause
    exit /b 1
)
powershell -Command "Expand-Archive -Path '%TEMP%\php.zip' -DestinationPath '%PHP_DIR%' -Force"
del "%TEMP%\php.zip" 2>nul

:: 下载 MariaDB
echo   下载 MariaDB...
powershell -Command "Invoke-WebRequest -Uri 'https://archive.mariadb.org/mariadb-10.11.8/winx64-packages/mariadb-10.11.8-winx64.zip' -UseBasicParsing -OutFile '%TEMP%\mariadb.zip'"
if not exist "%TEMP%\mariadb.zip" (
    echo   下载 MariaDB 失败，请检查网络连接
    pause
    exit /b 1
)
powershell -Command "Expand-Archive -Path '%TEMP%\mariadb.zip' -DestinationPath '%WORK_DIR%\runtime' -Force"
del "%TEMP%\mariadb.zip" 2>nul

:: 移动 MariaDB 文件
for /d %%i in ("%WORK_DIR%\runtime\mariadb*") do (
    if exist "%%i\bin\mariadbd.exe" (
        move "%%i\*" "%DB_DIR%\" >nul 2>nul
        rmdir /s /q "%%i" 2>nul
    )
)
if not exist "%DB_DIR%\bin\mariadbd.exe" (
    echo   解压 MariaDB 失败
    pause
    exit /b 1
)

:: 下载网站代码
echo   下载网站代码...
powershell -Command "Invoke-WebRequest -Uri 'https://github.com/lih257181-pixel/biyesheji-he-biyelunwen/archive/refs/heads/master.zip' -UseBasicParsing -OutFile '%TEMP%\site.zip'"
if not exist "%TEMP%\site.zip" (
    echo   下载网站代码失败
    pause
    exit /b 1
)
powershell -Command "Expand-Archive -Path '%TEMP%\site.zip' -DestinationPath '%WORK_DIR%\site_tmp' -Force"
del "%TEMP%\site.zip" 2>nul

:: 找解压出来的目录
for /d %%i in ("%WORK_DIR%\site_tmp\*") do (
    xcopy /e /q /y "%%i\*" "%WWW_DIR%\" >nul
)
rmdir /s /q "%WORK_DIR%\site_tmp" 2>nul

:: 配置 php.ini
if exist "%PHP_DIR%\php.ini-development" (
    copy /y "%PHP_DIR%\php.ini-development" "%PHP_DIR%\php.ini" >nul
)
if exist "%PHP_DIR%\php.ini" (
    powershell -Command "$f='%PHP_DIR%\php.ini';$c=Get-Content $f;$c=$c-replace ';extension_dir=\"ext\"','extension_dir=\"ext\"';$c=$c-replace ';extension=mysqli','extension=mysqli';$c=$c-replace ';extension=mbstring','extension=mbstring';$c=$c-replace ';extension=openssl','extension=openssl';Set-Content $f $c"
)

echo   下载完成

:init_db
echo [2/3] 初始化数据库...

:: 首次初始化 data 目录
if not exist "%DATA_DIR%\mysql" (
    echo   首次初始化数据库...
    "%DB_DIR%\bin\mariadbd.exe" --initialize-insecure --datadir="%DATA_DIR%" >nul 2>nul
    ping 127.0.0.1 -n 3 >nul
)

:: 停止可能的残留进程
taskkill /f /im mariadbd.exe >nul 2>nul
taskkill /f /im mysqld.exe >nul 2>nul
ping 127.0.0.1 -n 2 >nul

:: 启动 MariaDB
echo   启动数据库...
start /B "" "%DB_DIR%\bin\mariadbd.exe" --datadir="%DATA_DIR%" --port=3307 --skip-grant-tables
ping 127.0.0.1 -n 5 >nul

:: 创建数据库和导入数据
"%DB_DIR%\bin\mysql.exe" -u root --port=3307 --protocol=tcp -e "CREATE DATABASE IF NOT EXISTS cloudthink DEFAULT CHARSET utf8;" 2>nul
"%DB_DIR%\bin\mysql.exe" -u root --port=3307 --protocol=tcp cloudthink -e "source %WWW_DIR%\cloudthink.sql" 2>nul
"%DB_DIR%\bin\mysql.exe" -u root --port=3307 --protocol=tcp cloudthink -e "source %WWW_DIR%\sample_data.sql" 2>nul

echo   数据库就绪

:: 生成 db.php 配置
echo [3/3] 启动网站...
(
echo ^<?php
echo $db_host = '127.0.0.1';
echo $db_port = 3307;
echo $db_user = 'root';
echo $db_pass = '';
echo $db_name = 'cloudthink';
echo $conn = mysqli_connect^(^$db_host, ^$db_user, ^$db_pass, ^$db_name, ^$db_port^);
echo if ^(!^$conn^) die^('数据库连接失败'^);
echo mysqli_query^(^$conn, 'set names utf8'^);
echo session_start^(^);
) > "%WWW_DIR%\db.php"

(
echo ^<?php
echo $db_host = '127.0.0.1';
echo $db_port = 3307;
echo $db_user = 'root';
echo $db_pass = '';
echo $db_name = 'cloudthink';
echo $conn = mysqli_connect^(^$db_host, ^$db_user, ^$db_pass, ^$db_name, ^$db_port^);
echo if ^(!^$conn^) die^('数据库连接失败'^);
echo mysqli_query^(^$conn, 'set names utf8'^);
echo session_start^(^);
echo if ^(!isset^(^$_SESSION['admin']^)^^) {
echo     echo "<script>alert('请先登录');window.location.href='index.php';</script>";
echo     exit;
echo }
) > "%WWW_DIR%\admin\db.php"

:: 停止旧 PHP 进程
taskkill /f /im php.exe >nul 2>nul
ping 127.0.0.1 -n 2 >nul

:: 启动 PHP 内置服务器
start /B "" "%PHP_DIR%\php.exe" -S 0.0.0.0:%PORT% -t "%WWW_DIR%"
ping 127.0.0.1 -n 2 >nul

:success
echo.
echo ============================================
echo    网站已启动！
echo.
echo    前台: http://localhost:%PORT%/
echo    后台: http://localhost:%PORT%/admin/
echo    管理员: admin / admin123
echo.
echo    按任意键停止服务
echo ============================================

start http://localhost:%PORT%/
pause >nul

:: 停止服务
taskkill /f /im php.exe >nul 2>nul
taskkill /f /im mariadbd.exe >nul 2>nul
