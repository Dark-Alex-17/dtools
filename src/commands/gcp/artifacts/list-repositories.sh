# shellcheck disable=SC2155
declare gcp_location="$(get-gcp-location)"
declare gcp_project="$(get-gcp-project)"

validate-or-refresh-gcp-auth

gcloud artifacts repositories list --project "$gcp_project" --location "$gcp_location" --format json 2> /dev/null | jq -r '.[] | .name' | awk -F/ '{printf("%-20s %-15s\n", $6, $4)}'
