# shellcheck disable=SC2154
datetime="${args[date]}"

if [[ $datetime == "-" ]]; then
  date -u +"%Y-%m-%dT%H:%M:%S.%3NZ" -f -
else
  date -u +"%Y-%m-%dT%H:%M:%S.%3NZ" -d "$datetime"
fi
