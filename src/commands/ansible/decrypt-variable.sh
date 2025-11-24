# shellcheck disable=SC2154
ansible localhost -m ansible.builtin.debug -a var="${args[--variable]}" -e "@${args[--file]}" --ask-vault-pass
