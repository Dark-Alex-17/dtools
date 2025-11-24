# shellcheck disable=SC2155
declare aws_region="$(get-aws-region)"
declare aws_profile="$(get-aws-profile)"
# shellcheck disable=SC2154
declare parameter_name="${args[parameter_name]}"

validate-or-refresh-aws-auth

aws ssm delete-parameter --name "$parameter_name" --profile "$aws_profile" --region "$aws_region"
