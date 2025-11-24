validate_aws_profile_exists() {
  (grep -q "^\[profile $1\]\$" "$HOME"/.aws/config) || red_bold "The AWS profile '$1' does not exist in ~/.aws/config"
}

validate_relative_since_time_format() {
  if [[ ! $1 =~ ^[[:digit:]]+[smhdw]$ ]]; then
    red_bold "The relative time must be a valid integer, followed by only one of the following: 's', 'm', 'h', 'd', 'w'"
  fi
}

validate_aws_ssm_port_forwarding_number() {
  if [[ ! $1 =~ ^([1-9]|[1-9][0-9]{1,3}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5])$ ]]; then
    red_bold "The port number provided is invalid: $1"
  fi
}

validate_aws_ssm_port_forwarding_host() {
  if [[ ! $1 =~ ^[^,\$^\&\(\)\!\;\'\"\<\>\`{}\[\]\|#=]{3,}$ ]]; then
    red_bold "The provided host is invalid: $1"
  fi
}
