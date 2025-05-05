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


echo 🛑 현재 cmd 창 제외, 나머지 cmd.exe 종료 중...

REM 현재 PID 가져오기
for /f %%i in ('powershell -Command "[System.Diagnostics.Process]::GetCurrentProcess().Id"') do set "SELF_PID=%%i"

REM powershell로 모든 cmd.exe 프로세스 중 본인 제외 후 종료
powershell -Command ^
"Get-CimInstance Win32_Process -Filter \"Name = 'cmd.exe'\" | Where-Object { \$_.ProcessId -ne %SELF_PID% } | ForEach-Object { Stop-Process -Id \$_.ProcessId -Force; Write-Output \u0022✅ 종료: PID \$($_.ProcessId)\u0022 }"

echo ☑️ 모든 남은 cmd.exe 종료 시도 완료

echo ✅ 모든 프로세스 정리 완료
pause
