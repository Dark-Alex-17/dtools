# shellcheck disable=SC2155
declare gcp_project="$(get-gcp-project)"
declare gcp_location="$(get-gcp-location)"
# shellcheck disable=SC2154
declare repository_name="${args[repository_name]}"

validate-or-refresh-gcp-auth

if [[ "${args[--detailed]}" == 1 ]]; then
  gcloud artifacts docker images list "$gcp_location-docker.pkg.dev/$gcp_project/$repository_name" --format json
else
  gcloud artifacts docker images list "$gcp_location-docker.pkg.dev/$gcp_project/$repository_name" 2>&1 | awk 'NR > 3 {print $1}' | xargs -I{} basename {}
fi
