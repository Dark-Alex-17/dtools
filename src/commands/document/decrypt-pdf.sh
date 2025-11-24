# shellcheck disable=SC2154
declare input_file="${args[input-file]}"
# shellcheck disable=SC2154
declare output_file="${args[--output-file]}"

qpdf --decrypt "$input_file" "$output_file"
