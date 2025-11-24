# shellcheck disable=SC2154
declare search_string="${args[search-string]}"

git rev-list --all | (
    while read -r revision; do
      git grep -F "$search_string" "$revision"
    done
  )
