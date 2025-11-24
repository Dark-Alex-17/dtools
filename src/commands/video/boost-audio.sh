# shellcheck disable=SC2154
declare video_file="${args[video_file]}"
# shellcheck disable=SC2154
declare multiplier="${args[--multiplier]}"
# shellcheck disable=SC2154
declare output_file="${args[--output-file]}"

ffmpeg -i "$video_file" -vcodec copy -af "volume=2.0" "$output_file"
