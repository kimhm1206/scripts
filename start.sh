#!/bin/bash

BASEDIR="/home/telofarm"
DJANGO_DIR="$BASEDIR/telofarmer_django"
CTRL_DIR="$BASEDIR/controller_project"

echo "🚀 Telofarm 서비스 시작"

# 인터넷 연결 체크 (최대 5초 대기)
for i in {1..15}; do
    if ping -c 1 -W 1 8.8.8.8 > /dev/null 2>&1; then
        echo "🌐 인터넷 연결됨 → cloudflared 실행"
        setsid cloudflared tunnel run --url http://localhost:8000 seongju> /dev/null 2>&1 < /dev/null &
        break
    else
        echo "🔄 인터넷 연결 대기 중 ($i/5)..."
        sleep 2
    fi
done
sleep 2
echo "🌀 Daphne 실행"
cd "$DJANGO_DIR"
setsid daphne config.asgi:application > /dev/null 2>&1 < /dev/null &

echo "🐍 Controller 실행"
cd "$CTRL_DIR"
setsid python3 main.py > /dev/null 2>&1 < /dev/null &

echo "🎉 start.sh → 조건 기반 서비스 실행 완료"
