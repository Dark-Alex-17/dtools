trap 'spinny-stop' SIGINT
declare -a SPINNY_FRAMES=(▸ ▹▸ ▹▹▸ ▹▹▹▸ ▹▹▹▹▸ " ▹▹▹▹" "  ▹▹▹" "   ▹▹" "    ▹" "      " )
declare SPINNY_DELAY=0.1
declare __spinny__spinner_pid
declare -a __spinny__frames=()


spinny-start() {
  tput civis
  spinny_spinner &
  __spinny__spinner_pid=$!
}

spinny-stop() {
  [[ -z "$__spinny__spinner_pid" ]] && return 0

  kill -9 "$__spinny__spinner_pid" 
  # Use conditional to avoid exiting the program immediatly
  wait "$__spinny__spinner_pid" 2>/dev/null || true
  tput cnorm
  unset __spinny__spinner_pid
  unset __spinny__frames
}

spinny_spinner() {
  local delay="${SPINNY_DELAY:-0.3}"
  spinny_load_frames
  spinny_pad_frames
  while true; do
    for frame in "${__spinny__frames[@]}"; do
      # After rendering each frame the cursor is reset to 
      # the previous position so that the next frame can 
      # overwrite it
      tput sc
      printf "%b" "$frame"
      tput rc
      sleep "$delay"
    done
  done
}

spinny_pad_frames() {
  # Frames with different lengths need to be padded
  # for a smooth animation. We calculate the maximum
  # size of all frames and pad all smaller ones with
  # white space.
  local max_length
  max_length="$(spinny_max_framelength)"
  local array_length="${#__spinny__frames[@]}"
  for (( i=0; i < array_length; i++ )) do
    local frame="${__spinny__frames[$i]}"
    local frame_length="${#frame}"
    diff="$(( max_length - frame_length + 1 ))"
    # This adds the required number of white spaces
    # to the frame
    # TODO: Replace with pure bash if possible
    filler="$(seq -s ' ' "$diff" | tr -d '[:digit:]')"
    __spinny__frames[$i]="$frame$filler"
  done
}

spinny_max_framelength() {
  local max="${#__spinny__frames[0]}"
  for frame in "${__spinny__frames[@]}"; do
    declare len="${#frame}"
    (( len > max )) && max=$len
  done
  echo "$max"
}

spinny_load_frames() {
  # Load custom frames if any or fall back on the default animation
  if [[ -z $SPINNY_FRAMES ]]; then 
    __spinny__frames=(- "\\" "|" /)
  else
    __spinny__frames=("${SPINNY_FRAMES[@]}")
  fi
}
