# shellcheck disable=SC2155
declare gcp_location="$(get-gcp-location)"
# shellcheck disable=SC2154
declare file="${args[--file]}"
declare endpoint_name="${args[--endpoint-name]}"

validate-or-refresh-gcp-auth

endpoint_id="$(gcloud ai endpoints list --region "$gcp_location" --format json 2>/dev/null | jq --arg endpoint_name "$endpoint_name" -r '.[] | select(.displayName == $endpoint_name) | .deployedModels[0].id')"

if [[ -z $endpoint_id ]]; then
  red "Invalid endpoint name specified: '$endpoint_name'"
  red "Unable to determine endpoint ID"
  exit 1
fi

model_uri="$(gcloud ai endpoints list --region "$gcp_location" --format json 2>/dev/null | jq --arg endpoint_name "$endpoint_name" -r '.[] | select(.displayName == $endpoint_name) | .name')"

if [[ -z $model_uri ]]; then
  red "Unable to determine model URI from given endpoint name: '$endpoint_name' and region: '$gcp_location'"
  exit 1
fi

bearer="$(gcloud auth print-access-token)"

curl -X POST \
  -H "Authorization: Bearer $bearer" \
  -H "Content-Type: application/json; charset=utf-8" \
  -d @"${file}" \
  "https://${gcp_location}-aiplatform.googleapis.com/v1/$model_uri:predict"
