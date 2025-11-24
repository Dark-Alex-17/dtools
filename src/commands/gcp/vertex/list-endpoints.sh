# shellcheck disable=SC2155
declare gcp_location="$(get-gcp-location)"
declare gcp_project="$(get-gcp-project)"

validate-or-refresh-gcp-auth

# shellcheck disable=SC2154
if [[ ${args[--detailed]} == 1 ]]; then
  gcloud ai endpoints list --project "$gcp_project" --region "$gcp_location" --format json
else
  gcloud ai endpoints list --project "$gcp_project" --region "$gcp_location" --format=json | jq -r '.[].displayName'
fi
