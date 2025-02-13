#!/bin/bash

# ./create-project-react.sh <Project Name> [--ts]
# Example: ./create-project-react.sh myapp --ts

PROJECT_NAME=${1:-app}
TEMPLATE=""
IS_TS=false

if [ "$2" == "--ts" ]; then
    TEMPLATE="--template typescript"
    IS_TS=true
fi

export $(cat .env | xargs)
echo -e "\033[1;94mCreating \033[1;0m\033[1;104m$PROJECT_NAME\033[1;0m\033[1;94m project on Node.js v$NODE_VERSION\033[1;0m"
docker run --rm --user $UID -v $(pwd)/../:/vol node:$NODE_VERSION sh -c "\
  npx create-react-app ~/$PROJECT_NAME $TEMPLATE && \
  npm install --prefix  ~/$PROJECT_NAME web-vitals && \
  mv ~/$PROJECT_NAME/* /vol"

if [ "$IS_TS" = true ]; then
    INIT_REACT_DIR="./init_react_ts"
else
    INIT_REACT_DIR="./init_react"
fi

DEST_DIR="../"
if [ -d "$INIT_REACT_DIR" ]; then
    echo "Copying initial React setup files..."
    cp -r $INIT_REACT_DIR/* $DEST_DIR/
fi

rm -f "$DEST_DIR/src/logo.svg"
rm -f "$DEST_DIR/src/App.css"

mkdir -p $DEST_DIR/src/{assets,components,constants,hooks,state,services,utils,views}
for dir in assets components constants hooks state services utils views; do
    touch "$DEST_DIR/src/$dir/.gitkeep"
done

echo -e "\033[1;92mProject \033[1;0m\033[1;104m$PROJECT_NAME\033[1;0m\033[1;92m setup complete! 🚀\033[1;0m"