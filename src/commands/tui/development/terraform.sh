# shellcheck disable=SC2154
if [[ "${args[--terraform]}" == 1 ]]; then
  pug
else
  pug --program=terragrunt
fi
