# shellcheck disable=SC2154
declare tcp_host="${args[--tcp-host]}"
# shellcheck disable=SC2154
declare tcp_port="${args[--tcp-port]}"
# shellcheck disable=SC2154
declare proxy_target_host="${args[--proxy-target-host]}"
# shellcheck disable=SC2154
declare proxy_target_port="${args[--proxy-target-port]}"

sudo simpleproxy -L "${tcp_host}:${tcp_port}" -R "${proxy_target_host}:${proxy_target_port}" -v
