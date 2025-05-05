@chcp 65001 >nul
@echo off

echo 🛑 cloudflared 종료
taskkill /f /im cloudflared.exe >nul 2>&1
if %errorlevel%==0 (
    echo ✅ cloudflared 종료됨
) else (
    echo ⚠️ cloudflared 프로세스 없음
)

echo 🛑 main.py 종료 시도 중...

powershell -Command "Get-CimInstance Win32_Process | Where-Object { $_.CommandLine -like '*main.py*' } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force; Write-Output '✅ main.py 종료됨' }"

if %errorlevel% neq 0 (
    echo ⚠️ main.py 프로세스를 찾을 수 없거나 이미 종료됨
)

echo 🛑 daphne 종료
for /f "tokens=2 delims=," %%i in ('tasklist /v /fo csv ^| findstr /i "daphne"') do (
    taskkill /f /pid %%i >nul
    echo ✅ daphne 종료됨
)


echo 🛑 실행 중인 cmd 창 제외, 나머지 cmd.exe 종료 중...

REM 현재 PID 구하기
for /f %%i in ('powershell -Command "[System.Diagnostics.Process]::GetCurrentProcess().Id"') do set SELF_PID=%%i

REM 모든 cmd.exe 중 현재 pid 제외하고 종료
for /f "tokens=2 delims=," %%i in ('tasklist /v /fo csv ^| findstr /i "cmd.exe"') do (
    if not %%i==%SELF_PID% (
        taskkill /f /pid %%i >nul
        echo ✅ cmd.exe (PID %%i) 종료됨
    )
)

echo ☑️ 남은 cmd.exe 종료 완료 (현재 창 제외)

echo ✅ 모든 프로세스 정리 완료
pause
