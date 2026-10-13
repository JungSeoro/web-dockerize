#!/usr/bin/env sh

if [ -n "${BASH_VERSION:-}" ]; then
  _web_dockerize_compose_toggle_loader_directory=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
  source "$_web_dockerize_compose_toggle_loader_directory/compose-toggle.bash"
  unset _web_dockerize_compose_toggle_loader_directory
elif [ -n "${ZSH_VERSION:-}" ]; then
  _web_dockerize_compose_toggle_loader_directory=${${(%):-%x}:A:h}
  source "$_web_dockerize_compose_toggle_loader_directory/compose-toggle.zsh"
  unset _web_dockerize_compose_toggle_loader_directory
else
  printf '%s\n' 'compose-toggle completion supports Bash and Zsh only' >&2
  return 1 2>/dev/null || exit 1
fi
