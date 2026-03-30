# shellcheck disable=SC2154
declare host="${args[host]}"
declare port="${args[--port]}"
declare view_only="${args[--view-only]}"
declare output_dir="${args[--output-dir]}"
declare filename="${args[--filename]}"

if [[ "$view_only" == 1 ]]; then
  openssl s_client -showcerts -connect "${host}:${port}"
else
  openssl s_client -showcerts -connect "${host}:${port}" </dev/null | sed -n -e '/-.BEGIN/,/-.END/ p' | sudo tee "${output_dir}/${filename:-${host%%.*}}.pem"
fi

if dpkg -s ca-certificates > /dev/null 2>&1; then
  sudo update-ca-certificates
fi
