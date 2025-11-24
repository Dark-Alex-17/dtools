set -eo pipefail
# shellcheck disable=SC2154
declare pre_processing_pipe="${args[--pre-processing]}"
declare target_command="${args[command]}"
declare additional_xargs_arguments="${args[--additional-xargs-arguments]}"

if [[ -z $pre_processing_pipe ]]; then
  # shellcheck disable=SC2154
  eval "fzf --print0 --preview 'batcat {} --style=numbers --color=always' --height=75% --multi --bind '?:toggle-preview,ctrl-a:select-all' --preview-window hidden | xargs -0 $additional_xargs_arguments -o $target_command"
else
  # shellcheck disable=SC2154
  eval "fzf --print0 --preview 'batcat {} --style=numbers --color=always' --height=75% --multi --bind '?:toggle-preview,ctrl-a:select-all' --preview-window hidden | $pre_processing_pipe | xargs -0 $additional_xargs_arguments -o $target_command"
fi
