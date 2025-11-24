# shellcheck disable=SC2154
datetime="${args[timestamp]}"

if [[ $datetime == "-" ]]; then
  date +"%s%3N" -f -
else
  date -d "$datetime" +"%s%3N"
fi
