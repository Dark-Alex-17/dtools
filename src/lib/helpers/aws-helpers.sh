close-aws-auth-tab() {
  sleep 2
  zellij_session_id="$(zellij ls | grep -i current | awk '{print $1}' | sed -r 's/\x1B\[([0-9]{1,3}(;[0-9]{1,2};?)?)?[mGK]//g')"

  wmctrl -a "AWS access portal"
  xdotool key Ctrl+w
  wmctrl -a "$zellij_session_id"
}

validate-or-refresh-aws-auth() {
	# shellcheck disable=SC2155
	declare aws_profile="$(get-aws-profile)"
	# shellcheck disable=SC2155
	declare aws_region="$(get-aws-region)"

  if ! (aws sts get-caller-identity --profile "$aws_profile" --region "$aws_region" > /dev/null 2>&1); then
    yellow_bold "Detected SSO profile: credentials have expired and need to be refreshed"
    yellow "Refreshing credentials for ${aws_profile}..."

    spinny-start
    if ! (aws sso login --profile "$aws_profile" --region "$aws_region" > /dev/null 2>&1); then
    	spinny-stop
      red_bold "Unable to log into AWS."
    else
	    spinny-stop
	    close-aws-auth-tab
      green "Credentials refreshed for ${aws_profile}"
    fi
  fi
}

get-aws-profile() {
	echo "${args[--profile]:-$AWS_PROFILE}"
}

get-aws-region() {
	echo "${args[--region]:-$AWS_REGION}"
}
