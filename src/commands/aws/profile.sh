set-aws-profile() {
  if ( grep -q "AWS_PROFILE" ~/.bashrc ); then
    sed -i "/^AWS_PROFILE=/c\export AWS_PROFILE=$1" ~/.bashrc
	fi

	bash -c "export AWS_PROFILE=$1; exec bash"
}

declare profile
# shellcheck disable=SC2154
set-aws-profile "${args[profile]}"
