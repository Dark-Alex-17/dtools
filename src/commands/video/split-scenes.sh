# shellcheck disable=SC2154
declare video_file="${args[video_file]}"
# shellcheck disable=SC2154
declare content_threshold="${args[--content-threshold]}"
# shellcheck disable=SC2154
declare fade_threshold="${args[--fade-threshold]}"
# shellcheck disable=SC2154
declare keep_duration="${args[--keep-duration]}"

scenedetect --input "$video_file" detect-content --threshold "$content_threshold" detect-threshold --threshold "$fade_threshold" split-video

for file in *."${video_file##*.}"; do
  duration=$(ffprobe -v error -select_streams v:0 -show_entries stream=duration -of csv=p=0 "$file")

  if (( $(echo "$duration < $keep_duration" | bc -l) )); then
    rm "$file"
  fi
done
