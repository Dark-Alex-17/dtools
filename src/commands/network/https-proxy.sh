# shellcheck disable=SC2154
declare https_port="${args[--https-port]}"
# shellcheck disable=SC2154
declare proxy_target_host="${args[--proxy-target-host]}"
# shellcheck disable=SC2154
declare proxy_target_port="${args[--proxy-target-port]}"
# shellcheck disable=SC2154
declare ssl_certificate="${args[--ssl-certificate]}"
declare dtools_cert=/etc/devtools/dtools.pem

if [[ $ssl_certificate = "$dtools_cert" && ! -f $dtools_cert ]]; then
  [[ -d /etc/devtools ]] || sudo mkdir /etc/devtools
  sudo openssl req -new -x509 -days 365 -nodes -out "$dtool_cert" -keyout "$dtools_cert" -subj "/C=US/ST=Colorado/L=Denver/O=ClarkeCloud/OU=IT/CN=localhost"
  sudo chmod 600 "$dtools_cert"
fi

sudo socat openssl-listen:"$https_port",reuseaddr,fork,cert="$ssl_certificate",verify=0 tcp:"$proxy_target_host":"$proxy_target_port"
