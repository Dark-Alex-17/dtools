# shellcheck disable=SC2154
declare project_name="${args[project_name]}"

validate-or-refresh-gcp-auth

gcloud projects describe "$project_name" --format="value(projectNumber)"
