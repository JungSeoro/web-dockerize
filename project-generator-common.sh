#!/usr/bin/env bash

generator_staging_directory=
generator_moved_paths=()

generator_fail() {
  printf '%s\n' "$*" >&2
  exit 1
}

generator_validate_project_name() {
  local project_name=$1

  if [ "${#project_name}" -gt 214 ] || [[ ! "$project_name" =~ ^[a-z0-9][a-z0-9._-]*$ ]]; then
    generator_fail "Project name must start with a lowercase letter or number and contain only lowercase letters, numbers, dots, hyphens, or underscores"
  fi
}

generator_read_node_version() {
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
    generator_fail "Invalid NODE_VERSION: $node_version"
  fi

  printf '%s\n' "$node_version"
}

generator_assert_new_project_root() {
  local project_directory=$1
  local script_directory=$2
  local entry
  local entries

  shopt -s dotglob nullglob
  entries=("$project_directory"/*)
  shopt -u dotglob nullglob

  for entry in "${entries[@]}"; do
    case "$entry" in
      "$script_directory"|"$project_directory/.git"|"$project_directory/.gitmodules")
        ;;
      *)
        generator_fail "Project root must be empty except for $(basename "$script_directory"), .git, and .gitmodules: $entry"
        ;;
    esac
  done
}

generator_cleanup() {
  local exit_code=$?
  local path

  trap - EXIT

  if [ "$exit_code" -ne 0 ]; then
    for path in "${generator_moved_paths[@]}"; do
      rm -rf -- "$path" || true
    done
  fi

  if [ -n "$generator_staging_directory" ] && [ -d "$generator_staging_directory" ]; then
    rm -rf -- "$generator_staging_directory" || true
  fi

  exit "$exit_code"
}

generator_create_staging_directory() {
  local project_directory=$1
  local environment_name=$2

  generator_staging_directory=$(mktemp -d "$project_directory/.docker-init-$environment_name.XXXXXX")
  generator_moved_paths=()
  trap generator_cleanup EXIT
  trap 'exit 129' HUP
  trap 'exit 130' INT
  trap 'exit 143' TERM
}

generator_commit_project() {
  local source_directory=$1
  local project_directory=$2
  local destination
  local entry
  local entries

  case "$source_directory" in
    "$generator_staging_directory"/*)
      ;;
    *)
      generator_fail "Invalid staging source: $source_directory"
      ;;
  esac

  shopt -s dotglob nullglob
  entries=("$source_directory"/*)
  shopt -u dotglob nullglob

  if [ "${#entries[@]}" -eq 0 ]; then
    generator_fail "Generated project is empty"
  fi

  for entry in "${entries[@]}"; do
    destination="$project_directory/$(basename "$entry")"
    if [ -e "$destination" ] || [ -L "$destination" ]; then
      generator_fail "Project file already exists: $destination"
    fi
  done

  for entry in "${entries[@]}"; do
    destination="$project_directory/$(basename "$entry")"
    mv -- "$entry" "$destination"
    generator_moved_paths+=("$destination")
  done

  generator_moved_paths=()
}
