#!/usr/bin/env bash
set -Eeuo pipefail

script_directory=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
project_directory=$(CDPATH= cd -- "$script_directory/.." && pwd -P)

fail() {
  printf '%s\n' "$*" >&2
  exit 1
}

read_node_version() {
  local env_file=$1
  local node_version=${NODE_VERSION:-}

  if [ -z "$node_version" ] && [ -f "$env_file" ]; then
    node_version=$(sed -n 's/^[[:space:]]*NODE_VERSION[[:space:]]*=[[:space:]]*//p' "$env_file" | tail -n 1)
  fi

  node_version=${node_version:-22}
  node_version=$(printf '%s' "$node_version" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

  if [ "${#node_version}" -ge 2 ]; then
    case "$node_version" in
      \"*\")
        node_version=${node_version#\"}
        node_version=${node_version%\"}
        ;;
      \'*\')
        node_version=${node_version#\'}
        node_version=${node_version%\'}
        ;;
    esac
  fi

  if [ "${#node_version}" -gt 128 ] || [[ ! "$node_version" =~ ^[A-Za-z0-9_][A-Za-z0-9._-]*$ ]]; then
    fail "Invalid NODE_VERSION: $node_version"
  fi

  printf '%s\n' "$node_version"
}

print_usage() {
  printf 'Usage: %s <major|minor|patch|mj|mn|pt|x.y.z>\n' "$0"
  printf 'Examples:\n'
  printf '  %s patch\n' "$0"
  printf '  %s pt\n' "$0"
  printf '  %s minor\n' "$0"
  printf '  %s mn\n' "$0"
  printf '  %s major\n' "$0"
  printf '  %s mj\n' "$0"
  printf '  %s 1.2.3\n' "$0"
}

if [ "$#" -ne 1 ]; then
  print_usage >&2
  exit 2
fi

version_spec=$1
case "$version_spec" in
  -h | --help)
    print_usage
    exit 0
    ;;
  major | minor | patch)
    ;;
  mj)
    version_spec=major
    ;;
  mn)
    version_spec=minor
    ;;
  pt)
    version_spec=patch
    ;;
  *)
    if [[ ! "$version_spec" =~ ^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$ ]]; then
      printf 'Version must be major, minor, patch, or a numeric semantic version such as 1.2.3.\n' >&2
      exit 2
    fi
    ;;
esac

if ! command -v docker >/dev/null 2>&1; then
  printf 'Docker was not found.\n' >&2
  exit 1
fi

if [ ! -f "$project_directory/package.json" ]; then
  printf 'package.json was not found in %s.\n' "$project_directory" >&2
  exit 1
fi

node_version=$(read_node_version "$script_directory/.env")

docker run --rm \
  --user "$(id -u):$(id -g)" \
  --env HOME=/tmp \
  --env NPM_CONFIG_CACHE=/tmp/npm-cache \
  --volume "$project_directory:/workspace" \
  --workdir /workspace \
  "node:$node_version" \
  npm version "$version_spec" --no-git-tag-version --ignore-scripts
