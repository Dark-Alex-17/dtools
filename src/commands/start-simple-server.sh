# shellcheck disable=SC2154
declare port="${args[--port]}"

yellow "Starting a server on port '$port'..."
yellow_bold "Stop the server with 'Ctrl+c'"

while :; do
  printf 'HTTP/1.1 200 OK\r\n\r\n' | nc -Nl "$port"
done
