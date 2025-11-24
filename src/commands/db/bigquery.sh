set -e

# shellcheck disable=SC2154
declare gcp_location="${args[--location]}"
# shellcheck disable=SC2154
declare gcp_project="${args[--project]}"

validate-or-refresh-gcp-auth

if [[ -n $gcp_location ]]; then
  harlequin -a bigquery --project "$gcp_project" --location "$gcp_location"
else
  harlequin -a bigquery --project "$gcp_project"
fi
