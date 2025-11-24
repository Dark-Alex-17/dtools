# shellcheck disable=SC2155
declare aws_profile="$(get-aws-profile)"
declare aws_region="$(get-aws-region)"

validate-or-refresh-aws-auth

if ( grep "AWS_PROFILE" ~/.bashrc > /dev/null 2>&1 ); then
  sed -i "/^AWS_PROFILE=/c\export AWS_PROFILE=$aws_profile" ~/.bashrc
fi

if ( grep "AWS_REGION" ~/.bashrc > /dev/null 2>&1 ); then
	sed -i "/^AWS_REGION=/c\export AWS_REGION=$aws_region" ~/.bashrc
fi

bash -c "export AWS_PROFILE=$aws_profile; export AWS_REGION=$aws_region; eval \"\$(aws configure export-credentials --format env --profile $aws_profile)\"; exec bash"
