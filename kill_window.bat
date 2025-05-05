@chcp 65001 >nul
@echo off

echo 🛑 cloudflared 종료
taskkill /f /im cloudflared.exe >nul 2>&1
if %errorlevel%==0 (
    echo ✅ cloudflared 종료됨
) else (
    echo ⚠️ cloudflared 프로세스 없음
)

echo 🛑 controller(main.py) 종료
for /f "tokens=2 delims=," %%i in ('tasklist /v /fo csv ^| findstr /i "python.exe"') do (
    tasklist /fi "PID eq %%i" /v | findstr /i "main.py" >nul && (
        taskkill /f /pid %%i >nul
        echo ✅ main.py 종료됨
    )
)
echo ⚠️ main.py 관련 프로세스 없음 (또는 이미 종료됨)

echo 🛑 daphne 종료
for /f "tokens=2 delims=," %%i in ('tasklist /v /fo csv ^| findstr /i "daphne"') do (
    taskkill /f /pid %%i >nul
    echo ✅ daphne 종료됨
)

echo ✅ 모든 프로세스 정리 완료
pause
