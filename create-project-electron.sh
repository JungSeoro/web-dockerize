#!/usr/bin/env bash
set -euo pipefail

script_directory=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
project_directory=$(CDPATH= cd -- "$script_directory/.." && pwd)
template_directory="$script_directory/init_electron"
project_name=${1:-}
product_name=${2:-$project_name}

if [ -z "$project_name" ]; then
  echo "Usage: $0 <package-name> [product-name]" >&2
  exit 1
fi

if [[ ! "$project_name" =~ ^[a-z0-9][a-z0-9._-]*$ ]]; then
  echo "package-name must contain only lowercase letters, numbers, dots, hyphens, or underscores" >&2
  exit 1
fi

if [ ! -d "$template_directory" ]; then
  echo "init_electron not found: $template_directory" >&2
  exit 1
fi

for target in package.json forge.config.js src .gitignore; do
  if [ -e "$project_directory/$target" ]; then
    echo "Project file already exists: $project_directory/$target" >&2
    exit 1
  fi
done

node_version=${NODE_VERSION:-}
if [ -z "$node_version" ] && [ -f "$script_directory/.env" ]; then
  node_version=$(sed -n 's/^NODE_VERSION=//p' "$script_directory/.env" | tail -n 1)
fi
node_version=${node_version:-22}

cp -R "$template_directory"/. "$project_directory"/

docker run --rm \
  --user "$(id -u):$(id -g)" \
  --env HOME=/tmp \
  --env NPM_CONFIG_CACHE=/tmp/npm-cache \
  --volume "$project_directory:/workspace" \
  --workdir /workspace \
  "node:$node_version" \
  sh -c 'npm pkg set "name=$1" "productName=$2" && npm install' _ "$project_name" "$product_name"

mkdir -p "$project_directory/downloads"

echo "Created Electron project: $product_name"
