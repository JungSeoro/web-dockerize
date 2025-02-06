#!/bin/bash

# Usage: ./create-project-electron.sh <Project Name>
# Example: ./create-project-electron.sh myapp

PROJECT_NAME=${1:-app}
export $(cat .env | xargs)

read -p "Do you want to set up React as well? (y/n): " setup_react

echo -e "\033[1;94mCreate \033[1;0m\033[1;104m$PROJECT_NAME\033[1;0m\033[1;94m project on Node.js v$NODE_VERSION\033[1;0m"

docker run --rm --user $UID -v $(pwd)/../:/vol/$PROJECT_NAME node:$NODE_VERSION sh -c "
  cd /vol/$PROJECT_NAME && \
  npm init -y && \
  npm install electron && \
  sed -i 's/\"main\": \".*\"/\"main\": \"main.js\"/' package.json && \
  sed -i '/\"scripts\": {/a \  \"start\": \"electron . --no-sandbox\",' package.json"

cat > ../main.js <<EOL
const { app, BrowserWindow } = require('electron');
const path = require('path');

function createWindow() {
  const win = new BrowserWindow({
    width: 800,
    height: 600,
    webPreferences: {
      nodeIntegration: false,
      contextIsolation: true, 
    },
  });

  // HTML 파일 로드
  win.loadFile('index.html');
}

app.on('ready', createWindow);

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

app.on('activate', () => {
  if (BrowserWindow.getAllWindows().length === 0) {
    createWindow();
  }
});
EOL

cat > ../index.html <<EOL
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Electron App</title>
</head>
<body>
  <h1>Hello, Electron!</h1>
</body>
</html>
EOL

if [ "$setup_react" = "y" ]; then
  docker run --rm --user $UID -v $(pwd)/../:/vol/$PROJECT_NAME node:$NODE_VERSION sh -c "
    cd /vol/$PROJECT_NAME && \
    npm install react react-dom && \
    npm install --save-dev @babel/preset-react @babel/core @babel/preset-env babel-loader webpack webpack-cli webpack-dev-server html-webpack-plugin"

  mkdir -p ../{public,src}

  cat > ../public/index.html <<EOL
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Electron with React</title>
</head>
<body>
  <div id="root"></div>
  <script src="../dist/bundle.js"></script>
</body>
</html>
EOL

  cat > ../src/App.js <<EOL
import React from 'react';

const App = () => {
  return (
    <div>
      <h1>Hello, Electron with React!</h1>
    </div>
  );
}

export default App;
EOL

  cat > ../src/index.js <<EOL
import React from 'react';
import ReactDOM from 'react-dom';
import App from './App';

ReactDOM.render(<App />, document.getElementById('root'));
EOL

  cat > ../.babelrc <<EOL
{
  "presets": ["@babel/preset-env", "@babel/preset-react"]
}
EOL

  cat > ../webpack.config.js <<EOL
const path = require('path');
const HtmlWebpackPlugin = require('html-webpack-plugin');

module.exports = {
  entry: './src/index.js',
  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: 'bundle.js'
  },
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: {
          loader: 'babel-loader'
        }
      }
    ]
  },
  plugins: [
    new HtmlWebpackPlugin({
      template: './public/index.html'
    })
  ],
  resolve: {
    extensions: ['.js', '.jsx']
  }
};
EOL
fi
