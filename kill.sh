#!/bin/bash

echo "🛑 cloudflared 종료"
pkill -f "cloudflared tunnel" && echo "✅ cloudflared 종료됨" || echo "⚠️ cloudflared 프로세스 없음"

echo "🛑 controller(main.py) 종료"
pkill -f "python3 main.py" && echo "✅ main.py 종료됨" || echo "⚠️ main.py 프로세스 없음"

echo "🛑 daphne 종료"
pkill -f "daphne config.asgi:application" && echo "✅ daphne 종료됨" || echo "⚠️ daphne 프로세스 없음"

echo "✅ 모든 프로세스 정리 완료"
