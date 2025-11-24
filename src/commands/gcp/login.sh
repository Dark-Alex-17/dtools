# shellcheck disable=SC2155
declare gcp_project="$(get-gcp-project)"
declare gcp_location="$(get-gcp-location)"

yellow "Refreshing user credentials..."
spinny-start
if ! (gcloud auth login > /dev/null 2>&1); then
	spinny-stop
  red_bold "Unable to log into GCP."
else
	spinny-stop
	close-gcp-auth-tab
	green "User credentials refreshed"
fi

yellow "Refreshing application default credentials..."
spinny-start
if ! (gcloud auth application-default login > /dev/null 2>&1); then
	spinny-stop
  red_bold "Unable to configure GCP credentials for applications."
else
  spinny-stop
  close-gcp-auth-tab
  green "GCP application default credentials refreshed"
fi

if ( grep "GCP_PROJECT" ~/.bashrc > /dev/null 2>&1 ); then
  sed -i "/^GCP_PROJECT=/c\export GCP_PROJECT=$gcp_project" ~/.bashrc
fi

if ( grep "GCP_LOCATION" ~/.bashrc > /dev/null 2>&1 ); then
	sed -i "/^GCP_LOCATION=/c\export GCP_LOCATION=$gcp_location" ~/.bashrc
fi

bash -c "export GCP_PROJECT=$gcp_project; export GCP_LOCATION=$gcp_location; exec bash"
