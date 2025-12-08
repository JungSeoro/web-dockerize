#!/bin/bash
set -e

# 사용법: ./create-vite-react.sh my-app
PROJECT_NAME=${1:-app}

# .env 에서 NODE_VERSION 로드 (기존 방식 그대로)
if [ -f .env ]; then
  export $(cat .env | xargs)
fi

echo -e "\033[1;94mCreate \033[1;0m\033[1;104m$PROJECT_NAME\033[1;0m\033[1;94m Vite React project on Node.js v$NODE_VERSION\033[1;0m"

# 현재 스크립트 위치의 상위폴더(../)를 /vol 로 마운트
# 거기 안에 바로 Vite 템플릿을 생성하는 방식
docker run --rm --user $UID -v "$(pwd)/../:/vol" node:$NODE_VERSION sh -c "
  cd /vol \
  && npm config set strict-ssl false \
  && npm create vite@latest . -- --template react-ts
"

echo -e "\033[1;92mDone!\033[0m Vite React (react-ts) 프로젝트가 ../ 에 생성되었어."
