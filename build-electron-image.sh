#!/bin/sh
set -eu

script_directory=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
env_file="$script_directory/.env"

read_env_value() {
  key=$1
  if [ -f "$env_file" ]; then
    sed -n "s/^[[:space:]]*$key[[:space:]]*=[[:space:]]*//p" "$env_file" | tail -n 1 | tr -d '\r'
  fi
}

electron_image=${ELECTRON_IMAGE:-$(read_env_value ELECTRON_IMAGE)}
electron_node_version=${NODE_VERSION:-$(read_env_value NODE_VERSION)}
electron_sandbox_version=${ELECTRON_SANDBOX_VERSION:-$(read_env_value ELECTRON_SANDBOX_VERSION)}
electron_uid=${LOCAL_UID:-$(read_env_value LOCAL_UID)}
electron_gid=${LOCAL_GID:-$(read_env_value LOCAL_GID)}

electron_image=${electron_image:-jungseoro/electron:linux-dev}
electron_node_version=${electron_node_version:-22}
electron_sandbox_version=${electron_sandbox_version:-43.4.1}
electron_uid=${electron_uid:-1000}
electron_gid=${electron_gid:-1000}

docker build \
  --build-arg "NODE_VERSION=$electron_node_version" \
  --build-arg "ELECTRON_SANDBOX_VERSION=$electron_sandbox_version" \
  --build-arg "LOCAL_UID=$electron_uid" \
  --build-arg "LOCAL_GID=$electron_gid" \
  --file "$script_directory/DockerfileElectron" \
  --tag "$electron_image" \
  "$script_directory"

printf 'Built %s with Electron sandbox %s\n' "$electron_image" "$electron_sandbox_version"
