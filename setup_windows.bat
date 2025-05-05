@chcp 65001 >nul
@echo off
setlocal enabledelayedexpansion

:: 1. 기준 디렉토리 설정 (Documents)
set "BASEDIR=%USERPROFILE%\Documents"
echo 📁 BASEDIR: %BASEDIR%

:: 2. Git 설치 확인
echo 🚀 [1] Git 설치 확인
where git >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ Git이 설치되지 않았습니다. https://git-scm.com/download/win 에서 설치해주세요.
    pause
    exit /b
)

:: 3. Python 설치 여부 확인
where python >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ Python이 설치되지 않았거나 환경변수 PATH에 등록되어 있지 않습니다.
    pause
    exit /b
)

:: 4. 기존 프로젝트 제거
echo 🧹 [2] 기존 프로젝트 제거
rmdir /s /q "%BASEDIR%\telofarmer_django"
rmdir /s /q "%BASEDIR%\controller_project"

:: 5. Git 저장소 클론
echo 🌐 [3] Git 저장소 클론
cd "%BASEDIR%"
git clone https://github.com/kimhm1206/telofarmer_django.git
git clone https://github.com/kimhm1206/controller_project.git

:: 6. pip 최신화
echo 📦 [4] pip 최신화
python -m pip install --upgrade pip

:: 7. pip 패키지 설치
echo 📦 [5] 필수 pip 패키지 설치
python -m pip install ^
aiohappyeyeballs aiohttp aiosignal altgraph APScheduler async-timeout attrs certifi cffi ^
charset-normalizer contourpy cryptography cycler fonttools frozenlist idna kiwisolver ^
matplotlib multidict numpy packaging pandas pefile pillow pip propcache pycparser ^
pyinstaller pyinstaller-hooks-contrib pyparsing python-dateutil pytz pywin32-ctypes ^
requests scipy setuptools six typing_extensions tzdata tzlocal urllib3 websockets yarl ^
asgiref autobahn Automat channels constantly daphne Django hyperlink incremental ^
psycopg2-binary pyasn1 pyasn1_modules pyOpenSSL service-identity sqlparse tomli Twisted ^
txaio whitenoise zope.interface

:: 8. cloudflared 설치
echo ☁️ [6] cloudflared 설치
set "CF_BIN=cloudflared.exe"
if not exist %CF_BIN% (
    powershell -Command "Invoke-WebRequest -Uri https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-windows-amd64.exe -OutFile cloudflared.exe"
)
move cloudflared.exe "%BASEDIR%\cloudflared.exe" >nul
set "PATH=%BASEDIR%;%PATH%"
echo ✅ cloudflared 다운로드 완료

:: 9. cloudflared 전역 실행을 위한 PATH 추가
echo 🔧 [7] cloudflared 전역 명령 설정 중...
for /f "tokens=*" %%i in ('powershell -command "[Environment]::GetEnvironmentVariable(\"Path\", \"User\")"') do set "CURPATH=%%i"
echo !CURPATH! | findstr /C:"%BASEDIR%" >nul
if %errorlevel%==0 (
    echo ✅ 이미 PATH에 %BASEDIR% 포함되어 있음
) else (
    echo ➕ PATH에 %BASEDIR% 추가 중...
    setx PATH "!CURPATH!;%BASEDIR%"
    echo ✅ 추가 완료. 다음 명령부터 cloudflared 전역 실행 가능
)

:: 10. cloudflared 로그인 안내
echo.
echo 📌 cloudflared 로그인하려면 다음 명령어를 수동 실행하세요:
echo     cloudflared tunnel login
echo.

:: 11. Git에서 db.sqlite3 무시 설정
echo 🔒 [8] Git 보호 설정
set "DBFILE=%BASEDIR%\telofarmer_django\db.sqlite3"
if exist "%DBFILE%" (
    cd "%BASEDIR%\telofarmer_django"
    git update-index --assume-unchanged db.sqlite3
    echo ✅ db.sqlite3 로컬 보호 적용
) else (
    echo ⚠️ db.sqlite3 파일 없음. Git 보호 생략
)

:: 12. 완료 안내
echo.
echo 🎉 모든 윈도우 초기 셋업 완료!
echo 🔁 cloudflared 및 python은 전역 명령어로 사용 가능
echo 🖥️  재부팅 후에도 자동 적용됩니다
pause
