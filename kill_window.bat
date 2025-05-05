@chcp 65001 >nul
@echo off

REM 현재 창의 제목 설정
set "MY_TITLE=KILL_CMD_KEEP_THIS"
title %MY_TITLE%

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


echo 🛑 내 창 제목 제외, 나머지 cmd.exe 종료 중...

REM tasklist에서 "cmd.exe" 프로세스 중 제목이 다른 것만 종료
for /f "tokens=1,2,9 delims=," %%A in ('tasklist /v /fo csv ^| findstr /i "cmd.exe"') do (
    set "PID=%%~B"
    set "TITLE=%%~C"
    call :CHECK_TITLE !PID! "!TITLE!"
)

goto :eof

:CHECK_TITLE
REM %~2는 따옴표 제거된 TITLE
if "%~2"=="%MY_TITLE%" (
    echo 🛑 내 cmd 창(PID: %1, TITLE: %~2) 제외
) else (
    echo 🔪 종료 시도: PID %1 (TITLE: %~2)
    taskkill /f /pid %1 >nul 2>&1
    if %errorlevel%==0 (
        echo ✅ PID %1 종료 완료
    ) else (
        echo ⚠️ PID %1 종료 실패
    )
)

echo ☑️ 종료 시도 완료 (현재 창은 유지됨)

pause
