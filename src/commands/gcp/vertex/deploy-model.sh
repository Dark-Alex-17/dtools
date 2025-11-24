# shellcheck disable=SC2155
declare gcp_location="$(get-gcp-location)"
declare gcp_project="$(get-gcp-project)"
# shellcheck disable=SC2154
declare container_image="${args[--container-image]}"
declare container_image_uri="${gcp_location}-docker.pkg.dev/${gcp_project}/${container_image}"
declare container_port="${args[--container-port]}"
declare health_route="${args[--health-route]}"
declare predict_route="${args[--predict-route]}"
declare display_name="${args[--display-name]}"
declare artifact_uri="gs://${gcp_project}/${args[--model-gcs-uri]}"
declare endpoint_name="${args[--endpoint-name]}"
declare machine_type="${args[--machine-type]}"
declare accelerator="${args[--accelerator]}"

validate-or-refresh-gcp-auth

get-endpoint-id() {
  gcloud ai endpoints list \
    --region "$gcp_location" \
    2> /dev/null |\
    grep -i "$endpoint_name" |\
    awk '{print $1;}'
}

endpoint-has-deployed-model() {
  [[ $(gcloud ai endpoints describe "$endpoint_id" \
    --region "$gcp_location" \
    --format json \
    2> /dev/null |\
    jq -r '.deployedModels | length > 0') == "true" ]]
}

yellow "Uploading model to Vertex model registry..."

if [[ -z "$artifact_uri" ]]; then
  gcloud ai models upload \
    --project "$gcp_project" \
    --region "$gcp_location" \
    --display-name "$display_name" \
    --container-image-uri "$container_image_uri" \
    --container-ports "$container_port" \
    --container-health-route "$health_route" \
    --container-predict-route "$predict_route"
else
  gcloud ai models upload \
    --project "$gcp_project" \
    --region "$gcp_location" \
    --display-name "$display_name" \
    --container-image-uri "$container_image_uri" \
    --container-ports "$container_port" \
    --container-health-route "$health_route" \
    --container-predict-route "$predict_route" \
    --artifact-uri "$artifact_uri"
fi

green "Successfully uploaded model to Vertex model registry"

new_model_id="$(gcloud ai models list --sort-by ~versionCreateTime --format 'value(name)' --region "$gcp_location" 2> /dev/null | head -1)"

yellow "New model id: '$new_model_id'"

if [[ -z $(get-endpoint-id) ]]; then
  red_bold "Endpoint with name '$endpoint_name' does not exist."
  yellow "Creating new endpoint..."
  dataset_name="$(tr '-' '_' <<< "$endpoint_name")"
  
  gcloud ai endpoints create \
    --display-name "$endpoint_name" \
    --region "$gcp_location" \
    --request-response-logging-rate 1 \
    --request-response-logging-table "bq://${gcp_project}.${dataset_name}.serving_predict"

  green "Successfully created new endpoint with name: '$endpoint_name'"
fi

endpoint_id="$(get-endpoint-id)"
yellow "Endpoint '$endpoint_name' has id: '$endpoint_id'"

if endpoint-has-deployed-model; then
  old_model_id="$(gcloud ai endpoints describe "$endpoint_id" \
    --region "$gcp_location" \
    --format json \
    2> /dev/null |\
    jq -r '.deployedModels[0].model' |\
    xargs basename)"
  deployed_model_id="$(gcloud ai endpoints describe "$endpoint_id" \
    --region "$gcp_location" \
    --format json \
    2> /dev/null |\
    jq -r '.deployedModels[0].id')"
  red "Undeploying existing model: '$old_model_id' with deployed id: '$deployed_model_id'..."
  gcloud ai endpoints undeploy-model "$endpoint_id" \
    --region "$gcp_location" \
    --deployed-model-id "$deployed_model_id"

  green "Successfully undeployed existing model: '$old_model_id'"
fi

yellow "Deploying new model to endpoint '$endpoint_id'..."
if [[ -z "$accelerator" ]]; then
  gcloud ai endpoints deploy-model "$endpoint_id" \
    --region "$gcp_location" \
    --model "$new_model_id" \
    --display-name "$display_name" \
    --machine-type "$machine_type"
else
  gcloud ai endpoints deploy-model "$endpoint_id" \
    --region "$gcp_location" \
    --model "$new_model_id" \
    --display-name "$display_name" \
    --machine-type "$machine_type" \
    --accelerator "type=${accelerator},count=1"
fi
  
green "Successfully deployed model '$new_model_id' to endpoint '$endpoint_id'"
