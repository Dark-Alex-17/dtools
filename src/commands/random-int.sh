# shellcheck disable=SC2154
declare min="${args[--min]}"
declare max="${args[--max]}"

echo "$((SRANDOM % (max - min + 1) + min))"
