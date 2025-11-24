# shellcheck disable=SC2154
declare video_file="${args[video_file]}"
# shellcheck disable=SC2154
declare output_file="${args[--output-file]}"
# shellcheck disable=SC2154
declare title="${args[--title]:-$output_file}"

ffmpeg -i "$video_file" -acodec libmp3lame -metadata TITLE="$title" "$output_file.mp3"
