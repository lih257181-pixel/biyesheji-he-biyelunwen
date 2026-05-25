@echo off
chcp 65001 >nul
echo ============================================
echo    正在清除云创科技网站...
echo ============================================
docker compose down -v
docker rmi biyesheji-he-biyelunwen-web:latest 2>nul
echo.
echo ============================================
echo    已清除！
echo    数据库和数据卷已删除
echo ============================================
pause
