# shellcheck disable=SC2154
declare output_file="${args[output-file]}"
# shellcheck disable=SC2154
eval "input_files=(${args[--input-file]:-})"

pdftk ${input_files[*]} output "$output_file"
