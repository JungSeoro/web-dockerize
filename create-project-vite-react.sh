#!/bin/bash
set -e

# 사용법: ./create-vite-react.sh my-app
PROJECT_NAME=${1:-app}

if [ -f .env ]; then
  export $(cat .env | xargs)
fi

echo -e "\033[1;94mCreate \033[1;0m\033[1;104m$PROJECT_NAME\033[1;0m\033[1;94m Vite React project on Node.js v$NODE_VERSION\033[1;0m"

docker run --rm --user $UID -v "$(pwd)/../:/vol" node:$NODE_VERSION sh -c "
  set -e \
  && cd /tmp \
  && npm config set strict-ssl false \
  && npm create vite@latest $PROJECT_NAME -- --template react-ts \
  && cd $PROJECT_NAME \
  && cp -r . /vol \
  && cd /tmp \
  && rm -rf $PROJECT_NAME
"

SRC_DIR="../src"
mkdir -p "$SRC_DIR"
for dir in components constants hooks store services stories utils views; do
  mkdir -p "$SRC_DIR/$dir"
  touch "$SRC_DIR/$dir/.gitkeep"
done

echo -e "\033[1;92mDone!\033[0m Vite React (react-ts) 프로젝트가 ../ 에 생성되었어."
