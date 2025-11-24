# shellcheck disable=SC2154
declare output_file="${args[output_file]}"
declare cast_file="${output_file}.cast"
declare gif_file="${output_file}.gif"
declare speed="${args[--speed]}"
declare no_conversion="${args[--no-conversion]}"

yellow "Starting recording... Press Ctrl-D to finish the recording."
asciinema rec -c "bash --norc --noprofile -c 'PS1=\"\$ \" bash --norc --noprofile'" "$cast_file"

if [[ ! -f $cast_file ]]; then
  red_bold "Error: Recording failed or was cancelled"
  exit 1
fi

sed -i '$d' "$cast_file"

if [[ $no_conversion != "1" ]]; then
  yellow "Converting to GIF..."
  agg --speed "$speed" "$cast_file" "$gif_file"

  yellow "Cleaning up ${cast_file}..."
  rm "$cast_file"

  green "Successfully created $gif_file"
else
  green "Successfully created $cast_file"
fi
