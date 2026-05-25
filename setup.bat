@echo off
chcp 65001 >nul
title 云创科技 - 一键Docker部署

set "GIT_REPO=git@github.com:lih257181-pixel/biyesheji-he-biyelunwen.git"
set "DIR_NAME=cloudthink"
set "ADMIN_USER=admin"
set "ADMIN_PASS=admin123"
set "SITE_PORT=8080"

echo ============================================
echo    云创科技企业网站 - 一键Docker部署
echo ============================================
echo.

if not exist "docker-compose.yml" (
    echo [*] docker-compose.yml 未在当前目录找到
    where git >nul 2>&1
    if %ERRORLEVEL% EQU 0 (
        echo [*] 正在克隆仓库...
        git clone "%GIT_REPO%" "%DIR_NAME%"
        cd "%DIR_NAME%"
    ) else (
        echo [!] 未找到 git，请先安装 Git: https://git-scm.com/download/win
        pause
        exit /b 1
    )
)

echo [1/3] 检测 Docker Desktop...
where docker >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [*] 未检测到 Docker Desktop，正在下载安装程序...
    powershell -Command "Invoke-WebRequest -Uri 'https://desktop.docker.com/win/stable/amd64/Docker Desktop Installer.exe' -OutFile '%TEMP%\DockerDesktopInstaller.exe'"
    echo [*] 正在静默安装 Docker Desktop (安装完成后可能需要重启)...
    start /wait "" "%TEMP%\DockerDesktopInstaller.exe" install --accept-license --quiet
    echo [*] 等待 Docker Desktop 启动...
    timeout /t 30 /nobreak >nul
)

echo [2/3] 等待 Docker 就绪...
:wait_docker
docker info >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo     正在等待 Docker 引擎启动...
    timeout /t 5 /nobreak >nul
    goto wait_docker
)
echo [*] Docker 就绪

echo [3/3] 构建并启动容器...
docker compose up -d --build

echo.
echo ============================================
echo    部署完成！
echo.
echo    前台访问：http://localhost:%SITE_PORT%/
echo    后台访问：http://localhost:%SITE_PORT%/admin/
echo    管理员账号：%ADMIN_USER%  /  %ADMIN_PASS%
echo.
echo    停止服务：docker compose down
echo ============================================
echo.
pause
