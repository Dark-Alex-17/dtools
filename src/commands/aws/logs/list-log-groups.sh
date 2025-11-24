# shellcheck disable=SC2155
declare aws_region="$(get-aws-region)"
declare aws_profile="$(get-aws-profile)"
# shellcheck disable=SC2154
declare detailed_format="${args[--detailed]}"

validate-or-refresh-aws-auth

declare log_groups=$(aws logs describe-log-groups --profile "$aws_profile" --region "$aws_region")

if [[ $detailed_format == 1 ]]; then
  jq . <<< "$log_groups"
else
  jq -r '.logGroups[].logGroupName' <<< "$log_groups"
fi
