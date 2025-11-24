# shellcheck disable=SC2154
declare video_file="${args[video_file]}"

ffprobe -v error -select_streams v:0 -show_entries stream=duration -of csv=p=0 "$video_file"
