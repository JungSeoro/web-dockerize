#!/usr/bin/env bash
set -Eeuo pipefail

script_directory=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
project_directory=$(CDPATH= cd -- "$script_directory/.." && pwd -P)

source "$script_directory/project-generator-common.sh"

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ] || { [ "$#" -eq 2 ] && [ "$2" != "--ts" ]; }; then
  printf 'Usage: %s <project-name> [--ts]\n' "$0" >&2
  exit 1
fi

project_name=$1
is_typescript=false
template_arguments=()

if [ "$#" -eq 2 ]; then
  is_typescript=true
  template_arguments=(--template typescript)
fi

generator_validate_project_name "$project_name"
generator_assert_new_project_root "$project_directory" "$script_directory"
node_version=$(generator_read_node_version "$script_directory/.env")

if [ "$is_typescript" = true ]; then
  init_directory="$script_directory/init_react_ts"
else
  init_directory="$script_directory/init_react"
fi

if [ ! -d "$init_directory" ]; then
  generator_fail "React template not found: $init_directory"
fi

generator_create_staging_directory "$project_directory" react

printf 'Creating %s with Node.js %s\n' "$project_name" "$node_version"

docker run --rm \
  --user "$(id -u):$(id -g)" \
  --env HOME=/tmp \
  --env NPM_CONFIG_CACHE=/tmp/npm-cache \
  --volume "$generator_staging_directory:/workspace" \
  --workdir /workspace \
  "node:$node_version" \
  sh -eu -c 'project_name=$1; shift; npx --yes create-react-app@latest project --use-npm "$@" && cd project && npm install web-vitals && npm pkg set "name=$project_name"' _ "$project_name" "${template_arguments[@]}"

generated_project="$generator_staging_directory/project"

if [ ! -f "$generated_project/package.json" ]; then
  generator_fail "React project generation failed"
fi

rm -rf -- "$generated_project/node_modules" "$generated_project/.git"
cp -R "$init_directory"/. "$generated_project"/
rm -f "$generated_project/src/logo.svg" "$generated_project/src/App.css"

for directory in assets components constants hooks state services utils views; do
  mkdir -p "$generated_project/src/$directory"
  touch "$generated_project/src/$directory/.gitkeep"
done

generator_commit_project "$generated_project" "$project_directory"

printf 'Created React project: %s\n' "$project_name"
