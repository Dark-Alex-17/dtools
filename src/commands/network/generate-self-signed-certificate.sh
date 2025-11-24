# shellcheck disable=SC2154
declare output="${args[--output]}"
# shellcheck disable=SC2154
declare key_output="${args[--key-output]}"
# shellcheck disable=SC2154
declare pfx_output="${args[--pfx-output]}"
# shellcheck disable=SC2154
declare hostname="${args[--hostname]}"

sudo openssl req -x509 -newkey rsa:2048 -days 365 -nodes -out "$output" -keyout "$key_output" -subj "/C=US/ST=Colorado/L=Denver/O=ClarkeCloud/OU=IT/CN=$hostname"
sudo chmod 600 "$output"
sudo chmod 600 "$key_output"

if [[ -n $pfx_output ]]; then
  sudo openssl pkcs12 -export -out "$pfx_output" -inkey "$key_output" -in "$output"
  sudo chmod 600 "$pfx_output"
fi
