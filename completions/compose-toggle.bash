#!/usr/bin/env bash

if [ -n "${ZSH_VERSION:-}" ]; then
  _web_dockerize_compose_toggle_loader_directory=${${(%):-%x}:A:h}
  source "$_web_dockerize_compose_toggle_loader_directory/compose-toggle.zsh"
  unset _web_dockerize_compose_toggle_loader_directory
  return 0
fi

_web_dockerize_compose_toggle_directory=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
_web_dockerize_compose_toggle_script=$(CDPATH= cd -- "$_web_dockerize_compose_toggle_directory/.." && pwd -P)/compose-toggle.sh
_web_dockerize_compose_toggle_project=$(basename "$(dirname "$(dirname "$_web_dockerize_compose_toggle_script")")" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9_-]+/-/g; s/^[-_]+//; s/[-_]+$//')
_web_dockerize_compose_toggle_project=${_web_dockerize_compose_toggle_project:-docker-project}
_web_dockerize_compose_toggle_previous_bash_completion=${_web_dockerize_compose_toggle_previous_bash_completion:-}

_web_dockerize_compose_toggle_bash_spec=$(complete -p bash 2>/dev/null || true)
if [[ "$_web_dockerize_compose_toggle_bash_spec" =~ (^|[[:space:]])-F[[:space:]]+([^[:space:]]+) ]]; then
  _web_dockerize_compose_toggle_bash_function=${BASH_REMATCH[2]}
  if [ "$_web_dockerize_compose_toggle_bash_function" != "_web_dockerize_compose_toggle_bash_dispatch" ]; then
    _web_dockerize_compose_toggle_previous_bash_completion=$_web_dockerize_compose_toggle_bash_function
  fi
fi

unset -f _web_dockerize_compose_toggle_complete 2>/dev/null || true

_web_dockerize_compose_toggle_bash_candidates() {
  local argument_index=$1
  local current=${COMP_WORDS[COMP_CWORD]}

  case "$argument_index" in
    1)
      COMPREPLY=($(compgen -W 'nodejs react vite-react electron --help' -- "$current"))
      ;;
    2)
      COMPREPLY=($(compgen -W "$_web_dockerize_compose_toggle_project" -- "$current"))
      ;;
    *)
      COMPREPLY=()
      ;;
  esac
}

_web_dockerize_compose_toggle_bash_complete() {
  _web_dockerize_compose_toggle_bash_candidates "$COMP_CWORD"
}

_web_dockerize_compose_toggle_bash_dispatch() {
  local index
  local script_index=-1

  for ((index = 1; index < ${#COMP_WORDS[@]}; index += 1)); do
    if [ "${COMP_WORDS[$index]##*/}" = "compose-toggle.sh" ]; then
      script_index=$index
      break
    fi
  done

  if [ "$script_index" -ge 1 ] && [ "$COMP_CWORD" -gt "$script_index" ]; then
    _web_dockerize_compose_toggle_bash_candidates "$((COMP_CWORD - script_index))"
    return 0
  fi

  COMPREPLY=()
  if [ -n "$_web_dockerize_compose_toggle_previous_bash_completion" ] \
    && declare -F "$_web_dockerize_compose_toggle_previous_bash_completion" >/dev/null
  then
    "$_web_dockerize_compose_toggle_previous_bash_completion" || true
  fi
}

for _web_dockerize_compose_toggle_command in \
  compose-toggle.sh \
  ./compose-toggle.sh \
  docker/compose-toggle.sh \
  ./docker/compose-toggle.sh \
  "$_web_dockerize_compose_toggle_script"
do
  complete -F _web_dockerize_compose_toggle_bash_complete "$_web_dockerize_compose_toggle_command"
done

complete -o bashdefault -o default -o filenames -F _web_dockerize_compose_toggle_bash_dispatch bash

unset _web_dockerize_compose_toggle_command
unset _web_dockerize_compose_toggle_directory
unset _web_dockerize_compose_toggle_bash_spec
unset _web_dockerize_compose_toggle_bash_function
