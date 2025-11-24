close-gcp-auth-tab() {
  sleep 3
  zellij_session_id="$(zellij ls | grep -i current | awk '{print $1}' | sed -r 's/\x1B\[([0-9]{1,3}(;[0-9]{1,2};?)?)?[mGK]//g')"

  wmctrl -a "You are now authenticated with the gcloud CLI"
  xdotool key Ctrl+w
  wmctrl -a "$zellij_session_id"
}

validate-or-refresh-gcp-auth() {
  if ! (gcloud auth print-access-token --quiet > /dev/null 2>&1); then
    yellow_bold "GCP credentials have expired and need to be refreshed"

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
  fi
}

get-gcp-project() {
  echo "${args[--project]:-$GCP_PROJECT}"
}

get-gcp-location() {
  echo "${args[--location]:-$GCP_LOCATION}"
}

