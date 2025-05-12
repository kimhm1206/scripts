#!/bin/bash

BASEDIR="/home/telofarm"

echo "📥 telofarmer_django pull"
cd "$BASEDIR/telofarmer_django" || exit 1
git pull

echo "📥 controller_project pull"
cd "$BASEDIR/controller_project" || exit 1
git pull

echo "📥 scripts pull"
cd "$BASEDIR/scripts" || exit 1
git pull

echo "✅ 모든 프로젝트 최신 상태로 업데이트 완료"
