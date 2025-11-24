filter_project_and_location_variables_set_with_flags() {
	declare gcp_project="${args[--project]:-$GCP_PROJECT}"
  declare gcp_location="${args[--location]:-$GCP_LOCATION}"

  if [[ -z "$gcp_project" ]]; then
  	red_bold "The GCP project must be set."
  	red_bold "You can specify it using the '--project' flag."
  	red_bold "\nAlternatively, set the 'GCP_PROJECT' environment variable via 'dtools gcp project <PROJECT>' and then try again.\n\n"
  fi

  if [[ -z $gcp_location ]]; then
  	red_bold "The GCP location must be set."
  	red_bold "You can specify it using the '--location' flag."
  	red_bold "\nAlternatively, set the 'GCP_LOCATION' environment variable via 'dtools gcp location <LOCATION>' and then try again."
  fi
}
