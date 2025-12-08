#!/bin/bash
set -e

# 사용법: ./create-vite-react.sh my-app
PROJECT_NAME=${1:-app}

if [ -f .env ]; then
  export $(cat .env | xargs)
fi

echo -e "\033[1;94mCreate \033[1;0m\033[1;104m$PROJECT_NAME\033[1;0m\033[1;94m Vite React project on Node.js v$NODE_VERSION\033[1;0m"

docker run --rm --user $UID -v "$(pwd)/../:/vol" node:$NODE_VERSION sh -c "
  cd /vol \
  && npm config set strict-ssl false \
  && npm create vite@latest . -- --template react-ts
"

echo -e "\033[1;92mDone!\033[0m Vite React (react-ts) 프로젝트가 ../ 에 생성되었어."
