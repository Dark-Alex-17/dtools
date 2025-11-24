# shellcheck disable=SC2154
declare domain="${args[domain]}"
declare port="${args[--port]}"
declare script_file="${args[--script-file]}"

if [[ -z $script_file ]]; then
	script_file="$(mktemp /dev/shm/tmp.XXXXXX)"
	trap 'rm -f $script_file' EXIT

	cat <<-EOF >> "$script_file"
  from mitmproxy import http
  import re

  def request(flow: http.HTTPFlow) -> None:
	  match = re.search(r'$domain', flow.request.host)
	  if match is not None:
	    print(f"Request to {flow.request.host}:")
	    print(flow.request.method, flow.request.url)
	    print("Headers:", flow.request.headers)
	    print("Body:", flow.request.get_text())
    # Requests will be automatically forwarded unless explicitly modified or killed.
	EOF
fi

mitmproxy --listen-port "$port" -s "$script_file"
