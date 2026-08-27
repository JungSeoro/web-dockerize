#!/bin/sh
set -eu

workspace=${WORKSPACE_DIR:-/workspace}

if [ ! -f "$workspace/package.json" ]; then
  echo "package.json not found in $workspace" >&2
  exit 1
fi

require_writable_directory() {
  directory=$1
  if [ -L "$directory" ] || [ ! -d "$directory" ]; then
    echo "Directory must exist and must not be a symbolic link: $directory" >&2
    exit 1
  fi
  if ! gosu node /usr/bin/test -w "$directory"; then
    echo "Directory must be writable by the container user: $directory" >&2
    exit 1
  fi
}

for directory in \
  "$workspace/node_modules" \
  /home/node/.npm \
  /home/node/.cache \
  /home/node/.config \
  /home/node/Downloads
do
  require_writable_directory "$directory"
done

if [ "${SKIP_NPM_INSTALL:-0}" != "1" ]; then
  dependency_hash="$(
    {
      gosu node node --version
      gosu node npm --version
      sha256sum "$workspace/package.json"
      if [ -f "$workspace/package-lock.json" ]; then sha256sum "$workspace/package-lock.json"; fi
      if [ -f "$workspace/npm-shrinkwrap.json" ]; then sha256sum "$workspace/npm-shrinkwrap.json"; fi
      if [ -f "$workspace/.npmrc" ]; then sha256sum "$workspace/.npmrc"; fi
    } | sha256sum | cut -d ' ' -f 1
  )"
  install_marker="$workspace/node_modules/.docker-npm-$dependency_hash"

  if [ ! -f "$install_marker" ]; then
    install_mode=${NPM_INSTALL_MODE:-auto}
    if [ "$install_mode" = "auto" ]; then
      if [ -f "$workspace/package-lock.json" ] || [ -f "$workspace/npm-shrinkwrap.json" ]; then
        install_mode=ci
      else
        install_mode=install
      fi
    fi

    case "$install_mode" in
      ci)
        gosu node npm ci
        ;;
      install)
        gosu node npm install
        ;;
      *)
        echo "NPM_INSTALL_MODE must be auto, ci, or install" >&2
        exit 1
        ;;
    esac

    electron_installer="$workspace/node_modules/electron/install.js"
    electron_binary="$workspace/node_modules/electron/dist/electron"
    if [ -f "$electron_installer" ] && [ ! -x "$electron_binary" ]; then
      gosu node node "$electron_installer"
    fi

    gosu node touch "$install_marker"
  fi
fi

electron_package="$workspace/node_modules/electron/package.json"
sandbox_version_file=/usr/local/libexec/electron/version
if [ -f "$electron_package" ] && [ -r "$sandbox_version_file" ]; then
  sandbox_version=$(sed -n '1p' "$sandbox_version_file")
  installed_electron_version=$(gosu node node -e 'const fs = require("fs"); const packageFile = process.argv[1]; process.stdout.write(JSON.parse(fs.readFileSync(packageFile, "utf8")).version)' "$electron_package")
  if [ "$installed_electron_version" != "$sandbox_version" ]; then
    echo "Electron $installed_electron_version does not match the image sandbox helper $sandbox_version" >&2
    echo "Rebuild the image with ELECTRON_SANDBOX_VERSION=$installed_electron_version" >&2
    exit 1
  fi
fi

if [ "$#" -eq 0 ]; then
  set -- npm start
fi

exec gosu node dbus-run-session -- "$@"
