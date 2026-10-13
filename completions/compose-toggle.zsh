#!/usr/bin/env zsh

if [ -n "${BASH_VERSION:-}" ]; then
  _web_dockerize_compose_toggle_loader_directory=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
  source "$_web_dockerize_compose_toggle_loader_directory/compose-toggle.bash"
  unset _web_dockerize_compose_toggle_loader_directory
  return 0
fi

autoload -Uz compinit
if (( ! $+functions[compdef] )); then
  compinit
fi

_web_dockerize_compose_toggle_directory=${${(%):-%x}:A:h}
_web_dockerize_compose_toggle_script=${_web_dockerize_compose_toggle_directory:h}/compose-toggle.sh
_web_dockerize_compose_toggle_project=${_web_dockerize_compose_toggle_script:h:h:t:l}
_web_dockerize_compose_toggle_project=${_web_dockerize_compose_toggle_project//[^a-z0-9_-]/-}
_web_dockerize_compose_toggle_project=${_web_dockerize_compose_toggle_project:-docker-project}

unfunction _web_dockerize_compose_toggle_complete 2>/dev/null

_web_dockerize_compose_toggle_zsh_complete() {
  _arguments \
    '1:environment:(nodejs react vite-react electron --help)' \
    "2:project name:($_web_dockerize_compose_toggle_project)"
}

compdef _web_dockerize_compose_toggle_zsh_complete \
  compose-toggle.sh \
  ./compose-toggle.sh \
  docker/compose-toggle.sh \
  ./docker/compose-toggle.sh \
  "$_web_dockerize_compose_toggle_script"

unset _web_dockerize_compose_toggle_directory
