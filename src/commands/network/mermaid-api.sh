# shellcheck disable=SC2154
declare port="${args[port]}"

docker run --rm -it --name mermaid-server -p "$port:80" tomwright/mermaid-server:latest
