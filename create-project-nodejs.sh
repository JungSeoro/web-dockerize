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
generator_create_staging_directory "$project_directory" nodejs

generated_project="$generator_staging_directory/project"
mkdir -p "$generated_project"

printf 'Creating %s with Node.js %s\n' "$project_name" "$node_version"

docker run --rm \
  --user "$(id -u):$(id -g)" \
  --env HOME=/tmp \
  --env NPM_CONFIG_CACHE=/tmp/npm-cache \
  --volume "$generated_project:/workspace" \
  --workdir /workspace \
  "node:$node_version" \
  sh -eu -c 'npm init --yes && npm pkg set "name=$1" && npm install --save express' _ "$project_name"

rm -rf -- "$generated_project/node_modules"
generator_commit_project "$generated_project" "$project_directory"

printf 'Created Node.js project: %s\n' "$project_name"
