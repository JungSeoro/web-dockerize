#!/bin/bash
PROJECT_NAME=${1:-app}
export $(cat .env | xargs)
echo -e "\033[1;94mCreate \033[1;0m\033[1;104m$PROJECT_NAME\033[1;0m\033[1;94m project on Node.js v$NODE_VERSION\033[1;0m"
docker run --rm --user $UID -v $(pwd)/../:/vol/$PROJECT_NAME node:$NODE_VERSION sh -c "cd /vol/$PROJECT_NAME && npm init -y && npm install express --save"