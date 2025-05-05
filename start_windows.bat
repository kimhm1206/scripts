@chcp 65001 >nul
@echo off
setlocal enabledelayedexpansion

:: 기준 디렉토리 설정
set "BASEDIR=%USERPROFILE%\Documents"
set "DJANGO_DIR=%BASEDIR%\telofarmer_django"
set "CTRL_DIR=%BASEDIR%\controller_project"

:: 1. Django 디렉토리로 이동
cd /d "!DJANGO_DIR!"

echo ☁️ Cloudflare Tunnel 시작...
start "" cloudflared tunnel run --url http://localhost:8000 posco3

timeout /t 2 > nul

:: 2. Daphne 실행 (새 창)
start "" cmd /k "echo 🚀 Daphne (ASGI) 서버 시작 && daphne config.asgi:application"

timeout /t 2 > nul

:: 3. controller 실행
echo ⚙️ controller_main.py 실행...
cd /d "!CTRL_DIR!"
echo ▶ 실행: main.py
python main.py

echo ✅ 전체 실행 완료!
pause
