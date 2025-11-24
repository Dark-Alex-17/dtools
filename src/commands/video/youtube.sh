# shellcheck disable=SC2154
declare url="${args[url]}"
declare playlist="${args[--playlist]}"

if [[ "${args[--audio-only]}" == 1 ]]; then
  if [[ $playlist == 1 ]]; then
    sudo youtube-dl -f "bestaudio" \
      --continue \
      --no-overwrites \
      --ignore-errors \
      --extract-audio \
      --audio-format mp3 \
      -o "%(title)s.%(ext)s" \
      "$url"
  else
    sudo youtube-dl -x --audio-format mp3 "$url"
  fi
else
  if [[ $playlist == 1 ]]; then
    sudo youtube-dl -cit "$url"
  else
    sudo youtube-dl "$url"
  fi
fi
