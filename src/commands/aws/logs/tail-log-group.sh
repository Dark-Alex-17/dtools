# shellcheck disable=SC2155
declare aws_profile="$(get-aws-profile)"
declare aws_region="$(get-aws-region)"
declare temp_log_file="$(mktemp)"
set -e
# shellcheck disable=SC2064
# 'kill -- -$$' also kills the entire process group whose ID is $$
# So this means that this will also kill all subprocesses started by
# this script
trap "rm -f $temp_log_file && kill -- -$$" EXIT

validate-or-refresh-aws-auth

# shellcheck disable=SC2154
unbuffer aws --profile "$aws_profile" --region "$aws_region" logs tail "${args[log-group]}" --follow --format short --no-cli-auto-prompt --since "${args[--since]}" >> "$temp_log_file" &

if [[ ${args[--verbose]} == 1 ]]; then
  if [[ ${args[--stdout]} == 1 ]]; then
    tail -f "$temp_log_file"
  else
    lnav "$temp_log_file"
  fi
elif [[ ${args[--stdout]} == 1 ]]; then
  tail -f "$temp_log_file" |\
  awk '{$1=""; gsub(/^[ \t]+/, "", $0); if ($0 !~ /^END|^REPORT|^START/) { print }}'
else
  tail -f "$temp_log_file" |\
  awk '{$1=""; gsub(/^[ \t]+/, "", $0); if ($0 !~ /^END|^REPORT|^START/) { print }}' |\
  lnav
fi

