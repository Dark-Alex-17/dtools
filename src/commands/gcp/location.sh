# shellcheck disable=SC2154
declare gcp_location="${args[location]}"

if ( grep "GCP_LOCATION" ~/.bashrc ); then
  sed -i "/^GCP_LOCATION=/c\export GCP_LOCATION=$gcp_location" ~/.bashrc
fi

bash -c "export GCP_LOCATION=$gcp_location; exec bash"
