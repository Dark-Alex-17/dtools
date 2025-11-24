# shellcheck disable=SC2154
declare tcp_port="${args[--tcp-port]}"
# shellcheck disable=SC2154
declare proxy_target_host="${args[--proxy-target-host]}"
# shellcheck disable=SC2154
declare proxy_target_protocol="${args[--proxy-target-protocol]}"
# shellcheck disable=SC2155
declare temp_config_file="$(mktemp)"

# shellcheck disable=SC2064
trap "rm -f $temp_config_file" EXIT

cat <<-EOF >> "$temp_config_file"
	# nginx.conf
	worker_processes 1;

	events {}

	http {
	    server {
	        listen $tcp_port;

	        location / {
	            proxy_pass $proxy_target_protocol://$proxy_target_host;

	            # Forward the Host header so the remote API recognizes the request
	            proxy_set_header Host $proxy_target_host;

	            # Optional: standard reverse proxy headers
	            proxy_set_header X-Real-IP \$remote_addr;
	            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;

	            # Enable SNI (important for HTTPS targets)
	            proxy_ssl_server_name on;
	        }
	    }
	}
	EOF


yellow "Press 'Ctrl-c' to stop proxying"
sudo nginx -p . -g 'daemon off;' -c "$temp_config_file"
