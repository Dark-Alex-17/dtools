# shellcheck disable=SC2154
declare sound="${args[--sound]}"

if [[ -z $sound ]]; then
	ntfy sub "${args[topic]}" 'echo "$raw"'
else
	ntfy sub "${args[topic]}" 'echo "$raw" && mpg321 -q ~/Music/notification-sounds/notify.mp3'
fi