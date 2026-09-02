# Docker 개발 환경 사용법

이 저장소를 프로젝트 루트의 `docker/` 디렉터리에 두고 사용합니다. Node.js, Create React App, Vite React, Electron 개발 환경을 제공합니다.

## 준비

- Docker Engine 또는 Docker Desktop
- Docker Compose v2 (`docker compose`)
- Electron은 Linux 데스크톱 또는 WSLg 환경

새 프로젝트를 시작할 때는 다음과 같이 구성합니다.

```bash
mkdir my-app
cd my-app
git clone https://github.com/JungSeoro/web-dockerize.git docker
```

프로젝트 생성 스크립트는 실행 위치와 관계없이 `docker/`의 부모 디렉터리에 파일을 생성합니다. 아래 명령은 모두 프로젝트 루트에서 실행합니다. 신규 프로젝트 루트에는 `docker/`, `.git`, `.gitmodules` 외의 파일이 없어야 하며 생성 실패 시 기존 파일을 변경하지 않습니다.

## 패키지 버전 변경

Node.js를 호스트에 설치하지 않고 Node Docker 이미지로 `package.json`의 버전을 변경하며, `package-lock.json`이 있으면 함께 갱신합니다. Git 커밋과 태그는 생성하지 않습니다.

```bash
./docker/bump-version.sh patch
./docker/bump-version.sh pt
./docker/bump-version.sh minor
./docker/bump-version.sh mn
./docker/bump-version.sh major
./docker/bump-version.sh mj
./docker/bump-version.sh 1.2.3
```

`pt`, `mn`, `mj`는 각각 `patch`, `minor`, `major`의 약자입니다. 직접 입력하는 버전은 `x.y.z` 형식의 숫자 버전이어야 합니다. 사용할 Node 이미지 버전은 `docker/.env`의 `NODE_VERSION`을 따릅니다.

## 환경 선택

| 환경 | 프로젝트 생성 | Compose 파일 | 실행 결과 |
| --- | --- | --- | --- |
| Node.js | `create-project-nodejs.sh` | `docker-compose-nodejs.yml` | `http://localhost:3000` |
| React | `create-project-react.sh` | `docker-compose-react.yml` | `http://localhost:3000` |
| Vite React TypeScript | `create-project-vite-react.sh` | `docker-compose-vite-react.yml` | `http://localhost:3000` |
| Electron | `create-project-electron.sh` | `docker-compose-electron.yml` | 데스크톱 창 |

`compose-toggle.sh`는 선택한 환경이 실행 중이면 종료하고, 실행 중이 아니면 현재 터미널에서 시작해 실시간 로그를 출력합니다. `Ctrl+C`를 누르면 실행을 종료합니다. 프로젝트명은 프로젝트 루트 폴더명으로 자동 설정되며 두 번째 인자로 변경할 수 있습니다.

```bash
./docker/compose-toggle.sh electron
./docker/compose-toggle.sh electron my-app
```

인자 없이 실행하면 지원 환경과 사용 예시를 확인할 수 있습니다.

```bash
./docker/compose-toggle.sh
```

Bash와 Zsh 자동완성:

```bash
source ./docker/completions/compose-toggle.sh
```

스크립트를 직접 실행하거나 `bash`로 실행하는 방식 모두 자동완성됩니다.

```bash
./docker/compose-toggle.sh e<Tab>
bash ./docker/compose-toggle.sh e<Tab>
```

계속 사용하려면 프로젝트의 절대 경로를 사용해 Bash는 `~/.bashrc`, Zsh는 `~/.zshrc`에 같은 명령을 추가합니다.

```bash
source /path/to/project/docker/completions/compose-toggle.sh
```

## Node.js

```bash
./docker/create-project-nodejs.sh my-app
```

생성 후 프로젝트 루트에 `index.js`를 만들고 애플리케이션이 `0.0.0.0:3000`에서 수신하도록 설정합니다.

```js
const express = require('express')

const app = express()

app.get('/', (_request, response) => {
  response.send('Hello, Node.js!')
})

app.listen(3000, '0.0.0.0')
```

```bash
./docker/compose-toggle.sh nodejs
```

## React

JavaScript 프로젝트:

```bash
./docker/create-project-react.sh my-app
```

TypeScript 프로젝트:

```bash
./docker/create-project-react.sh my-app --ts
```

```bash
./docker/compose-toggle.sh react
```

## Vite React

React와 TypeScript로 생성됩니다.

```bash
./docker/create-project-vite-react.sh my-app
./docker/compose-toggle.sh vite-react
```

## Electron

Electron Forge 기반의 JavaScript 프로젝트를 생성합니다. 첫 번째 인자는 npm 패키지명, 두 번째 인자는 화면에 표시할 제품명입니다.

```bash
./docker/create-project-electron.sh my-app "My App"
./docker/compose-toggle.sh electron
```

생성되는 소스는 프로세스 역할에 따라 분리됩니다.

```text
src/
├── main/index.js
├── preload/index.js
└── renderer/
    ├── index.html
    ├── index.js
    └── styles.css
```

`npm start`, `npm run package`, `npm run make` 명령이 기본으로 설정됩니다.

Compose는 기본적으로 `jungseoro/electron:linux-dev` 이미지를 사용합니다. 이미지를 직접 만들려면 다음 명령을 먼저 실행합니다.

```bash
./docker/build-electron-image.sh
```

이미지의 `ELECTRON_SANDBOX_VERSION`은 프로젝트에 설치되는 Electron 버전과 같아야 합니다. 기본 보일러플레이트와 `docker/.env`는 동일한 버전으로 설정되어 있습니다. Electron 버전을 변경했다면 `docker/.env`도 변경하고 이미지를 다시 빌드합니다.

Electron Compose는 Linux 또는 WSLg의 GUI 개발용입니다. Windows와 macOS용 패키지는 각 운영체제에서 빌드해야 합니다.

Compose는 Chromium SUID sandbox의 PID/Network namespace 생성을 위해 `SYS_ADMIN` capability를 추가합니다. 신뢰할 수 없는 프로젝트 코드는 이 개발 컨테이너에서 실행하지 마세요.

## 기존 프로젝트에서 사용

기존 프로젝트에는 생성 스크립트를 실행하지 않고 `docker/` 디렉터리만 추가합니다. 프로젝트의 실행 명령과 일치하는 Compose 파일을 선택해 실행합니다.

Electron 프로젝트는 실행 전에 다운로드 출력 경로를 생성합니다.

```bash
mkdir -p downloads
```

- Node.js: `node index.js`
- React: `npm start`
- Vite React: `npm run dev`
- Electron: `npm start`

Node 버전과 Electron 이미지 태그는 `docker/.env`에서 변경할 수 있습니다. 실행할 때 사용한 `compose-toggle.sh` 명령을 다시 실행하면 종료됩니다.
