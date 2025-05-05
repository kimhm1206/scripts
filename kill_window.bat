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


echo 🛑 현재 창을 제외한 나머지 cmd.exe 종료 시도 중...

REM 현재 PID 가져오기
for /f %%i in ('powershell -NoProfile -Command "[System.Diagnostics.Process]::GetCurrentProcess().Id"') do set "SELF_PID=%%i"

REM 모든 cmd.exe 중 내 PID 제외하고 종료
for /f "tokens=2 delims=," %%P in ('tasklist /v /fo csv ^| findstr /i "cmd.exe"') do (
    set "PID=%%~P"
    call :CheckAndKill !PID!
)

goto :eof

:CheckAndKill
if "%1"=="%SELF_PID%" (
    echo 🛑 내 PID %1 은 제외
) else (
    echo 🔪 종료 시도 → PID %1
    taskkill /pid %1 >nul 2>&1
    if not errorlevel 1 (
        echo ✅ PID %1 종료됨
    ) else (
        echo ❌ PID %1 종료 실패 (권한 부족 또는 이미 종료)
    )
)
echo ☑️ 종료 시도 완료 (현재 창은 유지됨)

pause
