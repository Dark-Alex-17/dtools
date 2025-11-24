# shellcheck disable=SC2155
declare aws_region="$(get-aws-region)"
declare aws_profile="$(get-aws-profile)"
# shellcheck disable=SC2154
declare detailed_format="${args[--detailed]}"
declare parameter_name="${args[parameter_name]}"

validate-or-refresh-aws-auth

declare parameter_value=$(aws ssm get-parameter --name "$parameter_name" --profile "$aws_profile" --region "$aws_region")

if [[ $detailed_format == 1 ]]; then
  jq . <<< "$parameter_value"
else
  jq '.Parameter.Value' <<< "$parameter_value" | tr -d '"'
fi
