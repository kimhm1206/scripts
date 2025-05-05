#!/bin/bash

# 기준 디렉토리 고정
BASEDIR="/home/telofarm"
echo "📁 BASEDIR: $BASEDIR"

echo "🚀 [1] Git 설치"
sudo apt update
sudo apt install -y git

echo "📁 [2] 기준 디렉토리 생성 및 소유권 변경"
sudo mkdir -p "$BASEDIR"
sudo chown -R telofarm:telofarm "$BASEDIR"

echo "🧹 [3] 기존 프로젝트 제거"
rm -rf "$BASEDIR/telofarmer_django"
rm -rf "$BASEDIR/controller_project"

echo "🌐 [4] Git 저장소 클론"
cd "$BASEDIR"
git clone https://github.com/kimhm1206/telofarmer_django.git
git clone https://github.com/kimhm1206/controller_project.git

echo "🐍 [5] Python3 및 pip 설치"
sudo apt install -y python3 python3-pip

echo "🛠️ [6] 필수 빌드 패키지 설치"
sudo apt install -y build-essential python3-dev libffi-dev libssl-dev libjpeg-dev zlib1g-dev

echo "📦 [7] pip 최신화"
pip3 install --break-system-packages --upgrade pip

echo "📦 [8] 전체 pip 패키지 설치 (개발환경 동일하게)"
pip3 install --break-system-packages \
  aiohappyeyeballs aiohttp aiosignal altgraph APScheduler async-timeout attrs certifi cffi \
  charset-normalizer contourpy cryptography cycler fonttools frozenlist idna kiwisolver \
  matplotlib multidict numpy packaging pandas pefile pillow pip propcache pycparser \
  pyinstaller pyinstaller-hooks-contrib pyparsing python-dateutil pytz pywin32-ctypes \
  requests scipy setuptools six typing_extensions tzdata tzlocal urllib3 websockets yarl \
  asgiref autobahn Automat channels constantly daphne Django hyperlink incremental \
  psycopg2-binary pyasn1 pyasn1_modules pyOpenSSL service-identity sqlparse tomli Twisted \
  txaio whitenoise zope.interface python3-lgpio

echo "🈶 [9] 한글 폰트 설치 (나눔 폰트)"
sudo apt install -y fonts-nanum
sudo fc-cache -fv
echo "✅ 한글 폰트 설치 완료"

echo "☁️ [10] cloudflared 설치"
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64.deb
sudo dpkg -i cloudflared-linux-arm64.deb || sudo apt-get -f install -y

echo "✅ [11] cloudflared 로그인 안내"
echo ""
echo "📌 아래 명령을 직접 실행해서 GitHub 로그인하세요:"
echo "    cloudflared tunnel login"
echo ""

echo "🔒 [12] DB 및 프로젝트 폴더 권한 수정"
sudo chown telofarm:telofarm "$BASEDIR/telofarmer_django/db.sqlite3" 2>/dev/null || echo "⚠️ db.sqlite3 아직 없음, 나중에 다시 확인"
sudo chown -R telofarm:telofarm /home/telofarm/telofarmer_django
sudo chown -R telofarm:telofarm /home/telofarm/controller_project
echo "✅ 권한 조정 완료"

echo "🚫 [13] 이후 git pull에서 db.sqlite3 덮어쓰기 방지 설정"
if [ -f "$BASEDIR/telofarmer_django/db.sqlite3" ]; then
  cd "$BASEDIR/telofarmer_django"
  git update-index --assume-unchanged db.sqlite3
  echo "✅ db.sqlite3 로컬 보호 적용 (Git pull 시 무시)"
else
  echo "⚠️ db.sqlite3 파일이 없어 Git 보호 설정 생략됨"
fi

echo "🎉 초기 셋업 완료! ➤ 이후 update_rpi.sh 로 시스템 자동 재시작 가능"
