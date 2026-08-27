#!/usr/bin/env bash
set -Eeuo pipefail

script_directory=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
project_directory=$(CDPATH= cd -- "$script_directory/.." && pwd -P)

source "$script_directory/project-generator-common.sh"

if [ "$#" -ne 1 ]; then
  printf 'Usage: %s <project-name>\n' "$0" >&2
  exit 1
fi

project_name=$1
generator_validate_project_name "$project_name"
generator_assert_new_project_root "$project_directory" "$script_directory"
node_version=$(generator_read_node_version "$script_directory/.env")
generator_create_staging_directory "$project_directory" vite-react

printf 'Creating %s with Node.js %s\n' "$project_name" "$node_version"

docker run --rm \
  --user "$(id -u):$(id -g)" \
  --env HOME=/tmp \
  --env NPM_CONFIG_CACHE=/tmp/npm-cache \
  --volume "$generator_staging_directory:/workspace" \
  --workdir /workspace \
  "node:$node_version" \
  sh -eu -c 'project_name=$1; npm create vite@latest project -- --template react-ts && cd project && npm pkg set "name=$project_name"' _ "$project_name"

generated_project="$generator_staging_directory/project"

if [ ! -f "$generated_project/package.json" ]; then
  generator_fail "Vite React project generation failed"
fi

for directory in components constants hooks store services stories utils views; do
  mkdir -p "$generated_project/src/$directory"
  touch "$generated_project/src/$directory/.gitkeep"
done

generator_commit_project "$generated_project" "$project_directory"

printf 'Created Vite React project: %s\n' "$project_name"
