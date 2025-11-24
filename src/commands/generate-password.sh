# shellcheck disable=SC2154
if [[ "${args[--copy-to-clipboard]}" == 1 ]]; then
  openssl rand -base64 32 | tr -d '\n' | xclip -sel clip
else
  openssl rand -base64 32
fi
