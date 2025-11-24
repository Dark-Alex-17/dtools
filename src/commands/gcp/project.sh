# shellcheck disable=SC2154
declare gcp_project="${args[project]}"

if ( grep "GCP_PROJECT" ~/.bashrc > /dev/null 2>&1 ); then
  sed -i "/^GCP_PROJECT=/c\export GCP_PROJECT=$gcp_project" ~/.bashrc
fi

gcloud config set project "$gcp_project"
bash -c "export GCP_PROJECT=$gcp_project; exec bash"
