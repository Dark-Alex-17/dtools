# shellcheck disable=SC2155
declare gcp_location="$(get-gcp-location)"
declare gcp_project="$(get-gcp-project)"
# shellcheck disable=SC2154
declare endpoint_name="${args[endpoint_name]}"

validate-or-refresh-gcp-auth

endpoint_id="$(gcloud ai endpoints list --region "$gcp_location" --format json 2>/dev/null | jq --arg endpoint_name "$endpoint_name" -r '.[] | select(.displayName == $endpoint_name) | .deployedModels[0].id')"

if [[ -z $endpoint_id ]]; then
  red "Invalid endpoint name specified: '$endpoint_name'"
  red "Unable to determine endpoint ID"
  exit 1
fi

gcloud beta logging tail "resource.type=cloud_aiplatform_endpoint AND resource.labels.endpoint_id=$endpoint_id" --project "$gcp_project"
