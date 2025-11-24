# shellcheck disable=SC2154
declare file="${args[file]}"
# shellcheck disable=SC2154
declare source_format="${args[--source-format]}"
# shellcheck disable=SC2154
declare target_format="${args[--target-format]}"
# shellcheck disable=SC2154
declare output_file="${args[--output-file]:-${PWD}/${file%%."${source_format}"}.${target_format}}"

pandoc -f "$source_format" -t "$target_format" -o "$output_file" "$file" -V geometry:margin=1in
