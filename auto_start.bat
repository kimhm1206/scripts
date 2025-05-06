@echo off
:check_connection
ping -n 1 www.google.com >nul 2>&1
if errorlevel 1 (
    timeout /t 5 >nul
    goto check_connection
)

:: 인터넷 연결됨 → 실제 실행
start "" "%USERPROFILE%\Documents\scripts\start_windows.bat"
exit
