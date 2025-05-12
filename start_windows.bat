@chcp 65001 >nul
@echo off
setlocal enabledelayedexpansion

:: 기준 디렉토리 설정
set "BASEDIR=%USERPROFILE%\Documents"
set "DJANGO_DIR=%BASEDIR%\telofarmer_django"
set "CTRL_DIR=%BASEDIR%\controller_project"

:: tunnelname.txt에서 터널 이름 읽기
set "TUNNEL_FILE=%BASEDIR%\tunnelname.txt"
set "TUNNEL_NAME="

if exist "%TUNNEL_FILE%" (
    for /f "usebackq delims=" %%T in ("%TUNNEL_FILE%") do (
        set "TUNNEL_NAME=%%T"
        goto :start_tunnel
    )
) else (
    echo ❌ 터널 이름 파일이 존재하지 않음: %TUNNEL_FILE%
    pause
    exit /b
)

:start_tunnel
if "%TUNNEL_NAME%"=="" (
    echo ❌ tunnelname.txt가 비어있습니다.
    pause
    exit /b
)

:: 1. Django 디렉토리로 이동
cd /d "!DJANGO_DIR!"

echo ☁️ Cloudflare Tunnel 시작 → [%TUNNEL_NAME%]
start "" cloudflared tunnel run --url http://localhost:8000 %TUNNEL_NAME%

timeout /t 2 > nul

:: 2. Daphne 실행 (새 창)
start "" cmd /k "echo 🚀 Daphne (ASGI) 서버 시작 && daphne config.asgi:application"

timeout /t 2 > nul

:: 3. controller 실행
echo ⚙️ controller_main.py 실행...
cd /d "!CTRL_DIR!"
echo ▶ 실행: main.py
start "" cmd /k "python main.py"

echo ✅ 전체 실행 완료!
exit
