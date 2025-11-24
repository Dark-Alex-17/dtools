filter_profile_and_region_variables_set_with_flags() {
	declare aws_profile="${args[--profile]:-$AWS_PROFILE}"
  declare aws_region="${args[--region]:-$AWS_REGION}"

  if [[ -z "$aws_profile" ]]; then
  	red_bold "The AWS profile must be set."
  	red_bold "You can specify it using the '--profile' flag."
  	red_bold "\nAlternatively, set the 'AWS_PROFILE' environment variable via 'dtools aws profile <PROFILE>' and then try again.\n\n"
  fi

  if [[ -z $aws_region ]]; then
  	red_bold "The AWS region must be set."
  	red_bold "You can specify it using the '--region' flag."
  	red_bold "\nAlternatively, set the 'AWS_REGION' environment variable via 'dtools aws region <REGION>' and then try again."
  fi
}

filter_profile_and_region_variables_set_generic() {
  if [[ -z "$AWS_PROFILE" ]]; then
  	red_bold "The AWS profile must be set."
  	red_bold "You can set the 'AWS_PROFILE' environment variable via 'dtools aws profile <PROFILE>' and then try again.\n\n"
  fi

  if [[ -z $AWS_REGION ]]; then
  	red_bold "The AWS region must be set."
  	red_bold "You can set the 'AWS_REGION' environment variable via 'dtools aws region <REGION>' and then try again."
  fi
}
