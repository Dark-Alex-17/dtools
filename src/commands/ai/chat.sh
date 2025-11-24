# shellcheck disable=SC2154
declare repo="${args[--hf-repo]}"
declare file="${args[--hf-file]}"
llama-cli --hf-repo "$repo" --hf-file "$file" --conversation
