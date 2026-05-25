@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

set "WORK_DIR=%TEMP%\cloudthink_site"
set "PHP_DIR=%WORK_DIR%\runtime\php"
set "DB_DIR=%WORK_DIR%\runtime\mariadb"
set "DATA_DIR=%DB_DIR%\data"
set "WWW_DIR=%WORK_DIR%\www"
set "PORT=8080"

taskkill /f /im php.exe >nul 2>nul
taskkill /f /im mariadbd.exe >nul 2>nul
taskkill /f /im mysqld.exe >nul 2>nul
ping 127.0.0.1 -n 2 >nul

echo ============================================
echo   CloudThink Website - One Click Start
echo ============================================
echo.

if exist "%PHP_DIR%\php.exe" if exist "%DB_DIR%\bin\mariadbd.exe" (
    echo [1/3] Environment ready
    goto :init_db
)

echo [1/3] First run - downloading (about 80MB)...
echo.

if exist "%WORK_DIR%" rmdir /s /q "%WORK_DIR%"
mkdir "%WORK_DIR%\runtime" 2>nul

echo   Downloading PHP...
powershell -Command "Invoke-WebRequest -Uri 'https://windows.php.net/downloads/releases/php-8.1.29-nts-Win32-vs16-x64.zip' -UseBasicParsing -OutFile '%TEMP%\php.zip'"
if not exist "%TEMP%\php.zip" (
    echo Download PHP failed
    pause
    exit /b 1
)
powershell -Command "Expand-Archive -Path '%TEMP%\php.zip' -DestinationPath '%PHP_DIR%' -Force"
del "%TEMP%\php.zip" 2>nul

echo   Downloading MariaDB...
powershell -Command "Invoke-WebRequest -Uri 'https://archive.mariadb.org/mariadb-10.11.8/winx64-packages/mariadb-10.11.8-winx64.zip' -UseBasicParsing -OutFile '%TEMP%\mariadb.zip'"
if not exist "%TEMP%\mariadb.zip" (
    echo Download MariaDB failed
    pause
    exit /b 1
)
powershell -Command "Expand-Archive -Path '%TEMP%\mariadb.zip' -DestinationPath '%WORK_DIR%\runtime' -Force"
del "%TEMP%\mariadb.zip" 2>nul

for /d %%i in ("%WORK_DIR%\runtime\mariadb*") do (
    if exist "%%i\bin\mariadbd.exe" (
        move "%%i\*" "%DB_DIR%\" >nul 2>nul
        rmdir /s /q "%%i" 2>nul
    )
)
if not exist "%DB_DIR%\bin\mariadbd.exe" (
    echo MariaDB extract failed
    pause
    exit /b 1
)

echo   Downloading website code...
powershell -Command "Invoke-WebRequest -Uri 'https://github.com/lih257181-pixel/biyesheji-he-biyelunwen/archive/refs/heads/master.zip' -UseBasicParsing -OutFile '%TEMP%\site.zip'"
if not exist "%TEMP%\site.zip" (
    echo Download failed
    pause
    exit /b 1
)
powershell -Command "Expand-Archive -Path '%TEMP%\site.zip' -DestinationPath '%WORK_DIR%\site_tmp' -Force"
del "%TEMP%\site.zip" 2>nul

for /d %%i in ("%WORK_DIR%\site_tmp\*") do (
    xcopy /e /q /y "%%i\*" "%WWW_DIR%\" >nul
)
rmdir /s /q "%WORK_DIR%\site_tmp" 2>nul

if exist "%PHP_DIR%\php.ini-development" (
    copy /y "%PHP_DIR%\php.ini-development" "%PHP_DIR%\php.ini" >nul
)
if exist "%PHP_DIR%\php.ini" (
    powershell -Command "$f='%PHP_DIR%\php.ini';$c=Get-Content $f;$c=$c -replace ';extension_dir=\"ext\"','extension_dir=\"ext\"';$c=$c -replace ';extension=mysqli','extension=mysqli';$c=$c -replace ';extension=mbstring','extension=mbstring';$c=$c -replace ';extension=openssl','extension=openssl';Set-Content $f $c"
)

echo   Download complete

:init_db
echo [2/3] Initializing database...

if not exist "%DATA_DIR%\mysql" (
    echo   First time database init...
    "%DB_DIR%\bin\mariadbd.exe" --initialize-insecure --datadir="%DATA_DIR%" >nul 2>nul
    ping 127.0.0.1 -n 3 >nul
)

taskkill /f /im mariadbd.exe >nul 2>nul
taskkill /f /im mysqld.exe >nul 2>nul
ping 127.0.0.1 -n 2 >nul

echo   Starting database...
start /B "" "%DB_DIR%\bin\mariadbd.exe" --datadir="%DATA_DIR%" --port=3307 --skip-grant-tables
ping 127.0.0.1 -n 5 >nul

echo   Creating database and importing data...
"%DB_DIR%\bin\mysql.exe" -u root --port=3307 --protocol=tcp -e "CREATE DATABASE IF NOT EXISTS cloudthink DEFAULT CHARSET utf8;" 2>nul
"%DB_DIR%\bin\mysql.exe" -u root --port=3307 --protocol=tcp cloudthink -e "source %WWW_DIR%\cloudthink.sql" 2>nul
"%DB_DIR%\bin\mysql.exe" -u root --port=3307 --protocol=tcp cloudthink -e "source %WWW_DIR%\sample_data.sql" 2>nul
echo   Database ready

echo [3/3] Starting website...

> "%WWW_DIR%\db.php" echo ^<?php
>> "%WWW_DIR%\db.php" echo $db_host='127.0.0.1';$db_port=3307;$db_user='root';$db_pass='';$db_name='cloudthink';
>> "%WWW_DIR%\db.php" echo $conn=mysqli_connect($db_host,$db_user,$db_pass,$db_name,$db_port);
>> "%WWW_DIR%\db.php" echo if(!$conn)die('DB failed');mysqli_query($conn,'set names utf8');session_start();

> "%WWW_DIR%\admin\db.php" echo ^<?php
>> "%WWW_DIR%\admin\db.php" echo $db_host='127.0.0.1';$db_port=3307;$db_user='root';$db_pass='';$db_name='cloudthink';
>> "%WWW_DIR%\admin\db.php" echo $conn=mysqli_connect($db_host,$db_user,$db_pass,$db_name,$db_port);
>> "%WWW_DIR%\admin\db.php" echo if(!$conn)die('DB failed');mysqli_query($conn,'set names utf8');session_start();
>> "%WWW_DIR%\admin\db.php" echo if(!isset($_SESSION['admin'])){echo"<script>alert('login');window.location.href='index.php';</script>";exit;}

taskkill /f /im php.exe >nul 2>nul
ping 127.0.0.1 -n 2 >nul

start /B "" "%PHP_DIR%\php.exe" -S 0.0.0.0:%PORT% -t "%WWW_DIR%"
ping 127.0.0.1 -n 2 >nul

echo.
echo ============================================
echo   Website started!
echo.
echo   Frontend: http://localhost:%PORT%/
echo   Admin:    http://localhost:%PORT%/admin/
echo   Username: admin  Password: admin123
echo.
echo   Press any key to stop
echo ============================================

start http://localhost:%PORT%/
pause >nul

taskkill /f /im php.exe >nul 2>nul
taskkill /f /im mariadbd.exe >nul 2>nul
