# shellcheck disable=SC2154
epoch="${args[epoch]}"

convert-epoch() {
  awk '{print substr($0, 0, length($0)-3) "." substr($0, length($0)-2);}' <<< "$1"
}

if [[ $epoch == "-" ]]; then
  read epoch_stdin
  date -u -d "@$(convert-epoch "$epoch_stdin")" +"%Y-%m-%d %H:%M:%S"
else
  date -u -d "@$(convert-epoch "$epoch")" +"%Y-%m-%d %H:%M:%S"
fi
