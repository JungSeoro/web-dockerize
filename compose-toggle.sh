#!/usr/bin/env bash
set -euo pipefail

script_directory=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
project_directory=$(CDPATH= cd -- "$script_directory/.." && pwd)
environment=${1:-}

print_usage() {
  cat <<EOF
Usage: $0 <environment> [project-name]

Environments:
  nodejs      Node.js (alias: node)
  react       Create React App
  vite-react  Vite React TypeScript (alias: vite)
  electron    Electron

Examples:
  $0 nodejs
  $0 electron my-app

Completion:
  source "$script_directory/completions/compose-toggle.sh"
EOF
}

if [ -z "$environment" ]; then
  print_usage
  exit 0
fi

case "$environment" in
  -h | --help | help)
    print_usage
    exit 0
    ;;
esac

case "$environment" in
  node | nodejs)
    environment=nodejs
    compose_file="$script_directory/docker-compose-nodejs.yml"
    ;;
  react)
    compose_file="$script_directory/docker-compose-react.yml"
    ;;
  vite | vite-react)
    environment=vite-react
    compose_file="$script_directory/docker-compose-vite-react.yml"
    ;;
  electron)
    compose_file="$script_directory/docker-compose-electron.yml"
    ;;
  *)
    echo "Unknown environment: $environment" >&2
    print_usage >&2
    exit 1
    ;;
esac

default_project_name=$(basename "$project_directory" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9_-]+/-/g; s/^[-_]+//; s/[-_]+$//')
default_project_name=${default_project_name:-docker-project}
project_name=${2:-$default_project_name}

if [[ ! "$project_name" =~ ^[a-z0-9][a-z0-9_-]*$ ]]; then
  echo "project-name must start with a lowercase letter or number and contain only lowercase letters, numbers, hyphens, or underscores" >&2
  exit 1
fi

compose_command=(
  docker compose
  --env-file "$script_directory/.env"
  --project-name "$project_name"
  --file "$compose_file"
)

running_services=$("${compose_command[@]}" ps --status running --services)

if [ -n "$running_services" ]; then
  echo "Stopping $environment ($project_name)"
  "${compose_command[@]}" down
else
  echo "Starting $environment ($project_name)"
  "${compose_command[@]}" up
fi
