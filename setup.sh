#!/usr/bin/env bash
set -e

GIT_REPO="https://github.com/lih257181-pixel/biyesheji-he-biyelunwen.git"
GIT_SSH_REPO="git@github.com:lih257181-pixel/biyesheji-he-biyelunwen.git"
DIR_NAME="cloudthink"
ADMIN_USER="admin"
ADMIN_PASS="admin123"
SITE_PORT="8080"

if [ ! -f "docker-compose.yml" ]; then
    echo "[*] docker-compose.yml not found in current directory."
    if command -v git &>/dev/null; then
        echo "[*] Cloning repository..."
        git clone "$GIT_REPO" "$DIR_NAME" 2>/dev/null || git clone "$GIT_SSH_REPO" "$DIR_NAME" 2>/dev/null || {
            echo "[!] 克隆失败，请确保有仓库访问权限"
            echo "    SSH方式: git clone $GIT_SSH_REPO"
            echo "    HTTPS方式: git clone $GIT_REPO (需要GitHub账号密码)"
            exit 1
        }
        cd "$DIR_NAME"
    else
        echo "[!] git not found and no docker-compose.yml here."
        echo "    Please run this script inside the project directory,"
        echo "    or install git:  apt install git -y  (or use your package manager)"
        exit 1
    fi
fi

if ! command -v docker &>/dev/null; then
    echo "[*] Docker not found. Installing Docker..."
    curl -fsSL https://get.docker.com | sh
    sudo usermod -aG docker "$USER" 2>/dev/null || true
    echo "[*] Docker installed. You may need to log out and back in for group changes."
    echo "    For now we continue with sudo..."
    DOCKER_CMD="sudo docker"
else
    DOCKER_CMD="docker"
fi

if ! docker compose version &>/dev/null 2>&1; then
    echo "[*] docker compose plugin not found. Installing..."
    sudo apt-get update -qq && sudo apt-get install -y -qq docker-compose-plugin
fi

echo "[*] Building and starting containers..."
$DOCKER_CMD compose up -d --build

echo ""
echo "============================================"
echo "  部署完成！"
echo ""
echo "  前台访问：http://localhost:${SITE_PORT}/"
echo "  后台访问：http://localhost:${SITE_PORT}/admin/"
echo "  管理员账号：${ADMIN_USER}  /  ${ADMIN_PASS}"
echo ""
echo "  停止服务：docker compose down"
echo "============================================"
