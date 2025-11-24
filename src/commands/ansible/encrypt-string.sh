encrypt-string() {
  ansible-vault encrypt_string --ask-vault-pass --encrypt-vault-id default
}

# shellcheck disable=SC2154
if [[ "${args[--copy-output-to-clipboard]}" == 1 ]]; then
  yellow "Press 'Ctrl-d' twice to end secret input"
  encrypt-string | xclip -sel clip
else
  encrypt-string
fi

