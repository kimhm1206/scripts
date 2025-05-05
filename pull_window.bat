@chcp 65001 >nul
@echo off
setlocal

:: 기준 디렉토리 설정
set "BASEDIR=%USERPROFILE%\Documents"

echo 📥 telofarmer_django pull
cd "%BASEDIR%\telofarmer_django" || (
    echo ❌ 디렉토리 없음
    exit /b 1
)
git pull

echo 📥 controller_project pull
cd "%BASEDIR%\controller_project" || (
    echo ❌ 디렉토리 없음
    exit /b 1
)
git pull

echo 📥 scripts pull
cd "%BASEDIR%\scripts" || (
    echo ❌ 디렉토리 없음
    exit /b 1
)
git pull

echo ✅ 모든 프로젝트 최신 상태로 업데이트 완료
pause
